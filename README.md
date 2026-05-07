# DockShortcut (v0.3.1)

A macOS menu bar app that lets you launch or switch to Dock apps using keyboard shortcuts.

Install via [Homebrew](#homebrew-recommended) or [download manually](#manual).

## Shortcuts

The modifier key is configurable via the menu bar icon (default: `Ctrl+Option`):

| Shortcut | Dock Position |
|----------|---------------|
| `Modifier+1` | 1st app |
| `Modifier+2` | 2nd app |
| `Modifier+3` | 3rd app |
| `Modifier+4` | 4th app |
| `Modifier+5` | 5th app |
| `Modifier+6` | 6th app |
| `Modifier+7` | 7th app |
| `Modifier+8` | 8th app |
| `Modifier+9` | 9th app |
| `Modifier+0` | 10th app |

### Modifier Key Options

| Option | Keys |
|--------|------|
| Control+Option (default) | `⌃⌥` |
| Control only | `⌃` |

Change the modifier via **menu bar icon → Modifier Key**.

## Installation

### Homebrew (recommended)

```bash
brew install --cask huswim/tools/dock-shortcut
```

### Manual

[Download the latest release](https://github.com/hyeonuk/mac-dock-shortcut/releases/latest) and move `DockShortcut.app` to `/Applications`.

## Security (macOS Gatekeeper)

Because this app is not signed with an Apple Developer certificate, macOS will show a warning: *"Apple could not verify "DockShortcut" is free of malware..."*

To run the app:
1. Locate `DockShortcut` in Finder.
2. **Right-click** (or Control-click) the app and choose **Open**.
3. Click **Open** in the dialog that appears.

Alternatively, you can remove the quarantine flag via Terminal:
```bash
xattr -d com.apple.quarantine /path/to/DockShortcut.app
```

## Requirements

- macOS 12+
- Xcode 16+

## Build & Run

```bash
xcodebuild -project DockShortcut.xcodeproj -scheme DockShortcut -configuration Release build
```

Or open `DockShortcut.xcodeproj` in Xcode and run with `Cmd+R`.

## How It Works

- Reads your Dock layout from `~/Library/Preferences/com.apple.dock.plist`
- Registers global hotkeys using Carbon `RegisterEventHotKey` (no Accessibility permissions required)
- Launches or activates apps via `NSWorkspace`
- Runs as a menu bar app with no Dock icon (`LSUIElement`)
- Click the menu bar icon to see the current shortcut-to-app mappings
- Dock changes are picked up automatically when you open the menu
- Modifier key preference (Control+Option or Control only) is persisted across restarts
