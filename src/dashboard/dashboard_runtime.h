#ifndef DASHBOARD_RUNTIME_H
#define DASHBOARD_RUNTIME_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <QString>

class UserModel;

class DashboardRuntime : public QObject
{
    Q_OBJECT

public:
    explicit DashboardRuntime(QObject *parent = nullptr);

    bool initialize(QQmlApplicationEngine *engine, const QString &databasePath);

private:
    UserModel *m_userModel = nullptr;
};

#endif // DASHBOARD_RUNTIME_H
