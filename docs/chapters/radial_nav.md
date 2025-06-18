# RadialAction & RadialBottomEdge — Complete Documentation and Reference

## Overview
These two QML files work together to provide a modern, interactive radial menu at the bottom edge of the Talaan app. The radial menu is a circular arrangement of action buttons that expands from the bottom edge, offering quick access to key actions.

---

## RadialAction.qml
**Purpose:**
Defines a reusable action object for use in radial menus.

**Key Properties:**
- `iconName`: The icon to display (string)
- `iconColor`: The color of the icon, theme-aware
- `backgroundColor`: The background color of the button, theme-aware
- `label`: The text label for the action
- `hide`: Boolean to show/hide the action
- `visible`: Action is visible if `hide` is false

**Signals:**
- `triggered(var parameter)`: Emitted when the action is activated (usually by clicking)

**Usage Example:**
```qml
RadialAction {
    iconName: "note"
    label: "Lists"
    onTriggered: {
        // Your action code here
    }
}
```

---

## RadialBottomEdge.qml
**Purpose:**
Implements a custom bottom edge menu with a radial (circular) layout for actions.

**Key Features:**
- Draggable/clickable hint at the bottom edge
- Expands to show a set of `RadialAction` buttons in a circle
- Drag-to-expand/collapse, click-to-toggle
- Autohide/semi-hide/always-visible modes
- Theme-aware styling and animation
- Handles user interaction and action triggering
- Can show a leading (back) action button

**Key Properties:**
- `actions`: List of `RadialAction` objects to display
- `leadingActions`: ListModel for special leading actions (e.g., back)
- `mode`: "Always", "Autohide", or "Semihide" (controls visibility)
- `semiHideOpacity`, `timeoutSeconds`: Control hiding behavior
- `bgColor`, `bgOpacity`: Background appearance
- `hintIconName`, `hintIconColor`: Customize the hint icon
- `expandedPosition`, `collapsedPosition`: Control the expanded/collapsed Y positions
- `actionButtonSize`, `actionButtonDistance`: Control the size and distance of action buttons

**Signals/Functions:**
- `expand()`, `collapse()`: Expand/collapse the menu
- `switchToNormal()`, `switchToTimeout()`: Control opacity and timer

**How it Works:**
- Shows a hint at the bottom edge. Drag up or click to expand.
- When expanded, actions appear in a circle. Clicking an action triggers it and collapses the menu.
- Menu auto-collapses after a timeout, with opacity depending on mode.
- Leading action (like back) can be shown in a special position.

**Usage Example:**
```qml
RadialBottomEdge {
    id: radialMenu
    actions: [
        RadialAction { iconName: "note"; label: "Lists"; onTriggered: { /* ... */ } },
        RadialAction { iconName: "history"; label: "History"; onTriggered: { /* ... */ } },
        RadialAction { iconName: "bookmark"; label: "Saved"; onTriggered: { /* ... */ } },
        RadialAction { iconName: "settings"; label: "Settings"; onTriggered: { /* ... */ } }
    ]
    mode: "Autohide"
    semiHideOpacity: 40
    timeoutSeconds: 3
    bgColor: "#222"
    bgOpacity: 0.8
    hintIconName: "view-grid-symbolic"
    hintIconColor: UbuntuColors.coolGrey
}
```

---

## Full QML Code
### RadialAction.qml
```qml
import QtQuick 2.4
import Ubuntu.Components 1.3

Action {
    property string iconName: "add"
    property color iconColor: switch (settings.currentTheme) {
                              case "Default":
                                  "black"
                                  break
                              case "Ambiance":
                              case "System":
                              case "SuruDark":
                                  theme.palette.highlighted.overlayText
                                  break
                              default:
                                  "black"
                              }
    property color backgroundColor: switch (settings.currentTheme) {
                                    case "Default":
                                        "white"
                                        break
                                    case "Ambiance":
                                    case "System":
                                    case "SuruDark":
                                        theme.palette.highlighted.overlay
                                        break
                                    default:
                                        "white"
                                    }
    property bool hide: false
    property string label: ""
    text: label
    visible: !hide
}
```

### RadialBottomEdge.qml (Key Sections)
```qml
import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root
    property int hintSize: units.gu(8)
    property color hintColor: Theme.palette.normal.overlay
    property string hintIconName: "view-grid-symbolic"
    property alias hintIconSource: hintIcon.source
    property color hintIconColor: UbuntuColors.coolGrey
    property bool bottomEdgeEnabled: true
    property color bgColor: "black"
    property real bgOpacity: 0.7
    property string mode: "Always"
    property int semiHideOpacity: 50
    property int timeoutSeconds: 2
    property real expandedPosition: 0.6 * height
    property real collapsedPosition: height - hintSize / 2
    property list<RadialAction> actions
    property ListModel leadingActions
    property real actionButtonSize: units.gu(7)
    property real actionButtonDistance: 1.5 * hintSize
    anchors.fill: parent
    // ...full implementation includes UI, animation, drag logic, action repeater, and timer...
}
```

---

## Advanced: Customizing Action Behavior
You can connect to the `onTriggered` signal of each `RadialAction` to perform custom logic. For example:
```qml
RadialAction {
    iconName: "add"
    label: "Add Item"
    onTriggered: {
        // Open a dialog or add a new item
        myDialog.open()
    }
}
```

## Advanced: Dynamic Actions
You can dynamically generate actions in JavaScript and assign them to the `actions` property:
```qml
Component.onCompleted: {
    var actionList = [];
    for (var i = 0; i < 5; ++i) {
        actionList.push(RadialAction {
            iconName: "star"
            label: "Action " + i
            onTriggered: function() { console.log("Action " + i + " triggered") }
        });
    }
    radialMenu.actions = actionList;
}
```

---

## Integration Notes
- Use `RadialAction` for each action you want in the radial menu.
- Provide a list of these actions to the `actions` property of `RadialBottomEdge`.
- Customize appearance and behavior using the properties described above.
- You can use the `leadingActions` property to add a special back or main action.

For full details, see the source files in `talaan/components/`.
