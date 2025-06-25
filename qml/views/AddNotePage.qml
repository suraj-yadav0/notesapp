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

            // Title input
            TextField {
                id: noteTitleField
                Layout.fillWidth: true
                placeholderText: i18n.tr("Enter note title...")
                text: initialTitle
                font.pixelSize: units.gu(2)
                
                // Focus on the title field when page loads
                Component.onCompleted: {
                    Qt.callLater(function() {
                        forceActiveFocus()
                    })
                }
            }

            // Rich text toggle
            Row {
                Layout.fillWidth: true
                spacing: AppConstants.defaultMargin
                
                Label {
                    text: i18n.tr("Rich Text Format:")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: units.gu(1.8)
                }
                
                Switch {
                    id: richTextSwitch
                    checked: initialIsRichText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Content editor area
            Item {
                Layout.fillWidth: true
                Layout.minimumHeight: units.gu(30)
                Layout.preferredHeight: Math.max(units.gu(30), contentFlickable.height - units.gu(15))

                // Plain text editor
                ScrollView {
                    id: plainTextScrollView
                    anchors.fill: parent
                    visible: !richTextSwitch.checked

                    TextArea {
                        id: plainTextArea
                        placeholderText: i18n.tr("Start writing your note here...")
                        text: initialContent
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        font.pixelSize: units.gu(1.6)
                    }
                }

                // Rich text editor container
                Rectangle {
                    id: richTextContainer
                    anchors.fill: parent
                    visible: richTextSwitch.checked
                    border.width: 1
                    border.color: theme.palette.normal.baseText
                    color: theme.palette.normal.background
                    radius: units.gu(0.5)

                    Loader {
                        id: richTextLoader
                        anchors.fill: parent
                        anchors.margins: units.gu(1)
                        active: richTextSwitch.checked
                        visible: richTextSwitch.checked

                        sourceComponent: Component {
                            RichTextEditor {
                                id: richTextEditor
                                editMode: true
                            }
                        }

                        onLoaded: {
                            if (richTextSwitch.checked && initialContent) {
                                item.text = initialContent
                            }
                        }
                    }
                }

                // Handle mode switching
                Connections {
                    target: richTextSwitch
                    onCheckedChanged: {
                        if (richTextSwitch.checked) {
                            // Switching to rich text - transfer plain text content
                            if (richTextLoader.status === Loader.Ready && plainTextArea.text) {
                                richTextLoader.item.text = plainTextArea.text
                            }
                        } else {
                            // Switching to plain text - transfer rich text content
                            if (richTextLoader.status === Loader.Ready && richTextLoader.item) {
                                plainTextArea.text = richTextLoader.item.text || ""
                            }
                        }
                    }
                }
            }

            // Optional: Add some spacing at the bottom for better scrolling
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: AppConstants.defaultMargin * 2
            }
        }
    }

    // Functions
    function saveNote() {
        if (noteTitleField.text.trim() === "") {
            return
        }

        var content = ""
        if (richTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
            content = richTextLoader.item.text || ""
        } else {
            content = plainTextArea.text || ""
        }

        console.log("AddNotePage: Saving note - Title:", noteTitleField.text, "Content length:", content.length, "Rich text:", richTextSwitch.checked)
        saveRequested(noteTitleField.text.trim(), content, richTextSwitch.checked)
    }

    function clearFields() {
        noteTitleField.text = ""
        plainTextArea.text = ""
        richTextSwitch.checked = false
        if (richTextLoader.item) {
            richTextLoader.item.text = ""
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
