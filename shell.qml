import QtQuick.Layouts

import qs.Components
import qs.Components.Indicators
import qs.Commons

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Widgets

ShellRoot {
    Component.onCompleted: {
        Logger.i("Shell", "---------------------------");
        Logger.i("Shell", "Quickshell Hello!");
    }

    Bar {}
}
