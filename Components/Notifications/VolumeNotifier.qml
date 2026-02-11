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
    property int pollIntervalMs: 200
    property int notifyTimeoutMs: 3000
    property string notifyAppName: "System"
    property string sinkId: "@DEFAULT_AUDIO_SINK@"
    property int lowThreshold: 33
    property int mediumThreshold: 66
    property string iconMuted: "audio-volume-muted"
    property string iconLow: "audio-volume-low"
    property string iconMedium: "audio-volume-medium"
    property string iconHigh: "audio-volume-high"

    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", root.sinkId]
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
                    fdIcon = root.iconMuted;
                } else if (pct <= root.lowThreshold) {
                    fdIcon = root.iconLow;
                } else if (pct <= root.mediumThreshold) {
                    fdIcon = root.iconMedium;
                } else {
                    fdIcon = root.iconHigh;
                }

                const summary = isMuted ? "Volume Muted" : `Volume ${pct}%`;
                const value = isMuted ? 0 : pct;

                let cmd = ["notify-send", "-a", root.notifyAppName, "-t", root.notifyTimeoutMs.toString(), "-e", "-p",
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
        interval: root.pollIntervalMs
        running: true
        repeat: true
        onTriggered: volumeProcess.running = true
    }
}
