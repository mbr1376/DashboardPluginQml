#include "dashboard_plugin.h"

DashboardPlugin::DashboardPlugin(QObject *parent)
    : QObject(parent)
    , m_users(this)
{}

UserModel *DashboardPlugin::users()
{
    return &m_users;
}

bool DashboardPlugin::initializeDatabase(const QString &databasePath)
{
    return m_users.openDatabase(databasePath);
}