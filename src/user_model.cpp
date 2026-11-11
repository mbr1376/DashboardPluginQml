#include "dashboard/user_model.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QVariant>

#include <QUuid>

UserModel::UserModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_connectionName = "DashboardUsers_" + QUuid::createUuid().toString(QUuid::WithoutBraces);

    m_database = QSqlDatabase::addDatabase("QSQLITE", m_connectionName);
}

UserModel::~UserModel()
{
    if (m_database.isValid()) {
        m_database.close();
    }

    m_database = QSqlDatabase();

    QSqlDatabase::removeDatabase(m_connectionName);
}

int UserModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_users.count();
}

int UserModel::count() const
{
    return m_users.count();
}

void UserModel::notifyCountChanged()
{
    emit countChanged();
}

QVariant UserModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_users.size()) {
        return {};
    }

    const User &user = m_users.at(index.row());

    switch (role) {
    case IdRole:
        return user.id;

    case NameRole:
        return user.name;

    case EmailRole:
        return user.email;

    case InitialsRole:
        return user.initials;

    case RoleRole:
        return user.role;

    case StatusRole:
        return user.status;

    case LastActiveRole:
        return user.lastActive;

    case ActivityRole:
        return user.activity;

    case AvatarColorRole:
        return user.avatarColor;

    default:
        return {};
    }
}

QHash<int, QByteArray> UserModel::roleNames() const
{
    return {{IdRole, "userId"},
            {NameRole, "name"},
            {EmailRole, "email"},
            {InitialsRole, "initials"},
            {RoleRole, "role"},
            {StatusRole, "status"},
            {LastActiveRole, "lastActive"},
            {ActivityRole, "activity"},
            {AvatarColorRole, "avatarColor"}};
}

// =====================================================
// INITIALS
// =====================================================

QString UserModel::makeInitials(const QString &name) const
{
    const QStringList parts = name.split(' ', Qt::SkipEmptyParts);

    if (parts.isEmpty())
        return "?";

    QString result;

    result += parts.first().left(1).toUpper();

    if (parts.size() > 1)
        result += parts.last().left(1).toUpper();

    return result;
}

// =====================================================
// OPEN DATABASE
// =====================================================

bool UserModel::openDatabase(const QString &databasePath)
{
    if (databasePath.trimmed().isEmpty()) {
        emit errorOccurred("Database path is empty");
        return false;
    }

    if (m_database.isOpen())
        m_database.close();

    m_database.setDatabaseName(databasePath);

    if (!m_database.open()) {
        emit errorOccurred("Database connection failed: " + m_database.lastError().text());

        m_databaseReady = false;
        return false;
    }

    m_databaseReady = true;

    // Create table if it does not exist.
    QSqlQuery query(m_database);

    const QString createTable = R"(
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            role TEXT NOT NULL DEFAULT 'Viewer',
            status TEXT NOT NULL DEFAULT 'Active',
            last_active TEXT,
            activity INTEGER DEFAULT 0,
            avatar_color TEXT DEFAULT '#3498db'
        )
    )";

    if (!query.exec(createTable)) {
        emit errorOccurred("Cannot create users table: " + query.lastError().text());

        return false;
    }

    return reload();
}

// =====================================================
// LOAD USERS
// =====================================================

bool UserModel::reload()
{
    if (!m_databaseReady || !m_database.isOpen()) {
        emit errorOccurred("Database is not connected");
        return false;
    }

    QSqlQuery query(m_database);

    const QString sql = R"(
        SELECT
            id,
            name,
            email,
            role,
            status,
            last_active,
            activity,
            avatar_color
        FROM users
        ORDER BY id DESC
    )";

    if (!query.exec(sql)) {
        emit errorOccurred("Cannot load users: " + query.lastError().text());

        return false;
    }

    QList<User> newUsers;

    while (query.next()) {
        User user;

        user.id = query.value("id").toInt();
        user.name = query.value("name").toString();
        user.email = query.value("email").toString();

        user.initials = makeInitials(user.name);

        user.role = query.value("role").toString();
        user.status = query.value("status").toString();

        user.lastActive = query.value("last_active").toString();

        user.activity = query.value("activity").toInt();

        user.avatarColor = query.value("avatar_color").toString();

        if (user.avatarColor.isEmpty())
            user.avatarColor = "#3498db";

        newUsers.append(user);
    }

    beginResetModel();

    m_users = newUsers;

    endResetModel();

    notifyCountChanged();

    return true;
}

// =====================================================
// ADD USER
// =====================================================

bool UserModel::addUser(const QString &name,
                        const QString &email,
                        const QString &role,
                        const QString &status)
{
    if (!m_databaseReady)
        return false;

    if (name.trimmed().isEmpty() || email.trimmed().isEmpty()) {
        emit errorOccurred("Name and email are required");
        return false;
    }

    QSqlQuery query(m_database);

    query.prepare(R"(
        INSERT INTO users
        (name, email, role, status, last_active,
         activity, avatar_color)
        VALUES
        (:name, :email, :role, :status, :lastActive,
         :activity, :avatarColor)
    )");

    query.bindValue(":name", name.trimmed());
    query.bindValue(":email", email.trimmed());
    query.bindValue(":role", role);
    query.bindValue(":status", status);
    query.bindValue(":lastActive", "Just now");
    query.bindValue(":activity", 0);
    query.bindValue(":avatarColor", "#3498db");

    if (!query.exec()) {
        emit errorOccurred("Cannot add user: " + query.lastError().text());

        return false;
    }

    return reload();
}

// =====================================================
// REMOVE USER
// =====================================================

bool UserModel::removeUser(int id)
{
    if (!m_databaseReady)
        return false;

    QSqlQuery query(m_database);

    query.prepare("DELETE FROM users WHERE id = :id");

    query.bindValue(":id", id);

    if (!query.exec()) {
        emit errorOccurred("Cannot remove user: " + query.lastError().text());

        return false;
    }

    if (query.numRowsAffected() == 0)
        return false;

    return reload();
}