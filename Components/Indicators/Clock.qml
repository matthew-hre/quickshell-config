import QtQuick
import "../../Commons"

Text {
    text: {
        const now = new Date();
        return now.toLocaleTimeString(Qt.locale(), "hh:mm:ss A").replace(/\./g, "");
    }
    color: Style.textPrimary
    font.pointSize: Style.baseFontSize
    font.family: Style.fontFamily

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
