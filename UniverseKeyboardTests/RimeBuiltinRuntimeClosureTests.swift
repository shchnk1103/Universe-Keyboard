import Foundation
import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

/// Proves the resources actually embedded in the App can be installed and
/// consumed by the pinned iOS librime runtime without a network dependency.
@MainActor
final class RimeBuiltinRuntimeClosureTests: XCTestCase {
    func testBundledOfficialLunaClosureDeploysWithFuzzyPinyinOffAndOn() async throws {
        for fuzzyEnabled in [false, true] {
            try await assertRuntimeClosure(fuzzyEnabled: fuzzyEnabled)
            // A second clean deployment catches process-lifecycle or generated
            // state assumptions that a single warm run can hide.
            try await assertRuntimeClosure(fuzzyEnabled: fuzzyEnabled)
        }
    }

    private func assertRuntimeClosure(fuzzyEnabled: Bool) async throws {
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
        try assertBundledOpenCCProfiles(sharedURL: sharedURL)
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
        try RimeBuiltinResourceInstaller().recordOverlayReceipt(
            rimeRoot: root,
            userDataURL: userURL
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

    private func assertBundledOpenCCProfiles(sharedURL: URL) throws {
        let vectors = [
            (config: "s2t.json", input: "汉语龙马发型", expected: "漢語龍馬髮型"),
            (config: "t2s.json", input: "漢語龍馬髮型", expected: "汉语龙马发型"),
            (config: "t2hk.json", input: "僞兌叄", expected: "偽兑叁"),
            (config: "t2tw.json", input: "着牀麪條", expected: "著床麵條"),
        ]
        for vector in vectors {
            let configURL = sharedURL.appendingPathComponent("opencc/\(vector.config)")
            let converted = try RimeOpenCCConverter.convertText(
                vector.input,
                configPath: configURL.path
            )
            XCTAssertEqual(converted, vector.expected, "config=\(vector.config)")
        }
    }
}
