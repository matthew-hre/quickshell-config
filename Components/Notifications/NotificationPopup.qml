import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
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
        notification.urgency === NotificationUrgency.Critical

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

    function normalizeImageSource(source, allowIcon) {
        if (!source)
            return "";
        if (source.startsWith("file://") || source.startsWith("data:") || source.startsWith("image://"))
            return source;
        if (source.startsWith("/"))
            return "file://" + source;
        if (allowIcon)
            return Quickshell.iconPath(source, true);
        return source;
    }

    readonly property string leftImageSource: {
        let image = notification.image || "";
        if (image)
            return root.normalizeImageSource(image, false);
        let icon = notification.appIcon || "";
        if (icon)
            return root.normalizeImageSource(icon, true);
        return "";
    }

    readonly property string appIdentity: {
        let entry = notification.desktopEntry || "";
        if (entry)
            return entry.toLowerCase();
        let name = notification.appName || "";
        if (name)
            return name.toLowerCase();
        return "";
    }

    readonly property bool isDiscord: appIdentity.includes("discord")
    readonly property bool isTidal: appIdentity.includes("tidal")
    readonly property real imageRadius: isDiscord ? 0 : Style.radiusS

    implicitWidth: Style.notificationPopupWidth
    implicitHeight: contentColumn.implicitHeight + Style.notificationPopupPadding * 2
    radius: Style.radiusM
    color: Style.notificationBackground
    border.color: isCritical ? Style.red : Style.currentLine
    border.width: Style.borderWidth
    clip: true

    opacity: 0
    readonly property real slideOffscreen: root.implicitWidth + Style.notificationPanelMarginRight + Style.notificationPanelInnerMargin + Style.spacingXL
    transform: Translate { id: slideTransform; x: root.slideOffscreen }

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
        spacing: Style.spacingM

        Rectangle {
            visible: root.isTidal && root.leftImageSource !== ""
            color: Style.transparent
            radius: Style.radiusS
            Layout.fillWidth: true
            Layout.preferredHeight: width
            clip: true

            Image {
                anchors.fill: parent
                source: root.leftImageSource
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: root.leftImageSource !== ""
            }
        }

        RowLayout {
            id: contentRow
            Layout.fillWidth: true
            spacing: Style.spacingM

            Rectangle {
                visible: !root.isTidal && root.leftImageSource !== ""
                color: Style.transparent
                radius: root.imageRadius
                Layout.preferredWidth: Style.notificationImageSize
                Layout.preferredHeight: Style.notificationImageSize
                Layout.alignment: Qt.AlignTop
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.leftImageSource
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: root.leftImageSource !== ""
                }
            }

            ColumnLayout {
                id: detailsColumn
                Layout.fillWidth: true
                spacing: Style.spacingS

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.spacingM

                    Text {
                        text: notification.summary || notification.appName || root.fallbackSummary
                        color: Style.textPrimary
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
                    color: Style.foreground
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
                        color: Style.purple
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
        NumberAnimation { target: slideTransform; property: "x"; to: root.slideOffscreen; duration: Style.animMediumMs; easing.type: Easing.InCubic }
        onFinished: notification.expire()
    }
}
