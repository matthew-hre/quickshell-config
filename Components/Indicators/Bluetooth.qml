import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: bluetoothText
    text: "󰂲"
    color: "#fff"
    font.pointSize: 10.5
    font.family: "Work Sans"

    Process {
        id: bluetoothProcess
        command: ["bluetoothctl", "show"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                updateDisplay();
            }
        }
    }

    Process {
        id: connectedDeviceProcess
        command: ["bluetoothctl", "info"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                updateDisplay();
            }
        }
    }

    function updateDisplay() {
        let bluetoothOnIcon = "󰂯";
        let bluetoothOffIcon = "󰂲";

        let showOutput = bluetoothProcess.stdout.text.trim();
        let isOn = showOutput.includes("Powered: yes");

        let icon = isOn ? bluetoothOnIcon : bluetoothOffIcon;
        let displayText = icon;

        if (isOn) {
            let deviceOutput = connectedDeviceProcess.stdout.text.trim();
            let nameMatch = deviceOutput.match(/Name:\s+(.+)/);

            if (nameMatch) {
                let deviceName = nameMatch[1].trim();
                displayText = icon + " " + deviceName;
            }
        }

        bluetoothText.text = displayText;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            bluetoothProcess.running = true;
            connectedDeviceProcess.running = true;
        }
    }
}
