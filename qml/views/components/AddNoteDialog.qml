import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Popups 1.3
import "."

// Dialog for adding or editing notes
Dialog {
    id: noteDialog
    
    // Properties - determine if we're adding or editing
    property bool isEditing: false
    property string initialTitle: ""
    property string initialContent: ""
    property bool isRichText: false
    
    // Signals
    signal saveRequested(string title, string content, bool isRichText)
    signal cancelRequested()
    
    title: isEditing ? i18n.tr("Edit Note") : i18n.tr("Add New Note")
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
            text: initialTitle
        }
        
        // Toggle for rich text format
        Row {
            Layout.fillWidth: true
            spacing: units.gu(1)
            
            Label {
                text: i18n.tr("Rich Text:")
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Switch {
                id: richTextSwitch
                checked: isRichText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Different editor components depending on whether rich text is enabled
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: units.gu(20)
            
            // Standard TextArea for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Type your note here...")
                text: initialContent
                visible: !richTextSwitch.checked
            }
            
            // Rich text editor component
            Loader {
                id: richTextLoader
                anchors.fill: parent
                active: richTextSwitch.checked
                visible: richTextSwitch.checked
                
                sourceComponent: Component {
                    RichTextEditor {
                        text: initialContent
                        editMode: true
                    }
                }
                
                onLoaded: {
                    if (initialContent && richTextSwitch.checked) {
                        item.text = initialContent;
                    }
                }
            }
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
                        // Get content from either rich or plain text editor
                        var content = richTextSwitch.checked ? 
                                      richTextLoader.item.text : 
                                      plainTextArea.text;
                        
                        saveRequested(noteTitleArea.text, content, richTextSwitch.checked);
                        PopupUtils.close(noteDialog);
                    }
                }
            }
        }
    }
}