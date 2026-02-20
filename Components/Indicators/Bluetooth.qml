import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.Commons

Item {
    id: root
    implicitWidth: indicatorRow.implicitWidth
    implicitHeight: indicatorRow.implicitHeight

    readonly property bool adapterEnabled: Bluetooth.defaultAdapter?.enabled ?? false

    RowLayout {
        id: indicatorRow
        spacing: Style.spacingXS

        Text {
            text: root.adapterEnabled ? "󰂯" : "󰂲"
            color: Style.textPrimary
            font.pointSize: Style.baseFontSize
            font.family: Style.fontFamily
        }

        Repeater {
            model: ScriptModel {
                values: root.adapterEnabled
                    ? Bluetooth.devices.values.filter(d => d.connected)
                    : []
            }

            delegate: Text {
                required property var modelData
                text: modelData.name
                color: Style.textPrimary
                font.pointSize: Style.baseFontSize
                font.family: Style.fontFamily
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Settings.bluetoothPanelOpen = !Settings.bluetoothPanelOpen;
            Logger.i("Bluetooth", `Panel ${Settings.bluetoothPanelOpen ? "opened" : "closed"}`);
        }
    }
}
