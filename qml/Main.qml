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
import QtQuick.Controls 2.2 as QC2

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

    theme.palette: Palette {
         // color: "#131520"
    }

    // Models (now include controller functionality)
    NotesModel {
        id: notesModel
    }

    // Create page instances (will be managed by AdaptivePageLayout)
    property var todoPage: null
    property var settingsPageInstance: null

    AdaptivePageLayout {
        id: pageLayout
        anchors.fill: parent
        primaryPage: mainPage

        // Define computed properties for better readability
        readonly property bool isTabletMode: width > AppConstants.phoneMaxWidth && width < AppConstants.tabletMaxWidth
        readonly property bool isDesktopMode: width >= AppConstants.tabletMaxWidth
        readonly property bool isPhoneMode: width <= AppConstants.phoneMaxWidth

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
            notesModel: notesModel

            onEditNoteRequested: function(noteId) {
                noteEditPage.noteId = noteId
                if (pageLayout.isPhoneMode) {
                    pageLayout.addPageToCurrentColumn(mainPage, noteEditPage)
                } else {
                    pageLayout.addPageToNextColumn(mainPage, noteEditPage)
                }
                noteEditPageActive = true
            }

            onAddNoteRequested: {
                navigateToAddNote()
            }

            onTodoViewRequested: {
                navigateToTodo()
            }
        }

        // Note editor page
        NoteEditPage {
            id: noteEditPage
            notesModel: notesModel

            property string noteId: ""

            onBackRequested: {
                pageLayout.removePages(noteEditPage)
                noteEditPageActive = false
            }

            onSaveRequested: function(content) {
                notesModel.saveNote(noteId, content)
            }
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

    // Navigation state management
    property bool settingsPageActive: false
    property bool todoPageActive: false
    property bool noteEditPageActive: false
    property bool addNotePageActive: false

    // Page instances
    ToDoView {
        id: todoPageInstance
        visible: false
    }
    
    SettingsPage {
        id: settingsPageInstance
        visible: false
    }

    AddNotePage {
        id: addNotePageInstance
        visible: false
        notesModel: notesModel

        onSaveRequested: function(title, content, isRichText) {
            console.log("Main: Creating note from AddNotePage")
            notesModel.createNote(title, content, isRichText)
            navigateToMainPage()
        }

        onBackRequested: {
            navigateToMainPage()
        }
    }

    // Navigation helper functions
    function navigateToMainPage() {
        console.log("Navigating to main page")
        // Clear all state first
        settingsPageActive = false
        todoPageActive = false
        noteEditPageActive = false
        addNotePageActive = false
        
        // Remove any additional pages to show just the main page
        try {
            if (settingsPageInstance) {
                pageLayout.removePages(settingsPageInstance)
            }
            if (todoPageInstance) {
                pageLayout.removePages(todoPageInstance)
            }
            if (noteEditPage) {
                pageLayout.removePages(noteEditPage)
            }
            if (addNotePageInstance) {
                pageLayout.removePages(addNotePageInstance)
            }
        } catch (e) {
            console.log("Main page navigation cleanup error:", e)
        }
    }

    function navigateToAddNote() {
        console.log("Navigating to add note page")
        if (!addNotePageActive) {
            try {
                // Clear other pages first
                if (settingsPageActive) {
                    pageLayout.removePages(settingsPageInstance)
                    settingsPageActive = false
                }
                if (todoPageActive) {
                    pageLayout.removePages(todoPageInstance)
                    todoPageActive = false
                }
                if (noteEditPageActive) {
                    pageLayout.removePages(noteEditPage)
                    noteEditPageActive = false
                }
                
                // Reset add note page
                addNotePageInstance.isEditing = false
                addNotePageInstance.initialTitle = ""
                addNotePageInstance.initialContent = ""
                addNotePageInstance.initialIsRichText = false
                addNotePageInstance.clearFields()
                
                // Add the page
                if (pageLayout.isPhoneMode) {
                    pageLayout.addPageToCurrentColumn(mainPage, addNotePageInstance)
                } else {
                    pageLayout.addPageToNextColumn(mainPage, addNotePageInstance)
                }
                addNotePageActive = true
            } catch (e) {
                console.log("Add note navigation error:", e)
            }
        }
    }

    function navigateToSettings() {
        console.log("Navigating to settings")
        if (!settingsPageActive) {
            try {
                // Clear other pages first if they're active
                if (todoPageActive) {
                    pageLayout.removePages(todoPageInstance)
                    todoPageActive = false
                }
                if (noteEditPageActive) {
                    pageLayout.removePages(noteEditPage)
                    noteEditPageActive = false
                }
                
                // Add settings page
                if (pageLayout.isPhoneMode) {
                    pageLayout.addPageToCurrentColumn(mainPage, settingsPageInstance)
                } else {
                    pageLayout.addPageToNextColumn(mainPage, settingsPageInstance)
                }
                settingsPageActive = true
            } catch (e) {
                console.log("Settings navigation error:", e)
            }
        } else {
            console.log("Settings page already active")
        }
    }

    function navigateToTodo() {
        console.log("Navigating to todo")
        if (!todoPageActive) {
            try {
                // Clear other pages first if they're active
                if (settingsPageActive) {
                    pageLayout.removePages(settingsPageInstance)
                    settingsPageActive = false
                }
                if (noteEditPageActive) {
                    pageLayout.removePages(noteEditPage)
                    noteEditPageActive = false
                }
                
                // Add todo page
                if (pageLayout.isDesktopMode) {
                    pageLayout.addPageToNextColumn(mainPage, todoPageInstance)
                } else if (pageLayout.isTabletMode) {
                    pageLayout.addPageToNextColumn(mainPage, todoPageInstance) 
                } else {
                    pageLayout.addPageToCurrentColumn(mainPage, todoPageInstance)
                }
                todoPageActive = true
            } catch (e) {
                console.log("Todo navigation error:", e)
            }
        } else {
            console.log("Todo page already active")
        }
    }

    // Radial Navigation Menu
    RadialBottomEdge {
        id: radialNavigation
        mode: "Semihide"
        semiHideOpacity: 70
        timeoutSeconds: 3
        hintIconName: "navigation-menu"
        
        actions: [
            RadialAction {
                iconName: "note"
                label: "Notes"
                onTriggered: {
                    navigateToMainPage()
                }
            },
            RadialAction {
                iconName: "add"
                label: "New Note"
                onTriggered: {
                    navigateToAddNote()
                }
            },
            RadialAction {
                iconName: "view-list-symbolic"
                label: "To-Do"
                onTriggered: {
                    navigateToTodo()
                }
            },
            RadialAction {
                iconName: "settings"
                label: "Settings"
                onTriggered: {
                    navigateToSettings()
                }
            }
        ]
    }
}