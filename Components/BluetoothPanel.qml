import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.Commons

Item {
    id: root

    required property bool open
    signal close()

    readonly property bool adapterEnabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property real panelMarginTop: Style.barPanelOffset

    onOpenChanged: {
        if (open) {
            Settings.bluetoothPanelHeight = panelRect.implicitHeight + panelMarginTop;
        } else {
            Settings.bluetoothPanelHeight = 0;
            if (Bluetooth.defaultAdapter?.discovering ?? false) {
                Bluetooth.defaultAdapter.discovering = false;
                Logger.i("Bluetooth", "Scanning stopped (panel closed)");
            }
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

        // Dismiss when clicking outside the panel
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
                    Settings.bluetoothPanelHeight = implicitHeight + root.panelMarginTop;
            }

            // Absorb clicks on the panel so they don't dismiss
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
                        text: "󰂯"
                        color: Style.textPrimary
                        font.pointSize: Style.baseFontSize
                        font.family: Style.fontFamily
                    }

                    Text {
                        text: "Bluetooth"
                        color: Style.textPrimary
                        font.pointSize: Style.fontSizeTitle
                        font.family: Style.fontFamily
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 36
                        height: 20
                        radius: 10
                        color: root.adapterEnabled ? Style.purple : Style.currentLine

                        Behavior on color {
                            ColorAnimation { duration: Style.animFastMs }
                        }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.adapterEnabled ? parent.width - width - 2 : 2
                            color: Style.foreground

                            Behavior on x {
                                NumberAnimation { duration: Style.animFastMs; easing.type: Easing.InOutCubic }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (Bluetooth.defaultAdapter) {
                                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                                    Logger.i("Bluetooth", `Adapter ${Bluetooth.defaultAdapter.enabled ? "enabled" : "disabled"}`);
                                }
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.spacingS
                    height: Style.borderWidth
                    color: Style.currentLine
                    visible: root.adapterEnabled
                }

                // Connected devices section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingS
                    visible: root.adapterEnabled && connectedRepeater.count > 0

                    Text {
                        text: "Connected"
                        color: Style.textSecondary
                        font.pointSize: Style.fontSizeCaption
                        font.family: Style.fontFamily
                    }

                    Repeater {
                        id: connectedRepeater
                        model: ScriptModel {
                            values: Bluetooth.devices.values.filter(d => d.connected)
                        }

                        delegate: Rectangle {
                            id: connectedDelegate
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: deviceRow.implicitHeight + Style.controlPaddingS * 2
                            radius: Style.radiusS
                            color: deviceHover.containsMouse ? Style.currentLine : Style.transparent

                            RowLayout {
                                id: deviceRow
                                anchors.fill: parent
                                anchors.margins: Style.controlPaddingS
                                spacing: Style.spacingM

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: Style.spacingXS

                                    Text {
                                        text: modelData.name
                                        color: Style.textPrimary
                                        font.pointSize: Style.fontSizeBody
                                        font.family: Style.fontFamily
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        visible: modelData.batteryAvailable
                                        text: visible ? "󰥉 " + Math.round(modelData.battery * 100) + "%" : ""
                                        color: {
                                            if (!modelData.batteryAvailable) return Style.textSecondary;
                                            let pct = Math.round(modelData.battery * 100);
                                            if (pct <= 10) return Style.errorColor;
                                            if (pct <= 20) return Style.warningColor;
                                            return Style.textSecondary;
                                        }
                                        font.pointSize: Style.fontSizeCaption
                                        font.family: Style.fontFamily
                                    }
                                }

                                Text {
                                    text: "✕"
                                    color: Style.textSecondary
                                    font.pointSize: Style.fontSizeCaption
                                    font.family: Style.fontFamily

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Logger.i("Bluetooth", `Disconnecting ${modelData.name}`);
                                            modelData.disconnect();
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: deviceHover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                            }
                        }
                    }
                }

                // Paired (not connected) devices section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingS
                    visible: root.adapterEnabled && pairedRepeater.count > 0

                    Text {
                        text: "Paired"
                        color: Style.textSecondary
                        font.pointSize: Style.fontSizeCaption
                        font.family: Style.fontFamily
                    }

                    Repeater {
                        id: pairedRepeater
                        model: ScriptModel {
                            values: Bluetooth.devices.values.filter(d => d.paired && !d.connected)
                        }

                        delegate: Rectangle {
                            id: pairedDelegate
                            required property var modelData

                            readonly property bool isConnecting:
                                modelData.state === BluetoothDeviceState.Connecting

                            Layout.fillWidth: true
                            implicitHeight: pairedRow.implicitHeight + Style.controlPaddingS * 2
                            radius: Style.radiusS
                            color: pairedHover.containsMouse ? Style.currentLine : Style.transparent

                            RowLayout {
                                id: pairedRow
                                anchors.fill: parent
                                anchors.margins: Style.controlPaddingS
                                spacing: Style.spacingM

                                Text {
                                    text: modelData.name
                                    color: Style.textPrimary
                                    font.pointSize: Style.fontSizeBody
                                    font.family: Style.fontFamily
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: pairedDelegate.isConnecting ? "…" : "Connect"
                                    color: pairedDelegate.isConnecting ? Style.textSecondary : Style.purple
                                    font.pointSize: Style.fontSizeCaption
                                    font.family: Style.fontFamily

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: pairedDelegate.isConnecting ? Qt.ArrowCursor : Qt.PointingHandCursor
                                        onClicked: {
                                            if (!pairedDelegate.isConnecting) {
                                                Logger.i("Bluetooth", `Connecting to ${modelData.name}`);
                                                modelData.connect();
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: pairedHover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                            }
                        }
                    }
                }

                // Scanning section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingS
                    visible: root.adapterEnabled

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.bottomMargin: Style.spacingS
                        height: Style.borderWidth
                        color: Style.currentLine
                        visible: connectedRepeater.count > 0 || pairedRepeater.count > 0
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: scanRow.implicitHeight + Style.controlPaddingS * 2
                        radius: Style.radiusS
                        color: scanHover.containsMouse ? Style.currentLine : Style.transparent

                        RowLayout {
                            id: scanRow
                            anchors.fill: parent
                            anchors.margins: Style.controlPaddingS
                            spacing: Style.spacingM

                            Text {
                                text: (Bluetooth.defaultAdapter?.discovering ?? false) ? "Scanning…" : "Scan for devices"
                                color: Style.textPrimary
                                font.pointSize: Style.fontSizeBody
                                font.family: Style.fontFamily
                                Layout.fillWidth: true
                            }

                            Text {
                                text: (Bluetooth.defaultAdapter?.discovering ?? false) ? "Stop" : "Start"
                                color: Style.purple
                                font.pointSize: Style.fontSizeCaption
                                font.family: Style.fontFamily
                            }
                        }

                        MouseArea {
                            id: scanHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (Bluetooth.defaultAdapter) {
                                    Bluetooth.defaultAdapter.discovering = !Bluetooth.defaultAdapter.discovering;
                                    Logger.i("Bluetooth", `Scanning ${Bluetooth.defaultAdapter.discovering ? "started" : "stopped"}`);
                                }
                            }
                        }
                    }

                    // Discovered (unpaired) devices
                    Repeater {
                        id: discoveredRepeater
                        model: ScriptModel {
                            values: (Bluetooth.defaultAdapter?.discovering ?? false)
                                ? Bluetooth.devices.values.filter(d => !d.paired && !d.connected && d.name && d.name !== d.address)
                                : []
                        }

                        delegate: Rectangle {
                            id: discoveredDelegate
                            required property var modelData

                            readonly property bool isPairing: modelData.pairing ?? false

                            Layout.fillWidth: true
                            implicitHeight: discoveredRow.implicitHeight + Style.controlPaddingS * 2
                            radius: Style.radiusS
                            color: discoveredHover.containsMouse ? Style.currentLine : Style.transparent

                            RowLayout {
                                id: discoveredRow
                                anchors.fill: parent
                                anchors.margins: Style.controlPaddingS
                                spacing: Style.spacingM

                                Text {
                                    text: modelData.name
                                    color: Style.textSecondary
                                    font.pointSize: Style.fontSizeBody
                                    font.family: Style.fontFamily
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: discoveredDelegate.isPairing ? "…" : "Pair"
                                    color: discoveredDelegate.isPairing ? Style.textSecondary : Style.purple
                                    font.pointSize: Style.fontSizeCaption
                                    font.family: Style.fontFamily

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: discoveredDelegate.isPairing ? Qt.ArrowCursor : Qt.PointingHandCursor
                                        onClicked: {
                                            if (!discoveredDelegate.isPairing) {
                                                Logger.i("Bluetooth", `Pairing with ${modelData.name}`);
                                                modelData.pair();
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                id: discoveredHover
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.NoButton
                            }
                        }
                    }
                }

                // Disabled state
                Text {
                    visible: !root.adapterEnabled
                    text: "Bluetooth is off"
                    color: Style.textSecondary
                    font.pointSize: Style.fontSizeBody
                    font.family: Style.fontFamily
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: Style.spacingS
                    Layout.bottomMargin: Style.spacingS
                }
            }
        }
    }
}
