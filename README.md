# Quickshell Config

A fairly shoddy recreation of my Waybar setup, built using Quickshell's QML framework.

> This project is still under development, and is definitely a little rough around the edges. Use at your own risk.

## Project Layout

```txt
.
├── shell.qml                    # ShellRoot entry point
├── Commons/
│   ├── Logger.qml               # Singleton logger with timestamped, color-coded console output
│   ├── Settings.qml             # Runtime settings loaded from quickshell-settings.json
│   ├── Style.qml                # Global styling: colors, fonts, spacing, radii, and animation tokens
│   └── Time.qml                 # Singleton clock that ticks every 1s, shared across components
└── Components/
    ├── Bar.qml                  # Top panel window (30px) with indicator layout
    ├── Indicators/              # Individual status indicator components
    │   ├── Clock.qml            # System time display (hh:mm:ss A)
    │   ├── Volume.qml           # Audio volume level and mute status
    │   ├── Network.qml          # WiFi/ethernet network status and signal strength
    │   ├── Bluetooth.qml        # Bluetooth power state and connected device
    │   ├── Power.qml            # Battery percentage and charging status
    │   ├── RecordingStatus.qml  # Screen recording indicator via D-Bus
    │   └── ActiveWindow.qml     # Current focused window title (Niri)
    └── Notifications/           # Notification daemon components
        ├── NotificationPopup.qml    # Individual notification card with animations
        ├── NotificationStack.qml    # Server + stacked popup window
        ├── VolumeNotifier.qml       # Volume change monitor + OSD notification
        └── BrightnessNotifier.qml   # Brightness change monitor + OSD notification
```

## Configuration

The Home Manager module exposes `programs.quickshellConfig.settings` which renders
`~/.config/quickshell-settings.json` for runtime toggles. Each option defaults to `true`.

Available settings: `showClock`, `showRecordingStatus`, `showVolume`, `showNetwork`,
`showBluetooth`, `showBattery`, `showActiveWindow`, `showNotificationStack`,
`showVolumeNotifier`, `showBrightnessNotifier`.

Example:

```nix
programs.quickshellConfig.settings = {
  showBattery = false;
  showBluetooth = false;
  showRecordingStatus = false;
};
```

## Component Descriptions

### `shell.qml`

The `ShellRoot` entry point that instantiates `Bar`, `NotificationStack`, `VolumeNotifier`, and `BrightnessNotifier`. Notification and notifier visibility is controlled by `Settings`.

### `Commons/Logger.qml`

A singleton providing timestamped, ANSI-colored console logging methods (`i`, `w`, `e`) and a `callStack` helper for debugging.

### `Commons/Settings.qml`

A singleton that loads `~/.config/quickshell-settings.json` via `FileView`, watches for changes, and exposes boolean properties for each UI toggle.

### `Commons/Time.qml`

A singleton that maintains a `date` property updated every 1 second, shared across all components that need the current time.

### `Commons/Style.qml`

A singleton providing design tokens:

- **Colors**: Dracula-inspired palette (foreground, accent colors, notification background `#282a36`)
- **Fonts**: "Work Sans" family with 10.5pt base size, plus title/body/caption sizes
- **Spacing**: Predefined spacing values (XS, S, M, L, XL)
- **Radii**: XS (2), S (4), M (10)
- **Animations**: Fast (200ms), Medium (250ms), Slow (300ms)
- **Notification layout**: Stack width, popup width, margins, padding, icon/image sizes
- **Semantic colors**: Error (red), warning (orange), success (green)

### `Components/Bar.qml`

Creates a 30px `PanelWindow` anchored to the top of the screen. Uses a `RowLayout` with the clock on the left, right-aligned indicators (recording status, volume, network, Bluetooth, battery), and the active window title centered.

### `Components/Indicators/`

#### Clock.qml

- Displays current time in 12-hour format with seconds (`hh:mm:ss A`)
- Uses the shared `Time.date` singleton; refreshes display every 1 second

#### RecordingStatus.qml

- Checks if [`niri-screen-recorder`](https://github.com/matthew-hre/niri-screen-recorder) is active via D-Bus (`org.matthew_hre.NiriScreenRecorder`)
- Displays a red icon when recording; hidden otherwise
- Stops the active recording on click via D-Bus
- Polls every 500ms

#### Volume.qml

- Shows audio volume percentage (0-100%) using `wpctl get-volume`
- Displays different icons based on volume level (muted, low, medium, high)
- Polls every 100ms

#### Network.qml

- Displays connected WiFi network name and signal strength via `nmcli`
- Falls back to checking wired ethernet if no active WiFi connection
- Signal strength represented in 4 levels via icon changes
- Shows disconnected icon when no connection found
- Polls every 1 second

#### Bluetooth.qml

- Shows Bluetooth power state (on/off) via `bluetoothctl show`
- Displays connected device name (via `bluetoothctl info`) when powered on
- Polls every 1 second

#### Power.qml

- Displays battery percentage and charging status
- Icon changes based on battery level (10 discrete levels)
- Changes text color to red (<10%) or orange (<20%) for low battery warnings
- Charging icon displays when actively charging
- Reads from `/sys/class/power_supply/BAT1/` every 1 second

#### ActiveWindow.qml

- Shows the title of the currently focused window
- Uses Niri window manager protocol (`niri msg windows`)
- Fade animation on title changes
- Polls every 100ms

### `Components/Notifications/`

#### NotificationStack.qml

- Hosts a `NotificationServer` implementing the Desktop Notifications Specification
- Tracks incoming notifications and displays them in a `PanelWindow` anchored top-right
- Window uses `ExclusionMode.Ignore` so it overlays without reserving screen space
- Margin offsets configurable via `Style` tokens

#### NotificationPopup.qml

- Individual notification card with 350px width and 10px corner radius
- Slide-in and fade entrance animation; slide-out and fade exit animation
- Displays summary, body (up to 3 lines), app icon, and action buttons
- Critical urgency notifications use a red border; others use the default border
- Special layout handling for Discord and Tidal notifications (e.g., hero-style album art)
- Progress bar rendered when the notification carries a `value` hint
- Auto-expires after the notification's `expireTimeout` (defaults to 5s normal, 10s critical)
- Dismiss button to manually close notifications

#### VolumeNotifier.qml

- Polls `wpctl get-volume @DEFAULT_AUDIO_SINK@` every 200ms
- Sends a notification with progress bar when volume or mute state changes
- Uses `notify-send -p` to capture notification ID for in-place replacement
- Skips the initial reading to avoid a notification on shell start

#### BrightnessNotifier.qml

- Polls `brightnessctl -m info` every 200ms
- Sends a notification with progress bar when brightness changes
- Uses `notify-send -p` to capture notification ID for in-place replacement
- Skips the initial reading to avoid a notification on shell start

## Future Improvements

- [ ] Hover tooltips for detailed info on each indicator
- [ ] Centralized polling boilerplate
- [ ] Panels for each indicator with expanded details
- [ ] Animations
