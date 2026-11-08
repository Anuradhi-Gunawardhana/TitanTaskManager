
#include "thmstate.hpp"

#include <QByteArray>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QProcessEnvironment>
#include <QVariantMap>

QString ThmReader::defaultPath()
{
    const QString env =
        QProcessEnvironment::systemEnvironment()
        .value(QStringLiteral("THM_TELEMETRY_PATH"));

    if (!env.isEmpty())
        return env;

    return QStringLiteral("/run/archtitan/thm-state.json");
}

ThmState ThmReader::read(const QString &path)
{
    ThmState s;

    QFile file(path.isEmpty() ? defaultPath() : path);

    if (!file.open(QIODevice::ReadOnly))
        return s;

    const QByteArray raw = file.readAll();

    if (raw.isEmpty())
        return s;

    QJsonParseError error{};
    const QJsonDocument doc =
        QJsonDocument::fromJson(raw, &error);

    if (error.error != QJsonParseError::NoError ||
        !doc.isObject()) {
        return s;
    }

    const QJsonObject o = doc.object();

    s.available = true;
    s.version = o.value("version").toString();
    s.timestampMs = qint64(o.value("timestamp_ms").toDouble());
    s.uptimeSeconds = qint64(o.value("uptime_seconds").toDouble());

    const QJsonObject pressure =
        o.value("pressure").toObject();

    auto pressureValue = [&](const QString &key) {
        return pressure.contains(key)
            ? pressure.value(key)
            : o.value(key);
    };

    s.pressureLevel = pressureValue("level").toString();
    s.psiSome = pressureValue("psi_some_avg10").toDouble();
    s.psiFull = pressureValue("psi_full_avg10").toDouble();
    s.memUsedPct = pressureValue("mem_used_pct").toDouble();
    s.memTotalKb = qint64(pressureValue("mem_total_kb").toDouble());
    s.memAvailableKb = qint64(pressureValue("mem_available_kb").toDouble());

    s.governor = o.value("governor").toString();

    s.workloadCount = o.value("workload_count").toInt();
    s.activeWorkloads = o.value("active_workloads").toInt();
    s.classifiedWorkloads = o.value("classified_workloads").toInt();
    s.observedWorkloads = o.value("observed_workloads").toInt();

    const QJsonObject cpu = o.value("cpu").toObject();

    s.cpuPsiSome = cpu.value("psi_some_avg10").toDouble();
    s.load1 = cpu.value("load1").toDouble();

    const QJsonObject processes =
        o.value("processes").toObject();

    s.processesSeen = processes.value("seen").toInt();
    s.processesProtected = processes.value("protected").toInt();
    s.processesAssigned = processes.value("assigned").toInt();
    s.processesUnmanaged = processes.value("unmanaged").toInt();

    s.hyprlandConnected =
        processes.value("hyprland_connected").toBool();

    const QJsonValue last = o.value("last_action");

    if (last.isObject()) {
        const QJsonObject action = last.toObject();

        s.hasLastAction = true;
        s.lastAction = action.value("decision").toString();
        s.lastActionTarget = action.value("target").toString();
        s.lastActionPid = action.value("pid").toInt();
    }

    const QJsonArray workloads =
        o.value("workloads").toArray();

    for (const QJsonValue &value : workloads) {
        if (!value.isObject())
            continue;

        const QJsonObject w = value.toObject();

        QVariantMap item;

        item["id"] = w.value("id").toInt();
        item["pid"] = w.value("pid").toInt();
        item["workspace"] = w.value("workspace").toInt();
        item["name"] = w.value("name").toString();
        item["type"] = w.value("type").toString();
        item["state"] = w.value("state").toString();
        item["pids"] = w.value("pids").toInt();
        item["memMb"] = qint64(w.value("mem_mb").toDouble());
        item["cpuPct"] = w.value("cpu_pct").toDouble();
        item["observed"] = w.value("observed").toBool();

        s.workloads.append(item);
    }

    return s;
}
