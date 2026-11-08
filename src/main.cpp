
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "systemmonitor.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setApplicationName("Titan Task Manager");
    app.setOrganizationName("ArchTitan");

    SystemMonitor monitor;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "systemMonitor", &monitor
    );

    engine.loadFromModule("TitanTaskManager", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
