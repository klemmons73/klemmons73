import QtQuick 2.0

Item {
    id: b

    property int diametr: 40

    property int xVelocity: 0
    property int yVelocity: 0

    property int acceleration: 1
    property int speedLimit: 5

    property bool leftPressed: false
    property bool rightPressed: false
    property bool upPressed: false
    property bool downPressed: false

    Image {
        source: "ball.png"

        width: parent.diametr
        height: parent.diametr
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
        interval: 20
        triggeredOnStart: true
        running: true
        repeat: true

        onTriggered: {
            speedUpdate()

            b.x += xVelocity
            b.y += yVelocity
        }

    }

    function speedUpdate() {
        if(rightPressed) { xVelocity = Math.max(xVelocity+acceleration, speedLimit) }
        if(leftPressed) { xVelocity = Math.min(xVelocity-acceleration, -speedLimit) }
        if(upPressed) { yVelocity = Math.min(yVelocity-acceleration, -speedLimit) }
        if(downPressed) { yVelocity = Math.max(yVelocity+acceleration, speedLimit) }

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



}
