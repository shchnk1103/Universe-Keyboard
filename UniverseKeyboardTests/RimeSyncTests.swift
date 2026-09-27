import Foundation
import RimeBridge
import Security
import XCTest

@testable import Universe_Keyboard

final class RimeSyncModelTests: XCTestCase {
    @MainActor
    func testUITestFixtureDisablesProductionBackgroundScheduling() throws {
        let suiteName = "RimeSyncUITestFixture-\(UUID().uuidString)"
        let arguments = [
            RimeSyncUITestFixture.localFolderArgument,
            RimeSyncUITestFixture.defaultsSuiteArgument,
            suiteName,
        ]
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let model = try XCTUnwrap(
            RimeSyncUITestFixture.makeViewModelIfRequested(
                rimeStore: RimeSettingsStore(),
                arguments: arguments
            )
        )

        XCTAssertFalse(model.backgroundSchedulingEnabled)
    }

    func testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem() async throws {
        let account = "integration-test-\(UUID().uuidString)"
        try requireKeychainEntitlement(for: account)

        let secretStore = RimeSyncSecretStore()
        let firstValue = Data("first-test-value".utf8)
        let updatedValue = Data("updated-test-value".utf8)

        let initialValue = try await secretStore.data(for: account)
        XCTAssertNil(initialValue)

        do {
            try await secretStore.set(firstValue, for: account)
            let storedFirstValue = try await secretStore.data(for: account)
            XCTAssertEqual(storedFirstValue, firstValue)

            try await secretStore.set(updatedValue, for: account)
            let storedUpdatedValue = try await secretStore.data(for: account)
            XCTAssertEqual(storedUpdatedValue, updatedValue)

            try await secretStore.remove(account)
            let removedValue = try await secretStore.data(for: account)
            XCTAssertNil(removedValue)
        } catch {
            try? await secretStore.remove(account)
            throw error
        }
    }

    func testKeychainAccessDeniedGuidanceDoesNotReferToSyncFolder() {
        let message = RimeSyncError.keychainAccessDenied.errorDescription

        XCTAssertEqual(message, "无法访问本机 Keychain 同步凭据，请检查钥匙串权限后重试。")
        XCTAssertFalse(message?.contains("同步目录") ?? true)
        XCTAssertFalse(message?.contains("重新选择") ?? true)
        XCTAssertEqual(
            RimeSyncFolderAccess.diagnosticErrorCode(for: RimeSyncError.keychainAccessDenied),
            "keychain.access_denied"
        )
        XCTAssertEqual(
            RimeSyncDiagnosticFailureMapper.failure(for: RimeSyncError.keychainAccessDenied),
            .keychainAccessDenied
        )
        XCTAssertEqual(
            RimeSyncDiagnosticFailureMapper.failure(for: RimeSyncError.accessDenied),
            .accessDenied
        )
    }

    private func requireKeychainEntitlement(for account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.DoubleShy0N.Universe-Keyboard.rime-sync",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecMissingEntitlement {
            throw XCTSkip(
                "Unsigned host lacks Keychain entitlement; signed Simulator lane covers integration."
            )
        }

