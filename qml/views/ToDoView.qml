import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

import "../models"

Page {
    id: todoPage

    signal backRequested

    // Initialize the data model
    ToDoModel {
        id: todoData
    }

    header: PageHeader {
        id: header
        title: i18n.tr("To-Do")

        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Back")
                    onTriggered: {
                        console.log("🔙 Back button triggered in ToDoView");
                        todoPage.backRequested();
                    }
                }
            ]
        }

        trailingActionBar {
            actions: [
                Action {
                    id: addAction
                    iconName: "add"
                    text: i18n.tr("Add")
                    onTriggered: {
                        console.log("🔵 Add action triggered - opening dialog");
                        addDialog.open();
                    }
                }
            ]
        }
    }

    // Add new todo dialog as a popup page
    Rectangle {
        id: addDialog
        visible: false
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7) // Semi-transparent overlay
        z: 1000 // Ensure dialog is on top

        function open() {
            console.log("🟢 Opening ToDo dialog");
            visible = true;
            newTaskField.text = "";
            newTaskField.forceActiveFocus();
        }

        function close() {
            console.log("🔴 Closing ToDo dialog");
            visible = false;
        }

        // Background area that closes dialog when clicked
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("🔵 Background clicked - closing dialog");
                addDialog.close();
            }
        }

        Rectangle {
            id: dialogBox
            width: Math.min(parent.width - units.gu(4), units.gu(40))
            height: dialogContent.height + units.gu(4)
            anchors.centerIn: parent
            color: "#F7F7F7" // Light background color
            radius: units.gu(1)
            border.color: "#E0E0E0" // Light border color
            border.width: 1

            // Prevent clicks from propagating to background
            MouseArea {
                anchors.fill: parent
                onClicked:
                // Do nothing - just prevent background clicks
                {}
            }

            Column {
                id: dialogContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: units.gu(2)
                spacing: units.gu(2)

                Label {
                    text: i18n.tr("Add new task")
                    font.bold: true
                    color: "#333333" // Dark grey text
                }

                TextField {
                    id: newTaskField
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: i18n.tr("Enter your task...")

                    onTextChanged: {
                        console.log("🔵 TextField text changed to:", text, "length:", text.length);
                    }

                    onAccepted: {
                        console.log("🔵 TextField onAccepted triggered, text:", text);
                        if (text.trim() !== "") {
                            console.log("🟢 Adding todo item:", text.trim());
                            todoData.addItem(text.trim());
                            addDialog.close();
                        } else {
                            console.log("🔴 Empty text, not adding todo");
                        }
                    }

                    Keys.onEscapePressed: {
                        console.log("🔵 Escape pressed, closing dialog");
                        addDialog.close();
                    }
                }

                Row {
                    anchors.right: parent.right
                    spacing: units.gu(1)

                    Button {
                        text: i18n.tr("Cancel")
                        color: "#CCCCCC" // Light grey

                        onClicked: {
                            console.log("🔴 Cancel button clicked");
                            addDialog.close();
                        }
                    }

                    Button {
                        text: i18n.tr("Add")
                        color: "#4CAF50" // Green color
                        enabled: newTaskField.text.trim() !== ""

                        onClicked: {
                            console.log("🔵 Add button clicked, text:", newTaskField.text);
                            if (newTaskField.text.trim() !== "") {
                                console.log("🟢 Adding todo item from button:", newTaskField.text.trim());
                                todoData.addItem(newTaskField.text.trim());
                                addDialog.close();
                            } else {
                                console.log("🔴 Empty text from button, not adding todo");
                            }
                        }
                    }
                }
            }
        }
    }

    // Main todo list
    ListView {
        id: todoList
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(2)
        }

        model: todoData.model
        spacing: units.gu(1)

        delegate: ListItem {
            id: listItem
            height: todoLayout.height + units.gu(2)

            // Swipe to delete
            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: todoData.removeItem(index)
                    }
                ]
            }

            RowLayout {
                id: todoLayout
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                CheckBox {
                    id: checkbox
                    checked: model.completed
                    onClicked: todoData.toggleItem(index)
                }

                Label {
                    Layout.fillWidth: true
                    text: model.text
                    color: model.completed ? "#999999" : "#333333"
                    wrapMode: Text.WordWrap
                }
            }

            onClicked: todoData.toggleItem(index)
        }

        // Empty state
        Label {
            anchors.centerIn: parent
            visible: todoData.count === 0
            text: i18n.tr("No tasks yet.\nTap + to add your first task!")
            horizontalAlignment: Text.AlignHCenter
            color: "#999999" // Cool grey color
        }
    }
}
