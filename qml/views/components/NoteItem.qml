import QtQuick 2.7
import Lomiri.Components 1.3
import Ubuntu.Components 1.3

// Component to display a single note in the list
ListItem {
    id: noteItem
    height: units.gu(10)
    
    // Properties to be set from outside
    property string title
    property string content
    property string createdAt
    property int noteIndex
    property bool isRichText: false
    
    // Signals
    signal noteSelected(int index)
    signal noteEditRequested(int index)
    signal noteDeleteRequested(int index)
    
    clip : true
    // Leading actions (delete)
    leadingActions: ListItemActions {
        actions: [
            Action {
                iconName: "delete"
                onTriggered: {
                    noteDeleteRequested(noteIndex);
                }
            }
        ]
    }
    
    // Trailing actions (edit)
    trailingActions: ListItemActions {
        actions: [
            Action {
                iconName: "edit"
                onTriggered: {
                    noteEditRequested(noteIndex);
                }
            }
        ]
    }
    
    // Note visual representation
    Rectangle {
        anchors.fill: parent
      //  radius: units.gu(1)
        border.color: "transparent"
       // border.width: 1
        anchors.margins: units.gu(1)
        color : theme.palette.normal.background
        
        Row {
            id: contentRow
            spacing: units.gu(2)
            anchors.centerIn: parent
            width: parent.width - units.gu(4)
            
            Column {
                spacing: units.gu(0.5)
                width: contentRow.width - units.gu(6) - parent.spacing // Account for icon and spacing
                
                Text {
                    text: noteItem.title
                    font.pixelSize: units.gu(2)
                    elide: Text.ElideRight
                    width: parent.width
                    color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#FFFFFF" : "#0D141C"
                }
                
                Text {
                    text: "Last modified: " +  noteItem.createdAt
                    font.pixelSize: units.gu(1.75)
                    color: theme.name === "Ubuntu.Components.Themes.SuruDark" ? "#8FADCC" : "#4A739C"
                }
                
                // Preview of content - handles rich text
                // Text {
                //     width: parent.width
                //     maximumLineCount: 2
                //     elide: Text.ElideRight
                //     wrapMode: Text.WordWrap
                //     font.pixelSize: units.gu(1.8)
                    
                //     // Display either as rich text or plain text
                //     text: noteItem.isRichText ? 
                //           noteItem.content : 
                //           noteItem.content.length > 100 ? 
                //           noteItem.content.substring(0, 100) + "..." : 
                //           noteItem.content
                    
                //     textFormat: noteItem.isRichText ? Text.RichText : Text.PlainText
                    
                //     // Strip HTML tags for display when needed
                //     function stripHtml(html) {
                //         return html.replace(/<[^>]*>/g, '');
                //     }
                // }
            }

            // Right arrow icon
            Icon {
                width: units.gu(2)
                height: units.gu(2)
                name: "go-next"
                color: theme.palette.normal.baseText
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                noteSelected(noteIndex);
            }
        }
    }
}