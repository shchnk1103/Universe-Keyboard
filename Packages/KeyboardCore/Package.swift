// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "KeyboardCore",
    platforms: [.iOS("26.4")],
    products: [
        .library(name: "KeyboardCore", targets: ["KeyboardCore"])
    ],
    targets: [
        .systemLibrary(name: "CZLib"),
        .target(
            name: "KeyboardCore",
            dependencies: ["CZLib"]
        ),
        .testTarget(name: "KeyboardCoreTests", dependencies: ["KeyboardCore", "CZLib"])
    ]
)
