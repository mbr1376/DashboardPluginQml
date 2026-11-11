
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    radius: 14
    color: Theme.card
    border.color: Theme.border
    border.width: 1

    // ========================================
    // PUBLIC PROPERTIES
    // ========================================

    property string title: "Data Table"
    property var columns: []
    property var rows: []
    property int statusColumn: 2
    property var columnWidths: []

    property int rowHeight: 48
    property int headerHeight: 42

    property color headerColor: Theme.sidebarTop
    property color alternateRowColor: Theme.sidebarTop
    property color hoverColor: Theme.hover

    implicitHeight: titleLabel.height
                    + headerRow.height
                    + tableContent.height
                    + 65

    // ========================================
    // SECTION TITLE
    // ========================================

    Text {
        id: titleLabel

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 22
        anchors.topMargin: 18

        text: root.title
        color: Theme.textPrimary

        font.family: Theme.fontFamily
        font.pixelSize: 16
        font.bold: true
    }

    // ========================================
    // COLUMN HEADERS
    // ========================================

    Rectangle {
        id: headerRow

        anchors.top: titleLabel.bottom
        anchors.topMargin: 14

        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: 20
        anchors.rightMargin: 20

        height: root.headerHeight

        radius: 7
        color: root.headerColor

        Row {
            anchors.fill: parent
            clip: true

            Repeater {
                model: root.columns

                Item {
                    required property int index
                    required property var modelData

                    width: root.getColumnWidth(index)
                    height: parent.height

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 6

                        text: modelData

                        color: Theme.textSecondary

                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: true

                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    // ========================================
    // TABLE ROWS
    // ========================================

    Column {
        id: tableContent

        anchors.top: headerRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: 20
        anchors.rightMargin: 20

        Repeater {
            model: root.rows

            delegate: Rectangle {
                id: rowItem

                required property int index
                required property var modelData

                readonly property int rowIndex: index

                width: tableContent.width
                height: root.rowHeight

                color: rowMouse.containsMouse
                       ? root.hoverColor
                       : (index % 2 === 1
                          ? root.alternateRowColor
                          : "transparent")

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Row {
                    anchors.fill: parent
                    clip: true

                    Repeater {
                        model: root.columns.length

                        delegate: Item {
                            required property int index

                            readonly property int columnIndex: index

                            width: root.getColumnWidth(index)
                            height: parent.height

                            Loader {
                                anchors.fill: parent

                                anchors.leftMargin: 12
                                anchors.rightMargin: 8

                                property string cellValue:
                                    root.getCellValue(
                                        rowItem.modelData,
                                        columnIndex
                                    )

                                sourceComponent:
                                    columnIndex === root.statusColumn
                                    ? statusPillComponent
                                    : plainTextComponent
                            }
                        }
                    }
                }

                // Row hover
                MouseArea {
                    id: rowMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton

                    cursorShape: Qt.PointingHandCursor
                }

                // Subtle row separator
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: 1
                    color: Theme.border
                    opacity: 0.35
                }
            }
        }
    }

    // ========================================
    // EMPTY STATE
    // ========================================

    Text {
        anchors.top: headerRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 35

        visible: root.rows.length === 0

        text: "No data available"

        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: 12

        horizontalAlignment: Text.AlignHCenter
    }

    // ========================================
    // PLAIN TEXT CELL
    // ========================================

    Component {
        id: plainTextComponent

        Text {
            text: cellValue

            color: Theme.textPrimary

            font.family: Theme.fontFamily
            font.pixelSize: 12

            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    // ========================================
    // STATUS PILL
    // ========================================

    Component {
        id: statusPillComponent

        Item {
            Rectangle {
                id: pill

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left

                width: Math.min(
                    pillText.implicitWidth + 22,
                    parent.width
                )

                height: 25
                radius: 13

                color: statusColor(cellValue)
                opacity: 0.18

            }

            Text {
                id: pillText

                anchors.centerIn: pill

                width: pill.width - 8

                text: cellValue

                color: statusColor(cellValue)

                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                elide: Text.ElideRight
            }
        }
    }

    // ========================================
    // STATUS COLORS
    // ========================================

    function statusColor(status) {
        switch (String(status).toLowerCase()) {

        case "completed":
        case "active":
        case "success":
        case "approved":
            return Theme.accentGreen;

        case "pending":
        case "in progress":
        case "inactive":
        case "warning":
            return Theme.accentOrange;

        case "failed":
        case "suspended":
        case "error":
        case "rejected":
            return Theme.accentRed;

        case "scheduled":
        case "info":
            return Theme.accentBlue;

        default:
            return Theme.accentPurple;
        }
    }

    // ========================================
    // CELL VALUE
    // ========================================

    function getCellValue(rowObj, colIndex) {
        if (!rowObj)
            return "";

        // Array-based rows
        if (Array.isArray(rowObj)) {
            if (colIndex < rowObj.length)
                return String(rowObj[colIndex] ?? "");

            return "";
        }

        // Object-based rows
        var keys = Object.keys(rowObj);

        if (colIndex < keys.length) {
            var value = rowObj[keys[colIndex]];
            return value === null || value === undefined
                   ? ""
                   : String(value);
        }

        return "";
    }

    // ========================================
    // COLUMN WIDTH
    // ========================================

    function getColumnWidth(colIndex) {
        var availableWidth = Math.max(0, root.width - 40);

        if (root.columnWidths
                && root.columnWidths.length > colIndex
                && Number(root.columnWidths[colIndex]) > 0) {

            return Number(root.columnWidths[colIndex]);
        }

        if (root.columns.length === 0)
            return 0;

        return availableWidth / root.columns.length;
    }
}
