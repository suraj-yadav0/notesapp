import QtQuick 2.9
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

Item {
    id: richTextEditor
    width: parent ? parent.width : 400
    height: parent ? parent.height : 300

    property bool editMode: true
    property alias text: textArea.text
    property alias textFormat: textArea.textFormat
    property alias readOnly: textArea.readOnly
    property int fontSize: units.gu(2)
    property string initialText: ""
    property color textColor: theme.palette.normal.baseText
    property color backgroundColor: theme.palette.normal.background

    // Formatting state tracking
    property bool currentBold: false
    property bool currentItalic: false
    property bool currentUnderline: false
    property int currentFontSize: fontSize
    property color currentTextColor: textColor

    signal contentChanged(string text)
    signal selectionChanged()

    function selectAll() { textArea.selectAll() }
    function clear() { textArea.clear() }
    function copy() { textArea.copy() }
    function paste() { textArea.paste() }
    function cut() { textArea.cut() }
    function undo() { textArea.undo() }
    function redo() { textArea.redo() }

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

    // Formatting state tracking
    property bool currentBold: false
    property bool currentItalic: false
    property bool currentUnderline: false
    property int currentFontSize: fontSize
    property color currentTextColor: textColor

    signal contentChanged(string text)
    signal selectionChanged()

    // Public API functions
    function selectAll() { textArea.selectAll() }
    function clear() { textArea.clear() }
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
                            id: boldButton
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "B"
                            font.bold: true
                            color: currentBold ? theme.palette.selected.backgroundText : theme.palette.normal.backgroundText
                            
                            onClicked: {
                                toggleBold()
                                textArea.forceActiveFocus()
                            }
                        }

                        // Italic Button
                        Button {
                            id: italicButton
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "I"
                            font.italic: true
                            color: currentItalic ? theme.palette.selected.backgroundText : theme.palette.normal.backgroundText
                            
                            onClicked: {
                                toggleItalic()
                                textArea.forceActiveFocus()
                            }
                        }

                        // Underline Button
                        Button {
                            id: underlineButton
                            width: units.gu(5)
                            height: units.gu(4)
                            text: "U"
                            font.underline: true
                            color: currentUnderline ? theme.palette.selected.backgroundText : theme.palette.normal.backgroundText
                            
                            onClicked: {
                                toggleUnderline()
                                textArea.forceActiveFocus()
                            }
                        }

                        // Font Size Selector
                        OptionSelector {
                            id: fontSizeSelector
                            width: units.gu(10)
                            height: units.gu(4)
                            model: [12, 14, 16, 18, 20, 24, 28, 32]
                            selectedIndex: 2 // Default to 16
                            containerHeight: units.gu(20)
                            
                            onSelectedIndexChanged: {
                                if (selectedIndex >= 0 && selectedIndex < model.length) {
                                    setFontSize(model[selectedIndex])
                                }
                            }
                        }

                        // Font Size Buttons (Alternative to selector)
                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "H1"
                            font.bold: true
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                setFontSize(Math.round(fontSize * 2))
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
                                setFontSize(Math.round(fontSize * 1.5))
                                textArea.forceActiveFocus()
                            }
                        }

                        Button {
                            width: units.gu(8)
                            height: units.gu(4)
                            text: "Normal"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                setFontSize(fontSize)
                                textArea.forceActiveFocus()
                            }
                        }

                        // List Button
                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "List"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                insertBulletList()
                                textArea.forceActiveFocus()
                            }
                        }

                        // Color Button
                        Button {
                            width: units.gu(7)
                            height: units.gu(4)
                            text: "Color"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                colorDialog.visible = true
                            }
                        }

                        // Clear Formatting
                        Button {
                            width: units.gu(7)
                            height: units.gu(4)
                            text: "Clear"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                clearFormatting()
                                textArea.forceActiveFocus()
                            }
                        }

                        // Separator
                        Rectangle {
                            width: units.dp(1)
                            height: parent.height * 0.6
                            anchors.verticalCenter: parent.verticalCenter
                            color: theme.palette.normal.base
                        }

                        // Undo/Redo
                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "Undo"
                            enabled: textArea.canUndo
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                textArea.undo()
                                textArea.forceActiveFocus()
                            }
                        }

                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "Redo"
                            enabled: textArea.canRedo
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                textArea.redo()
                                textArea.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            // Text Editor
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextArea {
                    id: textArea
                    wrapMode: TextEdit.Wrap
                    textFormat: TextEdit.RichText
                    selectByMouse: true
                    selectByKeyboard: true
                    readOnly: !editMode
                    color: textColor
                    
                    font.pixelSize: fontSize
                    font.family: "Ubuntu"
                    placeholderText: i18n.tr("Start typing your rich text here...")
                    
                    // Custom text format handler
                    property QtObject textFormatHandler: QtObject {
                        property bool bold: currentBold
                        property bool italic: currentItalic
                        property bool underline: currentUnderline
                        property int fontSize: currentFontSize
                        property color textColor: currentTextColor

                        onBoldChanged: updateFormat()
                        onItalicChanged: updateFormat()
                        onUnderlineChanged: updateFormat()
                        onFontSizeChanged: updateFormat()
                        onTextColorChanged: updateFormat()

                        function updateFormat() {
                            if (textArea.selectionStart !== textArea.selectionEnd) {
                                applyFormattingToSelection()
                            }
                        }
                    }
                    
                    onTextChanged: {
                        richTextEditor.contentChanged(text)
                    }
                    
                    onSelectionStartChanged: updateFormattingState()
                    onSelectionEndChanged: updateFormattingState()
                    onCursorPositionChanged: updateFormattingState()
                    
                    // Keyboard shortcuts
                    Keys.onPressed: function(event) {
                        if (event.modifiers & Qt.ControlModifier) {
                            switch (event.key) {
                                case Qt.Key_B:
                                    toggleBold()
                                    event.accepted = true
                                    break
                                case Qt.Key_I:
                                    toggleItalic()
                                    event.accepted = true
                                    break
                                case Qt.Key_U:
                                    toggleUnderline()
                                    event.accepted = true
                                    break
                                case Qt.Key_Z:
                                    if (event.modifiers & Qt.ShiftModifier) {
                                        redo()
                                    } else {
                                        undo()
                                    }
                                    event.accepted = true
                                    break
                                case Qt.Key_Y:
                                    redo()
                                    event.accepted = true
                                    break
                            }
                        }
                    }
                }
            }
        }
    }

    // Color picker dialog
    Dialog {
        id: colorDialog
        modal: true
        title: i18n.tr("Choose Text Color")

        ColumnLayout {
            spacing: units.gu(1)

            GridLayout {
                columns: 4
                Layout.fillWidth: true
                
                Repeater {
                    model: ["#000000", "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF00FF", "#00FFFF", "#808080"]
                    
                    Rectangle {
                        width: units.gu(4)
                        height: units.gu(4)
                        color: modelData
                        border.color: theme.palette.normal.baseText
                        border.width: units.dp(1)
                        radius: units.gu(0.5)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                setTextColor(modelData)
                                colorDialog.close()
                            }
                        }
                    }
                }
            }

            RowLayout {
                Button {
                    text: i18n.tr("Cancel")
                    Layout.fillWidth: true
                    onClicked: colorDialog.close()
                }
            }
        }
    }

    // Formatting Functions
    function toggleBold() {
        if (textArea.selectionStart !== textArea.selectionEnd) {
            applyFormattingToSelection("bold")
        } else {
            currentBold = !currentBold
            console.log("Bold toggled for new text:", currentBold)
        }
        updateFormattingState()
    }
    
    function toggleItalic() {
        if (textArea.selectionStart !== textArea.selectionEnd) {
            applyFormattingToSelection("italic")
        } else {
            currentItalic = !currentItalic
            console.log("Italic toggled for new text:", currentItalic)
        }
        updateFormattingState()
    }
    
    function toggleUnderline() {
        if (textArea.selectionStart !== textArea.selectionEnd) {
            applyFormattingToSelection("underline")
        } else {
            currentUnderline = !currentUnderline
            console.log("Underline toggled for new text:", currentUnderline)
        }
        updateFormattingState()
    }
    
    function setFontSize(size) {
        if (textArea.selectionStart !== textArea.selectionEnd) {
            applyFormattingToSelection("fontSize", size)
        } else {
            currentFontSize = size
            console.log("Font size set for new text:", size)
        }
    }

    function setTextColor(color) {
        if (textArea.selectionStart !== textArea.selectionEnd) {
            applyFormattingToSelection("color", color)
        } else {
            currentTextColor = color
            console.log("Text color set for new text:", color)
        }
    }
    
    function applyFormattingToSelection(formatType, value) {
        var start = textArea.selectionStart
        var end = textArea.selectionEnd
        var selectedText = textArea.selectedText
        var fullText = textArea.text
        
        if (start === end || !selectedText) {
            console.log("No selection to format")
            return
        }
        
        console.log("Applying", formatType, "to selection:", selectedText)
        
        var beforeText = fullText.substring(0, start)
        var afterText = fullText.substring(end)
        
        var newText = selectedText
        
        switch (formatType) {
            case "bold":
                if (selectedText.indexOf('<b>') >= 0) {
                    newText = selectedText.replace(/<\/?b>/g, '')
                } else {
                    newText = '<b>' + selectedText + '</b>'
                }
                break
            case "italic":
                if (selectedText.indexOf('<i>') >= 0) {
                    newText = selectedText.replace(/<\/?i>/g, '')
                } else {
                    newText = '<i>' + selectedText + '</i>'
                }
                break
            case "underline":
                if (selectedText.indexOf('<u>') >= 0) {
                    newText = selectedText.replace(/<\/?u>/g, '')
                } else {
                    newText = '<u>' + selectedText + '</u>'
                }
                break
            case "fontSize":
                newText = '<span style="font-size:' + value + 'px;">' + selectedText + '</span>'
                break
            case "color":
                newText = '<span style="color:' + value + ';">' + selectedText + '</span>'
                break
        }
        
        // Replace the entire text
        textArea.text = beforeText + newText + afterText
        
        // Restore cursor position
        textArea.cursorPosition = start + newText.length
        
        console.log("Formatting applied. New text length:", newText.length)
    }
    
    function insertBulletList() {
        var cursorPos = textArea.cursorPosition
        var insertText = "<ul><li>List item</li></ul>"
        
        var fullText = textArea.text
        var beforeText = fullText.substring(0, cursorPos)
        var afterText = fullText.substring(cursorPos)
        
        textArea.text = beforeText + insertText + afterText
        textArea.cursorPosition = cursorPos + 8 // Position cursor inside <li>
        
        console.log("Bullet list inserted")
    }
    
    function clearFormatting() {
        if (textArea.selectionStart !== textArea.selectionEnd) {
            var start = textArea.selectionStart
            var end = textArea.selectionEnd
            var selectedText = textArea.selectedText
            var fullText = textArea.text
            
            var beforeText = fullText.substring(0, start)
            var afterText = fullText.substring(end)
            
            // Strip HTML tags from selected text
            var plainText = selectedText.replace(/<[^>]*>/g, '')
            
            textArea.text = beforeText + plainText + afterText
            textArea.cursorPosition = start + plainText.length
            
            console.log("Formatting cleared from selection")
        }
        
        // Reset formatting state
        currentBold = false
        currentItalic = false
        currentUnderline = false
        currentFontSize = fontSize
        currentTextColor = textColor
    }
    
    function updateFormattingState() {
        // Update formatting state based on current cursor position or selection
        // This is a simplified implementation
        richTextEditor.selectionChanged()
    }
}
}