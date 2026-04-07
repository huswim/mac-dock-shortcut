import AppKit

enum AppLauncher {
    static func launchOrActivate(bundleIdentifier: String) {
        // Try to activate if already running
        if let running = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleIdentifier == bundleIdentifier
        }) {
            running.activate(options: [.activateIgnoringOtherApps])
            return
        }

        // Launch the app
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
