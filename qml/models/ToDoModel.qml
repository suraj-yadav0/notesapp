import QtQuick 2.7
import Qt.labs.settings 1.0

Item {
    id: root

    // Expose the ListModel for use in ListView
    property alias model: todoModel
    property int count: todoModel.count

    // Settings for persistent storage
    Settings {
        id: settings
        property var todoItems: []
    }

    // Main list model
    ListModel {
        id: todoModel

        Component.onCompleted: {
            loadFromSettings()
        }

        function loadFromSettings() {
            // Load saved items from settings
            if (settings.todoItems && settings.todoItems.length > 0) {
                for (var i = 0; i < settings.todoItems.length; i++) {
                    var item = settings.todoItems[i]
                    // Ensure completed is a boolean
                    var completed = typeof item.completed === 'boolean' ? item.completed : (item.completed === 'true' || item.completed === true)
                    append({
                        text: item.text || "",
                        completed: completed
                    })
                }
            } else {
                // Default items if no saved data
                append({text: "Grocery shopping", completed: false})
                append({text: "Book doctor's appointment", completed: false})
                append({text: "Pay bills", completed: false})
                append({text: "Call mom", completed: false})
                append({text: "Finish project report", completed: false})
            }
        }

        function saveToSettings() {
            var items = []
            for (var i = 0; i < count; i++) {
                items.push({
                    text: get(i).text,
                    completed: get(i).completed
                })
            }
            settings.todoItems = items
        }

        function addItem(text) {
            append({text: text, completed: false})
            saveToSettings()
        }

        function toggleItem(index) {
            setProperty(index, "completed", !get(index).completed)
            saveToSettings()
        }

        function removeItem(index) {
            remove(index)
            saveToSettings()
        }
    }

    // Expose methods for use in views
    function addItem(text) { todoModel.addItem(text) }
    function toggleItem(index) { todoModel.toggleItem(index) }
    function removeItem(index) { todoModel.removeItem(index) }
}