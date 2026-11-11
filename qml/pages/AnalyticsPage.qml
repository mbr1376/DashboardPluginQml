
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Flickable {
    id: root

    // ========================================
    // PUBLIC PROPERTIES
    // ========================================

    property var rows: []
    property var fields: rows.length > 0 ? Object.keys(rows[0]) : []
    property var numericFields: findNumericFields()

    property string categoryField: fields.length > 0 ? fields[0] : ""
    property string metricField: numericFields.length > 0 ? numericFields[0] : ""
    property string chartType: "line"

    readonly property var chartTypes: [
        "line", "bar", "area", "scatter", "pie", "donut"
    ]

    readonly property color cardColor: Theme.card
    readonly property color panelColor: Theme.sidebarTop
    readonly property color borderColor: Theme.border
    readonly property color primaryText: Theme.textPrimary
    readonly property color secondaryText: Theme.textSecondary

    contentWidth: width
    contentHeight: contentColumn.height + 48

    clip: true
    boundsBehavior: Flickable.StopAtBounds

    // ========================================
    // DATA FUNCTIONS
    // ========================================

    function isNumericValue(value) {
        return value !== null
                && value !== undefined
                && value !== ""
                && isFinite(Number(value));
    }

    function findNumericFields() {
        if (!rows || rows.length === 0)
            return [];

        var result = [];

        var keys = Object.keys(rows[0]);

        for (var i = 0; i < keys.length; ++i) {
            var key = keys[i];
            var found = false;

            for (var r = 0; r < rows.length; ++r) {
                if (isNumericValue(rows[r][key])) {
                    found = true;
                    break;
                }
            }

            if (found)
                result.push(key);
        }

        return result;
    }

    function totalValue() {
        var total = 0;

        if (!metricField)
            return total;

        for (var i = 0; i < rows.length; ++i) {
            var value = Number(rows[i][metricField]);

            if (isNumericValue(rows[i][metricField]))
                total += value;
        }

        return total;
    }

    function averageValue() {
        var total = 0;
        var count = 0;

        if (!metricField)
            return 0;

        for (var i = 0; i < rows.length; ++i) {
            var value = rows[i][metricField];

            if (isNumericValue(value)) {
                total += Number(value);
                count++;
            }
        }

        return count > 0 ? total / count : 0;
    }

    function uniqueValueCount() {
        var values = [];

        if (!categoryField)
            return 0;

        for (var i = 0; i < rows.length; ++i) {
            var value = String(rows[i][categoryField]);

            if (values.indexOf(value) < 0)
                values.push(value);
        }

        return values.length;
    }

    function largestRows() {
        if (!metricField)
            return [];

        var result = rows.slice(0);

        result.sort(function(left, right) {
            return Number(right[metricField] || 0)
                   - Number(left[metricField] || 0);
        });

        return result.slice(0, 5);
    }

    function displayNumber(value) {
        var number = Number(value);

        if (!isFinite(number))
            return "—";

        return number.toLocaleString(Qt.locale(), "f", 2);
    }

    function refreshFields() {
        fields = rows.length > 0 ? Object.keys(rows[0]) : [];
        numericFields = findNumericFields();

        if (fields.indexOf(categoryField) < 0)
            categoryField = fields.length > 0 ? fields[0] : "";

        if (numericFields.indexOf(metricField) < 0)
            metricField = numericFields.length > 0
                          ? numericFields[0] : "";
    }

    onRowsChanged: refreshFields()

    // ========================================
    // ROOT CONTENT
    // ========================================

    ColumnLayout {
        id: contentColumn

        width: Math.max(0, root.width - 48)

        x: 24
        y: 22

        spacing: 18

        // ========================================
        // PAGE HEADER
        // ========================================

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "Analytics"
                    color: Theme.textPrimary

                    font.family: Theme.fontFamily
                    font.pixelSize: 23
                    font.bold: true
                }

                Text {
                    text: "Data overview and insights"
                    color: Theme.textSecondary

                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }

            Rectangle {
                Layout.preferredWidth: 105
                Layout.preferredHeight: 32

                radius: 8
                color: Theme.card
                border.color: Theme.border

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 7
                        height: 7
                        radius: 4
                        color: Theme.accentGreen

                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.rows.length + " records"
                        color: Theme.textSecondary

                        font.family: Theme.fontFamily
                        font.pixelSize: 10

                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        // ========================================
        // STATISTICS CARDS
        // ========================================

        GridLayout {
            Layout.fillWidth: true

            columns: root.width < 650 ? 2 : 4
            columnSpacing: 12
            rowSpacing: 12

            Repeater {
                model: [
                    {
                        title: "Total records",
                        value: root.rows.length,
                        color: Theme.accentBlue,
                        icon: "#"
                    },
                    {
                        title: "Total " + (root.metricField || "value"),
                        value: root.metricField
                               ? root.displayNumber(root.totalValue())
                               : "—",
                        color: Theme.accentGreen,
                        icon: "Σ"
                    },
                    {
                        title: "Average",
                        value: root.metricField
                               ? root.displayNumber(root.averageValue())
                               : "—",
                        color: Theme.accentOrange,
                        icon: "Ø"
                    },
                    {
                        title: "Unique values",
                        value: root.categoryField
                               ? root.uniqueValueCount()
                               : "—",
                        color: Theme.accentPurple,
                        icon: "◇"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 105

                    radius: 12
                    color: Theme.card
                    border.color: Theme.border

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom

                        width: 4
                        radius: 2
                        color: modelData.color
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 17
                        anchors.rightMargin: 12
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12

                        spacing: 7

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true

                                text: modelData.title
                                color: Theme.textSecondary

                                font.family: Theme.fontFamily
                                font.pixelSize: 10

                                elide: Text.ElideRight
                            }

                            Rectangle {
                                width: 25
                                height: 25
                                radius: 7
                                color: modelData.color
                                opacity: 0.18

                                Text {
                                    anchors.centerIn: parent

                                    text: modelData.icon
                                    color: modelData.color

                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true

                            text: String(modelData.value)
                            color: Theme.textPrimary

                            font.family: Theme.fontFamily
                            font.pixelSize: 21
                            font.bold: true

                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // ========================================
        // FILTER TOOLBAR
        // ========================================

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.width < 600 ? 125 : 68

            radius: 12
            color: Theme.card
            border.color: Theme.border

            GridLayout {
                anchors.fill: parent

                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.topMargin: 10
                anchors.bottomMargin: 10

                columns: root.width < 600 ? 2 : 7
                columnSpacing: 10
                rowSpacing: 7

                Text {
                    text: "GROUP BY"
                    color: Theme.textSecondary

                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.bold: true
                }

                ComboBox {
                    id: categorySelector

                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    model: root.fields

                    currentIndex: Math.max(
                        0,
                        root.fields.indexOf(root.categoryField)
                    )

                    onActivated: function(index) {
                        if (index >= 0)
                            root.categoryField = root.fields[index]
                    }

                    contentItem: Text {
                        leftPadding: 10
                        rightPadding: 22

                        text: categorySelector.displayText
                        color: Theme.textPrimary

                        font.family: Theme.fontFamily
                        font.pixelSize: 11

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        text: "⌄"
                        color: Theme.textSecondary
                        font.pixelSize: 15

                        anchors.right: parent.right
                        anchors.rightMargin: 7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    background: Rectangle {
                        radius: 7
                        color: Theme.sidebarTop

                        border.color: categorySelector.activeFocus
                                      ? Theme.accentBlue
                                      : Theme.border
                    }

                    delegate: ItemDelegate {
                        width: categorySelector.width
                        height: 34

                        contentItem: Text {
                            text: modelData
                            color: highlighted
                                   ? Theme.accentBlue
                                   : Theme.textPrimary

                            font.family: Theme.fontFamily
                            font.pixelSize: 11

                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }

                        background: Rectangle {
                            radius: 5
                            color: highlighted
                                   ? Theme.hover
                                   : "transparent"
                        }

                        highlighted: categorySelector.highlightedIndex === index
                    }

                    popup: Popup {
                        y: categorySelector.height + 4
                        width: categorySelector.width
                        padding: 4

                        background: Rectangle {
                            color: Theme.sidebarTop
                            border.color: Theme.border
                            radius: 8
                        }

                        contentItem: ListView {
                            implicitHeight: Math.min(contentHeight, 180)
                            model: categorySelector.popup.visible
                                   ? categorySelector.delegateModel
                                   : null
                            clip: true
                        }
                    }
                }

                Text {
                    text: "MEASURE"
                    color: Theme.textSecondary

                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.bold: true
                }

                ComboBox {
                    id: metricSelector

                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    model: root.numericFields

                    currentIndex: Math.max(
                        0,
                        root.numericFields.indexOf(root.metricField)
                    )

                    onActivated: function(index) {
                        if (index >= 0)
                            root.metricField = root.numericFields[index]
                    }

                    contentItem: Text {
                        leftPadding: 10
                        rightPadding: 22

                        text: metricSelector.displayText
                        color: Theme.textPrimary

                        font.family: Theme.fontFamily
                        font.pixelSize: 11

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        text: "⌄"
                        color: Theme.textSecondary
                        font.pixelSize: 15

                        anchors.right: parent.right
                        anchors.rightMargin: 7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    background: Rectangle {
                        radius: 7
                        color: Theme.sidebarTop

                        border.color: metricSelector.activeFocus
                                      ? Theme.accentBlue
                                      : Theme.border
                    }

                    delegate: ItemDelegate {
                        width: metricSelector.width
                        height: 34

                        contentItem: Text {
                            text: modelData
                            color: highlighted
                                   ? Theme.accentBlue
                                   : Theme.textPrimary

                            font.family: Theme.fontFamily
                            font.pixelSize: 11

                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }

                        background: Rectangle {
                            radius: 5
                            color: highlighted
                                   ? Theme.hover
                                   : "transparent"
                        }

                        highlighted: metricSelector.highlightedIndex === index
                    }

                    popup: Popup {
                        y: metricSelector.height + 4
                        width: metricSelector.width
                        padding: 4

                        background: Rectangle {
                            color: Theme.sidebarTop
                            border.color: Theme.border
                            radius: 8
                        }

                        contentItem: ListView {
                            implicitHeight: Math.min(contentHeight, 180)
                            model: metricSelector.popup.visible
                                   ? metricSelector.delegateModel
                                   : null
                            clip: true
                        }
                    }
                }

                Text {
                    text: "CHART"
                    color: Theme.textSecondary

                    font.family: Theme.fontFamily
                    font.pixelSize: 9
                    font.bold: true
                }

                ComboBox {
                    id: chartSelector

                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    model: root.chartTypes

                    currentIndex: Math.max(
                        0,
                        root.chartTypes.indexOf(root.chartType)
                    )

                    onActivated: function(index) {
                        root.chartType = root.chartTypes[index]
                    }

                    contentItem: Text {
                        leftPadding: 10
                        rightPadding: 22

                        text: chartSelector.displayText
                        color: Theme.textPrimary

                        font.family: Theme.fontFamily
                        font.pixelSize: 11

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    indicator: Text {
                        text: "⌄"
                        color: Theme.textSecondary
                        font.pixelSize: 15

                        anchors.right: parent.right
                        anchors.rightMargin: 7
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    background: Rectangle {
                        radius: 7
                        color: Theme.sidebarTop

                        border.color: chartSelector.activeFocus
                                      ? Theme.accentBlue
                                      : Theme.border
                    }

                    delegate: ItemDelegate {
                        width: chartSelector.width
                        height: 34

                        contentItem: Text {
                            text: modelData
                            color: highlighted
                                   ? Theme.accentBlue
                                   : Theme.textPrimary

                            font.family: Theme.fontFamily
                            font.pixelSize: 11

                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }

                        background: Rectangle {
                            radius: 5
                            color: highlighted
                                   ? Theme.hover
                                   : "transparent"
                        }

                        highlighted: chartSelector.highlightedIndex === index
                    }

                    popup: Popup {
                        y: chartSelector.height + 4
                        width: chartSelector.width
                        padding: 4

                        background: Rectangle {
                            color: Theme.sidebarTop
                            border.color: Theme.border
                            radius: 8
                        }

                        contentItem: ListView {
                            implicitHeight: Math.min(contentHeight, 180)
                            model: chartSelector.popup.visible
                                   ? chartSelector.delegateModel
                                   : null
                            clip: true
                        }
                    }
                }
            }
        }

        // ========================================
        // CHART CARD
        // ========================================

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(300, root.height * 0.43)

            radius: 14
            color: Theme.card
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: (root.metricField || "Value")
                                  + " by "
                                  + (root.categoryField || "Category")

                            color: Theme.textPrimary

                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Text {
                            text: root.chartType.toUpperCase() + " CHART"

                            color: Theme.textSecondary

                            font.family: Theme.fontFamily
                            font.pixelSize: 9
                        }
                    }

                    Rectangle {
                        width: 9
                        height: 9
                        radius: 5
                        color: Theme.accentBlue
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    color: Theme.sidebarTop
                    radius: 8
                    clip: true

                    DashboardChart {
                        anchors.fill: parent
                        anchors.margins: 8

                        rows: root.rows
                        fieldNames: root.fields

                        widget: ({
                            type: root.chartType,
                            xField: root.categoryField,
                            yField: root.metricField
                        })
                    }

                    Text {
                        anchors.centerIn: parent

                        visible: root.rows.length === 0

                        text: "Load data to display chart"
                        color: Theme.textSecondary

                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }
        }

        // ========================================
        // TOP RECORDS
        // ========================================

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: topValuesColumn.implicitHeight + 38

            radius: 14
            color: Theme.card
            border.color: Theme.border

            Column {
                id: topValuesColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.margins: 18

                spacing: 12

                RowLayout {
                    width: parent.width

                    Text {
                        Layout.fillWidth: true

                        text: "Largest records"

                        color: Theme.textPrimary

                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: "TOP 5"

                        color: Theme.accentBlue

                        font.family: Theme.fontFamily
                        font.pixelSize: 9
                        font.bold: true
                    }
                }

                Repeater {
                    model: root.largestRows()

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: topValuesColumn.width
                        height: 42

                        radius: 7

                        color: index % 2 === 0
                               ? Theme.sidebarTop
                               : "transparent"

                        RowLayout {
                            anchors.fill: parent

                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24

                                radius: 7

                                color: Theme.accentBlue
                                opacity: 0.18

                                Text {
                                    anchors.centerIn: parent

                                    text: String(index + 1)
                                    color: Theme.accentBlue

                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }

                            Text {
                                Layout.fillWidth: true

                                text: String(
                                    modelData[root.categoryField] === undefined
                                    ? "Row " + (index + 1)
                                    : modelData[root.categoryField]
                                )

                                color: Theme.textSecondary

                                font.family: Theme.fontFamily
                                font.pixelSize: 11

                                elide: Text.ElideRight
                            }

                            Text {
                                text: root.metricField
                                      ? root.displayNumber(
                                            modelData[root.metricField]
                                        )
                                      : "—"

                                color: Theme.textPrimary

                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                }

                Text {
                    visible: root.rows.length === 0

                    text: "Load data to view analytics."

                    color: Theme.textSecondary

                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }
}
