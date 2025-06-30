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
        border.color: "transparent"
        border.width: 0
        radius: 0

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
                border.color: "transparent"
                border.width: 0
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
                        Button {
                            id: fontSizeButton
                            width: units.gu(8)
                            height: units.gu(4)
                            text: currentFontSize + "pt"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                fontSizeSelector.expanded = !fontSizeSelector.expanded
                            }
                        }

                        // Font Size Options
                        OptionSelector {
                            id: fontSizeSelector
                            width: units.gu(8)
                            height: units.gu(4)
                            model: [8, 10, 12, 14, 16, 18, 20, 24, 28, 32]
                            selectedIndex: 4 // Default to 16
                            containerHeight: units.gu(20)
                            visible: false
                            
                            onSelectedIndexChanged: {
                                if (selectedIndex >= 0 && selectedIndex < model.length) {
                                    setFontSize(model[selectedIndex])
                                    visible = false
                                }
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
                                setFontSize(24)
                                setBold(true)
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
                                setFontSize(20)
                                setBold(true)
                                textArea.forceActiveFocus()
                            }
                        }

                        Button {
                            width: units.gu(8)
                            height: units.gu(4)
                            text: "Normal"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                setFontSize(16)
                                setBold(false)
                                setItalic(false)
                                setUnderline(false)
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
                                colorSheet.visible = true
                            }
                        }

                        // Separator
                        Rectangle {
                            width: units.dp(1)
                            height: parent.height * 0.6
                            anchors.verticalCenter: parent.verticalCenter
                            color: theme.palette.normal.base
                        }

                        // Text Actions
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

                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "Copy"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                textArea.copy()
                                textArea.forceActiveFocus()
                            }
                        }

                        Button {
                            width: units.gu(6)
                            height: units.gu(4)
                            text: "Paste"
                            color: theme.palette.normal.backgroundText
                            
                            onClicked: {
                                textArea.paste()
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
                border.color: "transparent"
                border.width: 0
                radius: 0

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    TextArea {
                        id: textArea
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.RichText
                        selectByMouse: true
                        readOnly: !editMode
                        color: currentTextColor
                        
                        font.pixelSize: currentFontSize
                        font.family: "Ubuntu"
                        font.bold: currentBold
                        font.italic: currentItalic
                        font.underline: currentUnderline
                        
                        placeholderText: i18n.tr("Start typing your text here...")
                        
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
    }

    // Color picker sheet
    BottomEdge {
        id: colorSheet
        height: units.gu(30)
        hint.text: i18n.tr("Choose Color")
        
        contentComponent: Item {
            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                spacing: units.gu(2)

                Label {
                    text: i18n.tr("Choose Text Color")
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Grid {
                    columns: 4
                    spacing: units.gu(1)
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Repeater {
                        model: [
                            {"name": "Black", "color": "#000000"},
                            {"name": "Red", "color": "#FF0000"},
                            {"name": "Green", "color": "#00AA00"},
                            {"name": "Blue", "color": "#0000FF"},
                            {"name": "Orange", "color": "#FF8800"},
                            {"name": "Purple", "color": "#8800FF"},
                            {"name": "Cyan", "color": "#00FFFF"},
                            {"name": "Gray", "color": "#808080"}
                        ]
                        
                        Button {
                            width: units.gu(8)
                            height: units.gu(6)
                            color: UbuntuColors.silk
                            
                            Rectangle {
                                anchors.centerIn: parent
                                width: units.gu(6)
                                height: units.gu(3)
                                color: modelData.color
                                border.color: theme.palette.normal.baseText
                                border.width: units.dp(1)
                                radius: units.gu(0.5)
                                
                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: modelData.color === "#000000" ? "white" : "black"
                                    fontSize: "x-small"
                                }
                            }
                            
                            onClicked: {
                                setTextColor(modelData.color)
                                colorSheet.collapse()
                            }
                        }
                    }
                }

                Button {
                    text: i18n.tr("Cancel")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: colorSheet.collapse()
                }
            }
        }
    }

    // Formatting Functions
    function toggleBold() {
        applyFormatting("bold", !currentBold)
    }
    
    function toggleItalic() {
        applyFormatting("italic", !currentItalic)
    }
    
    function toggleUnderline() {
        applyFormatting("underline", !currentUnderline)
    }

    function setBold(value) {
        applyFormatting("bold", value)
    }

    function setItalic(value) {
        applyFormatting("italic", value)
    }

    function setUnderline(value) {
        applyFormatting("underline", value)
    }
    
    function setFontSize(size) {
        applyFormatting("fontSize", size)
    }

    function setTextColor(color) {
        applyFormatting("color", color)
    }

    // Advanced formatting function that handles selection using TextEdit properties
    function applyFormatting(formatType, value) {
        // Since Lomiri TextArea might not expose all TextEdit properties directly,
        // we'll use a different approach focusing on HTML-based rich text
        
        var currentText = textArea.text || ""
        var cursorPos = textArea.cursorPosition || 0
        
        // For RichText format, we work with HTML
        if (textArea.selectedText && textArea.selectedText.length > 0) {
            // Apply formatting to selected text
            applySelectionFormatting(formatType, value)
        } else {
            // No selection - apply to current cursor position or entire text
            applyGlobalFormatting(formatType, value)
        }
        
        updateFormattingState()
    }
    
    function applySelectionFormatting(formatType, value) {
        // This is a simplified approach for selection formatting
        // In practice, you might need to use TextEdit directly or implement
        // a more sophisticated HTML manipulation system
        
        var currentText = textArea.text || ""
        var selectedText = textArea.selectedText || ""
        
        if (selectedText.length === 0) {
            return
        }
        
        // Apply HTML formatting to selected text
        var formattedText = applyHtmlFormatting(selectedText, formatType, value)
        
        // Replace selected text with formatted version
        // This is a basic implementation - in practice you'd need more sophisticated handling
        var newText = currentText.replace(selectedText, formattedText)
        textArea.text = newText
    }
    
    function updateCurrentFormatting(formatType, value) {
        switch (formatType) {
            case "bold":
                currentBold = value
                break
            case "italic":
                currentItalic = value
                break
            case "underline":
                currentUnderline = value
                break
        }
        updateFormattingState()
    }
    
    function applyHtmlFormatting(text, formatType, value) {
        // Remove existing formatting of the same type first
        text = removeHtmlFormatting(text, formatType)
        
        switch (formatType) {
            case "bold":
                return value ? "<b>" + text + "</b>" : text
            case "italic":
                return value ? "<i>" + text + "</i>" : text
            case "underline":
                return value ? "<u>" + text + "</u>" : text
            case "fontSize":
                return '<span style="font-size: ' + value + 'px;">' + text + '</span>'
            case "color":
                return '<span style="color: ' + value + ';">' + text + '</span>'
            default:
                return text
        }
    }
    
    function removeHtmlFormatting(text, formatType) {
        switch (formatType) {
            case "bold":
                return text.replace(/<\/?b>/g, "")
            case "italic":
                return text.replace(/<\/?i>/g, "")
            case "underline":
                return text.replace(/<\/?u>/g, "")
            case "fontSize":
                return text.replace(/<span style="font-size: [^"]*;">(.*?)<\/span>/g, "$1")
            case "color":
                return text.replace(/<span style="color: [^"]*;">(.*?)<\/span>/g, "$1")
            default:
                return text
        }
    }
    
    function applyGlobalFormatting(formatType, value) {
        // Fallback: apply formatting globally (original behavior)
        switch (formatType) {
            case "bold":
                currentBold = value
                textArea.font.bold = currentBold
                break
            case "italic":
                currentItalic = value
                textArea.font.italic = currentItalic
                break
            case "underline":
                currentUnderline = value
                textArea.font.underline = currentUnderline
                break
            case "fontSize":
                currentFontSize = value
                textArea.font.pixelSize = currentFontSize
                break
            case "color":
                currentTextColor = value
                textArea.color = currentTextColor
                break
        }
        updateFormattingState()
    }
    
    function clearFormatting() {
        currentBold = false
        currentItalic = false
        currentUnderline = false
        currentFontSize = fontSize
        currentTextColor = textColor
        
        textArea.font.bold = false
        textArea.font.italic = false
        textArea.font.underline = false
        textArea.font.pixelSize = fontSize
        textArea.color = textColor
        
        console.log("Formatting cleared")
        updateFormattingState()
    }
    
    function updateFormattingState() {
        // Sync the formatting state with the actual text area properties
        currentBold = textArea.font.bold
        currentItalic = textArea.font.italic
        currentUnderline = textArea.font.underline
        currentFontSize = textArea.font.pixelSize
        currentTextColor = textArea.color
        
        richTextEditor.selectionChanged()
    }
}
