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

    // Navigation signals
    signal mainPageRequested()
    signal todoPageRequested()
    signal settingsPageRequested()
     
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
                    mainPageRequested();
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
                    todoPageRequested();
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
                    settingsPageRequested();
                }
            }
        }
    }