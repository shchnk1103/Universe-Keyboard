import XCTest
import KeyboardCore

@testable import RimeBridge

final class RimeEngineContractTests: XCTestCase {
    func testPrintableKeycodesUseASCIIValues() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "a"), 0x0061)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Z"), 0x005A)
        XCTAssertEqual(RimeEngineImpl.keycode(for: " "), 0x0020)
    }

    func testControlKeycodesMatchRimeKeysyms() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "BackSpace"), 0xFF08)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Delete"), 0xFF08)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Return"), 0xFF0D)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Enter"), 0xFF0D)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Tab"), 0xFF09)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Escape"), 0xFF1B)
    }

    func testSpaceActionAliasMatchesLiteralSpace() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "space"), RimeEngineImpl.keycode(for: " "))
    }

    func testEmptyAndMultiscalarInputDoNotEmitAKeycode() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: ""), 0)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "ni"), 0)
    }

    func testOutputParserSeparatesRawInputFromDisplayPreedit() {
        let output = RimeEngineImpl.parseOutputDictionary([
            "rawInput": "nihap",
            "preedit": "ni h a p",
            "cursorPos": 8,
            "candidates": [["text": "你好安排", "comment": ""]],
            "pageNo": 2,
            "isLastPage": false,
            "highlightedIndex": 0,
        ])

        XCTAssertEqual(output.rawInput, "nihap")
        XCTAssertEqual(output.composition?.preeditText, "ni h a p")
        XCTAssertEqual(output.candidatePageNumber, 2)
        XCTAssertEqual(output.candidates.map(\.text), ["你好安排"])
        XCTAssertTrue(output.hasMorePages)
    }

    func testOutputParserAcceptsObjectiveCCollections() {
        let candidate = NSMutableDictionary()
        candidate["text"] = "你" as NSString
        candidate["comment"] = "" as NSString
        candidate["globalIndex"] = NSNumber(value: 0)

        let output = RimeEngineImpl.parseOutputDictionary([
            "rawInput": "ni",
            "preedit": "ni",
            "cursorPos": 2,
            "candidates": NSMutableArray(object: candidate),
            "isLastPage": true,
        ])

        XCTAssertEqual(output.candidates.map(\.text), ["你"])
        XCTAssertEqual(output.candidates.map(\.globalIndex), [0])
    }

    func testOutputParserUsesPhaseOneDefaultsWhenMetadataIsMissing() {
        let output = RimeEngineImpl.parseOutputDictionary([:])

        XCTAssertNil(output.rawInput)
        XCTAssertEqual(output.candidatePageNumber, 0)
    }

    func testCandidateWindowParserPreservesGlobalIndexes() {
        let window = RimeEngineImpl.parseCandidateWindowDictionary([
            "startIndex": 9,
            "nextIndex": 12,
            "hasMoreCandidates": true,
            "candidates": [
                ["text": "今", "comment": "", "globalIndex": 9],
                ["text": "金", "comment": "", "globalIndex": 10],
                ["text": "仅", "comment": "", "globalIndex": 11],
            ],
        ])

        XCTAssertEqual(window.startIndex, 9)
        XCTAssertEqual(window.nextIndex, 12)
        XCTAssertTrue(window.hasMoreCandidates)
        XCTAssertEqual(window.candidates.map(\.text), ["今", "金", "仅"])
        XCTAssertEqual(window.candidates.map(\.globalIndex), [9, 10, 11])
    }

    func testDeploymentRequestCarriesFullCheckBoundary() {
        let request = RimeDeploymentRequest(
            mode: .fullCheck,
            sharedDataURL: URL(fileURLWithPath: "/shared"),
            userDataURL: URL(fileURLWithPath: "/user")
        )

        guard case .fullCheck = request.mode else {
            return XCTFail("Main app deployments must use full-check mode.")
        }
        XCTAssertEqual(request.sharedDataURL.path, "/shared")
        XCTAssertEqual(request.userDataURL.path, "/user")
    }

    func testDeploymentModulesIncludeLuaWhenBridgeIsLuaCapable() {
        XCTAssertTrue(RimeBridgeCapabilities.luaModuleCompiledIn)
        XCTAssertTrue(RimeBridgeCapabilities.deploymentModules.contains("lua"))
    }

    func testRuntimeRecoveryRequestPreservesSessionOwnedBoundary() {
        let request = RimeDeploymentRequest(
            mode: .runtimeRecovery,
            sharedDataURL: URL(fileURLWithPath: "/shared"),
            userDataURL: URL(fileURLWithPath: "/user")
        )

        guard case .runtimeRecovery = request.mode else {
            return XCTFail("Keyboard recovery must remain a session-owned operation.")
        }
    }

    func testDeploymentServiceRejectsRuntimeRecoveryWithoutDeploymentDirectories() async throws {
        let request = RimeDeploymentRequest(
            mode: .runtimeRecovery,
            sharedDataURL: URL(fileURLWithPath: "/does-not-exist/shared"),
            userDataURL: URL(fileURLWithPath: "/does-not-exist/user")
        )

        let result = try await RimeDeploymentService().deploy(request)

        XCTAssertFalse(result.succeeded)
        XCTAssertTrue(result.diagnosticMessage.contains("keyboard session engine"))
    }

    func testStandardSyncInstallationKeepsUnrelatedConfiguration() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-standard-sync-\(UUID().uuidString)", isDirectory: true)
        let userDataURL = root.appendingPathComponent("user", isDirectory: true)
        let syncURL = root.appendingPathComponent("sync", isDirectory: true)
        try FileManager.default.createDirectory(at: userDataURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let installationURL = userDataURL.appendingPathComponent("installation.yaml")
        try "distribution_name: Existing Rime\ninstallation_id: old-device\ncustom_flag: true\n".write(
            to: installationURL,
            atomically: true,
            encoding: .utf8
        )

        try RimeStandardSyncInstallation.configure(
            userDataURL: userDataURL,
            syncDirectoryURL: syncURL,
            installationID: "universe-ios-device"
        )

        let output = try String(contentsOf: installationURL, encoding: .utf8)
        XCTAssertTrue(output.contains("distribution_name: Existing Rime"))
        XCTAssertTrue(output.contains("custom_flag: true"))
        XCTAssertTrue(output.contains("installation_id: 'universe-ios-device'"))
        XCTAssertTrue(output.contains("sync_dir: '\(syncURL.path)'"))
        XCTAssertFalse(output.contains("installation_id: old-device"))
    }

    func testStandardSyncInstallationRejectsComplexManagedField() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-standard-sync-invalid-\(UUID().uuidString)", isDirectory: true)
        let userDataURL = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: userDataURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try "sync_dir: |\n  /unsafe\n".write(
            to: userDataURL.appendingPathComponent("installation.yaml"),
            atomically: true,
            encoding: .utf8
        )

        XCTAssertThrowsError(
            try RimeStandardSyncInstallation.configure(
                userDataURL: userDataURL,
                syncDirectoryURL: root.appendingPathComponent("sync", isDirectory: true),
                installationID: "universe-ios-device"
            )
        ) { error in
            XCTAssertEqual(error as? RimeStandardSyncError, .invalidInstallationConfiguration)
        }
    }

    func testStandardSyncServiceCreatesOfficialDeviceDirectory() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-standard-sync-service-\(UUID().uuidString)", isDirectory: true)
        let sharedDataURL = root.appendingPathComponent("shared", isDirectory: true)
        let userDataURL = root.appendingPathComponent("user", isDirectory: true)
        let syncDirectoryURL = root.appendingPathComponent("sync", isDirectory: true)
        try FileManager.default.createDirectory(at: sharedDataURL, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: userDataURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        // librime 维护器要求共享目录至少含有基础 default.yaml；无需为这个
        // 资料同步测试构造完整 schema 或创建运行中的 userdb。
        try "config_version: '0.1'\nschema_list: []\n".write(
            to: sharedDataURL.appendingPathComponent("default.yaml"),
            atomically: true,
            encoding: .utf8
        )

        try await RimeStandardSyncService().synchronize(
            RimeStandardSyncRequest(
                sharedDataURL: sharedDataURL,
                userDataURL: userDataURL,
                syncDirectoryURL: syncDirectoryURL,
                installationID: "universe-ios-integration"
            )
        )

        let deviceDirectory = syncDirectoryURL.appendingPathComponent(
            "universe-ios-integration",
            isDirectory: true
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: deviceDirectory.path))
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: deviceDirectory.appendingPathComponent("installation.yaml").path
        ))
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: userDataURL.appendingPathComponent("luna_pinyin.userdb").path
        ))
    }
}
