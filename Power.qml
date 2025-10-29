import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: powerText
    text: "0%"
    color: "#fff"
    font.pointSize: 10.5
    font.family: "Work Sans"

    Process {
        id: capacityProcess
        command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                updateDisplay();
            }
        }
    }

    Process {
        id: statusProcess
        command: ["cat", "/sys/class/power_supply/BAT1/status"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                updateDisplay();
            }
        }
    }

    function updateDisplay() {
        let chargingIcon = "󱐋  ";
        let batteryIcons = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"];
        let batteryPercent = parseInt(capacityProcess.stdout.text.trim());
        let isCharging = statusProcess.stdout.text.trim() === "Charging";
        let displayText = "";

        if (isCharging) {
            displayText = chargingIcon + batteryPercent + "%";
        } else {
            let iconIndex = Math.floor(batteryPercent / 10);
            iconIndex = Math.min(iconIndex, batteryIcons.length - 1);
            displayText = batteryIcons[iconIndex] + "  " + batteryPercent + "%";
        }

        powerText.text = displayText;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            capacityProcess.running = true;
            statusProcess.running = true;
        }
    }
}
