// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [
        // Thread-affine owner requires Synchronization.Mutex (macOS 15+ / iOS 18+).
        // Package floor matches the Product-authorized app/extension minimum OS.
        .iOS("18.0"),
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
