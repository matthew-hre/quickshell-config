import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property int lastBrightness: -1
    property int notifId: -1
    property bool initialized: false

    property int pollIntervalMs: 200
    property int notifyTimeoutMs: 3000
    property string notifyAppName: "System"
    property string brightnessIcon: "brightness-symbolic";
    property var brightnessCommand: ["brightnessctl", "-m", "info"]

    function sendNotification(pct: int) {
        const summary = `Brightness ${pct}%`;
        let cmd = ["notify-send", "-a", root.notifyAppName, "-t", root.notifyTimeoutMs.toString(), "-p", "-e",
                   "-h", `int:value:${pct}`, "-i", brightnessIcon, summary];
        if (notifId >= 0)
            cmd.splice(7, 0, "-r", notifId.toString());
        notifProcess.command = cmd;
        notifProcess.running = true;
    }

    Process {
        id: brightnessProcess
        command: root.brightnessCommand
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim();
                const fields = out.split(",");
                if (fields.length < 4)
                    return;
                const pct = parseInt(fields[3].replace("%", ""));
                if (isNaN(pct))
                    return;
                if (!root.initialized) {
                    root.lastBrightness = pct;
                    root.initialized = true;
                    Logger.i("Brightness", `initialized at ${pct}%`);
                    return;
                }
                if (pct !== root.lastBrightness) {
                    root.lastBrightness = pct;
                    root.sendNotification(pct);
                    Logger.i("Brightness", `changed to ${pct}%`);
                }
            }
        }
    }

    Timer {
        interval: root.pollIntervalMs
        running: true
        repeat: true
        onTriggered: brightnessProcess.running = true
    }

    Process {
        id: notifProcess
        stdout: StdioCollector {
            onStreamFinished: {
                const id = parseInt(this.text.trim());
                if (!isNaN(id))
                    root.notifId = id;
            }
        }
    }
}
