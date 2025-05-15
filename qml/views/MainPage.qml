import QtQuick 2.7
import Lomiri.Components 1.3
import Ubuntu.Components.Popups 1.3
import "components"
import "practice"

Page {
    id: mainPage

    property var controller
    property var notesModel

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
            numberOfSlots: 2
            actions: [
                Action {
                    iconName: "add"
                    text: i18n.tr("Add Note")
                    onTriggered: {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("components/AddNoteDialog.qml"));
                        dialog.saveRequested.connect(function(title, content,isRichText) {
                            controller.createNote(title, content,isRichText);
                        });
                    }
                },

                Action {
                    iconName: "search"
                    text: i18n.tr("Search")
                    onTriggered: {
                        var dialog = PopupUtils.open(Qt.resolvedUrl("practice/first.qml"));
                    }
                }
            ]
        }
    }

    Rectangle {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: Theme.palette.normal.background

        ListView {
            id: notesListView
            anchors.fill: parent
            anchors.margins: units.gu(2)
            model: notesModel.notes
            delegate: NoteItem {
                width: parent.width
                title: model.title
                content: model.content || ""
                createdAt: model.createdAt
                noteIndex: index
                isRichText: model.isRichText || false
                palette: Theme.palette

                onNoteSelected: {
                    controller.setCurrentNote(index);
                    editNoteRequested(index);
                }

                onNoteEditRequested: {
                    controller.setCurrentNote(index);
                    editNoteRequested(index);
                }

                onNoteDeleteRequested: {
                    controller.deleteNote(index);
                }
            }
        }
    }
}