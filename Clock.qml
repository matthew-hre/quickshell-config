import QtQuick

Text {
    text: {
        const now = new Date();
        return now.toLocaleTimeString(Qt.locale(), "hh:mm:ss A").replace(/\./g, "");
    }
    color: "#fff"
    font.pointSize: 10.5
    font.family: "Work Sans"

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date();
            parent.text = now.toLocaleTimeString(Qt.locale(), "hh:mm:ss A").replace(/\./g, "");
        }
    }
}
