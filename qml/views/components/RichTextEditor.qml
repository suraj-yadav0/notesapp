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
                        onClicked: { formatText("b");
                        console.log("Bold button clicked"); }
                    }
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "<i>I</i>"
                        onClicked: { formatText("i");
                        console.log("Italic button clicked"); }
                    }
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "<u>U</u>"
                        onClicked: { formatText("u");
                        console.log("Underline button clicked"); }
                    }
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "H"
                        onClicked: { formatText("h3"); 
                        console.log("Heading button clicked"); }
                    }
                    Button {
                        width: units.gu(4)
                        height: units.gu(4)
                        text: "• List"
                        onClicked: { insertList(); }
                    }
                    Button {
                        width: units.gu(7)
                        height: units.gu(4)
                        text: "Clear Format"
                        onClicked: { clearFormatting(); }
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

                onCursorRectangleChanged: textFlick.ensureVisible(cursorRectangle)
                onTextChanged: richTextEditor.contentChanged(text)
            }
        }
    }

    // --- Formatting functions ---
    function formatText(tag) {
        var selStart = textEdit.selectionStart;
        var selEnd = textEdit.selectionEnd;
        if (selStart === selEnd) {
            var pos = textEdit.cursorPosition;
            var openTag = "<" + tag + ">";
            var closeTag = "</" + tag + ">";
            textEdit.insert(pos, openTag + closeTag);
            textEdit.cursorPosition = pos + openTag.length;
        } else {
            var selectedText = textEdit.selectedText;
            textEdit.remove(selStart, selEnd);
            textEdit.insert(selStart, "<" + tag + ">" + selectedText + "</" + tag + ">");
        }
    }

    function insertList() {
        var selStart = textEdit.selectionStart;
        var selEnd = textEdit.selectionEnd;
        if (selStart === selEnd) {
            var pos = textEdit.cursorPosition;
            var listTemplate = "<ul>\n  <li>Item 1</li>\n  <li>Item 2</li>\n  <li>Item 3</li>\n</ul>";
            textEdit.insert(pos, listTemplate);
        } else {
            var selectedText = textEdit.selectedText;
            var lines = selectedText.split("\n");
            var listItems = "";
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].trim() !== "") {
                    listItems += "  <li>" + lines[i] + "</li>\n";
                }
            }
            var listText = "<ul>\n" + listItems + "</ul>";
            textEdit.remove(selStart, selEnd);
            textEdit.insert(selStart, listText);
        }
    }

    function clearFormatting() {
        if (textEdit.selectionStart !== textEdit.selectionEnd) {
            var plainText = textEdit.selectedText.replace(/<[^>]*>/g, '');
            textEdit.remove(textEdit.selectionStart, textEdit.selectionEnd);
            textEdit.insert(textEdit.selectionStart, plainText);
        } else {
            var fullPlainText = textEdit.text.replace(/<[^>]*>/g, '');
            textEdit.text = fullPlainText;
        }
    }
}