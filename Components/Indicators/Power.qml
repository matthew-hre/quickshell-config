import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons

Item {
    id: root
    implicitWidth: indicatorRow.implicitWidth
    implicitHeight: indicatorRow.implicitHeight

    readonly property UPowerDevice battery: UPower.displayDevice

    readonly property var batteryIcons: ["󰁺 ", "󰁻 ", "󰁼 ", "󰁽 ", "󰁾 ", "󰁿 ", "󰂀 ", "󰂁 ", "󰂂 ", "󰁹 "]

    readonly property bool isCharging: battery.state === UPowerDeviceState.Charging
                                    || battery.state === UPowerDeviceState.PendingCharge
    readonly property bool isFull: battery.state === UPowerDeviceState.FullyCharged
    readonly property int batteryPercent: Math.round(battery.percentage * 100)

    onBatteryPercentChanged: {
        Logger.i("Battery", `percent changed: ${batteryPercent}% ready=${battery.ready} state=${battery.state}`);
    }

    Connections {
        target: battery
        function onReadyChanged() {
            Logger.i("Battery", `displayDevice ready=${battery.ready} percentage=${battery.percentage} state=${battery.state}`);
        }
    }

    readonly property string batteryIcon: {
        if (!battery.ready) return "󰂑";
        if (isFull) return "󰁹";
        if (isCharging) return "󱐋";
        let idx = Math.min(Math.floor(batteryPercent / 10), batteryIcons.length - 1);
        return batteryIcons[idx];
    }

    function formatTime(seconds: real): string {
        if (seconds <= 0) return "";
        let hours = Math.floor(seconds / 3600);
        let mins = Math.floor((seconds % 3600) / 60);
        if (hours > 0) return hours + "h " + mins + "m";
        return mins + "m";
    }

    readonly property string timeText: {
        if (isCharging && battery.timeToFull > 0) return formatTime(battery.timeToFull);
        if (battery.state === UPowerDeviceState.Discharging && battery.timeToEmpty > 0) return formatTime(battery.timeToEmpty);
        return "";
    }

    RowLayout {
        id: indicatorRow
        spacing: Style.spacingXS

        Text {
            text: root.batteryIcon
            color: {
                if (root.batteryPercent < 10) return Style.errorColor;
                if (root.batteryPercent < 20) return Style.warningColor;
                return Style.textPrimary;
            }
            font.pointSize: Style.baseFontSize
            font.family: Style.fontFamily
        }

        Text {
            text: root.battery.ready ? root.batteryPercent + "%" : "…"
            color: {
                if (root.batteryPercent < 10) return Style.errorColor;
                if (root.batteryPercent < 20) return Style.warningColor;
                return Style.textPrimary;
            }
            font.pointSize: Style.baseFontSize
            font.family: Style.fontFamily
        }

        Text {
            id: timeText
            Layout.leftMargin: Style.spacingS
            text: "(" + root.timeText + ")"
            color: Style.textSecondary
            font.pointSize: Style.baseFontSize
            font.family: Style.fontFamily
            visible: opacity > 0
            opacity: (hoverArea.containsMouse || Settings.batteryPanelOpen) && root.timeText !== "" ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: Style.animFastMs; easing.type: Easing.InOutCubic }
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Settings.batteryPanelOpen = !Settings.batteryPanelOpen;
            Logger.i("Battery", `Panel ${Settings.batteryPanelOpen ? "opened" : "closed"}`);
        }
    }
}
