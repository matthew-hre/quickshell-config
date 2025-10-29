import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

ShellRoot {
    PanelWindow {
        implicitHeight: 30
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 16

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
            anchors.centerIn: parent
        }
    }
}
