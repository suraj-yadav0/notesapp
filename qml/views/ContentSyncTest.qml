/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * Content Synchronization Test - Tests edit view content display
 */

import QtQuick 2.7
import QtQuick.Controls 2.2 as QC2
import "../models"

Rectangle {
    id: contentTestPage
    width: 700
    height: 900
    color: "#f8f9fa"

    NotesModel {
        id: testModel

        Component.onCompleted: {
            console.log("=== Content Sync Test Model Initialized ===");
            console.log("Database available:", useDatabase);

            // Create a test note with specific content
            var noteId = createNote("Content Test Note", "Original content for testing content synchronization.\n\nThis should be visible in edit mode.", false);
            console.log("Created test note with ID:", noteId);

            if (noteId && notes.count > 0) {
                setCurrentNote(0);
                console.log("Current note set for testing");
            }
        }

        onDataChanged: {
            console.log("Model data changed - Notes count:", notes.count);
            statusLabel.text = "✅ Model updated - Notes: " + notes.count;
        }

        onNoteSelectionChanged: {
            console.log("Note selection changed");
            currentNoteInfo.text = "Current: " + (currentNote.title || "None") + " | Content Length: " + (currentNote.content ? currentNote.content.length : 0);
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        QC2.Label {
            text: "🔍 Content Synchronization Test"
            font.pixelSize: 24
            font.bold: true
            color: "#2c3e50"
        }

        QC2.Label {
            text: "This test verifies that content is properly displayed in edit mode after updates"
            font.pixelSize: 12
            color: "#6c757d"
            wrapMode: Text.WordWrap
            width: parent.width
        }

        QC2.Label {
            id: statusLabel
            text: "Ready to test content synchronization"
            font.pixelSize: 14
            color: "#28a745"
        }

        QC2.Label {
            id: currentNoteInfo
            text: "Current: None selected"
            font.pixelSize: 12
            color: "#6c757d"
        }

        // Model Content Display
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
                    text: "📋 Model Content:"
                    font.bold: true
                }

                QC2.ScrollView {
                    width: parent.width
                    height: 120

                    QC2.Label {
                        text: testModel.currentNote ? (testModel.currentNote.content || "No content") : "No note selected"
                        wrapMode: Text.WordWrap
                        width: parent.width
                        font.pixelSize: 12
                        color: "#495057"
                    }
                }

                Row {
                    spacing: 10
                    QC2.Button {
                        text: "Select First Note"
                        onClicked: {
                            if (testModel.notes.count > 0) {
                                testModel.setCurrentNote(0);
                            }
                        }
                    }

                    QC2.Button {
                        text: "Refresh Model"
                        onClicked: {
                            testModel.loadNotesFromStorage();
                            if (testModel.notes.count > 0) {
                                testModel.setCurrentNote(0);
                            }
                        }
                    }
                }
            }
        }

        // Simulated Edit View
        Rectangle {
            width: parent.width
            height: 300
            color: "white"
            border.color: "#007bff"
            border.width: 2
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                QC2.Label {
                    text: "✏️ Simulated Edit View:"
                    font.bold: true
                    color: "#007bff"
                }

                QC2.TextField {
                    id: titleField
                    width: parent.width
                    placeholderText: "Title..."
                    text: testModel.currentNote ? testModel.currentNote.title : ""

                    // Update when model changes
                    Connections {
                        target: testModel
                        function onNoteSelectionChanged() {
                            titleField.text = testModel.currentNote ? testModel.currentNote.title : "";
                        }
                        function onDataChanged() {
                            titleField.text = testModel.currentNote ? testModel.currentNote.title : "";
                        }
                    }
                }

                QC2.ScrollView {
                    width: parent.width
                    height: 150

                    QC2.TextArea {
                        id: contentArea
                        placeholderText: "Content will appear here..."
                        text: testModel.currentNote ? testModel.currentNote.content : ""
                        wrapMode: TextArea.Wrap

                        // Update when model changes
                        Connections {
                            target: testModel
                            function onNoteSelectionChanged() {
                                contentArea.text = testModel.currentNote ? testModel.currentNote.content : "";
                                console.log("Content area updated with:", contentArea.text.length, "characters");
                            }
                            function onDataChanged() {
                                contentArea.text = testModel.currentNote ? testModel.currentNote.content : "";
                                console.log("Content area refreshed with:", contentArea.text.length, "characters");
                            }
                        }
                    }
                }

                Row {
                    spacing: 10

                    QC2.Button {
                        text: "💾 Update Content"
                        onClicked: {
                            var newContent = contentArea.text + "\n\n[UPDATED at " + new Date().toLocaleTimeString() + "]";
                            console.log("Updating note with new content:", newContent.length, "characters");

                            var result = testModel.updateCurrentNote(titleField.text, newContent, false);
                            if (result) {
                                statusLabel.text = "✅ Content updated successfully";
                                statusLabel.color = "#28a745";
                            } else {
                                statusLabel.text = "❌ Update failed";
                                statusLabel.color = "#dc3545";
                            }
                        }
                    }

                    QC2.Button {
                        text: "🔄 Force Refresh"
                        onClicked: {
                            titleField.text = testModel.currentNote ? testModel.currentNote.title : "";
                            contentArea.text = testModel.currentNote ? testModel.currentNote.content : "";
                            statusLabel.text = "🔄 Fields refreshed manually";
                            statusLabel.color = "#17a2b8";
                        }
                    }

                    QC2.Button {
                        text: "🧪 Add Test Update"
                        onClicked: {
                            contentArea.text = contentArea.text + "\n• Test update at " + new Date().toLocaleTimeString();
                        }
                    }
                }
            }
        }

        // Test Results
        Rectangle {
            width: parent.width
            height: 150
            color: "#e9ecef"
            border.color: "#adb5bd"
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                QC2.Label {
                    text: "🧪 Test Steps:"
                    font.bold: true
                    font.pixelSize: 14
                }

                QC2.Label {
                    text: "1. Edit content in the text area above\n2. Click 'Update Content' to save\n3. Verify that the content stays visible in edit view\n4. Check that Model Content shows the updated content"
                    font.pixelSize: 11
                    color: "#495057"
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                Row {
                    spacing: 10

                    Rectangle {
                        width: 15
                        height: 15
                        radius: 7.5
                        color: titleField.text === (testModel.currentNote ? testModel.currentNote.title : "") ? "#28a745" : "#dc3545"
                    }
                    QC2.Label {
                        text: "Title Sync"
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: 15
                        height: 15
                        radius: 7.5
                        color: contentArea.text === (testModel.currentNote ? testModel.currentNote.content : "") ? "#28a745" : "#dc3545"
                    }
                    QC2.Label {
                        text: "Content Sync"
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
