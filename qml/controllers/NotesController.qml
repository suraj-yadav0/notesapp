import QtQuick 2.7


Item {
    id: notesController
    
    // Reference to the model (will be set externally)
    property var model
    
   
    property var currentNote: ({ title: "", content: "",createdAt: "", index: -1 ,isRichText: false })
    
    // Signal when the current note changes, it causes error , will fix later
    //signal currentNoteChanged()
    
    // Create a new note
    function createNote(title, content, isRichText ) {
        if (title.trim() === "") return false;
        
        var index = model.addNote(title.trim(), content, isRichText);
        return index;
    }
    
    // Update an existing note
    function updateCurrentNote(title, content, isRichText = null) {
        if (currentNote.index >= 0 && title.trim() !== "") {
            model.updateNote(currentNote.index, title.trim(), content, isRichText);
            return true;
        }
        return false;
    }
    
    // Delete the current note
    function deleteCurrentNote() {
        if (currentNote.index >= 0) {
            model.deleteNote(currentNote.index);
            resetCurrentNote();
            return true;
        }
        return false;
    }
    
    // Delete a note by index
    function deleteNote(index) {
        if (index >= 0) {
            model.deleteNote(index);
            // If we're deleting the current note, reset it
            if (currentNote.index === index) {
                resetCurrentNote();
            }
            return true;
        }
        return false;
    }
    
    // Set the current note being edited
    function setCurrentNote(index) {
        var note = model.getNote(index);
        if (note) {
            currentNote = note;
            currentNoteChanged();
            return true;
        }
        return false;
    }
    
    // Reset the current note
    function resetCurrentNote() {
        currentNote = { title: "", content: "", createdAt: "", index: -1 };
        currentNoteChanged();
    }
}