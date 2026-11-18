#include "report/report_engine.h"

#include <QDate>
#include <QDateTime>
#include <QLocale>
#include <QMap>
#include <QSet>
#include <algorithm>
#include <cmath>

ReportEngine::ReportEngine(QObject *parent)
    : QObject(parent)
{}

QVariantList ReportEngine::rows() const
{
    return m_rows;
}
QVariantList ReportEngine::fields() const
{
    return m_fields;
}
QVariantList ReportEngine::numericFields() const
{
    return m_numericFields;
}
QVariantList ReportEngine::dateFields() const
{
    return m_dateFields;
}
QVariantList ReportEngine::booleanFields() const
{
    return m_booleanFields;
}
QVariantList ReportEngine::textFields() const
{
    return m_textFields;
}
QVariantList ReportEngine::filters() const
{
    return m_filters;
}
QVariantList ReportEngine::reportRows() const
{
    return m_reportRows;
}

QString ReportEngine::groupField() const
{
    return m_groupField;
}
QString ReportEngine::metricField() const
{
    return m_metricField;
}
QString ReportEngine::aggregation() const
{
    return m_aggregation;
}

int ReportEngine::sourceRecordCount() const
{
    return m_rows.size();
}

int ReportEngine::filteredRecordCount() const
{
    return filteredRows().size();
}

void ReportEngine::setRows(const QVariantList &rows)
{
    m_rows = rows;
    analyze();
    emit rowsChanged();
}

void ReportEngine::setGroupField(const QString &field)
{
    if (m_groupField == field)
        return;

    m_groupField = field;
    emit configurationChanged();
    rebuildReportRows();
}

void ReportEngine::setMetricField(const QString &field)
{
    if (m_metricField == field)
        return;

    m_metricField = field;
    emit configurationChanged();
    rebuildReportRows();
}

void ReportEngine::setAggregation(const QString &aggregation)
{
    static const QStringList allowed = {"sum", "average", "count", "minimum", "maximum"};

    if (!allowed.contains(aggregation) || m_aggregation == aggregation)
        return;

    m_aggregation = aggregation;
    emit configurationChanged();
    rebuildReportRows();
}

bool ReportEngine::toNumber(const QVariant &value, double *result) const
{
    if (!value.isValid() || value.isNull())
        return false;

    if (value.metaType().id() == QMetaType::Bool)
        return false;

    bool ok = false;
    double number = 0.0;

    if (value.metaType().id() == QMetaType::QString) {
        const QString text = value.toString().trimmed();

        if (text.isEmpty())
            return false;

        number = QLocale::c().toDouble(text, &ok);
    } else {
        number = value.toDouble(&ok);
    }

    if (!ok || !std::isfinite(number))
        return false;

    *result = number;
    return true;
}

QDateTime ReportEngine::toDateTime(const QVariant &value) const
{
    if (!value.isValid() || value.isNull())
        return {};

    if (value.metaType().id() == QMetaType::QDateTime)
        return value.toDateTime();

    if (value.metaType().id() == QMetaType::QDate)
        return QDateTime(value.toDate(), QTime(0, 0));

    const QString text = value.toString().trimmed();

    if (text.isEmpty())
        return {};

    QDateTime dateTime = QDateTime::fromString(text, Qt::ISODateWithMs);

    if (!dateTime.isValid())
        dateTime = QDateTime::fromString(text, Qt::ISODate);

    if (dateTime.isValid())
        return dateTime;

    const QDate date = QDate::fromString(text, Qt::ISODate);

    if (date.isValid())
        return QDateTime(date, QTime(0, 0));

    return {};
}

