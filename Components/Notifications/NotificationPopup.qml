import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Commons

Rectangle {
    id: root

    required property var notification

    property int defaultTimeoutMs: 5000
    property int criticalTimeoutMs: 10000
    property int bodyMaxLines: 3
    property string closeGlyph: "✕"
    property string fallbackSummary: "Notification"

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

    implicitWidth: Style.notificationPopupWidth
    implicitHeight: contentColumn.implicitHeight + Style.notificationPopupPadding * 2
    radius: Style.radiusM
    color: isCritical ? Style.red : Style.background
    border.color: isCritical ? Style.red : Style.currentLine
    border.width: Style.borderWidth
    clip: true

    opacity: 0
    transform: Translate { id: slideTransform; x: root.implicitWidth + Style.spacingXL }

    Component.onCompleted: enterAnimation.start()

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: Style.animMediumMs; easing.type: Easing.OutCubic }
        NumberAnimation { target: slideTransform; property: "x"; to: 0; duration: Style.animSlowMs; easing.type: Easing.OutCubic }
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
        anchors.margins: Style.notificationPopupPadding
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
                implicitSize: Style.notificationIconSize
                Layout.preferredWidth: Style.notificationIconSize
                Layout.preferredHeight: Style.notificationIconSize
            }

            Text {
                text: notification.summary || notification.appName || root.fallbackSummary
                color: isCritical ? Style.foreground : Style.textPrimary
                font.pointSize: Style.fontSizeTitle
                font.family: Style.fontFamily
                font.weight: Font.Medium
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.closeGlyph
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
            font.pointSize: Style.fontSizeBody
            font.family: Style.fontFamily
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            maximumLineCount: root.bodyMaxLines
            elide: Text.ElideRight
        }

        Rectangle {
            visible: root.progressValue >= 0
            Layout.fillWidth: true
            height: Style.progressHeight
            radius: Style.progressRadius
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
                    implicitHeight: actionLabel.implicitHeight + Style.controlPaddingS
                    radius: Style.radiusS
                    color: Style.currentLine

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        color: Style.textPrimary
                        font.pointSize: Style.fontSizeCaption
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
            if (root.isCritical) return root.criticalTimeoutMs;
            return root.defaultTimeoutMs;
        }
        running: enterAnimation.running === false
        onTriggered: {
            exitAnimation.start();
        }
    }

    ParallelAnimation {
        id: exitAnimation
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: Style.animFastMs; easing.type: Easing.InCubic }
        NumberAnimation { target: slideTransform; property: "x"; to: root.implicitWidth + Style.spacingXL; duration: Style.animMediumMs; easing.type: Easing.InCubic }
        onFinished: notification.expire()
    }
}
