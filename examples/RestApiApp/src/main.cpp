#include <QDir>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStandardPaths>

#include <dashboard/dashboard_plugin.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    engine.addImportPath(QStringLiteral(DASHBOARD_QML_IMPORT_PATH));

    DashboardPlugin dashboard;

    QString dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);

    QDir().mkpath(dataPath);

    QString databasePath = dataPath + "/dashboard.db";

    if (!dashboard.initializeDatabase(databasePath))
        return -1;

    engine.rootContext()->setContextProperty("Dashboard", &dashboard);

    engine.loadFromModule("DashboardRestApiExample", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}