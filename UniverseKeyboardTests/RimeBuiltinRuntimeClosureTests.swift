import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

/// Proves the resources actually embedded in the App can be installed and
/// consumed by the pinned iOS librime runtime without a network dependency.
@MainActor
final class RimeBuiltinRuntimeClosureTests: XCTestCase {
    func testBundledOfficialLunaClosureDeploysWithFuzzyPinyinOffAndOn() async throws {
        for fuzzyEnabled in [false, true] {
            let root = FileManager.default.temporaryDirectory.appendingPathComponent(
                "rime-builtin-runtime-\(UUID().uuidString)",
                isDirectory: true
            )
            defer { try? FileManager.default.removeItem(at: root) }

            let stagedBundle = try RimeConfigManager.stageBundledResourceClosure(from: .main)
            defer { try? FileManager.default.removeItem(at: stagedBundle) }

            _ = try RimeBuiltinResourceInstaller().install(
                sourceRoot: stagedBundle,
                rimeRoot: root
            )
            let sharedURL = root.appendingPathComponent("shared", isDirectory: true)
            let userURL = root.appendingPathComponent("user", isDirectory: true)
            try FileManager.default.createDirectory(at: userURL, withIntermediateDirectories: true)
            try "patch:\n  schema_list:\n    - schema: luna_pinyin\n".write(
                to: userURL.appendingPathComponent("default.custom.yaml"),
                atomically: true,
                encoding: .utf8
            )
            let fuzzySettings = RimeFuzzyPinyinSettings(
                enabled: fuzzyEnabled,
                zhZEnabled: true,
                chCEnabled: true,
                shSEnabled: true,
                nLEnabled: true
            )
            let lunaOverlay = try XCTUnwrap(
                RimeConfigManager.makeSchemaCustomYamlContent(
                    schemaID: "luna_pinyin",
                    simplificationEnabled: true,
                    userDictionaryEnabled: false,
                    fuzzyPinyinSettings: fuzzySettings
                )
            )
            try lunaOverlay.write(
                to: userURL.appendingPathComponent("luna_pinyin.custom.yaml"),
                atomically: true,
                encoding: .utf8
            )

            let result = try await RimeDeploymentService().deploy(
                RimeDeploymentRequest(
                    mode: .fullCheck,
                    sharedDataURL: sharedURL,
                    userDataURL: userURL,
                    runtimeSmokeSchemaID: "luna_pinyin"
                )
            )

            XCTAssertTrue(result.succeeded, "fuzzyEnabled=\(fuzzyEnabled): \(result.diagnosticMessage)")
            XCTAssertEqual(result.runtimeSmokePassed, true)
        }
    }
}
