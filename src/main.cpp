
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "systemmonitor.h"
#include "thmmonitor.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setApplicationName("Titan Task Manager");
    app.setOrganizationName("ArchTitan");

    SystemMonitor systemMonitor;
    ThmMonitor thmMonitor;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(
        "systemMonitor", &systemMonitor
    );

    engine.rootContext()->setContextProperty(
        "thmMonitor", &thmMonitor
    );

    engine.loadFromModule("TitanTaskManager", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
