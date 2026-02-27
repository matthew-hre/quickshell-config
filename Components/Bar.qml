import qs.Components.Indicators
import qs.Commons

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

Item {
    anchors.fill: parent
    clip: true

    PanelWindow {
        implicitHeight: Style.barHeight
        color: Style.panelBackground

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

            Clock {
                visible: Settings.showClock
            }

            Item {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
            }

            RecordingStatus {
                visible: Settings.showRecordingStatus
            }

            Volume {
                visible: Settings.showVolume
            }

            Network {
                visible: Settings.showNetwork
            }

            Bluetooth {
                visible: Settings.showBluetooth
            }

            Power {
                visible: Settings.showBattery
            }
        }

        ActiveWindow {
            anchors.centerIn: parent
            visible: Settings.showActiveWindow
        }
    }

    BluetoothPanel {
        open: Settings.bluetoothPanelOpen
        onClose: Settings.bluetoothPanelOpen = false
    }

    BatteryPanel {
        open: Settings.batteryPanelOpen
        onClose: Settings.batteryPanelOpen = false
    }

    AudioPanel {
        open: Settings.audioPanelOpen
        onClose: Settings.audioPanelOpen = false
    }
}
