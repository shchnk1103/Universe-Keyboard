import Foundation
import XCTest

@testable import Universe_Keyboard

final class RimeSyncModelTests: XCTestCase {
    func testSyncNotificationCopyFiltersAndCombinesSelectedScopes() throws {
        let standardPhaseStarted = RimeSyncNotificationEvent.phaseStarted(
            mode: .automatic,
            scope: .standardRimeData,
            completedScopes: [],
            pendingScopes: [.privateSettings]
        )

        let combinedPayload = try XCTUnwrap(
            standardPhaseStarted.payload(enabledScopes: [.standardRimeData, .privateSettings])
        )
        XCTAssertEqual(combinedPayload.title, "开始自动同步")
        XCTAssertTrue(combinedPayload.body.contains("RIME 常用词、标准资料和 Universe App 设置"))

        XCTAssertNil(standardPhaseStarted.payload(enabledScopes: [.privateSettings]))

        let privatePhaseStarted = RimeSyncNotificationEvent.phaseStarted(
            mode: .automatic,
            scope: .privateSettings,
            completedScopes: [.standardRimeData],
            pendingScopes: []
        )
        let privatePayload = try XCTUnwrap(
            privatePhaseStarted.payload(enabledScopes: [.privateSettings])
        )
        XCTAssertTrue(privatePayload.body.contains("Universe App 设置"))
        XCTAssertNil(
            privatePhaseStarted.payload(enabledScopes: [.standardRimeData, .privateSettings])
        )

        let failedStandard = RimeSyncNotificationEvent.failed(
            mode: .manual,
            failedScope: .standardRimeData,
            completedScopes: [],
            pendingScopes: [.privateSettings]
        )
        let failurePayload = try XCTUnwrap(
            failedStandard.payload(enabledScopes: [.standardRimeData, .privateSettings])
        )
        XCTAssertEqual(failurePayload.title, "同步失败")
        XCTAssertTrue(failurePayload.body.contains("RIME 常用词和标准资料未完成"))
        XCTAssertTrue(failurePayload.body.contains("Universe App 设置尚未开始"))
        XCTAssertNil(failedStandard.payload(enabledScopes: [.privateSettings]))

        let failedPrivate = RimeSyncNotificationEvent.failed(
            mode: .manual,
            failedScope: .privateSettings,
            completedScopes: [.standardRimeData],
            pendingScopes: []
        )
        let standardOnlyPayload = try XCTUnwrap(
            failedPrivate.payload(enabledScopes: [.standardRimeData])
        )
        XCTAssertEqual(standardOnlyPayload.title, "同步完成")
        XCTAssertTrue(standardOnlyPayload.body.contains("RIME 常用词和标准资料已更新"))
    }

    @MainActor
    func testAutomaticSyncSuboptionsDefaultOnAndPreserveExplicitChoice() {
        let suiteName = "RimeSyncSuboptions-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let migratedModel = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults
        )
        XCTAssertTrue(migratedModel.automaticStandardRimeDataEnabled)
        XCTAssertTrue(migratedModel.automaticPrivateSettingsEnabled)

