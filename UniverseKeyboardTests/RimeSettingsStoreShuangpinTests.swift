import Foundation
import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

/// PB-017 PR-3：双拼设置接线（26 键 picker 追加、共享目录物化、模糊音置灰门卫）。
@MainActor
final class RimeSettingsStoreShuangpinTests: XCTestCase {
    // MARK: - Fixtures（与 RimeSettingsStoreTests 同构，独立私有副本避免交叉耦合）

    private func makeStore(
        settings values: [String: Any] = [:],
        archiveInstaller: ShuangpinArchiveInstaller = ShuangpinArchiveInstaller()
    ) -> (store: RimeSettingsStore, deployment: ShuangpinDeploymentService) {
        let deployment = ShuangpinDeploymentService(succeeded: true)
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: ShuangpinSharedSettingsStore(values: values),
                sourceSelector: ShuangpinSourceSelector(),
                archiveDownloader: ShuangpinArchiveDownloader(),
                archiveInstaller: archiveInstaller,
                deploymentService: deployment
            ),
            persistence: ShuangpinStubPersistence(),
            userDictionaryBackupService: ShuangpinBackupService()
        )
        return (store, deployment)
    }

    // MARK: - 26 键 picker 追加内置双拼变体

    func testTwentySixKeyChoicesAppendBuiltinShuangpinVariants() throws {
        let (store, _) = makeStore()
        let choices = store.twentySixKeySchemeChoices
        let ids = choices.map(\.schemaID)

        XCTAssertTrue(ids.contains("double_pinyin_flypy"), String(describing: ids))
        XCTAssertTrue(ids.contains("double_pinyin"), String(describing: ids))

        let flypy = try XCTUnwrap(choices.first { $0.schemaID == "double_pinyin_flypy" })
        XCTAssertEqual(flypy.name, "小鹤双拼")
        XCTAssertEqual(flypy.source, .builtin)
        XCTAssertTrue(flypy.installed)
        XCTAssertFalse(flypy.isDownloadable)
        XCTAssertNil(flypy.licenseDescriptor)

        let zrm = try XCTUnwrap(choices.first { $0.schemaID == "double_pinyin" })
        XCTAssertEqual(zrm.name, "自然码双拼")
        XCTAssertTrue(zrm.installed)

        // 既有全拼可选方案不被挤掉。
        XCTAssertTrue(ids.contains("luna_pinyin"), String(describing: ids))
    }

    func testShuangpinChoicesStayStableAcrossRefresh() {
        let (store, _) = makeStore()
        store.load()
        let first = store.twentySixKeySchemeChoices.filter {
            RimeShuangpinVariant.isDoublePinyinSchemaID($0.schemaID)
        }
        XCTAssertEqual(first.count, 2)
    }

    // MARK: - 切换双拼物化 schema 文件到共享目录

    func testSetSchemeBinding26MaterializesFlypySchemaWithLunaHost() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-shuangpin-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let installer = ShuangpinArchiveInstaller(runtimeRoot: dir)
        let (store, deployment) = makeStore(archiveInstaller: installer)

        await store.setSchemeBinding26("double_pinyin_flypy")

        let yamlURL = dir.appendingPathComponent("double_pinyin_flypy.schema.yaml")
        XCTAssertTrue(FileManager.default.fileExists(atPath: yamlURL.path))
        let yaml = try String(contentsOf: yamlURL, encoding: .utf8)
        XCTAssertTrue(yaml.contains("schema_id: double_pinyin_flypy"))
        // 拍板 4：默认宿主为朙月（激活宿主非内置双拼宿主时兜底）。
        XCTAssertTrue(yaml.contains("dictionary: luna_pinyin"))

        // 既有绑定 / 激活别名 / 部署通知链保持既有语义。
        XCTAssertEqual(installer.sharedDataDirectoryURL(), dir)
        let requestCount = await deployment.requests.count
        XCTAssertEqual(requestCount, 1)
    }

    func testSetSchemeBinding26MaterializesZrmSchemaFollowingIceHost() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-shuangpin-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let installer = ShuangpinArchiveInstaller(runtimeRoot: dir)
        let (store, _) = makeStore(
            settings: ["rime_active_schema": "rime_ice"],
            archiveInstaller: installer
        )
        XCTAssertEqual(store.activeSchemaID, "rime_ice")

        await store.setSchemeBinding26("double_pinyin")

        let yaml = try String(
            contentsOf: dir.appendingPathComponent("double_pinyin.schema.yaml"), encoding: .utf8)
        XCTAssertTrue(yaml.contains("schema_id: double_pinyin"))
        // 拍板 4：跟随当前激活宿主词库（雾凇）。
        XCTAssertTrue(yaml.contains("dictionary: rime_ice"))
    }

    func testSetSchemeBinding26ForFullPinyinDoesNotWriteShuangpinFiles() async throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-shuangpin-store-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let installer = ShuangpinArchiveInstaller(runtimeRoot: dir)
        let (store, _) = makeStore(archiveInstaller: installer)

        await store.setSchemeBinding26("luna_pinyin")

        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: dir.appendingPathComponent("double_pinyin_flypy.schema.yaml").path))
        XCTAssertFalse(
            FileManager.default.fileExists(
                atPath: dir.appendingPathComponent("double_pinyin.schema.yaml").path))
    }

    // MARK: - 模糊音置灰门卫（26 键双拼激活态）

    func testShuangpinBindingGreysManagedFuzzyPinyin() {
        let values: [String: Any] = [
            KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.twentySixKey.rawValue,
            KeyboardLayoutSettingsKey.schemeBinding26: "double_pinyin_flypy",
        ]
        let (store, _) = makeStore(settings: values)

        XCTAssertEqual(store.settingsCapabilitySchemaID, "double_pinyin_flypy")
        XCTAssertFalse(store.supportsManagedFuzzyPinyin)
        // 提示文案用产品名，不落裸 schema ID。
        XCTAssertEqual(store.settingsCapabilitySchemeDisplayName, "小鹤双拼")
        XCTAssertTrue(store.fuzzyPinyinCapabilityStatusText.contains("小鹤双拼"))
    }

    func testNaturalCodeBindingReportsProductDisplayName() {
        let values: [String: Any] = [
            KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.twentySixKey.rawValue,
            KeyboardLayoutSettingsKey.schemeBinding26: "double_pinyin",
        ]
        let (store, _) = makeStore(settings: values)

        XCTAssertFalse(store.supportsManagedFuzzyPinyin)
        XCTAssertEqual(store.settingsCapabilitySchemeDisplayName, "自然码双拼")
    }

    func testFullPinyinBindingKeepsManagedFuzzyPinyinAvailable() {
        let values: [String: Any] = [
            KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.twentySixKey.rawValue,
            KeyboardLayoutSettingsKey.schemeBinding26: "rime_ice",
        ]
        let (store, _) = makeStore(settings: values)

        XCTAssertTrue(store.supportsManagedFuzzyPinyin)
    }

    // MARK: - 九宫格切换退出双拼门卫

    func testNineKeySwitchExitsShuangpinFuzzyGate() {
        let values: [String: Any] = [
            KeyboardLayoutSettingsKey.layoutStyle: KeyboardLayoutStyle.nineKey.rawValue,
            KeyboardLayoutSettingsKey.schemeBinding26: "double_pinyin_flypy",
            KeyboardLayoutSettingsKey.schemeBinding9: "t9",
        ]
        let (store, _) = makeStore(settings: values)

        XCTAssertEqual(store.settingsCapabilitySchemaID, "rime_ice")
        XCTAssertTrue(store.supportsManagedFuzzyPinyin)
    }
}

