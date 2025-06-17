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
import "views/components"


MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'notesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(60)
    height: units.gu(75)

    theme.palette: Palette {}

    // Models
    NotesModel {
        id: notesModel
    }

    // Controllers
    NotesController {
        id: notesController
        model: notesModel
    }

    // Add ToDoView and SettingsPage as pages
    ToDoView {
        id: todoPage
        visible: false
    }
    SettingsPage {
        id: settingsPage
        visible: false
    }

    AdaptivePageLayout {
        id: pageLayout
        anchors.fill: parent
        primaryPage: mainPage

        // Define computed properties for better readability
        readonly property bool isTabletMode: width > units.gu(80) && width < units.gu(130)
        readonly property bool isDesktopMode: width >= units.gu(130)
        readonly property bool isPhoneMode: width <= units.gu(80)

        layouts: [
            PageColumnsLayout {
                // Tablet Mode (2 columns)
                when: pageLayout.isTabletMode
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(50)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    fillWidth: true
                    minimumWidth: units.gu(50)
                }
            },
            PageColumnsLayout {
                // Desktop Mode (3 columns)
                when: pageLayout.isDesktopMode
                PageColumn {
                    minimumWidth: units.gu(30)
                    maximumWidth: units.gu(50)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    minimumWidth: units.gu(50)
                    maximumWidth: units.gu(80)
                    preferredWidth: units.gu(60)
                }
                PageColumn {
                    fillWidth: true
                    minimumWidth: units.gu(40)
                }
            }
        ]

        // Main notes list page
        MainPage {
            id: mainPage
            controller: notesController
            notesModel: notesModel

            onEditNoteRequested: function(noteId) {
                noteEditPage.noteId = noteId
                if (pageLayout.isPhoneMode) {
                    pageLayout.addPageToCurrentColumn(mainPage, noteEditPage)
                } else {
                    pageLayout.addPageToNextColumn(mainPage, noteEditPage)
                }
            }

            onTodoViewRequested: {
                if (pageLayout.isDesktopMode) {
                    // In desktop mode, show todo in the third column
                    pageLayout.addPageToColumn(2, todoPage)
                } else if (pageLayout.isTabletMode) {
                    // In tablet mode, show todo in second column
                    pageLayout.addPageToColumn(1, todoPage)
                } else {
                     pageLayout.addPageToColumn(0, todoPage)
                    // In phone mode, do nothing (do not show ToDoView as a page)
                    // Optionally, you could show a toast or dialog if needed
                }
            }

            // Connect BottomNavigtor signals to navigation logic
            BottomNavigtor {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                onMainPageRequested: {
                    // Show mainPage, hide others
                    mainPage.visible = true
                    todoPage.visible = false
                    settingsPage.visible = false
                    if (!pageLayout.hasPage(mainPage))
                        pageLayout.setPrimaryPage(mainPage)
                }
                onTodoPageRequested: {
                    mainPage.visible = false
                    todoPage.visible = true
                    settingsPage.visible = false
                    if (!pageLayout.hasPage(todoPage))
                        pageLayout.setPrimaryPage(todoPage)
                }
                onSettingsPageRequested: {
                    mainPage.visible = false
                    todoPage.visible = false
                    settingsPage.visible = true
                    if (!pageLayout.hasPage(settingsPage))
                        pageLayout.setPrimaryPage(settingsPage)
                }
            }
        }

        // Note editor page
        NoteEditPage {
            id: noteEditPage
            controller: notesController

            property string noteId: ""

            onBackRequested: {
                pageLayout.removePages(noteEditPage)
            }

            onSaveRequested: function(content) {
                controller.saveNote(noteId, content)
            }
        }

        // Add ToDoView and SettingsPage to the layout (hidden by default)
        ToDoView {
          //  id: todoPage
            visible: false

            
        }
        SettingsPage {
          //  id: settingsPage
            visible: false
        }
    }

    // Keyboard shortcuts (for desktop)
    Shortcut {
        sequence: StandardKey.New
        onActivated: mainPage.createNewNote()
    }

    Shortcut {
        sequence: "Ctrl+T"
        onActivated: mainPage.todoViewRequested()
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    // Handle back button on mobile
    Connections {
        target: root
        function onApplicationStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive) {
                // App became active
            }
        }
    }

    Component.onCompleted: {
        console.log("NotesApp initialized successfully")
        console.log("Screen size:", width + "x" + height)
        console.log("Mode:", pageLayout.isDesktopMode ? "Desktop" : 
                          pageLayout.isTabletMode ? "Tablet" : "Phone")
    }
}