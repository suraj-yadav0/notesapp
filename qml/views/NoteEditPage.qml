import QtQuick 2.7
import QtQuick.Controls 2.2 as QQC2
import Lomiri.Components 1.3

// Page for editing a note
Page {
    id: noteEditPage
    
    
    property var controller
    
    
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
          //  textFormat: Text.RichText
        }
        
        TextArea {
            id: contentEditArea
            width: parent.width
            height: parent.height - titleEditField.height - parent.spacing
            placeholderText: i18n.tr("Note content...")
            text: controller.currentNote.content
            textFormat: Text.RichText
            autoSize: false
        }
    }


    Rectangle {
                    id: formatToolbar
                    width: parent.width
                    height: units.gu(5)
                    color: "#f5f5f5"
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: units.gu(1)
                        
                        Button {
                            width: units.gu(4)
                            height: units.gu(4)
                            text: "B"
                            font.bold: true
                            onClicked: richTextEditor.runJavaScript("formatText('bold', true);")
                        }
                        
                        Button {
                            width: units.gu(4)
                            height: units.gu(4)
                            text: "I"
                            font.italic: true
                            onClicked: richTextEditor.runJavaScript("formatText('italic', true);")
                        }
                        
                        Button {
                            width: units.gu(4)
                            height: units.gu(4)
                            text: "U"
                            font.underline: true
                            onClicked: richTextEditor.runJavaScript("formatText('underline', true);")
                        }
                        
                        Button {
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "List"
                            onClicked: richTextEditor.runJavaScript("formatText('list', 'bullet');")
                        }
                        
                        Button {
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "H1"
                            onClicked: richTextEditor.runJavaScript("formatText('header', 1);")
                        }
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