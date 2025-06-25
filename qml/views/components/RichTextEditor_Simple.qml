import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import "../../common/constants"

Item {
    id: richTextEditor
    width: parent ? parent.width : 400
    height: parent ? parent.height : 300

    property bool editMode: true
    property alias text: textEdit.text
    property alias readOnly: textEdit.readOnly
    property int fontSize: units.gu(2)
    property string initialText: ""

    signal contentChanged(string text)

    function selectAll() { textEdit.selectAll() }
    function clear() { textEdit.clear() }
    
    // Track formatting state
    property bool isBold: false
    property bool isItalic: false
    property bool isUnderline: false
    property bool isHeading: false
    
    // Initialize content when component is ready
    Component.onCompleted: {
        if (initialText) {
            textEdit.text = initialText
        }
        Qt.callLater(function() {
            textEdit.focus = true
        })
    }
    
    // Watch for changes to initialText
    onInitialTextChanged: {
        if (initialText !== undefined && textEdit && textEdit.text !== initialText) {
            textEdit.text = initialText
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(1)

        // Toolbar at the top
        Rectangle {
            visible: editMode
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(6)
            color: theme.palette.normal.background
            border.color: theme.palette.normal.base
            border.width: 1
            radius: units.gu(0.5)

            ScrollView {
                anchors.fill: parent
                anchors.margins: units.gu(0.5)
                
                Row {
                    id: formatToolbar
                    spacing: units.gu(0.5)
                    height: parent.height

                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "B"
                        font.bold: true
                        color: isBold ? theme.palette.selected.foreground : theme.palette.normal.foreground
                        onClicked: {
                            console.log("Bold button clicked")
                            toggleBold()
                        }
                    }
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "I"
                        font.italic: true
                        color: isItalic ? theme.palette.selected.foreground : theme.palette.normal.foreground
                        onClicked: {
                            console.log("Italic button clicked")
                            toggleItalic()
                        }
                    }
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "U"
                        font.underline: true
                        color: isUnderline ? theme.palette.selected.foreground : theme.palette.normal.foreground
                        onClicked: {
                            console.log("Underline button clicked")
                            toggleUnderline()
                        }
                    }
                    Button {
                        width: units.gu(5)
                        height: units.gu(4)
                        text: "H1"
                        font.bold: true
                        color: isHeading ? theme.palette.selected.foreground : theme.palette.normal.foreground
                        onClicked: {
                            console.log("Heading button clicked")
                            toggleHeading()
                        }
                    }
                    Button {
                        width: units.gu(5)
                        height: units.gu(4)
                        text: "List"
                        color: theme.palette.normal.foreground
                        onClicked: {
                            console.log("List button clicked")
                            insertBulletPoint()
                        }
                    }
                    Button {
                        width: units.gu(6)
                        height: units.gu(4)
                        text: "Clear"
                        color: theme.palette.normal.foreground
                        onClicked: {
                            console.log("Clear button clicked")
                            clearFormatting()
                        }
                    }
                }
            }
        }

        // Text editor area
        ScrollView {
            id: textScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true

            TextEdit {
                id: textEdit
                width: textScrollView.width
                height: Math.max(textScrollView.height, contentHeight)
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                readOnly: !editMode
                color: theme.palette.normal.baseText
                
                // Apply formatting state to font
                font.pixelSize: isHeading ? richTextEditor.fontSize * 1.5 : richTextEditor.fontSize
                font.bold: isBold || isHeading
                font.italic: isItalic
                font.underline: isUnderline
                
                onTextChanged: {
                    richTextEditor.contentChanged(text)
                }
                
                // Handle key shortcuts
                Keys.onPressed: {
                    if (event.modifiers & Qt.ControlModifier) {
                        if (event.key === Qt.Key_B) {
                            toggleBold()
                            event.accepted = true
                        } else if (event.key === Qt.Key_I) {
                            toggleItalic()
                            event.accepted = true
                        } else if (event.key === Qt.Key_U) {
                            toggleUnderline()
                            event.accepted = true
                        }
                    }
                }
            }
        }
    }

    // --- Formatting functions ---
    function toggleBold() {
        isBold = !isBold
        console.log("Bold toggled:", isBold)
        textEdit.focus = true
    }
    
    function toggleItalic() {
        isItalic = !isItalic
        console.log("Italic toggled:", isItalic)
        textEdit.focus = true
    }
    
    function toggleUnderline() {
        isUnderline = !isUnderline
        console.log("Underline toggled:", isUnderline)
        textEdit.focus = true
    }
    
    function toggleHeading() {
        isHeading = !isHeading
        console.log("Heading toggled:", isHeading)
        textEdit.focus = true
    }
    
    function insertBulletPoint() {
        console.log("Inserting bullet point")
        
        var cursorPos = textEdit.cursorPosition
        var currentText = textEdit.text
        
        // Find start of current line
        var lineStart = currentText.lastIndexOf('\n', cursorPos - 1) + 1
        var beforeLine = currentText.substring(0, lineStart)
        var afterCursor = currentText.substring(cursorPos)
        
        // Insert bullet point
        var bulletText = "• "
        textEdit.text = beforeLine + bulletText + afterCursor
        textEdit.cursorPosition = lineStart + bulletText.length
        textEdit.focus = true
    }
    
    function clearFormatting() {
        console.log("Clearing formatting")
        isBold = false
        isItalic = false
        isUnderline = false
        isHeading = false
        textEdit.focus = true
    }
    
    // Public functions for external use
    function setText(content) {
        textEdit.text = content || ""
    }
    
    function getText() {
        return textEdit.text
    }
    
    function focusEditor() {
        textEdit.focus = true
    }
}
