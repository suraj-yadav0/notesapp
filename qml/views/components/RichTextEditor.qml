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
                border.color: theme.palette.normal.base
                border.width: units.dp(1)
                radius: units.gu(0.5)

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: units.gu(1)

                    TextArea {
                        id: textArea
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.PlainText
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
        currentBold = !currentBold
        textArea.font.bold = currentBold
        console.log("Bold toggled:", currentBold)
        updateFormattingState()
    }
    
    function toggleItalic() {
        currentItalic = !currentItalic
        textArea.font.italic = currentItalic
        console.log("Italic toggled:", currentItalic)
        updateFormattingState()
    }
    
    function toggleUnderline() {
        currentUnderline = !currentUnderline
        textArea.font.underline = currentUnderline
        console.log("Underline toggled:", currentUnderline)
        updateFormattingState()
    }

    function setBold(value) {
        currentBold = value
        textArea.font.bold = currentBold
        updateFormattingState()
    }

    function setItalic(value) {
        currentItalic = value
        textArea.font.italic = currentItalic
        updateFormattingState()
    }

    function setUnderline(value) {
        currentUnderline = value
        textArea.font.underline = currentUnderline
        updateFormattingState()
    }
    
    function setFontSize(size) {
        currentFontSize = size
        textArea.font.pixelSize = currentFontSize
        console.log("Font size set:", size)
        updateFormattingState()
    }

    function setTextColor(color) {
        currentTextColor = color
        textArea.color = currentTextColor
        console.log("Text color set:", color)
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
