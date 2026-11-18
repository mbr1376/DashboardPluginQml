#include "dashboard/dashboard_runtime.h"
#include "dashboard/user_model.h"

#include <QDebug>
#include <QQmlContext>

DashboardRuntime::DashboardRuntime(QObject *parent)
    : QObject(parent)
{}

bool DashboardRuntime::initialize(QQmlApplicationEngine *engine, const QString &databasePath)
{
    if (!engine) {
        qWarning() << "Invalid QML engine";
        return false;
    }

    if (!m_userModel)
        m_userModel = new UserModel(this);

    if (!m_userModel->openDatabase(databasePath)) {
        qWarning() << "Database initialization failed";
        return false;
    }

    engine->rootContext()->setContextProperty("userModel", m_userModel);

    return true;
}