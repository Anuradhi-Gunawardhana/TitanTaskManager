
#include "thmmonitor.h"

ThmMonitor::ThmMonitor(QObject *parent)
    : QObject(parent),
      m_path(ThmReader::defaultPath())
{
    connect(&m_timer, &QTimer::timeout,
            this, &ThmMonitor::refresh);

    refresh();
    m_timer.start(1000);
}

void ThmMonitor::refresh()
{
    m_state = ThmReader::read(m_path);
    emit updated();
}

bool ThmMonitor::available() const
{
    return m_state.available;
}

QString ThmMonitor::telemetryPath() const
{
    return m_path;
}

QString ThmMonitor::pressureLevel() const
{
    return m_state.pressureLevel;
}

double ThmMonitor::memoryUsage() const
{
    return m_state.memUsedPct;
}

double ThmMonitor::cpuPressure() const
{
    return m_state.cpuPsiSome;
}

double ThmMonitor::systemLoad() const
{
    return m_state.load1;
}

int ThmMonitor::workloadCount() const
{
    return m_state.workloadCount;
}

int ThmMonitor::activeWorkloads() const
{
    return m_state.activeWorkloads;
}

int ThmMonitor::processCount() const
{
    return m_state.processesSeen;
}

bool ThmMonitor::hyprlandConnected() const
{
    return m_state.hyprlandConnected;
}

QVariantList ThmMonitor::workloads() const
{
    return m_state.workloads;
}
