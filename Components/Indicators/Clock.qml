import QtQuick
import qs.Commons

Text {
    property var date: Time.date

    text: formatTime(date)
    color: Style.textPrimary
    font.pointSize: Style.baseFontSize
    font.family: Style.fontFamily

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            parent.text = formatTime(date);
        }
    }

    function formatTime(date) {
        return date.toLocaleTimeString(Qt.locale(), "hh:mm:ss A").replace(/\./g, "");
    }
}
