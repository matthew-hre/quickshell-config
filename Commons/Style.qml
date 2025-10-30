pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string fontFamily: "Work Sans"
    readonly property real baseFontSize: 10.5

    readonly property real spacingXS: 2
    readonly property real spacingS: 4
    readonly property real spacingM: 8
    readonly property real spacingL: 16
    readonly property real spacingXL: 24

    readonly property color background: "#282a36"
    readonly property color currentLine: "#44475a"
    readonly property color foreground: "#f8f8f2"
    readonly property color comment: "#6272a4"
    readonly property color red: "#ff5555"
    readonly property color orange: "#ffb86c"
    readonly property color yellow: "#f1fa8c"
    readonly property color green: "#50fa7b"
    readonly property color purple: "#bd93f9"
    readonly property color cyan: "#8be9fd"
    readonly property color pink: "#ff79c6"
    readonly property color transparent: "transparent"

    readonly property color textPrimary: foreground
    readonly property color textSecondary: comment
    readonly property color errorColor: red
    readonly property color warningColor: orange
    readonly property color successColor: green
    readonly property color panelBackground: transparent
}
