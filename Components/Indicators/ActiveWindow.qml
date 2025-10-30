import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../Commons"

Text {
    id: windowText
    color: Style.textPrimary
    font.pointSize: Style.baseFontSize
    font.family: Style.fontFamily
    maximumLineCount: 1
    text: ""

    Process {
        id: niriProcess
        command: ["niri", "msg", "windows"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const focusedWindow = this.text.match(/\(focused\)[\s\S]*?Title:\s+"([^"]+)"/);
                windowText.text = focusedWindow ? focusedWindow[1] : "";
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            niriProcess.running = true;
        }
    }
}
