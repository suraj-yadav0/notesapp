# Rich Text Editor

> The Rich Text Feature is not completed , it is still in development.
> 

So before watching the current course , Lets Start with Adding Rich Text Support to our notes app. Rich Text support will Help us to highlight the content of our notes like bold, italic, or Underlining. We can also implement later the support of adding Lists , Images , links etc. This will make our notes app more useful. 

> Task 1
> 

Let’s start with our data model for our app. First of all we will be adding Rich Text support in our data models file. so open the `NotesModel.qml` and add a boolean var `isRichText` to our notes model. By default this is `false`.

1. Change NoteEditPage code to this :

```jsx
import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import "components"

Page {
    id: noteEditPage

    // to be set from outside
    property var controller

    // when navigation back is requested
    signal backRequested

    visible: false

    header: PageHeader {
        id: editHeader
        title: i18n.tr('Edit Note')

        leadingActionBar.actions: [
            Action {
                iconName: "back"
                onTriggered: {
                    backRequested();
                }
            }
        ]

        trailingActionBar.actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    controller.deleteCurrentNote();
                    backRequested();
                }
            },
            Action {
                iconName: "ok"
                text: i18n.tr("Save")
                onTriggered: {
                    var content = isRichTextSwitch.checked ? richTextLoader.item.text : plainTextArea.text;

                    if (controller.updateCurrentNote(titleEditField.text, content, isRichTextSwitch.checked)) {
                        backRequested();
                    }
                }
            }
        ]
    }

    // Edit form
    Column {
        id: editForm
        anchors {
            top: editHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(2)
        }
        spacing: units.gu(2)

        TextField {
            id: titleEditField
            width: parent.width
            placeholderText: i18n.tr("Title")
            text: controller.currentNote.title
        }

        // Toggle for rich text 
        Row {
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: i18n.tr("Rich Text:")
                anchors.verticalCenter: parent.verticalCenter
            }

            Switch {
                id: isRichTextSwitch
                checked: controller.currentNote.isRichText || false
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        //rich/plain text switch
        Item {
            width: parent.width
            height: parent.height - titleEditField.height - parent.spacing * 2 - isRichTextSwitch.height

            //  for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Note content...")
                text: controller.currentNote.content
                autoSize: false
                visible: !isRichTextSwitch.checked
            }

            // Rich text editor
            Rectangle {
                anchors.fill: parent

                visible: isRichTextSwitch.checked
                border.width: 1
                border.color: theme.palette.normal.baseText
                color: theme.palette.normal.background
                radius: units.gu(0.5)
                height: parent.height - units.gu(5)

                
                anchors.margins: units.gu(-1)
            }

            Loader {
                id: richTextLoader
                anchors.fill: parent
                active: isRichTextSwitch.checked
                visible: isRichTextSwitch.checked

                sourceComponent: Component {
                    RichTextEditor {
                        editMode: true
                    }
                }

                onLoaded: {
                    if (controller.currentNote.content) {
                        item.text = controller.currentNote.content;
                        item.forceActiveFocus();
                    }
                }
            }
        }

        // Update fields when current note changes
        Connections {
            target: controller
            onCurrentNoteChanged: {
                titleEditField.text = controller.currentNote.title;
                isRichTextSwitch.checked = controller.currentNote.isRichText || false;

                if (isRichTextSwitch.checked && richTextLoader.status === Loader.Ready && richTextLoader.item) {
                    richTextLoader.item.text = controller.currentNote.content;
                    richTextLoader.item.forceActiveFocus();
                } else {
                    plainTextArea.text = controller.currentNote.content;
                }
            }
        }
    }
}

```

1. Add a new file called RichTextEditor in components dir of Views folder and add this code :

```jsx
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
            color: theme.palette.normal.background
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
                color: theme.palette.normal.baseText

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
```

1. Change the AddNoteDialog.qm code to this: 

