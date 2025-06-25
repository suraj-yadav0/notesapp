import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Popups 1.3
import "."

// Dialog ..for adding notes.
Dialog {
    id: noteDialog
   
    // width: Math.min(parent.width * 0.9, units.gu(90))
    // height: Math.min(parent.height * 0.7, units.gu(80))
    anchors.centerIn: parent
    contentHeight: parent.height * 0.75
    contentWidth: parent.width * 0.8
    

    
    Component.onCompleted: {
       
        Qt.callLater(function() {
            x = (parent.width - width) / 2
            y = (parent.height - height) / 2
        })
    }
    
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
        id: contentColumn
        width: parent.width
        spacing: units.gu(1.5)
        
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
            Layout.preferredHeight: units.gu(25)
            
            // Standard TextArea for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Type your note here...")
                text: initialContent
                visible: !richTextSwitch.checked
            }

            // Rectangle border for rich text editor
        
            
            Rectangle {
                anchors.fill: parent
                
                visible: richTextSwitch.checked
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
                active: richTextSwitch.checked
                visible: richTextSwitch.checked
                
                sourceComponent: Component {
                    RichTextEditor {
                        id: richTextEditor
                        editMode: true
                    }
                }
                
                onLoaded: {
                    
                    if (richTextSwitch.checked) {
                        item.text = initialContent;
                    }
                }
            }
            
            // Update rich text when switching modes
            Connections {
                target: richTextSwitch
                onCheckedChanged: {
                    if (richTextSwitch.checked && richTextLoader.status === Loader.Ready) {
                        richTextLoader.item.text = initialContent || plainTextArea.text;
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
                        var content;
                        if (richTextSwitch.checked && richTextLoader.status === Loader.Ready) {
                            content = richTextLoader.item.text;
                        } else {
                            content = plainTextArea.text;
                        }
                        
                        console.log("Saving note - Title: " + noteTitleArea.text + ", Content length: " + content.length);
                        saveRequested(noteTitleArea.text, content, richTextSwitch.checked);
                        PopupUtils.close(noteDialog);
                    }
                }
            }
        }
    }
}