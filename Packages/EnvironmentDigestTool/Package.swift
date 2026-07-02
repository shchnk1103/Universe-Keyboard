// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "EnvironmentDigestTool",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "EnvironmentDigest", targets: ["EnvironmentDigest"]),
        .executable(name: "environment-digest", targets: ["EnvironmentDigestCLI"]),
    ],
    targets: [
        .target(name: "EnvironmentDigest"),
        .executableTarget(name: "EnvironmentDigestCLI", dependencies: ["EnvironmentDigest"]),
        .testTarget(name: "EnvironmentDigestTests", dependencies: ["EnvironmentDigest"]),
    ]
)
