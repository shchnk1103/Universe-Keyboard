#if T9_RESPONSIVE_CANARY_INTERNAL

import Foundation

/// Atomically captured internal configuration for CANARY-001.
///
/// The type is absent from ordinary builds because the entire file is guarded
/// by `T9_RESPONSIVE_CANARY_INTERNAL`. Runtime values are evaluated once by the
/// mode coordinator; controller and lifecycle call sites must not re-evaluate
/// individual flags.
public struct ResponsiveRimeCanaryConfiguration: Sendable, Equatable {
    public let explicitEnable: Bool
    public let killSwitch: Bool
    public let bootstrapAvailable: Bool
    public let configurationValid: Bool
    public let expiresAtUnixSeconds: TimeInterval
    public let runID: String

    public init(
        explicitEnable: Bool,
        killSwitch: Bool,
        bootstrapAvailable: Bool,
        configurationValid: Bool,
        expiresAtUnixSeconds: TimeInterval,
        runID: String
    ) {
        self.explicitEnable = explicitEnable
        self.killSwitch = killSwitch
        self.bootstrapAvailable = bootstrapAvailable
        self.configurationValid = configurationValid
        self.expiresAtUnixSeconds = expiresAtUnixSeconds
        self.runID = runID
    }
}

public enum ResponsiveRimeCanaryBaselineReason: String, Sendable, Equatable {
    case notEnabled
    case killBeforeStartup
    case bootstrapUnavailable
    case invalidConfiguration
    case expired
}

public struct ResponsiveRimeCanaryTransitionKey: Sendable, Equatable {
    public let runID: String
    public let modeGeneration: UInt64
    public let fenceID: UInt64
    public let canarySessionInstance: UInt64

    public init(
        runID: String,
        modeGeneration: UInt64,
        fenceID: UInt64,
        canarySessionInstance: UInt64
    ) {
        self.runID = runID
        self.modeGeneration = modeGeneration
        self.fenceID = fenceID
        self.canarySessionInstance = canarySessionInstance
    }
}

public enum ResponsiveRimeCanaryTransitionTerminal: String, Sendable, Equatable {
    case ownerDestroyed
    case mailboxTerminal
    case deliveryDrained
}

public enum ResponsiveRimeCanaryPublishCompletion: String, Sendable, Equatable {
    case published
    case staleAfterFence
}

public enum ResponsiveRimeCanaryVisibilityDisposition: Sendable, Equatable {
    case visible(presentationRevision: UInt64)
    case notVisibleCoalesced(
        absorbedRevisionRange: ClosedRange<UInt64>,
        replacementRevision: UInt64
    )
    case notVisibleFencedBeforeVisible
}

public enum ResponsiveRimeCanaryVisibleFailureReason: String, Sendable, Equatable {
    case uiSynchronizationFailed
}

public enum ResponsiveRimeCanaryPaintTerminal: Sendable, Equatable {
    case painted
    case coalesced(
        absorbedRevisionRange: ClosedRange<UInt64>,
        replacementRevision: UInt64
    )
    case failedVisible(reason: ResponsiveRimeCanaryVisibleFailureReason)
    case failedFencedBeforeVisible
}

/// One mechanically complete presentation terminal for one PUBLISH revision.
public struct ResponsiveRimeCanaryPresentationTerminal: Sendable, Equatable {
    public let runID: String
    public let modeGeneration: UInt64
    public let canarySessionInstance: UInt64
    public let sessionEpoch: UInt64
    public let revision: UInt64
    public let completion: ResponsiveRimeCanaryPublishCompletion
    public let visibility: ResponsiveRimeCanaryVisibilityDisposition
    public let paint: ResponsiveRimeCanaryPaintTerminal

