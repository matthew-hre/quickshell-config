import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons

Text {
    id: windowText
    color: Style.textPrimary
    font.pointSize: Style.baseFontSize
    font.family: Style.fontFamily
    maximumLineCount: 1
    text: ""

    property string targetText: ""
    property bool isAnimating: false

    Behavior on opacity {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    function updateText(newText) {
        if (targetText === newText || isAnimating) {
            return;
        }

        targetText = newText;

        if (windowText.text === newText) {
            return;
        }

        isAnimating = true;
        windowText.opacity = 0;

        updateTimer.restart();
    }

    Timer {
        id: updateTimer
        interval: 100
        onTriggered: {
            windowText.text = targetText;
            fadeInTimer.restart();
        }
    }

    Timer {
        id: fadeInTimer
        interval: 30
        onTriggered: {
            windowText.opacity = 1.0;
            isAnimating = false;
        }
    }

    Process {
        id: niriProcess
        command: ["niri", "msg", "windows"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const focusedWindow = this.text.match(/\(focused\)[\s\S]*?Title:\s+"([^"]+)"/);
                const newText = focusedWindow ? focusedWindow[1] : "";

                windowText.updateText(newText);
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            niriProcess.running = true;
        }
    }
}
