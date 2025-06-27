// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CCUsageMenuBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CCUsageMenuBar",
            targets: ["CCUsageMenuBar"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CCUsageMenuBar",
            path: "CCUsageMenuBar",
            exclude: ["Info.plist", "CCUsageMenuBar.entitlements"],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)