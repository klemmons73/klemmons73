import QtQuick 2.0
import QtSensors 5.0

Item {
    id: b

    property int diametr: 40

    property int xVelocity: 0
    property int yVelocity: 0

    property int acceleration: 1
    property int speedLimit: 20

    property bool leftPressed: false
    property bool rightPressed: false
    property bool upPressed: false
    property bool downPressed: false

    property var bricks: null

    Image {
        source: "ball.png"

        width: parent.diametr
        height: parent.diametr
    }

    RotationSensor {
        id: rotation
        active: true


    }





    Keys.onPressed: {

        if (event.isAutoRepeat) {
            return;
        }

        switch(event.key) {
        case Qt.Key_Left:
            leftPressed = true
            break;
        case Qt.Key_Right:
            rightPressed = true
            break;
        case Qt.Key_Down:
            downPressed = true
            break;
        case Qt.Key_Up:
            upPressed = true
            break;
        }
    }

    Keys.onReleased: {
        if (event.isAutoRepeat) {
            return;
        }

        switch(event.key) {
        case Qt.Key_Left:
            leftPressed = false
            break;
        case Qt.Key_Right:
            rightPressed = false
            break;
        case Qt.Key_Down:
            downPressed = false
            break;
        case Qt.Key_Up:
            upPressed = false
            break;
        }
    }


    Timer {
        interval: 40
        triggeredOnStart: true
        running: true
        repeat: true

        onTriggered: {
            speedUpdate()

            if(bricks.getCollision(b.x, b.y, b.x+xVelocity, b.y+yVelocity, diametr)) {
                b.x = bricks.new_x
                b.y = bricks.new_y
                xVelocity = bricks.new_vx
                yVelocity = bricks.new_vy
                //console.log(xVelocity, yVelocity)
                //console.log("collision", bricks.new_x, bricks.new_y, bricks.new_vx, bricks.new_vy)
            }
            else {
                b.x += xVelocity
                b.y += yVelocity
            }
        }

    }

    function speedUpdate() {
        rotationUpdate()
        if(rightPressed) { xVelocity = Math.min(xVelocity+acceleration, speedLimit) }
        if(leftPressed) { xVelocity = Math.max(xVelocity-acceleration, -speedLimit) }
        if(upPressed) { yVelocity = Math.max(yVelocity-acceleration, -speedLimit) }
        if(downPressed) { yVelocity = Math.min(yVelocity+acceleration, speedLimit) }

        if(!rightPressed && !leftPressed && (xVelocity != 0)) {
            if(xVelocity < 0)
                xVelocity += acceleration
            else
                xVelocity -= acceleration
        }

        if(!upPressed && !downPressed && yVelocity != 0) {
            if(yVelocity < 0)
                yVelocity += acceleration
            else
                yVelocity -= acceleration
        }
    }

    function rotationUpdate() {
        upPressed = (rotation.reading.x > 10)
        downPressed = (rotation.reading.x < -10)
        leftPressed = (rotation.reading.y > 10)
        rightPressed = (rotation.reading.y < -10)
    }



}
