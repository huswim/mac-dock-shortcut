import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let hotkeyManager = HotkeyManager()
    private var dockApps: [DockApp] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        dockApps = DockReader.readDockApps()

        // Set up status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "dock.rectangle", accessibilityDescription: "DockShortcut") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "DS"
            }
        }

        // Build menu
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
        rebuildMenu(menu)

        // Register hotkeys
        hotkeyManager.onHotkey = { [weak self] index in
            self?.handleHotkey(index: index)
        }
        hotkeyManager.register()
    }

    func menuWillOpen(_ menu: NSMenu) {
        dockApps = DockReader.readDockApps()
        rebuildMenu(menu)
    }

    private func rebuildMenu(_ menu: NSMenu) {
        menu.removeAllItems()

        for (i, app) in dockApps.enumerated() {
            let key = i < 9 ? "\(i + 1)" : "0"
            let item = NSMenuItem(title: "⌃⌥\(key)  \(app.label)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        if dockApps.isEmpty {
            let item = NSMenuItem(title: "No dock apps found", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }

    private func handleHotkey(index: Int) {
        // Re-read dock apps fresh each time for accuracy
        let apps = DockReader.readDockApps()
        guard index >= 0 && index < apps.count else { return }
        AppLauncher.launchOrActivate(bundleIdentifier: apps[index].bundleIdentifier)
    }

    @objc private func quit() {
        hotkeyManager.unregister()
        NSApp.terminate(nil)
    }
}
