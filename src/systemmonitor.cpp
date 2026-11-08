
#include "systemmonitor.h"

#include <mach/mach.h>
#include <mach/host_info.h>

#include <sys/sysctl.h>
#include <sys/proc.h>
#include <sys/resource.h>
#include <signal.h>
#include <unistd.h>
#include <libproc.h>

#include <QVariantMap>
#include <algorithm>
#include <vector>

SystemMonitor::SystemMonitor(QObject *parent)
    : QObject(parent)
{
    processTimer.start();

    QTimer *timer = new QTimer(this);

    connect(timer, &QTimer::timeout,
            this, &SystemMonitor::updateMetrics);

    updateMetrics();
    timer->start(1000);
}

double SystemMonitor::cpuUsage() const
{
    return m_cpuUsage;
}

double SystemMonitor::memoryUsage() const
{
    return m_memoryUsage;
}

QString SystemMonitor::memoryText() const
{
    return m_memoryText;
}

int SystemMonitor::processCount() const
{
    return m_processCount;
}

QVariantList SystemMonitor::processes() const
{
    return m_processes;
}

bool SystemMonitor::terminateProcess(int pid)
{
    if (pid <= 1 || pid == getpid())
        return false;

    proc_bsdinfo info{};

    if (proc_pidinfo(
            pid,
            PROC_PIDTBSDINFO,
            0,
            &info,
            sizeof(info)
        ) <= 0) {
        return false;
    }

    // Only terminate processes owned by the current user.
    if (info.pbi_uid != getuid())
        return false;

    return kill(pid, SIGTERM) == 0;
}

void SystemMonitor::updateMetrics()
{
    // CPU monitoring
    natural_t cpuCount = 0;
    processor_info_array_t cpuInfo;
    mach_msg_type_number_t infoCount;

    kern_return_t result = host_processor_info(
        mach_host_self(),
        PROCESSOR_CPU_LOAD_INFO,
        &cpuCount,
        &cpuInfo,
        &infoCount
    );

    if (result == KERN_SUCCESS) {
        const int states = CPU_STATE_MAX;
        const size_t tickCount = cpuCount * states;

        bool hasPrevious = previousCpuTicks.size() == tickCount;

        double totalDelta = 0;
        double idleDelta = 0;

        for (natural_t i = 0; i < cpuCount; ++i) {
            unsigned long long total = 0;
            unsigned long long idle = 0;
            unsigned long long oldTotal = 0;
            unsigned long long oldIdle = 0;

            for (int j = 0; j < states; ++j) {
                auto tick = cpuInfo[i * states + j];

                total += tick;

                if (j == CPU_STATE_IDLE)
                    idle += tick;

                if (hasPrevious) {
                    auto oldTick = previousCpuTicks[i * states + j];

                    oldTotal += oldTick;

                    if (j == CPU_STATE_IDLE)
                        oldIdle += oldTick;
                }
            }

            if (hasPrevious) {
                totalDelta += total - oldTotal;
                idleDelta += idle - oldIdle;
            }
        }

        previousCpuTicks.resize(tickCount);

        for (size_t i = 0; i < tickCount; ++i)
            previousCpuTicks[i] = cpuInfo[i];

        if (hasPrevious && totalDelta > 0) {
            m_cpuUsage =
                (1.0 - idleDelta / totalDelta) * 100.0;
        }

        vm_deallocate(
            mach_task_self(),
            reinterpret_cast<vm_address_t>(cpuInfo),
            infoCount * sizeof(integer_t)
        );
    }

    // Memory monitoring
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t vmCount = HOST_VM_INFO64_COUNT;

    if (host_statistics64(
            mach_host_self(),
            HOST_VM_INFO64,
            reinterpret_cast<host_info64_t>(&vmStats),
            &vmCount
        ) == KERN_SUCCESS) {

        uint64_t totalMemory = 0;
        size_t size = sizeof(totalMemory);

        if (sysctlbyname(
                "hw.memsize",
                &totalMemory,
                &size,
                nullptr,
                0
            ) == 0) {

            uint64_t usedMemory =
                (vmStats.active_count +
                 vmStats.wire_count +
                 vmStats.compressor_page_count) * vm_page_size;

            if (totalMemory > 0) {
                m_memoryUsage =
                    (double(usedMemory) / totalMemory) * 100.0;

                m_memoryText = QString("%1 / %2 GB")
                    .arg(usedMemory / 1073741824.0, 0, 'f', 1)
                    .arg(totalMemory / 1073741824.0, 0, 'f', 1);
            }
        }
    }

    // Process monitoring
    int totalPids = proc_listallpids(nullptr, 0);

    QVariantList processList;
    QHash<int, quint64> currentProcessCpu;

    quint64 elapsedNs = processTimer.nsecsElapsed();

    if (totalPids > 0) {
        std::vector<pid_t> pids(totalPids + 64);

        int count = proc_listallpids(
            pids.data(),
            static_cast<int>(pids.size() * sizeof(pid_t))
        );

        for (int i = 0; i < count; ++i) {
            pid_t pid = pids[i];

            if (pid <= 0)
                continue;

            proc_bsdinfo info{};

            if (proc_pidinfo(
                    pid, PROC_PIDTBSDINFO, 0,
                    &info, sizeof(info)
                ) <= 0)
                continue;

            proc_taskinfo taskInfo{};

            if (proc_pidinfo(
                    pid, PROC_PIDTASKINFO, 0,
                    &taskInfo, sizeof(taskInfo)
                ) <= 0)
                continue;

            QVariantMap process;

            process["pid"] = pid;
            process["name"] = QString::fromUtf8(info.pbi_name);
            process["memory"] =
                taskInfo.pti_resident_size / 1048576.0;

            process["canTerminate"] =
                pid != getpid() &&
                pid > 1 &&
                info.pbi_uid == getuid();

            double cpu = 0;

            rusage_info_v2 usage{};

            if (proc_pid_rusage(
                    pid,
                    RUSAGE_INFO_V2,
                    reinterpret_cast<rusage_info_t *>(&usage)
                ) == 0) {

                quint64 cpuTime =
                    usage.ri_user_time + usage.ri_system_time;

                if (previousProcessCpu.contains(pid) &&
                    elapsedNs > 0) {

                    quint64 delta =
                        cpuTime - previousProcessCpu.value(pid);

                    cpu = double(delta) / elapsedNs * 100.0;
                }

                currentProcessCpu.insert(pid, cpuTime);
            }

            process["cpu"] = cpu;

            processList.append(process);
        }
    }

    previousProcessCpu = currentProcessCpu;
    processTimer.restart();

    std::sort(
        processList.begin(),
        processList.end(),
        [](const QVariant &a, const QVariant &b) {
            return a.toMap()["cpu"].toDouble() >
                   b.toMap()["cpu"].toDouble();
        }
    );

    m_processes = processList;
    m_processCount = processList.size();

    emit metricsUpdated();
}
