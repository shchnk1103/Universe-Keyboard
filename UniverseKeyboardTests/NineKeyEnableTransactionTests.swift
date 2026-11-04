import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class NineKeyEnableTransactionTests: XCTestCase {
    func testBeginTransactionForcesTwentySixKeyAndInvalidatesReadiness() {
        let suite = "uk.ninekey.tx.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let settings = AppGroupSharedSettingsStoreForTests(defaults: defaults)
        // Seed matched readiness + nine key as if previously enabled.
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "old-fp",
            upstreamVersion: "test",
            settings: settings
        )
        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .nineKey
        )
        let before = T9DeploymentSupport.loadMarker(settings: settings)
        XCTAssertEqual(before?.ready, true)

        // Production transaction entry used by the enable orchestrator.
        let manager = SchemaManager(settings: settings)
        manager.beginNineKeyEnableTransaction()

        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .twentySixKey
        )
        let after = T9DeploymentSupport.loadMarker(settings: settings)
        XCTAssertEqual(after?.ready, false)
        XCTAssertFalse(
            RimeT9Readiness.isMatched(marker: after, onDiskFingerprint: "old-fp")
        )
    }

    func testOrchestratorSuccessWritesReadinessBeforeNineKey() async {
        let settings = RecordingSettingsStore()
        let shared = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-9key-ok-\(UUID().uuidString)", isDirectory: true)
        let user = shared.appendingPathComponent("user", isDirectory: true)
        try? FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: shared) }

        var order: [String] = []
        let failure = await NineKeyEnableOrchestrator.enable(
            using: NineKeyEnableOrchestrator.Dependencies(
                iceInstalled: { true },
                resolveDirectories: {
                    NineKeyEnableOrchestrator.Directories(sharedDataURL: shared, userDataURL: user)
                },
                beginTransaction: {
                    order.append("begin")
                    T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
                    T9DeploymentSupport.invalidateReadiness(settings: settings)
                },
                prepare: { _ in order.append("prepare") },
                deploy: {
                    order.append("deploy")
                    return true
                },
                smoke: { _, _ in
                    order.append("smoke")
                    return true
                },
                fingerprint: { _ in
                    order.append("fingerprint")
                    return "new-fp"
                },
                writeMatchedReadiness: { fingerprint in
                    order.append("readiness")
                    // nineKey must not be published yet.
                    XCTAssertEqual(
                        KeyboardLayoutStyle.resolve(
                            settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)
                        ),
                        .twentySixKey
                    )
                    T9DeploymentSupport.writeMatchedReadiness(
                        fingerprint: fingerprint,
                        upstreamVersion: "v",
                        settings: settings
                    )
                },
                publishNineKey: {
                    order.append("nineKey")
                    T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
                }
            )
        )

        XCTAssertNil(failure)
        XCTAssertEqual(order, ["begin", "prepare", "deploy", "smoke", "fingerprint", "readiness", "nineKey"])
        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)),
            .nineKey
        )
        XCTAssertTrue(
            RimeT9Readiness.isMatched(
                marker: T9DeploymentSupport.loadMarker(settings: settings),
                onDiskFingerprint: "new-fp"
            )
        )
    }

    func testOrchestratorIceAndDirectoryPreconditionsSkipTransaction() async {
        var began = false
        let iceFailure = await NineKeyEnableOrchestrator.enable(
            using: makeDeps(iceInstalled: false, begin: { began = true })
        )
        XCTAssertEqual(iceFailure, .iceNotInstalled)
        XCTAssertFalse(began)

        began = false
        let dirFailure = await NineKeyEnableOrchestrator.enable(
            using: makeDeps(directories: nil, begin: { began = true })
        )
        XCTAssertEqual(dirFailure, .directoriesUnavailable)
        XCTAssertFalse(began)
    }

    func testOrchestratorPrepareFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(
            expected: .prepareFailed,
            mutate: { deps in
                deps.prepare = { _ in throw TestPrepareError() }
            })
    }

    func testOrchestratorDeployFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(
            expected: .deployFailed,
            mutate: { deps in
                deps.deploy = { false }
            })
    }

    func testOrchestratorSmokeFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(
            expected: .smokeFailed,
            mutate: { deps in
                deps.smoke = { _, _ in false }
            })
    }

    func testOrchestratorFingerprintFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(
            expected: .fingerprintUnavailable,
            mutate: { deps in
                deps.fingerprint = { _ in nil }
            })
    }

    func testProductionEntryWaitsForCommitLeaseBeforePrepareAndDeploysOnce() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-9key-lease-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let t9URL = shared.appendingPathComponent("t9.schema.yaml")
        try Self.validT9Upstream.write(to: t9URL, atomically: true, encoding: .utf8)

        let settings = RecordingSettingsStore()
        let deploymentService = NineKeyRecordingDeploymentService(succeeded: false)
        let installer = NineKeySchemaArchiveInstaller(
            directories: SchemaDeploymentDirectories(
                sharedDataURL: shared,
                userDataURL: user
            )
        )
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: installer,
            deploymentService: deploymentService
        )
        let blockingOperationID = UUID()
        let acquired = await manager.acquireSchemeDeliveryCommitLease(
            operationID: blockingOperationID
        )
        XCTAssertTrue(acquired)

        let enableTask = Task { @MainActor in await manager.enableNineKeyLayout() }
        await Task.yield()

        XCTAssertEqual(manager.schemeDeliveryCommitLeaseAvailabilityWaiterCount, 1)
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseOperationID, blockingOperationID)
        XCTAssertTrue(try String(contentsOf: t9URL, encoding: .utf8).contains("force_gc"))
        let requestCountBeforeRelease = await deploymentService.requestCount()
        XCTAssertEqual(requestCountBeforeRelease, 0)

        manager.releaseSchemeDeliveryCommitLease(operationID: blockingOperationID)
        let message = await enableTask.value

        XCTAssertEqual(message, "RIME 部署失败，已回退 26 键")
        XCTAssertFalse(try String(contentsOf: t9URL, encoding: .utf8).contains("force_gc"))
        let requestCountAfterRelease = await deploymentService.requestCount()
        XCTAssertEqual(requestCountAfterRelease, 1)
    }

    func testCancellingDownloadWaitingForNineKeyLeaseCannotCommitAfterRelease() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-9key-cancel-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try Self.validT9Upstream.write(
            to: shared.appendingPathComponent("t9.schema.yaml"),
            atomically: true,
            encoding: .utf8
        )

        let deploymentService = BlockingNineKeyDeploymentService()
        let manager = SchemaManager(
            settings: RecordingSettingsStore(),
            archiveInstaller: NineKeySchemaArchiveInstaller(
                directories: SchemaDeploymentDirectories(
                    sharedDataURL: shared,
                    userDataURL: user
                )
            ),
            deploymentService: deploymentService
        )
        let enableTask = Task { @MainActor in await manager.enableNineKeyLayout() }
        await deploymentService.waitUntilRequested()
        XCTAssertNotNil(manager.schemeDeliveryCommitLeaseOperationID)

        let downloadOperationID = UUID()
        let commitProbe = CommitProbe()
        manager.activeDownloadOperationID = downloadOperationID
        let downloadTask = Task { @MainActor in
            let acquired = await manager.acquireSchemeDeliveryCommitLease(
                operationID: downloadOperationID
            )
            guard acquired else { return }
            if !Task.isCancelled, manager.activeDownloadOperationID == downloadOperationID {
                commitProbe.didCommit = true
            }
            manager.releaseSchemeDeliveryCommitLease(operationID: downloadOperationID)
        }
        manager.currentDownloadTask = downloadTask
        await Task.yield()
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseAvailabilityWaiterCount, 1)

        manager.cancelDownload()
        await Task.yield()
        XCTAssertEqual(manager.downloadState, .idle)
        XCTAssertEqual(manager.schemeDeliveryCommitLeaseAvailabilityWaiterCount, 0)

        await deploymentService.finish(succeeded: false)
        _ = await enableTask.value
        await downloadTask.value

        XCTAssertFalse(commitProbe.didCommit)
        XCTAssertNil(manager.activeDownloadOperationID)
        XCTAssertNil(manager.schemeDeliveryCommitLeaseOperationID)
    }

    func testPreTransactionFailuresKeepPreviousNineKeyState() async {
        let settings = RecordingSettingsStore()
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "keep", upstreamVersion: "v", settings: settings)
        let wan = wanxiangScheme()
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wan.schemaID, fingerprint: "wan", upstreamVersion: "v", settings: settings)

        let missingFamily = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: settings, scheme: wan, familyInstalled: false))
        XCTAssertEqual(missingFamily, .familyNotInstalled)
        XCTAssertEqual(layout(settings), .nineKey)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, true)
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wan.schemaID, settings: settings)?.ready, true)

        let missingDir = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: settings, scheme: wan, directories: nil))
        XCTAssertEqual(missingDir, .directoriesUnavailable)
        XCTAssertEqual(layout(settings), .nineKey)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, true)
    }

    func testPrepareFailureInvalidatesOnlyTheTargetMarker() async {
        let settings = RecordingSettingsStore()
        let wan = wanxiangScheme()
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "ice", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wan.schemaID, fingerprint: "wan", upstreamVersion: "v", settings: settings)
        let failure = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: settings, scheme: wan, prepareThrows: true))
        XCTAssertEqual(failure, .prepareFailed)
        XCTAssertEqual(layout(settings), .twentySixKey)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, true)
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wan.schemaID, settings: settings)?.ready, false)
    }

    func testSharedDeployFailureClearsBothMarkersAndForcesTwentySix() async {
        let settings = RecordingSettingsStore()
        let wan = wanxiangScheme()
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "ice", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wan.schemaID, fingerprint: "wan", upstreamVersion: "v", settings: settings)
        let failure = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: settings, scheme: wan, deploy: false))
        XCTAssertEqual(failure, .deployFailed)
        XCTAssertEqual(layout(settings), .twentySixKey)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.ready, false)
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wan.schemaID, settings: settings)?.ready, false)
        XCTAssertNil(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9))
    }

    func testOneFamilySmokeFailurePublishesOnlyTheOtherInBothOrders() async {
        let wan = wanxiangScheme()
        let ice = NineKeySchemeRegistry.scheme("t9")!
        for order in [[ice, wan], [wan, ice]] {
            let settings = RecordingSettingsStore()
            var smoked: [String] = []
            let failure = await NineKeyEnableOrchestrator.enable(
                using: activeDeps(
                    settings: settings,
                    scheme: wan,
                    schemes: order,
                    smoke: { scheme, _, _ in
                        smoked.append(scheme.schemaID)
                        return scheme.schemaID == "t9"
                    }
                ))
            XCTAssertEqual(failure, .smokeFailed(wan.schemaID))
            XCTAssertEqual(smoked, order.map(\.schemaID))
            XCTAssertEqual(layout(settings), .twentySixKey)
            XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.resourceFingerprint, "fp")
            XCTAssertNotEqual(
                T9DeploymentSupport.loadMarker(schemaID: wan.schemaID, settings: settings)?.ready, true)
        }
    }

    func testRestoreFailureAfterSmokeForcesTwentySix() async {
        let settings = RecordingSettingsStore()
        let wan = wanxiangScheme()
        let failure = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: settings, scheme: wan, restore: false))
        XCTAssertEqual(failure, .restoreFailed)
        XCTAssertEqual(layout(settings), .twentySixKey)
        XCTAssertNil(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9))
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wan.schemaID, settings: settings)?.ready, true)
    }

    func testFingerprintMissAndSmokeFalseAndDirectoryMissAreDistinct() async {
        let wan = wanxiangScheme()
        let missingFingerprint = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: RecordingSettingsStore(), scheme: wan, fingerprint: nil))
        XCTAssertEqual(missingFingerprint, .fingerprintUnavailable(wan.schemaID))
        let smokeMiss = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(
                settings: RecordingSettingsStore(), scheme: wan,
                smoke: { _, _, _ in false }))
        XCTAssertEqual(smokeMiss, .smokeFailed(wan.schemaID))
        let directories = await NineKeyEnableOrchestrator.enable(
            using: activeDeps(settings: RecordingSettingsStore(), scheme: wan, directories: nil))
        XCTAssertEqual(directories, .directoriesUnavailable)
    }

    func testReadyTargetBindingDoesNotDeploy() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("uk-9key-bind-\(UUID().uuidString)", isDirectory: true)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let wan = wanxiangScheme()
        let source = shared.appendingPathComponent(wan.schemaFileName)
        try "schema_id: test\n".write(to: source, atomically: true, encoding: .utf8)
        let fingerprint = try XCTUnwrap(
            T9DeploymentSupport.resourceFingerprint(schemaID: wan.schemaID, sharedDataURL: shared))
        let settings = RecordingSettingsStore()
        settings.set(true, forKey: "wanxiang_installed")
        T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wan.schemaID, fingerprint: fingerprint, upstreamVersion: "v", settings: settings)
        let deployment = NineKeyRecordingDeploymentService(succeeded: true)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: NineKeySchemaArchiveInstaller(
                directories: SchemaDeploymentDirectories(sharedDataURL: shared, userDataURL: user)),
            deploymentService: deployment
        )
        let failure = await manager.setSchemeBinding9(wan.schemaID)
        XCTAssertNil(failure)
        XCTAssertEqual(settings.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9), wan.schemaID)
        XCTAssertEqual(layout(settings), .twentySixKey)
        XCTAssertEqual(await deployment.requestCount(), 0)
    }

    func testSecondEnableWhileLeaseHeldDoesNotWriteMarkerOrLayout() async throws {
        let wan = wanxiangScheme()
        let settings = RecordingSettingsStore()
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "held", upstreamVersion: "v", settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            schemaID: wan.schemaID, fingerprint: "held-wan", upstreamVersion: "v", settings: settings)
        let manager = SchemaManager(
            settings: settings,
            archiveInstaller: NineKeySchemaArchiveInstaller(
                directories: SchemaDeploymentDirectories(
                    sharedDataURL: URL(fileURLWithPath: "/tmp/uk-shared"),
                    userDataURL: URL(fileURLWithPath: "/tmp/uk-user")
                )),
            deploymentService: NineKeyRecordingDeploymentService(succeeded: true)
        )
        let holder = UUID()
        XCTAssertTrue(await manager.acquireSchemeDeliveryCommitLease(operationID: holder))
        let message = await manager.enableNineKeyLayout(schemeID: wan.schemaID)
        XCTAssertEqual(message, "RIME 部署失败，已回退 26 键")
        XCTAssertEqual(layout(settings), .nineKey)
        XCTAssertEqual(T9DeploymentSupport.loadMarker(settings: settings)?.resourceFingerprint, "held")
        XCTAssertEqual(
            T9DeploymentSupport.loadMarker(schemaID: wan.schemaID, settings: settings)?.resourceFingerprint,
            "held-wan")
        manager.releaseSchemeDeliveryCommitLease(operationID: holder)
    }

    // MARK: - Helpers

    private func wanxiangScheme() -> NineKeyScheme {
        NineKeySchemeRegistry.entries.first { $0.familyID == "wanxiang" }!
    }

    private func layout(_ settings: RecordingSettingsStore) -> KeyboardLayoutStyle {
        KeyboardLayoutStyle.resolve(settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle))
    }

    private func activeDeps(
        settings: RecordingSettingsStore,
        scheme: NineKeyScheme,
        familyInstalled: Bool = true,
        directories: NineKeyEnableOrchestrator.Directories? = NineKeyEnableOrchestrator.Directories(
            sharedDataURL: URL(fileURLWithPath: "/tmp/uk-shared"),
            userDataURL: URL(fileURLWithPath: "/tmp/uk-user")
        ),
        prepareThrows: Bool = false,
        deploy: Bool = true,
        schemes: [NineKeyScheme]? = nil,
        smoke: @escaping (NineKeyScheme, String, String) -> Bool = { _, _, _ in true },
        fingerprint: String? = "fp",
        restore: Bool = true
    ) -> NineKeyEnableOrchestrator.ActiveDependencies {
        let listed = schemes ?? [NineKeySchemeRegistry.scheme("t9")!, scheme]
        return NineKeyEnableOrchestrator.ActiveDependencies(
            target: scheme,
            familyInstalled: { familyInstalled },
            resolveDirectories: { directories },
            beginTargetTransaction: {
                T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
                T9DeploymentSupport.invalidateReadiness(schemaID: scheme.schemaID, settings: settings)
            },
            prepare: { _ in if prepareThrows { throw TestPrepareError() } },
            invalidateAllMarkers: {
                T9DeploymentSupport.invalidateAllReadiness(settings: settings)
            },
            deploy: { deploy },
            schemesToVerify: { listed },
            rewriteCheck: { _, _ in true },
            smoke: smoke,
            fingerprint: { _, _ in fingerprint },
            restoreRoute: { restore },
            forceTwentySix: {
                T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
            },
            writeMarker: { candidate, value in
                T9DeploymentSupport.writeMatchedReadiness(
                    schemaID: candidate.schemaID, fingerprint: value, upstreamVersion: "v",
                    settings: settings)
            },
            publishBinding: { id in
                settings.set(id, forKey: KeyboardLayoutSettingsKey.schemeBinding9)
            },
            publishLayout: {
                T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
            }
        )
    }

    private static let validT9Upstream = """
        schema:
          schema_id: t9
        engine:
          processors:
            - ascii_composer
          translators:
            - script_translator
            - lua_translator@*force_gc
        speller:
          algebra:
            - derive/[abc]/2/
            - derive/[def]/3/
            - derive/[hgi]/4/
            - derive/[jkl]/5/
            - derive/[omn]/6/
            - derive/[pqrs]/7/
            - derive/[tuv]/8/
            - derive/[wxyz]/9/
        """

    private func assertFailClosed(
        expected: NineKeyEnableOrchestrator.Failure,
        mutate: (inout NineKeyEnableOrchestrator.Dependencies) -> Void
    ) async {
        let settings = RecordingSettingsStore()
        T9DeploymentSupport.persistLayout(.nineKey, settings: settings)
        T9DeploymentSupport.writeMatchedReadiness(
            fingerprint: "stale-fp",
            upstreamVersion: "old",
            settings: settings
        )

        var published = false
        var wroteReadiness = false
        var deps = makeDeps(
            begin: {
                T9DeploymentSupport.persistLayout(.twentySixKey, settings: settings)
                T9DeploymentSupport.invalidateReadiness(settings: settings)
            },
            writeReadiness: { _ in wroteReadiness = true },
            publish: { published = true }
        )
        mutate(&deps)

        let failure = await NineKeyEnableOrchestrator.enable(using: deps)
        XCTAssertEqual(failure, expected)
        XCTAssertFalse(published, "must not publish nineKey on \(expected)")
        XCTAssertFalse(wroteReadiness, "must not write matched readiness on \(expected)")
        XCTAssertEqual(
            KeyboardLayoutStyle.resolve(
                settings.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)
            ),
            .twentySixKey
        )
        XCTAssertFalse(
            RimeT9Readiness.isMatched(
                marker: T9DeploymentSupport.loadMarker(settings: settings),
                onDiskFingerprint: "stale-fp"
            )
        )
    }

    private func makeDeps(
        iceInstalled: Bool = true,
        directories: NineKeyEnableOrchestrator.Directories? = NineKeyEnableOrchestrator.Directories(
            sharedDataURL: URL(fileURLWithPath: "/tmp/uk-shared"),
            userDataURL: URL(fileURLWithPath: "/tmp/uk-user")
        ),
        begin: @escaping () -> Void = {},
        writeReadiness: @escaping (String) -> Void = { _ in },
        publish: @escaping () -> Void = {}
    ) -> NineKeyEnableOrchestrator.Dependencies {
        NineKeyEnableOrchestrator.Dependencies(
            iceInstalled: { iceInstalled },
            resolveDirectories: { directories },
            beginTransaction: begin,
            prepare: { _ in },
            deploy: { true },
            smoke: { _, _ in true },
            fingerprint: { _ in "fp" },
            writeMatchedReadiness: writeReadiness,
            publishNineKey: publish
        )
    }
}

