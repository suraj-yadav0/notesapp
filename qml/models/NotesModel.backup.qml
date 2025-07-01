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

// Enhanced NotesModel with SQLite database integration
Item {
    id: notesModel

    // Database manager instance
    property DatabaseManager dbManager: DatabaseManager {
        id: dbManagerInstance
    }

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
            loadNotesFromDatabase();
        }
    }

    // === CONTROLLER FUNCTIONS (previously in NotesController) ===
    
    // Create a new note
    function createNote(title, content, isRichText = false) {
        if (title.trim() === "") return false;
        
        var noteId = dbManager.insertNote(title.trim(), content, isRichText);
        if (noteId > 0) {
            loadNotesFromDatabase(); // Refresh the list
            return noteId;
        }
        return false;
    }

    // Update the current note
    function updateCurrentNote(title, content, isRichText = null) {
        if (currentNote.id > 0 && title.trim() !== "") {
            var richText = isRichText !== null ? isRichText : currentNote.isRichText;
            var success = dbManager.updateNote(currentNote.id, title.trim(), content, richText);
            if (success) {
                loadNotesFromDatabase(); // Refresh the list
                // Update current note data
                var updatedNote = dbManager.getNoteById(currentNote.id);
                if (updatedNote) {
                    setCurrentNoteFromDbNote(updatedNote);
                }
                return true;
            }
        }
        return false;
    }

    // Delete the current note
    function deleteCurrentNote() {
        if (currentNote.id > 0) {
            var success = dbManager.deleteNote(currentNote.id);
            if (success) {
                resetCurrentNote();
                loadNotesFromDatabase(); // Refresh the list
                return true;
            }
        }
        return false;
    }

    // Set the current note being edited by index in the list model
    function setCurrentNote(index) {
        if (index >= 0 && index < notesListModel.count) {
            var note = notesListModel.get(index);
            currentNote = {
                id: note.id,
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                isRichText: note.isRichText,
                index: index
            };
            noteSelectionChanged();
            return true;
        }
        return false;
    }

    // Set current note from database note object
    function setCurrentNoteFromDbNote(dbNote) {
        if (dbNote) {
            // Find the index in the list model
            var index = findNoteIndexById(dbNote.id);
            currentNote = {
                id: dbNote.id,
                title: dbNote.title,
                content: dbNote.content,
                createdAt: dbNote.createdAt,
                updatedAt: dbNote.updatedAt,
                isRichText: dbNote.isRichText,
                index: index
            };
            noteSelectionChanged();
        }
    }

    // Reset the current note
    function resetCurrentNote() {
        currentNote = { id: -1, title: "", content: "", createdAt: "", updatedAt: "", index: -1 };
        noteSelectionChanged();
    }

    // Save note (for backward compatibility)
    function saveNote(noteId, content) {
        if (currentNote.id > 0) {
            updateCurrentNote(currentNote.title, content);
        }
    }

    // === DATA MANAGEMENT FUNCTIONS ===

    // Load notes from database into the ListModel
    function loadNotesFromDatabase() {
        var dbNotes = dbManager.getAllNotes();
        
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

    // Find note index by ID
    function findNoteIndexById(noteId) {
        for (var i = 0; i < notesListModel.count; i++) {
            if (notesListModel.get(i).id === noteId) {
                return i;
            }
        }
        return -1;
    }

    // Create sample notes if database is empty
    function createSampleNotes() {
        dbManager.insertNote("First Note", "This is my first note content.", false);
        dbManager.insertNote("Second Note", "Some content for the second note.", false);
        dbManager.insertNote("Meeting Notes", "Discuss project timeline\n- Feature prioritization\n- Budget allocation", false);
        
        // Reload after creating sample notes
        loadNotesFromDatabase();
    }

    // Function to add a new note (legacy compatibility)
    function addNote(title, content, isRichText = false) {
        return createNote(title, content, isRichText);
    }

    // Function to update an existing note by index (legacy compatibility)
    function updateNote(index, title, content, isRichText = null) {
        if (index >= 0 && index < notesListModel.count) {
            var noteId = notesListModel.get(index).id;
            var note = dbManager.getNoteById(noteId);
            if (note) {
                var richText = isRichText !== null ? isRichText : note.isRichText;
                var success = dbManager.updateNote(noteId, title, content, richText);
                if (success) {
                    loadNotesFromDatabase();
                    return true;
                }
            }
        }
        return false;
    }

    // Function to delete a note by index (legacy compatibility)
    function deleteNote(index) {
        if (index >= 0 && index < notesListModel.count) {
            var noteId = notesListModel.get(index).id;
            var success = dbManager.deleteNote(noteId);
            if (success) {
                loadNotesFromDatabase();
                // Update current note if it was the deleted one
                if (currentNote.index === index) {
                    resetCurrentNote();
                } else if (currentNote.index > index) {
                    currentNote.index -= 1;
                }
                return true;
            }
        }
        return false;
    }

    // Function to get a note by index (legacy compatibility)
    function getNote(index) {
        if (index >= 0 && index < notesListModel.count) {
            var note = notesListModel.get(index);
            return {
                id: note.id,
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                isRichText: note.isRichText || false,
                index: index
            };
        }
        return null;
    }

    // Search notes function
    function searchNotes(searchTerm) {
        if (searchTerm.trim() === "") {
            loadNotesFromDatabase();
            return;
        }
        
        var searchResults = dbManager.searchNotes(searchTerm);
        
        // Update list model with search results
        notesListModel.clear();
        for (var i = 0; i < searchResults.length; i++) {
            var note = searchResults[i];
            notesListModel.append({
                id: note.id,
                title: note.title,
                content: note.content,
                createdAt: formatDate(note.createdAt),
                updatedAt: formatDate(note.updatedAt),
                isRichText: note.isRichText
            });
        }
        
        dataChanged();
    }

    // === UTILITY FUNCTIONS ===

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

    // Get database statistics
    function getDatabaseStats() {
        return dbManager.getDatabaseStats();
    }

    // Export notes
    function exportNotes() {
        return dbManager.exportNotes();
    }

    // Clear all notes (use with caution)
    function clearAllNotes() {
        var success = dbManager.clearAllNotes();
        if (success) {
            loadNotesFromDatabase();
            resetCurrentNote();
        }
        return success;
    }

    // Legacy functions for backward compatibility (remove Settings usage)
    function saveNotes() {
        // No longer needed as database auto-saves
        console.log("saveNotes() called - data is automatically saved to database");
    }

    function loadNotes() {
        // Redirect to database loading
        loadNotesFromDatabase();
    }
}
