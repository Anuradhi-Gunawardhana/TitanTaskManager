
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setApplicationName("Titan Task Manager");
    app.setOrganizationName("ArchTitan");

    QQmlApplicationEngine engine;

    engine.loadFromModule("TitanTaskManager", "Main");

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