        defaults.set(false, forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled)
        let explicitChoiceModel = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults
        )
        XCTAssertFalse(explicitChoiceModel.automaticStandardRimeDataEnabled)
        XCTAssertTrue(explicitChoiceModel.automaticPrivateSettingsEnabled)
    }

    @MainActor
    func testAutomaticSyncRequiresUserOptInAndTurnsOffWithLastScope() {
        let suiteName = "RimeSyncOptIn-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set(Data([0x01]), forKey: RimeSyncStorageKey.folderBookmark)
        defaults.set(Date(), forKey: RimeSyncStorageKey.standardRimeLastSuccess)

        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults
        )
        XCTAssertFalse(model.automaticSyncEnabled)

        model.setAutomaticSyncEnabled(true)
        XCTAssertTrue(model.automaticSyncEnabled)
        XCTAssertTrue(model.automaticStandardRimeDataEnabled)
        XCTAssertTrue(model.automaticPrivateSettingsEnabled)

        model.setAutomaticStandardRimeDataEnabled(false)
        XCTAssertTrue(model.automaticSyncEnabled)

        model.setAutomaticPrivateSettingsEnabled(false)
        XCTAssertFalse(model.automaticSyncEnabled)
        XCTAssertFalse(defaults.bool(forKey: RimeSyncStorageKey.automaticSyncEnabled))

        model.setAutomaticSyncEnabled(true)
        XCTAssertTrue(model.automaticSyncEnabled)
        XCTAssertTrue(model.automaticStandardRimeDataEnabled)
        XCTAssertTrue(model.automaticPrivateSettingsEnabled)

        defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)
        defaults.set(false, forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled)
        defaults.set(false, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)
        let repairedModel = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults
        )
        XCTAssertFalse(repairedModel.automaticSyncEnabled)
    }

    func testSyncPhasesDescribeTheSingleVisibleSyncFlow() {
        XCTAssertEqual(RimeSyncPhase.standardRimeData.progressMessage, "正在同步 RIME 用户资料…")
        XCTAssertEqual(RimeSyncPhase.privateSettings.progressMessage, "正在同步 Universe 私密设置…")
        XCTAssertEqual(
            RimeSyncCompletion.standardRimeAndPrivateSettings.message,
            "RIME 用户资料与私密设置已同步"
        )
        XCTAssertEqual(RimeSyncCompletion.standardRimeData.message, "RIME 标准资料已同步")
    }

    func testProfileUpdatesOnlyChangedFieldsAndPreservesUnknownFields() {
        let original = RimeSyncProfile(fields: [
            "future.setting": RimeSyncField(
                value: .string("preserve-me"),
                version: .init(counter: 4, deviceID: "future-device")
            ),
            "rime.pageSize": RimeSyncField(
                value: .int(9),
                version: .init(counter: 3, deviceID: "phone")
            ),
        ])

        let updated = original.updating(
            values: ["rime.pageSize": .int(12)],
            deviceID: "tablet"
        )

        XCTAssertEqual(updated.fields["future.setting"]?.value, .string("preserve-me"))
        XCTAssertEqual(updated.fields["rime.pageSize"]?.value, .int(12))
        XCTAssertEqual(updated.fields["rime.pageSize"]?.version.counter, 5)
        XCTAssertEqual(updated.fields["rime.pageSize"]?.version.deviceID, "tablet")
    }

    func testProfileMergeKeepsIndependentChangesAndDeterministicallyResolvesSameField() throws {
        let phone = RimeSyncProfile(fields: [
            "rime.pageSize": .init(
                value: .int(12),
                version: .init(counter: 8, deviceID: "phone")
            ),
            "rime.simplified": .init(
                value: .bool(true),
                version: .init(counter: 7, deviceID: "phone")
            ),
        ])
        let desktop = RimeSyncProfile(fields: [
            "rime.pageSize": .init(
                value: .int(15),
                version: .init(counter: 8, deviceID: "windows")
            ),
            "rime.fuzzy.enabled": .init(
                value: .bool(false),
                version: .init(counter: 9, deviceID: "windows")
            ),
        ])

        let merged = try phone.merging(desktop)

        XCTAssertEqual(merged.fields["rime.pageSize"]?.value, .int(15))
        XCTAssertEqual(merged.fields["rime.simplified"]?.value, .bool(true))
        XCTAssertEqual(merged.fields["rime.fuzzy.enabled"]?.value, .bool(false))
    }

    func testScalarUsesPlainJSONValues() throws {
        let values: [String: RimeSyncScalar] = [
            "bool": .bool(true),
            "int": .int(9),
            "string": .string("rime_ice"),
        ]

        let data = try JSONEncoder().encode(values)
        let json = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(json.contains("true"))
        XCTAssertTrue(json.contains("9"))
        XCTAssertTrue(json.contains("rime_ice"))
        XCTAssertEqual(try JSONDecoder().decode([String: RimeSyncScalar].self, from: data), values)
    }
}

