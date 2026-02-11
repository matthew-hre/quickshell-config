import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Commons

Rectangle {
    id: root

    required property var notification

    readonly property bool isCritical:
        notification.urgency === 2 // NotificationUrgency.Critical

    readonly property int progressValue: {
        let hints = notification.hints;
        if (hints && hints.value !== undefined)
            return hints.value;
        return -1;
    }

    readonly property var defaultAction: {
        let actions = notification.actions;
        for (let i = 0; i < actions.length; i++) {
            if (actions[i].identifier === "default")
                return actions[i];
        }
        return null;
    }

    readonly property var visibleActions: {
        let actions = notification.actions;
        let result = [];
        for (let i = 0; i < actions.length; i++) {
            if (actions[i].text && actions[i].identifier !== "default")
                result.push(actions[i]);
        }
        return result;
    }

    implicitWidth: 350
    implicitHeight: contentColumn.implicitHeight + 24
    radius: 10
    color: isCritical ? Style.red : Style.background
    border.color: isCritical ? Style.red : Style.currentLine
    border.width: 1
    clip: true

    opacity: 0
    transform: Translate { id: slideTransform; x: 380 }

    Component.onCompleted: enterAnimation.start()

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: slideTransform; property: "x"; to: 0; duration: 300; easing.type: Easing.OutCubic }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.defaultAction) {
                Logger.i("Notifications", "Default action invoked");
                root.defaultAction.invoke();
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: Style.spacingS

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.spacingM

            IconImage {
                id: appIconImage
                source: {
                    let icon = notification.appIcon || "";
                    if (!icon) return "";
                    if (icon.startsWith("file://"))
                        return icon;
                    if (icon.startsWith("/"))
                        return "file://" + icon;
                    return Quickshell.iconPath(icon, true);
                }
                visible: source != ""
                implicitSize: 24
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }

            Text {
                text: notification.summary || notification.appName || "Notification"
                color: isCritical ? Style.foreground : Style.textPrimary
                font.pointSize: Style.baseFontSize
                font.family: Style.fontFamily
                font.weight: Font.Medium
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: "✕"
                color: Style.textSecondary
                font.pointSize: Style.baseFontSize
                font.family: Style.fontFamily

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: exitAnimation.start()
                }
            }
        }

        Text {
            text: notification.body || ""
            visible: text !== ""
            color: isCritical ? Style.foreground : Style.foreground
            font.pointSize: Style.baseFontSize - 0.5
            font.family: Style.fontFamily
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        Rectangle {
            visible: root.progressValue >= 0
            Layout.fillWidth: true
            height: 4
            radius: 2
            color: Style.currentLine

            Rectangle {
                width: parent.width * (root.progressValue / 100)
                height: parent.height
                radius: parent.radius
                color: isCritical ? Style.foreground : Style.purple
            }
        }

        RowLayout {
            visible: root.visibleActions.length > 0
            Layout.fillWidth: true
            spacing: Style.spacingS

            Repeater {
                model: root.visibleActions

                Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: actionLabel.implicitHeight + 8
                    radius: 4
                    color: Style.currentLine

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: Style.textPrimary
                        font.pointSize: Style.baseFontSize - 1
                        font.family: Style.fontFamily
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Logger.i("Notifications", `Action invoked: ${modelData.text}`);
                            modelData.invoke();
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: notification
        function onSummaryChanged() {
            if (expireTimer.running) {
                expireTimer.restart();
            }
        }
    }

    Timer {
        id: expireTimer
        interval: {
            let t = notification.expireTimeout;
            if (t > 0) return t;
            if (root.isCritical) return 10000;
            return 5000;
        }
        running: enterAnimation.running === false
        onTriggered: {
            exitAnimation.start();
        }
    }

    ParallelAnimation {
        id: exitAnimation
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InCubic }
        NumberAnimation { target: slideTransform; property: "x"; to: 380; duration: 250; easing.type: Easing.InCubic }
        onFinished: notification.expire()
    }
}
