import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs.Commons

Item {
    id: root

    required property bool open
    signal close()

    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property real panelMarginTop: Style.barPanelOffset

    readonly property bool isCharging: battery.state === UPowerDeviceState.Charging
                                    || battery.state === UPowerDeviceState.PendingCharge
    readonly property bool isFull: battery.state === UPowerDeviceState.FullyCharged
    readonly property int batteryPercent: Math.round(battery.percentage * 100)

    onOpenChanged: {
        if (open) {
            Settings.batteryPanelHeight = panelRect.implicitHeight + panelMarginTop;
        } else {
            Settings.batteryPanelHeight = 0;
        }
    }

    function formatTime(seconds: real): string {
        if (seconds <= 0) return "";
        let hours = Math.floor(seconds / 3600);
        let mins = Math.floor((seconds % 3600) / 60);
        if (hours > 0) return hours + "h " + mins + "m";
        return mins + "m";
    }

    function stateText(): string {
        switch (battery.state) {
            case UPowerDeviceState.Charging: return "Charging";
            case UPowerDeviceState.Discharging: return "Discharging";
            case UPowerDeviceState.FullyCharged: return "Fully charged";
            case UPowerDeviceState.PendingCharge: return "Pending charge";
            case UPowerDeviceState.PendingDischarge: return "Pending discharge";
            case UPowerDeviceState.Empty: return "Empty";
            default: return "Unknown";
        }
    }

    PanelWindow {
        id: panelWindow
        visible: root.open
        color: Style.transparent

        implicitWidth: screen.width
        implicitHeight: screen.height

        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Rectangle {
            id: panelRect
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: Style.notificationPanelMarginRight + Style.notificationPanelInnerMargin
            anchors.topMargin: root.panelMarginTop + Style.notificationPanelInnerMargin
            width: Style.notificationPopupWidth
            implicitHeight: panelColumn.implicitHeight + Style.notificationPopupPadding * 2
            radius: Style.radiusM
            color: Style.notificationBackground
            border.color: Style.currentLine
            border.width: Style.borderWidth
            clip: true

            onImplicitHeightChanged: {
                if (root.open)
                    Settings.batteryPanelHeight = implicitHeight + root.panelMarginTop;
            }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                id: panelColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Style.notificationPopupPadding
                spacing: Style.spacingM

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingM

                    Text {
                        text: root.isCharging ? "󱐋" : "󰁹"
                        color: Style.textPrimary
                        font.pointSize: Style.baseFontSize
                        font.family: Style.fontFamily
                    }

                    Text {
                        text: "Battery"
                        color: Style.textPrimary
                        font.pointSize: Style.fontSizeTitle
                        font.family: Style.fontFamily
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.batteryPercent + "%"
                        color: {
                            if (root.batteryPercent < 10) return Style.errorColor;
                            if (root.batteryPercent < 20) return Style.warningColor;
                            return Style.textPrimary;
                        }
                        font.pointSize: Style.fontSizeTitle
                        font.family: Style.fontFamily
                        font.weight: Font.Medium
                    }
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: Style.progressHeight
                    radius: Style.progressRadius
                    color: Style.currentLine

                    Rectangle {
                        width: parent.width * (root.batteryPercent / 100)
                        height: parent.height
                        radius: parent.radius
                        color: {
                            if (root.batteryPercent < 10) return Style.errorColor;
                            if (root.batteryPercent < 20) return Style.warningColor;
                            if (root.isCharging) return Style.green;
                            return Style.purple;
                        }

                        Behavior on width {
                            NumberAnimation { duration: Style.animMediumMs; easing.type: Easing.InOutCubic }
                        }

                        Behavior on color {
                            ColorAnimation { duration: Style.animFastMs }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.spacingS
                    height: Style.borderWidth
                    color: Style.currentLine
                }

                // Details
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingS

                    // Status
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Status"
                            color: Style.textSecondary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.stateText()
                            color: Style.textPrimary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                        }
                    }

                    // Time remaining
                    RowLayout {
                        Layout.fillWidth: true
                        visible: {
                            if (root.isCharging) return root.battery.timeToFull > 0;
                            if (root.battery.state === UPowerDeviceState.Discharging) return root.battery.timeToEmpty > 0;
                            return false;
                        }
                        Text {
                            text: root.isCharging ? "Time to full" : "Time remaining"
                            color: Style.textSecondary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                            Layout.fillWidth: true
                        }
                        Text {
                            text: root.isCharging
                                ? root.formatTime(root.battery.timeToFull)
                                : root.formatTime(root.battery.timeToEmpty)
                            color: Style.textPrimary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                        }
                    }

                    // Power draw
                    RowLayout {
                        Layout.fillWidth: true
                        visible: Math.abs(root.battery.changeRate) > 0
                        Text {
                            text: "Power draw"
                            color: Style.textSecondary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Math.abs(root.battery.changeRate).toFixed(1) + " W"
                            color: Style.textPrimary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                        }
                    }

                    // Health
                    RowLayout {
                        Layout.fillWidth: true
                        visible: root.battery.healthPercentage > 0.0
                        Text {
                            text: "Health"
                            color: Style.textSecondary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                            Layout.fillWidth: true
                        }
                        Text {
                            text: Math.round(root.battery.healthPercentage * 100) + "%"
                            color: Style.textPrimary
                            font.pointSize: Style.fontSizeBody
                            font.family: Style.fontFamily
                        }
                    }
                }


            }
        }
    }
}
