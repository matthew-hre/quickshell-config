import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Text {
    id: networkText
    text: "󰤮 "
    color: Style.textPrimary
    font.pointSize: Style.baseFontSize
    font.family: Style.fontFamily

    Process {
        id: networkProcess
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "device", "wifi", "list"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let disconnectedIcon = "󰤮  ";
                let signalStrengths = ["󰤟  ", "󰤢  ", "󰤥  ", "󰤨  "];

                let output = this.text.trim();

                let lines = output.split("\n");
                let displayText = "";
                let found = false;

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line)
                        continue;

                    // ACTIVE:SSID:SIGNAL
                    let parts = line.split(":");
                    if (parts.length < 3)
                        continue;

                    let isActive = parts[0] === "yes";

                    if (isActive) {
                        let ssid = parts[1];
                        let signal = parseInt(parts[2]);
                        let signalIndex;

                        if (signal < 25) {
                            signalIndex = 0;
                        } else if (signal < 50) {
                            signalIndex = 1;
                        } else if (signal < 75) {
                            signalIndex = 2;
                        } else {
                            signalIndex = 3;
                        }

                        displayText = signalStrengths[signalIndex] + ssid;
                        found = true;
                        break;
                    }
                }

                if (!found) {
                    displayText = disconnectedIcon;
                }

                networkText.text = displayText;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            networkProcess.running = true;
        }
    }
}
