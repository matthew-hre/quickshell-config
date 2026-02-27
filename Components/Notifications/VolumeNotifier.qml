import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Commons

Item {
    id: root

    property int lastPct: -1
    property bool lastMuted: false
    property bool initialized: false
    property int notifId: -1
    property int notifyTimeoutMs: 3000
    property string notifyAppName: "System"
    property int lowThreshold: 33
    property int mediumThreshold: 66
    property string iconMuted: "audio-volume-muted"
    property string iconLow: "audio-volume-low"
    property string iconMedium: "audio-volume-medium"
    property string iconHigh: "audio-volume-high"

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property int pct: Math.round((Pipewire.defaultAudioSink?.audio?.volume ?? 0) * 100)
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    onPctChanged: handleChange()
    onMutedChanged: handleChange()

    function handleChange() {
        if (!initialized) {
            lastPct = pct;
            lastMuted = muted;
            initialized = true;
            return;
        }

        if (pct === lastPct && muted === lastMuted)
            return;

        lastPct = pct;
        lastMuted = muted;

        if (Settings.audioPanelOpen)
            return;

        let fdIcon;
        if (muted) {
            fdIcon = iconMuted;
        } else if (pct <= lowThreshold) {
            fdIcon = iconLow;
        } else if (pct <= mediumThreshold) {
            fdIcon = iconMedium;
        } else {
            fdIcon = iconHigh;
        }

        const summary = muted ? "Volume Muted" : `Volume ${pct}%`;
        const value = muted ? 0 : pct;

        let cmd = ["notify-send", "-a", notifyAppName, "-t", notifyTimeoutMs.toString(), "-e", "-p",
                   "-h", `int:value:${value}`, "-i", fdIcon];
        if (notifId >= 0)
            cmd.push("-r", notifId.toString());
        cmd.push(summary);

        notifyProcess.command = cmd;
        notifyProcess.running = true;

        Logger.i("Volume", `${summary} (id: ${notifId})`);
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
}
