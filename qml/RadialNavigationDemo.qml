/*
 * RadialNavigation Demo - Shows how to use the RadialBottomEdge component
 * 
 * This is a standalone demo file that demonstrates the radial navigation feature
 * created for the notes app. You can run this file independently to test the
 * radial navigation without the full app complexity.
 */

import QtQuick 2.9
import Lomiri.Components 1.3
import "views/components"

MainView {
    id: root
    width: units.gu(50)
    height: units.gu(90)
    
    theme.palette: Palette {}
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: theme.palette.normal.background
        
        Column {
            anchors.centerIn: parent
            spacing: units.gu(2)
            
            Label {
                text: "Radial Navigation Demo"
                fontSize: "x-large"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Label {
                text: "Look for the navigation hint at the bottom edge"
                fontSize: "medium"
                color: theme.palette.normal.backgroundSecondaryText
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            Label {
                text: "• Drag up or click to expand\n• Click actions to navigate\n• Menu auto-hides after timeout"
                fontSize: "small"
                color: theme.palette.normal.backgroundSecondaryText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    
    // Radial Navigation Menu
    RadialBottomEdge {
        id: radialNavigation
        mode: "Semihide"
        semiHideOpacity: 60
        timeoutSeconds: 4
        hintIconName: "navigation-menu"
        
        actions: [
            RadialAction {
                iconName: "note"
                label: "Notes"
                onTriggered: {
                    console.log("Notes action triggered")
                }
            },
            RadialAction {
                iconName: "add"
                label: "New Note"
                onTriggered: {
                    console.log("New Note action triggered")
                }
            },
            RadialAction {
                iconName: "checklist"
                label: "To-Do"
                onTriggered: {
                    console.log("To-Do action triggered")
                }
            },
            RadialAction {
                iconName: "settings"
                label: "Settings"
                onTriggered: {
                    console.log("Settings action triggered")
                }
            },
            RadialAction {
                iconName: "search"
                label: "Search"
                onTriggered: {
                    console.log("Search action triggered")
                }
            }
        ]
    }
}