ReportEngine::FieldType ReportEngine::detectFieldType(const QString &field) const
{
    bool hasText = false;
    bool hasNumber = false;
    bool hasDate = false;
    bool hasBoolean = false;

    for (const QVariant &item : m_rows) {
        const QVariantMap row = item.toMap();

        if (!row.contains(field))
            continue;

        const QVariant value = row.value(field);

        if (!value.isValid() || value.isNull() || value.toString().trimmed().isEmpty()) {
            continue;
        }

        if (value.metaType().id() == QMetaType::Bool) {
            hasBoolean = true;
            continue;
        }

        const QString text = value.toString().trimmed().toLower();

        if (text == "true" || text == "false") {
            hasBoolean = true;
            continue;
        }

        if (toDateTime(value).isValid()) {
            hasDate = true;
            continue;
        }

        double number = 0;
        if (toNumber(value, &number)) {
            hasNumber = true;
            continue;
        }

        hasText = true;
    }

    const int detectedTypes = int(hasText) + int(hasNumber) + int(hasDate) + int(hasBoolean);

    if (detectedTypes > 1)
        return FieldType::Mixed;

    if (hasBoolean)
        return FieldType::Boolean;
    if (hasDate)
        return FieldType::DateTime;
    if (hasNumber)
        return FieldType::Numeric;

    return FieldType::Text;
}

QString ReportEngine::fieldTypeName(FieldType type) const
{
    switch (type) {
    case FieldType::Numeric:
        return "numeric";
    case FieldType::DateTime:
        return "date";
    case FieldType::Boolean:
        return "boolean";
    case FieldType::Mixed:
        return "mixed";
    default:
        return "text";
    }
}

void ReportEngine::analyze()
{
    QSet<QString> names;

    // Union of keys across all records, not just the first record.
    for (const QVariant &item : m_rows) {
        const QVariantMap row = item.toMap();

        for (auto it = row.cbegin(); it != row.cend(); ++it)
            names.insert(it.key());
    }

    QStringList sortedNames = names.values();
    std::sort(sortedNames.begin(), sortedNames.end());

    m_fields.clear();
    m_numericFields.clear();
    m_dateFields.clear();
    m_booleanFields.clear();
    m_textFields.clear();

    for (const QString &name : sortedNames) {
        const FieldType type = detectFieldType(name);

        m_fields.append(name);
        switch (type) {
        case FieldType::Numeric:
            m_numericFields.append(name);
            break;
        case FieldType::DateTime:
            m_dateFields.append(name);
            break;
        case FieldType::Boolean:
            m_booleanFields.append(name);
            break;
        case FieldType::Text:
        case FieldType::Mixed:
            m_textFields.append(name);
            break;
        }
    }

    if (!m_groupField.isEmpty() && !names.contains(m_groupField))
        m_groupField.clear();

    if (!m_metricField.isEmpty() && !m_numericFields.contains(m_metricField))
        m_metricField.clear();

    if (m_groupField.isEmpty() && !sortedNames.isEmpty())
        m_groupField = sortedNames.first();

    if (m_metricField.isEmpty() && !m_numericFields.isEmpty())
        m_metricField = m_numericFields.first().toString();

    emit fieldsChanged();
    emit configurationChanged();

    rebuildReportRows();
}

void ReportEngine::setFilter(const QString &field,
                             const QString &operation,
                             const QVariant &value,
                             const QVariant &value2)
{
    if (field.isEmpty())
        return;

    removeFilter(field);

    m_filters.append(QVariantMap{{"field", field},
                                 {"operator", operation},
                                 {"value", value},
                                 {"value2", value2}});

    emit filtersChanged();
    rebuildReportRows();
}

void ReportEngine::removeFilter(const QString &field)
{
    QVariantList updated;

    for (const QVariant &item : m_filters) {
        if (item.toMap().value("field").toString() != field)
            updated.append(item);
    }

    if (updated.size() == m_filters.size())
        return;

    m_filters = updated;
    emit filtersChanged();
    rebuildReportRows();
}

void ReportEngine::clearFilters()
{
    if (m_filters.isEmpty())
        return;

    m_filters.clear();
    emit filtersChanged();
    rebuildReportRows();
}