private struct TestPrepareError: Error {}

/// Minimal SharedSettingsStoring for transaction ordering tests.
@MainActor
final class AppGroupSharedSettingsStoreForTests: SharedSettingsStoring {
    private let defaults: UserDefaults
    init(defaults: UserDefaults) { self.defaults = defaults }
    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func object(forKey key: String) -> Any? { defaults.object(forKey: key) }
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func removeObject(forKey key: String) { defaults.removeObject(forKey: key) }
    func synchronize() { defaults.synchronize() }
}

@MainActor
final class RecordingSettingsStore: SharedSettingsStoring {
    private var storage: [String: Any] = [:]
    func string(forKey key: String) -> String? { storage[key] as? String }
    func bool(forKey key: String) -> Bool { storage[key] as? Bool ?? false }
    func object(forKey key: String) -> Any? { storage[key] }
    func set(_ value: Any?, forKey key: String) {
        if let value { storage[key] = value } else { storage.removeValue(forKey: key) }
    }
    func removeObject(forKey key: String) { storage.removeValue(forKey: key) }
    func synchronize() {}
}

@MainActor
private final class CommitProbe {
    var didCommit = false
}

@MainActor
private final class NineKeySchemaArchiveInstaller: SchemaArchiveInstalling {
    let directories: SchemaDeploymentDirectories

