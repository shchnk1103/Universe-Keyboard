import Foundation
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class RimeSettingsStoreTests: XCTestCase {
    func testLoadReadsPreferencesThroughInjectedPersistence() {
        let persistence = StubRimeSettingsPersistence(
            values: ["rime_page_size": 12, "rime_simplification": false]
        )
        let store = RimeSettingsStore(persistence: persistence)

        store.load()

        XCTAssertEqual(store.pageSize, 12)
        XCTAssertFalse(store.simplified)
    }

    func testTriggerDeploymentCompletesInsideMainAppBeforeKeyboardUse() async {
        let settings = StoreSharedSettingsStore()
        let deploymentService = StoreDeploymentService(succeeded: true)
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                catalogClient: StoreCatalogClient(),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: deploymentService
            ),
            persistence: StubRimeSettingsPersistence()
        )

        await store.triggerDeployment()

        let requests = await deploymentService.requests
        XCTAssertEqual(requests.count, 1)
        guard case .fullCheck = requests[0].mode else {
            return XCTFail("The main app must own full deployment.")
        }
        XCTAssertEqual(store.deploymentState, .deployed)
        XCTAssertTrue(store.deploymentLog.contains { $0.contains("键盘可直接使用") })
    }

    func testCheckForUpdateReportsAlreadyCurrentWithoutStartingDownload() async {
        let settings = StoreSharedSettingsStore(values: ["rime_ice_version": "2026.05.01"])
        let store = RimeSettingsStore(
            schemaManager: SchemaManager(
                settings: settings,
                catalogClient: StoreCatalogClient(
                    latestURL: URL(string: "https://github.com/iDvel/rime-ice/releases/download/2026.05.01/full.zip")
                ),
                archiveDownloader: StoreArchiveDownloader(),
                archiveInstaller: StoreArchiveInstaller(),
                deploymentService: StoreDeploymentService(succeeded: true)
            ),
            persistence: StubRimeSettingsPersistence()
        )

        await store.checkForUpdateAndDownload()

        XCTAssertEqual(store.updateStatusMessage, "已是最新版本")
        XCTAssertEqual(store.downloadState, .idle)
    }
}

@MainActor
private final class StubRimeSettingsPersistence: RimeSettingsPersisting {
    private var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func integer(forKey key: String) -> Int { values[key] as? Int ?? 0 }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func hasValue(forKey key: String) -> Bool { values[key] != nil }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func synchronize() {}
}

@MainActor
private final class StoreSharedSettingsStore: SharedSettingsStoring {
    private var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func string(forKey key: String) -> String? { values[key] as? String }
    func bool(forKey key: String) -> Bool { values[key] as? Bool ?? false }
    func object(forKey key: String) -> Any? { values[key] }
    func set(_ value: Any?, forKey key: String) { values[key] = value }
    func removeObject(forKey key: String) { values.removeValue(forKey: key) }
    func synchronize() {}
}

private struct StoreCatalogClient: SchemaCatalogClient {
    let latestURL: URL?

    init(latestURL: URL? = nil) {
        self.latestURL = latestURL
    }

    func latestRimeIceArchiveURL() async throws -> URL? { latestURL }
}

private struct StoreArchiveDownloader: SchemaArchiveDownloading {
    func downloadArchive(
        from url: URL,
        existingETag: String?,
        cachedArchiveURL: URL
    ) async throws -> DownloadedSchemaArchive {
        DownloadedSchemaArchive(localURL: cachedArchiveURL, expectedContentLength: 1, eTag: existingETag)
    }
}

@MainActor
private final class StoreArchiveInstaller: SchemaArchiveInstalling {
    var cachedArchiveURL: URL { URL(fileURLWithPath: "/tmp/rime.zip") }
    func prepareExtractionDirectory() throws -> URL { URL(fileURLWithPath: "/tmp/rime-extract") }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledRimeIceSchema() -> Bool { false }
    func checkDiskSpace(needed: Int64) throws {}
    func installRimeIceFiles(from extractDir: URL, luaAvailable: Bool) throws {}
    func uninstallRimeIceFiles() {}
    func deploymentDirectories() throws -> SchemaDeploymentDirectories {
        SchemaDeploymentDirectories(
            sharedDataURL: URL(fileURLWithPath: "/tmp/shared"),
            userDataURL: URL(fileURLWithPath: "/tmp/user")
        )
    }
}

private actor StoreDeploymentService: RimeDeploymentServicing {
    let succeeded: Bool
    private(set) var requests: [RimeDeploymentRequest] = []

    init(succeeded: Bool) {
        self.succeeded = succeeded
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        requests.append(request)
        return RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")
    }
}
