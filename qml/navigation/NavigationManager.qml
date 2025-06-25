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

pragma Singleton
import QtQuick 2.9
import Lomiri.Components 1.3
import "../common/constants"

QtObject {
    id: navigationManager
    
    // Navigation state tracking
    property bool settingsPageActive: false
    property bool todoPageActive: false
    property bool noteEditPageActive: false
    
    // Page references (should be set by Main.qml)
    property var pageLayout: null
    property var mainPage: null
    property var settingsPageInstance: null
    property var todoPageInstance: null
    property var noteEditPage: null
    
    /**
     * Navigate to main page and clear all other pages
     */
    function navigateToMainPage() {
        console.log("NavigationManager: Navigating to main page")
        _clearAllState()
        _removeAllPages()
    }
    
    /**
     * Navigate to settings page
     */
    function navigateToSettings() {
        console.log("NavigationManager: Navigating to settings")
        if (settingsPageActive || !settingsPageInstance) {
            console.log("Settings page already active or not available")
            return
        }
        
        try {
            _clearOtherPages(["settings"])
            _addPage(settingsPageInstance, "settings")
            settingsPageActive = true
        } catch (e) {
            console.log("Settings navigation error:", e)
        }
    }
    
    /**
     * Navigate to todo page
     */
    function navigateToTodo() {
        console.log("NavigationManager: Navigating to todo")
        if (todoPageActive || !todoPageInstance) {
            console.log("Todo page already active or not available")
            return
        }
        
        try {
            _clearOtherPages(["todo"])
            _addPage(todoPageInstance, "todo")
            todoPageActive = true
        } catch (e) {
            console.log("Todo navigation error:", e)
        }
    }
    
    /**
     * Navigate to note edit page
     */
    function navigateToNoteEdit(noteId) {
        console.log("NavigationManager: Navigating to note edit for:", noteId)
        if (!noteEditPage) {
            console.log("Note edit page not available")
            return
        }
        
        try {
            noteEditPage.noteId = noteId
            _clearOtherPages(["noteEdit"])
            _addPage(noteEditPage, "noteEdit")
            noteEditPageActive = true
        } catch (e) {
            console.log("Note edit navigation error:", e)
        }
    }
    
    /**
     * Get current layout mode
     */
    function getLayoutMode() {
        if (!pageLayout) return "phone"
        
        if (pageLayout.width >= AppConstants.tabletMaxWidth) {
            return "desktop"
        } else if (pageLayout.width > AppConstants.phoneMaxWidth) {
            return "tablet"
        } else {
            return "phone"
        }
    }
    
    // Private helper functions
    function _clearAllState() {
        settingsPageActive = false
        todoPageActive = false
        noteEditPageActive = false
    }
    
    function _clearOtherPages(keepPages) {
        if (keepPages.indexOf("settings") === -1 && settingsPageActive) {
            pageLayout.removePages(settingsPageInstance)
            settingsPageActive = false
        }
        if (keepPages.indexOf("todo") === -1 && todoPageActive) {
            pageLayout.removePages(todoPageInstance)
            todoPageActive = false
        }
        if (keepPages.indexOf("noteEdit") === -1 && noteEditPageActive) {
            pageLayout.removePages(noteEditPage)
            noteEditPageActive = false
        }
    }
    
    function _removeAllPages() {
        try {
            if (settingsPageInstance) pageLayout.removePages(settingsPageInstance)
            if (todoPageInstance) pageLayout.removePages(todoPageInstance)
            if (noteEditPage) pageLayout.removePages(noteEditPage)
        } catch (e) {
            console.log("Page removal error:", e)
        }
    }
    
    function _addPage(page, pageType) {
        var layoutMode = getLayoutMode()
        
        if (layoutMode === "phone") {
            pageLayout.addPageToCurrentColumn(mainPage, page)
        } else {
            pageLayout.addPageToNextColumn(mainPage, page)
        }
    }
}
