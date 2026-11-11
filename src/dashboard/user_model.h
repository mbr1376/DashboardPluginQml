#ifndef USERMODEL_H
#define USERMODEL_H

#include <QAbstractListModel>
#include <QSqlDatabase>
#include <QString>
#include <QVariant>
#include <QtQml/qqmlregistration.h>
class UserModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit UserModel(QObject *parent = nullptr);
    ~UserModel() override;

    enum UserRoles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        EmailRole,
        InitialsRole,
        RoleRole,
        StatusRole,
        LastActiveRole,
        ActivityRole,
        AvatarColorRole
    };

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    Q_INVOKABLE bool openDatabase(const QString &databasePath);

    Q_INVOKABLE bool reload();

    Q_INVOKABLE bool addUser(const QString &name,
                             const QString &email,
                             const QString &role,
                             const QString &status);

    Q_INVOKABLE bool removeUser(int id);

signals:

    void countChanged();
    void errorOccurred(const QString &message);

private:
    struct User
    {
        int id;
        QString name;
        QString email;
        QString initials;
        QString role;
        QString status;
        QString lastActive;
        int activity;
        QString avatarColor;
    };

    QList<User> m_users;

    QSqlDatabase m_database;
    QString m_connectionName;

    bool m_databaseReady = false;

    QString makeInitials(const QString &name) const;

    void notifyCountChanged();
};

#endif