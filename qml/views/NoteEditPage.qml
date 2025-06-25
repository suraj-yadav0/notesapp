import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import "../views/components/"
import "../common/constants"

Page {
    id: noteEditPage

    // to be set from outside
    property var notesModel

    // when navigation back is requested
    signal backRequested
    signal saveRequested(var content)

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
                    notesModel.deleteCurrentNote();
                    backRequested();
                }
            },
            Action {
                iconName: "ok"
                text: i18n.tr("Save")
                onTriggered: {
                    var content = isRichTextSwitch.checked ? richTextLoader.item.text : plainTextArea.text;

                    if (notesModel.updateCurrentNote(titleEditField.text, content, isRichTextSwitch.checked)) {
                        saveRequested(content)
                        backRequested();
                    }
                }
            }
        ]
    }

    // Edit form
    Column {
        id: editForm
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
            text: notesModel.currentNote.title
        }

        // Toggle for rich text 
        Row {
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: i18n.tr("Rich Text:")
                anchors.verticalCenter: parent.verticalCenter
            }

            Switch {
                id: isRichTextSwitch
                checked: notesModel.currentNote.isRichText || false
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        //rich/plain text switch
        Item {
            width: parent.width
            height: parent.height - titleEditField.height - parent.spacing * 2 - isRichTextSwitch.height

            //  for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Note content...")
                text: notesModel.currentNote.content
                autoSize: false
                visible: !isRichTextSwitch.checked
            }

            // Rich text editor
            Rectangle {
                anchors.fill: parent

                visible: isRichTextSwitch.checked
                border.width: 1
                border.color: theme.palette.normal.baseText
                color: theme.palette.normal.background
                radius: units.gu(0.5)
                height: parent.height - units.gu(5)

                
                anchors.margins: units.gu(-1)
            }

            Loader {
                id: richTextLoader
                anchors.fill: parent
                active: isRichTextSwitch.checked
                visible: isRichTextSwitch.checked

                sourceComponent: Component {
                    RichTextEditor {
                        editMode: true
                        initialText: notesModel.currentNote.content
                        
                        onContentChanged: {
                            // Auto-save content changes
                            console.log("Rich text content changed in edit mode")
                        }
                        
                        Component.onCompleted: {
                            focusEditor()
                        }
                    }
                }

                onLoaded: {
                    if (notesModel.currentNote.content) {
                        item.initialText = notesModel.currentNote.content
                        item.text = notesModel.currentNote.content
                        item.focusEditor()
                    }
                }
            }
        }

        // Update fields when current note changes
        Connections {
            target: notesModel
            onNoteSelectionChanged: {
                titleEditField.text = notesModel.currentNote.title;
                isRichTextSwitch.checked = notesModel.currentNote.isRichText || false;

                if (isRichTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                    richTextLoader.item.text = notesModel.currentNote.content;
                    richTextLoader.item.forceActiveFocus();
                } else {
                    plainTextArea.text = notesModel.currentNote.content;
                }
            }
        }
    }
}
