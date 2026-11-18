#pragma once

#include <QObject>
#include <QStringList>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class ReportEngine : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QVariantList rows READ rows WRITE setRows NOTIFY rowsChanged)
    Q_PROPERTY(QVariantList fields READ fields NOTIFY fieldsChanged)
    Q_PROPERTY(QVariantList numericFields READ numericFields NOTIFY fieldsChanged)
    Q_PROPERTY(QVariantList dateFields READ dateFields NOTIFY fieldsChanged)
    Q_PROPERTY(QVariantList booleanFields READ booleanFields NOTIFY fieldsChanged)
    Q_PROPERTY(QVariantList textFields READ textFields NOTIFY fieldsChanged)

    Q_PROPERTY(QVariantList filters READ filters NOTIFY filtersChanged)
    Q_PROPERTY(QVariantList reportRows READ reportRows NOTIFY reportRowsChanged)

    Q_PROPERTY(QString groupField READ groupField WRITE setGroupField NOTIFY configurationChanged)
    Q_PROPERTY(QString metricField READ metricField WRITE setMetricField NOTIFY configurationChanged)
    Q_PROPERTY(QString aggregation READ aggregation WRITE setAggregation NOTIFY configurationChanged)

    Q_PROPERTY(int sourceRecordCount READ sourceRecordCount NOTIFY rowsChanged)
    Q_PROPERTY(int filteredRecordCount READ filteredRecordCount NOTIFY reportRowsChanged)

public:
    explicit ReportEngine(QObject *parent = nullptr);

    QVariantList rows() const;
    void setRows(const QVariantList &rows);

    QVariantList fields() const;
    QVariantList numericFields() const;
    QVariantList dateFields() const;
    QVariantList booleanFields() const;
    QVariantList textFields() const;

    QVariantList filters() const;
    QVariantList reportRows() const;

    QString groupField() const;
    void setGroupField(const QString &field);

    QString metricField() const;
    void setMetricField(const QString &field);

    QString aggregation() const;
    void setAggregation(const QString &aggregation);

    int sourceRecordCount() const;
    int filteredRecordCount() const;

    Q_INVOKABLE void analyze();
    Q_INVOKABLE void generateReport();
    Q_INVOKABLE void setFilter(const QString &field,
                               const QString &operation,
                               const QVariant &value,
                               const QVariant &value2 = QVariant());
    Q_INVOKABLE void removeFilter(const QString &field);
    Q_INVOKABLE void clearFilters();

signals:
    void rowsChanged();
    void fieldsChanged();
    void filtersChanged();
    void reportRowsChanged();
    void configurationChanged();
    void reportGenerated(const QVariantMap &report);
    void errorOccurred(const QString &message);

private:
    enum class FieldType { Text, Numeric, DateTime, Boolean, Mixed };

    FieldType detectFieldType(const QString &field) const;
    QString fieldTypeName(FieldType type) const;

    bool matchesFilters(const QVariantMap &row) const;
    bool matchesFilter(const QVariant &actual,
                       const QString &operation,
                       const QVariant &value,
                       const QVariant &value2) const;

    bool toNumber(const QVariant &value, double *result) const;
    QDateTime toDateTime(const QVariant &value) const;

    QVariantList filteredRows() const;
    void rebuildReportRows();

private:
    QVariantList m_rows;
    QVariantList m_fields;
    QVariantList m_numericFields;
    QVariantList m_dateFields;
    QVariantList m_booleanFields;
    QVariantList m_textFields;
    QVariantList m_filters;
    QVariantList m_reportRows;

    QString m_groupField;
    QString m_metricField;
    QString m_aggregation = "sum";
};