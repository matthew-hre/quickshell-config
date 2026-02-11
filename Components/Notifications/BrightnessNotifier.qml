import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property int lastBrightness: -1
    property int notifId: -1
    property bool initialized: false

    readonly property string brightnessIconPath:
        "/home/matthew_hre/.local/share/icons/ePapirus/24x24/panel/brightness-high-symbolic.svg"

    function sendNotification(pct: int) {
        const summary = `Brightness ${pct}%`;
        let cmd = ["notify-send", "-a", "System", "-t", "3000", "-p", "-e",
                   "-h", `int:value:${pct}`, "-i", brightnessIconPath, summary];
        if (notifId >= 0)
            cmd.splice(7, 0, "-r", notifId.toString());
        notifProcess.command = cmd;
        notifProcess.running = true;
    }

    Process {
        id: brightnessProcess
        command: ["brightnessctl", "-m", "info"]
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
        interval: 200
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