    init(directories: SchemaDeploymentDirectories) {
        self.directories = directories
    }

    func cachedArchiveURL(for distribution: RimeSchemeDistribution) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(distribution.cachedArchiveFileName)
    }
    func prepareExtractionDirectory(for distribution: RimeSchemeDistribution) throws -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(distribution.extractionDirectoryName)
    }
    func removeTemporaryItem(at url: URL) {}
    func containsInstalledSchema(plan: RimeSchemeInstallationPlan) -> Bool { true }
    func checkDiskSpace(needed: Int64) throws {}
    func installSchemaFiles(
        from extractDir: URL,
        plan: RimeSchemeInstallationPlan,
        luaAvailable: Bool
    ) throws {}

    func createUpgradeCheckpoint(plan: RimeSchemeInstallationPlan, luaAvailable: Bool) throws
        -> SchemaUpgradeCheckpoint?
    {
        nil
    }
    func restoreUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) throws {}
    func commitUpgradeCheckpoint(_ checkpoint: SchemaUpgradeCheckpoint) {}
    func stageSchemaUninstall(plan: RimeSchemeInstallationPlan) throws -> SchemaUninstallStaging {
        SchemaUninstallStaging(rootURL: URL(fileURLWithPath: "/tmp/staging"), movedRelativePaths: [])
    }
    func commitSchemaUninstall(_ staging: SchemaUninstallStaging, plan: RimeSchemeInstallationPlan) {}
    func rollbackSchemaUninstall(_ staging: SchemaUninstallStaging) {}
    func clearBuildCache(plan: RimeSchemeInstallationPlan) {}
    func sharedDataDirectoryURL() -> URL? { directories.sharedDataURL }
    func runtimeDirectories() throws -> SchemaDeploymentDirectories { directories }
    func deploymentDirectories(pendingSchemaID: String?) throws -> SchemaDeploymentDirectories { directories }
}

