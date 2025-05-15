import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import "components" // This import is crucial for finding SimpleRichTextEditor

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
                    var content = isRichTextSwitch.checked ? 
                                  richTextLoader.item.text : 
                                  plainTextArea.text;
                    
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
                
                // Handle mode switching explicitly to ensure content transfer
                onCheckedChanged: {
                    if (checked && richTextLoader.status === Loader.Ready) {
                        richTextLoader.item.text = plainTextArea.text;
                        // Ensure focus after a small delay to let the UI update
                        focusTimer.start();
                    } else if (!checked) {
                        plainTextArea.text = richTextLoader.item ? richTextLoader.item.text : controller.currentNote.content;
                    }
                }
            }
            
            // Timer to set focus after mode switch
            Timer {
                id: focusTimer
                interval: 100
                onTriggered: {
                    if (richTextLoader.item) {
                        richTextLoader.item.forceActiveFocus();
                    }
                }
            }
        }
        
        // Content area with rich/plain text switch
        Item {
            width: parent.width
            height: parent.height - titleEditField.height - parent.spacing*2 - isRichTextSwitch.height
            
            // Standard text area for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Note content...")
                text: controller.currentNote.content
                autoSize: false
                visible: !isRichTextSwitch.checked
            }
            
            // Use our new SimpleRichTextEditor instead of the RichTextEditor
            Loader {
                id: richTextLoader
                anchors.fill: parent
                active: isRichTextSwitch.checked
                visible: isRichTextSwitch.checked
                
                sourceComponent: Component {
                    SimpleRichTextEditor {
                        id: simpleRichEditor
                        // Initialize with content
                        text: controller.currentNote.content || ""
                        
                        // Debug any content changes
                        onContentChanged: {
                            console.log("Rich text content changed in editor, length:", newText.length);
                        }
                        
                        // Make sure we initialize the component
                        Component.onCompleted: {
                            console.log("SimpleRichTextEditor component completed in NoteEditPage");
                            forceActiveFocus();
                        }
                    }
                }
                
                onLoaded: {
                    console.log("SimpleRichTextEditor loaded in NoteEditPage");
                    if (controller.currentNote.content) {
                        item.text = controller.currentNote.content;
                        console.log("Set text from controller, length:", controller.currentNote.content.length);
                    }
                    // Force focus after loading
                    focusTimer.restart();
                }
                
                // Handle status changes
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        console.log("Loader is now ready");
                    }
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
            
            // Handle content updating with a slight delay to ensure the loader is ready
            Qt.callLater(function() {
                if (isRichTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                    richTextLoader.item.text = controller.currentNote.content || "";
                    focusTimer.restart();
                } else {
                    plainTextArea.text = controller.currentNote.content || "";
                }
            });
        }
    }
}