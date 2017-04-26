import QtQuick 2.0

Item {
    z: 2

    Image {
        source: "star.png"

        width: parent.width
        height: parent.height
/*
        SpringAnimation on y {
            spring: 2
            damping: 0.5
            loops: Animation.Infinite
            running: true
        }
*/
    }

}
