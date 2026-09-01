import Foundation
import KeyboardCore
import RimeBridge
import Synchronization

nonisolated protocol RimeSyncDiagnosing: Sendable {
    func record(_ payload: DiagnosticEvent.RimeSyncPayload, level: Logger.Level)
}

nonisolated extension RimeSyncDiagnosing {
    func record(_ payload: DiagnosticEvent.RimeSyncPayload) {
        record(payload, level: .info)
    }
}

/// Main-App adapter for the reviewed automatic-sync diagnostic protocol.
/// Journal availability and backpressure never participate in sync control flow.
nonisolated final class RimeSyncDiagnostics: RimeSyncDiagnosing, Sendable {
    static let live = RimeSyncDiagnostics()

    private let runtime: DiagnosticsJournalRuntime

    init(runtime: DiagnosticsJournalRuntime? = nil) {
        self.runtime =
            runtime
            ?? DiagnosticsJournalRuntime(
                origin: .mainApp,
                isMainAppWriter: true,
                rootURL: {
                    FileManager.default
                        .containerURL(
                            forSecurityApplicationGroupIdentifier: SchemaManager.appGroupID
                        )?
                        .appendingPathComponent("Diagnostics/v1", isDirectory: true)
                },
                isCategoryEnabled: Logger.isLiveCategoryEnabled
            )
    }

    func record(_ payload: DiagnosticEvent.RimeSyncPayload, level: Logger.Level) {
        runtime.recordRimeSync(payload, level: level)
    }
}

