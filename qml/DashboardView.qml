// DashboardView.qml - Embeddable root item for Qt Quick applications
//
// The standalone application wraps this item in a Window. Other applications
// can place DashboardView directly inside their own QML scene.

import QtQuick
import QtQuick.Layouts

/*!
    \qmltype DashboardView
    \inqmlmodule Dashboard
    \since 1.0
    \brief The main embeddable dashboard component.

    DashboardView displays dashboard pages and provides the public API for
    supplying data, loading JSON and CSV, retrieving REST data, and managing
    the dashboard layout.
*/

Item {
    id: root

    implicitWidth: 1400
    implicitHeight: 900

    /*! The optional Qt item model used as the dashboard data source. */
    property var dataModel: null

    /*! Whether the data source is currently loading remote data. */
    readonly property bool loading: dataSource.loading

    /*! The current dashboard widget layout. */
    property var dashboardLayout: [
        { id: "sales-line", title: "Sales by category", type: "line",
          x: 0, y: 0, w: 6, h: 3, xField: "category", yField: "sales" },
        { id: "orders-bar", title: "Orders by category", type: "bar",
          x: 6, y: 0, w: 6, h: 3, xField: "category", yField: "orders" },
        { id: "sales-donut", title: "Sales distribution", type: "donut",
          x: 0, y: 3, w: 5, h: 3, xField: "category", yField: "sales" },
        { id: "data-table", title: "All data", type: "table",
          x: 5, y: 3, w: 7, h: 3, xField: "category", yField: "sales" }
    ]

    readonly property var pageNames: [
        "Dashboard  /  Overview",
        "Analytics  /  Traffic & Engagement",
        "Reports  /  Documents & Exports",
        "Users  /  Management"
    ]

    /*! The records currently displayed by the dashboard. */
    readonly property var dataRows: dataSource.rows

    /*! Emitted when the dashboard layout changes. */
    signal layoutChanged(var layout)
    /*! Emitted when the application should persist the current layout. */
    signal saveLayoutRequested(var layout)
    /*! Emitted when a data-loading operation fails. */
    signal dataLoadFailed(string message)
    /*! Emitted when the reporting page generates a report. */
    signal reportGenerated(var report)
    /*! Emitted when the application is asked to export report data as CSV. */
    signal reportExportRequested(string fileName, string csv)

    /*! Replaces the current dashboard records. Returns whether the rows were accepted. */
    function setData(rows) {
        return dataSource.setRows(rows);
    }

    /*! Sets the Qt item model used as the dashboard data source. */
    function setDataModel(model) {
        if (dataModel === model)
            return dataSource.setSource(model);
        dataModel = model;
        return true;
    }

    /*! Loads records from a JSON string. */
    function loadJson(json) {
        return dataSource.loadJson(json);
    }

    /*! Loads records from CSV text with a header row. */
    function loadCsv(csv) {
        return dataSource.loadCsv(csv);
    }

    /*! Loads a local JSON or CSV file. */
    function loadFile(url) {
        return dataSource.loadFile(url);
    }

    /*! Loads JSON from an HTTP or HTTPS endpoint, optionally using a Bearer token. */
    function loadRest(url, bearerToken) {
        return dataSource.loadUrl(url, bearerToken || "");
    }

    /*! Applies a dashboard layout and returns whether it was accepted. */
    function setLayout(layout) {
        if (!builder)
            return false;
        if (!builder.setLayout(layout))
            return false;
        dashboardLayout = layout;
        return true;
    }

    DashboardDataSource {
        id: dataSource
        onErrorMessageChanged: {
            if (dataSource.errorMessage.length > 0)
                root.dataLoadFailed(dataSource.errorMessage);
        }
    }

    onDataModelChanged: dataSource.setSource(dataModel)

    onDashboardLayoutChanged: {
        if (builder && builder.widgets !== dashboardLayout)
            builder.setLayout(dashboardLayout);
    }

    Component.onCompleted: {
        if (dataModel === null && dataSource.rows.length === 0) {
            dataSource.setRows([
                { category: "Online", sales: 240, orders: 120, expenses: 72 },
                { category: "Retail", sales: 185, orders: 94, expenses: 63 },
                { category: "Wholesale", sales: 310, orders: 61, expenses: 110 },
                { category: "Partner", sales: 155, orders: 48, expenses: 52 },
                { category: "Mobile", sales: 205, orders: 108, expenses: 70 },
                { category: "Other", sales: 95, orders: 39, expenses: 33 }
            ]);
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.fillHeight: true

            onNavigationChanged: function(index) {
                pageStack.currentIndex = index;
                if (index >= 0 && index < root.pageNames.length) {
                    topBar.breadcrumbText = root.pageNames[index];
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            TopBar {
                id: topBar
                Layout.fillWidth: true
            }

            StackLayout {
                id: pageStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                DashboardBuilder {
                    id: builder
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    rows: root.dataRows
                    source: dataSource
                    widgets: root.dashboardLayout

                    onLayoutChanged: function(layout) {
                        root.dashboardLayout = layout;
                        root.layoutChanged(layout);
                    }
                    onSaveRequested: function(layout) {
                        root.saveLayoutRequested(layout);
                    }
                }
                AnalyticsPage {
                    rows: root.dataRows
                }
                ReportsPage {
                    rows: root.dataRows
                    onReportGenerated: function(report) {
                        root.reportGenerated(report);
                    }
                    onExportRequested: function(fileName, csv) {
                        root.reportExportRequested(fileName, csv);
                    }
                }
                UsersPage {}
            }
        }
    }
}
