
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Dashboard 1.0

Dialog {
    id: settingsDialog

    modal: true
    anchors.centerIn: Overlay.overlay

    width: 420
    implicitHeight: 390

    padding: 22
    spacing: 16

    title: "Settings"

    background: Rectangle {
        color: Theme.card
        radius: 14
        border.color: Theme.border
        border.width: 1
    }

    header: Item {
        implicitHeight: 42
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            text: "Application Settings"

            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.bold: true

        }
    }

    contentItem: ColumnLayout {
        spacing: 12

        // Appearance title
        Text {
            Layout.fillWidth: true

            text: "Appearance"
            color: Theme.accentBlue

            font.family: Theme.fontFamily
            font.pixelSize: 14
            font.bold: true
        }

        // Description
        Text {
            Layout.fillWidth: true

            text: "Choose your application theme"

            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        // Theme selector
        ComboBox {
            id: themeCombo

            Layout.fillWidth: true
            Layout.preferredHeight: 40

            model: Theme.allThemeNames
            currentIndex: Theme.currentThemeIndex

            onActivated: function(index) {
                Theme.setThemeByIndex(index)
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

            indicator: Text {
                x: themeCombo.width - width - 12
                y: (themeCombo.height - height) / 2

                text: "⌄"
                color: Theme.textSecondary
                font.pixelSize: 18
            }

            background: Rectangle {
                color: Theme.background
                radius: 7

                border.width: 1
                border.color: themeCombo.activeFocus
                              ? Theme.accentBlue
                              : Theme.border
            }

            delegate: ItemDelegate {
                width: themeCombo.width
                height: 38

                highlighted: themeCombo.highlightedIndex === index

                contentItem: Text {
                    text: modelData

                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: 13

                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: 5

                    color: parent.highlighted
                           ? Theme.background
                           : Theme.card
                }
            }

            popup.background: Rectangle {
                color: Theme.card
                radius: 8

                border.color: Theme.border
                border.width: 1
            }
        }

        // Color preview label
        Text {
            Layout.fillWidth: true

            text: "Color Preview"

            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        // Color preview
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            spacing: 8

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
                    Layout.fillHeight: true

                    radius: 6
                    color: modelData
                }
            }
        }

        // Current theme information
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 55

            radius: 8

            color: Theme.background
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10

                spacing: 10

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30

                    radius: 8
                    color: Theme.accentBlue
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing: 2

                    Text {
                        Layout.fillWidth: true

                        text: Theme.currentThemeName

                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true

                        text: Theme.isCustomTheme(
                                  Theme.currentThemeName)
                              ? "Custom Theme"
                              : "Built-in Theme"

                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }
            }
        }
    }

    footer: RowLayout {
        spacing: 10

        Item {
            Layout.fillWidth: true
        }

        Button {
            id: closeButton

            Layout.preferredWidth: 85
            Layout.preferredHeight: 36

            text: "Close"
            Layout.rightMargin: 10
            Layout.bottomMargin: 10
            onClicked: settingsDialog.close()

            contentItem: Text {
                text: closeButton.text

                color: Theme.buttonText
                font.family: Theme.fontFamily
                font.pixelSize: 12

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 7

                color: closeButton.down
                       ? Theme.accentBlue
                       : Theme.accentBlue

                opacity: closeButton.down ? 0.75 : 1.0
            }
        }
    }
}



