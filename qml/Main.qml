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
import QtQuick.Layouts 1.3
import Lomiri.Components 1.3
import Lomiri.Components.Themes 1.3
import Ubuntu.Components.Popups 1.3

// Import our own components
import "models"
import "views"
import "views/components"
import "common/constants"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'notesapp.surajyadav'
    automaticOrientation: true

    width: units.gu(52)
    height: units.gu(90)

    // Models (now include controller functionality)
    property alias notesModelInstance: notesModel

    NotesModel {
        id: notesModel

        Component.onCompleted: {
            console.log("NotesModel initialized with SQLite database");
        }
    }

    // Page Stack for navigation
    PageStack {
        id: pageStack
        anchors.fill: parent

        Component.onCompleted: {
            push(mainPageInstance);
        }
    }

    // Main page instance
    MainPage {
        id: mainPageInstance
        visible: false
        notesModel: notesModel

        onEditNoteRequested: function (noteIndex) {
            console.log("Edit note requested for index:", noteIndex);
            notesModel.setCurrentNote(noteIndex);
            pageStack.push(noteEditPageComponent, {
                notesModel: notesModel
            });
        }

        onAddNoteRequested: {
            pageStack.push(addNotePageComponent, {
                notesModel: notesModel
            });
        }

        onTodoViewRequested: {
            pageStack.push(todoPageComponent);
        }
    }

    // Note editor page component
    property Component noteEditPageComponent: Component {
        NoteEditPage {
            notesModel: notesModel

            onBackRequested: {
                pageStack.pop();
            }

            onSaveRequested: function (content) {
                console.log("Save requested with content length:", content ? content.length : 0);
            }
        }
    }

    // Add note page component
    property Component addNotePageComponent: Component {
        AddNotePage {
            notesModel: notesModel

            onSaveRequested: function (title, content, isRichText) {
                console.log("Main: Creating note from AddNotePage");
                notesModel.createNote(title, content, isRichText);
                pageStack.pop();
            }

            onBackRequested: {
                pageStack.pop();
            }
        }
    }

    // Todo page component
    Component {
        id: todoPageComponent
        ToDoView {
            onBackRequested: {
                pageStack.pop();
            }
        }
    }

    // Settings page component
    Component {
        id: settingsPageComponent
        SettingsPage {
            onBackRequested: {
                pageStack.pop();
            }
        }
    }

    // Keyboard shortcuts (for desktop)
    Shortcut {
        sequence: StandardKey.New
        onActivated: navigateToAddNote()
    }

    Shortcut {
        sequence: "Ctrl+T"
        onActivated: navigateToTodo()
    }

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    // Handle back button on mobile
    Connections {
        target: root
        function onApplicationStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive)
            // App became active
            {}
        }
    }

    Component.onCompleted: {
        console.log("NotesApp initialized successfully");
        console.log("Screen size:", width + "x" + height);
        console.log("Using PageStack navigation");
    }

    // Navigation helper functions
    function navigateToMainPage() {
        console.log("Navigating to main page");
        pageStack.clear();
        pageStack.push(mainPageComponent);
    }

    function navigateToAddNote() {
        console.log("Navigating to add note page");
        pageStack.push(addNotePageComponent);
    }

    function navigateToSettings() {
        console.log("Navigating to settings");
        pageStack.push(settingsPageComponent);
    }

    function navigateToTodo() {
        console.log("Navigating to todo");
        pageStack.push(todoPageComponent);
    }

    // Radial Navigation Menu
    RadialBottomEdge {
        id: radialNavigation
        mode: "Semihide"
        semiHideOpacity: 70
        timeoutSeconds: 3
        hintIconName: "view-grid-symbolic"

        actions: [
            RadialAction {
                iconName: "note"
                label: "Notes"
                onTriggered: {
                    navigateToMainPage();
                }
            },
            RadialAction {
                iconName: "add"
                label: "New Note"
                onTriggered: {
                    navigateToAddNote();
                }
            },
            RadialAction {
                iconName: "view-list-symbolic"
                label: "To-Do"
                onTriggered: {
                    navigateToTodo();
                }
            },
            RadialAction {
                iconName: "settings"
                label: "Settings"
                onTriggered: {
                    navigateToSettings();
                }
            }
        ]
    }
}
