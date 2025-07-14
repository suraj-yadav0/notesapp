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

// Clean NotesModel using DatabaseManager for data operations
QtObject {
    id: notesModel

    // Database manager instance
    property DatabaseManager databaseManager: DatabaseManager {
        id: dbManager
    }

    // Fallback settings storage when database is not available
    property Settings fallbackSettings: Settings {
        id: settingsStorage
        property var savedNotes: []
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

    // Database availability flag
    property bool useDatabase: databaseManager.database !== null

    // Signals
    signal noteSelectionChanged
    signal dataChanged

    // Initialize the model
    Component.onCompleted: {
        loadNotesFromStorage();
    }

    // === MAIN CRUD OPERATIONS ===

    // Create a new note
    function createNote(title, content, isRichText) {
        if (title.trim() === "")
            return false;

        if (useDatabase) {
            var noteId = databaseManager.insertNote(title.trim(), content, isRichText || false);
            if (noteId > 0) {
                loadNotesFromStorage(); // Refresh the list
                return noteId;
            }
        } else {
            // Fallback to Settings storage
            var index = addNoteToSettings(title.trim(), content, isRichText || false);
            return index >= 0 ? index : false;
        }
        return false;
    }

    // Update the current note with proper isolation
    function updateCurrentNote(title, content, isRichText) {
        console.log("updateCurrentNote called with:", title, "content length:", content ? content.length : 0, "richText:", isRichText);
        console.log("currentNote:", JSON.stringify(currentNote));

        if (currentNote.id > 0 && title.trim() !== "") {
            var richText = isRichText !== null ? isRichText : currentNote.isRichText;
            var success = false;

            if (useDatabase) {
                console.log("Updating in database, noteId:", currentNote.id);
                success = databaseManager.updateNote(currentNote.id, title.trim(), content, richText);
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

                    // Update current note reference - create a new object
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
                }
            } else if (currentNote.index >= 0) {
                success = updateNoteInSettings(currentNote.index, title.trim(), content, richText);
            }

            if (success) {
                dataChanged();
                noteSelectionChanged(); // Notify that current note changed
                return true;
            }
        }
        console.log("updateCurrentNote failed - returning false");
        return false;
    }

    // Delete the current note
    function deleteCurrentNote() {
        var success = false;

        if (useDatabase && currentNote.id > 0) {
            success = databaseManager.deleteNote(currentNote.id);
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

    // Search notes
    function searchNotes(searchTerm) {
        if (useDatabase) {
            return databaseManager.searchNotes(searchTerm);
        } else {
            // Fallback search in settings
            var results = [];
            var savedNotesArray = fallbackSettings.savedNotes;
            if (savedNotesArray && savedNotesArray.length > 0) {
                for (var i = 0; i < savedNotesArray.length; i++) {
                    var note = savedNotesArray[i];
                    if (note.title.toLowerCase().includes(searchTerm.toLowerCase()) || note.content.toLowerCase().includes(searchTerm.toLowerCase())) {
                        results.push(note);
                    }
                }
            }
            return results;
        }
    }

    // === DATA LOADING FUNCTIONS ===

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
    }

    // Load notes from Settings (fallback)
    function loadNotesFromSettings() {
        var savedNotesArray = fallbackSettings.savedNotes;
        notes.clear();

        if (savedNotesArray && savedNotesArray.length > 0) {
            for (var i = 0; i < savedNotesArray.length; i++) {
                var note = savedNotesArray[i];

                if (typeof note.isRichText === 'undefined') {
                    note.isRichText = false;
                }
                // Add fake ID for settings-based notes
                note.id = i + 1;
                notes.append(note);
            }
        } else {
            createSampleNotes();
        }

        dataChanged();
    }

    // Create sample notes
    function createSampleNotes() {
        if (useDatabase) {
            databaseManager.insertNote("Welcome to Notes App", "This is your first note! You can create, edit, and delete notes using this application.", false);
            databaseManager.insertNote("Getting Started", "Here are some tips:\\n- Tap the + button to create a new note\\n- Tap on any note to edit it\\n- Swipe to delete notes\\n- All your notes are saved automatically", false);
            databaseManager.insertNote("Rich Text Support", "This app supports rich text formatting including:\\n- **Bold text**\\n- *Italic text*\\n- Lists and more!", false);
            loadNotesFromDatabase();
        } else {
            addNoteToSettings("Welcome to Notes App", "This is your first note! You can create, edit, and delete notes using this application.", false);
            addNoteToSettings("Getting Started", "Here are some tips:\\n- Tap the + button to create a new note\\n- Tap on any note to edit it\\n- Swipe to delete notes\\n- All your notes are saved automatically", false);
            addNoteToSettings("Rich Text Support", "This app supports rich text formatting including:\\n- **Bold text**\\n- *Italic text*\\n- Lists and more!", false);
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

    // === UTILITY FUNCTIONS ===

    // Set the current note being edited by index in the list model
    function setCurrentNote(index) {
        if (index >= 0 && index < notes.count) {
            var note = notes.get(index);
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

    // Get database statistics
    function getDatabaseStats() {
        if (useDatabase) {
            return databaseManager.getDatabaseStats();
        } else {
            return {
                notesCount: notes.count
            };
        }
    }

    // Export notes data
    function exportNotes() {
        if (useDatabase) {
            return databaseManager.exportNotes();
        } else {
            var notesArray = [];
            for (var i = 0; i < notes.count; i++) {
                notesArray.push(notes.get(i));
            }
            return JSON.stringify(notesArray, null, 2);
        }
    }

    // Clear all notes
    function clearAllNotes() {
        if (useDatabase) {
            return databaseManager.clearAllNotes();
        } else {
            notes.clear();
            fallbackSettings.savedNotes = [];
            return true;
        }
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

    function saveNote(noteId, content) {
        console.log("saveNote called with noteId:", noteId, "content length:", content ? content.length : 0);
        if (currentNote.index >= 0 && currentNote.id > 0) {
            // Use the current note's title and update with new content
            var result = updateCurrentNote(currentNote.title, content, currentNote.isRichText);
            console.log("saveNote result:", result);
            return result;
        }
        console.log("saveNote failed - no current note selected");
        return false;
    }

    function saveNotes() {
        console.log("saveNotes() called - data is automatically saved");
    }

    function loadNotes() {
        loadNotesFromStorage();
    }

    // Helper function to update a specific note in the model
    function updateNoteInModel(index, noteData) {
        if (index >= 0 && index < notes.count) {
            // Create a completely new object to avoid reference sharing
            var updatedNote = {
                id: noteData.id,
                title: noteData.title,
                content: noteData.content,
                isRichText: noteData.isRichText,
                createdAt: noteData.createdAt,
                updatedAt: noteData.updatedAt
            };

            // Replace the entire item to ensure proper isolation
            notes.set(index, updatedNote);
            console.log("Updated note at index", index, "with title:", updatedNote.title);
        }
    }

    // === DATA LOADING FUNCTIONS ===
}
