import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

Item {
    id: richTextEditor
    width: parent ? parent.width : 400
    height: parent ? parent.height : 300

    property bool editMode: true
    property alias text: textEdit.text
    property alias readOnly: textEdit.readOnly
    property int fontSize: units.gu(2)

    signal contentChanged(string text)

    function selectAll() { textEdit.selectAll(); }
    function clear() { textEdit.clear(); }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(1)

        // Toolbar at the top
        Rectangle {
            visible: editMode
            Layout.fillWidth: true
            height: formatToolbar.height + units.gu(2)
            color: "#f0f0f0"
            radius: units.gu(0.5)
            clip: true

            Flickable {
                anchors.fill: parent
                contentWidth: formatToolbar.width
                flickableDirection: Flickable.HorizontalFlick

                Row {
                    id: formatToolbar
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: units.gu(1)
                    spacing: units.gu(1)

                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "<b>B</b>"
                        onClicked: {
                            formatWithTag("b");
                        }
                    }
                    
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "<i>I</i>"
                        onClicked: {
                            formatWithTag("i");
                        }
                    }
                    
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "<u>U</u>"
                        onClicked: {
                            formatWithTag("u");
                        }
                    }
                    
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "H"
                        onClicked: {
                            formatWithTag("h3");
                        }
                    }
                    
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "• List"
                        onClicked: {
                            insertBulletList();
                        }
                    }
                    
                    Button {
                        width: units.gu(7)
                        height: units.gu(4)
                        text: "Clear Format"
                        onClicked: {
                            clearFormat();
                        }
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
                readOnly: !editMode
                
                Rectangle {
                    z: -1
                    anchors.fill: parent
                    color: "transparent"
                    border.color: "#dddddd"
                    border.width: 1
                    radius: units.gu(0.5)
                }

                onCursorRectangleChanged: textFlick.ensureVisible(cursorRectangle)
                onTextChanged: richTextEditor.contentChanged(text)
                
                // Initial setup
                Component.onCompleted: {
                    forceActiveFocus();
                }
            }
        }
    }
    
    // --- Improved formatting functions ---
    
    // Bold, italic, underline, headings
    function formatWithTag(tag) {
        textEdit.forceActiveFocus();
        var start = textEdit.selectionStart;
        var end = textEdit.selectionEnd;
        var selectedText = textEdit.selectedText;
        
        if (start !== end) {
            // Format selected text
            var html = "<" + tag + ">" + selectedText + "</" + tag + ">";
            textEdit.remove(start, end);
            textEdit.insert(start, html);
        } else {
            // Insert empty tags and position cursor between them
            var openTag = "<" + tag + ">";
            var closeTag = "</" + tag + ">";
            var cursorPos = textEdit.cursorPosition;
            textEdit.insert(cursorPos, openTag + closeTag);
            textEdit.cursorPosition = cursorPos + openTag.length;
        }
    }
    
    // Insert a bullet list
    function insertBulletList() {
        textEdit.forceActiveFocus();
        var cursorPos = textEdit.cursorPosition;
        var selectedText = textEdit.selectedText;
        
        var htmlList;
        if (textEdit.selectedText) {
            var lines = selectedText.split("\n");
            var listItems = "";
            
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].trim()) {
                    listItems += "<li>" + lines[i].trim() + "</li>";
                }
            }
            
            htmlList = "<ul>" + listItems + "</ul>";
            
            textEdit.remove(textEdit.selectionStart, textEdit.selectionEnd);
            textEdit.insert(textEdit.selectionStart, htmlList);
        } else {
            htmlList = "<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>";
            textEdit.insert(cursorPos, htmlList);
        }
    }
    
    // Clear formatting from selected text
    function clearFormat() {
        textEdit.forceActiveFocus();
        
        if (textEdit.selectedText) {
            var plainText = textEdit.selectedText.replace(/<[^>]*>/g, '');
            var start = textEdit.selectionStart;
            var end = textEdit.selectionEnd;
            
            textEdit.remove(start, end);
            textEdit.insert(start, plainText);
        } else {
            // If nothing selected, clear entire document formatting
            var fullText = textEdit.text;
            // Keep simple line breaks by replacing <br> and <p> tags
            fullText = fullText.replace(/<br\s*\/?>/gi, '\n');
            fullText = fullText.replace(/<\/p>\s*<p>/gi, '\n\n');
            fullText = fullText.replace(/<[^>]*>/g, ''); // Remove all other tags
            textEdit.text = fullText;
        }
    }

    // Ensure we catch external text changes (e.g., from bindings)
    onTextChanged: {
        // Ensure it's a real rich text document
        if (text && !text.startsWith("<!DOCTYPE") && !text.startsWith("<html>")) {
            // Simple text needs to be wrapped for proper rich text handling
            if (!text.match(/<[a-z][\s\S]*>/i)) {
                // It's plain text, add minimal HTML structure
                textEdit.text = "<html><body>" + text + "</body></html>";
            }
        }
    }
}