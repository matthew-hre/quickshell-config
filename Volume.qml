import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: volumeText
    text: "󰝟 0%"
    color: "#fff"
    font.pointSize: 10.5
    font.family: "Work Sans"

    Process {
        id: volumeProcess
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let volumeMutedIcon = "󰝟";
                let volumeLevels = ["󰕿", "󰖀", "󰕾"];

                let output = this.text.trim();

                // "Volume: 0.10 [MUTED]" or "Volume: 0.10"
                let isMuted = output.includes("[MUTED]");
                let volumeMatch = output.match(/Volume:\s+([\d.]+)/);

                if (!volumeMatch) {
                    console.log("Failed to parse volume output");
                    return;
                }

                let volumePercent = Math.round(parseFloat(volumeMatch[1]) * 100);
                let icon;

                if (isMuted) {
                    icon = volumeMutedIcon;
                } else if (volumePercent === 0) {
                    icon = volumeLevels[0];
                } else if (volumePercent < 50) {
                    icon = volumeLevels[1];
                } else {
                    icon = volumeLevels[2];
                }

                volumeText.text = icon + " " + volumePercent + "%";
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            volumeProcess.running = true;
        }
    }
}
