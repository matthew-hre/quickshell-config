import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.Commons

Item {
    id: root

    NotificationServer {
        id: server
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: false
        keepOnReload: false

        onNotification: notification => {
            notification.tracked = true;
            Logger.i("Notifications", `Received: ${notification.summary}`);
        }
    }

    PanelWindow {
        id: notifWindow
        color: Style.panelBackground

        implicitWidth: Style.notificationStackWidth
        implicitHeight: screen.height

        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true
        mask: Region { item: notifColumn }

        anchors {
            top: true
            right: true
            left: false
            bottom: false
        }

        margins {
            top: Style.notificationPanelMarginTop
            right: Style.notificationPanelMarginRight
        }

        Column {
            id: notifColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: {
                let offset = Style.notificationPanelInnerMargin;
                let panelHeight = 0;
                if (Settings.bluetoothPanelOpen) panelHeight = Math.max(panelHeight, Settings.bluetoothPanelHeight);
                if (Settings.batteryPanelOpen) panelHeight = Math.max(panelHeight, Settings.batteryPanelHeight);
                if (panelHeight > 0) offset = panelHeight + Style.spacingM - Style.notificationPanelMarginTop + Style.notificationPanelInnerMargin;
                return offset;
            }
            anchors.leftMargin: Style.notificationPanelInnerMargin
            anchors.rightMargin: Style.notificationPanelInnerMargin
            spacing: Style.spacingM
            visible: notifRepeater.count > 0

            move: Transition {
                NumberAnimation { properties: "y"; duration: Style.animMediumMs; easing.type: Easing.InOutCubic }
            }

            Repeater {
                id: notifRepeater
                model: server.trackedNotifications

                NotificationPopup {
                    required property var modelData
                    notification: modelData
                    width: notifColumn.width
                }
            }
        }
    }
}
