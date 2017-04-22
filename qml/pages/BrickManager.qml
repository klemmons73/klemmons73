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

    property var steps: [[-1,0],[0,-1],[1,0],[0,1],[-1,-1],[1,-1],[1,1],[-1,1]]


    property var bricks: []
    property var holls:  []

    function generateWalls() {

        horizontalBricks = Math.floor(parent.width / brickSize)
        verticalBricks = Math.floor(parent.height / brickSize)

        for(var i = 0; i < verticalBricks; i++) {          // row
            bricks[i] = []            
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

    function addHolls(amount) {
        while(amount > 0) {
            while(true) {
                var col = Math.floor(Math.random() * horizontalBricks)
                var row = Math.floor(Math.random() * verticalBricks)
                var brick = bricks[row][col]

                if(brick && brick.type == 1) {
                    brick.setType(2)
                    holls.push(brick)
                    break;
                }
            }
            amount--
        }
    }

    function addSprings(amount) {
        while(amount > 0) {
            while(true) {
                var col = Math.floor(Math.random() * horizontalBricks)
                var row = Math.floor(Math.random() * verticalBricks)
                var brick = bricks[row][col]

                if(brick && brick.type == 1) {
                    brick.setType(3)
                    break;
                }
            }
            amount--
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

        var get_spring = false
        var obj_holl

        //for(var i = b_row-1; i <= b_row+1; i++) {
            //for(var j = b_col-1; j <=b_col+1; j++) {
            for(var k = 0; k < steps.length; k++) {
                var i = b_row + steps[k][0]
                var j = b_col + steps[k][1]

                if(i < 0 || i >= verticalBricks || j < 0 || j >= horizontalBricks)
                    continue;

                var brick = bricks[i][j]
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

                        if(brick.type == 3) {
                            get_spring = (diff_h + 0.3*brick.width < 0 || diff_v + 0.3*brick.height < 0)
                        }

                        if(brick.type == 2) {
                            if(diff_h + 0.3*brick.width < 0 || diff_v + 0.3*brick.height < 0)
                            { obj_holl = brick }
                        }
                    }
                }
            }
        //}

        if(dent_hor==0 && dent_ver==0) return false;

        var dx = x1-x0
        var dy = y1-y0

        if(obj_holl) {
            hollExit(obj_holl, dx, dy)
            return true
        }

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

        if(get_spring) {
            new_vx *= 3
            new_vy *= 3
        }

        return true;
    }

    function hollExit(holl, dx, dy) {
        var exit = holl

        while(exit == holl) {
            var n = Math.floor(Math.random() * holls.length)
            exit = holls[n]
            console.log(n)
        }

        var exit_x = Math.floor(exit.x + exit.width/2)
        var exit_y = Math.floor(exit.y + exit.height/2)

        var col = Math.floor(exit.x / exit.width)
        var row = Math.floor(exit.y / exit.height)

        console.log(col, row)

        var i, j
        for(var k = 0; k < steps.length; k++) {
            i = col + steps[k][0]
            j = row + steps[k][1]

            if(!(i < 0 || i >= horizontalBricks || j < 0 || j >= verticalBricks || bricks[j][i])) break;
        }


        console.log(i,j)

        var ball_x = Math.floor((i+0.5)*exit.width)
        var ball_y = Math.floor((j+0.5)*exit.height)

        var dv = Math.sqrt(dx*dx+dy*dy)
        var hyp = Math.sqrt((exit_x-ball_x)*(exit_x-ball_x) + (exit_y-ball_y)*(exit_y-ball_y));

        new_x = ball_x
        new_y = ball_y
        new_vx = Math.floor(dv*(ball_x-exit_x)/hyp)
        new_vy = Math.floor(dv*(ball_y-exit_y)/hyp)

        console.log(new_x, new_y, new_vx, new_vy)

    }

}
