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
//import QtQuick.Controls 2.2
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

    Page {
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

                numberOfSlots: 3
                actions: [
                    Action {

                        iconName: "search"
                        text: i18n.tr("Search")
                    },
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
                bottom: parent.bottom // Tip : Its Very important to define the length of the List in the ListView
                topMargin: units.gu(2)
                rightMargin: units.gu(2)
                leftMargin: units.gu(2)
            }
            // spacing: 10

            model: notesModel
           

            delegate: ListItem {
                id: noteItem
                height: units.gu(10)

                leadingActions: ListItemActions {
                    actions: [
                        Action {
                            iconName: "delete"
                            onTriggered: {
                                var rowid = notesModel.get(index).rowid;
                                notesModel.remove(index);
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

                            Text {
                                text: model.title
                                font.pixelSize: units.gu(2.5)
                              //  font.bold: true
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
                            // Navigate to note detail
                        }
                    }
                }
            }
        }
    }
    ListModel {
        id: notesModel

        ListElement {
            title: "First Note"
            createdAt: "2025-04-28"
        }
        ListElement {
            title: "Second Note"
            createdAt: "2025-04-27"
        }
        ListElement {
            title: "Meeting Notes"
            createdAt: "2025-04-26"
        }
    }

    // Dialog component for adding new notes
    Component {
        id: noteDialogComponent

        Dialog {
            id: noteDialog
            title: i18n.tr("Add New Action")
            modal: true

            ColumnLayout {
                width: parent.width
                spacing: units.gu(1)

                Label {
                    text: i18n.tr("Enter your note:")
                }

                TextArea {
                    id: noteTextArea
                    Layout.fillWidth: true
                    Layout.preferredHeight: units.gu(15)
                    placeholderText: i18n.tr("Type your note here...")
                    // autoSize: false
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
                            if (noteTextArea.text.trim() !== "") {
                                notesModel.append({
                                    title: noteTextArea.text.trim(),
                                    createdAt: Qt.formatDateTime(new Date(), "yyyy-MM-dd")
                                });
                                //  notesModel.append({"title": noteTextArea.text.trim()})

                                PopupUtils.close(noteDialog);
                            }
                        }
                    }
                }
            }
        }
    }
}
