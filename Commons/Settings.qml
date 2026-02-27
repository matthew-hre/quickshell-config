pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property var config: ({})
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME")
    readonly property string resolvedConfigHome: configHome && configHome.length > 0
        ? configHome
        : Quickshell.env("HOME") + "/.config"

    readonly property bool showClock: config.showClock ?? true
    readonly property bool showRecordingStatus: config.showRecordingStatus ?? true
    readonly property bool showVolume: config.showVolume ?? true
    readonly property bool showNetwork: config.showNetwork ?? true
    readonly property bool showBluetooth: config.showBluetooth ?? true
    readonly property bool showBattery: config.showBattery ?? true
    readonly property bool showActiveWindow: config.showActiveWindow ?? true

    readonly property bool showNotificationStack: config.showNotificationStack ?? true
    readonly property bool showVolumeNotifier: config.showVolumeNotifier ?? true
    readonly property bool showBrightnessNotifier: config.showBrightnessNotifier ?? true

    // Shared state for panel ↔ notification coordination
    property bool bluetoothPanelOpen: false
    property real bluetoothPanelHeight: 0
    property bool batteryPanelOpen: false
    property real batteryPanelHeight: 0
    property bool audioPanelOpen: false
    property real audioPanelHeight: 0

    function loadSettings() {
        const rawText = settingsFile.text();
        if (!rawText || rawText.trim().length === 0)
            return;

        try {
            config = JSON.parse(rawText);
        } catch (error) {
            console.warn("Settings.json parse failed:", error);
        }
    }

    Component.onCompleted: loadSettings()

    FileView {
        id: settingsFile
        path: resolvedConfigHome + "/quickshell-settings.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: {
            settingsFile.reload();
            loadSettings();
        }
    }
}
