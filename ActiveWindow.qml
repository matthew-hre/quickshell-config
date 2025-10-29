import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Text {
    id: windowText
    color: "#fff"
    font.pointSize: 10.5
    font.family: "Work Sans"
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
