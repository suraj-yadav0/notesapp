/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * notesapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.0

// Enhanced NotesModel with SQLite database integration (hybrid approach)
Item {
    id: notesModel

    // Database configuration
    property string databaseName: "NotesAppDB"
    property string databaseVersion: "1.0"
    property string databaseDescription: "Notes Application Database"
    property int databaseSize: 1000000 // 1MB
    property var database: null
    property bool useDatabase: true

    // Expose the notes list model
    property alias notes: notesListModel
    
    // Current note being edited (moved from controller)
    property var currentNote: ({ id: -1, title: "", content: "", createdAt: "", updatedAt: "", index: -1 })
    
    // Signals (renamed to avoid conflicts)
    signal noteSelectionChanged()
    signal dataChanged()

    // Main notes list model
    ListModel {
        id: notesListModel
        
        // Load notes when component is ready
        Component.onCompleted: {
            initializeDatabase();
            loadNotesFromStorage();
        }
    }

    // Initialize database
    function initializeDatabase() {
        try {
            database = LocalStorage.openDatabaseSync(
                databaseName,
                databaseVersion,
                databaseDescription,
                databaseSize
            );

            // Create tables if they don't exist
            createTables();
            console.log("Database initialized successfully");
            useDatabase = true;
        } catch (error) {
            console.error("Failed to initialize database:", error);
            console.log("Falling back to Settings storage");
            useDatabase = false;
        }
    }

    // Create necessary tables
    function createTables() {
        if (!database) return;
        
        database.transaction(function(tx) {
            // Create notes table
            tx.executeSql(
                'CREATE TABLE IF NOT EXISTS notes (' +
                'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                'title TEXT NOT NULL, ' +
                'content TEXT, ' +
                'isRichText BOOLEAN DEFAULT 0, ' +
                'createdAt TEXT NOT NULL, ' +
                'updatedAt TEXT NOT NULL' +
                ')'
            );

            console.log("Database tables created successfully");
        });
    }

    // Fallback settings storage
    Settings {
        id: fallbackSettings
        property var savedNotes: []
    }

    // === DATABASE FUNCTIONS ===

    // Insert a new note to database
    function insertNoteToDatabase(title, content, isRichText) {
        if (!database) return -1;
        
        var noteId = -1;
        var currentDateTime = new Date().toISOString();

        database.transaction(function(tx) {
            var result = tx.executeSql(
                'INSERT INTO notes (title, content, isRichText, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?)',
                [title, content, isRichText || false, currentDateTime, currentDateTime]
            );
            noteId = result.insertId;
        });

        console.log("Note inserted with ID:", noteId);
        return noteId;
    }

    // Get all notes from database
    function getAllNotesFromDatabase() {
        if (!database) return [];
        
        var notes = [];

        database.readTransaction(function(tx) {
            var result = tx.executeSql('SELECT * FROM notes ORDER BY updatedAt DESC');
            
            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i);
                notes.push({
                    id: row.id,
                    title: row.title,
                    content: row.content,
                    isRichText: row.isRichText === 1,
                    createdAt: row.createdAt,
                    updatedAt: row.updatedAt
                });
            }
        });

        return notes;
    }

    // Update note in database
    function updateNoteInDatabase(noteId, title, content, isRichText) {
        if (!database) return false;
        
        var success = false;
        var currentDateTime = new Date().toISOString();

        database.transaction(function(tx) {
            var result = tx.executeSql(
                'UPDATE notes SET title = ?, content = ?, isRichText = ?, updatedAt = ? WHERE id = ?',
                [title, content, isRichText || false, currentDateTime, noteId]
            );
            success = result.rowsAffected > 0;
        });

        console.log("Note updated:", success);
        return success;
    }

    // Delete note from database
    function deleteNoteFromDatabase(noteId) {
        if (!database) return false;
        
        var success = false;

        database.transaction(function(tx) {
            var result = tx.executeSql('DELETE FROM notes WHERE id = ?', [noteId]);
            success = result.rowsAffected > 0;
        });

        console.log("Note deleted:", success);
        return success;
    }

    // === CONTROLLER FUNCTIONS (previously in NotesController) ===
    
    // Create a new note
    function createNote(title, content, isRichText = false) {
        if (title.trim() === "") return false;
        
        if (useDatabase) {
            var noteId = insertNoteToDatabase(title.trim(), content, isRichText);
            if (noteId > 0) {
                loadNotesFromStorage(); // Refresh the list
                return noteId;
            }
        } else {
            // Fallback to adding to ListModel and Settings
            var index = addNoteToSettings(title.trim(), content, isRichText);
            return index >= 0 ? index : false;
        }
        return false;
    }

    // Update the current note
    function updateCurrentNote(title, content, isRichText = null) {
        if (currentNote.id > 0 && title.trim() !== "") {
            var richText = isRichText !== null ? isRichText : currentNote.isRichText;
            var success = false;
            
            if (useDatabase) {
                success = updateNoteInDatabase(currentNote.id, title.trim(), content, richText);
            } else if (currentNote.index >= 0) {
                success = updateNoteInSettings(currentNote.index, title.trim(), content, richText);
            }
            
            if (success) {
                loadNotesFromStorage(); // Refresh the list
                return true;
            }
        }
        return false;
    }

    // Delete the current note
    function deleteCurrentNote() {
        var success = false;
        
        if (useDatabase && currentNote.id > 0) {
            success = deleteNoteFromDatabase(currentNote.id);
        } else if (!useDatabase && currentNote.index >= 0) {
            success = deleteNoteFromSettings(currentNote.index);
        }
        
        if (success) {
            resetCurrentNote();
            loadNotesFromStorage(); // Refresh the list
            return true;
        }
        return false;
    }

    // === DATA MANAGEMENT FUNCTIONS ===

    // Load notes from the appropriate storage
    function loadNotesFromStorage() {
        if (useDatabase) {
            loadNotesFromDatabase();
        } else {
            loadNotesFromSettings();
        }
    }

    // Load notes from database into the ListModel
    function loadNotesFromDatabase() {
        var dbNotes = getAllNotesFromDatabase();
        
        // Clear existing notes
        notesListModel.clear();
        
        // Add notes from database
        for (var i = 0; i < dbNotes.length; i++) {
            var dbNote = dbNotes[i];
            notesListModel.append({
                id: dbNote.id,
                title: dbNote.title,
                content: dbNote.content,
                createdAt: formatDate(dbNote.createdAt),
                updatedAt: formatDate(dbNote.updatedAt),
                isRichText: dbNote.isRichText
            });
        }
        
        // If no notes exist, add some sample data
        if (notesListModel.count === 0) {
            createSampleNotes();
        }
        
        dataChanged();
    }

    // Load notes from Settings (fallback)
    function loadNotesFromSettings() {
        var savedNotesArray = fallbackSettings.savedNotes;
        notesListModel.clear();
        
        if (savedNotesArray && savedNotesArray.length > 0) {
            for (var i = 0; i < savedNotesArray.length; i++) {
                var note = savedNotesArray[i];
                
                if (typeof note.isRichText === 'undefined') {
                    note.isRichText = false;
                }
                // Add fake ID for settings-based notes
                note.id = i + 1;
                notesListModel.append(note);
            }
        } else {
            createSampleNotes();
        }
        
        dataChanged();
    }

    // Create sample notes
    function createSampleNotes() {
        if (useDatabase) {
            insertNoteToDatabase("First Note", "This is my first note content.", false);
            insertNoteToDatabase("Second Note", "Some content for the second note.", false);
            insertNoteToDatabase("Meeting Notes", "Discuss project timeline\\n- Feature prioritization\\n- Budget allocation", false);
            loadNotesFromDatabase();
        } else {
            addNoteToSettings("First Note", "This is my first note content.", false);
            addNoteToSettings("Second Note", "Some content for the second note.", false);
            addNoteToSettings("Meeting Notes", "Discuss project timeline\\n- Feature prioritization\\n- Budget allocation", false);
        }
    }

    // === SETTINGS FALLBACK FUNCTIONS ===

    function addNoteToSettings(title, content, isRichText) {
        notes.append({
            id: notes.count + 1,
            title: title,
            content: content,
            createdAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd"),
            updatedAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd"),
            isRichText: isRichText
        });
        saveNotesToSettings();
        return notes.count - 1;
    }

    function updateNoteInSettings(index, title, content, isRichText) {
        var note = notes.get(index);
        var updatedIsRichText = isRichText === null ? note.isRichText : isRichText;

        notes.set(index, {
            id: note.id,
            title: title,
            content: content,
            createdAt: note.createdAt,
            updatedAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd"),
            isRichText: updatedIsRichText
        });
        saveNotesToSettings();
        return true;
    }

    function deleteNoteFromSettings(index) {
        notes.remove(index);
        saveNotesToSettings();
        return true;
    }

    function saveNotesToSettings() {
        var notesArray = [];
        for (var i = 0; i < notes.count; i++) {
            var note = notes.get(i);
            notesArray.push({
                id: note.id,
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                isRichText: note.isRichText || false
            });
        }
        fallbackSettings.savedNotes = notesArray;
    }

    // === UTILITY AND LEGACY FUNCTIONS ===

    // Set the current note being edited by index in the list model
    function setCurrentNote(index) {
        if (index >= 0 && index < notesListModel.count) {
            var note = notesListModel.get(index);
            currentNote = {
                id: note.id || -1,
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt || note.createdAt,
                isRichText: note.isRichText,
                index: index
            };
            noteSelectionChanged();
            return true;
        }
        return false;
    }

    // Reset the current note
    function resetCurrentNote() {
        currentNote = { id: -1, title: "", content: "", createdAt: "", updatedAt: "", index: -1 };
        noteSelectionChanged();
    }

    // Format date for display
    function formatDate(dateString) {
        if (!dateString) return "";
        
        try {
            var date = new Date(dateString);
            return Qt.formatDateTime(date, "yyyy-MM-dd");
        } catch (e) {
            return dateString; // Return original if parsing fails
        }
    }

    // Legacy compatibility functions
    function addNote(title, content, isRichText = false) {
        return createNote(title, content, isRichText);
    }

    function updateNote(index, title, content, isRichText = null) {
        return updateCurrentNote(title, content, isRichText);
    }

    function deleteNote(index) {
        if (setCurrentNote(index)) {
            return deleteCurrentNote();
        }
        return false;
    }

    function getNote(index) {
        if (index >= 0 && index < notesListModel.count) {
            var note = notesListModel.get(index);
            return {
                id: note.id || -1,
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt || note.createdAt,
                isRichText: note.isRichText || false,
                index: index
            };
        }
        return null;
    }

    function saveNote(noteId, content) {
        if (currentNote.index >= 0) {
            updateCurrentNote(currentNote.title, content);
        }
    }

    function saveNotes() {
        console.log("saveNotes() called - data is automatically saved");
    }

    function loadNotes() {
        loadNotesFromStorage();
    }
}
