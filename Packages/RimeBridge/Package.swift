// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RimeBridge",
    platforms: [.iOS("26.4")],
    products: [
        .library(name: "RimeBridge", targets: ["RimeBridge"])
    ],
    dependencies: [
        .package(path: "../KeyboardCore")
    ],
    targets: [

        // MARK: - ObjC 桥接层
        .target(
            name: "RimeBridgeObjC",
            dependencies: [
                "librimeRIME",
                "boost_atomicRIME",
                "boost_filesystemRIME",
                "boost_regexRIME",
                "libglogRIME",
                "libleveldbRIME",
                "libmarisaRIME",
                "libopenccRIME",
                "libyamlCppRIME",
                "libluaRIME",
                "librimeLuaRIME",
            ],
            path: "Sources/RimeBridgeObjC",
            publicHeadersPath: "include",
            cSettings: [
                .define("RIME_HAS_LUA"),
                .define("RIME_DIAGNOSTICS", .when(configuration: .debug)),
            ],
            linkerSettings: [.linkedLibrary("c++")]
        ),

        // MARK: - Swift 引擎封装
        .target(
            name: "RimeBridge",
            dependencies: [
                "RimeBridgeObjC",
                "KeyboardCore",
            ],
            path: "Sources/RimeBridge"
        ),

        // MARK: - Binary Targets（预编译 xcframework）
        .binaryTarget(name: "librimeRIME", path: "Vendor/librime.xcframework"),
        .binaryTarget(name: "boost_atomicRIME", path: "Vendor/boost_atomic.xcframework"),
        .binaryTarget(name: "boost_filesystemRIME", path: "Vendor/boost_filesystem.xcframework"),
        .binaryTarget(name: "boost_regexRIME", path: "Vendor/boost_regex.xcframework"),
        .binaryTarget(name: "libglogRIME", path: "Vendor/libglog.xcframework"),
        .binaryTarget(name: "libleveldbRIME", path: "Vendor/libleveldb.xcframework"),
        .binaryTarget(name: "libmarisaRIME", path: "Vendor/libmarisa.xcframework"),
        .binaryTarget(name: "libopenccRIME", path: "Vendor/libopencc.xcframework"),
        .binaryTarget(name: "libyamlCppRIME", path: "Vendor/libyaml-cpp.xcframework"),
        .binaryTarget(name: "libluaRIME", path: "Vendor/liblua.xcframework"),
        .binaryTarget(name: "librimeLuaRIME", path: "Vendor/librime-lua.xcframework"),

        .testTarget(
            name: "RimeBridgeTests",
            dependencies: ["RimeBridge"],
            path: "Tests/RimeBridgeTests"
        ),
    ]
)