// MARK: - Fixtures

@MainActor
private final class ShuangpinStubPersistence: RimeSettingsPersisting {
    private var values: [String: Any] = [:]

    func string(forKey key: String) -> String? { values[key] as? String }
    func integer(forKey key: String) -> Int { values[key] as? Int ?? 0 }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func hasValue(forKey key: String) -> Bool { values[key] != nil }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func synchronize() {}
}

@MainActor
private final class ShuangpinBackupService: RimeUserDictionaryBackingUp {
    func status(for schemaID: String) -> RimeUserDictionaryBackupStatus {
        RimeUserDictionaryBackupStatus(hasLearningData: false, latestBackupDate: nil, readiness: .noLearningData)
    }
    func backup(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        RimeUserDictionaryOperationResult(succeeded: false, message: "")
    }
    func restoreLatest(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        RimeUserDictionaryOperationResult(succeeded: false, message: "")
    }
    func resetLearningData(schemaID: String, displayName: String) -> RimeUserDictionaryOperationResult {
        RimeUserDictionaryOperationResult(succeeded: false, message: "")
    }
}

@MainActor
private final class ShuangpinSharedSettingsStore: SharedSettingsStoring, RimeSettingsPersisting {
    private var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func string(forKey key: String) -> String? { values[key] as? String }
    func integer(forKey key: String) -> Int { values[key] as? Int ?? 0 }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func hasValue(forKey key: String) -> Bool { values[key] != nil }
    func object(forKey key: String) -> Any? { values[key] }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func removeObject(forKey key: String) { values.removeValue(forKey: key) }
    func synchronize() {}
}