    public init(
        runID: String,
        modeGeneration: UInt64,
        canarySessionInstance: UInt64,
        sessionEpoch: UInt64,
        revision: UInt64,
        completion: ResponsiveRimeCanaryPublishCompletion,
        visibility: ResponsiveRimeCanaryVisibilityDisposition,
        paint: ResponsiveRimeCanaryPaintTerminal
    ) {
        self.runID = runID
        self.modeGeneration = modeGeneration
        self.canarySessionInstance = canarySessionInstance
        self.sessionEpoch = sessionEpoch
        self.revision = revision
        self.completion = completion
        self.visibility = visibility
        self.paint = paint
    }
}

public struct ResponsiveRimeCanaryTerminalIdentity: Sendable, Equatable, Hashable {
    public let runID: String
    public let modeGeneration: UInt64
    public let canarySessionInstance: UInt64
    public let sessionEpoch: UInt64
    public let revision: UInt64
}

public enum ResponsiveRimeCanaryState: Sendable, Equatable {
    case baselineActive(reason: ResponsiveRimeCanaryBaselineReason)
    case canaryStarting(modeGeneration: UInt64)
    case canaryActive(modeGeneration: UInt64, canarySessionInstance: UInt64)
    case visibilityEnding(modeGeneration: UInt64, canarySessionInstance: UInt64)
    case visibilitySuspended(modeGeneration: UInt64)
    case fenceIssued(
        key: ResponsiveRimeCanaryTransitionKey,
        acceptedThroughRevision: UInt64
    )
    case baselineRecoveryPermitted(key: ResponsiveRimeCanaryTransitionKey)
    case fencedUnavailable(reason: String)
}

public enum ResponsiveRimeCanaryStartupDecision: Sendable, Equatable {
    case useBaseline(ResponsiveRimeCanaryBaselineReason)
    case startCanary(modeGeneration: UInt64)
}

/// MainActor is the unique mode authority for the internal canary artifact.
@MainActor
public final class ResponsiveRimeCanaryModeCoordinator {
    public private(set) var state: ResponsiveRimeCanaryState =
        .baselineActive(reason: .notEnabled)
    public private(set) var modeGeneration: UInt64 = 0
    private var activeSessionModeGeneration: UInt64 = 0

    private var nextFenceID: UInt64 = 1
    private var nextSessionInstance: UInt64 = 1
    private var expectedTransitionIndex = 0
    private var presentationTerminalKeys: Set<String> = []
    private var visibilityAbandonmentKeys: Set<String> = []
    public private(set) var abandonedVisibilityCount = 0
    public private(set) var presentationTerminalIdentities:
        [ResponsiveRimeCanaryTerminalIdentity] = []
    public private(set) var visibilityAbandonmentIdentities:
        [ResponsiveRimeCanaryTerminalIdentity] = []
    public private(set) var lastContractFailure: String?
    private var activeRunID = ""

    public init() {}

    public func evaluateStartup(
        _ configuration: ResponsiveRimeCanaryConfiguration,
        nowUnixSeconds: TimeInterval
    ) -> ResponsiveRimeCanaryStartupDecision {
        let baselineReason: ResponsiveRimeCanaryBaselineReason? = {
            guard configuration.configurationValid,
                  !configuration.runID.isEmpty,
                  configuration.expiresAtUnixSeconds.isFinite,
                  configuration.expiresAtUnixSeconds > 0
            else { return .invalidConfiguration }
            guard configuration.explicitEnable else { return .notEnabled }
            guard !configuration.killSwitch else { return .killBeforeStartup }
            guard configuration.bootstrapAvailable else { return .bootstrapUnavailable }
            guard nowUnixSeconds < configuration.expiresAtUnixSeconds else { return .expired }
            return nil
        }()

        if let baselineReason {
            state = .baselineActive(reason: baselineReason)
            return .useBaseline(baselineReason)
        }

        modeGeneration &+= 1
        presentationTerminalKeys.removeAll(keepingCapacity: true)
        visibilityAbandonmentKeys.removeAll(keepingCapacity: true)
        abandonedVisibilityCount = 0
        presentationTerminalIdentities.removeAll(keepingCapacity: true)
        visibilityAbandonmentIdentities.removeAll(keepingCapacity: true)
        lastContractFailure = nil
        activeRunID = configuration.runID
        activeSessionModeGeneration = 0
        state = .canaryStarting(modeGeneration: modeGeneration)
        return .startCanary(modeGeneration: modeGeneration)
    }

