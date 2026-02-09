import qs.Components.Indicators
import qs.Commons

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    anchors.fill: parent
    clip: true

    PanelWindow {
        id: barWindow
        implicitHeight: 30
        color: activeWindow.hasActiveWindow ? Style.panelBackground : Style.transparent

        anchors {
            top: true
            left: true
            right: true
            bottom: false
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: Style.spacingL

            Clock {}

            Item {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
            }

            Volume {}

            Network {}

            Bluetooth {}

            Power {}
        }

        ActiveWindow {
            id: activeWindow
            anchors.centerIn: parent
        }

        property bool logSampling: true
        property int sampleX: Math.round(0)
        property int sampleY: Math.round(32)
        property string sampleCommand: "grim -g \"" + sampleX + "," + sampleY + " 1x1\" -t png - | magick - -format '%[hex:p{0,0}]' info:"

        Process {
            id: colorSampleProcess
            command: ["sh", "-c", barWindow.sampleCommand]
            stdout: SplitParser {
                onRead: data => {
                    if (!data) {
                        return;
                    }
                    const hex = data.trim();
                    if (hex.length === 6 || hex.length === 8) {
                        Style.panelBackground = "#" + hex.toLowerCase();
                        if (barWindow.logSampling) {
                            Logger.i("Bar", "Sampled " + barWindow.sampleX + "," + barWindow.sampleY + " -> #" + hex.toLowerCase());
                        }
                    } else if (barWindow.logSampling) {
                        Logger.w("Bar", "Unexpected sample output: " + hex);
                    }
                }
            }
            stderr: StdioCollector {
                onStreamFinished: {
                    if (barWindow.logSampling && text.trim().length) {
                        Logger.w("Bar", "Sample error: " + text.trim());
                    }
                }
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                if (!colorSampleProcess.running) {
                    if (barWindow.logSampling) {
                        Logger.i("Bar", "Sampling bar color...");
                    }
                    colorSampleProcess.running = true;
                }
            }
        }
    }
}
