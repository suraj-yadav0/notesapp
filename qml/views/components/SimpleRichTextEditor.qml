import QtQuick 2.7
import QtQuick.Controls 2.2
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3

Item {
    id: simpleEditor
    width: parent ? parent.width : 400
    height: parent ? parent.height : 300

    // Properties
    property string text: ""
    property bool readOnly: false
    property int fontSize: units.gu(2)
    
    // Signal when content changes
    signal contentChanged(string newText)
    
    // Public methods
    function selectAll() { editor.selectAll() }
    function clear() { editor.clear() }
    function forceActiveFocus() { editor.forceActiveFocus() }

    ColumnLayout {
        anchors.fill: parent
        spacing: units.gu(1)
        
        // Toolbar
        Rectangle {
            visible: !readOnly
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(6)
            color: "#f0f0f0"
            radius: units.gu(0.5)
            
            Flow {
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }
                spacing: units.gu(1)
                
                // Bold button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "<b>B</b>"
                    onClicked: {
                        applyMarkdown("**", "**");
                        console.log("Bold button clicked");
                    }
                }
                
                // Italic button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "<i>I</i>"
                    onClicked: {
                        applyMarkdown("_", "_");
                        console.log("Italic button clicked");
                    }
                }
                
                // Underline button (using HTML since Markdown doesn't have underline)
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "<u>U</u>"
                    onClicked: {
                        applyMarkdown("<u>", "</u>");
                        console.log("Underline button clicked");
                    }
                }
                
                // Heading button
                Button {
                    width: units.gu(4)
                    height: units.gu(4)
                    text: "H"
                    onClicked: {
                        applyHeading();
                        console.log("Heading button clicked");
                    }
                }
                
                // List button
                Button {
                    width: units.gu(6)
                    height: units.gu(4)
                    text: "• List"
                    onClicked: {
                        applyList();
                        console.log("List button clicked");
                    }
                }
            }
        }
        
        // Editor area - using direct TextArea instead of ScrollView for better compatibility
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: "#CCCCCC"
            border.width: 1
            radius: units.gu(0.5)
            color: "white"
            
            // Direct TextArea instead of inside a ScrollView
            TextArea {
                id: editor
                anchors {
                    fill: parent
                    margins: units.gu(1) // Add margins inside the border
                }
                wrapMode: TextEdit.Wrap
                textFormat: TextEdit.PlainText // Use plain text for better markdown handling
                font.pixelSize: fontSize
                readOnly: simpleEditor.readOnly
                
                // Debug coloring to make sure the TextArea is visible
                // background: Rectangle { color: "#f9f9f9" }
                
                // Update external text property when internal text changes
                onTextChanged: {
                    console.log("Editor text changed:", text.substring(0, 20) + "..." );
                    if (simpleEditor.text !== text) {
                        simpleEditor.text = text;
                        simpleEditor.contentChanged(text);
                    }
                }
            }
        }
    }
    
    // Handle external text changes
    onTextChanged: {
        console.log("SimpleRichTextEditor external text changed: ", text.substring(0, 20) + "...");
        if (editor && editor.text !== text) {
            editor.text = text;
        }
    }
    
    // -- Formatting functions --
    
    function applyMarkdown(startMark, endMark) {
        editor.forceActiveFocus();
        
        var selStart = editor.selectionStart;
        var selEnd = editor.selectionEnd;
        var selectedText = editor.selectedText;
        
        if (selStart !== selEnd) {
            // Format selected text
            editor.remove(selStart, selEnd);
            editor.insert(selStart, startMark + selectedText + endMark);
            
            // Set selection to include the formatting marks
            editor.select(selStart, selStart + startMark.length + selectedText.length + endMark.length);
        } else {
            // No selection, insert markers and place cursor between them
            var cursorPos = editor.cursorPosition;
            editor.insert(cursorPos, startMark + endMark);
            editor.cursorPosition = cursorPos + startMark.length;
        }
    }
    
    function applyHeading() {
        editor.forceActiveFocus();
        
        // Find the start of the current line
        var text = editor.text;
        var cursorPos = editor.cursorPosition;
        var lineStart = cursorPos;
        
        while (lineStart > 0 && text[lineStart-1] !== '\n') {
            lineStart--;
        }
        
        // Check if line already starts with # and add/remove accordingly
        if (text.substring(lineStart, lineStart + 2) === "# ") {
            editor.remove(lineStart, lineStart + 2);
        } else {
            editor.insert(lineStart, "# ");
        }
    }
    
    function applyList() {
        editor.forceActiveFocus();
        
        var selStart = editor.selectionStart;
        var selEnd = editor.selectionEnd;
        var selectedText = editor.selectedText;
        
        if (selectedText) {
            // Format each line of selected text as list items
            var lines = selectedText.split('\n');
            var result = "";
            
            for (var i = 0; i < lines.length; i++) {
                if (lines[i].trim() !== "") {
                    result += "* " + lines[i] + "\n";
                } else if (lines[i] === "") {
                    result += "\n";
                }
            }
            
            editor.remove(selStart, selEnd);
            editor.insert(selStart, result);
        } else {
            // No selection, insert a sample list
            var cursorPos = editor.cursorPosition;
            var listTemplate = "* Item 1\n* Item 2\n* Item 3\n";
            editor.insert(cursorPos, listTemplate);
            editor.cursorPosition = cursorPos + 2; // Position after first '*'
        }
    }
    
    Component.onCompleted: {
        console.log("SimpleRichTextEditor completed, text length: ", text.length);
        // Ensure the text is set after a brief delay to allow the component to initialize
        Qt.callLater(function() {
            if (editor && text) {
                editor.text = text;
                editor.forceActiveFocus();
            }
        });
    }
}
