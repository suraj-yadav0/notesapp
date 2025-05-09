# Day 4

So today Our Main Focus will be to Refactor our entire code and make it follow `MVC` (Model - View - Control) pattern. This is very important for our app to be scalable. It is initial stage of our app, so it is good to know about refactoring.

Along with refactoring we will try to implement Persistent Storage so that our data will be stored even when we close our app.

With Today’s Goal in mind Let’s get started..!!

> Task 1
> 

First of all , start with the Views Folder. Here all the UI part of our application will be stored. To keep it more flexible and scalable we will having a different file for each screen and we also store our helping components in different files. This will make our code more scalable and modular.

In `qml` folder , create a new folder called `views` and in views create two files called `MainPage.qml` and `NoteEditPage.qml` . These Pages are for our two Screens , as the name suggest. 

Paste this Code in the `MainPage.qml` :

```jsx
import QtQuick 2.7
import Lomiri.Components 1.3
import Ubuntu.Components.Popups 1.3
import "components"

// Main page displaying the list of notes
Page {
    id: mainPage
    
    // Properties to be set from outside
    property var controller
    property var notesModel
    
    // Signal when note editing is requested
    signal editNoteRequested(int index)
    
    anchors.fill: parent
    
    header: PageHeader {
        id: header
        title: i18n.tr('Notes')
        subtitle: i18n.tr('Keep Your Ideas in One Place.')
        
        ActionBar {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            
            numberOfSlots: 2
            actions: [
                Action {
                    iconName: "add"
                    text: i18n.tr("Add Note")
                    onTriggered: {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("components/AddNoteDialog.qml"));
                        dialog.saveRequested.connect(function(title, content) {
                            controller.createNote(title, content);
                        });
                    }
                }
            ]
        }
    }
    
    ListView {
        id: notesListView
        
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: units.gu(2)
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }
        
        model: notesModel.notes
        
        delegate: NoteItem {
            width: parent.width
            title: model.title
            content: model.content || ""
            createdAt: model.createdAt
            noteIndex: index
            
            onNoteSelected: {
                controller.setCurrentNote(index);
                editNoteRequested(index);
            }
            
            onNoteEditRequested: {
                controller.setCurrentNote(index);
                editNoteRequested(index);
            }
            
            onNoteDeleteRequested: {
                controller.deleteNote(index);
            }
        }
    }
}
```

  

- In this code first defined the `Page` and given it a `id : mainPage`  . Then we have defined two property variables `controller` and `notesModel`. Controller will be used to implement the `Buisness Logic` and `notesModel` is the model for our views. Then we have initiated a `signal` to track whenever Note-Editing is requested.
- For the positioning we have defined `anchors.fill : parent` , so whatever the parent has.
- Then there is the `PageHeader` with title, subtitle and some actions. Currently we will be having only the `add` button , later we can have `search` icon there too.
- When the add button is triggered , it uses a `dialog` to open a new screen that is our `AddNotePage` . After the dialog is opened , the connects to the `saveRequested`  signal.
- This `saveRequested` signal includes a inline callback function . This function takes two parameters , which are passed. This function calls the `controller.createNote()` method while passing `title` and `content` as arguments.
- Then we have our `ListView` to display our Notes. We have given it a id and anchored it according to the `Pageheader`. We have given its model as `notesModel.notes` .
- In delegate , we have our `NoteItem` with some properties like `width` , `title` , `content` , `createdAt`, and `noteIndex` .
- `NoteItem` also define three Signal handlers `onNoteSelected` , `onNoteEditRequested` and `onNoteDeleteRequested`. These handlers respond to user interactions with the note.

> Now create a Components folder inside views folder and add a file named `AddNoteDialog.qml` and paste this code :
> 

```jsx
import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Popups 1.3

// Dialog for adding or editing notes
Dialog {
    id: noteDialog
    
    // Signals
    signal saveRequested(string title, string content)
    signal cancelRequested()
    
    title: i18n.tr("Add New Note")
    modal: true
    
    ColumnLayout {
        width: parent.width
        spacing: units.gu(1)
        
        TextArea {
            id: noteTitleArea
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(5)
            placeholderText: i18n.tr("Title of your Note...")
            autoSize: false
            text: ""
        }
        
        TextArea {
            id: noteTextArea
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(15)
            placeholderText: i18n.tr("Type your note here...")
            text: ""
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: units.gu(1)
            spacing: units.gu(1)
            
            Button {
                Layout.fillWidth: true
                text: i18n.tr("Cancel")
                onClicked: {
                    cancelRequested();
                    PopupUtils.close(noteDialog);
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: i18n.tr("Save")
                color: theme.palette.normal.positive
                onClicked: {
                    if (noteTitleArea.text.trim() !== "") {
                        saveRequested(noteTitleArea.text, noteTextArea.text);
                        PopupUtils.close(noteDialog);
                    }
                }
            }
        }
    }
}
```

