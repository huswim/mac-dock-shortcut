import Foundation

struct DockApp {
    let label: String
    let bundleIdentifier: String
}

enum DockReader {
    static func readDockApps() -> [DockApp] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let plistPath = home.appendingPathComponent("Library/Preferences/com.apple.dock.plist").path

        guard let plist = NSDictionary(contentsOfFile: plistPath),
              let persistentApps = plist["persistent-apps"] as? [[String: Any]] else {
            return []
        }

        var apps: [DockApp] = []
        for entry in persistentApps.prefix(10) {
            guard let tileData = entry["tile-data"] as? [String: Any],
                  let label = tileData["file-label"] as? String,
                  let bundleId = tileData["bundle-identifier"] as? String else {
                continue
            }
            apps.append(DockApp(label: label, bundleIdentifier: bundleId))
        }
        return apps
    }
}
