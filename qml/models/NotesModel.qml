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

// SQLite-only NotesModel using DatabaseManager for all data operations
QtObject {
    id: notesModel

    // Database manager instance
    property DatabaseManager databaseManager: DatabaseManager {
        id: dbManager

        Component.onCompleted: {
            console.log("DatabaseManager component completed");
            var initialized = initializeDatabase();
            if (initialized) {
                console.log("Database initialized successfully in NotesModel");
                notesModel.loadNotesFromDatabase();
                notesModel.isInitialized = true;
            } else {
                console.error("Failed to initialize database in NotesModel");
            }
        }
    }

    // Main notes list model
    property ListModel notes: ListModel {
        id: notesListModel
    }

    // Current note being edited
    property var currentNote: ({
            id: -1,
            title: "",
            content: "",
            createdAt: "",
            updatedAt: "",
            index: -1
        })

    // Database is always available - no fallback
    property bool useDatabase: true
    property bool isInitialized: false

    // Signals
    signal noteSelectionChanged
    signal dataChanged

    // Initialize the model
    Component.onCompleted: {
        console.log("NotesModel Component.onCompleted");
        // Database initialization is handled in DatabaseManager
        // We'll load notes when needed
    }

    // === MAIN CRUD OPERATIONS ===

    // Create a new note (SQLite only)
    function createNote(title, content, isRichText) {
        if (title.trim() === "")
            return false;

        console.log("Creating note in SQLite database");
        var noteId = databaseManager.insertNote(title.trim(), content, isRichText || false);
        if (noteId > 0) {
            loadNotesFromDatabase(); // Refresh the list
            return noteId;
        }
        console.log("Failed to create note in database");
        return false;
    }

    // Update the current note (SQLite only)
    function updateCurrentNote(title, content, isRichText) {
        console.log("updateCurrentNote called with:", title, "content length:", content ? content.length : 0, "richText:", isRichText);
        console.log("currentNote:", JSON.stringify(currentNote));

        if (currentNote.id > 0 && title.trim() !== "") {
            var richText = isRichText !== null ? isRichText : currentNote.isRichText;

            console.log("Updating note in SQLite database, noteId:", currentNote.id);
            var success = databaseManager.updateNote(currentNote.id, title.trim(), content, richText);
            console.log("Database update result:", success);

            if (success) {
                // Update the specific item in the model instead of reloading everything
                var updatedData = {
                    id: currentNote.id,
                    title: title.trim(),
                    content: content,
                    isRichText: richText,
                    createdAt: currentNote.createdAt,
                    updatedAt: formatDate(new Date().toISOString())
                };

                updateNoteInModel(currentNote.index, updatedData);

                // Update current note reference - create a completely new object to avoid reference issues
                currentNote = {
                    id: currentNote.id,
                    title: title.trim(),
                    content: content,
                    isRichText: richText,
                    createdAt: currentNote.createdAt,
                    updatedAt: formatDate(new Date().toISOString()),
                    index: currentNote.index
                };

                console.log("Updated currentNote:", JSON.stringify(currentNote));
                dataChanged();
                noteSelectionChanged(); // Notify that current note changed
                return true;
            }
        }
        console.log("updateCurrentNote failed - returning false");
        return false;
    }

    // Delete the current note (SQLite only)
    function deleteCurrentNote() {
        if (currentNote.id > 0) {
            console.log("Deleting note from SQLite database, noteId:", currentNote.id);
            var success = databaseManager.deleteNote(currentNote.id);

            if (success) {
                resetCurrentNote();
                loadNotesFromDatabase(); // Refresh the list
                return true;
            }
        }
        return false;
    }

    // Search notes (SQLite only)
    function searchNotes(searchTerm) {
        console.log("Searching notes in SQLite database for:", searchTerm);
        return databaseManager.searchNotes(searchTerm);
    }

    // === DATA LOADING FUNCTIONS ===

    // Load notes from SQLite database only
    function loadNotesFromStorage() {
        loadNotesFromDatabase();
    }

    // Load notes from database into the ListModel
    function loadNotesFromDatabase() {
        console.log("Loading notes from SQLite database");
        var dbNotes = databaseManager.getAllNotes();

        // Clear existing notes
        notes.clear();

        // Add notes from database
        for (var i = 0; i < dbNotes.length; i++) {
            var dbNote = dbNotes[i];
            notes.append({
                id: dbNote.id,
                title: dbNote.title,
                content: dbNote.content,
                createdAt: formatDate(dbNote.createdAt),
                updatedAt: formatDate(dbNote.updatedAt),
                isRichText: dbNote.isRichText
            });
        }

        // If no notes exist, add some sample data
        if (notes.count === 0) {
            createSampleNotes();
        }

        dataChanged();
        console.log("Loaded", notes.count, "notes from database");
    }

    // Create sample notes in SQLite database only
    function createSampleNotes() {
        console.log("Creating sample notes in SQLite database");
        databaseManager.insertNote("Welcome to Notes App", "This is your first note! You can create, edit, and delete notes using this application.", false);
        databaseManager.insertNote("Getting Started", "Here are some tips:\\n- Tap the + button to create a new note\\n- Tap on any note to edit it\\n- Swipe to delete notes\\n- All your notes are saved automatically", false);
        databaseManager.insertNote("Rich Text Support", "This app supports rich text formatting including:\\n- **Bold text**\\n- *Italic text*\\n- Lists and more!", false);
        loadNotesFromDatabase();
    }

    // === UTILITY FUNCTIONS ===

    // Update a specific note in the model (helper function)
    function updateNoteInModel(index, updatedData) {
        if (index >= 0 && index < notes.count) {
            console.log("Updating note in model at index:", index);
            notes.set(index, updatedData);
            console.log("Note updated in model successfully");
        }
    }

    // Set the current note being edited by index in the list model
    function setCurrentNote(index) {
        console.log("setCurrentNote called with index:", index, "notes.count:", notes.count);
        if (index >= 0 && index < notes.count) {
            var note = notes.get(index);
            console.log("Retrieved note from model:", JSON.stringify(note));

            // Create a completely new object to avoid reference issues
            currentNote = {
                id: note.id || -1,
                title: note.title || "",
                content: note.content || "",
                createdAt: note.createdAt || "",
                updatedAt: note.updatedAt || note.createdAt || "",
                isRichText: note.isRichText || false,
                index: index
            };

            console.log("Set currentNote:", JSON.stringify(currentNote));
            console.log("Emitting noteSelectionChanged signal");
            noteSelectionChanged();
            console.log("noteSelectionChanged signal emitted");
            return true;
        }
        console.log("setCurrentNote failed - index out of bounds");
        return false;
    }

    // Reset the current note
    function resetCurrentNote() {
        currentNote = {
            id: -1,
            title: "",
            content: "",
            createdAt: "",
            updatedAt: "",
            index: -1
        };
        noteSelectionChanged();
    }

    // Format date for display
    function formatDate(dateString) {
        if (!dateString)
            return "";

        try {
            var date = new Date(dateString);
            return Qt.formatDateTime(date, "yyyy-MM-dd");
        } catch (e) {
            return dateString; // Return original if parsing fails
        }
    }

    // Get database statistics (SQLite only)
    function getDatabaseStats() {
        return databaseManager.getDatabaseStats();
    }

    // Export notes data (SQLite only)
    function exportNotes() {
        return databaseManager.exportNotes();
    }

    // Clear all notes (SQLite only)
    function clearAllNotes() {
        var success = databaseManager.clearAllNotes();
        if (success) {
            loadNotesFromDatabase();
        }
        return success;
    }

    // === LEGACY COMPATIBILITY FUNCTIONS ===

    function addNote(title, content, isRichText) {
        return createNote(title, content, isRichText);
    }

    function updateNote(index, title, content, isRichText) {
        if (setCurrentNote(index)) {
            return updateCurrentNote(title, content, isRichText);
        }
        return false;
    }

    function deleteNote(index) {
        if (setCurrentNote(index)) {
            return deleteCurrentNote();
        }
        return false;
    }

    function getNote(index) {
        if (index >= 0 && index < notes.count) {
            var note = notes.get(index);
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
}
