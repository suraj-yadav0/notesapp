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

                numberOfSlots: 2
                actions: [
                    Action {
                        iconName: "info"
                        text: i18n.tr("About")
                    },
                    Action {

                        iconName: "search"
                        text: i18n.tr("Search")
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
            spacing: 10

            model: notesModel

            delegate: Rectangle {
                width: ListView.view.width
                height: 80
                //color: "white"
                //border.color: "#cccccc"
                border.width: 1
                radius: 8
                anchors.margins: 8

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16

                    Text {
                        text: model.title
                        font.pixelSize: 20
                        font.bold: true
                        //   color: "black"
                    }

                    Text {
                        text: model.createdAt
                        font.pixelSize: 14
                        //  color: "#888888"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked on note:", model.title);
                        // TODO: Navigate to Note Detail View
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
}
