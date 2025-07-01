/*
 * Copyright (C) 2025  Suraj Yadav
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * notesapp is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import Lomiri.Components 1.3
import "../../common/constants"

/**
 * RadialBottomEdge provides a radial navigation menu that expands from the bottom edge
 * Supports gestures, auto-hide modes, and customizable actions in a circular layout
 */

Item {
    id: root
    
    // Configuration properties
    property int hintSize: AppConstants.defaultHintSize
    property color hintColor: theme.name === "Ubuntu.Components.Themes.SuruDark" ? theme.palette.normal.overlay : "lightgrey"
    property string hintIconName: "navigation-menu"
    property alias hintIconSource: hintIcon.source
    property color hintIconColor: theme.palette.normal.backgroundText
    property bool bottomEdgeEnabled: true
    property color bgColor: theme.palette.normal.overlay
    property real bgOpacity: AppConstants.defaultBgOpacity
    
    // Behavior modes
    property string mode: "Always" // "Always", "Autohide", "Semihide"
    property int semiHideOpacity: 50
    property int timeoutSeconds: AppConstants.navigationTimeoutSeconds
    
    // Layout properties
    property real expandedPosition: 0.6 * height
    property real collapsedPosition: height - hintSize / 2
    property real actionButtonSize: AppConstants.defaultButtonSize
    property real actionButtonDistance: AppConstants.defaultRadialDistance * hintSize
    
    // Action properties
    property list<RadialAction> actions
    property ListModel leadingActions
    
    // State management
    property bool expanded: false
    property bool pressed: false
    
    anchors.fill: parent
    
    // Functions
    function expand() {
        expanded = true
        expandAnimation.start()
        switchToNormal()
    }
    
    function collapse() {
        expanded = false
        collapseAnimation.start()
        switchToTimeout()
    }
    
    function switchToNormal() {
        hideTimer.stop()
        if (mode === "Semihide") {
            root.opacity = 1.0
        }
    }
    
    function switchToTimeout() {
        if (mode === "Autohide" || mode === "Semihide") {
            hideTimer.restart()
        }
    }
    
    // Background overlay
    Rectangle {
        id: backgroundOverlay
        anchors.fill: parent
        color: bgColor
        opacity: expanded ? bgOpacity : 0
        visible: expanded
        
        Behavior on opacity {
            NumberAnimation {
                duration: AppConstants.defaultAnimationDuration
                easing.type: Easing.OutQuad
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: collapse()
        }
    }
    
    // Main container
    Item {
        id: container
        anchors.fill: parent
        
        // Hint at bottom edge
        Rectangle {
            id: hint
            width: hintSize
            height: hintSize
            radius: hintSize / 2
            color: hintColor
            anchors.horizontalCenter: parent.horizontalCenter
            y: collapsedPosition
            
            Icon {
                id: hintIcon
                name: hintIconName
                color: hintIconColor
                width: AppConstants.defaultIconSize
                height: AppConstants.defaultIconSize
                anchors.centerIn: parent
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (expanded) {
                        collapse()
                    } else {
                        expand()
                    }
                }
                
                onPressed: {
                    pressed = true
                    switchToNormal()
                }
                
                onReleased: pressed = false
            }
            
            // Drag area for gesture
            MouseArea {
                anchors.fill: parent
                anchors.margins: -units.gu(2)
                
                property real startY: 0
                property bool dragging: false
                
                onPressed: {
                    startY = mouse.y
                    dragging = false
                    switchToNormal()
                }
                
                onPositionChanged: {
                    if (Math.abs(mouse.y - startY) > units.gu(1)) {
                        dragging = true
                    }
                    
                    if (dragging) {
                        var dragDistance = startY - mouse.y
                        if (dragDistance > units.gu(3) && !expanded) {
                            expand()
                        } else if (dragDistance < -units.gu(2) && expanded) {
                            collapse()
                        }
                    }
                }
                
                onReleased: {
                    dragging = false
                }
            }
        }
        
        // Action buttons in radial layout
        Repeater {
            id: actionRepeater
            model: actions
            
            Rectangle {
                id: actionButton
                width: actionButtonSize
                height: actionButtonSize
                radius: actionButtonSize / 2
                color: modelData.backgroundColor
                opacity: expanded ? 1 : 0
                visible: !modelData.hide
                
                // Calculate position in circle
                property real angle: index * (2 * Math.PI / actions.length) - Math.PI / 2
                property real centerX: container.width / 2
                property real centerY: expandedPosition
                
                x: centerX + actionButtonDistance * Math.cos(angle) - width / 2
                y: centerY + actionButtonDistance * Math.sin(angle) - height / 2
                
                Icon {
                    name: modelData.iconName
                    color: modelData.iconColor
                    width: units.gu(3)
                    height: units.gu(3)
                    anchors.centerIn: parent
                }
                
                MouseArea {
                    anchors.fill: parent
                    enabled: expanded
                    onClicked: {
                        modelData.triggered(modelData)
                        collapse()
                    }
                }
                
                // Label
                Label {
                    text: modelData.label
                    color: theme.palette.normal.backgroundText
                    fontSize: "small"
                    anchors.top: parent.bottom
                    anchors.topMargin: units.gu(0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: expanded && modelData.label !== ""
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }
                
                Behavior on x {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }
                
                Behavior on y {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
        
        // Leading action (e.g., back button)
        Repeater {
            model: leadingActions
            
            Rectangle {
                width: actionButtonSize
                height: actionButtonSize
                radius: actionButtonSize / 2
                color: theme.palette.normal.background
                opacity: expanded ? 1 : 0
                
                anchors.horizontalCenter: parent.horizontalCenter
                y: expandedPosition - actionButtonDistance - height / 2
                
                Icon {
                    name: model.iconName || "back"
                    color: theme.palette.normal.backgroundText
                    width: units.gu(3)
                    height: units.gu(3)
                    anchors.centerIn: parent
                }
                
                MouseArea {
                    anchors.fill: parent
                    enabled: expanded
                    onClicked: {
                        if (model.action) {
                            model.action()
                        }
                        collapse()
                    }
                }
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
    }
    
    // Animations
    NumberAnimation {
        id: expandAnimation
        target: hint
        property: "y"
        to: expandedPosition
        duration: 300
        easing.type: Easing.OutBack
    }
    
    NumberAnimation {
        id: collapseAnimation
        target: hint
        property: "y"
        to: collapsedPosition
        duration: 300
        easing.type: Easing.OutBack
    }
    
    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: timeoutSeconds * 1000
        onTriggered: {
            if (mode === "Autohide") {
                root.opacity = 0
            } else if (mode === "Semihide") {
                root.opacity = semiHideOpacity / 100.0
            }
        }
    }
    
    // Opacity behavior
    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }
    
    Component.onCompleted: {
        if (mode === "Autohide" || mode === "Semihide") {
            switchToTimeout()
        }
    }
}
