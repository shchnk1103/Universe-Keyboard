import XCTest

/// Gate unit tests cover real state/action sequences and call counts only.
/// They do not prove NSExtensionHost notification delivery, appex controller wiring, or runtime recovery.
@MainActor
final class KeyboardHostLifecycleRecoveryGateTests: XCTestCase {
    private final class FakeHostContext {}

    private var gate: KeyboardHostLifecycleRecoveryGate!
    private var current: FakeHostContext!
    private var foreign: FakeHostContext!
    private var resumeCount = 0
    private var rearmCount = 0
    private var firstFrameCount = 0
    private var suspendCount = 0

    override func setUp() async throws {
        try await super.setUp()
        gate = KeyboardHostLifecycleRecoveryGate()
        current = FakeHostContext()
        foreign = FakeHostContext()
        resumeCount = 0
        rearmCount = 0
        firstFrameCount = 0
        suspendCount = 0
    }

    func testVisibleResignThenActiveResumesExactlyOnce() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )

        XCTAssertEqual(suspendCount, 1)
        XCTAssertEqual(resumeCount, 1)
        XCTAssertEqual(rearmCount, 0)
        XCTAssertNil(gate.pending)
        XCTAssertEqual(gate.phase, .visible)
    }

    func testDuplicateActiveAndResignAreIdempotent() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .baselineActive
            )
        )
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .baselineActive
            )
        )

        XCTAssertEqual(suspendCount, 1)
        XCTAssertEqual(resumeCount, 1)
    }

    func testAppearThenActiveAndActiveThenAppearConsumePendingOnce() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        execute(
            gate.handleVisibleWindowEstablished(
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(resumeCount, 1)

        resumeCount = 0
        gate.noteViewWillAppear(context: id(current))
        execute(
            gate.handleVisibleWindowEstablished(
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(resumeCount, 0, "new appearance must not consume a completed host recovery")
    }

    func testForeignAndMissingContextDoNotChangeState() {
        enterVisible()
        let generation = gate.presentationGeneration
        XCTAssertEqual(
            gate.handleHostWillResignActive(context: nil, activatedAtSuspend: true),
            .none
        )
        XCTAssertEqual(
            gate.handleHostWillResignActive(context: id(foreign), activatedAtSuspend: true),
            .none
        )
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: nil,
                hasWindow: true,
                canary: .nonCanaryBuild
            ),
            .none
        )
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: id(foreign),
                hasWindow: true,
                canary: .nonCanaryBuild
            ),
            .none
        )
        XCTAssertEqual(gate.presentationGeneration, generation)
        XCTAssertNil(gate.pending)
        XCTAssertEqual(suspendCount, 0)
        XCTAssertEqual(resumeCount, 0)
    }

    func testHiddenAndNoWindowDoNotResume() {
        gate.noteViewWillAppear(context: id(current))
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        XCTAssertNil(gate.pending)
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            ),
            .none
        )

        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: false,
                canary: .nonCanaryBuild
            ),
            .none
        )
        XCTAssertNotNil(gate.pending)
        XCTAssertEqual(resumeCount, 0)
    }

    func testPrecreatedHiddenInstanceDoesNotResumeOnHostActive() {
        XCTAssertEqual(gate.phase, .hidden)
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            ),
            .none
        )
        XCTAssertEqual(resumeCount, 0)
        XCTAssertEqual(firstFrameCount, 0)
    }

    func testCancelledFirstFrameRearmsOnceWithoutImmediateOwner() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(rearmCount, 1)
        XCTAssertEqual(firstFrameCount, 0)
        XCTAssertEqual(resumeCount, 0)
        XCTAssertTrue(gate.firstFrameRearmPending)
        XCTAssertNotNil(gate.pending)

        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(rearmCount, 1)
    }

    func testLateFirstFrameTickAfterDisappearDoesNotActivate() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        let arm = requireArm()
        gate.noteViewWillDisappear()
        XCTAssertEqual(tick(arm), .none)
        XCTAssertEqual(firstFrameCount, 0)
    }

    func testFirstFrameElapsedConsumesPendingAndActivatesOnce() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        let arm = requireArm()
        XCTAssertEqual(tick(arm), .none)
        execute(tick(arm))
        execute(tick(arm))
        XCTAssertEqual(firstFrameCount, 1)
        XCTAssertNil(gate.pending)
        XCTAssertFalse(gate.firstFrameRearmPending)
    }

    func testCanaryPermissionTableDeniesOwnerStartingBeforeResume() {
        let denials: [KeyboardHostRecoveryCanaryPermission] = [
            .fenceIssued,
            .visibilityEnding,
            .fencedUnavailable,
            .canaryStarting,
            .canaryActive,
            .baselineRecoveryPermitted,
            .visibilitySuspended(resumeGranted: false),
        ]
        for permission in denials {
            resetCounts()
            gate = KeyboardHostLifecycleRecoveryGate()
            current = FakeHostContext()
            enterVisible()
            execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
            XCTAssertEqual(
                gate.previewHostDidBecomeActive(context: id(current), hasWindow: true),
                .performSharedResume
            )
            execute(
                gate.handleHostDidBecomeActive(
                    context: id(current),
                    hasWindow: true,
                    canary: permission
                )
            )
            XCTAssertEqual(resumeCount, 0, "denied \(permission) must not resume")
            XCTAssertEqual(gate.pending?.blocked, true)
        }
    }

    func testVisibilitySuspendedGrantedAllowsExactlyOneResume() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .visibilitySuspended(resumeGranted: true)
            )
        )
        XCTAssertEqual(resumeCount, 1)
        XCTAssertNil(gate.pending)
    }

    func testFenceBlocksRearmAndFirstFrameCreation() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .fenceIssued
            )
        )
        XCTAssertEqual(rearmCount, 0)
        XCTAssertEqual(firstFrameCount, 0)
        XCTAssertEqual(gate.pending?.blocked, true)
        XCTAssertNil(gate.beginFirstFrameArm(hasWindow: true))
        XCTAssertEqual(
            gate.noteFirstFrameTick(
                token: 1,
                generation: gate.presentationGeneration,
                hasWindow: true,
                canary: .fenceIssued
            ),
            .none
        )
    }

    func testCanaryStartingAllowsOriginalFirstFrameButNotHostActiveResume() {
        enterVisible()
        let arm = requireArm()
        XCTAssertEqual(tick(arm, canary: .canaryStarting), .none)
        XCTAssertEqual(
            tick(arm, canary: .canaryStarting),
            .completeFirstFrameActivation
        )
        execute(.completeFirstFrameActivation)
        XCTAssertEqual(firstFrameCount, 1)

        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .canaryStarting
            )
        )
        XCTAssertEqual(resumeCount, 0)
    }

    func testOldPresentationPendingIsInvalidatedOnNewAppearance() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        XCTAssertNotNil(gate.pending)
        gate.noteViewWillAppear(context: id(current))
        XCTAssertNil(gate.pending)
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            ),
            .none
        )
        XCTAssertEqual(resumeCount, 0)
    }

    func testHostActiveBeforeWindowIsTakenOverByDidAppear() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        XCTAssertEqual(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: false,
                canary: .nonCanaryBuild
            ),
            .none
        )
        execute(
            gate.handleVisibleWindowEstablished(
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(resumeCount, 1)
        XCTAssertNil(gate.pending)
    }

    func testPermissionOrderIsEvaluatedBeforeConsumingPending() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        let preview = gate.previewHostDidBecomeActive(context: id(current), hasWindow: true)
        XCTAssertEqual(preview, .performSharedResume)
        XCTAssertNotNil(gate.pending)
        XCTAssertEqual(
            KeyboardHostRecoveryCanaryPermission.fenceIssued.permitsOwnerStarting(source: .hostActive),
            false
        )
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .fenceIssued
            )
        )
        XCTAssertEqual(resumeCount, 0)
        XCTAssertEqual(gate.pending?.blocked, true)
    }

    func testDuplicateActiveDoesNotEmitResumeThatWouldClearNewComposition() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: true))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(resumeCount, 1)
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        XCTAssertEqual(resumeCount, 1)
    }

    func testResignInvalidatesArmedTicksBeforeHostActive() {
        enterVisible()
        let arm = requireArm()
        XCTAssertEqual(tick(arm), .none)
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        XCTAssertFalse(gate.hasLiveFirstFrameArm)
        XCTAssertEqual(tick(arm), .none)
        XCTAssertEqual(tick(arm), .none)
        XCTAssertEqual(firstFrameCount, 0)
    }

    func testStaleArmTokenTicksAfterRearmDoNotAdvanceCurrentArm() {
        enterVisible()
        let first = requireArm()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        let second = requireArm()
        XCTAssertNotEqual(first.token, second.token)
        XCTAssertEqual(tick(first), .none)
        XCTAssertEqual(tick(first), .none)
        XCTAssertEqual(gate.firstFrameTickCount, 0)
        XCTAssertEqual(tick(second), .none)
        execute(tick(second))
        XCTAssertEqual(firstFrameCount, 1)
    }

    func testHiddenAndNoWindowDoNotBeginFirstFrameArm() {
        gate.noteViewWillAppear(context: id(current))
        XCTAssertNil(gate.beginFirstFrameArm(hasWindow: true))
        enterVisible()
        XCTAssertNil(gate.beginFirstFrameArm(hasWindow: false))
        XCTAssertFalse(gate.hasLiveFirstFrameArm)
        XCTAssertEqual(
            gate.noteFirstFrameTick(
                token: 1,
                generation: gate.presentationGeneration,
                hasWindow: true,
                canary: .nonCanaryBuild
            ),
            .none
        )
        XCTAssertEqual(firstFrameCount, 0)
    }

    func testCurrentArmTokenCompletesExactlyOnSecondTick() {
        enterVisible()
        let arm = requireArm()
        XCTAssertEqual(tick(arm), .none)
        execute(tick(arm))
        XCTAssertEqual(firstFrameCount, 1)
        XCTAssertEqual(tick(arm), .none)
        XCTAssertEqual(firstFrameCount, 1)
        XCTAssertFalse(gate.hasLiveFirstFrameArm)
    }

    func testRejectedOrInvalidatedArmStopsTicksWithoutRetry() {
        enterVisible()
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        let denied = requireArm()
        XCTAssertEqual(tick(denied), .none)
        XCTAssertEqual(tick(denied, canary: .fenceIssued), .none)
        XCTAssertEqual(firstFrameCount, 0)
        XCTAssertEqual(gate.pending?.blocked, true)
        XCTAssertFalse(gate.hasLiveFirstFrameArm)
        XCTAssertEqual(tick(denied, canary: .fenceIssued), .none)
        XCTAssertNil(gate.beginFirstFrameArm(hasWindow: true))

        resetCounts()
        gate = KeyboardHostLifecycleRecoveryGate()
        current = FakeHostContext()
        enterVisible()
        let vanished = requireArm()
        XCTAssertEqual(tick(vanished), .none)
        XCTAssertEqual(tick(vanished, hasWindow: false), .none)
        XCTAssertEqual(firstFrameCount, 0)
        XCTAssertFalse(gate.hasLiveFirstFrameArm)
        XCTAssertEqual(tick(vanished), .none)
        XCTAssertNil(gate.beginFirstFrameArm(hasWindow: true))
    }

    func testDuplicateBeginFirstFrameArmIsIdempotentUntilGenuineRearm() {
        enterVisible()
        let first = requireArm()
        XCTAssertEqual(tick(first), .none)
        XCTAssertEqual(gate.firstFrameTickCount, 1)
        XCTAssertEqual(gate.beginFirstFrameArm(hasWindow: true), first.token)
        XCTAssertEqual(gate.firstFrameTickCount, 1)
        execute(tick(first))
        XCTAssertEqual(firstFrameCount, 1)

        resetCounts()
        gate = KeyboardHostLifecycleRecoveryGate()
        current = FakeHostContext()
        enterVisible()
        let beforeResign = requireArm()
        XCTAssertEqual(tick(beforeResign), .none)
        execute(gate.handleHostWillResignActive(context: id(current), activatedAtSuspend: false))
        execute(
            gate.handleHostDidBecomeActive(
                context: id(current),
                hasWindow: true,
                canary: .nonCanaryBuild
            )
        )
        let afterRearm = requireArm()
        XCTAssertNotEqual(beforeResign.token, afterRearm.token)
        XCTAssertEqual(gate.firstFrameTickCount, 0)
        XCTAssertEqual(tick(afterRearm), .none)
        execute(tick(afterRearm))
        XCTAssertEqual(firstFrameCount, 1)
    }

    private func enterVisible() {
        gate.noteViewWillAppear(context: id(current))
        gate.noteViewDidAppear(hasWindow: true)
        XCTAssertEqual(gate.phase, .visible)
    }

    private func id(_ object: FakeHostContext) -> KeyboardHostExtensionContextID {
        KeyboardHostExtensionContextID(object)
    }

    private func resetCounts() {
        resumeCount = 0
        rearmCount = 0
        firstFrameCount = 0
        suspendCount = 0
    }

    private func execute(_ action: KeyboardHostRecoveryAction) {
        switch action {
        case .none:
            break
        case .suspendRuntime:
            suspendCount += 1
        case .performSharedResume:
            resumeCount += 1
        case .rearmFirstFrameGate:
            rearmCount += 1
        case .completeFirstFrameActivation:
            firstFrameCount += 1
        }
    }

    private struct ArmedFirstFrame {
        let token: UInt64
        let generation: UInt64
    }

    private func requireArm(hasWindow: Bool = true) -> ArmedFirstFrame {
        let token = gate.beginFirstFrameArm(hasWindow: hasWindow)
        XCTAssertNotNil(token)
        return ArmedFirstFrame(token: token ?? 0, generation: gate.presentationGeneration)
    }

    @discardableResult
    private func tick(
        _ arm: ArmedFirstFrame,
        hasWindow: Bool = true,
        canary: KeyboardHostRecoveryCanaryPermission = .nonCanaryBuild
    ) -> KeyboardHostRecoveryAction {
        gate.noteFirstFrameTick(
            token: arm.token,
            generation: arm.generation,
            hasWindow: hasWindow,
            canary: canary
        )
    }
}
