// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [
        .iOS("26.4"),
        // Thread-affine owner requires Synchronization.Mutex (macOS 15+ / iOS 18+).
        // Package floor matches the R4-Wire deployment target used by the app.
        .macOS(.v15),
    ],
    products: [
        .library(name: "KeyboardCore", targets: ["KeyboardCore"])
    ],
    targets: [
        .target(
            name: "KeyboardCore",
            resources: [.process("Resources")],
            linkerSettings: [.linkedLibrary("z")]
        ),
        .testTarget(name: "KeyboardCoreTests", dependencies: ["KeyboardCore"]),
    ]
)
