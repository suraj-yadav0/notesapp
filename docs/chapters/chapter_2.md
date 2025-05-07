
    # Day 2

---

Well starting the Day with , Some research on Ubuntu Touch App Development. Browsing through documentation and community Forums and looking at Developers advice. 

<aside>
💡

Do Checkout the Clickable Documentation [here](https://clickable-ut.dev/en/latest/index.html)

</aside>

I have been preparing a Time-Line for the app , and I think i should be able to complete this in less than a month. Well the Developers in the forum says it can take up-to 2 to 3 months. But I am a quick learner and I should be able to do it.

> Task 1
> 

> Now Lets talk about our app, Now I want to add UI when we click on the Add action in the Page header a new page should open and we should be able to add our Notes from there in the APP.
> 

<aside>
💡

New learning of the day, do not UN-comment the `QtQuick.Controls 2.2`

</aside>

To add a new task I have decided to add a pop-up that will have a `TextArea` where we can add our notes . Just for simplicity sake we will have two buttons , `Cancel` and `Save`. Cancel closes that pop-up and Save `appends` that Note to our `ListView` . This a temporary UI , we will be enhancing this in Future with Complexity of our Project increases.  

```jsx

    Component {
        id: noteDialogComponent

        Dialog {
            id: noteDialog
            title: i18n.tr("Add New Action")
            modal: true

            ColumnLayout {
                width: parent.width
                spacing: units.gu(1)

                Label {
                    text: i18n.tr("Enter your note:")
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
                            if (noteTextArea.text.trim() !== "") {
                                notesModel.append({
                                    title: noteTextArea.text.trim(),
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

 

  ![notes2.1](/docs/screenshots/notes2.1.png)

> Task 2
> 

Now we have the Functionality to Add our Notes(Well Temporarily One) To our `ListView` and We want to Delete the Note. So how do we do it ?

We can achieve this by wrapping the `Rectangle` with a `ListItem` in the `delegate` section of `ListView.`

Replace the `delegate` section with given code:

```jsx

            delegate: ListItem {
                id: noteItem
                height: units.gu(10)

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            onTriggered: {
                                var rowid = notesModel.get(index).rowid;
                                notesModel.remove(index);
                            }
                        }
                    ]
                }

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

                            Text {
                                text: model.title
                                font.pixelSize: units.gu(2.5)
                              //  font.bold: true
                            }

                            Text {
                                text: model.createdAt
                                font.pixelSize: units.gu(2)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Clicked on note:", model.title);
                            // Navigate to note detail
                        }
                    }
                }
            }
```

  

This Feature adds a `delete` button when you slide the `ListView` Item from left to right

Then Also Resolved some Inconsistency in the UI. Learning `QML` through documentation.

Next Features i should add :

- [ ]  Adding sqlite3
- [ ]  Adding a Edit Button
- [ ]  Improve Model Of Notes , Add a Content Section
- [ ]  Improve the Notes Add Section
- [ ]  Test For Convergence
- [ ]  Test For Dark-Mode Compatibility
- [ ]  Refactor code for Modularity

