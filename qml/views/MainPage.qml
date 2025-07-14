import QtQuick 2.7
import Lomiri.Components 1.3
import "components"
import "../common/constants"
import "../common/theme"

// Main page displaying the list of notes
Page {
    id: mainPage

    property var notesModel

    signal editNoteRequested(int index)
    signal todoViewRequested
    signal addNoteRequested
    property var onTodoViewRequested

    anchors.fill: parent

    header: PageHeader {
        id: header
        title: "" // Hide default title
        subtitle: ""
        // Custom centered title
        Text {
            text: AppConstants.appName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: units.gu(2.25)
            color: ThemeHelper.getTextColor()
            font.bold: true
        }

        ActionBar {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: AppConstants.smallMargin
                rightMargin: AppConstants.smallMargin
            }
            numberOfSlots: 2
            actions: [
                Action {
                    iconName: ThemeHelper.getThemeToggleIcon()
                    text: ThemeHelper.getThemeToggleText()
                    onTriggered: {
                        ThemeHelper.toggleTheme();
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
            rightMargin: AppConstants.defaultMargin
            leftMargin: AppConstants.defaultMargin
        }
        model: notesModel.notes

        delegate: NoteItem {
            width: parent.width
            title: model.title
            content: model.content || ""
            createdAt: model.createdAt
            noteIndex: index
            isRichText: model.isRichText || false

            onNoteSelected: {
                notesModel.setCurrentNote(index);
                editNoteRequested(index);
            }
            onNoteEditRequested: {
                notesModel.setCurrentNote(index);
                editNoteRequested(index);
            }
            onNoteDeleteRequested: {
                notesModel.deleteNote(index);
            }
        }
    }

    // Floating Action Button
    Rectangle {
        id: floatingButton
        width: AppConstants.defaultButtonSize
        height: AppConstants.defaultButtonSize
        radius: width / 2
        color: LomiriColors.orange
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: AppConstants.defaultIconSize
            bottomMargin: AppConstants.defaultHintSize
        }

        Icon {
            anchors.centerIn: parent
            name: "add"
            width: AppConstants.defaultIconSize
            height: AppConstants.defaultIconSize
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Add note floating button clicked!");
                addNoteRequested();
            }
        }
    }

    onTodoViewRequested:
    // This can be left empty or used for local handling if needed
    {}

    // Function for creating new note (called by keyboard shortcuts)
    function createNewNote() {
        console.log("Creating new note via keyboard shortcut");
        addNoteRequested();
    }
}
