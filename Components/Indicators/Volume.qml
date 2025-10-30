import QtQuick
import Quickshell
import Quickshell.Io
import "../../Commons"

Item {
    id: root
    // size to content
    implicitWidth: volumeText.implicitWidth
    implicitHeight: volumeText.implicitHeight

    Text {
        id: volumeText
        text: "󰝟 0%"
        color: Style.textPrimary
        font.pointSize: Style.baseFontSize
        font.family: Style.fontFamily
    }

    // Existing poller
    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const volumeMutedIcon = "󰝟";
                const volumeLevels = ["󰕿", "󰖀", "󰕾"];
                const out = this.text.trim();
                const isMuted = out.includes("[MUTED]");
                const m = out.match(/Volume:\s+([\d.]+)/);
                if (!m)
                    return;
                const pct = Math.round(parseFloat(m[1]) * 100);
                let icon = isMuted ? volumeMutedIcon : (pct === 0 ? volumeLevels[0] : (pct < 50 ? volumeLevels[1] : volumeLevels[2]));
                volumeText.text = `${icon} ${pct}%`;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: volumeProcess.running = true
    }
}
