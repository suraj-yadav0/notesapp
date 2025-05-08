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
    
    // Signals
    signal noteSelected(int index)
    signal noteEditRequested(int index)
    signal noteDeleteRequested(int index)
    
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
        radius: units.gu(1)
        border.color: "#cccccc"
        border.width: 1
        anchors.margins: units.gu(1)
        
        Row {
            spacing: units.gu(2)
            anchors.fill: parent
            anchors.margins: units.gu(2)
            
            Column {
                spacing: units.gu(0.5)
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - parent.spacing
                
                Text {
                    text: noteItem.title
                    font.pixelSize: units.gu(2.5)
                    elide: Text.ElideRight
                    width: parent.width
                }
                
                Text {
                    text: noteItem.createdAt
                    font.pixelSize: units.gu(2)
                }
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