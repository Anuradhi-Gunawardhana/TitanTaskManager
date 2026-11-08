
#ifndef SYSTEMMONITOR_H
#define SYSTEMMONITOR_H

#include <QObject>
#include <QTimer>
#include <QString>
#include <vector>

class SystemMonitor : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY metricsUpdated)
    Q_PROPERTY(double memoryUsage READ memoryUsage NOTIFY metricsUpdated)
    Q_PROPERTY(QString memoryText READ memoryText NOTIFY metricsUpdated)
    Q_PROPERTY(int processCount READ processCount NOTIFY metricsUpdated)

public:
    explicit SystemMonitor(QObject *parent = nullptr);

    double cpuUsage() const;
    double memoryUsage() const;
    QString memoryText() const;
    int processCount() const;

signals:
    void metricsUpdated();

private slots:
    void updateMetrics();

private:
    double m_cpuUsage = 0;
    double m_memoryUsage = 0;
    QString m_memoryText = "0 GB";
    int m_processCount = 0;

    std::vector<unsigned long long> previousCpuTicks;
};

#endif
