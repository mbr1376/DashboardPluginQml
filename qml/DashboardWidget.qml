
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    // ========================================
    // PUBLIC PROPERTIES
    // ========================================

    property var widget: ({})
    property var rows: []
    property var fieldNames: []
    property bool editMode: false

    readonly property var chartTypes: [
        "line", "bar", "area", "scatter",
        "pie", "donut", "table"
    ]

    signal fieldChanged(string name, var value)
    signal removeRequested()
    signal dragStarted()
    signal dragMoved(real x, real y)
    signal dragFinished()
    signal resizeStarted()
    signal resizeMoved(real x, real y)
    signal resizeFinished()

    // ========================================
    // THEME COLORS
    // ========================================

    readonly property color cardColor: Theme.card
    readonly property color headerColor: Theme.sidebarTop
    readonly property color borderColor: Theme.border
    readonly property color textColor: Theme.textPrimary
    readonly property color secondaryTextColor: Theme.textSecondary
    readonly property color hoverColor: Theme.hover

    radius: 14
    color: cardColor
    border.color: borderColor
    border.width: 1
    clip: true

    // ========================================
    // HEADER
    // ========================================

    Rectangle {
        id: header

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 48
        color: "transparent"

        // Drag area
        Item {
            id: dragArea

            anchors.left: parent.left
            anchors.top: parent.top

            width: root.editMode ? parent.width * 0.35 : parent.width
            height: parent.height
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 10
            spacing: 8

            // Widget title
            Text {
                id: titleLabel

                Layout.fillWidth: true

                text: root.widget.title || "Widget"
                color: root.textColor

                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true

                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            // Chart type selector
            ComboBox {
                id: typeSelector

                visible: root.editMode

                Layout.preferredWidth: 105
                Layout.preferredHeight: 30

                model: root.chartTypes

                currentIndex: Math.max(
                    0,
                    root.chartTypes.indexOf(root.widget.type || "line")
                )

                onActivated: function(index) {
                    root.fieldChanged("type", root.chartTypes[index])
                }

                contentItem: Text {
                    leftPadding: 8
                    rightPadding: 22

                    text: typeSelector.displayText
                    color: Theme.textPrimary

                    font.family: Theme.fontFamily
                    font.pixelSize: 10

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
                    color: typeSelector.hovered
                           ? Theme.hover
                           : Theme.card

                    border.color: typeSelector.activeFocus
                                  ? Theme.accentBlue
                                  : Theme.border
                }

                popup: Popup {
                    y: typeSelector.height + 4
                    width: typeSelector.width
                    padding: 4

                    background: Rectangle {
                        color: Theme.sidebarTop
                        border.color: Theme.border
                        radius: 8
                    }

                    contentItem: ListView {
                        implicitHeight: Math.min(
                            contentHeight,
                            210
                        )

                        model: typeSelector.popup.visible
                               ? typeSelector.delegateModel
                               : null

                        clip: true
                        currentIndex: typeSelector.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator {}
                    }
                }

                delegate: ItemDelegate {
                    width: typeSelector.width
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

                    highlighted: typeSelector.highlightedIndex === index
                }
            }

            // Remove button
            Button {
                id: removeButton

                visible: root.editMode

                Layout.preferredWidth: 30
                Layout.preferredHeight: 30

                text: "×"
                padding: 0

                onClicked: root.removeRequested()

                contentItem: Text {
                    text: removeButton.text

                    color: removeButton.hovered
                           ? Theme.accentRed
                           : Theme.textSecondary

                    font.pixelSize: 21
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 7

                    color: removeButton.hovered
                           ? Qt.darker(Theme.accentRed, 2.5)
                           : "transparent"

                    border.color: removeButton.hovered
                                  ? Theme.accentRed
                                  : Theme.border
                }
            }
        }

        // Drag handler
        DragHandler {
            parent: dragArea
            enabled: root.editMode
            target: null

            onActiveChanged: {
                if (active)
                    root.dragStarted()
                else
                    root.dragFinished()
            }

            onTranslationChanged: {
                root.dragMoved(translation.x, translation.y)
            }
        }
    }

    // Header separator
    Rectangle {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        height: 1
        color: Theme.border
        opacity: 0.5
    }

    // ========================================
    // FIELD SELECTORS
    // ========================================

    RowLayout {
        id: fieldsRow

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom

        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 7

        height: root.editMode && root.widget.type !== "table"
                ? 34 : 0

        visible: height > 0
        spacing: 8

        Repeater {
            model: ["xField", "yField"]

            delegate: ComboBox {
                id: fieldSelector

                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 30

                model: root.fieldNames

                currentIndex: Math.max(
                    0,
                    root.fieldNames.indexOf(root.widget[modelData])
                )

                onActivated: function(index) {
                    if (index >= 0 && index < root.fieldNames.length) {
                        root.fieldChanged(
                            modelData,
                            root.fieldNames[index]
                        )
                    }
                }

                contentItem: Text {
                    leftPadding: 8
                    rightPadding: 20

                    text: fieldSelector.displayText
                    color: Theme.textPrimary

                    font.family: Theme.fontFamily
                    font.pixelSize: 10

                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                indicator: Text {
                    text: "⌄"
                    color: Theme.textSecondary
                    font.pixelSize: 14

                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                }

                background: Rectangle {
                    radius: 6
                    color: Theme.card

                    border.color: fieldSelector.activeFocus
                                  ? Theme.accentBlue
                                  : Theme.border
                }

                popup: Popup {
                    y: fieldSelector.height + 3
                    width: fieldSelector.width
                    padding: 4

                    background: Rectangle {
                        color: Theme.sidebarTop
                        border.color: Theme.border
                        radius: 7
                    }

                    contentItem: ListView {
                        implicitHeight: Math.min(contentHeight, 180)

                        model: fieldSelector.popup.visible
                               ? fieldSelector.delegateModel
                               : null

                        clip: true
                        currentIndex: fieldSelector.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator {}
                    }
                }

                delegate: ItemDelegate {
                    width: fieldSelector.width
                    height: 32

                    contentItem: Text {
                        text: modelData

                        color: highlighted
                               ? Theme.accentBlue
                               : Theme.textPrimary

                        font.family: Theme.fontFamily
                        font.pixelSize: 10

                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }

                    background: Rectangle {
                        radius: 5
                        color: highlighted
                               ? Theme.hover
                               : "transparent"
                    }

                    highlighted: fieldSelector.highlightedIndex === index
                }
            }
        }
    }

    // ========================================
    // WIDGET CONTENT
    // ========================================

    Item {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: fieldsRow.visible
                     ? fieldsRow.bottom
                     : header.bottom

        anchors.bottom: parent.bottom

        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 12

        DashboardChart {
            anchors.fill: parent

            visible: root.widget.type !== "table"

            rows: root.rows
            widget: root.widget
            fieldNames: root.fieldNames
        }

        // ========================================
        // TABLE VIEW
        // ========================================

        Column {
            id: tableContainer

            visible: root.widget.type === "table"
            anchors.fill: parent

            spacing: 0

            Rectangle {
                id: tableHeader

                width: parent.width
                height: 32

                color: Theme.sidebarTop
                radius: 5

                Row {
                    id: headerColumns

                    anchors.fill: parent
                    clip: true

                    Repeater {
                        model: root.fieldNames

                        delegate: Item {
                            required property var modelData

                            width: root.fieldNames.length > 0
                                   ? headerColumns.width
                                     / root.fieldNames.length
                                   : 0

                            height: parent.height

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 5

                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight

                                text: String(modelData)
                                color: Theme.textSecondary

                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }
                }
            }

            ListView {
                id: tableList

                width: parent.width
                height: Math.max(0, parent.height - tableHeader.height)

                clip: true
                model: root.rows

                ScrollBar.vertical: ScrollBar {
                    active: tableList.moving
                }

                delegate: Rectangle {
                    id: tableRow

                    required property var modelData
                    required property int index

                    property var rowData: modelData

                    width: tableList.width
                    height: 34

                    color: rowMouse.containsMouse
                           ? Theme.hover
                           : (index % 2
                              ? Theme.sidebarTop
                              : "transparent")

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }

                    Row {
                        id: dataColumns

                        anchors.fill: parent
                        clip: true

                        Repeater {
                            model: root.fieldNames

                            delegate: Item {
                                id: cell

                                required property var modelData

                                width: root.fieldNames.length > 0
                                       ? dataColumns.width
                                         / root.fieldNames.length
                                       : 0

                                height: dataColumns.height

                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 5

                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight

                                    text: {
                                        var value = tableRow.rowData
                                                    ? tableRow.rowData[cell.modelData]
                                                    : "";

                                        return value === undefined || value === null
                                               ? ""
                                               : String(value);
                                    }

                                    color: Theme.textPrimary

                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: rowMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }

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

            // Empty table state
            Text {
                anchors.centerIn: parent

                visible: root.rows.length === 0

                text: "No data available"
                color: Theme.textSecondary

                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }
    }

    // ========================================
    // RESIZE HANDLE
    // ========================================

    Item {
        id: resizeHandle

        visible: root.editMode

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: 25
        height: 25

        Rectangle {
            anchors.fill: parent

            radius: 5
            color: resizeMouse.containsMouse
                   ? Theme.hover
                   : "transparent"
        }

        Canvas {
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = Theme.accentBlue
                ctx.lineWidth = 1.8
                ctx.lineCap = "round"

                for (var i = 0; i < 3; ++i) {
                    ctx.beginPath()
                    ctx.moveTo(width - 5, height - 8 - i * 5)
                    ctx.lineTo(width - 8 - i * 5, height - 5)
                    ctx.stroke()
                }
            }
        }

        DragHandler {
            parent: resizeHandle
            enabled: root.editMode
            target: null

            onActiveChanged: {
                if (active)
                    root.resizeStarted()
                else
                    root.resizeFinished()
            }

            onTranslationChanged: {
                root.resizeMoved(translation.x, translation.y)
            }
        }

        HoverHandler {
            id: resizeMouse
        }
    }
}
