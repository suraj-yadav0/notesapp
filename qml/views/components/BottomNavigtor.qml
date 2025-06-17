import QtQuick 2.7
import Lomiri.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Popups 1.3
 
 
 Rectangle {
        id: bottomNav
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: units.gu(7)
        color: theme.palette.normal.background
        border.color: theme.palette.normal.base
        border.width: units.dp(1)
        
        // Show only if the entire screen width is less than 800px (mobile/tablet)
      
 visible: isMultiColumn ? false : true
     
        Row {
            anchors.centerIn: parent
            spacing: units.gu(8)
            
            AbstractButton {
                width: units.gu(6)
                height: units.gu(6)
                
                Icon {
                    anchors.centerIn: parent
                    name: "note"
                    width: units.gu(3)
                    height: units.gu(3)
                    color: theme.palette.normal.backgroundText
                }
                
                onClicked: {
                    // Navigate to notes - already on notes page
                }
            }
            
            AbstractButton {
                width: units.gu(6)
                height: units.gu(6)
                
                Icon {
                    anchors.centerIn: parent
                    name: "view-list-symbolic"
                    width: units.gu(3)
                    height: units.gu(3)
                    color: theme.palette.normal.backgroundSecondaryText
                }
                
                onClicked: {
                    // Show ToDo page using the app's navigation logic
                    if (typeof mainPage.todoViewRequested === "function") {
                        mainPage.todoViewRequested();
                    }
                    if (typeof mainPage.onTodoViewRequested === "function") {
                        mainPage.onTodoViewRequested();
                    }
                }
            }
            
            AbstractButton {
                width: units.gu(6)
                height: units.gu(6)
                
                Icon {
                    anchors.centerIn: parent
                    name: "settings"
                    width: units.gu(3)
                    height: units.gu(3)
                    color: theme.palette.normal.backgroundSecondaryText
                }
                
                onClicked: {
                    // Could add settings page here
                }
            }
        }
    }