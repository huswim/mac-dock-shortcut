import AppKit
import Carbon
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let hotkeyManager = HotkeyManager()
    private var dockApps: [DockApp] = []

    private static let modifierKeyDefaultsKey = "modifierKey"
    private static let modifierCtrlOnly = "ctrl"

    private var useCtrlOnly: Bool {
        UserDefaults.standard.string(forKey: Self.modifierKeyDefaultsKey) == Self.modifierCtrlOnly
    }

    private func currentModifiers() -> UInt32 {
        useCtrlOnly ? UInt32(controlKey) : UInt32(controlKey | optionKey)
    }

    private func modifierSymbols() -> String {
        useCtrlOnly ? "⌃" : "⌃⌥"
    }

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
        hotkeyManager.register(modifiers: currentModifiers())
    }

    func menuWillOpen(_ menu: NSMenu) {
        dockApps = DockReader.readDockApps()
        rebuildMenu(menu)
    }

    private func rebuildMenu(_ menu: NSMenu) {
        menu.removeAllItems()

        let symbols = modifierSymbols()
        for (i, app) in dockApps.enumerated() {
            let key = i < 9 ? "\(i + 1)" : "0"
            let item = NSMenuItem(title: "\(symbols)\(key)  \(app.label)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        if dockApps.isEmpty {
            let item = NSMenuItem(title: "No dock apps found", action: nil, keyEquivalent: "")
            item.isEnabled = false
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        let modifierMenu = NSMenu()
        let ctrlOptionItem = NSMenuItem(title: "⌃⌥  Control+Option (default)", action: #selector(setModifierCtrlOption), keyEquivalent: "")
        ctrlOptionItem.state = useCtrlOnly ? .off : .on
        modifierMenu.addItem(ctrlOptionItem)
        let ctrlOnlyItem = NSMenuItem(title: "⌃  Control only", action: #selector(setModifierCtrlOnly), keyEquivalent: "")
        ctrlOnlyItem.state = useCtrlOnly ? .on : .off
        modifierMenu.addItem(ctrlOnlyItem)
        let modifierParent = NSMenuItem(title: "Modifier Key", action: nil, keyEquivalent: "")
        modifierParent.submenu = modifierMenu
        menu.addItem(modifierParent)

        if #available(macOS 13.0, *) {
            let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
            launchItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
            menu.addItem(launchItem)
        }

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }

    @available(macOS 13.0, *)
    @objc private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Failed to toggle launch at login"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    private func handleHotkey(index: Int) {
        // Re-read dock apps fresh each time for accuracy
        let apps = DockReader.readDockApps()
        guard index >= 0 && index < apps.count else { return }
        AppLauncher.launchOrActivate(bundleIdentifier: apps[index].bundleIdentifier)
    }

    @objc private func setModifierCtrlOption() {
        UserDefaults.standard.removeObject(forKey: Self.modifierKeyDefaultsKey)
        reregisterHotkeys()
    }

    @objc private func setModifierCtrlOnly() {
        UserDefaults.standard.set(Self.modifierCtrlOnly, forKey: Self.modifierKeyDefaultsKey)
        reregisterHotkeys()
    }

    private func reregisterHotkeys() {
        hotkeyManager.unregister()
        hotkeyManager.register(modifiers: currentModifiers())
        if let menu = statusItem.menu {
            rebuildMenu(menu)
        }
    }

    @objc private func quit() {
        hotkeyManager.unregister()
        NSApp.terminate(nil)
    }
}
