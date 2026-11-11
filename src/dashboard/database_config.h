#ifndef DATABASE_CONFIG_H
#define DATABASE_CONFIG_H
#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class DatabaseConfig : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(
        QString databasePath READ databasePath WRITE setDatabasePath NOTIFY databasePathChanged)

public:
    explicit DatabaseConfig(QObject *parent = nullptr);

    QString databasePath() const;

    void setDatabasePath(const QString &path);

signals:
    void databasePathChanged();

private:
    QString m_databasePath;
};
#endif // DATABASE_CONFIG_H
