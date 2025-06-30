import QtQuick 2.9
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

Item {
    id: richTextEditor
    width: parent ? parent.width : 400
    height: parent ? parent.height : 300

    property bool editMode: true
    property alias text: textArea.text
    property alias readOnly: textArea.readOnly
    property int fontSize: units.gu(2)
    property string initialText: ""
    property color textColor: theme.palette.normal.baseText
    property color backgroundColor: theme.palette.normal.background

    // Current formatting state
    property bool currentBold: false
    property bool currentItalic: false
    property bool currentUnderline: false
    property int currentFontSize: fontSize
    property color currentTextColor: textColor

    signal contentChanged(string text)
    signal selectionChanged()

    // Public API functions
    function selectAll() { textArea.selectAll() }
    function clear() { textArea.text = "" }
    function copy() { textArea.copy() }
    function paste() { textArea.paste() }
    function cut() { textArea.cut() }
    function undo() { textArea.undo() }
    function redo() { textArea.redo() }
    function setText(content) { textArea.text = content || "" }
    function getText() { return textArea.text }
    function focusEditor() { textArea.forceActiveFocus() }

    Component.onCompleted: {
        if (initialText) {
            textArea.text = initialText
        }
        Qt.callLater(function() {
            if (editMode) {
                textArea.forceActiveFocus()
            }
        })
    }

    onInitialTextChanged: {
        if (initialText !== undefined && textArea && textArea.text !== initialText) {
            textArea.text = initialText
        }
    }

    Rectangle {
        anchors.fill: parent
        color: backgroundColor
        border.color: theme.palette.normal.base
        border.width: units.dp(1)
        radius: units.gu(0.5)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: units.gu(0.5)
            spacing: units.gu(1)

            // Formatting Toolbar
            Rectangle {
                visible: editMode
                Layout.fillWidth: true
                Layout.preferredHeight: units.gu(6)
                color: theme.palette.normal.foreground
                border.color: theme.palette.normal.base
                border.width: units.dp(1)
                radius: units.gu(0.5)

                Flickable {
                    anchors.fill: parent
                    anchors.margins: units.gu(0.5)
                    contentWidth: toolbarRow.width
                    flickableDirection: Flickable.HorizontalFlick
                    
                    Row {
                        id: toolbarRow
                        spacing: units.gu(0.5)
                        height: parent.height

                        // Bold Button
                        Button {
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "B"
                            font.bold: true
                            color: currentBold ? theme.palette.selected.backgroundText : theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("bold", !currentBold)
                                textArea.forceActiveFocus()
                            }
                        }

                        // Italic Button
                        Button {
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "I"
                            font.italic: true
                            color: currentItalic ? theme.palette.selected.backgroundText : theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("italic", !currentItalic)
                                textArea.forceActiveFocus()
                            }
                        }

                        // Underline Button
                        Button {
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "U"
                            font.underline: true
                            color: currentUnderline ? theme.palette.selected.backgroundText : theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("underline", !currentUnderline)
                                textArea.forceActiveFocus()
                            }
                        }

                        // Header Buttons
                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "H1"
                            font.bold: true
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("header1")
                                textArea.forceActiveFocus()
                            }
                        }

                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "H2"
                            font.bold: true
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("header2")
                                textArea.forceActiveFocus()
                            }
                        }

                        Button {
                            width: units.gu(8)
                            height: units.gu(4)
                            text: "Normal"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("normal")
                                textArea.forceActiveFocus()
                            }
                        }

                        // Clear Formatting
                        Button {
                            width: units.gu(7)
                            height: units.gu(4)
                            text: "Clear"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                applyFormatting("clear")
                                textArea.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            // Text Editor Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: theme.palette.normal.background
                border.color: theme.palette.normal.base
                border.width: units.dp(1)
                radius: units.gu(0.5)

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    TextArea {
                        id: textArea
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.RichText
                        selectByMouse: true
                        readOnly: !editMode
                        
                        font.family: "Ubuntu"
                        
                        placeholderText: i18n.tr("Start typing your text here...")
                        
                        onTextChanged: {
                            richTextEditor.contentChanged(text)
                        }
                        
                        onSelectionStartChanged: detectFormattingAtCursor()
                        onSelectionEndChanged: detectFormattingAtCursor()
                        onCursorPositionChanged: detectFormattingAtCursor()
                        
                        // Keyboard shortcuts
                        Keys.onPressed: function(event) {
                            if (event.modifiers & Qt.ControlModifier) {
                                switch (event.key) {
                                    case Qt.Key_B:
                                        applyFormatting("bold", !currentBold)
                                        event.accepted = true
                                        break
                                    case Qt.Key_I:
                                        applyFormatting("italic", !currentItalic)
                                        event.accepted = true
                                        break
                                    case Qt.Key_U:
                                        applyFormatting("underline", !currentUnderline)
                                        event.accepted = true
                                        break
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Enhanced JavaScript formatting functions
    function applyFormatting(formatType, value) {
        var selectedText = getSelectedText()
        var hasSelection = selectedText.length > 0
        
        if (hasSelection) {
            applyFormattingToSelection(formatType, value)
        } else {
            applyFormattingAtCursor(formatType, value)
        }
        
        detectFormattingAtCursor()
    }
    
    function getSelectedText() {
        // Try to get selected text - this might work differently depending on TextArea implementation
        if (textArea.selectedText !== undefined) {
            return textArea.selectedText
        }
        
        // Fallback: extract selection based on cursor positions
        var start = textArea.selectionStart || 0
        var end = textArea.selectionEnd || 0
        if (start !== end) {
            return textArea.text.substring(start, end)
        }
        
        return ""
    }
    
    function applyFormattingToSelection(formatType, value) {
        var fullText = textArea.text
        var selectedText = getSelectedText()
        
        if (selectedText.length === 0) return
        
        var formattedText = wrapTextWithHtml(selectedText, formatType, value)
        
        // Replace the selected text with formatted version
        var newText = fullText.replace(selectedText, formattedText)
        textArea.text = newText
        
        console.log("Applied", formatType, "to selection:", selectedText)
    }
    
    function applyFormattingAtCursor(formatType, value) {
        // When no selection, we can set the state for future typing
        // or apply to the entire document (fallback)
        
        switch (formatType) {
            case "bold":
                currentBold = value !== undefined ? value : !currentBold
                break
            case "italic":
                currentItalic = value !== undefined ? value : !currentItalic
                break
            case "underline":
                currentUnderline = value !== undefined ? value : !currentUnderline
                break
            case "header1":
                currentBold = true
                currentFontSize = units.gu(3)
                break
            case "header2":
                currentBold = true
                currentFontSize = units.gu(2.5)
                break
            case "normal":
                currentBold = false
                currentItalic = false
                currentUnderline = false
                currentFontSize = fontSize
                break
            case "clear":
                currentBold = false
                currentItalic = false
                currentUnderline = false
                currentFontSize = fontSize
                break
        }
        
        console.log("Set formatting state for cursor:", formatType)
    }
    
    function wrapTextWithHtml(text, formatType, value) {
        // Remove existing formatting first
        text = stripHtmlTags(text)
        
        switch (formatType) {
            case "bold":
                return value ? "<b>" + text + "</b>" : text
            case "italic":
                return value ? "<i>" + text + "</i>" : text
            case "underline":
                return value ? "<u>" + text + "</u>" : text
            case "header1":
                return "<h1>" + text + "</h1>"
            case "header2":
                return "<h2>" + text + "</h2>"
            case "normal":
                return "<p>" + text + "</p>"
            case "clear":
                return text
            default:
                return text
        }
    }
    
    function stripHtmlTags(text) {
        // Simple HTML tag removal - you might want to make this more sophisticated
        return text.replace(/<[^>]*>/g, "")
    }
    
    function detectFormattingAtCursor() {
        // Try to detect current formatting state based on cursor position
        // This is a simplified implementation
        
        var cursorPos = textArea.cursorPosition || 0
        var text = textArea.text
        
        // Look for HTML tags around cursor position
        var beforeCursor = text.substring(0, cursorPos)
        var afterCursor = text.substring(cursorPos)
        
        // Simple detection (you might want to make this more robust)
        currentBold = beforeCursor.includes("<b>") && !beforeCursor.includes("</b>")
        currentItalic = beforeCursor.includes("<i>") && !beforeCursor.includes("</i>")
        currentUnderline = beforeCursor.includes("<u>") && !beforeCursor.includes("</u>")
        
        richTextEditor.selectionChanged()
    }
}
