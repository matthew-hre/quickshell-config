# Quickshell Config

A fairly shoddy recreation of my Waybar setup, built using Quickshell's QML framework.

> This project is still under development, and is definitely a little rough around the edges. Use at your own risk.

## Project Layout

```txt
.
├── shell.qml                    # Main shell configuration and panel layout
├── Commons/
│   └── Style.qml               # Global styling, colors, fonts, and spacing constants
└── Components/
    ├── Indicators/             # Individual status indicator components
    │   ├── Clock.qml           # System time display (HH:MM:SS A)
    │   ├── Volume.qml          # Audio volume level and mute status
    │   ├── Network.qml         # WiFi network status and signal strength
    │   ├── Bluetooth.qml       # Bluetooth power state and connected device
    │   ├── Power.qml           # Battery percentage and charging status
    │   └── ActiveWindow.qml    # Current focused window title
    └── Notifications/          # Notification daemon components
        ├── NotificationPopup.qml   # Individual notification card
        ├── NotificationStack.qml   # Server + stacked popup window
        ├── VolumeNotifier.qml      # Volume change monitor + OSD notification
        └── BrightnessNotifier.qml  # Brightness change monitor + OSD notification
```

## Component Descriptions

## Configuration

The Home Manager module exposes `programs.quickshellConfig.settings` which renders
`Commons/Settings.json` for runtime toggles. Each option defaults to `true`.

Example:

```nix
programs.quickshellConfig.settings = {
  showBattery = false;
  showBluetooth = false;
};
```

### `shell.qml`

The main entry point that creates a 30px panel window positioned at the top of the screen. It uses a horizontal layout to display all indicators with the active window title centered in the middle.

### `Commons/Style.qml`

A singleton providing design tokens:

- **Colors**: Dracula palette (background, foreground, accent colors)
- **Fonts**: "Work Sans" family with 10.5pt base size
- **Spacing**: Predefined spacing values (XS, S, M, L, XL)
- **Semantic colors**: Error (red), warning (orange), success (green)

### `Components/Indicators/`

#### Clock.qml

- Displays current time in 12-hour format with seconds
- Updates every 1 second via JavaScript timer

#### Volume.qml

- Shows audio volume percentage (0-100%) using `wpctl` backend
- Displays different icons based on volume level (muted, low, medium, high)
- Updates every 1 second

#### Network.qml

- Displays connected WiFi network name and signal strength
- Shows disconnected icon when no active WiFi connection
- Signal strength represented in 4 levels via icon changes
- Queries NetworkManager (`nmcli`) every 1 second

#### Bluetooth.qml

- Shows Bluetooth power state (on/off)
- Displays connected device name when powered on
- Updates every 1 second via `bluetoothctl`

#### Power.qml

- Displays battery percentage and charging status
- Icon changes based on battery level (0%, 10%, 20%, ..., 100%)
- Changes text color to red (<10%) or orange (<20%) for low battery warnings
- Charging icon displays when actively charging
- Reads from `/sys/class/power_supply/BAT1/` every 1 second

#### ActiveWindow.qml

- Shows the title of the currently focused window
- Uses Niri window manager protocol (`niri msg windows`)
- Updates every 500ms

### `Components/Notifications/`

#### NotificationStack.qml

- Hosts a `NotificationServer` implementing the Desktop Notifications Specification
- Tracks incoming notifications and displays them in a `PanelWindow` anchored top-right
- Window uses `ExclusionMode.Ignore` so it overlays without reserving screen space
- Offset 40px from top (below the bar) and 9px from the right edge

#### NotificationPopup.qml

- Individual notification card with 350px width and 11px corner radius (matching former Dunst config)
- Displays summary, body (up to 3 lines), app icon, and action buttons
- Critical urgency notifications use red background; others use Dracula background
- Progress bar rendered when the notification carries a `value` hint
- Auto-expires after the notification's `expireTimeout` (defaults to 5s normal, 10s critical)
- Dismiss button to manually close notifications

#### VolumeNotifier.qml

- Polls `wpctl get-volume @DEFAULT_AUDIO_SINK@` every 200ms
- Sends a notification with progress bar when volume or mute state changes
- Uses `notify-send -r` to replace the notification in-place (no stacking)
- Skips the initial reading to avoid a notification on shell start

#### BrightnessNotifier.qml

- Polls `brightnessctl -m info` every 200ms
- Sends a notification with progress bar when brightness changes
- Uses `notify-send -r` to replace the notification in-place (no stacking)
- Skips the initial reading to avoid a notification on shell start

## Future Improvements

- [ ] Hover tooltips for detailed info on each indicator
- [ ] Centralized polling boilerplate
- [ ] Panels for each indicator with expanded details
- [ ] Animations
