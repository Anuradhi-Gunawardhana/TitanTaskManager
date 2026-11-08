
#pragma once

#include <QString>
#include <QVariantList>

struct ThmState
{
    bool available = false;
    QString version;
    qint64 timestampMs = 0;
    qint64 uptimeSeconds = 0;

    QString pressureLevel;
    double psiSome = 0.0;
    double psiFull = 0.0;
    double memUsedPct = 0.0;
    qint64 memTotalKb = 0;
    qint64 memAvailableKb = 0;

    QString governor;

    int workloadCount = 0;
    int activeWorkloads = 0;
    int classifiedWorkloads = 0;
    int observedWorkloads = 0;

    double cpuPsiSome = 0.0;
    double load1 = 0.0;

    int processesSeen = 0;
    int processesProtected = 0;
    int processesAssigned = 0;
    int processesUnmanaged = 0;

    bool hyprlandConnected = false;

    bool hasLastAction = false;
    QString lastAction;
    QString lastActionTarget;
    int lastActionPid = 0;

    QVariantList workloads;
};

class ThmReader
{
public:
    static QString defaultPath();
    static ThmState read(const QString &path = QString());
};
