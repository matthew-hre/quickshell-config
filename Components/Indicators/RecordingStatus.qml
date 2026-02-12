import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root
    implicitWidth: isRecording ? recordingText.implicitWidth : 0
    implicitHeight: isRecording ? recordingText.implicitHeight : 0

    property bool isRecording: false

    Text {
        id: recordingText
        text: ""
        color: Style.red
        font.pointSize: Style.baseFontSize
        font.family: Style.fontFamily
        opacity: isRecording ? 1 : 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (root.isRecording) {
                stopProcess.running = true;
            }
        }
    }

    // Check recording status
    Process {
        id: statusProcess
        command: ["dbus-send", "--session", "--print-reply",
                  "--dest=org.matthew_hre.NiriScreenRecorder",
                  "/org/matthew_hre/NiriScreenRecorder",
                  "org.matthew_hre.NiriScreenRecorder.IsRecording"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                const wasRecording = root.isRecording;
                root.isRecording = output.includes("true");
            }
        }
    }

    // Stop recording
    Process {
        id: stopProcess
        command: ["dbus-send", "--session", "--print-reply",
                  "--dest=org.matthew_hre.NiriScreenRecorder",
                  "/org/matthew_hre/NiriScreenRecorder",
                  "org.matthew_hre.NiriScreenRecorder.StopRecording"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                statusProcess.running = true;
            }
        }
    }

    // Poll status every 500ms
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            statusProcess.running = true
        }
    }

    Component.onCompleted: {
        statusProcess.running = true;
    }
}
