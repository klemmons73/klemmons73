import QtQuick 2.0

Item {
    id: manager

    property var gameBoard: null

    property int brickSize: 50

    property int brickWidth: 50
    property int brickHeight: 50

    property int horizontalBricks: 0
    property int verticalBricks: 0

    property int limit: 0

    property int new_x: 0
    property int new_y: 0
    property int new_vx: 0
    property int new_vy: 0

    property var steps: [[-1,0], [0,-1], [1,0], [0,1], [-1,-1], [1,-1], [1,1], [-1,1]]


    property int brickNumber: 0
    property var bricks: []
    property var holls:  []

    property var finish: []
    property var finishStar: null
    property bool finished: false

    // external walls and main parameters
    function generateWalls() {
        // define number of bricks and its size
        horizontalBricks = Math.floor(parent.width / brickSize)
        verticalBricks = Math.floor(parent.height / brickSize)

        brickWidth = Math.floor(parent.width / horizontalBricks)
        brickHeight = Math.floor(parent.height / verticalBricks)

        // represent bricks as a matrix
        for(var i = 0; i < verticalBricks; i++) {          // row
            bricks[i] = []            
        }

        // setup borders
        var component = Qt.createComponent("Brick.qml")

        for(var col = 0; col < horizontalBricks; col++) {
            for(var row = 0; row < verticalBricks; row++) {
                if((col==0) || (col==(horizontalBricks-1)) || (row==0) || (row==(verticalBricks-1))) {
                    var x = col*brickWidth
                    var y = row*brickHeight

                    var brick = component.createObject(gameBoard, {"x":x, "y":y, "width":brickWidth, "height":brickHeight});

                    brick.setType(1)
                    bricks[row][col] = brick
                    brickNumber ++
                }
            }
        }
    }

    // black holls generation
    function addHolls() {
        var amount = Math.floor(0.05 * brickNumber)
        while(amount > 0) {
            while(true) {
                var col = Math.floor(Math.random() * horizontalBricks)
                var row = Math.floor(Math.random() * verticalBricks)
                var brick = bricks[row][col]

                if(brick && brick.type == 1 && !isAngle(col, row)) {
                    brick.setType(2)
                    holls.push(brick) // list of all holls
                    break;
                }
            }
            amount--
        }
    }

    // springs generation
    function addSprings() {
        var amount = Math.floor(0.05 * brickNumber)
        while(amount > 0) {
            while(true) {
                var col = Math.floor(Math.random() * horizontalBricks)
                var row = Math.floor(Math.random() * verticalBricks)
                var brick = bricks[row][col]

                if(brick && brick.type == 1 && !isAngle(col, row)) {
                    brick.setType(3)
                    break;
                }
            }
            amount--
        }
    }

    function isAngle(c,r) {
        return (c == 0 && r == 0) || (c == 0 && r == verticalBricks-1) || (c == horizontalBricks-1 && r == 0) || (c == horizontalBricks-1 && r == verticalBricks-1)
    }

    // collision checking
    function getCollision(x0,y0,x1,y1, diam) {

        if(isFinished(x1,y1)) {
            finished = true
            return false
        }

        var b_row = Math.floor((y0+diam*0.5) / brickHeight)
        var b_col = Math.floor((x0+diam*0.5) / brickWidth)

        var b_l = x1
        var b_r = x1+diam
        var b_t = y1
        var b_b = y1+diam

        var dent_hor = 0
        var dent_ver = 0

        var get_spring = false
        var obj_holl

        steps.forEach(function (step) {
            var i = b_row + step[0]
            var j = b_col + step[1]

            var brick
            if(bricks[i]) { brick = bricks[i][j] }
            if(brick) {
                // external borders
                var left = Math.min(b_l, j*brickWidth);
                var right = Math.max(b_r, (j+1)*brickWidth);
                var top = Math.min(b_t, i*brickHeight);
                var bottom = Math.max(b_b, (i+1)*brickHeight);

                // shift
                var diff_h = right - left - brickWidth - diam
                var diff_v = bottom - top - brickHeight - diam

                if(diff_h < limit && diff_v < limit) {
                    // check direction of collision
                    dent_hor += diff_h;                    
                    dent_ver += diff_v;

                    // for spring
                    if(brick.type == 3) {
                        // mark if sufficient
                        get_spring = (diff_h + 0.3*brickWidth < 0 || diff_v + 0.3*brickHeight < 0)
                    }

                    // for black hole
                    if(brick.type == 2) {
                        // copy object if sufficient
                        if(diff_h + 0.3*brickWidth < 0 || diff_v + 0.3*brickHeight < 0)
                        { obj_holl = brick }
                    }
                }
            }
        })

        // no collision
        if(dent_hor==0 && dent_ver==0) return false;

        // velocity
        var dx = x1-x0
        var dy = y1-y0

        // interracion with black hole
        if(obj_holl) {
            hollExit(obj_holl, dx, dy)
            return true
        }

        // correct position and velocity
        if(dent_ver + diam == 0 || dent_ver < 2*dent_hor) {
            new_x = x0
            new_y = y1
            new_vx = -dx
            new_vy = dy            
        } else if(dent_hor + diam == 0 || dent_hor < 2*dent_ver) {
            new_x = x1
            new_y = y0
            new_vx = dx
            new_vy = -dy            
        }
        else {
            new_x = x0
            new_y = y0
            new_vx = -dx
            new_vy = -dy            
        }

        // reduce velocity after rebound
        if(new_vx != 0) { new_vx = (new_vx / Math.abs(new_vx)) * (Math.floor(Math.abs(new_vx)/1.5)) }
        if(new_vy != 0) { new_vy = (new_vy) / Math.abs(new_vy) * (Math.floor(Math.abs(new_vy)/1.5)) }

        // for spring amplify it
        if(get_spring) {
            new_vx *= 3
            new_vy *= 3
        }

        return true;
    }

    function isFinished(x,y) {
        var dist = (x-finish[0])*(x-finish[0])+(y-finish[1])*(y-finish[1])
        return dist < (brickWidth*brickHeight*0.25)
    }

    // black holl teleportation
    function hollExit(holl, dx, dy) {

        // get exit
        var exit = holl
        while(exit == holl) {
            var n = Math.floor(Math.random() * holls.length)
            exit = holls[n]
        }

        // coordinates
        var exit_x = Math.floor(exit.x + exit.width/2)
        var exit_y = Math.floor(exit.y + exit.height/2)

        var col = Math.floor(exit.x / exit.width)
        var row = Math.floor(exit.y / exit.height)

        // find free cell
        var i, j
        for(var k = 0; k < steps.length; k++) {
            i = col + steps[k][0]
            j = row + steps[k][1]

            if(!(i < 0 || i >= horizontalBricks || j < 0 || j >= verticalBricks || bricks[j][i])) break;
        }

        // new ball position
        var ball_x = Math.floor((i+0.5)*brickWidth)
        var ball_y = Math.floor((j+0.5)*brickHeight)

        // new velocity
        var dv = Math.sqrt(dx*dx+dy*dy)*1.5
        var hyp = Math.sqrt((exit_x-ball_x)*(exit_x-ball_x) + (exit_y-ball_y)*(exit_y-ball_y));

        new_x = ball_x
        new_y = ball_y
        new_vx = Math.floor(dv*(ball_x-exit_x)/hyp)
        new_vy = Math.floor(dv*(ball_y-exit_y)/hyp)
    }

    function generateMaze() {

        //starComponent = Qt.createComponent("FinishStar.qml")

        var field = []
        var stack = []

        var width = horizontalBricks-2-(horizontalBricks % 2 == 0 ? 1 : 0)
        var height = verticalBricks-2-(verticalBricks % 2 == 0 ? 1 : 0)

        // initialize grid
        for(var j = 0; j < height; j++) {
            field[j] = []
            for(var i = 0; i < width; i++) {
                field[j][i] = (i % 2 == 0 && j % 2 == 0) ? 0 : -1
            }
        }

        // generate
        var current = [0,0]
        field[0][0] = 1 // visited
        var notAll = true
        var dirs = [[-2,0],[2,0],[0,-2],[0,2]]
        var path = 1

        while(notAll) {
            notAll = false
            field[current[0]][current[1]] = path

            var start = Math.floor(Math.random() * dirs.length) // randomize first index

            for(var k = 0; k < dirs.length; k++) {
                var v = (start+k) % dirs.length
                var next = [current[0] + dirs[v][0], current[1] + dirs[v][1]]
                if(next[0] >= 0 && next[0] < height && next[1] >= 0 && next[1] < width && field[next[0]][next[1]] == 0) {
                    notAll = true

                    // remove wall
                    if(current[0] == next[0])
                        field[current[0]][(current[1]+next[1])/2] = path
                    else
                        field[(current[0]+next[0])/2][current[1]] = path

                    // remember it
                    stack.push(current)
                    current = next
                    path ++
                    break;
                }
            }

            if(!notAll && stack.length > 0) {                
                current = stack.pop()                
                notAll = true
                path = field[current[0]][current[1]]
            }

        }

        // save
        var component = Qt.createComponent("Brick.qml")

        for(var col = 0; col < width; col++) {
            for(var row = 0; row < height; row++) {
                if(field[row][col] == -1) {
                    var x = (col+1)*brickWidth
                    var y = (row+1)*brickHeight

                    var brick = component.createObject(gameBoard, {"x":x, "y":y, "width":brickWidth, "height":brickHeight});

                    brick.setType(1)
                    bricks[row+1][col+1] = brick
                    brickNumber ++                    
                }
            }
        }

        // get longest path
        var m_path = 0
        var m_x = 0, m_y = 0

        for(var px = 0; px < height; px++) {
            for(var py = 0; py < width; py++) {
                if(field[px][py] > m_path) {
                    m_x = px
                    m_y = py
                    m_path = field[px][py]
                }
            }
        }
        console.log(m_x, m_y)
        finish = [m_x+1, m_y+1]
    }

    function setupFinish() {
        var component = Qt.createComponent("FinishStar.qml")
        if(finish) {
            var width = brickWidth * 0.9
            var height = brickHeight * 0.9
            var x = finish[1] * brickWidth + (brickWidth-width)*0.5
            var y = finish[0] * brickHeight + (brickHeight-height)*0.5

            finishStar = component.createObject(gameBoard, {"x":x, "y":y, "width":width, "height":height})
            finish = [x,y]
        }
    }
}
