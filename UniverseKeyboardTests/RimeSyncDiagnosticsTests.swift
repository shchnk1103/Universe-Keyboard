import RimeBridge
import Synchronization
import XCTest

@testable import KeyboardCore
@testable import Universe_Keyboard

final class RimeSyncDiagnosticsTests: XCTestCase {
    func testSchedulerExpirationRecordsBeforeLateCancellation() {
        let diagnostics = RecordingRimeSyncDiagnostics()
        let operationID = UUID()
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        let session = RimeSyncDiagnosticSession(
            operationID: operationID,
            source: .backgroundAutomatic,
            requestedPhases: [.standardRimeData],
            diagnostics: diagnostics
        )

        session.begin()
        session.phase(.standardRimeData, result: .started)
        var taskCompletions: [Bool] = []
        XCTAssertTrue(
            RimeAutomaticSyncScheduler.expireOperation(
                lifecycle: lifecycle,
                recordExpiration: { session.terminal(.expired) },
                cancel: { XCTAssertFalse(session.proposeTerminal(.cancelled)) },
                completeTask: { taskCompletions.append($0) }
            )
        )
        session.phase(.standardRimeData, result: .completed)

        let payloads = diagnostics.payloads
        XCTAssertEqual(payloads.count, 3)
        XCTAssertEqual(
            payloads.map(\.code),
            [
                .rimeSyncInvoked,
                .rimeSyncPhaseChanged,
                .rimeSyncTerminal,
            ])
        guard let lastPayload = payloads.last, case .terminal(let terminal) = lastPayload else {
            return XCTFail("missing terminal payload")
        }
        XCTAssertEqual(terminal.context.operationID, operationID)
        XCTAssertEqual(terminal.result, .expired)
        XCTAssertEqual(terminal.phase, .standardRimeData)
        XCTAssertEqual(taskCompletions, [false])
    }

    @MainActor
    func testSchedulerCompletionCommitsProposedTerminalAfterLifecycleClaim() async {
        let diagnostics = RecordingRimeSyncDiagnostics()
        let lifecycle = RimeAutomaticSyncTaskLifecycle()
        let session = RimeSyncDiagnosticSession(
            source: .backgroundAutomatic,
            requestedPhases: [.standardRimeData],
            diagnostics: diagnostics
        )
        session.begin()
        session.phase(.standardRimeData, result: .started)
        session.phase(.standardRimeData, result: .completed)
        XCTAssertTrue(session.proposeTerminal(.completed))

        let didFinish = await RimeAutomaticSyncScheduler.finishOperation(
            result: .completed(Date()),
            lifecycle: lifecycle,
            recordDiagnosticTerminal: { session.commitProposedTerminal() },
            notifyCompletion: {},
            reschedule: {},
            completeTask: { _ in }
        )

        XCTAssertTrue(didFinish)
        XCTAssertEqual(diagnostics.payloads.compactMap(\.terminalResult), [.completed])
        XCTAssertFalse(lifecycle.claimExpiration())
    }

    func testSessionRejectsUnrequestedAndOutOfOrderPhases() {
        let diagnostics = RecordingRimeSyncDiagnostics()
        let session = RimeSyncDiagnosticSession(
            source: .backgroundAutomatic,
            requestedPhases: [.standardRimeData],
            diagnostics: diagnostics
        )

        session.begin()
        XCTAssertFalse(session.phase(.privateSettings, result: .started))
        XCTAssertFalse(session.phase(.standardRimeData, result: .completed))
        XCTAssertTrue(session.phase(.standardRimeData, result: .started))
        XCTAssertFalse(session.phase(.standardRimeData, result: .started))
        XCTAssertFalse(session.phase(.privateSettings, result: .completed))
        XCTAssertTrue(session.phase(.standardRimeData, result: .completed))
        XCTAssertTrue(session.terminal(.completed))

        XCTAssertEqual(
            diagnostics.payloads.map(\.code),
            [
                .rimeSyncInvoked,
                .rimeSyncPhaseChanged,
                .rimeSyncPhaseChanged,
                .rimeSyncTerminal,
            ]
        )
    }

    @MainActor
    func testBackgroundSuccessRecordsOneCoherentPhaseSequence() async throws {
        let suiteName = "RimeSyncDiagnosticsSuccess-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        configureBackgroundSync(defaults)

        let diagnostics = RecordingRimeSyncDiagnostics()
        let syncURL = FileManager.default.temporaryDirectory
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            standardRimeSyncService: ImmediateRimeStandardSyncService(),
            standardRimeSyncRequestFactory: {
                RimeStandardSyncRequest(
                    sharedDataURL: syncURL,
                    userDataURL: syncURL,
                    syncDirectoryURL: syncURL,
                    installationID: "test-device"
                )
            },
            notificationService: SilentRimeSyncNotificationService(),
            processGate: RimeSyncProcessGate(),
            keyboardActivityDefaults: defaults,
            diagnostics: diagnostics
        )

