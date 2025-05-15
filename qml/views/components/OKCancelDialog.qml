import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

Dialog {
    id: dialog //the id attribute
    signal doAction() //signal

    Button {
        text: i18n.tr("OK") //dynamic property attribute
        color: theme.palette.normal.negative
        onClicked: {
            PopupUtils.close(dialog)
            doAction() 
        }
    }

    Button {
        text: i18n.tr("Cancel")
        onClicked: PopupUtils.close(dialog)
    }
}