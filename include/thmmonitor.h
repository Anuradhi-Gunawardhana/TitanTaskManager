
#pragma once

#include <QObject>
#include <QTimer>
#include <QVariantList>

#include "thmstate.hpp"

class ThmMonitor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool available READ available NOTIFY updated)
    Q_PROPERTY(QString telemetryPath READ telemetryPath CONSTANT)
    Q_PROPERTY(QString pressureLevel READ pressureLevel NOTIFY updated)
    Q_PROPERTY(double memoryUsage READ memoryUsage NOTIFY updated)
    Q_PROPERTY(double cpuPressure READ cpuPressure NOTIFY updated)
    Q_PROPERTY(double systemLoad READ systemLoad NOTIFY updated)
    Q_PROPERTY(int workloadCount READ workloadCount NOTIFY updated)
    Q_PROPERTY(int activeWorkloads READ activeWorkloads NOTIFY updated)
    Q_PROPERTY(int processCount READ processCount NOTIFY updated)
    Q_PROPERTY(bool hyprlandConnected READ hyprlandConnected NOTIFY updated)
    Q_PROPERTY(QVariantList workloads READ workloads NOTIFY updated)

public:
    explicit ThmMonitor(QObject *parent = nullptr);

    bool available() const;
    QString telemetryPath() const;
    QString pressureLevel() const;
    double memoryUsage() const;
    double cpuPressure() const;
    double systemLoad() const;
    int workloadCount() const;
    int activeWorkloads() const;
    int processCount() const;
    bool hyprlandConnected() const;
    QVariantList workloads() const;

signals:
    void updated();

private slots:
    void refresh();

private:
    ThmState m_state;
    QString m_path;
    QTimer m_timer;
};
