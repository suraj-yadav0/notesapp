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
    
    // Update fields when current note changes
    Connections {
        target: controller
        onCurrentNoteChanged: {
            titleEditField.text = controller.currentNote.title;
            contentEditArea.text = controller.currentNote.content;
        }
    }
}