bool ReportEngine::matchesFilter(const QVariant &actual,
                                 const QString &operation,
                                 const QVariant &value,
                                 const QVariant &value2) const
{
    const QString text = actual.toString();
    const QString expected = value.toString();

    if (operation == "isEmpty")
        return !actual.isValid() || actual.isNull() || text.trimmed().isEmpty();

    if (operation == "isNotEmpty")
        return actual.isValid() && !actual.isNull() && !text.trimmed().isEmpty();

    if (operation == "contains")
        return text.contains(expected, Qt::CaseInsensitive);

    if (operation == "equals")
        return text.compare(expected, Qt::CaseInsensitive) == 0;

    if (operation == "startsWith")
        return text.startsWith(expected, Qt::CaseInsensitive);

    if (operation == "endsWith")
        return text.endsWith(expected, Qt::CaseInsensitive);

    double actualNumber = 0;
    double expectedNumber = 0;
    double secondNumber = 0;

    const bool numeric = toNumber(actual, &actualNumber) && toNumber(value, &expectedNumber);

    if (numeric) {
        if (operation == "gt")
            return actualNumber > expectedNumber;
        if (operation == "gte")
            return actualNumber >= expectedNumber;
        if (operation == "lt")
            return actualNumber < expectedNumber;
        if (operation == "lte")
            return actualNumber <= expectedNumber;

        if (operation == "between" && toNumber(value2, &secondNumber)) {
            return actualNumber >= expectedNumber && actualNumber <= secondNumber;
        }
    }

    const QDateTime actualDate = toDateTime(actual);
    const QDateTime expectedDate = toDateTime(value);

    if (actualDate.isValid() && expectedDate.isValid()) {
        if (operation == "before")
            return actualDate < expectedDate;
        if (operation == "after")
            return actualDate > expectedDate;

        const QDateTime secondDate = toDateTime(value2);

        if (operation == "between" && secondDate.isValid()) {
            return actualDate >= expectedDate && actualDate <= secondDate;
        }
    }

    return false;
}

bool ReportEngine::matchesFilters(const QVariantMap &row) const
{
    for (const QVariant &item : m_filters) {
        const QVariantMap filter = item.toMap();
        const QString field = filter.value("field").toString();

        if (!matchesFilter(row.value(field),
                           filter.value("operator").toString(),
                           filter.value("value"),
                           filter.value("value2"))) {
            return false;
        }
    }

    return true;
}

QVariantList ReportEngine::filteredRows() const
{
    QVariantList result;

    for (const QVariant &item : m_rows) {
        const QVariantMap row = item.toMap();

        if (matchesFilters(row))
            result.append(row);
    }

    return result;
}

void ReportEngine::rebuildReportRows()
{
    struct GroupData
    {
        double sum = 0;
        double minimum = 0;
        double maximum = 0;
        int numericCount = 0;
        int records = 0;
        bool initialized = false;
        QString label;
    };

    QMap<QString, GroupData> groups;
    const QVariantList source = filteredRows();

    for (const QVariant &item : source) {
        const QVariantMap row = item.toMap();

        const QString label = m_groupField.isEmpty() ? QStringLiteral("All records")
                                                     : row.value(m_groupField).toString();

        // Prefix avoids collisions with special map keys.
        const QString key = QStringLiteral("$") + label;

        GroupData &group = groups[key];
        group.label = label;
        group.records++;

        double number = 0;

        if (!m_metricField.isEmpty() && toNumber(row.value(m_metricField), &number)) {
            group.sum += number;
            group.numericCount++;

            if (!group.initialized) {
                group.minimum = number;
                group.maximum = number;
                group.initialized = true;
            } else {
                group.minimum = std::min(group.minimum, number);
                group.maximum = std::max(group.maximum, number);
            }
        }
    }

    m_reportRows.clear();

    for (auto it = groups.cbegin(); it != groups.cend(); ++it) {
        const GroupData &group = it.value();

        double result = 0;

        if (m_aggregation == "count") {
            result = group.records;
        } else if (group.numericCount > 0) {
            if (m_aggregation == "average")
                result = group.sum / group.numericCount;
            else if (m_aggregation == "minimum")
                result = group.minimum;
            else if (m_aggregation == "maximum")
                result = group.maximum;
            else
                result = group.sum;
        }

        m_reportRows.append(
            QVariantMap{{"group", group.label}, {"value", result}, {"records", group.records}});
    }

    emit reportRowsChanged();
}

void ReportEngine::generateReport()
{
    const QVariantMap report{{"groupField", m_groupField.isEmpty() ? "All records" : m_groupField},
                             {"metricField", m_aggregation == "count" ? "records" : m_metricField},
                             {"aggregation", m_aggregation},
                             {"sourceRecordCount", m_rows.size()},
                             {"filteredRecordCount", filteredRows().size()},
                             {"rows", m_reportRows}};

    emit reportGenerated(report);
}