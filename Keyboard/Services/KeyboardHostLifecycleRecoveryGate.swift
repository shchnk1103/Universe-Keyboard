//
//  KeyboardHostLifecycleRecoveryGate.swift
//  Keyboard
//
//  MainActor 内存状态机：宿主失活/重新激活与展示世代的恢复决策。
//  无 UIKit / KeyboardCore / I/O 依赖；不持有引擎或 composition。
//  许可判定由调用方在任何可能创建 owner 的动作之前传入。
//

/// Opaque identity for the current `NSExtensionContext` without importing UIKit.
struct KeyboardHostExtensionContextID: Hashable, Sendable {
    private let objectID: ObjectIdentifier

    init(_ object: AnyObject) {
        objectID = ObjectIdentifier(object)
    }
}

enum KeyboardHostRecoveryPhase: Equatable, Sendable {
    case hidden
    case appearing
    case visible
}

enum KeyboardHostRecoveryAction: Equatable, Sendable {
    case none
    case suspendRuntime
    case performSharedResume
    case rearmFirstFrameGate
    case completeFirstFrameActivation
}

enum KeyboardHostRecoverySource: Equatable, Sendable {
    case appearance
    case hostActive
    case firstFrame
}

/// One-shot UI classification of Core canary state. The gate does not store or mutate Core.
enum KeyboardHostRecoveryCanaryPermission: Equatable, Sendable {
    case nonCanaryBuild
    case baselineActive
    case visibilitySuspended(resumeGranted: Bool)
    case canaryStarting
    case canaryActive
    case visibilityEnding
    case fenceIssued
    case baselineRecoveryPermitted
    case fencedUnavailable

    func permitsOwnerStarting(source: KeyboardHostRecoverySource) -> Bool {
        switch self {
        case .nonCanaryBuild, .baselineActive:
            return true
        case .visibilitySuspended(let granted):
            return granted
        case .canaryStarting:
            // Original first-frame startup owns canaryStarting; host-active must not start a second owner.
            return source == .firstFrame
        case .canaryActive, .visibilityEnding, .fenceIssued, .fencedUnavailable,
            .baselineRecoveryPermitted:
            return false
        }
    }

    /// Host-active must not rearm or resume when first-frame creation or generic resume is forbidden.
    var blocksHostActiveRecovery: Bool {
        switch self {
        case .fenceIssued, .visibilityEnding, .fencedUnavailable, .baselineRecoveryPermitted,
            .canaryActive:
            return true
        case .visibilitySuspended(let granted):
            return !granted
        case .canaryStarting, .nonCanaryBuild, .baselineActive:
            return false
        }
    }
}

/// Pending host-suspend request, consumed at most once per generation/context pair.
struct KeyboardHostPendingSuspend: Equatable, Sendable {
    var generation: UInt64
    var context: KeyboardHostExtensionContextID
    var activatedAtSuspend: Bool
    var blocked: Bool
}

@MainActor
final class KeyboardHostLifecycleRecoveryGate {
    private(set) var presentationGeneration: UInt64 = 0
    private(set) var phase: KeyboardHostRecoveryPhase = .hidden
    private(set) var currentContext: KeyboardHostExtensionContextID?
    private(set) var pending: KeyboardHostPendingSuspend?
    private(set) var firstFrameRearmPending = false
    private(set) var didSuspendCurrentGeneration = false
    private(set) var firstFrameConsumedForGeneration = false
    private(set) var firstFrameArmToken: UInt64 = 0
    private(set) var firstFrameArmGeneration: UInt64 = 0
    private(set) var firstFrameTickCount = 0
    private(set) var hasLiveFirstFrameArm = false
    /// After reject/complete, begin must not mint a new token until rearm or a new presentation.
    private var firstFrameArmSuppressed = false

    var hasVisibleResumePending: Bool {
        guard let pending, !pending.blocked else { return false }
        return pending.generation == presentationGeneration && pending.context == currentContext
    }

