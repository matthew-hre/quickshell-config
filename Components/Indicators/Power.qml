import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Text {
    id: powerText
    text: "0%"
    color: Style.textPrimary
    font.pointSize: Style.baseFontSize
    font.family: Style.fontFamily

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

        if (batteryPercent < 10) {
            powerText.color = Style.errorColor;
        } else if (batteryPercent < 20) {
            powerText.color = Style.warningColor;
        } else {
            powerText.color = Style.textPrimary;
        }
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
