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

import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes 1.3

// Import our own components
import "models"
import "controllers"
import "views"


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'notesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(60)
    height: units.gu(75)

    theme.palette: Palette {}

    NotesModel {
        id: notesModel
    }

    NotesController {
        id: notesController
        model: notesModel
    }

    AdaptivePageLayout {
        id: pageLayout
        anchors.fill: parent
        primaryPage: mainPage
         property Page thirdPage: todoPage
        
        property bool isMultiColumn: true

        layouts: [
            PageColumnsLayout {
                // Tablet Mode
                when: width > units.gu(80) && width < units.gu(130)
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(50)
                    preferredWidth: width > units.gu(90) ? units.gu(20) : units.gu(15)
                }
                PageColumn {
                    minimumWidth: units.gu(50)
                    maximumWidth: units.gu(80)
                    preferredWidth: width > units.gu(90) ? units.gu(60) : units.gu(45)
                }
            },
            PageColumnsLayout {
                // Desktop Mode
                when: width >= units.gu(130)
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(50)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    minimumWidth: units.gu(65)
                    maximumWidth: units.gu(80)
                    preferredWidth: units.gu(50)
                }
                PageColumn {
                    fillWidth: true
                }
            }
        ]

        // Main notes list page
        MainPage {
            id: mainPage
            controller: notesController
            notesModel: notesModel

            onEditNoteRequested: {
                pageLayout.addPageToNextColumn(mainPage, noteEditPage)
            }
        }

        // Note editor page
        NoteEditPage {
            id: noteEditPage
            controller: notesController

            onBackRequested: {
                pageLayout.removePages(noteEditPage)
            }
        }
    }
}