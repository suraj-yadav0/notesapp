import QtQuick 2.9
import Lomiri.Components 1.3

Page {
    id: testPage
    header: PageHeader {
        title: "Rich Text Editor Test"
    }

    RichTextEditor {
        id: richTextEditor
        anchors {
            fill: parent
            topMargin: testPage.header.height
            margins: units.gu(2)
        }
        
        editMode: true
        initialText: "Welcome to the improved Rich Text Editor!\n\nTry the formatting buttons above."
        
        onContentChanged: {
            console.log("Content changed:", text.length, "characters")
        }
        
        onSelectionChanged: {
            console.log("Selection changed")
        }
    }
    
    // Test the API
    Component.onCompleted: {
        console.log("Rich Text Editor loaded with text:", richTextEditor.getText())
    }
}
