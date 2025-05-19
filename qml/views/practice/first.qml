import QtQuick 2.9



Rectangle{
    id:root
    width: 400
    height: 400
    color: "grey"

    Rectangle{
        color: "lightblue"
        x:50
        y:50
        
        width: 300
        height: 300

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "lightblue"
            }
            GradientStop {
                position: 1.0
                color: "blue"
            }
        }

    }
}