    func noteViewWillAppear(context: KeyboardHostExtensionContextID?) {
        presentationGeneration &+= 1
        phase = .appearing
        currentContext = context
        pending = nil
        firstFrameRearmPending = false
        didSuspendCurrentGeneration = false
        firstFrameConsumedForGeneration = false
        firstFrameArmSuppressed = false
        invalidateFirstFrameArm()
    }

    func noteViewDidAppear(hasWindow: Bool) {
        guard phase == .appearing else { return }
        if hasWindow {
            phase = .visible
        }
        didSuspendCurrentGeneration = false
    }

    func noteViewWillDisappear() {
        phase = .hidden
        presentationGeneration &+= 1
        pending = nil
        firstFrameRearmPending = false
        didSuspendCurrentGeneration = false
        firstFrameConsumedForGeneration = false
        firstFrameArmSuppressed = true
        invalidateFirstFrameArm()
    }

    @discardableResult
    func handleHostWillResignActive(
        context: KeyboardHostExtensionContextID?,
        activatedAtSuspend: Bool
    ) -> KeyboardHostRecoveryAction {
        guard let context, context == currentContext else { return .none }
        let hadRearm = firstFrameRearmPending
        firstFrameRearmPending = false
        invalidateFirstFrameArm()
        if didSuspendCurrentGeneration {
            // Duplicate resign must still cancel an armed first-frame wait.
            return hadRearm ? .suspendRuntime : .none
        }
        didSuspendCurrentGeneration = true
        if phase == .visible, let currentContext {
            pending = KeyboardHostPendingSuspend(
                generation: presentationGeneration,
                context: currentContext,
                activatedAtSuspend: activatedAtSuspend,
                blocked: false
            )
        } else {
            // Appearing/hidden resign must not create a visible resume pending.
            pending = nil
        }
        return .suspendRuntime
    }

    func previewHostDidBecomeActive(
        context: KeyboardHostExtensionContextID?,
        hasWindow: Bool
    ) -> KeyboardHostRecoveryAction {
        decideHostDidBecomeActive(context: context, hasWindow: hasWindow)
    }

    @discardableResult
    func handleHostDidBecomeActive(
        context: KeyboardHostExtensionContextID?,
        hasWindow: Bool,
        canary: KeyboardHostRecoveryCanaryPermission
    ) -> KeyboardHostRecoveryAction {
        let action = decideHostDidBecomeActive(context: context, hasWindow: hasWindow)
        switch action {
        case .none:
            return .none
        case .performSharedResume:
            if !canary.permitsOwnerStarting(source: .hostActive) {
                blockPending()
                return .none
            }
            consumePendingAndRearm()
            return .performSharedResume
        case .rearmFirstFrameGate:
            if canary.blocksHostActiveRecovery {
                blockPending()
                return .none
            }
            invalidateFirstFrameArm()
            firstFrameArmSuppressed = false
            firstFrameRearmPending = true
            firstFrameConsumedForGeneration = false
            return .rearmFirstFrameGate
        case .suspendRuntime, .completeFirstFrameActivation:
            return .none
        }
    }

    /// Issues or reuses the current first-frame arm. Hidden / no-window never mint a token.
    @discardableResult
    func beginFirstFrameArm(hasWindow: Bool) -> UInt64? {
        guard phase == .visible, hasWindow else {
            if hasLiveFirstFrameArm {
                firstFrameArmSuppressed = true
                invalidateFirstFrameArm()
            }
            return nil
        }
        if hasLiveFirstFrameArm {
            return firstFrameArmToken
        }
        if firstFrameArmSuppressed { return nil }
        if firstFrameConsumedForGeneration, !firstFrameRearmPending { return nil }
        firstFrameArmToken &+= 1
        if firstFrameArmToken == 0 {
            firstFrameArmToken = 1
        }
        firstFrameArmGeneration = presentationGeneration
        firstFrameTickCount = 0
        hasLiveFirstFrameArm = true
        return firstFrameArmToken
    }

