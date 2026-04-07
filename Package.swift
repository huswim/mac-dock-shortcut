// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DockShortcut",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "DockShortcut",
            path: "Sources/DockShortcut",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Info.plist"
                ])
            ]
        )
    ]
)
