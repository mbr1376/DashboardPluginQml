#ifndef DASHBOARD_PLUGIN_H
#define DASHBOARD_PLUGIN_H

#include <QObject>
#include <QString>

#include "user_model.h"

class DashboardPlugin : public QObject
{
    Q_OBJECT

    Q_PROPERTY(UserModel *users READ users CONSTANT)

public:
    explicit DashboardPlugin(QObject *parent = nullptr);

    UserModel *users();

    Q_INVOKABLE bool initializeDatabase(const QString &databasePath);

private:
    UserModel m_users;
};
#endif // DASHBOARD_PLUGIN_H
