import QtQuick
import QtQuick.Layouts
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
        color: "transparent"

        implicitWidth: 370
        implicitHeight: Math.max(notifColumn.implicitHeight + 18, 1)

        exclusionMode: ExclusionMode.Ignore
        aboveWindows: true

        anchors {
            top: true
            right: true
            left: false
            bottom: false
        }

        margins {
            top: 40
            right: 9
        }

        ColumnLayout {
            id: notifColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 9
            spacing: Style.spacingM
            visible: notifRepeater.count > 0

            Repeater {
                id: notifRepeater
                model: server.trackedNotifications

                NotificationPopup {
                    required property var modelData
                    notification: modelData
                    Layout.fillWidth: true
                }
            }
        }
    }
}
