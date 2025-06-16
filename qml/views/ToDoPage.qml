import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

Page {
    id: todoPage
    
    property alias todoModel: todoListModel
    
    // List model to store todo items
    ListModel {
        id: todoListModel
        
        Component.onCompleted: {
            // Add initial todo items
            append({
                "text": "Grocery shopping",
                "completed": false
            })
            append({
                "text": "Book doctor's appointment", 
                "completed": false
            })
            append({
                "text": "Pay bills",
                "completed": false
            })
            append({
                "text": "Call mom",
                "completed": false
            })
            append({
                "text": "Finish project report",
                "completed": false
            })
        }
    }
    
    header: PageHeader {
        id: pageHeader
        title: "To-Do"
        
        trailingActionBar {
            actions: [
                Action {
                    iconName: "add"
                    text: "Add"
                    onTriggered: {
                        if (addTextField.text.trim() !== "") {
                            todoListModel.append({
                                "text": addTextField.text.trim(),
                                "completed": false
                            })
                            addTextField.text = ""
                        }
                    }
                }
            ]
        }
    }
    
    ColumnLayout {
        anchors {
            fill: parent
            margins: units.gu(2)
            topMargin: pageHeader.height + units.gu(2)
        }
        spacing: units.gu(2)
        
        // Add new todo section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(6)
            color: "#3a3a3a"
            radius: units.gu(1)
            
            TextField {
                id: addTextField
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }
                placeholderText: "Add a to-do"
                color: "white"
                
                // Style the text field to match the design
                style: TextFieldStyle {
                    background: Rectangle {
                        color: "transparent"
                    }
                }
                
                onAccepted: {
                    if (text.trim() !== "") {
                        todoListModel.append({
                            "text": text.trim(),
                            "completed": false
                        })
                        text = ""
                    }
                }
            }
        }
        
        // Todo list
        ListView {
            id: todoListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            model: todoListModel
            spacing: units.gu(1)
            
            delegate: ListItem {
                id: todoItem
                height: units.gu(7)
                
                // Swipe to delete functionality
                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            backgroundColor: "#d32f2f"
                            onTriggered: {
                                todoListModel.remove(index)
                            }
                        }
                    ]
                }
                
                ListItemLayout {
                    anchors.fill: parent
                    
                    // Checkbox
                    CheckBox {
                        id: todoCheckBox
                        SlotsLayout.position: SlotsLayout.Leading
                        checked: model.completed
                        
                        onCheckedChanged: {
                            todoListModel.setProperty(index, "completed", checked)
                        }
                    }
                    
                    // Todo text
                    Label {
                        SlotsLayout.position: SlotsLayout.Main
                        text: model.text
                        color: model.completed ? "#888888" : "white"
                        fontSize: "medium"
                        
                        // Strike through effect for completed items
                        font.strikeout: model.completed
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                todoCheckBox.checked = !todoCheckBox.checked
                            }
                        }
                    }
                }
                
                // Divider line
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: units.dp(1)
                    color: "#444444"
                }
            }
        }
        
        // Empty state message
        Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            text: "No tasks yet. Add one above!"
            color: "#888888"
            fontSize: "large"
            horizontalAlignment: Text.AlignHCenter
            visible: todoListModel.count === 0
        }
    }
}