This is the dialog for adding or editing Notes. and this Dialog opens when you click on the Add or Edit Button. Here we have boolean property to keep track if we are editing the file or we are adding a new note. Then we have two signals to keep track `saveRequested()` with title and content as arguments or `cancelRequested()` .

> Now Lets add the Component to display the Single Item in the `ListView` on the Main page.
> 

> create a new file called `NoteItem.qml` in the components folder and paste these lines:
> 

```jsx
import QtQuick 2.7
import Lomiri.Components 1.3
import Ubuntu.Components 1.3

// Component to display a single note in the list
ListItem {
    id: noteItem
    height: units.gu(10)
    
    // Properties to be set from outside
    property string title
    property string content
    property string createdAt
    property int noteIndex
    property var dateHelper
    
    // Signals
    signal noteSelected(int index)
    signal noteEditRequested(int index)
    signal noteDeleteRequested(int index)
    
    // Leading actions (delete)
    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    noteDeleteRequested(noteIndex);
                }
            }
        ]
    }
    
    // Trailing actions (edit)
    trailingActions: ListItemActions {
        actions: [
            Action {
                iconName: "edit"
                onTriggered: {
                    noteEditRequested(noteIndex);
                }
            }
        ]
    }
    
    // Note visual representation
    Rectangle {
        anchors.fill: parent
        radius: units.gu(1)
        border.color: "#cccccc"
        border.width: 1
        anchors.margins: units.gu(1)
        
        Row {
            spacing: units.gu(2)
            anchors.fill: parent
            anchors.margins: units.gu(2)
            
            Column {
                spacing: units.gu(0.5)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - parent.spacing
                
                Text {
                    text: noteItem.title
                    font.pixelSize: units.gu(2.5)
                    elide: Text.ElideRight
                    width: parent.width
                }
                
                Text {
                    text: dateHelper ? dateHelper.timeAgo(noteItem.createdAt) : noteItem.createdAt
                    font.pixelSize: units.gu(2)
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                noteSelected(noteIndex);
            }
        }
    }
}
```

- This is a `ListItem` with the id `noteItem`  . This one we use on the main page.
- It has some properties which it needs as arguments like `title`, `content`. It also invokes some signals like `noteSelected` , `noteEditRequest` and `NoteDeleteRequest.` It defines the leading action as well as the trailing action just as we discussed in previous modules. It also takes care of our UI of our `ListItem` as well as the actions for `MouseArea` which we have already discussed in day2 and day3.

> Task 2
> 

Now Lets add the Views for the `NotesEditPage` which is displayed when we click on the Notes or on the trailing Edit action button. 

For this , create a `NotesEditPage.qml` in the Views folder and paste this code:

```jsx
import QtQuick 2.7
import Lomiri.Components 1.3

// Page for editing a note
Page {
    id: noteEditPage
    
    // Properties to be set from outside
    property var controller
    
    // Signal when navigation back is requested
    signal backRequested()
    
    visible: false
    
    header: PageHeader {
        id: editHeader
        title: i18n.tr('Edit Note')
        
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    backRequested();
                }
            }
        ]
        
        trailingActionBar.actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    controller.deleteCurrentNote();
                    backRequested();
                }
            },
            Action {
                iconName: "ok"
                text: i18n.tr("Save")
                onTriggered: {
                    if (controller.updateCurrentNote(titleEditField.text, contentEditArea.text)) {
                        backRequested();
                    }
                }
            }
        ]
    }
    
    // Edit form
    Column {
        anchors {
            top: editHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(2)
        }
        spacing: units.gu(2)
        
        TextField {
            id: titleEditField
            width: parent.width
            placeholderText: i18n.tr("Title")
            text: controller.currentNote.title
        }
        
        TextArea {
            id: contentEditArea
            width: parent.width
            height: parent.height - titleEditField.height - parent.spacing
            placeholderText: i18n.tr("Note content...")
            text: controller.currentNote.content
            autoSize: false
        }
    }
    
    
    Connections {
        target: controller
        onCurrentNoteChanged: {
            titleEditField.text = controller.currentNote.title;
            contentEditArea.text = controller.currentNote.content;
        }
    }
}
```

Once again we have a controller property and a signal.

It has a header with back button and two trailing actions for either saving the note or deleting it.

Then we have two `text-forms` . one for the `title` and the other for the `content` of our note. 

We get the context about which note to edit , from the controller which we access with `controller.currentNote.title` ,etc.

At last we have a connections element , which we are using to handle a signal which is out of scope for our current `qml` file. Here we have defined the target as `controller` and `signal` as `onCurrentNoteChanged` and defines what to do when it is invoked, basically just changing the title and content of the note. 

```jsx
      Connections {        target: controller        onCurrentNoteChanged: {            titleEditField.text = controller.currentNote.title;            contentEditArea.text = controller.currentNote.content;        }    }
```