import QtQuick 2.0

Item {
    id: manager

    property var gameBoard: null

    property int brickSize: 50

    property int horizontalBricks: 0
    property int verticalBricks: 0

    property int limit: 0

    property int new_x: 0
    property int new_y: 0
    property int new_vx: 0
    property int new_vy: 0

    //property var walls: []

    property var bricks: []

    function generateWalls() {

        horizontalBricks = Math.floor(parent.width / brickSize)
        verticalBricks = Math.floor(parent.height / brickSize)

        for(var i = 0; i < verticalBricks; i++) {          // row
            bricks[i] = []
            /*
            for(var j = 0; j < horizontalBricks; j++) {    // col
                bricks[i][j] = null
            }*/
        }

        var component = Qt.createComponent("Brick.qml")

        for(var col = 0; col < horizontalBricks; col++) {
            for(var row = 0; row < verticalBricks; row++) {
                if((col==0) || (col==(horizontalBricks-1)) || (row==0) || (row==(verticalBricks-1)) /*|| ((col%2==0) && (row%2==0))*/) {
                    var x = col*brickSize
                    var y = row*brickSize

                    var brick = component.createObject(gameBoard, {"x":x, "y":y, "size": brickSize});

                    brick.setType(1)
                    bricks[row][col] = brick
                }
            }
        }
    }

    function getCollision(x0,y0,x1,y1, diam) {

        var b_row = Math.floor((y0+diam/2) / brickSize)
        var b_col = Math.floor((x0+diam/2) / brickSize)

        var b_l = x1
        var b_r = x1+diam
        var b_t = y1
        var b_b = y1+diam

        var dent_hor = 0
        var dent_ver = 0

        for(var i = -1; i <= 1; i++) {
            for(var j = -1; j <= 1; j++) {
                var brick = bricks[b_row+i][b_col+j]
                if(brick) {
                    var left = Math.min(b_l, brick.x);
                    var right = Math.max(b_r, brick.x+brick.width);
                    var top = Math.min(b_t, brick.y);
                    var bottom = Math.max(b_b, brick.y+brick.height);

                    var diff_h = right - left - brick.width - diam
                    var diff_v = bottom - top - brick.height - diam

                    if(diff_h < limit && diff_v < limit) {
                        dent_hor += diff_h;
                        dent_ver += diff_v;
                    }
                }
            }
        }

        if(dent_hor==0 && dent_ver==0) return false;

        var dx = x1-x0
        var dy = y1-y0

        //console.log(dent_hor, dent_ver)

        if(dent_ver + diam == 0 || dent_ver < 2*dent_hor) {
            new_x = x0
            new_y = y1
            new_vx = -dx
            new_vy = dy
            //console.log("horizontal")
        } else if(dent_hor + diam == 0 || dent_hor < 2*dent_ver) {
            new_x = x1
            new_y = y0
            new_vx = dx
            new_vy = -dy
            //console.log("vertical")
        }
        else {
            new_x = x0
            new_y = y0
            new_vx = -dx
            new_vy = -dy
            //console.log("combined")
        }

        if(new_vx != 0) { new_vx = (new_vx / Math.abs(new_vx)) * (Math.floor(Math.abs(new_vx)/1.5)) }
        if(new_vy != 0) { new_vy = (new_vy) / Math.abs(new_vy) * (Math.floor(Math.abs(new_vy)/1.5)) }

        return true;

    }

}
