import XCTest
@testable import Universe_Keyboard
import KeyboardCore

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
        await assertFailClosed(expected: .prepareFailed, mutate: { deps in
            deps.prepare = { _ in throw TestPrepareError() }
        })
    }

    func testOrchestratorDeployFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(expected: .deployFailed, mutate: { deps in
            deps.deploy = { false }
        })
    }

    func testOrchestratorSmokeFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(expected: .smokeFailed, mutate: { deps in
            deps.smoke = { _, _ in false }
        })
    }

    func testOrchestratorFingerprintFailureLeavesTwentySixKeyAndUnmatchedReadiness() async {
        await assertFailClosed(expected: .fingerprintUnavailable, mutate: { deps in
            deps.fingerprint = { _ in nil }
        })
    }

    // MARK: - Helpers

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