    func invalidateFirstFrameArm() {
        hasLiveFirstFrameArm = false
        firstFrameTickCount = 0
    }

    func previewFirstFrameTick(
        token: UInt64,
        generation: UInt64,
        hasWindow: Bool
    ) -> KeyboardHostRecoveryAction {
        guard isLiveArm(token: token, generation: generation) else { return .none }
        guard phase == .visible, hasWindow else { return .none }
        guard firstFrameTickCount + 1 >= 2 else { return .none }
        return decideFirstFrameElapsed(hasWindow: hasWindow)
    }

    @discardableResult
    func noteFirstFrameTick(
        token: UInt64,
        generation: UInt64,
        hasWindow: Bool,
        canary: KeyboardHostRecoveryCanaryPermission
    ) -> KeyboardHostRecoveryAction {
        guard isLiveArm(token: token, generation: generation) else { return .none }
        if phase != .visible || !hasWindow {
            rejectCurrentArm(blockPending: false)
            return .none
        }
        firstFrameTickCount += 1
        if firstFrameTickCount < 2 {
            return .none
        }
        let action = decideFirstFrameElapsed(hasWindow: hasWindow)
        guard action == .completeFirstFrameActivation else {
            rejectCurrentArm(blockPending: false)
            return .none
        }
        if !canary.permitsOwnerStarting(source: .firstFrame) {
            rejectCurrentArm(blockPending: true)
            return .none
        }
        consumePendingAndRearm()
        firstFrameConsumedForGeneration = true
        firstFrameArmSuppressed = true
        invalidateFirstFrameArm()
        return .completeFirstFrameActivation
    }

    /// Same recovery branch as host-active, used when active arrived before the window existed.
    @discardableResult
    func handleVisibleWindowEstablished(
        hasWindow: Bool,
        canary: KeyboardHostRecoveryCanaryPermission
    ) -> KeyboardHostRecoveryAction {
        handleHostDidBecomeActive(
            context: currentContext,
            hasWindow: hasWindow,
            canary: canary
        )
    }

    private func isLiveArm(token: UInt64, generation: UInt64) -> Bool {
        hasLiveFirstFrameArm && token == firstFrameArmToken && generation == firstFrameArmGeneration
    }

    private func rejectCurrentArm(blockPending shouldBlock: Bool) {
        firstFrameArmSuppressed = true
        if shouldBlock {
            blockPending()
        } else {
            invalidateFirstFrameArm()
        }
    }

    private func decideHostDidBecomeActive(
        context: KeyboardHostExtensionContextID?,
        hasWindow: Bool
    ) -> KeyboardHostRecoveryAction {
        guard let context, context == currentContext else { return .none }
        guard phase == .visible, hasWindow else { return .none }
        guard let pending, !pending.blocked else { return .none }
        guard pending.generation == presentationGeneration, pending.context == context else {
            return .none
        }
        if firstFrameRearmPending {
            return .none
        }
        if pending.activatedAtSuspend {
            return .performSharedResume
        }
        return .rearmFirstFrameGate
    }

    private func decideFirstFrameElapsed(hasWindow: Bool) -> KeyboardHostRecoveryAction {
        guard phase == .visible, hasWindow else { return .none }
        if firstFrameConsumedForGeneration, !firstFrameRearmPending {
            return .none
        }
        if let pending {
            guard !pending.blocked else { return .none }
            guard pending.generation == presentationGeneration, pending.context == currentContext
            else {
                return .none
            }
        }
        return .completeFirstFrameActivation
    }

    private func blockPending() {
        pending?.blocked = true
        firstFrameRearmPending = false
        firstFrameArmSuppressed = true
        invalidateFirstFrameArm()
    }

    private func consumePendingAndRearm() {
        pending = nil
        firstFrameRearmPending = false
        didSuspendCurrentGeneration = false
    }
}
