/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * Save Functionality Test
 */

import QtQuick 2.7
import QtQuick.Controls 2.2 as QC2
import "../models"

Rectangle {
    id: saveTestPage
    width: 600
    height: 700
    color: "#f8f9fa"

    NotesModel {
        id: testModel

        Component.onCompleted: {
            console.log("=== Save Test Model Initialized ===");
            console.log("Database available:", useDatabase);

            // Create a test note
            var noteId = createNote("Test Save Note", "Original content for save testing", false);
            console.log("Created test note with ID:", noteId);

            if (noteId && notes.count > 0) {
                setCurrentNote(0);
                console.log("Current note set:", JSON.stringify(currentNote));
            }
        }

        onDataChanged: {
            console.log("Data changed event fired");
            saveResultText.text = "Data changed - Notes count: " + notes.count;
        }

        onNoteSelectionChanged: {
            console.log("Note selection changed event fired");
            currentNoteText.text = "Current: " + (currentNote.title || "None") + " (ID: " + currentNote.id + ")";
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        QC2.Label {
            text: "🔧 Save Functionality Test"
            font.pixelSize: 24
            font.bold: true
            color: "#2c3e50"
        }

        Rectangle {
            width: parent.width
            height: 50
            color: testModel.useDatabase ? "#d4edda" : "#fff3cd"
            border.color: testModel.useDatabase ? "#c3e6cb" : "#ffeaa7"
            border.width: 2
            radius: 8

            QC2.Label {
                anchors.centerIn: parent
                text: "Storage: " + (testModel.useDatabase ? "SQLite Database" : "Settings Fallback")
                font.bold: true
                color: testModel.useDatabase ? "#155724" : "#856404"
            }
        }

        QC2.Label {
            id: currentNoteText
            text: "Current: None selected"
            font.pixelSize: 14
            color: "#6c757d"
        }

        // Test Input Fields
        Rectangle {
            width: parent.width
            height: 200
            color: "white"
            border.color: "#dee2e6"
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                QC2.Label {
                    text: "Edit Note Content:"
                    font.bold: true
                }

                QC2.TextField {
                    id: titleInput
                    width: parent.width
                    placeholderText: "Enter title..."
                    text: testModel.currentNote ? testModel.currentNote.title : ""
                }

                QC2.ScrollView {
                    width: parent.width
                    height: 100

                    QC2.TextArea {
                        id: contentInput
                        placeholderText: "Enter content..."
                        text: testModel.currentNote ? testModel.currentNote.content : ""
                        wrapMode: TextArea.Wrap
                    }
                }

                Row {
                    spacing: 10

                    QC2.Button {
                        text: "💾 Save Note"
                        highlighted: true
                        onClicked: {
                            console.log("=== SAVE BUTTON CLICKED ===");
                            console.log("Title:", titleInput.text);
                            console.log("Content:", contentInput.text);
                            console.log("Current note ID:", testModel.currentNote.id);

                            var result = testModel.updateCurrentNote(titleInput.text, contentInput.text, false);
                            console.log("Save result:", result);

                            if (result) {
                                saveResultText.text = "✅ Save successful!";
                                saveResultText.color = "#28a745";
                            } else {
                                saveResultText.text = "❌ Save failed!";
                                saveResultText.color = "#dc3545";
                            }
                        }
                    }

                    QC2.Button {
                        text: "🔄 Reload"
                        onClicked: {
                            testModel.loadNotesFromStorage();
                            if (testModel.notes.count > 0) {
                                testModel.setCurrentNote(0);
                            }
                        }
                    }

                    QC2.Button {
                        text: "➕ Create New"
                        onClicked: {
                            var timestamp = new Date().toLocaleTimeString();
                            var newId = testModel.createNote("New Note " + timestamp, "Created at " + timestamp, false);
                            console.log("Created new note with ID:", newId);
                        }
                    }
                }
            }
        }

        QC2.Label {
            id: saveResultText
            text: "Ready to test save functionality"
            font.pixelSize: 14
            color: "#6c757d"
        }

        // Notes List
        Rectangle {
            width: parent.width
            height: 250
            color: "white"
            border.color: "#dee2e6"
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                QC2.Label {
                    text: "📝 Notes List (" + testModel.notes.count + " items):"
                    font.bold: true
                }

                ListView {
                    width: parent.width
                    height: 200
                    model: testModel.notes
                    spacing: 5

                    delegate: Rectangle {
                        width: parent.width
                        height: 60
                        color: index % 2 === 0 ? "#f8f9fa" : "white"
                        border.color: testModel.currentNote.id === model.id ? "#007bff" : "#e9ecef"
                        border.width: testModel.currentNote.id === model.id ? 2 : 1
                        radius: 4

                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Column {
                                width: parent.width * 0.7
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
                                    color: "#6c757d"
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                QC2.Label {
                                    text: "Updated: " + (model.updatedAt || "N/A")
                                    font.pixelSize: 9
                                    color: "#adb5bd"
                                }
                            }

                            QC2.Button {
                                text: "Select"
                                height: 30
                                onClicked: {
                                    console.log("Selecting note at index", index, "with ID", model.id);
                                    testModel.setCurrentNote(index);
                                    titleInput.text = testModel.currentNote.title;
                                    contentInput.text = testModel.currentNote.content;
                                }
                            }
                        }
                    }
                }
            }
        }

        // Debug Info
        Rectangle {
            width: parent.width
            height: 80
            color: "#e9ecef"
            border.color: "#adb5bd"
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                QC2.Label {
                    text: "🐛 Debug Info"
                    font.bold: true
                    font.pixelSize: 12
                }

                QC2.Label {
                    text: "Current Note JSON: " + JSON.stringify(testModel.currentNote)
                    font.pixelSize: 10
                    color: "#495057"
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }
    }
}
