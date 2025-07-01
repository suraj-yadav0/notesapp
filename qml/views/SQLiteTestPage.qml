/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * SQLite Integration Test and Demo
 */

import QtQuick 2.7
import QtQuick.Controls 2.2 as QC2
import "../models"

Rectangle {
    id: testPage
    width: 400
    height: 600
    color: "#f0f0f0"

    NotesModel {
        id: testNotesModel
        
        Component.onCompleted: {
            console.log("=== SQLite Integration Test ===");
            console.log("Database available:", useDatabase);
            console.log("Notes count:", notes.count);
            
            // Test creating a note
            var testId = createNote("Test SQLite Note", "This note was created to test SQLite integration!\n\nFeatures:\n- Database storage\n- Automatic timestamps\n- Rich text support", false);
            console.log("Created test note with ID:", testId);
            
            // Test updating
            if (testId) {
                setCurrentNote(0);
                updateCurrentNote("Updated SQLite Note", currentNote.content + "\n\n[Updated at " + new Date().toLocaleString() + "]");
                console.log("Updated note successfully");
            }
            
            // Show stats
            var stats = getDatabaseStats ? getDatabaseStats() : { notesCount: notes.count };
            console.log("Database stats:", JSON.stringify(stats));
        }
        
        onDataChanged: {
            console.log("Data changed - Notes count:", notes.count);
            notesListView.model = notes;
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        QC2.Label {
            text: "SQLite Integration Test"
            font.pixelSize: 24
            font.bold: true
        }

        Row {
            spacing: 10
            QC2.Label {
                text: "Storage Method:"
                font.pixelSize: 16
            }
            Rectangle {
                width: 100
                height: 30
                color: testNotesModel.useDatabase ? "#4CAF50" : "#FF9800"
                radius: 4
                QC2.Label {
                    anchors.centerIn: parent
                    text: testNotesModel.useDatabase ? "SQLite" : "Settings"
                    color: "white"
                    font.bold: true
                }
            }
        }

        Row {
            spacing: 10
            QC2.Button {
                text: "Add Test Note"
                onClicked: {
                    var noteId = testNotesModel.createNote(
                        "Test Note " + (testNotesModel.notes.count + 1),
                        "Content created at " + new Date().toLocaleString(),
                        false
                    );
                    console.log("Created note with ID:", noteId);
                }
            }

            QC2.Button {
                text: "Search Test"
                onClicked: {
                    if (testNotesModel.searchNotes) {
                        testNotesModel.searchNotes("Test");
                        console.log("Searched for 'Test'");
                    }
                }
            }

            QC2.Button {
                text: "Clear Search"
                onClicked: {
                    if (testNotesModel.searchNotes) {
                        testNotesModel.searchNotes("");
                        console.log("Cleared search");
                    }
                }
            }
        }

        QC2.Label {
            text: "Notes List (" + testNotesModel.notes.count + " items):"
            font.pixelSize: 18
            font.bold: true
        }

        ListView {
            id: notesListView
            width: parent.width
            height: 300
            model: testNotesModel.notes
            
            delegate: Rectangle {
                width: notesListView.width
                height: 80
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 4
                
                Column {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 5
                    
                    QC2.Label {
                        text: model.title
                        font.bold: true
                        font.pixelSize: 16
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    
                    QC2.Label {
                        text: model.content
                        font.pixelSize: 12
                        color: "#666666"
                        elide: Text.ElideRight
                        width: parent.width
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                    }
                    
                    Row {
                        spacing: 10
                        QC2.Label {
                            text: "ID: " + (model.id || "N/A")
                            font.pixelSize: 10
                            color: "#888888"
                        }
                        QC2.Label {
                            text: "Created: " + (model.createdAt || "N/A")
                            font.pixelSize: 10
                            color: "#888888"
                        }
                        QC2.Label {
                            text: "Updated: " + (model.updatedAt || model.createdAt || "N/A")
                            font.pixelSize: 10
                            color: "#888888"
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Selected note:", model.title, "ID:", model.id);
                        testNotesModel.setCurrentNote(index);
                    }
                }
            }
        }

        QC2.Label {
            text: "Current Note: " + (testNotesModel.currentNote.title || "None selected")
            font.pixelSize: 14
            color: "#666666"
        }

        Row {
            spacing: 10
            QC2.Button {
                text: "Update Current"
                enabled: testNotesModel.currentNote.id > 0
                onClicked: {
                    testNotesModel.updateCurrentNote(
                        testNotesModel.currentNote.title,
                        testNotesModel.currentNote.content + "\n[Updated: " + new Date().toLocaleString() + "]"
                    );
                }
            }

            QC2.Button {
                text: "Delete Current"
                enabled: testNotesModel.currentNote.id > 0
                onClicked: {
                    testNotesModel.deleteCurrentNote();
                }
            }
        }
    }
}
