import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property int lastVolume: -1
    property bool lastMuted: false
    property bool initialized: false
    property int notifId: -1

    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim();
                const isMuted = out.includes("[MUTED]");
                const m = out.match(/Volume:\s+([\d.]+)/);
                if (!m)
                    return;
                const pct = Math.round(parseFloat(m[1]) * 100);

                if (!root.initialized) {
                    root.lastVolume = pct;
                    root.lastMuted = isMuted;
                    root.initialized = true;
                    return;
                }

                if (pct === root.lastVolume && isMuted === root.lastMuted)
                    return;

                root.lastVolume = pct;
                root.lastMuted = isMuted;

                let fdIcon;
                if (isMuted) {
                    fdIcon = "audio-volume-muted";
                } else if (pct <= 33) {
                    fdIcon = "audio-volume-low";
                } else if (pct <= 66) {
                    fdIcon = "audio-volume-medium";
                } else {
                    fdIcon = "audio-volume-high";
                }

                const summary = isMuted ? "Volume Muted" : `Volume ${pct}%`;
                const value = isMuted ? 0 : pct;

                let cmd = ["notify-send", "-a", "System", "-t", "3000", "-e", "-p",
                           "-h", `int:value:${value}`, "-i", fdIcon];
                if (root.notifId >= 0)
                    cmd.push("-r", root.notifId.toString());
                cmd.push(summary);

                notifyProcess.command = cmd;
                notifyProcess.running = true;

                Logger.i("Volume", `${summary} (id: ${root.notifId})`);
            }
        }
    }

    Process {
        id: notifyProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const id = parseInt(this.text.trim());
                if (!isNaN(id))
                    root.notifId = id;
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: volumeProcess.running = true
    }
}
