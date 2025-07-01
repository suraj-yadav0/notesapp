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

Page {
    id: noteEditPage

    // Properties
    property var notesModel

    // Signals
    signal backRequested
    signal saveRequested(var content)

    header: PageHeader {
        id: editHeader
        title: i18n.tr('Edit Note')

        leadingActionBar {
            actions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Back")
                    onTriggered: {
                        backRequested();
                    }
                }
            ]
        }

        trailingActionBar {
            actions: [
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: {
                        notesModel.deleteCurrentNote();
                        backRequested();
                    }
                },
                Action {
                    iconName: "ok"
                    text: i18n.tr("Save")
                    enabled: titleEditField.text.trim() !== ""
                    onTriggered: {
                        saveNote();
                    }
                }
            ]
        }
    }

    // Main content area
    Flickable {
        id: contentFlickable
        anchors {
            top: editHeader.bottom
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
                id: titleEditField
                Layout.fillWidth: true
                placeholderText: i18n.tr("💡 Enter note title...")
                text: notesModel.currentNote ? notesModel.currentNote.title : ""
                font.pixelSize: units.gu(2.2)

                // Focus on the title field when page loads
                Component.onCompleted: {
                    Qt.callLater(function () {
                        forceActiveFocus();
                    });
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
                    id: isRichTextSwitch
                    checked: notesModel.currentNote ? (notesModel.currentNote.isRichText || false) : false
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: units.gu(1.5)

                    // Add debugging
                    onCheckedChanged: {
                        console.log("Edit page: Switch checked changed directly:", checked);
                    }

                    Component.onCompleted: {
                        console.log("Edit page: Switch completed with checked:", checked);
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
                            name: isRichTextSwitch.checked ? "edit" : "edit-copy"
                            width: units.gu(2)
                            height: units.gu(2)
                            color: theme.palette.normal.backgroundText
                        }

                        Label {
                            text: isRichTextSwitch.checked ? i18n.tr("Rich Text Editor") : i18n.tr("Plain Text Editor")
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
                      //  anchors.fill: parent
                        clip: true
                        anchors.fill: parent
                        visible: !isRichTextSwitch.checked

                        TextArea {
                            id: plainTextArea
                            enabled: true
                            placeholderText: i18n.tr("✍️ Start editing your note here.....")
                            text: notesModel.currentNote ? notesModel.currentNote.content : ""
                            width: units.gu(45) // Adjust width to fill parent with margins
                            height: Math.max(units.gu(40), contentHeight + units.gu(2))
                           // autoSize: true
                            wrapMode: TextArea.Wrap
                            selectByMouse: true
                            font.pixelSize: units.gu(1.8)

                            // Custom styling for border highlighting
                            Rectangle {
                                id: borderRect
                                anchors.fill: parent
                                color: "transparent"
                                radius: units.gu(0.5)
                                border.width: parent.activeFocus ? units.gu(0.2) : units.gu(0.1)
                                border.color: parent.activeFocus ? "#69181f81" : (theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#d3d1d1" : "#999")
                              // z: -1
                            }
                        }
                    }

                    // Enhanced rich text editor container
                    Item {
                        id: richTextContainer
                        anchors.fill: parent
                        visible: isRichTextSwitch.checked

                        Loader {
                            id: richTextLoader
                            anchors.fill: parent
                            active: isRichTextSwitch.checked
                            visible: isRichTextSwitch.checked

                            sourceComponent: Component {
                                RichTextEditor {
                                    id: richTextEditor
                                    editMode: true
                                    initialText: notesModel.currentNote ? notesModel.currentNote.content : ""
                                    fontSize: units.gu(1.8)
                                    backgroundColor: "transparent"

                                    onContentChanged: {
                                        // Auto-save content changes
                                        console.log("Edit page: Rich text content changed");
                                    }

                                    Component.onCompleted: {
                                        console.log("Edit page: RichTextEditor component completed");
                                        focusEditor();
                                    }
                                }
                            }

                            onLoaded: {
                                console.log("Edit page: RichTextLoader loaded, switch checked:", isRichTextSwitch.checked);
                                if (isRichTextSwitch.checked && notesModel.currentNote) {
                                    var currentContent = notesModel.currentNote.content || "";
                                    item.initialText = currentContent;
                                    if (currentContent) {
                                        item.text = currentContent;
                                    }
                                    item.focusEditor();
                                }
                            }

                            onActiveChanged: {
                                console.log("Edit page: RichTextLoader active changed to:", active);
                            }
                        }
                    }
                }

                // Handle mode switching with proper target
                Connections {
                    target: isRichTextSwitch
                    function onCheckedChanged() {
                        console.log("Edit page: Rich text switch changed to:", isRichTextSwitch.checked);

                        if (isRichTextSwitch.checked) {
                            // Switching to rich text - transfer plain text content
                            console.log("Edit page: Switching to rich text mode");
                            if (richTextLoader.status === Loader.Ready && plainTextArea.text) {
                                console.log("Edit page: Transferring content to rich text:", plainTextArea.text.length, "characters");
                                richTextLoader.item.text = plainTextArea.text;
                            }
                        } else {
                            // Switching to plain text - transfer rich text content
                            console.log("Edit page: Switching to plain text mode");
                            if (richTextLoader.status === Loader.Ready && richTextLoader.item) {
                                var richContent = richTextLoader.item.text || "";
                                console.log("Edit page: Transferring content to plain text:", richContent.length, "characters");
                                plainTextArea.text = richContent;
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
                            var charCount = 0;
                            if (isRichTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                                charCount = (richTextLoader.item.text || "").length;
                            } else {
                                charCount = plainTextArea.text.length;
                            }
                            return i18n.tr("Characters: %1").arg(charCount);
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

                    Label {
                        text: isRichTextSwitch.checked ? i18n.tr("Rich Text") : i18n.tr("Plain Text")
                        font.pixelSize: units.gu(1.2)
                        color: theme.palette.normal.backgroundText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        name: isRichTextSwitch.checked ? "edit" : "edit-copy"
                        width: units.gu(1.5)
                        height: units.gu(1.5)
                        color: theme.palette.normal.backgroundText
                    }
                }
            }
        }
    }

    // Enhanced save function
    function saveNote() {
        if (!notesModel.currentNote) {
            console.error("Edit page: No current note to save");
            return;
        }

        var content = isRichTextSwitch.checked ? (richTextLoader.item ? richTextLoader.item.text : "") : plainTextArea.text;

        console.log("Edit page: Saving note with title:", titleEditField.text);
        console.log("Edit page: Content length:", content.length);
        console.log("Edit page: Is rich text:", isRichTextSwitch.checked);

        if (notesModel.updateCurrentNote(titleEditField.text, content, isRichTextSwitch.checked)) {
            console.log("Edit page: Note updated successfully");
            saveRequested(content);
            backRequested();
        } else {
            console.error("Edit page: Failed to update note");
        }
    }

    // Clear fields function
    function clearFields() {
        titleEditField.text = "";
        plainTextArea.text = "";
        if (richTextLoader.status === Loader.Ready && richTextLoader.item) {
            richTextLoader.item.text = "";
        }
    }

    // Update fields when current note changes
    Connections {
        target: notesModel
        function onNoteSelectionChanged() {
            console.log("Edit page: Note selection changed");
            if (notesModel.currentNote) {
                titleEditField.text = notesModel.currentNote.title || "";
                isRichTextSwitch.checked = notesModel.currentNote.isRichText || false;

                var currentContent = notesModel.currentNote.content || "";
                console.log("Edit page: Loading content:", currentContent.length, "characters");

                if (isRichTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                    richTextLoader.item.text = currentContent;
                    richTextLoader.item.forceActiveFocus();
                } else {
                    plainTextArea.text = currentContent;
                }
            }
        
    
        }}}