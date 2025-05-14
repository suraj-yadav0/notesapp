import QtQuick 2.7
import Qt.labs.settings 1.0

// Store notes data and handle persistence
Item {
    id: notesModel

   
    property ListModel notes: ListModel {
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

    // Function to add 
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

    // Function to update 
    function updateNote(index, title, content,isRichText = null) {
        var note = notes.get(index);
        //if richtext is not null, Kepp the Value
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