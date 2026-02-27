import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.Commons

PopupPanel {
    id: root
    panelId: "audio"

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property real sinkVolume: sink?.audio?.volume ?? 0
    readonly property bool sinkMuted: sink?.audio?.muted ?? false
    readonly property int sinkPct: Math.round(sinkVolume * 100)

    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: source?.audio?.muted ?? false
    readonly property int sourcePct: Math.round(sourceVolume * 100)

    PwObjectTracker {
        objects: [root.sink, root.source].concat(sinkRepeater.items).concat(sourceRepeater.items)
    }

    function displayName(node: PwNode): string {
        if (!node) return "";
        const desc = node.description;
        if (desc && desc !== "") return desc;
        const nick = node.nickname;
        if (nick && nick !== "") return nick;
        return node.name;
    }

    // ── Output header ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacingM

        Text {
            text: root.sinkMuted ? "󰝟" : "󰕾"
            color: Style.textPrimary
            font.pointSize: Style.baseFontSize
            font.family: Style.fontFamily
        }

        Text {
            text: "Output"
            color: Style.textPrimary
            font.pointSize: Style.fontSizeTitle
            font.family: Style.fontFamily
            font.weight: Font.Medium
            Layout.fillWidth: true
        }

        Text {
            text: root.sinkMuted ? "Muted" : root.sinkPct + "%"
            color: root.sinkMuted ? Style.textSecondary : Style.textPrimary
            font.pointSize: Style.fontSizeTitle
            font.family: Style.fontFamily
            font.weight: Font.Medium
        }
    }

    // ── Output volume slider ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacingM

        Rectangle {
            width: 20
            height: 20
            radius: Style.radiusS
            color: sinkMuteHover.containsMouse ? Style.currentLine : Style.transparent

            Text {
                anchors.centerIn: parent
                text: root.sinkMuted ? "󰝟" : "󰕾"
                color: root.sinkMuted ? Style.textSecondary : Style.textPrimary
                font.pointSize: Style.fontSizeBody
                font.family: Style.fontFamily
            }

            MouseArea {
                id: sinkMuteHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.sink)
                        root.sink.audio.muted = !root.sink.audio.muted;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: Style.progressHeight
            radius: Style.progressRadius
            color: Style.currentLine

            Rectangle {
                width: Math.min(parent.width, parent.width * root.sinkVolume)
                height: parent.height
                radius: parent.radius
                color: root.sinkMuted ? Style.textSecondary : Style.purple

                Behavior on width {
                    NumberAnimation { duration: Style.animFastMs; easing.type: Easing.InOutCubic }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (root.sink)
                        root.sink.audio.volume = Math.max(0, Math.min(1.5, mouse.x / width));
                }
                onPositionChanged: mouse => {
                    if (pressed && root.sink)
                        root.sink.audio.volume = Math.max(0, Math.min(1.5, mouse.x / width));
                }
            }
        }
    }

    // ── Separator ──
    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Style.spacingS
        height: Style.borderWidth
        color: Style.currentLine
    }

    // ── Output devices ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.spacingS

        Text {
            text: "Output Devices"
            color: Style.textSecondary
            font.pointSize: Style.fontSizeCaption
            font.family: Style.fontFamily
        }

        Repeater {
            id: sinkRepeater
            model: ScriptModel {
                values: Pipewire.nodes.values.filter(n => n.type === PwNodeType.AudioSink)
            }

            property list<PwNode> items: {
                let result = [];
                for (let i = 0; i < count; i++) {
                    let item = itemAt(i);
                    if (item && item.modelData) result.push(item.modelData);
                }
                return result;
            }

            delegate: Rectangle {
                id: sinkDelegate
                required property PwNode modelData

                readonly property bool isDefault: root.sink && modelData.id === root.sink.id

                Layout.fillWidth: true
                implicitHeight: sinkRow.implicitHeight + Style.controlPaddingS * 2
                radius: Style.radiusS
                color: sinkItemHover.containsMouse ? Style.currentLine : Style.transparent

                RowLayout {
                    id: sinkRow
                    anchors.fill: parent
                    anchors.margins: Style.controlPaddingS
                    spacing: Style.spacingM

                    Text {
                        text: root.displayName(modelData)
                        color: sinkDelegate.isDefault ? Style.purple : Style.textPrimary
                        font.pointSize: Style.fontSizeBody
                        font.family: Style.fontFamily
                        font.weight: sinkDelegate.isDefault ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: sinkDelegate.isDefault
                        text: "✓"
                        color: Style.purple
                        font.pointSize: Style.fontSizeCaption
                        font.family: Style.fontFamily
                    }
                }

                MouseArea {
                    id: sinkItemHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Pipewire.preferredDefaultAudioSink = modelData;
                        Logger.i("Audio", `Default sink → ${root.displayName(modelData)}`);
                    }
                }
            }
        }
    }

    // ── Separator ──
    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Style.spacingS
        height: Style.borderWidth
        color: Style.currentLine
    }

    // ── Input header ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacingM

        Text {
            text: root.sourceMuted ? "󰍭" : "󰍬"
            color: Style.textPrimary
            font.pointSize: Style.baseFontSize
            font.family: Style.fontFamily
        }

        Text {
            text: "Input"
            color: Style.textPrimary
            font.pointSize: Style.fontSizeTitle
            font.family: Style.fontFamily
            font.weight: Font.Medium
            Layout.fillWidth: true
        }

        Text {
            text: root.sourceMuted ? "Muted" : root.sourcePct + "%"
            color: root.sourceMuted ? Style.textSecondary : Style.textPrimary
            font.pointSize: Style.fontSizeTitle
            font.family: Style.fontFamily
            font.weight: Font.Medium
        }
    }

    // ── Input volume slider ──
    RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacingM

        Rectangle {
            width: 20
            height: 20
            radius: Style.radiusS
            color: sourceMuteHover.containsMouse ? Style.currentLine : Style.transparent

            Text {
                anchors.centerIn: parent
                text: root.sourceMuted ? "󰍭" : "󰍬"
                color: root.sourceMuted ? Style.textSecondary : Style.textPrimary
                font.pointSize: Style.fontSizeBody
                font.family: Style.fontFamily
            }

            MouseArea {
                id: sourceMuteHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.source)
                        root.source.audio.muted = !root.source.audio.muted;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: Style.progressHeight
            radius: Style.progressRadius
            color: Style.currentLine

            Rectangle {
                width: Math.min(parent.width, parent.width * root.sourceVolume)
                height: parent.height
                radius: parent.radius
                color: root.sourceMuted ? Style.textSecondary : Style.cyan

                Behavior on width {
                    NumberAnimation { duration: Style.animFastMs; easing.type: Easing.InOutCubic }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (root.source)
                        root.source.audio.volume = Math.max(0, Math.min(1.5, mouse.x / width));
                }
                onPositionChanged: mouse => {
                    if (pressed && root.source)
                        root.source.audio.volume = Math.max(0, Math.min(1.5, mouse.x / width));
                }
            }
        }
    }

    // ── Separator ──
    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Style.spacingS
        height: Style.borderWidth
        color: Style.currentLine
    }

    // ── Input devices ──
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.spacingS

        Text {
            text: "Input Devices"
            color: Style.textSecondary
            font.pointSize: Style.fontSizeCaption
            font.family: Style.fontFamily
        }

        Repeater {
            id: sourceRepeater
            model: ScriptModel {
                values: Pipewire.nodes.values.filter(n => n.type === PwNodeType.AudioSource)
            }

            property list<PwNode> items: {
                let result = [];
                for (let i = 0; i < count; i++) {
                    let item = itemAt(i);
                    if (item && item.modelData) result.push(item.modelData);
                }
                return result;
            }

            delegate: Rectangle {
                id: sourceDelegate
                required property PwNode modelData

                readonly property bool isDefault: root.source && modelData.id === root.source.id

                Layout.fillWidth: true
                implicitHeight: sourceRow.implicitHeight + Style.controlPaddingS * 2
                radius: Style.radiusS
                color: sourceItemHover.containsMouse ? Style.currentLine : Style.transparent

                RowLayout {
                    id: sourceRow
                    anchors.fill: parent
                    anchors.margins: Style.controlPaddingS
                    spacing: Style.spacingM

                    Text {
                        text: root.displayName(modelData)
                        color: sourceDelegate.isDefault ? Style.cyan : Style.textPrimary
                        font.pointSize: Style.fontSizeBody
                        font.family: Style.fontFamily
                        font.weight: sourceDelegate.isDefault ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: sourceDelegate.isDefault
                        text: "✓"
                        color: Style.cyan
                        font.pointSize: Style.fontSizeCaption
                        font.family: Style.fontFamily
                    }
                }

                MouseArea {
                    id: sourceItemHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Pipewire.preferredDefaultAudioSource = modelData;
                        Logger.i("Audio", `Default source → ${root.displayName(modelData)}`);
                    }
                }
            }
        }
    }
}