/// Correlates one automatic-sync invocation and arbitrates its diagnostic terminal.
/// Expiration and a late cancellation may race, but only the winner is persisted.
nonisolated final class RimeSyncDiagnosticSession: Sendable {
    private struct PendingTerminal: Sendable {
        let result: DiagnosticEvent.RimeSyncTerminalResult
        let phase: DiagnosticEvent.RimeSyncPhase?
        let failure: DiagnosticEvent.RimeSyncFailure?
    }

    private struct State: Sendable {
        var began = false
        var finished = false
        var activePhase: DiagnosticEvent.RimeSyncPhase?
        var pendingTerminal: PendingTerminal?
    }

    let context: DiagnosticEvent.RimeSyncContext

    private let requestedPhases: [DiagnosticEvent.RimeSyncPhase]
    private let requestedPhaseSet: Set<DiagnosticEvent.RimeSyncPhase>
    private let diagnostics: any RimeSyncDiagnosing
    private let state = Mutex(State())

    init(
        operationID: UUID = UUID(),
        source: DiagnosticEvent.RimeSyncSource,
        requestedPhases: [DiagnosticEvent.RimeSyncPhase],
        diagnostics: any RimeSyncDiagnosing = RimeSyncDiagnostics.live
    ) {
        precondition(
            !requestedPhases.isEmpty && Set(requestedPhases).count == requestedPhases.count,
            "RIME sync diagnostic phases must be non-empty and unique"
        )
        context = .init(operationID: operationID, source: source)
        self.requestedPhases = requestedPhases
        requestedPhaseSet = Set(requestedPhases)
        self.diagnostics = diagnostics
    }

    func begin() {
        state.withLock { state in
            guard !state.began, !state.finished else { return }
            state.began = true
            diagnostics.record(
                .invoked(.init(context: context, requestedPhases: requestedPhases))
            )
        }
    }

    @discardableResult
    func phase(
        _ phase: DiagnosticEvent.RimeSyncPhase,
        result: DiagnosticEvent.RimeSyncPhaseResult
    ) -> Bool {
        state.withLock { state in
            guard
                state.began,
                !state.finished,
                state.pendingTerminal == nil,
                requestedPhaseSet.contains(phase)
            else { return false }
            switch result {
            case .started:
                guard state.activePhase == nil else { return false }
                state.activePhase = phase
            case .completed:
                guard state.activePhase == phase else { return false }
                state.activePhase = nil
            }
            diagnostics.record(
                .phaseChanged(.init(context: context, phase: phase, result: result))
            )
            return true
        }
    }

    @discardableResult
    func skip(_ reason: DiagnosticEvent.RimeSyncSkipReason) -> Bool {
        state.withLock { state in
            guard state.began, !state.finished else { return false }
            state.finished = true
            state.pendingTerminal = nil
            diagnostics.record(.skipped(.init(context: context, reason: reason)))
            return true
        }
    }

    /// The BGTask operation proposes its result, but only the scheduler lifecycle
    /// winner may persist it. This keeps task completion and diagnostics aligned.
    @discardableResult
    func proposeTerminal(
        _ result: DiagnosticEvent.RimeSyncTerminalResult,
        phase explicitPhase: DiagnosticEvent.RimeSyncPhase? = nil,
        failure: DiagnosticEvent.RimeSyncFailure? = nil
    ) -> Bool {
        state.withLock { state in
            guard state.began, !state.finished, state.pendingTerminal == nil else { return false }
            let phase = explicitPhase ?? state.activePhase
            guard Self.isValidTerminal(result: result, phase: phase, failure: failure) else {
                return false
            }
            state.pendingTerminal = .init(result: result, phase: phase, failure: failure)
            return true
        }
    }

    @discardableResult
    func commitProposedTerminal() -> Bool {
        state.withLock { state in
            guard
                state.began,
                !state.finished,
                let pending = state.pendingTerminal
            else { return false }
            state.finished = true
            state.pendingTerminal = nil
            diagnostics.record(
                .terminal(
                    .init(
                        context: context,
                        result: pending.result,
                        phase: pending.phase,
                        failure: pending.failure
                    )
                ),
                level: Self.level(for: pending.result)
            )
            return true
        }
    }

    @discardableResult
    func terminal(
        _ result: DiagnosticEvent.RimeSyncTerminalResult,
        phase explicitPhase: DiagnosticEvent.RimeSyncPhase? = nil,
        failure: DiagnosticEvent.RimeSyncFailure? = nil
    ) -> Bool {
        state.withLock { state in
            guard state.began, !state.finished else { return false }
            let phase = explicitPhase ?? state.activePhase
            guard Self.isValidTerminal(result: result, phase: phase, failure: failure) else {
                return false
            }
            state.finished = true
            state.pendingTerminal = nil
            diagnostics.record(
                .terminal(
                    .init(
                        context: context,
                        result: result,
                        phase: phase,
                        failure: failure
                    )
                ),
                level: Self.level(for: result)
            )
            return true
        }
    }

    private static func isValidTerminal(
        result: DiagnosticEvent.RimeSyncTerminalResult,
        phase: DiagnosticEvent.RimeSyncPhase?,
        failure: DiagnosticEvent.RimeSyncFailure?
    ) -> Bool {
        switch result {
        case .completed: phase == nil && failure == nil
        case .failed: phase != nil && failure != nil
        case .cancelled, .expired: failure == nil
        }
    }

    private static func level(
        for result: DiagnosticEvent.RimeSyncTerminalResult
    ) -> Logger.Level {
        switch result {
        case .completed: .info
        case .failed: .error
        case .cancelled, .expired: .warning
        }
    }
}

nonisolated enum RimeSyncDiagnosticFailureMapper {
    static func failure(for error: Error) -> DiagnosticEvent.RimeSyncFailure {
        if error is RimeSyncFolderAccessError {
            return .accessDenied
        }
        if let error = error as? RimeStandardSyncError {
            switch error {
            case .invalidInstallationID: return .invalidInstallationID
            case .invalidInstallationConfiguration: return .invalidInstallationConfiguration
            case .unavailableUserDirectory: return .unavailableUserDirectory
            case .unavailableSyncDirectory: return .unavailableSyncDirectory
            case .synchronizationFailed: return .standardSynchronizationFailed
            }
        }
        if let error = error as? RimeSyncError {
            switch error {
            case .notConfigured, .accessDenied: return .accessDenied
            case .missingEncryptionKey: return .missingEncryptionKey
            case .unsupportedFormat: return .unsupportedFormat
            case .packageTooLarge: return .packageTooLarge
            case .corruptedPackage, .invalidRecoveryCode: return .corruptedPackage
            case .remoteConflict: return .remoteConflict
            case .transport: return .transport
            case .invalidServerURL, .insecureServerURL, .missingCredentials: return .unknown
            }
        }
        if error is CocoaError {
            return .localIO
        }
        return .unknown
    }
}
