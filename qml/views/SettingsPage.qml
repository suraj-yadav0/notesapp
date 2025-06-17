import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3


import "../models" as Models

Page {
    id: settingsPage

    property alias settingsModel: settingsModel
    // Add this property for visibility control
  //  property bool visible: true

    header: PageHeader {
        id: pageHeader
        title: "Settings"
        StyleHints {
            foregroundColor: theme.palette.normal.backgroundText
            backgroundColor: "#131520"
            dividerColor: "#131520"
        }
        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"
                    text: "Back"
                    onTriggered: {
                        // Hide settings page, show main page (handled in Main.qml)
                    }
                }
            ]
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#131520"

        Flickable {
            id: flickable
            anchors {
                fill: parent
                bottom: bottomNavigation.top
            }
            contentHeight: mainColumn.height

            Column {
                id: mainColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Repeater {
                    model: settingsModel
                    delegate: Column {
                        width: parent.width

                        // Category header
                        Item {
                            width: parent.width
                            height: index === 0 || model.category !== settingsModel.get(index - 1).category ? units.gu(5) : 0
                            visible: height > 0

                            Label {
                                anchors {
                                    left: parent.left
                                    leftMargin: units.gu(2)
                                    verticalCenter: parent.verticalCenter
                                }
                                text: model.category
                                fontSize: "large"
                                font.weight: Font.Bold
                                color: "white"
                            }
                        }

                        // Setting item
                        ListItem {
                            height: units.gu(9)
                            divider.visible: false

                            Rectangle {
                                anchors.fill: parent
                                color: "#131520"
                            }

                            Row {
                                anchors {
                                    left: parent.left
                                    leftMargin: units.gu(2)
                                    right: parent.right
                                    rightMargin: units.gu(2)
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: units.gu(2)

                                // Icon (for account)
                                Item {
                                    width: model.icon !== "" ? units.gu(7) : 0
                                    height: units.gu(7)
                                    visible: width > 0

                                    // UbuntuShape {
                                    //     anchors.fill: parent
                                    //     radius: "large"
                                    //     source: Image {
                                    //         source: "https://lh3.googleusercontent.com/aida-public/AB6AXuDoFt5Wk3qFI9joCcqaretEbEOtQ_2KM_goCv1oPtJ8iatlkkZ0iYVohs-goHnNSMhgeqg6_t0AdehrjMAhdjMh20GIgKE701SlHl4yh8oMwCYFjKlO1ZNKSGNIaVU0oeaK4BbyxOTAPqIuPDO4-mqdQxQAYUpYqWWLQZH13CnO_hevpjirlMQxKXXZplPAekt8XktCVkvPlFtLGipzqNksO9TKRvQftzAyMRW9y_EBBKIRfvmdlBXsCpCzRofERBQfqLY2lFI9sBFi"
                                    //         fillMode: Image.PreserveAspectCrop
                                    //     }
                                    // }
                                }

                                // Text content
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: units.gu(0.5)

                                    Label {
                                        text: model.title
                                        fontSize: "medium"
                                        color: "white"
                                        font.weight: Font.Medium
                                    }

                                    Label {
                                        text: model.subtitle
                                        fontSize: "small"
                                        color: "#99a0c2"
                                    }
                                }

                                // Spacer
                                Item {
                                    Layout.fillWidth: true
                                    width: parent.width - (model.icon !== "" ? units.gu(9) : 0) - valueItem.width - units.gu(4)
                                    height: 1
                                }

                                // Value/Control
                                Item {
                                    id: valueItem
                                    width: model.type === "toggle" ? units.gu(6) : valueLabel.width
                                    height: units.gu(4)
                                    anchors.verticalCenter: parent.verticalCenter

                                    // Toggle switch
                                    Switch {
                                        anchors.centerIn: parent
                                        visible: model.type === "toggle"
                                        checked: model.value

                                        onCheckedChanged: {
                                            settingsModel.setProperty(index, "value", checked)
                                        }
                                    }

                                    // Value label
                                    Label {
                                        id: valueLabel
                                        anchors.centerIn: parent
                                        visible: model.type !== "toggle"
                                        text: model.value
                                        fontSize: "medium"
                                        color: "white"
                                    }
                                }
                            }

                            onClicked: {
                                if (model.type === "selector") {
                                    // Handle selector tap
                                    console.log("Tapped:", model.title)
                                }
                            }
                        }
                    }
                }
            }
        }
    }


ListModel {
    id: settingsModel

    ListElement {
        category: "General"
        title: "Dark Mode"
        subtitle: "System default"
        type: "toggle"
        value: true
        icon: ""
    }

    ListElement {
        category: "Account"
        title: "Account"
        subtitle: "Logged in as user@example.com"
        type: "info"
        value: ""
        icon: "contact"
    }

    ListElement {
        category: "Appearance"
        title: "Theme"
        subtitle: "System default"
        type: "selector"
        value: "Light"
        icon: ""
    }

    ListElement {
        category: "Appearance"
        title: "Font size"
        subtitle: "16"
        type: "selector"
        value: "Medium"
        icon: ""
    }

    ListElement {
        category: "Notes"
        title: "Storage location"
        subtitle: "Local storage"
        type: "selector"
        value: "Device"
        icon: ""
    }

    ListElement {
        category: "Notes"
        title: "Backup frequency"
        subtitle: "Never"
        type: "selector"
        value: "Manual"
        icon: ""
    }

    ListElement {
        category: "Notifications"
        title: "Reminders"
        subtitle: "Off"
        type: "selector"
        value: "Disabled"
        icon: ""
    }
}

    // You can add bottom navigation here if needed, or keep it in MainView
}