private actor NineKeyRecordingDeploymentService: RimeDeploymentServicing {
    private let succeeded: Bool
    private var requests: [RimeDeploymentRequest] = []

    init(succeeded: Bool) {
        self.succeeded = succeeded
    }

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        requests.append(request)
        return RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")
    }

    func requestCount() -> Int { requests.count }
}

private actor BlockingNineKeyDeploymentService: RimeDeploymentServicing {
    private var requestStarted = false
    private var requestWaiters: [CheckedContinuation<Void, Never>] = []
    private var resultContinuation: CheckedContinuation<Bool, Never>?

    func deploy(_ request: RimeDeploymentRequest) async throws -> RimeDeploymentResult {
        requestStarted = true
        let waiters = requestWaiters
        requestWaiters.removeAll()
        waiters.forEach { $0.resume() }
        let succeeded = await withCheckedContinuation { continuation in
            resultContinuation = continuation
        }
        return RimeDeploymentResult(succeeded: succeeded, diagnosticMessage: "test")
    }

    func waitUntilRequested() async {
        guard !requestStarted else { return }
        await withCheckedContinuation { continuation in
            requestWaiters.append(continuation)
        }
    }

    func finish(succeeded: Bool) {
        resultContinuation?.resume(returning: succeeded)
        resultContinuation = nil
    }
}
