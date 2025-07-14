import QtQuick 2.7
import Lomiri.Components 1.3
import "../common/constants"
import "../common/theme"

Page {
    id: settingsPage

    signal backRequested

    header: PageHeader {
        title: i18n.tr("Settings")
        StyleHints {
            foregroundColor: theme.palette.normal.backgroundText
            backgroundColor: theme.palette.normal.background
            dividerColor: theme.palette.normal.background
        }
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: settingsPage.backRequested()
            }
        ]
    }

    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background

        Flickable {
            anchors.fill: parent
            contentHeight: settingsColumn.height + units.gu(4)

            Column {
                id: settingsColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: units.gu(2)
                }
                spacing: units.gu(2)

                // Appearance Section
                Label {
                    text: i18n.tr("Appearance")
                    fontSize: "large"
                    font.weight: Font.Bold
                    color: ThemeHelper.getTextColor()
                    anchors.left: parent.left
                }

                // Dark Mode Setting
                ListItem {
                    width: parent.width
                    height: units.gu(8)
                    divider.visible: false

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: units.gu(1)
                            rightMargin: units.gu(1)
                        }
                        spacing: units.gu(2)

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - darkModeSwitch.width - parent.spacing

                            Label {
                                text: i18n.tr("Dark Mode")
                                fontSize: "medium"
                                font.weight: Font.Medium
                                color: ThemeHelper.getTextColor()
                            }

                            Label {
                                text: ThemeHelper.isDarkTheme ? i18n.tr("On") : i18n.tr("Off")
                                fontSize: "small"
                                color: theme.palette.normal.secondaryText
                            }
                        }

                        Switch {
                            id: darkModeSwitch
                            anchors.verticalCenter: parent.verticalCenter
                            checked: ThemeHelper.isDarkTheme
                            onClicked: {
                                ThemeHelper.toggleTheme();
                            }
                        }
                    }

                    onClicked: {
                        darkModeSwitch.clicked();
                    }
                }

                // Font Size Setting
                ListItem {
                    width: parent.width
                    height: units.gu(8)
                    divider.visible: false

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: units.gu(1)
                            rightMargin: units.gu(1)
                        }
                        spacing: units.gu(2)

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - fontSizeLabel.width - parent.spacing

                            Label {
                                text: i18n.tr("Font Size")
                                fontSize: "medium"
                                font.weight: Font.Medium
                                color: ThemeHelper.getTextColor()
                            }

                            Label {
                                text: i18n.tr("System default")
                                fontSize: "small"
                                color: theme.palette.normal.secondaryText
                            }
                        }

                        Label {
                            id: fontSizeLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: i18n.tr("Medium")
                            fontSize: "medium"
                            color: ThemeHelper.getTextColor()
                        }
                    }

                    onClicked: {
                        console.log("Font size setting tapped");
                    }
                }
            }
        }
    }
}