nonisolated private struct ShuangpinSourceSelector: SchemaSourceSelecting {
    func selectSource(
        from variants: [RimeSchemeSourceVariant],
        preferredSourceID: String?
    ) async throws -> RimeSchemeSourceVariant {
        if let preferredSourceID, let preferred = variants.first(where: { $0.id == preferredSourceID }) {
            return preferred
        }
        guard let first = variants.first else { throw DownloadError.allSourcesUnavailable }
        return first
    }
}

private struct ShuangpinArchiveDownloader: SchemaArchiveDownloading {
    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive {
        onProgress?(1)
        return DownloadedSchemaArchive(
            localURL: URL(fileURLWithPath: "/tmp/\(UUID().uuidString).zip"),
            expectedContentLength: source.expectedByteCount,
            operationID: operationID,
            attemptID: attemptID,
            sourceID: source.id,
            artifactID: UUID(),
            finalHost: source.downloadURL.host ?? "github.com"
        )
    }
}

@MainActor
private final class ShuangpinArchiveInstaller: SchemaArchiveInstalling {
    private let runtimeRoot: URL?

    init(runtimeRoot: URL? = nil) {
        self.runtimeRoot = runtimeRoot
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        URL(fileURLWithPath: "/tmp/\(distribution.cachedArchiveFileName)")
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        URL(fileURLWithPath: "/tmp/\(distribution.extractionDirectoryName)")
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { false }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(from extractDir: URL, plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws {}
    func createUpgradeCheckpoint(plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
        -> SchemaUpgradeCheckpoint?
    { nil }
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {}
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {}
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        SchemaUninstallStaging(rootURL: URL(fileURLWithPath: "/tmp/staging"), movedRelativePaths: [])
    }
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {}
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) {}
    func clearBuildCache(plan: RimeSchemeInstallationPlan) {}
    func sharedDataDirectoryURL() -> URL? {
        runtimeRoot ?? URL(fileURLWithPath: "/tmp/shared")
    }
    func runtimeDirectories() throws -> SchemaDeploymentDirectories {
        SchemaDeploymentDirectories(
            sharedDataURL: runtimeRoot ?? URL(fileURLWithPath: "/tmp/shared"),
            userDataURL: (runtimeRoot ?? URL(fileURLWithPath: "/tmp")).appendingPathComponent("user")
        )
    }
    func deploymentDirectories(pendingSchemaID: String?) throws -> SchemaDeploymentDirectories {
        SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: "/tmp/shared"),
            userDataURL: URL(fileURLWithPath: "/tmp/user")
        )
    }
}

private actor ShuangpinDeploymentService: RimeDeploymentServicing {
    let succeeded: Bool
    private(set) var requests: [RimeDeploymentRequest] = []

    init(succeeded: Bool) {
        self.succeeded = succeeded
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        requests.append(request)
        return RimeDeploymentResult(
            succeeded: succeeded,
            diagnosticMessage: "test",
            librimeVersion: succeeded ? "test-librime" : nil,
            runtimeSmokePassed: succeeded ? true : nil
        )
    }
}
