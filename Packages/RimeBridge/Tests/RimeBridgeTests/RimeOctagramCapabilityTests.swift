import RimeBridgeObjC
import XCTest

@testable import RimeBridge

/// G1 contract: the vendor links octagram and can surface the concrete `grammar`
/// component without any `.gram` model file, schema patch, or user text.
final class RimeOctagramCapabilityTests: XCTestCase {
    func testOctagramIsCompiledIntoBridge() {
        XCTAssertTrue(
            RimeBridgeCapabilities.octagramModuleCompiledIn,
            "RIME_HAS_OCTAGRAM must be defined when librime-octagram is linked"
        )
        XCTAssertTrue(
            RimeDeployer.octagramModuleCompiledIn(),
            "ObjC deployer must mirror the compile-time octagram flag"
        )
    }

    func testConfiguredModulesIncludeOctagramAlongsideBaseAndLua() {
        let modules = RimeBridgeCapabilities.deploymentModules
        XCTAssertEqual(
            modules,
            ["core", "dict", "gears", "lua", "octagram"],
            "G1 module list must keep base + lua and add octagram only"
        )
    }

    func testGrammarComponentIsDiscoverableWithoutModelFile() throws {
        // Empty temporary data dirs prove we never require a .gram path for module
        // registration. No user text is processed.
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("td012-octagram-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let manager = RimeSessionManager()
        XCTAssertTrue(
            manager.setup(withSharedDataDir: shared.path, userDataDir: user.path),
            "RIME setup must succeed with empty shared/user dirs"
        )
        XCTAssertTrue(
            manager.initializeEngine(),
            "RIME initialize must succeed without any grammar model file"
        )

        XCTAssertTrue(
            RimeBridgeCapabilities.octagramModuleRegistered,
            "octagram module must appear in the runtime module table"
        )
        XCTAssertTrue(
            RimeBridgeCapabilities.grammarComponentRegistered,
            "registry must expose the concrete grammar component without loading .gram"
        )

        // Base Lua capability must remain available when octagram is present.
        XCTAssertTrue(RimeBridgeCapabilities.luaModuleCompiledIn)
        XCTAssertTrue(
            RimeBridgeCapabilities.luaModuleRegistered,
            "octagram must not displace the lua module registration path"
        )
    }
}
