import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import "components"

// Page for editing a note
Page {
    id: noteEditPage

    // Properties to be set from outside
    property var controller

    // Signal when navigation back is requested
    signal backRequested

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
                    var content = isRichTextSwitch.checked ? richTextLoader.item.text : plainTextArea.text;

                    if (controller.updateCurrentNote(titleEditField.text, content, isRichTextSwitch.checked)) {
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
            text: controller.currentNote.title
        }

        // Toggle for rich text format
        Row {
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: i18n.tr("Rich Text:")
                anchors.verticalCenter: parent.verticalCenter
            }

            Switch {
                id: isRichTextSwitch
                checked: controller.currentNote.isRichText || false
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Content area with rich/plain text switch
        Item {
            width: parent.width
            height: parent.height - titleEditField.height - parent.spacing * 2 - isRichTextSwitch.height

            // Standard text area for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Note content...")
                text: controller.currentNote.content
                autoSize: false
                visible: !isRichTextSwitch.checked
            }

            // Rich text editor
            Rectangle {
                anchors.fill: parent

                visible: isRichTextSwitch.checked
                border.width: 1
                border.color: "#CCCCCC"
                radius: units.gu(0.5)
                height: parent.height - units.gu(5)

                // Use this instead of padding which is not available
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
                    }
                }

                onLoaded: {
                    if (controller.currentNote.content) {
                        item.text = controller.currentNote.content;
                        item.forceActiveFocus();
                    }
                }
            }
        }

        // Update fields when current note changes
        Connections {
            target: controller
            onCurrentNoteChanged: {
                titleEditField.text = controller.currentNote.title;
                isRichTextSwitch.checked = controller.currentNote.isRichText || false;

                if (isRichTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                    richTextLoader.item.text = controller.currentNote.content;
                    richTextLoader.item.forceActiveFocus();
                } else {
                    plainTextArea.text = controller.currentNote.content;
                }
            }
        }
    }
}
