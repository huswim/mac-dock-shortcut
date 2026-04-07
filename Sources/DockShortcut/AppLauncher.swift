import AppKit

enum AppLauncher {
    static func launchOrActivate(bundleIdentifier: String) {
        if let running = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleIdentifier == bundleIdentifier
        }) {
            if running.isActive {
                running.hide()
            } else {
                // Use openApplication to activate — this also sends the "reopen"
                // Apple Event, which makes apps open a new window if they have none.
                // Same behavior as clicking the Dock icon. No special permissions needed.
                openApp(bundleIdentifier: bundleIdentifier)
            }
            return
        }

        // App not running — launch it
        openApp(bundleIdentifier: bundleIdentifier)
    }

    private static func openApp(bundleIdentifier: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            NSLog("DockShortcut: Could not find app with bundle ID: \(bundleIdentifier)")
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(at: appURL, configuration: config) { _, error in
            if let error = error {
                NSLog("DockShortcut: Failed to launch \(bundleIdentifier): \(error)")
            }
        }
    }
}