    @discardableResult
    public func markCanaryReady() -> UInt64? {
        guard case .canaryStarting(let generation) = state,
              generation == modeGeneration
        else {
            failClosed("ownerReadyOutOfState")
            return nil
        }
        let sessionInstance = nextSessionInstance
        nextSessionInstance &+= 1
        activeSessionModeGeneration = generation
        state = .canaryActive(
            modeGeneration: generation,
            canarySessionInstance: sessionInstance
        )
        return sessionInstance
    }

    @discardableResult
    public func recordPresentationTerminal(
        _ terminal: ResponsiveRimeCanaryPresentationTerminal
    ) -> Bool {
        let expectedSessionInstance: UInt64
        switch state {
        case .canaryActive(_, let instance), .visibilityEnding(_, let instance):
            expectedSessionInstance = instance
        case .fenceIssued(let key, _):
            expectedSessionInstance = key.canarySessionInstance
        default:
            return rejectContract("presentationTerminalOutOfState")
        }
        guard terminal.runID == activeRunID,
              terminal.modeGeneration == activeSessionModeGeneration,
              terminal.canarySessionInstance == expectedSessionInstance
        else {
            return rejectContract("presentationTerminalIdentityMismatch")
        }

        let pairingIsValid: Bool = {
            switch (terminal.completion, terminal.visibility, terminal.paint) {
            case (.published, .visible(let visibleRevision), .painted):
                return visibleRevision == terminal.revision
            case (.published, .visible(let visibleRevision), .failedVisible(_)):
                return visibleRevision == terminal.revision
            case (
                .published,
                .notVisibleCoalesced(let visibilityRange, let visibilityReplacement),
                .coalesced(let paintRange, let paintReplacement)
            ):
                return visibilityRange == paintRange
                    && visibilityRange.contains(terminal.revision)
                    && visibilityReplacement == paintReplacement
            case (
                .staleAfterFence,
                .notVisibleFencedBeforeVisible,
                .failedFencedBeforeVisible
            ):
                return true
            default:
                return false
            }
        }()
        guard pairingIsValid else {
            return rejectContract("presentationPairingMismatch")
        }

        let identity = ResponsiveRimeCanaryTerminalIdentity(
            runID: terminal.runID,
            modeGeneration: terminal.modeGeneration,
            canarySessionInstance: terminal.canarySessionInstance,
            sessionEpoch: terminal.sessionEpoch,
            revision: terminal.revision
        )
        let key = "\(identity.runID):\(identity.modeGeneration):"
            + "\(identity.canarySessionInstance):\(identity.sessionEpoch):"
            + "\(identity.revision)"
        guard presentationTerminalKeys.insert(key).inserted else {
            return rejectContract("duplicatePresentationTerminal")
        }
        presentationTerminalIdentities.append(identity)
        return true
    }

    public func beginActiveKill(
        runID: String,
        acceptedThroughRevision: UInt64
    ) -> ResponsiveRimeCanaryTransitionKey? {
        guard case .canaryActive(_, let sessionInstance) = state,
              !runID.isEmpty
        else {
            failClosed("killOutOfState")
            return nil
        }

        modeGeneration &+= 1
        let key = ResponsiveRimeCanaryTransitionKey(
            runID: runID,
            modeGeneration: modeGeneration,
            fenceID: nextFenceID,
            canarySessionInstance: sessionInstance
        )
        nextFenceID &+= 1
        expectedTransitionIndex = 0
        state = .fenceIssued(
            key: key,
            acceptedThroughRevision: acceptedThroughRevision
        )
        return key
    }

