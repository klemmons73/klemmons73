import QtQuick 2.0

Item {
    property int size: 40

    property int type: 1


    property var src: "bricks.png"

    Image {
        width: parent.size
        height: parent.size

        source: src
    }
}
