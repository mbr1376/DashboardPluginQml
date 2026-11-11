#include "dashboard/database_config.h"

DatabaseConfig::DatabaseConfig(QObject *parent)
    : QObject(parent)
{}

QString DatabaseConfig::databasePath() const
{
    return m_databasePath;
}

void DatabaseConfig::setDatabasePath(const QString &path)
{
    if (m_databasePath == path)
        return;

    m_databasePath = path;
    emit databasePathChanged();
}