final class RimeSyncCryptoTests: XCTestCase {
    func testEncryptionRoundTripAndRecoveryCodeRoundTrip() throws {
        let codec = RimeSyncPackageCodec()
        let key = RimeSyncPackageCodec.generateKey()
        let profile = RimeSyncProfile(fields: [
            "rime.pageSize": .init(
                value: .int(11),
                version: .init(counter: 1, deviceID: "iphone")
            )
        ])

        let encrypted = try codec.encrypt(profile: profile, keyData: key)
        let recoveryCode = RimeSyncPackageCodec.recoveryCode(for: key)
        let recoveredKey = try RimeSyncPackageCodec.keyData(fromRecoveryCode: recoveryCode)

        XCTAssertNil(encrypted.range(of: Data("rime.pageSize".utf8)))
        XCTAssertEqual(recoveredKey, key)
        XCTAssertEqual(try codec.decrypt(data: encrypted, keyData: recoveredKey), profile)
    }

    func testWrongKeyFailsClosed() throws {
        let codec = RimeSyncPackageCodec()
        let encrypted = try codec.encrypt(
            profile: RimeSyncProfile(),
            keyData: RimeSyncPackageCodec.generateKey()
        )

        XCTAssertThrowsError(
            try codec.decrypt(data: encrypted, keyData: RimeSyncPackageCodec.generateKey())
        ) { error in
            XCTAssertEqual(error as? RimeSyncError, .corruptedPackage)
        }
    }
}

final class RimeSyncTransportTests: XCTestCase {
    func testFolderPreflightDiagnosticIncludesTheFailingStage() {
        let missingFolder = NSError(domain: NSCocoaErrorDomain, code: 260)
        let error = RimeSyncFolderAccessError.preflight(
            stage: "coordinate",
            underlying: missingFolder
        )

        XCTAssertEqual(
            RimeSyncFolderAccess.diagnosticErrorCode(for: error),
            "preflight.coordinate.NSCocoaErrorDomain#260"
        )
    }

