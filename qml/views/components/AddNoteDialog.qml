import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.Controls 2.2 as QQC2

// Dialog for adding or editing notes
Dialog {
    id: noteDialog
    
    
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