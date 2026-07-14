// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [
        .iOS("26.4"),
        // `swift test` builds this package on macOS, and the logger writer uses
        // Swift Concurrency APIs whose macOS availability begins at 10.15.
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "KeyboardCore", targets: ["KeyboardCore"])
    ],
    targets: [
        .target(
            name: "KeyboardCore",
            linkerSettings: [.linkedLibrary("z")]
        ),
        .testTarget(name: "KeyboardCoreTests", dependencies: ["KeyboardCore"]),
    ]
)
