import QtQuick 2.12

ListModel {
    id: settingsModel

    ListElement {
        category: "General"
        title: "Dark Mode"
        subtitle: "System default"
        type: "toggle"
        value: true
        icon: ""
    }

    ListElement {
        category: "Account"
        title: "Account"
        subtitle: "Logged in as user@example.com"
        type: "info"
        value: ""
        icon: "contact"
    }

    ListElement {
        category: "Appearance"
        title: "Theme"
        subtitle: "System default"
        type: "selector"
        value: "Light"
        icon: ""
    }

    ListElement {
        category: "Appearance"
        title: "Font size"
        subtitle: "16"
        type: "selector"
        value: "Medium"
        icon: ""
    }

    ListElement {
        category: "Notes"
        title: "Storage location"
        subtitle: "Local storage"
        type: "selector"
        value: "Device"
        icon: ""
    }

    ListElement {
        category: "Notes"
        title: "Backup frequency"
        subtitle: "Never"
        type: "selector"
        value: "Manual"
        icon: ""
    }

    ListElement {
        category: "Notifications"
        title: "Reminders"
        subtitle: "Off"
        type: "selector"
        value: "Disabled"
        icon: ""
    }
}
