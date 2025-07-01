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

// Enhanced NotesModel with integrated controller functionality
Item {
    id: notesModel

    // Expose the notes list model
    property alias notes: notesListModel
    
    // Current note being edited (moved from controller)
    property var currentNote: ({ title: "", content: "", createdAt: "", index: -1 })
    
    // Signals (renamed to avoid conflicts)
    signal noteSelectionChanged()

    // Main notes list model
    ListModel {
        id: notesListModel

        // Initial sample data
        Component.onCompleted: {
            if (notesListModel.count === 0) {
                append({
                    title: "First Note",
                    content: "This is my first note content.",
                    createdAt: "2025-04-28",
                    isRichText: false
                });
                append({
                    title: "Second Note",
                    content: "Some content for the second note.",
                    createdAt: "2025-04-27",
                    isRichText: false
                });
                append({
                    title: "Meeting Notes",
                    content: "Discuss project timeline\n- Feature prioritization\n- Budget allocation",
                    createdAt: "2025-04-26",
                    isRichText: false
                });
            }
        }
    }

    // Settings to persist notes data
    Settings {
        id: notesSettings
        property var savedNotes: []

        Component.onCompleted: {
            loadNotes();
        }
    }

    // === CONTROLLER FUNCTIONS (previously in NotesController) ===
    
    // Create a new note
    function createNote(title, content, isRichText = false) {
        if (title.trim() === "") return false;
        
        var index = addNote(title.trim(), content, isRichText);
        return index;
    }

    // Update the current note
    function updateCurrentNote(title, content, isRichText = null) {
        if (currentNote.index >= 0 && title.trim() !== "") {
            updateNote(currentNote.index, title.trim(), content, isRichText);
            return true;
        }
        return false;
    }

    // Delete the current note
    function deleteCurrentNote() {
        if (currentNote.index >= 0) {
            deleteNote(currentNote.index);
            resetCurrentNote();
            return true;
        }
        return false;
    }

    // Set the current note being edited
    function setCurrentNote(index) {
        var note = getNote(index);
        if (note) {
            currentNote = note;
            noteSelectionChanged();
            return true;
        }
        return false;
    }

    // Reset the current note
    function resetCurrentNote() {
        currentNote = { title: "", content: "", createdAt: "", index: -1 };
        noteSelectionChanged();
    }

    // Save note (for backward compatibility)
    function saveNote(noteId, content) {
        if (currentNote.index >= 0) {
            updateNote(currentNote.index, currentNote.title, content);
        }
    }

    // === DATA MANAGEMENT FUNCTIONS ===

    // Function to add a new note
    function addNote(title, content, isRichText = false) {
        notes.append({
            title: title,
            content: content,
            createdAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd"),
            isRichText: isRichText
        });
        saveNotes();
        return notes.count - 1;
    }

    // Function to update an existing note
    function updateNote(index, title, content, isRichText = null) {
        var note = notes.get(index);
        // If richtext is not null, keep the value
        var updatedIsRichText = isRichText === null ? note.isRichText : isRichText;

        notes.set(index, {
            title: title,
            content: content,
            createdAt: notes.get(index).createdAt,
            isRichText: updatedIsRichText
        });
        saveNotes();
    }

    // Function to delete a note
    function deleteNote(index) {
        notes.remove(index);
        saveNotes();
        // Update current note index if necessary
        if (currentNote.index === index) {
            resetCurrentNote();
        } else if (currentNote.index > index) {
            currentNote.index -= 1;
        }
    }

    // Function to get a note by index
    function getNote(index) {
        if (index >= 0 && index < notes.count) {
            var note = notes.get(index);
            return {
                title: note.title,
                content: note.content,
                createdAt: note.createdAt,
                isRichText: note.isRichText || false,
                index: index
            };
        }
        return null;
    }

    // Save notes to persistent storage
    function saveNotes() {
        var notesArray = [];
        for (var i = 0; i < notes.count; i++) {
            var note = notes.get(i);
            notesArray.push({
                title: note.title,
                content: note.content,
                createdAt: note.createdAt, 
                isRichText: note.isRichText || false
            });
        }
        notesSettings.savedNotes = notesArray;
    }

    // Load notes from persistent storage
    function loadNotes() {
        var savedNotesArray = notesSettings.savedNotes;
        if (savedNotesArray && savedNotesArray.length > 0) {
            notes.clear();
            for (var i = 0; i < savedNotesArray.length; i++) {
                var note = savedNotesArray[i];
                
                if (typeof note.isRichText === 'undefined') {
                    note.isRichText = false;
                }
                notes.append(note);
            }
        }
    }
}
