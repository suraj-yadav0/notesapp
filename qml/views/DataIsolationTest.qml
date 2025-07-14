/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * Data Isolation Test - Tests that editing one item doesn't affect others
 */

import QtQuick 2.7
import QtQuick.Controls 2.2 as QC2
import "../models"

Rectangle {
    id: testPage
    width: 600
    height: 800
    color: "#f5f5f5"

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        QC2.Label {
            text: "Data Isolation Test"
            font.pixelSize: 28
            font.bold: true
            color: "#2c3e50"
        }

        QC2.Label {
            text: "This test verifies that editing one item doesn't affect others"
            font.pixelSize: 14
            color: "#7f8c8d"
            wrapMode: Text.WordWrap
            width: parent.width
        }

        // Notes Test Section
        Rectangle {
            width: parent.width
            height: 300
            color: "white"
            border.color: "#bdc3c7"
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Row {
                    spacing: 10
                    QC2.Label {
                        text: "📝 Notes Test"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QC2.Button {
                        text: "Add Test Note"
                        onClicked: {
                            var timestamp = new Date().toLocaleTimeString();
                            notesModel.createNote("Note " + timestamp, "Content created at " + timestamp, false);
                        }
                    }
                }

                ListView {
                    width: parent.width
                    height: 200
                    model: notesModel.notes
                    spacing: 5

                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: index % 2 === 0 ? "#ecf0f1" : "#white"
                        border.color: "#bdc3c7"
                        border.width: 1
                        radius: 4

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Column {
                                width: parent.width * 0.6
                                spacing: 2

                                QC2.Label {
                                    text: "ID: " + (model.id || "N/A") + " | " + (model.title || "No Title")
                                    font.bold: true
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                QC2.Label {
                                    text: model.content || "No Content"
                                    font.pixelSize: 10
                                    color: "#7f8c8d"
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            QC2.Button {
                                text: "Edit"
                                height: 30
                                onClicked: {
                                    var newTitle = "EDITED Note " + model.id;
                                    var newContent = "EDITED content for note " + model.id + " at " + new Date().toLocaleTimeString();

                                    notesModel.setCurrentNote(index);
                                    notesModel.updateCurrentNote(newTitle, newContent, false);

                                    console.log("Edited note at index", index, "with ID", model.id);
                                }
                            }
                        }
                    }
                }

                NotesModel {
                    id: notesModel

                    Component.onCompleted: {
                        // Add some initial test notes
                        createNote("Initial Note 1", "This is the first test note", false);
                        createNote("Initial Note 2", "This is the second test note", false);
                        createNote("Initial Note 3", "This is the third test note", false);
                    }
                }
            }
        }

        // ToDo Test Section
        Rectangle {
            width: parent.width
            height: 300
            color: "white"
            border.color: "#bdc3c7"
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Row {
                    spacing: 10
                    QC2.Label {
                        text: "✅ ToDo Test"
                        font.pixelSize: 18
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    QC2.Button {
                        text: "Add Test Task"
                        onClicked: {
                            var timestamp = new Date().toLocaleTimeString();
                            todoModel.addItem("Task created at " + timestamp);
                        }
                    }
                }

                ListView {
                    width: parent.width
                    height: 200
                    model: todoModel.model
                    spacing: 5

                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: index % 2 === 0 ? "#ecf0f1" : "white"
                        border.color: "#bdc3c7"
                        border.width: 1
                        radius: 4

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            QC2.CheckBox {
                                checked: model.completed
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    todoModel.toggleItem(index);
                                    console.log("Toggled task at index", index);
                                }
                            }

                            QC2.Label {
                                text: model.text || "No Text"
                                font.pixelSize: 12
                                color: model.completed ? "#95a5a6" : "#2c3e50"
                                width: parent.width * 0.5
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            QC2.Button {
                                text: "Edit"
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    var newText = "EDITED Task " + index + " at " + new Date().toLocaleTimeString();
                                    todoModel.updateItem(index, newText);
                                    console.log("Edited task at index", index);
                                }
                            }
                        }
                    }
                }

                ToDoModel {
                    id: todoModel

                    Component.onCompleted: {
                        // Clear existing and add test items
                        while (model.count > 0) {
                            model.remove(0);
                        }
                        addItem("Test Task 1");
                        addItem("Test Task 2");
                        addItem("Test Task 3");
                    }
                }
            }
        }

        // Test Results Display
        Rectangle {
            width: parent.width
            height: 100
            color: "#e8f5e8"
            border.color: "#27ae60"
            border.width: 2
            radius: 8

            Column {
                anchors.centerIn: parent
                spacing: 5

                QC2.Label {
                    text: "✅ Test Instructions"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#27ae60"
                }

                QC2.Label {
                    text: "1. Click 'Edit' on any note or task\n2. Verify that ONLY that item changes\n3. Other items should keep their original content"
                    font.pixelSize: 12
                    color: "#2c3e50"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
