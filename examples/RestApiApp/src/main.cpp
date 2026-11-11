#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

#include <dashboard/dashboard_runtime.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    DashboardRuntime dashboard;

    dashboard.initialize(&engine, QCoreApplication::applicationDirPath() + "/db.sqlite");

    engine.loadFromModule("DashboardRestApiExample", "Main");

    return app.exec();
}