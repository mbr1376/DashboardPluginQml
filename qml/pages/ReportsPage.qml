import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Dashboard 1.0

Flickable {
    id: root

    // داده ورودی؛ آرایه‌ای از رکوردهای داینامیک
    property var rows: []

    // موتور گزارش C++
    ReportEngine {
        id: reportEngine
        rows: root.rows
    }

    // اتصال به اطلاعات موتور گزارش
    property var fields: reportEngine.fields
    property var numericFields: reportEngine.numericFields
    property var dateFields: reportEngine.dateFields
    property var booleanFields: reportEngine.booleanFields
    property var textFields: reportEngine.textFields
    property var reportRows: reportEngine.reportRows

    property string groupField: reportEngine.groupField
    property string metricField: reportEngine.metricField
    property string aggregation: reportEngine.aggregation

    property string searchText: ""
    property string filterField: ""
    property string filterOperator: "contains"
    property string filterValue: ""
    property string filterValue2: ""

    property var lastGeneratedReport: null

    signal reportGenerated(var report)
    signal exportRequested(string fileName, string csv)

    contentWidth: width
    contentHeight: contentColumn.implicitHeight + 48
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    // ---------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------

    function fieldType(fieldName) {
        for (var i = 0; i < fields.length; ++i) {
            var item = fields[i];

            if (typeof item === "string") {
                if (item === fieldName)
                    return "text";
            } else if (item.name === fieldName) {
                return item.type || "text";
            }
        }

        return "text";
    }

    function filterOperators() {
        var type = fieldType(filterField);

        if (type === "numeric") {
            return ["equals", "gt", "gte", "lt", "lte", "between", "isEmpty", "isNotEmpty"];
        }

        if (type === "date") {
            return ["before", "after", "between", "equals", "isEmpty", "isNotEmpty"];
        }

        if (type === "boolean") {
            return ["equals", "isEmpty", "isNotEmpty"];
        }

        return ["contains", "equals", "startsWith", "endsWith", "isEmpty", "isNotEmpty"];
    }

    function filterInputEnabled() {
        return filterOperator !== "isEmpty" && filterOperator !== "isNotEmpty";
    }

    function filterReportRows() {
        var query = searchText.trim().toLowerCase();

        if (!query)
            return reportRows;

        var result = [];

        for (var i = 0; i < reportRows.length; ++i) {
            var row = reportRows[i];

            if (String(row.group).toLowerCase().indexOf(query) >= 0 || String(row.value).toLowerCase().indexOf(query) >= 0 || String(row.records).toLowerCase().indexOf(query) >= 0) {
                result.push(row);
            }
        }

        return result;
    }

    property var visibleReportRows: filterReportRows()

    function applyFilter() {
        if (!filterField)
            return;

        if (filterOperator === "isEmpty" || filterOperator === "isNotEmpty") {
            reportEngine.setFilter(filterField, filterOperator, "");
        } else if (filterOperator === "between") {
            reportEngine.setFilter(filterField, filterOperator, filterValue, filterValue2);
        } else {
            reportEngine.setFilter(filterField, filterOperator, filterValue);
        }

        lastGeneratedReport = null;
    }

    function clearAllFilters() {
        reportEngine.clearFilters();
        filterValue = "";
        filterValue2 = "";
        lastGeneratedReport = null;
    }

    function removeSingleFilter(fieldName) {
        reportEngine.removeFilter(fieldName);
        lastGeneratedReport = null;
    }

    function csvEscape(value) {
        var text = String(value === undefined || value === null ? "" : value);

        return '"' + text.replace(/"/g, '""') + '"';
    }

    function reportCsv(report) {
        var lines = [];

        lines.push([report.groupField, report.aggregation + " " + report.metricField, "records"].map(csvEscape).join(","));

        for (var i = 0; i < report.rows.length; ++i) {
            var item = report.rows[i];

            lines.push([item.group, item.value, item.records].map(csvEscape).join(","));
        }

        // UTF-8 BOM برای نمایش صحیح فارسی در Excel
        return "\uFEFF" + lines.join("\r\n");
    }

    function generateReport() {
        reportEngine.generateReport();
    }

    function exportReport() {
        if (!lastGeneratedReport)
            generateReport();

        if (!lastGeneratedReport)
            return;

        exportRequested("dashboard-report.csv", reportCsv(lastGeneratedReport));
    }

    function aggregationLabel(value) {
        switch (value) {
        case "sum":
            return "Sum";
        case "average":
            return "Average";
        case "count":
            return "Count";
        case "minimum":
            return "Minimum";
        case "maximum":
            return "Maximum";
        default:
            return value;
        }
    }

    function formatNumber(value) {
        return Number(value).toLocaleString(Qt.locale(), "f", 2);
    }

    // ---------------------------------------------------------
    // Engine connections
    // ---------------------------------------------------------

    Connections {
        target: reportEngine

        function onReportGenerated(generatedReport) {
            var report = {
                title: reportTitle.text.trim() || "Dashboard report",
                groupField: generatedReport.groupField,
                metricField: generatedReport.metricField,
                aggregation: generatedReport.aggregation,
                sourceRecordCount: generatedReport.sourceRecordCount,
                filteredRecordCount: generatedReport.filteredRecordCount,
                rows: generatedReport.rows
            };

            root.lastGeneratedReport = report;
            root.reportGenerated(report);
        }

        function onErrorOccurred(message) {
            console.error("ReportEngine:", message);
        }

        function onReportRowsChanged() {
            root.lastGeneratedReport = null;
        }

        function onFieldsChanged() {
            if (root.fields.length > 0 && !root.filterField)
                root.filterField = root.fields[0].name || root.fields[0];
        }
    }

    onRowsChanged: {
        lastGeneratedReport = null;
    }

    // ---------------------------------------------------------
    // Main layout
    // ---------------------------------------------------------

    ColumnLayout {
        id: contentColumn

        width: Math.max(0, root.width - 48)
        x: 24
        y: 20
        spacing: 18

        // -----------------------------------------------------
        // Header
        // -----------------------------------------------------

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true

                text: "Reports"
                color: Theme.textPrimary

                font {
                    pixelSize: 24
                    bold: true
                    family: Theme.fontFamily
                }
            }

            Text {
                text: root.rows.length + " source records"
                color: Theme.textSecondary

                font {
                    pixelSize: 13
                    family: Theme.fontFamily
                }
            }
        }

        // -----------------------------------------------------
        // Report builder
        // -----------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            radius: 14
            color: Theme.card
            border.color: Theme.border
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                TextField {
                    id: reportTitle

                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    placeholderText: "Report title"
                    text: "Data summary"
                    selectByMouse: true

                    color: Theme.textPrimary
                    placeholderTextColor: Theme.textSecondary
                    selectionColor: Theme.accentBlue
                    selectedTextColor: "#FFFFFF"

                    font.pixelSize: 12
                    font.family: Theme.fontFamily

                    background: Rectangle {
                        radius: 8
                        color: Theme.background

                        border.width: reportTitle.activeFocus ? 2 : 1
                        border.color: reportTitle.activeFocus ? Theme.accentBlue : Theme.border
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Group field
                    ComboBox {
                        id: groupCombo

                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        model: root.fields.map(function (item) {
                            return typeof item === "string" ? item : item.name;
                        })

                        enabled: root.fields.length > 0

                        currentIndex: model.indexOf(root.groupField)

                        onActivated: function (index) {
                            reportEngine.groupField = model[index];
                            root.lastGeneratedReport = null;
                        }

                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: 28

                            text: groupCombo.displayText
                            color: groupCombo.enabled ? Theme.textPrimary : Theme.textSecondary

                            font.pixelSize: 11
                            font.family: Theme.fontFamily

                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        indicator: Text {
                            x: groupCombo.width - width - 10
                            y: (groupCombo.height - height) / 2

                            text: "⌄"
                            color: Theme.textSecondary
                            font.pixelSize: 16
                        }

                        background: Rectangle {
                            radius: 8

                            color: groupCombo.enabled ? Theme.background : Theme.border

                            border.width: groupCombo.activeFocus ? 2 : 1
                            border.color: groupCombo.activeFocus ? Theme.accentBlue : Theme.border
                        }

                        delegate: ItemDelegate {
                            width: groupCombo.width
                            height: 34

                            highlighted: groupCombo.highlightedIndex === index

                            contentItem: Text {
                                text: modelData
                                color: Theme.textPrimary

                                font.pixelSize: 11
                                font.family: Theme.fontFamily

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                color: parent.highlighted ? Theme.hover : Theme.card
                            }
                        }

                        popup: Popup {
                            y: groupCombo.height + 4
                            width: groupCombo.width
                            padding: 4

                            contentItem: ListView {
                                clip: true

                                implicitHeight: Math.min(contentHeight, 180)

                                model: groupCombo.popup.visible ? groupCombo.delegateModel : null

                                currentIndex: groupCombo.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator {}
                            }

                            background: Rectangle {
                                radius: 8
                                color: Theme.card
                                border.color: Theme.border
                            }
                        }
                    }

                    // Numeric metric
                    ComboBox {
                        id: metricCombo

                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        model: root.numericFields

                        enabled: root.numericFields.length > 0

                        currentIndex: model.indexOf(root.metricField)

                        onActivated: function (index) {
                            reportEngine.metricField = model[index];
                            root.lastGeneratedReport = null;
                        }

                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: 28

                            text: metricCombo.displayText
                            color: metricCombo.enabled ? Theme.textPrimary : Theme.textSecondary

                            font.pixelSize: 11
                            font.family: Theme.fontFamily

                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        indicator: Text {
                            x: metricCombo.width - width - 10
                            y: (metricCombo.height - height) / 2

                            text: "⌄"
                            color: Theme.textSecondary
                            font.pixelSize: 16
                        }

                        background: Rectangle {
                            radius: 8

                            color: metricCombo.enabled ? Theme.background : Theme.border

                            border.width: metricCombo.activeFocus ? 2 : 1
                            border.color: metricCombo.activeFocus ? Theme.accentBlue : Theme.border
                        }

                        delegate: ItemDelegate {
                            width: metricCombo.width
                            height: 34

                            highlighted: metricCombo.highlightedIndex === index

                            contentItem: Text {
                                text: modelData
                                color: Theme.textPrimary

                                font.pixelSize: 11
                                font.family: Theme.fontFamily

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            background: Rectangle {
                                color: parent.highlighted ? Theme.hover : Theme.card
                            }
                        }

                        popup: Popup {
                            y: metricCombo.height + 4
                            width: metricCombo.width
                            padding: 4

                            contentItem: ListView {
                                clip: true

                                implicitHeight: Math.min(contentHeight, 180)

                                model: metricCombo.popup.visible ? metricCombo.delegateModel : null

                                currentIndex: metricCombo.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator {}
                            }

                            background: Rectangle {
                                radius: 8
                                color: Theme.card
                                border.color: Theme.border
                            }
                        }
                    }

                    // Aggregation
                    ComboBox {
                        id: aggregationCombo

                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 36

                        model: ["sum", "average", "count", "minimum", "maximum"]

                        currentIndex: model.indexOf(root.aggregation)

                        onActivated: function (index) {
                            reportEngine.aggregation = model[index];
                            root.lastGeneratedReport = null;
                        }

                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: 28

                            text: aggregationCombo.displayText
                            color: Theme.textPrimary

                            font.pixelSize: 11
                            font.family: Theme.fontFamily

                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        indicator: Text {
                            x: aggregationCombo.width - width - 10
                            y: (aggregationCombo.height - height) / 2

                            text: "⌄"
                            color: Theme.textSecondary
                            font.pixelSize: 16
                        }

                        background: Rectangle {
                            radius: 8
                            color: Theme.background

                            border.width: aggregationCombo.activeFocus ? 2 : 1
                            border.color: aggregationCombo.activeFocus ? Theme.accentBlue : Theme.border
                        }

                        delegate: ItemDelegate {
                            width: aggregationCombo.width
                            height: 34

                            highlighted: aggregationCombo.highlightedIndex === index

                            contentItem: Text {
                                text: root.aggregationLabel(modelData)
                                color: Theme.textPrimary

                                font.pixelSize: 11
                                font.family: Theme.fontFamily

                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.highlighted ? Theme.hover : Theme.card
                            }
                        }

                        popup: Popup {
                            y: aggregationCombo.height + 4
                            width: aggregationCombo.width
                            padding: 4

                            contentItem: ListView {
                                clip: true

                                implicitHeight: Math.min(contentHeight, 180)

                                model: aggregationCombo.popup.visible ? aggregationCombo.delegateModel : null

                                currentIndex: aggregationCombo.highlightedIndex

                                ScrollIndicator.vertical: ScrollIndicator {}
                            }

                            background: Rectangle {
                                radius: 8
                                color: Theme.card
                                border.color: Theme.border
                            }
                        }
                    }

                    // Generate button
                    Button {
                        id: generateButton

                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 36

                        text: "Generate"
                        enabled: root.rows.length > 0

                        onClicked: root.generateReport()

                        contentItem: Text {
                            text: generateButton.text
                            color: "#FFFFFF"

                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontFamily

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 8

                            color: !generateButton.enabled ? Theme.border : generateButton.down ? Theme.accentPurple : generateButton.hovered ? Theme.accentPurple : Theme.accentBlue
                        }
                    }

                    // Export button
                    Button {
                        id: exportButton

                        Layout.preferredWidth: 105
                        Layout.preferredHeight: 36

                        text: "Export CSV"
                        enabled: root.reportRows.length > 0

                        onClicked: root.exportReport()

                        contentItem: Text {
                            text: exportButton.text

                            color: exportButton.enabled ? Theme.textPrimary : Theme.textSecondary

                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontFamily

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 8

                            color: exportButton.down ? Theme.border : exportButton.hovered ? Theme.hover : Theme.background

                            border.color: Theme.border
                            border.width: 1
                        }
                    }
                }
            }
        }

        // -----------------------------------------------------
        // Dynamic filters
        // -----------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: filterColumn.implicitHeight + 28

            radius: 14
            color: Theme.card
            border.color: Theme.border
            border.width: 1

            ColumnLayout {
                id: filterColumn

                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true

                        text: "Advanced filters"
                        color: Theme.textPrimary

                        font {
                            pixelSize: 15
                            bold: true
                            family: Theme.fontFamily
                        }
                    }

                    Text {
                        text: reportEngine.filters.length + " active"
                        color: Theme.textSecondary

                        font {
                            pixelSize: 11
                            family: Theme.fontFamily
                        }
                    }

                    Button {
                        text: "Clear all"
                        enabled: reportEngine.filters.length > 0

                        onClicked: root.clearAllFilters()

                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? Theme.hover : "transparent"
                        }

                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? Theme.accentBlue : Theme.textSecondary

                            font {
                                pixelSize: 11
                                family: Theme.fontFamily
                            }

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Field selector
                    ComboBox {
                        id: filterFieldCombo

                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        model: root.fields.map(function (item) {
                            return typeof item === "string" ? item : item.name;
                        })

                        enabled: root.fields.length > 0

                        currentIndex: model.indexOf(root.filterField)

                        onActivated: function (index) {
                            root.filterField = model[index];
                            root.filterOperator = root.filterOperators()[0];
                            root.filterValue = "";
                            root.filterValue2 = "";
                        }

                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: 24

                            text: filterFieldCombo.displayText
                            color: Theme.textPrimary

                            font.pixelSize: 11
                            font.family: Theme.fontFamily

                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            radius: 8
                            color: Theme.background
                            border.color: filterFieldCombo.activeFocus ? Theme.accentBlue : Theme.border
                        }

                        delegate: ItemDelegate {
                            width: filterFieldCombo.width
                            height: 34

                            contentItem: Text {
                                text: modelData
                                color: Theme.textPrimary

                                font.pixelSize: 11
                                font.family: Theme.fontFamily

                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.highlighted ? Theme.hover : Theme.card
                            }
                        }

                        popup: Popup {
                            y: filterFieldCombo.height + 4
                            width: filterFieldCombo.width
                            padding: 4

                            contentItem: ListView {
                                clip: true

                                implicitHeight: Math.min(contentHeight, 180)

                                model: filterFieldCombo.popup.visible ? filterFieldCombo.delegateModel : null

                                ScrollIndicator.vertical: ScrollIndicator {}
                            }

                            background: Rectangle {
                                radius: 8
                                color: Theme.card
                                border.color: Theme.border
                            }
                        }
                    }

                    // Operator selector
                    ComboBox {
                        id: filterOperatorCombo

                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        model: root.filterOperators()

                        currentIndex: model.indexOf(root.filterOperator)

                        onActivated: function (index) {
                            root.filterOperator = model[index];
                        }

                        contentItem: Text {
                            leftPadding: 10
                            rightPadding: 24

                            text: filterOperatorCombo.displayText
                            color: Theme.textPrimary

                            font.pixelSize: 11
                            font.family: Theme.fontFamily

                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            radius: 8
                            color: Theme.background
                            border.color: filterOperatorCombo.activeFocus ? Theme.accentBlue : Theme.border
                        }

                        delegate: ItemDelegate {
                            width: filterOperatorCombo.width
                            height: 34

                            contentItem: Text {
                                text: modelData
                                color: Theme.textPrimary

                                font.pixelSize: 11
                                font.family: Theme.fontFamily

                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.highlighted ? Theme.hover : Theme.card
                            }
                        }

                        popup: Popup {
                            y: filterOperatorCombo.height + 4
                            width: filterOperatorCombo.width
                            padding: 4

                            contentItem: ListView {
                                clip: true

                                implicitHeight: Math.min(contentHeight, 180)

                                model: filterOperatorCombo.popup.visible ? filterOperatorCombo.delegateModel : null

                                ScrollIndicator.vertical: ScrollIndicator {}
                            }

                            background: Rectangle {
                                radius: 8
                                color: Theme.card
                                border.color: Theme.border
                            }
                        }
                    }

                    // First value
                    TextField {
                        id: filterValueInput

                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        visible: root.filterInputEnabled()
                        enabled: visible

                        placeholderText: root.fieldType(root.filterField) === "date" ? "YYYY-MM-DD" : "Value"

                        text: root.filterValue
                        onTextChanged: root.filterValue = text

                        color: Theme.textPrimary
                        placeholderTextColor: Theme.textSecondary

                        font.pixelSize: 11
                        font.family: Theme.fontFamily

                        background: Rectangle {
                            radius: 8
                            color: Theme.background
                            border.color: filterValueInput.activeFocus ? Theme.accentBlue : Theme.border
                        }
                    }

                    // Second value for between
                    TextField {
                        id: filterValue2Input

                        Layout.fillWidth: true
                        Layout.preferredHeight: 36

                        visible: root.filterOperator === "between"
                        enabled: visible

                        placeholderText: "To"
                        text: root.filterValue2
                        onTextChanged: root.filterValue2 = text

                        color: Theme.textPrimary
                        placeholderTextColor: Theme.textSecondary

                        font.pixelSize: 11
                        font.family: Theme.fontFamily

                        background: Rectangle {
                            radius: 8
                            color: Theme.background
                            border.color: filterValue2Input.activeFocus ? Theme.accentBlue : Theme.border
                        }
                    }

                    Button {
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 36

                        text: "Add filter"
                        enabled: root.filterField !== "" && (root.filterInputEnabled() ? root.filterValue.trim() !== "" : true) && (root.filterOperator !== "between" || root.filterValue2.trim() !== "")

                        onClicked: root.applyFilter()

                        contentItem: Text {
                            text: parent.text
                            color: "#FFFFFF"

                            font {
                                pixelSize: 11
                                bold: true
                                family: Theme.fontFamily
                            }

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 8
                            color: !parent.enabled ? Theme.border : parent.down ? Theme.accentPurple : Theme.accentBlue
                        }
                    }
                }

                // Active filters
                Flow {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: reportEngine.filters

                        delegate: Rectangle {
                            required property var modelData

                            width: filterChipText.implicitWidth + 38
                            height: 28

                            radius: 14
                            color: Theme.background
                            border.color: Theme.border

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    id: filterChipText

                                    text: modelData.field + " " + modelData.operator + " " + (modelData.operator === "between" ? modelData.value + " - " + modelData.value2 : modelData.value)

                                    color: Theme.textPrimary

                                    font {
                                        pixelSize: 10
                                        family: Theme.fontFamily
                                    }

                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "×"
                                    color: Theme.accentRed

                                    font {
                                        pixelSize: 16
                                        bold: true
                                    }

                                    anchors.verticalCenter: parent.verticalCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -5

                                        onClicked: {
                                            root.removeSingleFilter(modelData.field);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // -----------------------------------------------------
        // Statistics cards
        // -----------------------------------------------------

        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Repeater {
                model: [
                    {
                        title: "Source records",
                        value: root.rows.length
                    },
                    {
                        title: "Filtered records",
                        value: reportEngine.filteredRecordCount
                    },
                    {
                        title: "Groups",
                        value: root.reportRows.length
                    },
                    {
                        title: "Aggregation",
                        value: root.aggregationLabel(root.aggregation)
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 76

                    radius: 12
                    color: Theme.card
                    border.color: Theme.border

                    Column {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: modelData.title
                            color: Theme.textSecondary

                            font {
                                pixelSize: 11
                                family: Theme.fontFamily
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: String(modelData.value)
                            color: Theme.textPrimary

                            font {
                                pixelSize: 17
                                bold: true
                                family: Theme.fontFamily
                            }
                        }
                    }
                }
            }
        }

        // -----------------------------------------------------
        // Chart
        // -----------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 300

            radius: 14
            color: Theme.card
            border.color: Theme.border

            Text {
                anchors.left: parent.left
                anchors.top: parent.top

                anchors.leftMargin: 18
                anchors.topMargin: 14

                text: root.aggregationLabel(root.aggregation) + " " + (root.metricField || "records") + " by " + (root.groupField || "all records")

                color: Theme.textPrimary

                font {
                    pixelSize: 15
                    bold: true
                    family: Theme.fontFamily
                }
            }

            DashboardChart {
                anchors.fill: parent
                anchors.topMargin: 40
                anchors.margins: 12

                rows: root.reportRows
                fieldNames: ["group", "value", "records"]

                widget: ({
                        type: "bar",
                        xField: "group",
                        yField: "value"
                    })
            }

            Text {
                anchors.centerIn: parent

                visible: root.reportRows.length === 0

                text: "No data available"
                color: Theme.textSecondary

                font {
                    pixelSize: 12
                    family: Theme.fontFamily
                }
            }
        }

        // -----------------------------------------------------
        // Report table
        // -----------------------------------------------------

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: reportTable.implicitHeight + 76

            radius: 14
            color: Theme.card
            border.color: Theme.border

            ColumnLayout {
                id: reportTable

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: 16
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true

                        text: "Generated report"
                        color: Theme.textPrimary

                        font {
                            pixelSize: 15
                            bold: true
                            family: Theme.fontFamily
                        }
                    }

                    TextField {
                        Layout.preferredWidth: 240
                        Layout.preferredHeight: 36

                        placeholderText: "Search report..."
                        selectByMouse: true

                        color: Theme.textPrimary
                        placeholderTextColor: Theme.textSecondary
                        selectionColor: Theme.accentBlue
                        selectedTextColor: Theme.textPrimary

                        font.family: Theme.fontFamily
                        font.pixelSize: 13

                        leftPadding: 12
                        rightPadding: 12

                        background: Rectangle {
                            radius: 8
                            color: Theme.card

                            border.width: 1
                            border.color: parent.activeFocus ? Theme.accentBlue : Theme.border

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        onTextChanged: root.searchText = text
                    }
                }

                // Table header
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true

                        text: root.groupField || "Group"
                        color: Theme.textSecondary

                        font {
                            pixelSize: 12
                            bold: true
                            family: Theme.fontFamily
                        }
                    }

                    Text {
                        Layout.preferredWidth: 160

                        horizontalAlignment: Text.AlignRight

                        text: root.aggregationLabel(root.aggregation) + " " + (root.metricField || "records")

                        color: Theme.textSecondary

                        font {
                            pixelSize: 12
                            bold: true
                            family: Theme.fontFamily
                        }
                    }

                    Text {
                        Layout.preferredWidth: 100

                        horizontalAlignment: Text.AlignRight

                        text: "Records"
                        color: Theme.textSecondary

                        font {
                            pixelSize: 12
                            bold: true
                            family: Theme.fontFamily
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.border
                }

                // Table rows
                Repeater {
                    model: root.visibleReportRows

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        radius: 5
                        color: index % 2 ? Theme.border : "transparent"

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            Text {
                                Layout.fillWidth: true

                                text: modelData.group
                                color: Theme.textPrimary

                                font {
                                    pixelSize: 12
                                    family: Theme.fontFamily
                                }

                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.preferredWidth: 160

                                horizontalAlignment: Text.AlignRight

                                text: root.formatNumber(modelData.value)
                                color: Theme.textPrimary

                                font {
                                    pixelSize: 12
                                    family: Theme.fontFamily
                                }
                            }

                            Text {
                                Layout.preferredWidth: 100

                                horizontalAlignment: Text.AlignRight

                                text: String(modelData.records)
                                color: Theme.textSecondary

                                font {
                                    pixelSize: 12
                                    family: Theme.fontFamily
                                }
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    Layout.fillWidth: true

                    visible: root.visibleReportRows.length === 0

                    text: root.rows.length === 0 ? "Load data to generate a report." : "No report rows match this search."

                    color: Theme.textSecondary

                    font {
                        pixelSize: 12
                        family: Theme.fontFamily
                    }
                }
            }
        }

        // -----------------------------------------------------
        // Generated report status
        // -----------------------------------------------------

        Text {
            Layout.fillWidth: true

            visible: root.lastGeneratedReport !== null

            text: root.lastGeneratedReport ? "Generated: " + root.lastGeneratedReport.title + " — " + root.lastGeneratedReport.rows.length + " groups" : ""

            color: Theme.accentGreen

            font {
                pixelSize: 12
                family: Theme.fontFamily
            }
        }
    }
}
