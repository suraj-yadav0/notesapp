import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

// Rich text editor component
Item {
    id: richTextEditor
    
    // Properties
    property bool editMode: true
    property alias text: textEdit.text
    property alias readOnly: textEdit.readOnly
    property int fontSize: units.gu(2)
    
    // Signals
    signal contentChanged(string text)
    
    // Exposed functions
    function selectAll() {
        textEdit.selectAll();
    }
    
    function clear() {
        textEdit.clear();
    }
    
    // Layout
    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(1)
        
        // Formatting toolbar (only visible in edit mode)
        Rectangle {
            visible: editMode
            Layout.fillWidth: true
            height: formatToolbar.height + units.gu(2)
            color: "#f0f0f0"
            radius: units.gu(0.5)
            
            Row {
                id: formatToolbar
                anchors.centerIn: parent
                spacing: units.gu(1)
                
                // Bold button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "<b>B</b>"
                    onClicked: {
                        formatText("b");
                    }
                }
                
                // Italic button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "<i>I</i>"
                    onClicked: {
                        formatText("i");
                    }
                }
                
                // Underline button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "<u>U</u>"
                    onClicked: {
                        formatText("u");
                    }
                }
                
                // Heading button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "H"
                    onClicked: {
                        formatText("h3");
                    }
                }
                
               // List button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "• List"
                    onClicked: {
                        insertList();
                    }
                }
                
                // Clear formatting
                Button {
                    width: units.gu(7)
                    height: units.gu(4)
                    text: "Clear Format"
                    onClicked: {
                        clearFormatting();
                    }
                }
            }
        }
        
        // Text editor area
        Flickable {
            id: textFlick
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: textEdit.paintedWidth
            contentHeight: textEdit.paintedHeight
            clip: true
            
            function ensureVisible(rect) {
                if (contentX >= rect.x)
                    contentX = rect.x;
                else if (contentX + width <= rect.x + rect.width)
                    contentX = rect.x + rect.width - width;
                if (contentY >= rect.y)
                    contentY = rect.y;
                else if (contentY + height <= rect.y + rect.height)
                    contentY = rect.y + rect.height - height;
            }
            
            TextEdit {
                id: textEdit
                width: textFlick.width
                height: Math.max(textFlick.height, paintedHeight)
                focus: true
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                textFormat: TextEdit.RichText
                font.pixelSize: richTextEditor.fontSize
                
                onCursorRectangleChanged: textFlick.ensureVisible(cursorRectangle)
                onTextChanged: richTextEditor.contentChanged(text)
            }
        }
    }
    
    // Private functions for text formatting
    function formatText(tag) {
        var selStart = textEdit.selectionStart;
        var selEnd = textEdit.selectionEnd;
        
        if (selStart === selEnd) {
            // No selection, just insert tags
            var pos = textEdit.cursorPosition;
            var openTag = "<" + tag + ">";
            var closeTag = "</" + tag + ">";
            
            textEdit.insert(pos, openTag + closeTag);
            textEdit.cursorPosition = pos + openTag.length;
        } else {
            // Wrap selected text with tags
            var selectedText = textEdit.selectedText;
            var formattedText = "<" + tag + ">" + selectedText + "</" + tag + ">";
            
            textEdit.remove(selStart, selEnd);
            textEdit.insert(selStart, formattedText);
            textEdit.select(selStart, selStart + formattedText.length);
        }
    }
    
    function insertList() {
        var pos = textEdit.cursorPosition;
        var listTemplate = "<ul>\n  <li>Item 1</li>\n  <li>Item 2</li>\n  <li>Item 3</li>\n</ul>";
        
        textEdit.insert(pos, listTemplate);
    }
    
    function clearFormatting() {
        if (textEdit.selectionStart !== textEdit.selectionEnd) {
            // Clear formatting of selected text
            var plainText = textEdit.selectedText.replace(/<[^>]*>/g, '');
            
            textEdit.remove(textEdit.selectionStart, textEdit.selectionEnd);
            textEdit.insert(textEdit.selectionStart, plainText);
        } else {
            // Convert all text to plain text
            var fullPlainText = textEdit.text.replace(/<[^>]*>/g, '');
            textEdit.text = fullPlainText;
        }
    }
}