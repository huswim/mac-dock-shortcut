# DockShortcut

A macOS menu bar app that lets you launch or switch to Dock apps using keyboard shortcuts.

| Shortcut | Dock Position |
|----------|---------------|
| `Ctrl+Option+1` | 1st app |
| `Ctrl+Option+2` | 2nd app |
| `Ctrl+Option+3` | 3rd app |
| `Ctrl+Option+4` | 4th app |
| `Ctrl+Option+5` | 5th app |
| `Ctrl+Option+6` | 6th app |
| `Ctrl+Option+7` | 7th app |
| `Ctrl+Option+8` | 8th app |
| `Ctrl+Option+9` | 9th app |
| `Ctrl+Option+0` | 10th app |

## Requirements

- macOS 12+
- Swift 5.9+

## Build & Run

```bash
swift build
swift run DockShortcut
```

For a release build:

```bash
swift build -c release
.build/release/DockShortcut
```

## How It Works

- Reads your Dock layout from `~/Library/Preferences/com.apple.dock.plist`
- Registers global hotkeys using Carbon `RegisterEventHotKey` (no Accessibility permissions required)
- Launches or activates apps via `NSWorkspace`
- Runs as a menu bar app with no Dock icon (`LSUIElement`)
- Click the menu bar icon to see the current shortcut-to-app mappings
- Dock changes are picked up automatically when you open the menu
