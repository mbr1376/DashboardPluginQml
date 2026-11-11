
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Dashboard 1.0
Dialog {
    id: settingsDialog

    modal: true
    anchors.centerIn: Overlay.overlay

    width: 420
    padding: 22

    title: "Settings"

    background: Rectangle {
        color: Theme.card
        radius: 14
        border.color: Theme.border
        border.width: 1
    }

    header: Rectangle {
        color: "transparent"
        height: 42

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: "Application Settings"
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.bold: true
        }
    }

    contentItem: ColumnLayout {
        spacing: 16

        Text {
            text: "Appearance"
            color: Theme.accentBlue
            font.family: Theme.fontFamily
            font.pixelSize: 14
            font.bold: true
        }

        Text {
            text: "Choose application theme"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        ComboBox {
            id: themeCombo

            Layout.fillWidth: true
            model: Theme.themeNames
            currentIndex: Theme.currentThemeIndex

            onActivated: function(index) {
                Theme.currentThemeIndex = index
            }

            contentItem: Text {
                leftPadding: 12
                rightPadding: 30
                text: themeCombo.displayText
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: Theme.background
                radius: 7
                border.color: themeCombo.activeFocus
                             ? Theme.accentBlue
                             : Theme.border
                border.width: 1
            }

            indicator: Text {
                x: themeCombo.width - width - 12
                y: (themeCombo.height - height) / 2
                text: "⌄"
                color: Theme.textSecondary
                font.pixelSize: 18
            }

            delegate: ItemDelegate {
                width: themeCombo.width
                height: 38

                contentItem: Text {
                    text: modelData
                    color: highlighted
                           ? Theme.accentBlue
                           : Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: highlighted ? Theme.hover : Theme.card
                }

                highlighted: themeCombo.highlightedIndex === index
            }

            popup: Popup {
                y: themeCombo.height + 4
                width: themeCombo.width
                implicitHeight: contentItem.implicitHeight
                padding: 4

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: themeCombo.popup.visible
                           ? themeCombo.delegateModel : null
                    currentIndex: themeCombo.highlightedIndex
                    ScrollIndicator.vertical: ScrollIndicator {}
                }

                background: Rectangle {
                    color: Theme.card
                    radius: 7
                    border.color: Theme.border
                    border.width: 1
                }
            }
        }

        Text {
            text: "Color Preview"
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: [
                    Theme.accentBlue,
                    Theme.accentGreen,
                    Theme.accentRed,
                    Theme.accentOrange,
                    Theme.accentPurple
                ]

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 6
                    color: modelData
                }
            }
        }

        Text {
            text: "Active theme: " + Theme.currentThemeName
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    footer: DialogButtonBox {
        alignment: Qt.AlignRight

        Button {
            text: "Close"
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole

            onClicked: settingsDialog.close()

            contentItem: Text {
                text: "Close"
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: Theme.accentBlue
                radius: 7
            }
        }

        background: Rectangle {
            color: "transparent"
        }
    }
}