    @discardableResult
    public func beginVisibilityExit() -> Bool {
        guard case .canaryActive(_, let sessionInstance) = state else { return false }
        modeGeneration &+= 1
        state = .visibilityEnding(
            modeGeneration: modeGeneration,
            canarySessionInstance: sessionInstance
        )
        return true
    }

    public func completeVisibilityExit(teardownPositive: Bool) {
        guard case .visibilityEnding = state else {
            failClosed("visibilityTerminalOutOfState")
            return
        }
        guard teardownPositive else {
            failClosed("visibilityTeardownIncomplete")
            return
        }
        state = .visibilitySuspended(modeGeneration: modeGeneration)
    }

    @discardableResult
    public func recordVisibilityAbandonments(
        _ receipts: [ThreadAffineRimeVisibilityAbandonmentReceipt]
    ) -> Bool {
        guard case .visibilityEnding = state else {
            failClosed("visibilityReceiptOutOfState")
            return false
        }
        for receipt in receipts {
            guard receipt.terminal == .abandonedVisibility else {
                failClosed("visibilityReceiptTerminalMismatch")
                return false
            }
            let sessionInstance: UInt64
            if case .visibilityEnding(_, let instance) = state {
                sessionInstance = instance
            } else {
                return rejectContract("visibilityReceiptIdentityUnavailable")
            }
            let identity = ResponsiveRimeCanaryTerminalIdentity(
                runID: activeRunID,
                modeGeneration: activeSessionModeGeneration,
                canarySessionInstance: sessionInstance,
                sessionEpoch: receipt.sessionEpoch,
                revision: receipt.revision
            )
            let key = "\(identity.runID):\(identity.modeGeneration):"
                + "\(identity.canarySessionInstance):\(identity.sessionEpoch):"
                + "\(identity.revision)"
            guard visibilityAbandonmentKeys.insert(key).inserted else {
                return rejectContract("duplicateVisibilityReceipt")
            }
            visibilityAbandonmentIdentities.append(identity)
        }
        abandonedVisibilityCount += receipts.count
        return true
    }

    @discardableResult
    public func beginVisibilityResume() -> Bool {
        guard case .visibilitySuspended = state else { return false }
        modeGeneration &+= 1
        state = .canaryStarting(modeGeneration: modeGeneration)
        return true
    }

    /// Grants baseline after a failed startup only when the caller has already
    /// obtained positive proof that the partially started owner was destroyed.
    public func markFailedStartupTeardownComplete() {
        guard case .canaryStarting = state else {
            failClosed("startupTeardownOutOfState")
            return
        }
        state = .baselineActive(reason: .bootstrapUnavailable)
    }

    /// Consumes positive terminals in the only order that grants baseline
    /// recovery. Any mismatch is fail-closed and cannot be retried in-place.
    @discardableResult
    public func recordPositiveTerminal(
        _ terminal: ResponsiveRimeCanaryTransitionTerminal,
        key: ResponsiveRimeCanaryTransitionKey
    ) -> Bool {
        guard case .fenceIssued(let expectedKey, _) = state,
              key == expectedKey
        else {
            failClosed("transitionKeyMismatch")
            return false
        }

        let expected: [ResponsiveRimeCanaryTransitionTerminal] = [
            .ownerDestroyed,
            .mailboxTerminal,
            .deliveryDrained,
        ]
        guard expectedTransitionIndex < expected.count,
              expected[expectedTransitionIndex] == terminal
        else {
            failClosed("transitionOrderMismatch")
            return false
        }

        expectedTransitionIndex += 1
        if expectedTransitionIndex == expected.count {
            state = .baselineRecoveryPermitted(key: key)
            return true
        }
        return false
    }

    public func failClosed(_ reason: String) {
        state = .fencedUnavailable(reason: reason)
    }

    private func rejectContract(_ reason: String) -> Bool {
        lastContractFailure = reason
        return false
    }

    public var permitsBaselineCreation: Bool {
        switch state {
        case .baselineActive, .baselineRecoveryPermitted:
            return true
        default:
            return false
        }
    }
}

#endif