```jsx
import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Popups 1.3
import "."

// Dialog ..for adding notes.
Dialog {
    id: noteDialog
   
    // width: Math.min(parent.width * 0.9, units.gu(90))
    // height: Math.min(parent.height * 0.7, units.gu(80))
    anchors.centerIn: parent
    contentHeight: parent.height * 0.75
    contentWidth: parent.width * 0.8
    

    
    Component.onCompleted: {
       
        Qt.callLater(function() {
            x = (parent.width - width) / 2
            y = (parent.height - height) / 2
        })
    }
    
    property bool isEditing: false
    property string initialTitle: ""
    property string initialContent: ""
    property bool isRichText: false
    
    // Signals
    signal saveRequested(string title, string content, bool isRichText)
    signal cancelRequested()
    
    title: isEditing ? i18n.tr("Edit Note") : i18n.tr("Add New Note")
    modal: true
    
    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: units.gu(1.5)
        
        TextArea {
            id: noteTitleArea
            Layout.fillWidth: true
            Layout.preferredHeight: units.gu(5)
            placeholderText: i18n.tr("Title of your Note...")
            autoSize: false
            text: initialTitle
        }
        
        // Toggle for rich text format
        Row {
            Layout.fillWidth: true
            spacing: units.gu(1)
            
            Label {
                text: i18n.tr("Rich Text:")
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Switch {
                id: richTextSwitch
                checked: isRichText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // Different editor components depending on whether rich text is enabled
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: units.gu(25)
            
            // Standard TextArea for plain text
            TextArea {
                id: plainTextArea
                anchors.fill: parent
                placeholderText: i18n.tr("Type your note here...")
                text: initialContent
                visible: !richTextSwitch.checked
            }

            // Rectangle border for rich text editor
        
            
            Rectangle {
                anchors.fill: parent
                
                visible: richTextSwitch.checked
                border.width: 1
                border.color: theme.palette.normal.baseText
                color: theme.palette.normal.background
                radius: units.gu(0.5)
                height: parent.height - units.gu(5)
                
                
                anchors.margins: units.gu(-1)
            }
            
            Loader {
                id: richTextLoader
                anchors.fill: parent
                active: richTextSwitch.checked
                visible: richTextSwitch.checked
                
                sourceComponent: Component {
                    RichTextEditor {
                        id: richTextEditor
                        editMode: true
                    }
                }
                
                onLoaded: {
                    
                    if (richTextSwitch.checked) {
                        item.text = initialContent;
                    }
                }
            }
            
            // Update rich text when switching modes
            Connections {
                target: richTextSwitch
                onCheckedChanged: {
                    if (richTextSwitch.checked && richTextLoader.status === Loader.Ready) {
                        richTextLoader.item.text = initialContent || plainTextArea.text;
                    }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: units.gu(1)
            spacing: units.gu(1)
            
            Button {
                Layout.fillWidth: true
                text: i18n.tr("Cancel")
                onClicked: {
                    cancelRequested();
                    PopupUtils.close(noteDialog);
                }
            }
            
            Button {
                Layout.fillWidth: true
                text: i18n.tr("Save")
                color: theme.palette.normal.positive
                onClicked: {
                    if (noteTitleArea.text.trim() !== "") {
                        // Get content from either rich or plain text editor
                        var content;
                        if (richTextSwitch.checked && richTextLoader.status === Loader.Ready) {
                            content = richTextLoader.item.text;
                        } else {
                            content = plainTextArea.text;
                        }
                        
                        console.log("Saving note - Title: " + noteTitleArea.text + ", Content length: " + content.length);
                        saveRequested(noteTitleArea.text, content, richTextSwitch.checked);
                        PopupUtils.close(noteDialog);
                    }
                }
            }
        }
    }
}
```

1. Also Ensure whenever note creation function is called, isRichText is passed as argument for the context to maintain the state of the note. 
2. The isRichText argument should be properly pasased from Models, Controllers and MainPage