import QtQuick 2.7
import Lomiri.Components 1.3
import Ubuntu.Components.Popups 1.3
import "components"
import "practice"

// Main page displaying the list of notes
Page {
    id: mainPage
    
    
    property var controller
    property var notesModel
    property var selectedNotes: [] // Array to track selected note indices
    property bool selectionMode: false // Show checkboxes only in selection mode
    
    signal editNoteRequested(int index)
    
    anchors.fill: parent
    
    header: PageHeader {
        id: header
        title: i18n.tr('Notes')
        subtitle: i18n.tr('Keep Your Ideas in One Place.')
        
        ActionBar {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            
            numberOfSlots: 4
            actions: [
                Action {
                    iconName: "add"
                    text: i18n.tr("Add Note")
                    onTriggered: {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("components/AddNoteDialog.qml"));
                        dialog.saveRequested.connect(function(title, content,isRichText) {
                            mainPage.controller.createNote(title, content,isRichText);
                        });
                    }
                },
                Action {
                    iconName: "search"
                    text: i18n.tr("Search")
                    onTriggered: {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("practice/first.qml"));
                    }
                },
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete Selected")
                    enabled: mainPage.selectedNotes.length > 0
                    onTriggered: {
                        mainPage.controller.deleteMultipleNotes(mainPage.selectedNotes);
                        mainPage.selectedNotes = [];
                    }
                },
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete All")
                    enabled: mainPage.notesModel.notes.length > 0
                    onTriggered: {
                        mainPage.controller.deleteAllNotes();
                        mainPage.selectedNotes = [];
                    }
                }
            ]
        }
    }
    
    ListView {
        id: notesListView
        
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: units.gu(2)
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }
        
        model: mainPage.notesModel.notes
        
        delegate: ListItem {
            height: units.gu(6)
            Item {
                width: parent.width
                height: parent.height
                MouseArea {
                    anchors.fill: parent
                    onPressAndHold: mainPage.selectionMode = true
                    onClicked: {
                        if (mainPage.selectionMode) {
                            var idx = mainPage.selectedNotes.indexOf(index);
                            if (idx === -1) {
                                mainPage.selectedNotes.push(index);
                            } else {
                                mainPage.selectedNotes.splice(idx, 1);
                            }
                        } else {
                            mainPage.controller.setCurrentNote(index);
                            mainPage.editNoteRequested(index);
                        }
                    }
                }
                CheckBox {
                    id: selectBox
                    visible: mainPage.selectionMode
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    checked: mainPage.selectedNotes.indexOf(index) !== -1
                    onClicked: {
                        if (checked) {
                            if (mainPage.selectedNotes.indexOf(index) === -1)
                                mainPage.selectedNotes.push(index);
                        } else {
                            var idx = mainPage.selectedNotes.indexOf(index);
                            if (idx !== -1)
                                mainPage.selectedNotes.splice(idx, 1);
                        }
                    }
                }
                NoteItem {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: selectBox.right
                    anchors.leftMargin: units.gu(1)
                    width: parent.width - selectBox.width - units.gu(3)
                    title: model.title
                    content: model.content || ""
                    createdAt: model.createdAt
                    noteIndex: index
                    isRichText: model.isRichText || false
                    onNoteSelected: {
                        if (!mainPage.selectionMode) {
                            mainPage.controller.setCurrentNote(index);
                            mainPage.editNoteRequested(index);
                        }
                    }
                    onNoteEditRequested: {
                        if (!mainPage.selectionMode) {
                            mainPage.controller.setCurrentNote(index);
                            mainPage.editNoteRequested(index);
                        }
                    }
                    onNoteDeleteRequested: {
                        mainPage.controller.deleteNote(index);
                    }
                }
            }
        }
    }
}