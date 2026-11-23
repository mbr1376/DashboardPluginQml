
import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

/*!
    \qmltype DashboardBuilder
    \inqmlmodule Dashboard
    \since 1.0
    \brief Provides dashboard layout editing and widget management.

    DashboardBuilder manages dashboard widget placement, editing gestures,
    and layout serialization.
*/

Item {
    id: root

    property var rows: []
    property var source: null
    property var widgets: []
    property bool editMode: false
    property var fieldNames: rows.length > 0 ? Object.keys(rows[0]) : []

    readonly property int gridColumns: 12
    readonly property real gap: 14
    readonly property real rowHeight: 116
    readonly property real cellWidth: Math.max(1, (board.width - gap * (gridColumns - 1)) / gridColumns)
    readonly property var widgetTypes: ["line", "bar", "area", "scatter", "pie", "donut", "table"]

    property string activeWidgetId: ""
    property string activeGesture: ""
    property real gestureStartX: 0
    property real gestureStartY: 0
    property real gestureDeltaX: 0
    property real gestureDeltaY: 0

    signal layoutChanged(var layout)
    signal saveRequested(var layout)

    // ========================================
    // THEME HELPERS
    // ========================================

    readonly property color panelColor: Theme.sidebarTop
    readonly property color buttonColor: Theme.card
    readonly property color buttonHover: Theme.hover
    readonly property color inputColor: Theme.card
    readonly property color inputBorder: Theme.border

    function widthFor(columns) {
        return columns * cellWidth + (columns - 1) * gap;
    }

    function heightFor(rowsCount) {
        return rowsCount * rowHeight + (rowsCount - 1) * gap;
    }

    function xFor(widget) {
        if (activeWidgetId === widget.id && activeGesture === "move")
            return Math.max(0, gestureStartX + gestureDeltaX);
        return widget.x * (cellWidth + gap);
    }

    function yFor(widget) {
        if (activeWidgetId === widget.id && activeGesture === "move")
            return Math.max(0, gestureStartY + gestureDeltaY);
        return widget.y * (rowHeight + gap);
    }

    function columnsFor(widget) {
        if (activeWidgetId === widget.id && activeGesture === "resize") {
            return Math.max(2, Math.min(gridColumns - widget.x,
                Math.round((widthFor(widget.w) + gestureDeltaX + gap) / (cellWidth + gap))));
        }
        return widget.w;
    }

    function rowsFor(widget) {
        if (activeWidgetId === widget.id && activeGesture === "resize") {
            return Math.max(2, Math.min(8,
                Math.round((heightFor(widget.h) + gestureDeltaY + gap) / (rowHeight + gap))));
        }
        return widget.h;
    }

    function startGesture(widget, kind) {
        activeWidgetId = widget.id;
        activeGesture = kind;
        gestureStartX = widget.x * (cellWidth + gap);
        gestureStartY = widget.y * (rowHeight + gap);
        gestureDeltaX = 0;
        gestureDeltaY = 0;
    }

    function updateGesture(dx, dy) {
        gestureDeltaX = dx;
        gestureDeltaY = dy;
    }

    function finishGesture() {
        if (activeWidgetId === "")
            return;

        var current = findWidget(activeWidgetId);

        if (current) {
            var x = current.x;
            var y = current.y;
            var w = current.w;
            var h = current.h;

            if (activeGesture === "move") {
                x = Math.max(0, Math.min(gridColumns - w,
                    Math.round((gestureStartX + gestureDeltaX) / (cellWidth + gap))));
                y = Math.max(0,
                    Math.round((gestureStartY + gestureDeltaY) / (rowHeight + gap)));
            } else if (activeGesture === "resize") {
                w = columnsFor(current);
                h = rowsFor(current);
            }

            if (!overlapsOther(current.id, x, y, w, h))
                updateWidget(current.id, { x: x, y: y, w: w, h: h });
        }

        activeWidgetId = "";
        activeGesture = "";
        gestureDeltaX = 0;
        gestureDeltaY = 0;
    }

    function findWidget(id) {
        for (var i = 0; i < widgets.length; ++i) {
            if (widgets[i].id === id)
                return widgets[i];
        }
        return null;
    }

    function overlapsOther(id, x, y, w, h) {
        for (var i = 0; i < widgets.length; ++i) {
            var other = widgets[i];

            if (other.id === id)
                continue;

            if (x < other.x + other.w && x + w > other.x
                    && y < other.y + other.h && y + h > other.y)
                return true;
        }

        return false;
    }

    function updateWidget(id, changes) {
        var next = [];

        for (var i = 0; i < widgets.length; ++i) {
            var current = widgets[i];

            if (current.id !== id) {
                next.push(current);
                continue;
            }

            var updated = {};

            for (var key in current)
                updated[key] = current[key];

            for (var changedKey in changes)
                updated[changedKey] = changes[changedKey];

            next.push(updated);
        }

        widgets = next;
        layoutChanged(widgets);
    }

    function addWidget(type, title) {
        var y = 0;

        for (var i = 0; i < widgets.length; ++i)
            y = Math.max(y, widgets[i].y + widgets[i].h);

        var xField = fieldNames.length > 0 ? fieldNames[0] : "";
        var yField = fieldNames.length > 1 ? fieldNames[1] : xField;

        for (var f = 0; f < fieldNames.length; ++f) {
            if (rows.length > 0 && isFinite(Number(rows[0][fieldNames[f]]))) {
                yField = fieldNames[f];
                break;
            }
        }

        var next = widgets.slice(0);

        next.push({
            id: "widget-" + Date.now() + "-" + next.length,
            title: title.trim() || type.charAt(0).toUpperCase() + type.slice(1),
            type: type,
            x: 0,
            y: y,
            w: 6,
            h: 3,
            xField: xField,
            yField: yField
        });

        widgets = next;
        layoutChanged(widgets);
    }

    function removeWidget(id) {
        var next = [];

        for (var i = 0; i < widgets.length; ++i) {
            if (widgets[i].id !== id)
                next.push(widgets[i]);
        }

        widgets = next;
        layoutChanged(widgets);
    }

    function setLayout(layout) {
        if (!Array.isArray(layout))
            return false;

        for (var i = 0; i < layout.length; ++i) {
            var widget = layout[i];

            if (!widget || typeof widget.id !== "string"
                    || typeof widget.title !== "string"
                    || widgetTypes.indexOf(widget.type) < 0
                    || !isFinite(Number(widget.x))
                    || !isFinite(Number(widget.y))
                    || !isFinite(Number(widget.w))
                    || !isFinite(Number(widget.h))
                    || Math.floor(Number(widget.x)) !== Number(widget.x)
                    || Math.floor(Number(widget.y)) !== Number(widget.y)
                    || Math.floor(Number(widget.w)) !== Number(widget.w)
                    || Math.floor(Number(widget.h)) !== Number(widget.h)
                    || widget.x < 0 || widget.y < 0
                    || widget.w < 2 || widget.w > gridColumns
                    || widget.h < 2 || widget.h > 8
                    || widget.x + widget.w > gridColumns
                    || typeof widget.xField !== "string"
                    || typeof widget.yField !== "string") {
                return false;
            }

            for (var previous = 0; previous < i; ++previous) {
                var other = layout[previous];

                if (other.id === widget.id
                        || (widget.x < other.x + other.w
                            && widget.x + widget.w > other.x
                            && widget.y < other.y + other.h
                            && widget.y + widget.h > other.y))
                    return false;
            }
        }

        widgets = layout;
        return true;
    }

    // ========================================
    // ROOT BACKGROUND
    // ========================================

    Rectangle {
        anchors.fill: parent
        color: Theme.background
    }


    // ========================================
    // MODERN TOOLBAR
    // ========================================

    Rectangle {
        id: toolbarBackground

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 72
        radius: 12

        color: Theme.sidebarTop
        border.color: Theme.border
        border.width: 1

        RowLayout {
            id: toolbar

            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 12
            Item {
                Layout.fillWidth: true
            }

            // Edit layout button
            Button {
                id: editButton

                text: root.editMode ? "✓  Done" : "✎  Edit layout"

                Layout.preferredHeight: 40
                Layout.minimumWidth: 112

                padding: 12

                onClicked: root.editMode = !root.editMode

                contentItem: Text {
                    text: editButton.text
                    color: root.editMode
                           ? Theme.accentBlue
                           : Theme.textPrimary

                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8

                    color: root.editMode
                           ? Qt.darker(Theme.accentBlue, 1.7)
                           : editButton.hovered
                             ? Theme.hover
                             : Theme.card

                    border.color: root.editMode
                                  ? Theme.accentBlue
                                  : Theme.border

                    border.width: 1
                }
            }

            // Add widget button
            Button {
                id: addButton

                text: "+  Add widget"

                Layout.preferredHeight: 40
                Layout.minimumWidth: 120

                padding: 12

                onClicked: addDialog.open()

                contentItem: Text {
                    text: addButton.text
                    color: Theme.textPrimary

                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8

                    color: addButton.hovered
                           ? Qt.darker(Theme.accentBlue, 1.2)
                           : Theme.accentBlue

                    border.color: Theme.accentBlue
                    border.width: 1
                }
            }

            // Vertical separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 28

                color: Theme.border
            }

            // Save button
            Button {
                id: saveButton

                text: "↥  Save layout"

                Layout.preferredHeight: 40
                Layout.minimumWidth: 120

                padding: 12

                onClicked: root.saveRequested(root.widgets)

                contentItem: Text {
                    text: saveButton.text
                    color: Theme.textPrimary

                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 8

                    color: saveButton.hovered
                           ? Theme.hover
                           : Theme.card

                    border.color: Theme.accentGreen
                    border.width: 1
                }
            }
        }
    }


    // ========================================
    // ERROR MESSAGE
    // ========================================

    Rectangle {
        id: errorBackground
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolbarBackground.bottom
        anchors.topMargin: 5

        height: root.source && root.source.errorMessage.length > 0
                ? 34 : 0

        visible: height > 0
        color: Theme.card
        border.color: Theme.accentRed
        radius: 6

        Text {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            verticalAlignment: Text.AlignVCenter
            text: root.source ? root.source.errorMessage : ""
            color: Theme.accentRed

            font.family: Theme.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    // ========================================
    // DASHBOARD BOARD
    // ========================================

    Flickable {
        id: scrollArea

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: errorBackground.bottom
        anchors.bottom: parent.bottom

        clip: true
        contentWidth: width
        contentHeight: board.y + board.height
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: board

            x: 8
            y: 8

            width: Math.max(1, scrollArea.width - 16)

            height: {
                var bottom = 0;

                for (var i = 0; i < root.widgets.length; ++i)
                    bottom = Math.max(
                        bottom,
                        root.widgets[i].y + root.rowsFor(root.widgets[i])
                    );

                return Math.max(
                    350,
                    root.heightFor(Math.max(1, bottom))
                );
            }

            Repeater {
                model: root.widgets

                delegate: DashboardWidget {
                    id: dashboardWidget

                    required property var modelData
                    required property int index

                    property var config: modelData

                    x: root.xFor(config)
                    y: root.yFor(config)

                    width: root.widthFor(root.columnsFor(config))
                    height: root.heightFor(root.rowsFor(config))

                    z: root.activeWidgetId === config.id ? 1 : 0

                    rows: root.rows
                    fieldNames: root.fieldNames
                    editMode: root.editMode
                    widget: config

                    onFieldChanged: function(name, value) {
                        var changes = {};
                        changes[name] = value;
                        root.updateWidget(config.id, changes);
                    }

                    onRemoveRequested:
                        root.removeWidget(config.id)

                    onDragStarted:
                        root.startGesture(config, "move")

                    onDragMoved: function(dx, dy) {
                        root.updateGesture(dx, dy);
                    }

                    onDragFinished:
                        root.finishGesture()

                    onResizeStarted:
                        root.startGesture(config, "resize")

                    onResizeMoved: function(dx, dy) {
                        root.updateGesture(dx, dy);
                    }

                    onResizeFinished:
                        root.finishGesture()
                }
            }
        }
    }

    // ========================================
    // ADD WIDGET DIALOG
    // ========================================


    Dialog {
        id: addDialog

        title: "Add dashboard widget"
        modal: true
        anchors.centerIn: Overlay.overlay

        width: 380
        padding: 20

        standardButtons: Dialog.NoButton

        property string widgetType: "line"
        property string widgetTitle: ""

        background: Rectangle {
            color: Theme.sidebarTop
            radius: 14
            border.color: Theme.border
            border.width: 1
        }

        header: ColumnLayout {
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 10
                    color: Theme.card
                    border.color: Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: Theme.accentBlue
                        font.pixelSize: 25
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Add new widget"
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        text: "Customize your dashboard"
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 12
                height: 1
                color: Theme.border
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            Text {
                text: "Widget type"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            ComboBox {
                id: typeInput

                Layout.fillWidth: true
                Layout.preferredHeight: 42

                model: root.widgetTypes
                currentIndex: 0

                onActivated: function(index) {
                    addDialog.widgetType = root.widgetTypes[index]
                }

                contentItem: Text {
                    leftPadding: 12
                    rightPadding: 30
                    text: typeInput.displayText
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter
                }

                indicator: Text {
                    x: typeInput.width - width - 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "⌄"
                    color: Theme.textSecondary
                    font.pixelSize: 18
                }

                background: Rectangle {
                    radius: 8
                    color: Theme.card
                    border.color: typeInput.activeFocus
                                 ? Theme.accentBlue
                                 : Theme.border
                    border.width: 1
                }

                popup: Popup {
                    y: typeInput.height + 4
                    width: typeInput.width
                    padding: 4

                    background: Rectangle {
                        color: Theme.sidebarTop
                        border.color: Theme.border
                        radius: 8
                    }

                    contentItem: ListView {
                        implicitHeight: Math.min(contentHeight, 220)
                        model: typeInput.popup.visible
                               ? typeInput.delegateModel
                               : null
                        clip: true
                        currentIndex: typeInput.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator {}
                    }
                }

                delegate: ItemDelegate {
                    width: typeInput.width
                    height: 38

                    contentItem: Text {
                        text: modelData
                        color: highlighted
                               ? Theme.accentBlue
                               : Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 10
                    }

                    background: Rectangle {
                        radius: 6
                        color: highlighted
                               ? Theme.hover
                               : "transparent"
                    }

                    highlighted: typeInput.highlightedIndex === index
                }
            }

            Text {
                Layout.topMargin: 6
                text: "Widget title"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            TextField {
                id: titleInput

                Layout.fillWidth: true
                Layout.preferredHeight: 42

                placeholderText: "Enter widget title..."
                color: Theme.textPrimary
                placeholderTextColor: Theme.textSecondary

                font.family: Theme.fontFamily
                font.pixelSize: 13
                selectByMouse: true

                background: Rectangle {
                    radius: 8
                    color: Theme.card
                    border.color: titleInput.activeFocus
                                 ? Theme.accentBlue
                                 : Theme.border
                    border.width: 1
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 14
                spacing: 10

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Cancel"
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 38

                    onClicked: addDialog.reject()

                    contentItem: Text {
                        text: parent.text
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered
                               ? Theme.hover
                               : Theme.card
                        border.color: Theme.border
                    }
                }

                Button {
                    text: "Add widget"
                    Layout.preferredWidth: 115
                    Layout.preferredHeight: 38

                    onClicked: addDialog.accept()

                    contentItem: Text {
                        text: parent.text
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 8
                        color: parent.hovered
                               ? Qt.darker(Theme.accentBlue, 1.2)
                               : Theme.accentBlue
                    }
                }
            }
        }

        onOpened: {
            widgetType = "line"
            widgetTitle = ""
            typeInput.currentIndex = 0
            titleInput.text = ""
        }

        onAccepted: {
            root.addWidget(widgetType, titleInput.text)
        }
    }


    // ========================================
    // FILE DIALOG
    // ========================================

    FileDialog {
        id: fileDialog

        title: "Choose JSON or CSV data"

        nameFilters: [
            "Data files (*.json *.csv)",
            "JSON files (*.json)",
            "CSV files (*.csv)"
        ]

        onAccepted: {
            if (root.source)
                root.source.loadFile(selectedFile);
        }
    }

    // ========================================
    // JSON DIALOG
    // ========================================

    Dialog {
        id: jsonDialog

        title: "Load JSON data"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: Theme.sidebarTop
            border.color: Theme.border
            radius: 12
        }

        contentItem: TextArea {
            id: jsonInput

            width: 520
            height: 300

            placeholderText: '[{"month":"Jan","sales":120}]'
            wrapMode: TextEdit.NoWrap
            selectByMouse: true

            color: Theme.textPrimary
            placeholderTextColor: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 13

            background: Rectangle {
                color: Theme.card
                border.color: Theme.border
                radius: 7
            }
        }

        onOpened:
            jsonInput.text = ""

        onAccepted: {
            if (root.source)
                root.source.loadJson(jsonInput.text);
        }
    }
}

