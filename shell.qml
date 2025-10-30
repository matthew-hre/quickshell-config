import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "Components/Indicators"
import "Commons"

ShellRoot {
    PanelWindow {
        implicitHeight: 30
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