    func testLocalFolderPreflightVerifiesAccessWithoutLeavingFiles() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-preflight-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try RimeSyncFolderAccess.preflight(root)

        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: root.path), [])
    }

    func testLocalFolderPublishesContractLayoutAndRejectsStaleETag() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-transport-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let transport = LocalFolderRimeSyncTransport(selectedFolderURL: root)
        let initial = try await transport.fetchSettings()
        XCTAssertNil(initial.data)
        XCTAssertNil(initial.eTag)

        let firstData = Data("first".utf8)
        try await transport.publish(
            formatData: Data("{}".utf8),
            settingsData: firstData,
            matching: nil
        )
        let fetched = try await transport.fetchSettings()
        XCTAssertEqual(fetched.data, firstData)
        XCTAssertNotNil(fetched.eTag)

        do {
            try await transport.publish(
                formatData: Data("{}".utf8),
                settingsData: Data("stale".utf8),
                matching: "stale-etag"
            )
            XCTFail("Expected stale write to fail")
        } catch {
            XCTAssertEqual(error as? RimeSyncError, .remoteConflict)
        }

        let settingsURL = root
            .appendingPathComponent("universe-rime-sync/profiles/default/settings.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: settingsURL.path))
    }

    func testCoordinatorRetriesOneConcurrentWrite() async throws {
        let transport = ConflictOnceSyncTransport()
        let coordinator = RimeSyncCoordinator(maximumConflictRetries: 2)
        let profile = RimeSyncProfile(fields: [
            "rime.simplified": .init(
                value: .bool(true),
                version: .init(counter: 1, deviceID: "ios")
            )
        ])

        let result = try await coordinator.synchronize(
            localProfile: profile,
            keyData: RimeSyncPackageCodec.generateKey(),
            transport: transport
        )

        let attempts = await transport.publishAttempts
        XCTAssertEqual(result.profile, profile)
        XCTAssertEqual(attempts, 2)
    }

    func testCoordinatorRejectsOversizedRemotePackageBeforeDecryption() async throws {
        let transport = OversizedSyncTransport()
        let coordinator = RimeSyncCoordinator()

        do {
            _ = try await coordinator.synchronize(
                localProfile: RimeSyncProfile(),
                keyData: RimeSyncPackageCodec.generateKey(),
                transport: transport
            )
            XCTFail("Expected oversized package to fail")
        } catch {
            XCTAssertEqual(error as? RimeSyncError, .packageTooLarge)
        }
    }

    func testWebDAVUsesConditionalWriteAndExpectedPackagePaths() async throws {
        let baseURL = try XCTUnwrap(URL(string: "https://sync.example.test/dav/universe-rime-sync"))
        let client = RecordingRimeSyncHTTPClient(baseURL: baseURL)
        let transport = WebDAVRimeSyncTransport(
            baseURL: baseURL,
            username: "user",
            password: "secret",
            client: client
        )

        let remote = try await transport.fetchSettings()
        XCTAssertEqual(remote.data, Data("remote".utf8))
        XCTAssertEqual(remote.eTag, "etag-1")

        try await transport.publish(
            formatData: Data("format".utf8),
            settingsData: Data("settings".utf8),
            matching: remote.eTag
        )

        let requests = await client.requests
        XCTAssertEqual(requests.first?.httpMethod, "GET")
        XCTAssertEqual(requests.first?.url?.path, "/dav/universe-rime-sync/profiles/default/settings.json")
        XCTAssertEqual(requests.filter { $0.httpMethod == "MKCOL" }.count, 3)
        let settingsPut = try XCTUnwrap(
            requests.first { $0.httpMethod == "PUT" && $0.url?.lastPathComponent == "settings.json" }
        )
        XCTAssertEqual(settingsPut.value(forHTTPHeaderField: "If-Match"), "etag-1")
        XCTAssertNotNil(settingsPut.value(forHTTPHeaderField: "Authorization"))
    }
}

private actor ConflictOnceSyncTransport: RimeSyncTransport {
    private(set) var publishAttempts = 0
    private var data: Data?
    private var eTag: String?

    func fetchSettings() async throws -> RimeSyncRemoteObject {
        RimeSyncRemoteObject(data: data, eTag: eTag)
    }

    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {
        publishAttempts += 1
        if publishAttempts == 1 {
            throw RimeSyncError.remoteConflict
        }
        data = settingsData
        self.eTag = "etag-2"
    }

    func deleteRemoteData() async throws {
        data = nil
        eTag = nil
    }
}

private actor OversizedSyncTransport: RimeSyncTransport {
    func fetchSettings() async throws -> RimeSyncRemoteObject {
        RimeSyncRemoteObject(
            data: Data(count: RimeSyncCoordinator.maximumSettingsPackageBytes + 1),
            eTag: "oversized"
        )
    }

    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {
        XCTFail("Oversized remote data must not be published")
    }

    func deleteRemoteData() async throws {}
}

private actor RecordingRimeSyncHTTPClient: RimeSyncHTTPClient {
    private(set) var requests: [URLRequest] = []
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        let statusCode: Int
        let headers: [String: String]
        let data: Data

        switch request.httpMethod {
        case "GET":
            statusCode = 200
            headers = ["ETag": "etag-1"]
            data = Data("remote".utf8)
        case "MKCOL":
            statusCode = 201
            headers = [:]
            data = Data()
        case "PUT":
            statusCode = 204
            headers = [:]
            data = Data()
        default:
            statusCode = 204
            headers = [:]
            data = Data()
        }

        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: request.url ?? baseURL,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: headers
            )
        )
        return (data, response)
    }
}
