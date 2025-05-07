/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * notesapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'notesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    // This keeps the track of the current note being edited..
    property var currentNote: ({title: "", content: "", createdAt: "", index: -1})
    
    
    PageStack {
        id: pageStack
        Component.onCompleted: push(mainPage)
        
        
        Page {
            id: mainPage
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
                        // Action {
                        //     iconName: "search"
                        //     text: i18n.tr("Search")
                        // },
                        Action {
                            iconName: "add"
                            text: i18n.tr("Add Note")
                            onTriggered: {
                                PopupUtils.open(noteDialogComponent);
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

                model: notesModel

                delegate: ListItem {
                    id: noteItem
                    height: units.gu(10)

                    //leading action for delete functionality..

                    leadingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "delete"
                                onTriggered: {
                                    notesModel.remove(index);
                                }
                            }
                        ]
                    }
                    
                    // trailing actions for edit functionality..
                    trailingActions: ListItemActions {
                        actions: [
                            Action {
                                iconName: "edit"
                                onTriggered: {
                                    // Set current note data
                                    currentNote = {
                                        title: model.title,
                                        content: model.content || "",
                                        createdAt: model.createdAt,
                                        index: index
                                    };
                                    // Open the edit page
                                    pageStack.push(noteEditPage);
                                }
                            }
                        ]
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: units.gu(1)
                        border.color: "#cccccc"
                        border.width: 1

                        anchors.margins: units.gu(1)

                        Row {
                            spacing: units.gu(2)
                            anchors.fill: parent
                            anchors.margins: units.gu(2)

                            Column {
                                spacing: units.gu(0.5)
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - parent.spacing

                                Text {
                                    text: model.title
                                    font.pixelSize: units.gu(2.5)
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: model.createdAt
                                    font.pixelSize: units.gu(2)
                                }
                                
                            }

                          
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Clicked on note:", model.title);
                                // Set current note data
                                currentNote = {
                                    title: model.title,
                                    content: model.content || "",
                                    createdAt: model.createdAt,
                                    index: index
                                };
                                // Navigate to note detail page
                                pageStack.push(noteEditPage);
                            }
                        }
                    }
                }
            }
        }
        
        // Note edit page component
        Page {
            id: noteEditPage
            visible: false
            
            header: PageHeader {
                id: editHeader
                title: i18n.tr('Edit Note')
                
                leadingActionBar.actions: [
                    Action {
                        iconName: "back"
                        onTriggered: {
                            pageStack.pop();
                        }
                    }
                ]
                
                trailingActionBar.actions: [
                    Action {
                                iconName: "delete"
                                onTriggered: {
                                    notesModel.remove(currentNote.index);
                                    pageStack.pop();
                                }
                            } , 
                    Action {
                        iconName: "ok"
                        text: i18n.tr("Save")
                        onTriggered: {
                            // Update the note in the model
                            if (currentNote.index >= 0) {
                                notesModel.set(currentNote.index, {
                                    title: titleEditField.text,
                                    content: contentEditArea.text,
                                    createdAt: currentNote.createdAt,
                                    iconName: notesModel.get(currentNote.index).iconName
                                });
                                pageStack.pop();
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
                    text: currentNote.title
                }
                
                TextArea {
                    id: contentEditArea
                    width: parent.width
                    height: parent.height - titleEditField.height - parent.spacing
                    placeholderText: i18n.tr("Note content...")
                    text: currentNote.content
                    autoSize: false
                }
            }
        }
    }
    
    ListModel {
        id: notesModel

        ListElement {
            title: "First Note"
            content: "This is my first note content."
            createdAt: "2025-04-28"
            iconName: "note"
        }
        ListElement {
            title: "Second Note"
            content: "Some content for the second note."
            createdAt: "2025-04-27"
        }
        ListElement {
            title: "Meeting Notes"
            content: "Discuss project timeline\n- Feature prioritization\n- Budget allocation"
            createdAt: "2025-04-26"
        }
    }

    // Dialog component for adding new notes
    Component {
        id: noteDialogComponent

        Dialog {
            id: noteDialog

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
                }

                TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.gu(15)
                    placeholderText: i18n.tr("Type your note here...")
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: units.gu(1)
                    spacing: units.gu(1)

                    Button {
                        Layout.fillWidth: true
                        text: i18n.tr("Cancel")
                        onClicked: {
                            PopupUtils.close(noteDialog);
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        text: i18n.tr("Save")
                        color: theme.palette.normal.positive
                        onClicked: {
                            if (noteTitleArea.text.trim() !== "") {
                                notesModel.append({
                                    title: noteTitleArea.text.trim(),
                                    content: noteTextArea.text.trim(),
                                    createdAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd")
                                });

                                PopupUtils.close(noteDialog);
                            }
                        }
                    }
                }
            }
        }
    }
}