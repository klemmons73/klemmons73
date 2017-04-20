import QtQuick 2.0

Item {
    property int size: 40

    property int type: 1

    property int col: 0
    property int row: 0


    property var src: "bricks.png"

    width: size
    height: size

    Image {
        width: parent.size
        height: parent.size

        source: src
    }

    function setCell(c, r) {
        col = c
        row = r
    }
}
