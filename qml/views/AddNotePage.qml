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
import "components"
import "../common/constants"

// Full page for adding/editing notes
Page {
    id: addNotePage

    // Properties
    property var notesModel
    property bool isEditing: false
    property string initialTitle: ""
    property string initialContent: ""
    property bool initialIsRichText: false

    // Signals
    signal saveRequested(string title, string content, bool isRichText)
    signal backRequested()

    header: PageHeader {
        id: addNoteHeader
        title: isEditing ? i18n.tr("Edit Note") : i18n.tr("Add New Note")

        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Back")
                    onTriggered: {
                        backRequested()
                    }
                }
            ]
        }

        trailingActionBar {
            actions: [
                Action {
                    iconName: "ok"
                    text: i18n.tr("Save")
                    enabled: noteTitleField.text.trim() !== ""
                    onTriggered: {
                        saveNote()
                    }
                },
                Action {
                    iconName: "edit-clear"
                    text: i18n.tr("Clear")
                    onTriggered: {
                        clearFields()
                    }
                }
            ]
        }
    }

    // Main content area
    Flickable {
        id: contentFlickable
        anchors {
            top: addNoteHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: AppConstants.defaultMargin
        }
        contentHeight: contentColumn.height
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: AppConstants.defaultMargin

            // Enhanced title input
            TextField {
                id: noteTitleField
                Layout.fillWidth: true
                placeholderText: i18n.tr("💡 Enter note title...")
                text: initialTitle
                font.pixelSize: units.gu(2.2)
                
                // Focus on the title field when page loads
                Component.onCompleted: {
                    Qt.callLater(function() {
                        forceActiveFocus()
                    })
                }
            }

            // Enhanced rich text toggle with card design
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(6)
                color: theme.palette.normal.foreground
                border.color: theme.palette.normal.base
                border.width: units.dp(1)
                radius: units.gu(1)
                
                // Use anchors instead of Row for better control
                Icon {
                    id: toggleIcon
                    name: "edit"
                    width: units.gu(2.5)
                    height: units.gu(2.5)
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: units.gu(1.5)
                    color: theme.palette.normal.backgroundText
                }
                
                Label {
                    id: toggleLabel
                    text: i18n.tr("Rich Text Formatting")
                    anchors.left: toggleIcon.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: units.gu(2)
                    font.pixelSize: units.gu(1.8)
                    color: theme.palette.normal.backgroundText
                }
                
                Switch {
                    id: richTextSwitch
                    checked: initialIsRichText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: units.gu(1.5)
                    
                    // Add debugging
                    onCheckedChanged: {
                        console.log("Switch checked changed directly:", checked)
                    }
                    
                    Component.onCompleted: {
                        console.log("Switch completed with checked:", checked)
                    }
                }
            }

            // Enhanced content editor area with modern card design
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: units.gu(35)
                Layout.preferredHeight: Math.max(units.gu(35), contentFlickable.height - units.gu(30))
                color: theme.palette.normal.background
                border.color: theme.palette.normal.base
                border.width: units.dp(1)
                radius: units.gu(1)

                // Header bar for editor mode indication
                Rectangle {
                    id: editorHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: units.gu(4)
                    color: theme.palette.normal.foreground
                    radius: units.gu(1)
                    
                    // Only round top corners
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: units.gu(1)
                        color: parent.color
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: units.gu(1)
                        spacing: units.gu(1)

                        Icon {
                            name: richTextSwitch.checked ? "edit" : "edit-copy"
                            width: units.gu(2)
                            height: units.gu(2)
                            color: theme.palette.normal.backgroundText
                        }

                        Label {
                            text: richTextSwitch.checked ? 
                                  i18n.tr("Rich Text Editor") : 
                                  i18n.tr("Plain Text Editor")
                            font.pixelSize: units.gu(1.4)
                            color: theme.palette.normal.backgroundText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Content area
                Item {
                    anchors.top: editorHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: units.gu(1)

                    // Enhanced plain text editor
                    ScrollView {
                        id: plainTextScrollView
                        anchors.fill: parent
                        visible: !richTextSwitch.checked

                        TextArea {
                            id: plainTextArea
                            placeholderText: i18n.tr("✍️ Start writing your note here...")
                            text: initialContent
                            wrapMode: Text.WordWrap
                            selectByMouse: true
                            font.pixelSize: units.gu(1.8)
                        }
                    }

                    // Enhanced rich text editor container
                    Item {
                        id: richTextContainer
                        anchors.fill: parent
                        visible: richTextSwitch.checked

                        Loader {
                            id: richTextLoader
                            anchors.fill: parent
                            active: richTextSwitch.checked
                            visible: richTextSwitch.checked

                            sourceComponent: Component {
                                RichTextEditor {
                                    id: richTextEditor
                                    editMode: true
                                    initialText: initialContent
                                    fontSize: units.gu(1.8)
                                    backgroundColor: "transparent"
                                    
                                    onContentChanged: {
                                        // Auto-save content changes
                                        console.log("Rich text content changed")
                                    }
                                    
                                    Component.onCompleted: {
                                        console.log("RichTextEditor component completed")
                                        focusEditor()
                                    }
                                }
                            }

                            onLoaded: {
                                console.log("RichTextLoader loaded, switch checked:", richTextSwitch.checked)
                                if (richTextSwitch.checked) {
                                    item.initialText = initialContent
                                    if (initialContent) {
                                        item.text = initialContent
                                    }
                                }
                            }
                            
                            onActiveChanged: {
                                console.log("RichTextLoader active changed to:", active)
                            }
                        }
                    }
                }

                // Handle mode switching with proper target
                Connections {
                    target: richTextSwitch
                    function onCheckedChanged() {
                        console.log("Rich text switch changed to:", richTextSwitch.checked)
                        
                        if (richTextSwitch.checked) {
                            // Switching to rich text - transfer plain text content
                            console.log("Switching to rich text mode")
                            if (richTextLoader.status === Loader.Ready && plainTextArea.text) {
                                console.log("Transferring content to rich text:", plainTextArea.text.length, "characters")
                                richTextLoader.item.text = plainTextArea.text
                            }
                        } else {
                            // Switching to plain text - transfer rich text content
                            console.log("Switching to plain text mode")
                            if (richTextLoader.status === Loader.Ready && richTextLoader.item) {
                                var richContent = richTextLoader.item.text || ""
                                console.log("Transferring content to plain text:", richContent.length, "characters")
                                plainTextArea.text = richContent
                            }
                        }
                    }
                }
            }

            // Status and action bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(5)
                color: theme.palette.normal.foreground
                border.color: theme.palette.normal.base
                border.width: units.dp(1)
                radius: units.gu(1)

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(1)
                    spacing: units.gu(2)

                    Icon {
                        name: "info"
                        width: units.gu(2)
                        height: units.gu(2)
                        color: theme.palette.normal.backgroundText
                    }

                    Label {
                        text: {
                            var charCount = 0
                            if (richTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                                charCount = (richTextLoader.item.text || "").length
                            } else {
                                charCount = plainTextArea.text.length
                            }
                            return i18n.tr("Characters: %1").arg(charCount)
                        }
                        font.pixelSize: units.gu(1.3)
                        color: theme.palette.normal.backgroundText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: units.gu(1)
                    spacing: units.gu(1)

                    Button {
                        text: i18n.tr("Preview")
                        width: units.gu(10)
                        height: units.gu(3.5)
                        enabled: richTextSwitch.checked && richTextLoader.status === Loader.Ready
                        onClicked: {
                            // Could show a preview dialog
                            console.log("Preview requested")
                        }
                    }
                }
            }
        }
    }

    // Enhanced functions with better user feedback
    function saveNote() {
        if (noteTitleField.text.trim() === "") {
            // Could show a notification here
            console.log("AddNotePage: Cannot save - title is required")
            noteTitleField.forceActiveFocus()
            return
        }

        var content = ""
        var wordCount = 0
        
        if (richTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
            content = richTextLoader.item.text || ""
        } else {
            content = plainTextArea.text || ""
        }
        
        // Calculate word count for logging
        wordCount = content.trim().split(/\s+/).length
        if (content.trim() === "") wordCount = 0

        console.log("AddNotePage: Saving note - Title:", noteTitleField.text, 
                   "Content length:", content.length, "Words:", wordCount, 
                   "Rich text:", richTextSwitch.checked)
        
        saveRequested(noteTitleField.text.trim(), content, richTextSwitch.checked)
    }

    function clearFields() {
        noteTitleField.text = ""
        plainTextArea.text = ""
        richTextSwitch.checked = false
        
        // Clear rich text editor if loaded
        if (richTextLoader.status === Loader.Ready && richTextLoader.item) {
            richTextLoader.item.clear()
            richTextLoader.item.text = ""
        }
        
        // Focus on title field after clearing
        Qt.callLater(function() {
            noteTitleField.forceActiveFocus()
        })
        
        console.log("AddNotePage: Fields cleared")
    }

    // New function to get current content for status display
    function getCurrentContent() {
        if (richTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
            return richTextLoader.item.text || ""
        } else {
            return plainTextArea.text || ""
        }
    }

    // Keyboard shortcuts
    Shortcut {
        sequence: StandardKey.Save
        onActivated: saveNote()
    }

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: backRequested()
    }

    // Initialize fields when page properties change
    onInitialTitleChanged: noteTitleField.text = initialTitle
    onInitialContentChanged: {
        plainTextArea.text = initialContent
        if (richTextLoader.status === Loader.Ready && richTextLoader.item) {
            richTextLoader.item.text = initialContent
        }
    }
    onInitialIsRichTextChanged: richTextSwitch.checked = initialIsRichText
}
