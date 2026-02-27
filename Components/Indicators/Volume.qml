import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.Commons

Item {
    id: root
    implicitWidth: volumeText.implicitWidth
    implicitHeight: volumeText.implicitHeight

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    readonly property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false
    readonly property int pct: Math.round(volume * 100)

    readonly property string volumeMutedIcon: "󰝟"
    readonly property var volumeLevels: ["󰕿", "󰖀", "󰕾"]

    readonly property string icon: {
        if (muted || pct === 0) return volumeMutedIcon;
        if (pct < 50) return volumeLevels[1];
        return volumeLevels[2];
    }

    Text {
        id: volumeText
        text: `${root.icon} ${root.pct}%`
        color: Style.textPrimary
        font.pointSize: Style.baseFontSize
        font.family: Style.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Settings.audioPanelOpen = !Settings.audioPanelOpen;
            Logger.i("Audio", `Panel ${Settings.audioPanelOpen ? "opened" : "closed"}`);
        }
    }
}
