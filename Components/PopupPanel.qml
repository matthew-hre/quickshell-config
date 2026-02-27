import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons

Item {
    id: root

    required property bool open
    required property string panelId
    signal close()

    default property alias content: panelColumn.data

    readonly property real panelMarginTop: Style.barPanelOffset

    Connections {
        target: root
        function onOpenChanged() {
            if (root.open) {
                Settings.updatePanelHeight(root.panelId, panelRect.implicitHeight + root.panelMarginTop);
            } else {
                Settings.updatePanelHeight(root.panelId, 0);
            }
        }
    }

    PanelWindow {
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
                    Settings.updatePanelHeight(root.panelId, implicitHeight + root.panelMarginTop);
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
            }
        }
    }
}
