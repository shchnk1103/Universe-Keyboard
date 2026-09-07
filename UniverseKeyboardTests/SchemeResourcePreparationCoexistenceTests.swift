import CryptoKit
import Foundation
import XCTest

@testable import RimeBridge
@testable import Universe_Keyboard

/// P0: production Ice/Wanxiang install plans against the built-in installer.
/// Does not use App Group; the installer seam only substitutes the container root.
@MainActor
final class SchemeResourcePreparationCoexistenceTests: XCTestCase {
    func testIcePlanInstallsDefaultYamlAndBuiltinRedeployFailsWithByteCountMismatch() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        XCTAssertTrue(icePlan.shouldInstall(relativePath: "default.yaml", luaAvailable: true))
        XCTAssertFalse(icePlan.removableFiles.contains("default.yaml"))

        let iceDefault = try iceDefaultYAMLData()
        XCTAssertNotEqual(iceDefault.count, official.count)

        let extract = env.root.appendingPathComponent("ice-extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try iceDefault.write(to: extract.appendingPathComponent("default.yaml"))
        try Data("ice-schema".utf8).write(to: extract.appendingPathComponent("rime_ice.schema.yaml"))

        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), iceDefault)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("rime_ice.schema.yaml")),
            Data("ice-schema".utf8)
        )

        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .byteCountMismatch
            )
        }
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), iceDefault)
    }

    func testWanxiangPlanSkipsDefaultYamlSoBuiltinRedeploySucceeds() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        let wanxiangPlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "wanxiang")?.installationPlan)
        XCTAssertFalse(wanxiangPlan.shouldInstall(relativePath: "default.yaml", luaAvailable: true))

        let extract = env.root.appendingPathComponent("wanxiang-extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try Data(repeating: 0x61, count: 14_842).write(to: extract.appendingPathComponent("default.yaml"))
        try Data("wanxiang-schema".utf8).write(
            to: extract.appendingPathComponent("wanxiang.schema.yaml")
        )

        try env.installer.installSchemaFiles(from: extract, plan: wanxiangPlan, luaAvailable: true)

        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
        XCTAssertEqual(
            try Data(contentsOf: env.shared.appendingPathComponent("wanxiang.schema.yaml")),
            Data("wanxiang-schema".utf8)
        )
        XCTAssertNoThrow(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    func testIceUninstallLeavesOverwrittenDefaultYaml() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        let iceDefault = try iceDefaultYAMLData()
        let extract = env.root.appendingPathComponent("ice-extract", isDirectory: true)
        try FileManager.default.createDirectory(at: extract, withIntermediateDirectories: true)
        try iceDefault.write(to: extract.appendingPathComponent("default.yaml"))
        try Data("ice-schema".utf8).write(to: extract.appendingPathComponent("rime_ice.schema.yaml"))
        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        env.installer.uninstallSchemaFiles(plan: icePlan)

        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: env.shared.appendingPathComponent("rime_ice.schema.yaml").path
            )
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), iceDefault)
        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .byteCountMismatch
            )
        }
    }

    func testBuiltinOnlyRepeatedDeployRemainsIdempotent() throws {
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let official = try Data(contentsOf: env.defaultYAMLURL)
        _ = try RimeBuiltinResourceInstaller().install(
            sourceRoot: env.sourceRoot,
            rimeRoot: env.rimeRoot
        )
        XCTAssertEqual(try Data(contentsOf: env.defaultYAMLURL), official)
    }

    func testProductionProcessedIceTreeOverwritesDefaultYamlWhenFixturePresent() throws {
        let extract = try iceProcessedExtractURL()
        let env = try makeEnvironment()
        defer { env.tearDown() }

        let icePlan = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice")?.installationPlan)
        try env.installer.installSchemaFiles(from: extract, plan: icePlan, luaAvailable: true)

        let installed = try Data(contentsOf: env.defaultYAMLURL)
        XCTAssertEqual(installed.count, 14_842)
        XCTAssertEqual(
            sha256(installed),
            "0dacfbaca4774c07a0adb2ca2380dc290ada5dfb97e027d54063790ebaca37cd"
        )
        XCTAssertThrowsError(
            try RimeBuiltinResourceInstaller().install(
                sourceRoot: env.sourceRoot,
                rimeRoot: env.rimeRoot
            )
        ) { error in
            XCTAssertEqual(
                error as? RimeBuiltinResourceInstaller.InstallationError,
                .byteCountMismatch
            )
        }
    }

    private struct Environment {
        let root: URL
        let sourceRoot: URL
        let rimeRoot: URL
        let shared: URL
        let defaultYAMLURL: URL
        let installer: SharedContainerSchemaArchiveInstaller

        func tearDown() {
            try? FileManager.default.removeItem(at: root)
            try? FileManager.default.removeItem(at: sourceRoot)
        }
    }

    private func makeEnvironment() throws -> Environment {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "uk-p0-coexist-\(UUID().uuidString)",
            isDirectory: true
        )
        let container = root.appendingPathComponent("container", isDirectory: true)
        try FileManager.default.createDirectory(at: container, withIntermediateDirectories: true)
        let rimeRoot = container.appendingPathComponent("Rime", isDirectory: true)
        let sourceRoot = try RimeConfigManager.stageBundledResourceClosure(from: .main)
        _ = try RimeBuiltinResourceInstaller().install(sourceRoot: sourceRoot, rimeRoot: rimeRoot)
        return Environment(
            root: root,
            sourceRoot: sourceRoot,
            rimeRoot: rimeRoot,
            shared: rimeRoot.appendingPathComponent("shared", isDirectory: true),
            defaultYAMLURL: rimeRoot.appendingPathComponent("shared/default.yaml"),
            installer: SharedContainerSchemaArchiveInstaller(
                appGroupID: "group.com.DoubleShy0N.Universe-Keyboard",
                containerURL: container
            )
        )
    }

    private func iceDefaultYAMLData() throws -> Data {
        if let extract = optionalIceExtractURL() {
            return try Data(contentsOf: extract.appendingPathComponent("default.yaml"))
        }
        return Data(repeating: 0x61, count: 14_842)
    }

    private func iceProcessedExtractURL() throws -> URL {
        guard let extract = optionalIceExtractURL() else {
            throw XCTSkip(
                "Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded Ice archives"
            )
        }
        return extract
    }

    private func optionalIceExtractURL() -> URL? {
        let roots = [
            ProcessInfo.processInfo.environment["SCHEME_PIN_ARCHIVE_ROOT"],
            "/private/tmp/rime-ice-20260630",
        ].compactMap { $0 }
        for path in roots {
            let withLua = URL(fileURLWithPath: path).appendingPathComponent("withLua")
            if FileManager.default.fileExists(
                atPath: withLua.appendingPathComponent("default.yaml").path
            ) {
                return withLua
            }
        }
        return nil
    }

    private func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
