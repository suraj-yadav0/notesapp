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
    property int drawerWidth: units.gu(20)
    property bool isWide: width >= 800
    property bool drawerOpen: false // <-- Move here

    signal editNoteRequested(int index)

    anchors.fill: parent

    // Optional: Add a background Rectangle for the Page
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background // or any preferred color
        z: -1
    }

    // Custom Adaptive Drawer
    Rectangle {
        id: leftDrawer
        width: mainPage.drawerWidth
        height: parent.height
        color: "#f8f8f8" // light contrasting color
        border.color: "#cccccc"
        border.width: 1
        z: 100 // ensure it's above everything
        visible: !mainPage.isWide && mainPage.drawerOpen // <-- Use mainPage.drawerOpen
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: 0
        Behavior on x { NumberAnimation { duration: 200 } }

        Column {
            anchors.fill: parent
            spacing: units.gu(2)
            Label { text: i18n.tr("All Notes") }
            // Add more navigation items here
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mainPage.drawerOpen = false // <-- Use mainPage.drawerOpen
            // Prevent closing when clicking inside drawer
            propagateComposedEvents: true
        }
    }

    // Permanent side pane for wide screens
    Rectangle {
        id: sidePane
        width: mainPage.drawerWidth
        visible: mainPage.isWide
        color: "transparent"
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        Column {
            anchors.fill: parent
            spacing: units.gu(2)
            Label { text: i18n.tr("All Notes") }
            // Add more navigation items here
        }
    }

    // Move PageHeader and ActionBar here, directly inside Page
    Rectangle {
        id: headerBg
        color: "#e0e0e0"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: header.implicitHeight

        PageHeader {
            id: header
            anchors.fill: parent
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
                        iconName: "menu"
                        text: i18n.tr("Menu")
                        visible: !mainPage.isWide
                        onTriggered: mainPage.drawerOpen = true // <-- Use mainPage.drawerOpen
                    },

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
                    },

                    Action {
                        iconName: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "weather-clear" : "weather-clear-night"
                        text: theme.name === "Ubuntu.Components.Themes.SuruDark" ? i18n.tr("Light Mode") : i18n.tr("Dark Mode")
                        onTriggered: {
                        Theme.name = theme.name === "Ubuntu.Components.Themes.SuruDark" ? 
                                "Ubuntu.Components.Themes.Ambiance" : 
                                "Ubuntu.Components.Themes.SuruDark";
                        }
                    }
                ]
            }
        }
    }

    // Main content area, shifted if pane is visible
    Item {
        id: mainContent
        anchors {
            top: headerBg.bottom
            left: mainPage.isWide ? sidePane.right : parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ListView {
            id: notesListView
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: units.gu(2)
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
    }
}