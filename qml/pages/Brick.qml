import QtQuick 2.0

Item {

    property int type: 1     // type of brick

    //property int col: 0
    //property int row: 0


    property string src: "bricks.png"

    width: 40
    height: 40

    Image {
        width: parent.width
        height: parent.height

        source: src
    }
/*
    function setCell(c, r) {
        col = c
        row = r
    }
*/
    function setType(n) {
        type = n
        switch(n) {
        // black hole
        case 2:
            src = "hole.png"
            break;
        // spring
        case 3:
            src = "spring.png"
            break;
        // bricks otherwise
        default:
            type = 1
            src = "bricks.png"
            break;
        }
    }
}
