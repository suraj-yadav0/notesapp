# Day 3

Let’s Start the day with Learning some `qml` and its UI elements and what we can do with it.

> Task 1
> 

> Lets Change our Model and Add Button View Component to accommodate `Title` and `Description` of the Note.
> 

Lets Add another `TextArea` for the for the `Title` of Our Notes. Lets also remove the redundant `label` we won’t be needing it now. 

Replace the Component For the Adding new Notes with this Code :

```jsx
  Component {
        id: noteDialogComponent

        Dialog {
            id: noteDialog

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
                }

                TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.gu(15)
                    placeholderText: i18n.tr("Type your note here...")
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: units.gu(1)
                    spacing: units.gu(1)

                    Button {
                        Layout.fillWidth: true
                        text: i18n.tr("Cancel")
                        onClicked: {
                            PopupUtils.close(noteDialog);
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: i18n.tr("Save")
                        color: theme.palette.normal.positive
                        onClicked: {
                            if (noteTitleArea.text.trim() !== "") {
                                notesModel.append({
                                    title: noteTitleArea.text.trim(),
                                    content: noteTextArea.text.trim(),
                                    createdAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd")
                                });

                                PopupUtils.close(noteDialog);
                            }
                        }
                    }
                }
            }
        }
    }
```

<aside>
💡

The `modal: true` property ensures that the dialog captures all user input and prevents interaction with other parts of the UI until it is closed.

</aside>


                   
![notes3.1](/docs/screenshots/notes3.3.png)
Image 3.1


> Task 2
> 

Let’s add a Edit Button to our `ListItems` We will add this Edit Button to the `trailingActions` 

Here we define a `ListItemActions` and define list of `actions` . This List take Action as a parameter which further takes a `iconName` , `onTriggered` parameters. 

<aside>
💡

Lets add property variable at the Top of Page called `currentNote` , which will keep track of the current Note being Edited.

</aside>

```jsx
property var currentNote: ({title: "", content: "", createdAt: "", index: -1})
```

Now Add this Code just below the `leadingActions` Button :

```jsx
 trailingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "edit"
                                onTriggered: {
                                    // Set current note data
                                    currentNote = {
                                        title: model.title,
                                        content: model.content || "",
                                        createdAt: model.createdAt,
                                        index: index
                                    };
                                    // Open the edit page
                                    pageStack.push(noteEditPage);
                                }
                            }
                        ]
                    }
```

Here when clicked or triggered `currentNote` is set to current `listitem’`s data be it `title,` `content` or `createdAt` or the `index` . 

Image 3.2
 ![notes3.2](/docs/screenshots/notes3.2.png)

> Task 3
> 

Now as you can see in the Edit Button , i have defined `pageStack.push(noteEditPage);` after the `onTriggred` function. This will help in opening a new Page on top of our current Page.

To implement this first of all wrap the `Page` with `PageStack` and give it a id as `pageStack` then write `Component.onCompleted: push(mainPage)` . This Will load our main Screen Home Page when device is booted or app is launched.

Replace the `MouseArea` Code with this :

```jsx
   MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Clicked on note:", model.title);
                                // Set current note data
                                currentNote = {
                                    title: model.title,
                                    content: model.content || "",
                                    createdAt: model.createdAt,
                                    index: index
                                };
                                // Navigate to note detail page
                                pageStack.push(noteEditPage);
                            }
                        }
```

So now When Clicked on the `ListItem` a new Page will be Pushed onto the `pageStack` and we will be able to view the `noteEditPage` (To be implemented).

> Task 4
> 

Now we want to create a new page that will appear when clicked on the `ListItem` and when clicked on the Edit Icon from the `trailingAction` Button.

Add this Code Just when our MainPage Ends. Here in this Page we have given it a different `id` and `title` : 

```jsx
Page {
   id: noteEditPage
   visible: false

        header: PageHeader {
            id: editHeader
            title: i18n.tr('Edit Note')

            leadingActionBar.actions: [
                Action {
                    iconName: "back"
                    onTriggered: {
                        pageStack.pop();
                    }
                }
            ]

            trailingActionBar.actions: [
                Action {
                            iconName: "delete"
                            onTriggered: {
                                notesModel.remove(currentNote.index);
                                pageStack.pop();
                            }
                        } ,
                Action {
                    iconName: "ok"
                    text: i18n.tr("Save")
                    onTriggered: {
                        // Update the note in the model
                        if (currentNote.index >= 0) {
                            notesModel.set(currentNote.index, {
                                title: titleEditField.text,
                                content: contentEditArea.text,
                                createdAt: currentNote.createdAt,

                            });
                            pageStack.pop();
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
                text: currentNote.title
            }

            TextArea {
                id: contentEditArea
                width: parent.width
                height: parent.height - titleEditField.height - parent.spacing
                placeholderText: i18n.tr("Note content...")
                text: currentNote.content
                autoSize: false
            }
        }
    }

```

Here we have also added the option to delete and save the note at the top in the PageHeader.

These two actions in the Pageheader recieve their context on which Note to perform action , is from the currentNote var property defined at the top.

In the Edit Form , there are two text forms. One for the title of the Note and other for the Description of the Notes. 

> You can also change the dummy data in the model to suit the new model of the Notes.
> 

Now Your edit page should look something like this.

 ![notes3.3](/docs/screenshots/notes3.3.png)

Image 3.3