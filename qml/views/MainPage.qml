import QtQuick 2.7
import Lomiri.Components 1.3
import Ubuntu.Components.Popups 1.3
import "components"
import "../assets"

// Main page displaying the list of notes
Page {
    id: mainPage

    property var controller
    property var notesModel

    signal editNoteRequested(int index)
    signal todoViewRequested()
    property var onTodoViewRequested

    anchors.fill: parent

        header: PageHeader {
            id: header
            title: "" // Hide default title
            subtitle: ""
            // Custom centered title
            Text {
                text: "N O T E S"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: units.gu(2.25)
                color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#FFFFFF" : "#0D141C"
                font.bold: true
            }

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
                            dialog.saveRequested.connect(function (title, content, isRichText) {
                                controller.createNote(title, content, isRichText);
                            });
                        }
                    },
                    Action {
                        iconName: "search"
                        text: i18n.tr("Search")
                        onTriggered: {
                            console.log("Search action triggered");
                            todoViewRequested()
                        }
                    },
                    Action {
                        iconName: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "weather-clear" : "weather-clear-night"
                        text: theme.name === "Ubuntu.Components.Themes.SuruDark" ? i18n.tr("Light Mode") : i18n.tr("Dark Mode")
                        onTriggered: {
                            Theme.name = theme.name === "Ubuntu.Components.Themes.SuruDark" ? "Ubuntu.Components.Themes.Ambiance" : "Ubuntu.Components.Themes.SuruDark";
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
                rightMargin: units.gu(2)
                leftMargin: units.gu(2)
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

    // Floating Action Button
    Rectangle {
        id: floatingButton
        width: units.gu(7)
        height: units.gu(7)
        radius: width / 2
        color: LomiriColors.orange // Or any color you prefer
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: units.gu(3)
            bottomMargin: units.gu(8)
        }

       Icon{
            anchors.centerIn: parent
            name: "add"
            width: units.gu(3)
            height: units.gu(3)
            color: "white" // Icon color
       }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Floating button clicked!")
                // Add your action here, for example, opening the AddNoteDialog
                var dialog = PopupUtils.open(Qt.resolvedUrl("components/AddNoteDialog.qml"));
                dialog.saveRequested.connect(function (title, content, isRichText) {
                    controller.createNote(title, content, isRichText);
                });
            }
        }

        // Optional: Add a shadow or elevation effect
        // Rectangle {
        //     anchors.fill: parent
        //     radius: floatingButton.radius
        //     color: "transparent" // Make the shape itself transparent
        //    // elevation: units.dp(6) // Adjust elevation for shadow effect
        //     z: -1 // Place shadow behind the button
        // }
    }

    onTodoViewRequested: {
        // This can be left empty or used for local handling if needed
    }
}