        guard status == errSecItemNotFound else {
            XCTFail("Keychain preflight expected an absent unique account, got OSStatus \(status).")
            return
        }
    }

    @MainActor
    func testRemoteDeletionDisconnectRemovesSecretsAndSyncConfiguration() async throws {
        let suiteName = "RimeSyncDisconnect-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(RimeSyncProvider.webDAV.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set("https://sync.example.test/dav", forKey: RimeSyncStorageKey.webDAVURL)
        defaults.set("tester", forKey: RimeSyncStorageKey.webDAVUsername)
        defaults.set(Date(), forKey: RimeSyncStorageKey.lastSuccess)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)

        let secretStore = MemoryRimeSyncSecretStore()
        try await secretStore.set(Data("password".utf8), for: "webdav-password")
        try await secretStore.set(Data(repeating: 0x42, count: 32), for: "encryption-key")
        let transport = DeletionRecordingSyncTransport()
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            secretStore: secretStore,
            syncTransportFactory: { transport }
        )
        await model.loadSecrets()

        XCTAssertTrue(model.isConfigured)
        await model.disconnect(deleteRemoteData: true)

        let deletionCount = await transport.deletionCount()
        let password = try await secretStore.data(for: "webdav-password")
        let encryptionKey = try await secretStore.data(for: "encryption-key")
        XCTAssertEqual(deletionCount, 1)
        XCTAssertNil(password)
        XCTAssertNil(encryptionKey)
        XCTAssertNil(defaults.object(forKey: RimeSyncStorageKey.provider))
        XCTAssertNil(defaults.object(forKey: RimeSyncStorageKey.webDAVURL))
        XCTAssertNil(defaults.object(forKey: RimeSyncStorageKey.webDAVUsername))
        XCTAssertNil(defaults.object(forKey: RimeSyncStorageKey.lastSuccess))
        XCTAssertNil(defaults.object(forKey: RimeSyncStorageKey.automaticSyncEnabled))
        XCTAssertEqual(model.provider, .none)
        XCTAssertFalse(model.isConfigured)
        XCTAssertEqual(model.webDAVPassword, "")
        XCTAssertEqual(model.recoveryCode, "")
    }

    @MainActor
    func testRemoteDeletionReportsPartialKeychainCleanupAndCanBeRetried() async throws {
        let suiteName = "RimeSyncDisconnectPartialCleanup-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(RimeSyncProvider.webDAV.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set("https://sync.example.test/dav", forKey: RimeSyncStorageKey.webDAVURL)
        defaults.set("tester", forKey: RimeSyncStorageKey.webDAVUsername)

        let secretStore = FailingRemovalRimeSyncSecretStore(
            values: [
                "webdav-password": Data("password".utf8),
                "encryption-key": Data(repeating: 0x2A, count: 32),
            ],
            failingAccount: "webdav-password"
        )
        let transport = DeletionRecordingSyncTransport()
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            secretStore: secretStore,
            syncTransportFactory: { transport }
        )
        await model.loadSecrets()

        await model.disconnect(deleteRemoteData: true)

        let firstDeletionCount = await transport.deletionCount()
        XCTAssertEqual(firstDeletionCount, 1)
        XCTAssertTrue(model.isConfigured)
        XCTAssertTrue(model.statusText.contains("云端加密设置包已删除"))
        XCTAssertTrue(model.statusText.contains("Keychain 凭据清理未完成"))
        XCTAssertTrue(model.statusText.contains("重试“删除云端数据并断开”"))
        XCTAssertTrue(model.statusText.contains("无需重新选择同步文件夹"))
        XCTAssertFalse(model.statusText.contains("无法访问或写入同步目录"))
        let keyAfterFirstAttempt = try await secretStore.data(for: "encryption-key")
        let passwordAfterFirstAttempt = try await secretStore.data(for: "webdav-password")
        XCTAssertNil(keyAfterFirstAttempt)
        XCTAssertEqual(passwordAfterFirstAttempt, Data("password".utf8))

        await secretStore.allowAllRemovals()
        await model.disconnect(deleteRemoteData: true)

        let deletionCountAfterRetry = await transport.deletionCount()
        XCTAssertEqual(deletionCountAfterRetry, 2)
        XCTAssertEqual(model.provider, .none)
        XCTAssertFalse(model.isConfigured)
        let passwordAfterRetry = try await secretStore.data(for: "webdav-password")
        XCTAssertNil(passwordAfterRetry)
    }

    @MainActor
    func testDisconnectDoesNotMutateStateWhileAnotherProcessSyncOwnsGate() async throws {
        let suiteName = "RimeSyncDisconnectBusy-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(RimeSyncProvider.webDAV.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set("https://sync.example.test/dav", forKey: RimeSyncStorageKey.webDAVURL)
        defaults.set("tester", forKey: RimeSyncStorageKey.webDAVUsername)

        let secretStore = MemoryRimeSyncSecretStore()
        let password = Data("password".utf8)
        let encryptionKey = Data(repeating: 0x42, count: 32)
        try await secretStore.set(password, for: "webdav-password")
        try await secretStore.set(encryptionKey, for: "encryption-key")

        let transport = DeletionRecordingSyncTransport()
        let processGate = RimeSyncProcessGate()
        let backgroundLease = try XCTUnwrap(processGate.claim(source: .backgroundAutomatic))
        defer { processGate.release(backgroundLease) }

        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            secretStore: secretStore,
            syncTransportFactory: { transport },
            processGate: processGate,
            keyboardActivityDefaults: defaults,
            backgroundSchedulingEnabled: false
        )
        await model.loadSecrets()

        await model.disconnect(deleteRemoteData: true)

        let deletionCount = await transport.deletionCount()
        let storedPassword = try await secretStore.data(for: "webdav-password")
        let storedEncryptionKey = try await secretStore.data(for: "encryption-key")
        XCTAssertEqual(processGate.activeSource, .backgroundAutomatic)
        XCTAssertEqual(deletionCount, 0)
        XCTAssertEqual(storedPassword, password)
        XCTAssertEqual(storedEncryptionKey, encryptionKey)
        XCTAssertEqual(defaults.string(forKey: RimeSyncStorageKey.provider), RimeSyncProvider.webDAV.rawValue)
        XCTAssertEqual(defaults.string(forKey: RimeSyncStorageKey.webDAVURL), "https://sync.example.test/dav")
        XCTAssertTrue(model.isConfigured)
        guard case .failed(let message) = model.status else {
            return XCTFail("Busy disconnect must report an actionable status")
        }
        XCTAssertEqual(message, "另一个同步操作正在进行，请完成后再试。")
    }

    @MainActor
    func testConfigurationAndManualSyncAreRejectedWhileAnotherProcessOwnsGate() async throws {
        let suiteName = "RimeSyncConfigurationBusy-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(RimeSyncProvider.webDAV.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set("https://sync.example.test/dav", forKey: RimeSyncStorageKey.webDAVURL)
        defaults.set("tester", forKey: RimeSyncStorageKey.webDAVUsername)
        defaults.set(Data([0x01, 0x02]), forKey: RimeSyncStorageKey.folderBookmark)
        defaults.set("Existing Folder", forKey: RimeSyncStorageKey.folderName)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)
        defaults.set(RimeAutomaticSyncCadence.daily.rawValue, forKey: RimeSyncStorageKey.automaticSyncCadence)

        let secretStore = MemoryRimeSyncSecretStore()
        let password = Data("existing-password".utf8)
        let existingKey = Data(repeating: 0x42, count: 32)
        let replacementKey = Data(repeating: 0x24, count: 32)
        try await secretStore.set(password, for: "webdav-password")
        try await secretStore.set(existingKey, for: "encryption-key")

        let processGate = RimeSyncProcessGate()
        let backgroundLease = try XCTUnwrap(processGate.claim(source: .backgroundAutomatic))
        defer { processGate.release(backgroundLease) }

        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            secretStore: secretStore,
            processGate: processGate,
            keyboardActivityDefaults: defaults,
            backgroundSchedulingEnabled: false
        )
        await model.loadSecrets()

        model.recoveryCodeInput = RimeSyncPackageCodec.recoveryCode(for: replacementKey)
        await model.importRecoveryCode()
        model.selectProvider(.none)
        await model.configureLocalFolder(
            FileManager.default.temporaryDirectory.appendingPathComponent("not-selected"),
            hasActivePickerScope: false
        )
        model.setAutomaticPrivateSettingsEnabled(false)
        model.setAutomaticSyncCadence(.weekly)
        await model.saveWebDAVConfiguration()
        await model.synchronizeAllNow()

        let storedPassword = try await secretStore.data(for: "webdav-password")
        let storedKey = try await secretStore.data(for: "encryption-key")
        XCTAssertEqual(processGate.activeSource, .backgroundAutomatic)
        XCTAssertEqual(storedPassword, password)
        XCTAssertEqual(storedKey, existingKey)
        XCTAssertEqual(defaults.string(forKey: RimeSyncStorageKey.provider), RimeSyncProvider.webDAV.rawValue)
        XCTAssertEqual(defaults.data(forKey: RimeSyncStorageKey.folderBookmark), Data([0x01, 0x02]))
        XCTAssertEqual(defaults.string(forKey: RimeSyncStorageKey.folderName), "Existing Folder")
        XCTAssertTrue(defaults.bool(forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled))
        XCTAssertEqual(
            defaults.string(forKey: RimeSyncStorageKey.automaticSyncCadence),
            RimeAutomaticSyncCadence.daily.rawValue
        )
        XCTAssertEqual(model.provider, .webDAV)
        XCTAssertTrue(model.isConfigured)
        guard case .failed(let message) = model.status else {
            return XCTFail("A rejected manual sync must report an actionable status")
        }
        XCTAssertEqual(message, "另一个同步操作正在进行，请完成后再试。")
    }

    @MainActor
    func testLocalFolderDeletionFailurePreservesPackageConfigurationAndSecrets() async throws {
        let suiteName = "RimeSyncLocalFolderDeleteFailure-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let bookmark = Data([0x01])
        let lastSuccess = Date(timeIntervalSince1970: 1_000)
        defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set(bookmark, forKey: RimeSyncStorageKey.folderBookmark)
        defaults.set("Test Sync Folder", forKey: RimeSyncStorageKey.folderName)
        defaults.set(lastSuccess, forKey: RimeSyncStorageKey.lastSuccess)
        defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)

        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-delete-denied-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageRoot = root.appendingPathComponent("universe-rime-sync", isDirectory: true)
        try FileManager.default.createDirectory(at: packageRoot, withIntermediateDirectories: true)
        let markerURL = packageRoot.appendingPathComponent("settings.json")
        try Data("encrypted-settings".utf8).write(to: markerURL)

        let secretStore = MemoryRimeSyncSecretStore()
        let password = Data("local-provider-password".utf8)
        let encryptionKey = Data(repeating: 0x42, count: 32)
        try await secretStore.set(password, for: "webdav-password")
        try await secretStore.set(encryptionKey, for: "encryption-key")

        let transport = LocalFolderRimeSyncTransport(
            selectedFolderURL: root,
            packageRootState: { _ in throw CocoaError(.fileReadNoPermission) }
        )
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            secretStore: secretStore,
            syncTransportFactory: { transport }
        )
        await model.loadSecrets()

        XCTAssertTrue(model.isConfigured)
        await model.disconnect(deleteRemoteData: true)

        XCTAssertEqual(model.provider, .localFolder)
        XCTAssertTrue(model.isConfigured)
        XCTAssertEqual(defaults.data(forKey: RimeSyncStorageKey.folderBookmark), bookmark)
        XCTAssertEqual(defaults.string(forKey: RimeSyncStorageKey.folderName), "Test Sync Folder")
        XCTAssertEqual(defaults.object(forKey: RimeSyncStorageKey.lastSuccess) as? Date, lastSuccess)
        XCTAssertTrue(defaults.bool(forKey: RimeSyncStorageKey.automaticSyncEnabled))
        if case .failed = model.status {
            // Failure feedback is expected; local configuration must remain retryable.
        } else {
            XCTFail("An indeterminate package state must not be reported as a successful disconnect")
        }

        let storedPassword = try await secretStore.data(for: "webdav-password")
        let storedKey = try await secretStore.data(for: "encryption-key")
        XCTAssertEqual(storedPassword, password)
        XCTAssertEqual(storedKey, encryptionKey)
        XCTAssertTrue(FileManager.default.fileExists(atPath: markerURL.path))
    }

    @MainActor
    func testUnknownPackageRootTypePreservesConfigurationAndSecrets() async throws {
        let suiteName = "RimeSyncLocalFolderUnknownRootType-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let bookmark = Data([0x02])
        defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
        defaults.set(bookmark, forKey: RimeSyncStorageKey.folderBookmark)
        defaults.set("Unknown Type Folder", forKey: RimeSyncStorageKey.folderName)

        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-unknown-root-type-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageRoot = root.appendingPathComponent("universe-rime-sync", isDirectory: true)
        try FileManager.default.createDirectory(at: packageRoot, withIntermediateDirectories: true)
        let markerURL = packageRoot.appendingPathComponent("settings.json")
        try Data("encrypted-settings".utf8).write(to: markerURL)

        let secretStore = MemoryRimeSyncSecretStore()
        let password = Data("local-provider-password".utf8)
        let encryptionKey = Data(repeating: 0x24, count: 32)
        try await secretStore.set(password, for: "webdav-password")
        try await secretStore.set(encryptionKey, for: "encryption-key")

        let transport = LocalFolderRimeSyncTransport(
            selectedFolderURL: root,
            packageRootState: { _ in .unknown }
        )
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            secretStore: secretStore,
            syncTransportFactory: { transport }
        )
        await model.loadSecrets()

        XCTAssertTrue(model.isConfigured)
        await model.disconnect(deleteRemoteData: true)

        XCTAssertEqual(model.provider, .localFolder)
        XCTAssertTrue(model.isConfigured)
        XCTAssertEqual(defaults.data(forKey: RimeSyncStorageKey.folderBookmark), bookmark)
        XCTAssertEqual(defaults.string(forKey: RimeSyncStorageKey.folderName), "Unknown Type Folder")
        if case .failed = model.status {
            // Unknown package type must remain retryable instead of reporting deletion success.
        } else {
            XCTFail("Unknown package-root metadata must fail closed")
        }
        let storedPassword = try await secretStore.data(for: "webdav-password")
        let storedKey = try await secretStore.data(for: "encryption-key")
        XCTAssertEqual(storedPassword, password)
        XCTAssertEqual(storedKey, encryptionKey)
        XCTAssertEqual(try Data(contentsOf: markerURL), Data("encrypted-settings".utf8))
    }

    @MainActor
    func testCancellablePhaseRejectsLateSuccessAfterCancellation() async {
        let gate = NonCooperativePhaseGate()
        let task = Task { @MainActor in
            try await RimeSyncViewModel.runCancellablePhase {
                await gate.run()
                return 42
            }
        }

        await gate.waitUntilStarted()
        task.cancel()
        await gate.release()

        do {
            _ = try await task.value
            XCTFail("A cancelled non-cooperative phase must not publish its late result")
        } catch is CancellationError {
            // Expected: the shared boundary observes cancellation after the phase returns.
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }

    @MainActor
    func testCancellablePhaseReturnsSuccessfulValueWhenStillActive() async throws {
        let value = try await RimeSyncViewModel.runCancellablePhase { 42 }

        XCTAssertEqual(value, 42)
    }

    func testAutomaticCancellationNotificationRequiresAnUnfinishedScope() {
        XCTAssertFalse(
            RimeSyncViewModel.shouldNotifyAutomaticCancellation(
                requestedScopes: [.standardRimeData, .privateSettings],
                completedScopes: [.standardRimeData, .privateSettings]
            )
        )
        XCTAssertTrue(
            RimeSyncViewModel.shouldNotifyAutomaticCancellation(
                requestedScopes: [.standardRimeData, .privateSettings],
                completedScopes: [.standardRimeData]
            )
        )
    }

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

        let automaticStandardCompletion = RimeSyncNotificationEvent.completed(
            mode: .automatic,
            scopes: [.standardRimeData]
        )
        let automaticCompletionPayload = try XCTUnwrap(
            automaticStandardCompletion.payload(enabledScopes: [.standardRimeData])
        )
        XCTAssertEqual(automaticCompletionPayload.title, "自动同步完成")
        XCTAssertEqual(automaticCompletionPayload.body, "RIME 常用词和标准资料已更新。")

        let automaticExpirationBetweenPhases = RimeSyncNotificationEvent.failed(
            mode: .automatic,
            failedScope: .privateSettings,
            completedScopes: [.standardRimeData],
            pendingScopes: []
        )
        let expirationPayload = try XCTUnwrap(
            automaticExpirationBetweenPhases.payload(
                enabledScopes: [.standardRimeData, .privateSettings]
            )
        )
        XCTAssertEqual(expirationPayload.title, "自动同步失败")
        XCTAssertTrue(expirationPayload.body.contains("RIME 常用词和标准资料已更新"))
        XCTAssertTrue(expirationPayload.body.contains("Universe App 设置未完成"))
        XCTAssertFalse(expirationPayload.body.contains("RIME 常用词和标准资料未完成"))

        let inconsistentFailure = RimeSyncNotificationEvent.failed(
            mode: .automatic,
            failedScope: .standardRimeData,
            completedScopes: [.standardRimeData],
            pendingScopes: [.privateSettings]
        )
        let normalizedPayload = try XCTUnwrap(
            inconsistentFailure.payload(enabledScopes: [.standardRimeData, .privateSettings])
        )
        XCTAssertFalse(normalizedPayload.body.contains("已更新；RIME 常用词和标准资料未完成"))
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

private actor NonCooperativePhaseGate {
    private var isStarted = false
    private var startWaiters: [CheckedContinuation<Void, Never>] = []
    private var operationContinuation: CheckedContinuation<Void, Never>?

    func run() async {
        isStarted = true
        startWaiters.forEach { $0.resume() }
        startWaiters.removeAll()
        await withCheckedContinuation { continuation in
            operationContinuation = continuation
        }
    }

    func waitUntilStarted() async {
        guard !isStarted else { return }
        await withCheckedContinuation { continuation in
            startWaiters.append(continuation)
        }
    }

    func release() {
        operationContinuation?.resume()
        operationContinuation = nil
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

    func testTamperedCiphertextFailsClosedAndContainsNoManagedValue() throws {
        let codec = RimeSyncPackageCodec()
        let key = RimeSyncPackageCodec.generateKey()
        let privateValue = "rime-sync-security-canary-9f31"
        let profile = RimeSyncProfile(fields: [
            "private.setting": RimeSyncField(
                value: .string(privateValue),
                version: .init(counter: 1, deviceID: "test-device")
            )
        ])

        let encrypted = try codec.encrypt(profile: profile, keyData: key)
        XCTAssertNil(encrypted.range(of: Data(privateValue.utf8)))

        var envelope = try JSONDecoder().decode(RimeSyncEncryptedSettings.self, from: encrypted)
        var ciphertext = try XCTUnwrap(Data(base64Encoded: envelope.combined))
        ciphertext[ciphertext.startIndex] ^= 0x01
        envelope = RimeSyncEncryptedSettings(
            version: envelope.version,
            algorithm: envelope.algorithm,
            combined: ciphertext.base64EncodedString()
        )
        let tamperedPackage = try JSONEncoder().encode(envelope)

        XCTAssertThrowsError(try codec.decrypt(data: tamperedPackage, keyData: key)) { error in
            XCTAssertEqual(error as? RimeSyncError, .corruptedPackage)
        }
    }

    func testCoordinatorRejectsTamperedRemoteBeforePublishingMergedSettings() async throws {
        let key = RimeSyncPackageCodec.generateKey()
        let codec = RimeSyncPackageCodec()
        var tamperedData = try codec.encrypt(profile: RimeSyncProfile(), keyData: key)
        tamperedData[tamperedData.startIndex] ^= 0x01
        let transport = TamperedRemotePackageSyncTransport(data: tamperedData)
        let localProfile = RimeSyncProfile(fields: [
            "private.setting": RimeSyncField(
                value: .string("keep-local-value"),
                version: .init(counter: 3, deviceID: "local-device")
            )
        ])

        do {
            _ = try await RimeSyncCoordinator().synchronize(
                localProfile: localProfile,
                keyData: key,
                transport: transport
            )
            XCTFail("A modified authenticated remote package must be rejected")
        } catch {
            XCTAssertEqual(error as? RimeSyncError, .corruptedPackage)
        }

        let publishCount = await transport.publishCount()
        XCTAssertEqual(publishCount, 0)
    }
}

final class RimeSyncTransportTests: XCTestCase {
    func testFolderPreflightDiagnosticIncludesTheFailingStage() {
        let privateUnderlyingError = NSError(domain: "private.path", code: 260)
        let error = RimeSyncFolderAccessError.preflight(
            stage: "coordinate",
            underlying: privateUnderlyingError
        )

        XCTAssertEqual(
            RimeSyncFolderAccess.diagnosticErrorCode(for: error),
            "folder.preflight.coordinate"
        )
    }

    func testDiagnosticErrorCodesAreStableAndExcludeUnderlyingDetails() {
        let bookmarkError = RimeSyncFolderAccessError.bookmark(
            underlying: NSError(domain: "/private/user/folder", code: 17)
        )

        XCTAssertEqual(RimeSyncFolderAccess.diagnosticErrorCode(for: bookmarkError), "folder.bookmark")
        XCTAssertEqual(
            RimeSyncFolderAccess.diagnosticErrorCode(for: RimeSyncError.transport("private URL")),
            "transport.failure"
        )
        XCTAssertEqual(
            RimeSyncFolderAccess.diagnosticErrorCode(
                for: RimeStandardSyncError.unavailableSyncDirectory
            ),
            "standard_sync.sync_directory_unavailable"
        )
        XCTAssertEqual(
            RimeSyncFolderAccess.diagnosticErrorCode(
                for: NSError(domain: "private.example", code: 42)
            ),
            "unknown"
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

        let settingsURL =
            root
            .appendingPathComponent("universe-rime-sync/profiles/default/settings.json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: settingsURL.path))
    }

    func testLocalFolderPublishFailsClosedWhenExistingSettingsCannotBeRead() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-unreadable-settings-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageRoot = root.appendingPathComponent("universe-rime-sync", isDirectory: true)
        let settingsURL =
            packageRoot
            .appendingPathComponent("profiles", isDirectory: true)
            .appendingPathComponent("default", isDirectory: true)
            .appendingPathComponent("settings.json", isDirectory: true)
        try FileManager.default.createDirectory(at: settingsURL, withIntermediateDirectories: true)

        let transport = LocalFolderRimeSyncTransport(selectedFolderURL: root)
        do {
            try await transport.publish(
                formatData: Data("new-format".utf8),
                settingsData: Data("new-settings".utf8),
                matching: nil
            )
            XCTFail("Expected an existing unreadable settings object to fail closed")
        } catch {
            XCTAssertNotEqual(error as? RimeSyncError, .remoteConflict)
        }

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: packageRoot.appendingPathComponent("format.json").path),
            "A failed read must not write any part of the package"
        )
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: settingsURL.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }

    func testLocalFolderDeletionRemovesPrivatePackageOnly() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-delete-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let standardDataURL = root.appendingPathComponent("installation.yaml")
        let userDictionarySnapshotURL = root.appendingPathComponent("userdb.txt")
        let privatePackageURL = root.appendingPathComponent("universe-rime-sync", isDirectory: true)
        try Data("standard-config".utf8).write(to: standardDataURL)
        try Data("user-dictionary-snapshot".utf8).write(to: userDictionarySnapshotURL)
        try FileManager.default.createDirectory(at: privatePackageURL, withIntermediateDirectories: true)
        try Data("encrypted-settings".utf8)
            .write(to: privatePackageURL.appendingPathComponent("settings.json"))

        try await LocalFolderRimeSyncTransport(selectedFolderURL: root).deleteRemoteData()

        XCTAssertFalse(FileManager.default.fileExists(atPath: privatePackageURL.path))
        XCTAssertEqual(try Data(contentsOf: standardDataURL), Data("standard-config".utf8))
        XCTAssertEqual(
            try Data(contentsOf: userDictionarySnapshotURL),
            Data("user-dictionary-snapshot".utf8)
        )
    }

    func testLocalFolderDeletionSucceedsWhenPrivatePackageIsConfirmedMissing() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-delete-missing-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageRoot = root.appendingPathComponent("universe-rime-sync", isDirectory: true)
        try await LocalFolderRimeSyncTransport(selectedFolderURL: root).deleteRemoteData()

        XCTAssertFalse(FileManager.default.fileExists(atPath: packageRoot.path))
    }

    func testLocalFolderDeletionDoesNotRemoveNonDirectoryAtPackageRoot() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-sync-delete-nondirectory-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let packageRoot = root.appendingPathComponent("universe-rime-sync", isDirectory: false)
        let existingData = Data("user-owned-file".utf8)
        try existingData.write(to: packageRoot)

        do {
            try await LocalFolderRimeSyncTransport(selectedFolderURL: root).deleteRemoteData()
            XCTFail("A non-directory at the reserved package root must not be deleted")
        } catch {
            XCTAssertEqual(error as? RimeSyncError, .accessDenied)
        }

        XCTAssertEqual(try Data(contentsOf: packageRoot), existingData)
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

    func testWebDAVDeletionIsScopedToThePrivatePackageRoot() async throws {
        let baseURL = try XCTUnwrap(URL(string: "https://sync.example.test/dav/universe-rime-sync"))
        let client = RecordingRimeSyncHTTPClient(baseURL: baseURL)
        let transport = WebDAVRimeSyncTransport(
            baseURL: baseURL,
            username: "user",
            password: "secret",
            client: client
        )

        try await transport.deleteRemoteData()

        let deleteRequests = await client.requests.filter { $0.httpMethod == "DELETE" }
        let deleteRequest = try XCTUnwrap(deleteRequests.onlyElement)
        XCTAssertEqual(deleteRequest.url?.path, "/dav/universe-rime-sync")
        XCTAssertEqual(deleteRequest.url?.scheme, "https")
        XCTAssertNotNil(deleteRequest.value(forHTTPHeaderField: "Authorization"))
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

private actor MemoryRimeSyncSecretStore: RimeSyncSecretStoring {
    private var values: [String: Data] = [:]

    func data(for account: String) async throws -> Data? {
        values[account]
    }

    func set(_ data: Data, for account: String) async throws {
        values[account] = data
    }

    func remove(_ account: String) async throws {
        values.removeValue(forKey: account)
    }
}

private actor FailingRemovalRimeSyncSecretStore: RimeSyncSecretStoring {
    private var values: [String: Data]
    private var failingAccount: String?

    init(values: [String: Data], failingAccount: String?) {
        self.values = values
        self.failingAccount = failingAccount
    }

    func data(for account: String) async throws -> Data? {
        values[account]
    }

    func set(_ data: Data, for account: String) async throws {
        values[account] = data
    }

    func remove(_ account: String) async throws {
        guard account != failingAccount else {
            throw RimeSyncError.keychainAccessDenied
        }
        values.removeValue(forKey: account)
    }

    func allowAllRemovals() {
        failingAccount = nil
    }
}

private actor DeletionRecordingSyncTransport: RimeSyncTransport {
    private var deletions = 0

    func fetchSettings() async throws -> RimeSyncRemoteObject {
        RimeSyncRemoteObject(data: nil, eTag: nil)
    }

    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {}

    func deleteRemoteData() async throws {
        deletions += 1
    }

    func deletionCount() -> Int { deletions }
}

private actor TamperedRemotePackageSyncTransport: RimeSyncTransport {
    private let data: Data
    private var publishes = 0

    init(data: Data) {
        self.data = data
    }

    func fetchSettings() async throws -> RimeSyncRemoteObject {
        RimeSyncRemoteObject(data: data, eTag: "remote-etag")
    }

    func publish(formatData: Data, settingsData: Data, matching eTag: String?) async throws {
        publishes += 1
    }

    func deleteRemoteData() async throws {}

    func publishCount() -> Int { publishes }
}

private extension Collection {
    var onlyElement: Element? {
        guard count == 1 else { return nil }
        return first
    }
}
