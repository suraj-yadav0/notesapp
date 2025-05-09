# Day 5

We will be continuing with the refactoring of our code. In the Last Chapter we were done with the Views section , Today we will try to implement the Persistent storage too with the help of settings element of qt , which helps in storing data persistently in devices , so that we will not lose our data even after closing the device. 

> Task 1
> 

Let us create the model for our app. Create a Folder called models in `qml` directory. In this models folder , create a file called `NotesModel.qml` . And Paste the given below code into this file :

```jsx
import QtQuick 2.7
import Qt.labs.settings 1.0

// Store notes data and handle persistence
Item {
    id: notesModel

    // Property to store notes as a ListModel
    property ListModel notes: ListModel {
        id: notesListModel

        // Initial sample data
        Component.onCompleted: {
            if (notesListModel.count === 0) {
                append({
                    title: "First Note",
                    content: "This is my first note content.",
                    createdAt: "2025-04-28"
                });
                append({
                    title: "Second Note",
                    content: "Some content for the second note.",
                    createdAt: "2025-04-27"
                });
                append({
                    title: "Meeting Notes",
                    content: "Discuss project timeline\n- Feature prioritization\n- Budget allocation",
                    createdAt: "2025-04-26"
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

    // Function to add a new note
    function addNote(title, content) {
        notes.append({
            title: title,
            content: content,
            createdAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd")
        });
        saveNotes();
        return notes.count - 1;
    }

    // Function to update an existing note
    function updateNote(index, title, content) {
        notes.set(index, {
            title: title,
            content: content,
            createdAt: notes.get(index).createdAt
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
                createdAt: note.createdAt
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
                notes.append(note);
            }
        }
    }
}
```

This model is wrapped inside a Item element with a id `notesModel` , which we were referencing in the previous chapter. It has the previous old sample data , so if no data is there , this sample data will be displayed. You can remove this too, if u want.

<aside>
💡

Important

</aside>

Then we have the settings element , which is storing our notes in the form of a array.

```jsx
 Settings {
        id: notesSettings
        property var savedNotes: []

        Component.onCompleted: {
            loadNotes();
        }
    }
```

Then we have some functions for `adding` notes, `updating` notes, `deleting` notes, `getting` a note , `saving` notes, and also for `loading` notes.

> Task 2
> 

Now let us implement the controller of our app, which is where our business logic will be stored. Let us a create a new folder in the qml directory called controllers. In this directory create a new file called NotesController.qml and copy this code into this file : 

```jsx
import QtQuick 2.7

// Controller to handle business logic for notes operations
Item {
    id: notesController
    
    // Reference to the model (will be set externally)
    property var model
    
    // Property to keep track of the currently selected note
    property var currentNote: ({ title: "", content: "", createdAt: "", index: -1 })
    
    // Signal when the current note changes
    //signal currentNoteChanged()
    
    // Create a new note
    function createNote(title, content) {
        if (title.trim() === "") return false;
        
        var index = model.addNote(title.trim(), content.trim());
        return index;
    }
    
    // Update an existing note
    function updateCurrentNote(title, content) {
        if (currentNote.index >= 0 && title.trim() !== "") {
            model.updateNote(currentNote.index, title.trim(), content.trim());
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
```

This Controller is also wrapped in a Item and it has a id as `notesController`.

It also has the property variable model and currentNote

It has all these functions to `createNote`, `updateCurrentNote` , `deleteCurrentNote` , `setCurrentNote`, `resetCurrentnote`. Some of these functionalities we will be implementing later. 

Whenever these functions are invoked from the controllers , the methods from the models are called which we have defined in the models file.  

In the future I will be adding a pop-up so , whenever there is a crud operation performed our app displays a confirmation message in form of a pop-up.