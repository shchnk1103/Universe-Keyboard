// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [
        // Thread-affine owner uses os.OSAllocatedUnfairLock (macOS 13+ / iOS 16+).
        // Package floor matches the Product-authorized app/extension minimum OS.
        .iOS("17.0"),
        .macOS(.v14),
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
