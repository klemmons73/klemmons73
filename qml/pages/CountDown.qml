import QtQuick 2.0

Item {

    property int rest: 100
    property bool timeOut: false

    z: 1

    Text {
        id: monitor

        text: "0:00:00"
        color: "white"
        font.bold: true

    }

    Timer {
        id: timer

        interval: 1000
        repeat: true
        //running: true
        //triggeredOnStart: true

        onTriggered: rest -= 1
    }

    function start(duration) {
        rest = duration
        timer.running = true
    }

    function timeString(t) {
        var h = Math.floor(t / 3600)
        var m = Math.floor((t % 3600) / 60)
        var s = Math.floor((t % 3600) % 60)

        var str = h.toString() + ":"
        str += (m >= 10) ? m.toString() : ("0" + m.toString())
        str += ":"
        str += (s >= 10) ? s.toString() : ("0" + s.toString())

        return str
    }

    onRestChanged: {
        monitor.text = timeString(rest)
        if(rest == 0) {
            timer.running = false
            timeOut = true
        }
    }
}
