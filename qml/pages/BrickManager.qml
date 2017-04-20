import QtQuick 2.0

Item {
    id: manager

    property var gameBoard: null

    property int brickSize: 50

    property int horizontalBricks: 0
    property int verticalBricks: 0


    property var walls: []



    function generateWalls() {

        horizontalBricks = Math.floor(parent.width / brickSize)
        verticalBricks = Math.floor(parent.height / brickSize)

        var component = Qt.createComponent("Brick.qml")

        for(var col = 0; col < horizontalBricks; col++) {
            for(var row = 0; row < verticalBricks; row++) {
                if((col==0) || (col==(horizontalBricks-1)) || (row==0) || (row==(verticalBricks-1)) || ((col%2==0) && (row%2==0))) {
                    var x = col*brickSize
                    var y = row*brickSize

                    var sprite = component.createObject(gameBoard, {"x":x, "y":y, "size": brickSize});
                    walls.push(sprite)
                }
            }
        }
    }

}
