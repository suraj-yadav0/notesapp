import QtQuick 2.9
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3

import "../models"

Page {
    id: todoPage

    // Add this property for visibility control
   

        // Initialize the data model
        ToDoModel {
            id: todoData
        }

        header: PageHeader {
            id: header
            title: i18n.tr("To-Do")

            trailingActionBar {
                actions: [
                    Action {
                        id: addAction
                        iconName: "add"
                        text: i18n.tr("Add")
                        onTriggered: {
                            addDialog.open()
                        }
                    }
                ]
            }
        }

        // Add new todo dialog
        // Dialog {
        //     id: addDialog
        //     title: i18n.tr("Add new task")
        //
        //     TextField {
        //         id: newTaskField
        //         placeholderText: i18n.tr("Add a to-do")
        //         onAccepted: {
        //             if (text.trim() !== "") {
        //                 todoData.model.addItem(text.trim())
        //                 text = ""
        //                 addDialog.close()
        //             }
        //         }
        //     }
        //
        //     Button {
        //         text: i18n.tr("Add")
        //         color: theme.palette.normal.positive
        //         onClicked: {
        //             if (newTaskField.text.trim() !== "") {
        //                 todoData.model.addItem(newTaskField.text.trim())
        //                 newTaskField.text = ""
        //                 addDialog.close()
        //             }
        //         }
        //     }
        //
        //     Button {
        //         text: i18n.tr("Cancel")
        //         onClicked: {
        //             newTaskField.text = ""
        //             addDialog.close()
        //         }
        //     }
        // }

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
                        color: model.completed ? theme.palette.normal.backgroundSecondaryText : theme.palette.normal.backgroundText
                        wrapMode: Text.WordWrap
                    }
                }

                onClicked: todoData.toggleItem(index)
            }

            // Empty state
            Label {
                anchors.centerIn: parent
                visible: todoData.count === 0
                text: i18n.tr("No tasks yet.\nTap + to add one!")
                horizontalAlignment: Text.AlignHCenter
                color: theme.palette.normal.backgroundSecondaryText
            }
        }

     

}