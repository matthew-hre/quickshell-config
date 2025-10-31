import QtQuick.Layouts

import qs.Components.Indicators
import qs.Commons

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets

ShellRoot {
    Component.onCompleted: {
        Logger.i("Shell", "---------------------------");
        Logger.i("Shell", "Quickshell Hello!");
    }

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