        let result = await model.synchronizeAutomatically()

        guard case .completed = result else {
            return XCTFail("expected completed result, got \(result)")
        }
        let payloads = diagnostics.payloads
        XCTAssertEqual(
            payloads.map(\.code),
            [
                .rimeSyncInvoked,
                .rimeSyncPhaseChanged,
                .rimeSyncPhaseChanged,
                .rimeSyncTerminal,
            ])
        let operationIDs = Set(payloads.map(\.context.operationID))
        XCTAssertEqual(operationIDs.count, 1)
        XCTAssertEqual(payloads.compactMap(\.terminalResult), [.completed])
    }

    @MainActor
    func testProcessBusyRecordsSkipWithoutPhaseStart() async throws {
        let suiteName = "RimeSyncDiagnosticsBusy-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        let processGate = RimeSyncProcessGate()
        let owner = try XCTUnwrap(processGate.claim(source: .foregroundAutomatic))
        defer {
            processGate.release(owner)
            defaults.removePersistentDomain(forName: suiteName)
        }
        configureBackgroundSync(defaults)

        let diagnostics = RecordingRimeSyncDiagnostics()
        let model = RimeSyncViewModel(
            rimeStore: RimeSettingsStore(),
            defaults: defaults,
            notificationService: SilentRimeSyncNotificationService(),
            processGate: processGate,
            keyboardActivityDefaults: defaults,
            diagnostics: diagnostics
        )

        let result = await model.synchronizeAutomatically()
        XCTAssertEqual(result, .skipped(.alreadyRunning))
        XCTAssertEqual(diagnostics.payloads.map(\.code), [.rimeSyncInvoked, .rimeSyncSkipped])
        guard
            let lastPayload = diagnostics.payloads.last,
            case .skipped(let skipped) = lastPayload
        else {
            return XCTFail("missing skipped payload")
        }
        XCTAssertEqual(skipped.reason, .processBusy)
    }

    func testFailureMapperNeverPersistsRawErrorText() {
        XCTAssertEqual(
            RimeSyncDiagnosticFailureMapper.failure(for: RimeStandardSyncError.synchronizationFailed),
            .standardSynchronizationFailed
        )
        XCTAssertEqual(
            RimeSyncDiagnosticFailureMapper.failure(for: RimeSyncError.transport("secret path")),
            .transport
        )
        XCTAssertEqual(
            RimeSyncDiagnosticFailureMapper.failure(
                for: NSError(domain: "private.example", code: 42)
            ),
            .unknown
        )
    }
}

private final class RecordingRimeSyncDiagnostics: RimeSyncDiagnosing, Sendable {
    private let storage = Mutex<[DiagnosticEvent.RimeSyncPayload]>([])

    var payloads: [DiagnosticEvent.RimeSyncPayload] {
        storage.withLock { $0 }
    }

    func record(_ payload: DiagnosticEvent.RimeSyncPayload, level: Logger.Level) {
        _ = level
        storage.withLock { $0.append(payload) }
    }
}

private extension DiagnosticEvent.RimeSyncPayload {
    var context: DiagnosticEvent.RimeSyncContext {
        switch self {
        case .invoked(let event): event.context
        case .phaseChanged(let event): event.context
        case .skipped(let event): event.context
        case .terminal(let event): event.context
        }
    }

    var terminalResult: DiagnosticEvent.RimeSyncTerminalResult? {
        guard case .terminal(let event) = self else { return nil }
        return event.result
    }
}

@MainActor
private final class SilentRimeSyncNotificationService: AppNotificationNotifying {
    func notify(_ event: RimeSyncNotificationEvent) async {
        _ = event
    }
}

private actor ImmediateRimeStandardSyncService: RimeStandardSyncing {
    func synchronize(_ request: RimeStandardSyncRequest) async throws {
        _ = request
    }
}

@MainActor
private func configureBackgroundSync(_ defaults: UserDefaults) {
    defaults.set(RimeSyncProvider.localFolder.rawValue, forKey: RimeSyncStorageKey.provider)
    defaults.set(Data([0x01]), forKey: RimeSyncStorageKey.folderBookmark)
    defaults.set(Date(), forKey: RimeSyncStorageKey.standardRimeLastSuccess)
    defaults.set(true, forKey: RimeSyncStorageKey.automaticSyncEnabled)
    defaults.set(true, forKey: RimeSyncStorageKey.automaticStandardRimeDataEnabled)
    defaults.set(false, forKey: RimeSyncStorageKey.automaticPrivateSettingsEnabled)
    defaults.set(
        Date().addingTimeInterval(-2 * RimeAutomaticSyncCadence.daily.interval),
        forKey: RimeSyncStorageKey.lastAutomaticAttempt
    )
}
