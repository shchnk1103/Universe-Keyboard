import UIKit
import XCTest

@testable import KeyboardCore

/// 真实 UIKit 约束测试；省略引擎 bootstrap，不等同于系统激活的扩展。
nonisolated final class KeyboardHeightControllerTests: XCTestCase {
    @MainActor
    func testUnpreparedHeightManagementKeepsSceneLessWindowTouchable() throws {
        let owner = makeOwner(saved: nil, nineKey: true)
        owner.keyboardHeightGeometrySource = { nil }
        owner.setupRootStack()
        owner.reloadKeyboard()
        layout(owner)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(owner.view)
        window.isHidden = false
        defer { window.isHidden = true }
        owner.synchronizeKeyboardHeightLayout()
        layout(owner)
        let key = try XCTUnwrap(
            descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.first {
                $0.accessibilityIdentifier == "6"
            })
        let point = key.convert(CGPoint(x: key.bounds.midX, y: key.bounds.midY), to: owner.view)
        let hit = owner.view.hitTest(point, with: nil)
        XCTAssertFalse(owner.isKeyboardHeightManaged)
        XCTAssertNil(owner.keyboardHeightStatus)
        XCTAssertEqual(owner.view.alpha, 1)
        XCTAssertTrue(owner.keyboardHeightConstraint?.isActive == true)
        XCTAssertTrue(hit === key || hit?.isDescendant(of: key) == true)
    }

    @MainActor
    func testMissingSceneDefersFirstRequestAndReadsPreferenceOnlyOnce() throws {
        let owner = makeOwner(saved: nil)
        var reads = 0
        owner.keyboardRowHeightSource = {
            reads += 1; return 70
        }
        owner.keyboardHeightGeometrySource = { nil }
        owner.prepareKeyboardHeightForAppearance()
        owner.installPreferredKeyboardHeight()
        owner.installKeyboardUIIfNeeded()
        XCTAssertNil(owner.keyboardHeightConstraint)
        XCTAssertFalse(owner.isKeyboardUIInstalled)
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertEqual(owner.keyboardHeightStatus, "waitingForWindowScene")
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
        XCTAssertTrue(owner.isKeyboardUIInstalled)
        XCTAssertEqual(owner.view.alpha, 1)
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(reads, 1)
    }

    @MainActor
    func testDefaultPagesKeepOriginalGeometry() throws {
        XCTAssertEqual(KeyboardHeightSettings.defaultRowHeight, 45)
        XCTAssertEqual(KeyboardDesignTokens.CandidateBar.totalHeight, 46)
        XCTAssertEqual(KeyboardDesignTokens.T9PinyinBar.visibleHeight, 34)
        XCTAssertEqual(KeyboardViewController.defaultKeyboardHeightWithoutPath, 254)
        for page in [KeyboardPage.letters, .numbers, .symbols, .emoji] {
            let owner = makeOwner(saved: nil)
            owner.controller.state.currentPage = page
            install(owner)
            XCTAssertEqual(owner.keyHeight, 45)
            XCTAssertEqual(owner.preferredKeyboardHeight, 254)
            XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 254)
            XCTAssertEqual(owner.candidateBarHeight, 46)
            assertRowConstraints(owner, rowHeight: 45)
            attachLayout(owner, name: "default-\(page)")
        }
        let nineKey = makeOwner(saved: nil, nineKey: true)
        install(nineKey)
        showPath(nineKey)
        layout(nineKey)
        XCTAssertEqual(nineKey.preferredKeyboardHeight, 288)
        XCTAssertEqual(nineKey.keyboardHeightConstraint?.constant, 288)
        XCTAssertEqual(nineKey.t9PinyinPathBarView?.frame.height, 34)
        assertRowConstraints(nineKey, rowHeight: 45)
        attachLayout(nineKey, name: "default-nine-key-path")
    }

    @MainActor
    func testSavedHeightDrivesAllPagesAndDerivedConstraints() {
        for page in [KeyboardPage.letters, .numbers, .symbols, .emoji] {
            let owner = makeOwner(saved: 70)
            owner.controller.state.currentPage = page
            install(owner)
            XCTAssertEqual(owner.keyHeight, 70)
            XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
            assertRowConstraints(owner, rowHeight: 70)
            if page == .emoji {
                XCTAssertTrue(
                    owner.keyboardHeightConstraints.contains {
                        $0.rows == 3 && $0.constraint?.constant == 226
                    })
            }
            attachLayout(owner, name: "row70-\(page)")
        }
        let owner = makeOwner(saved: 70, nineKey: true)
        install(owner)
        showPath(owner)
        let panel = owner.makePinyinPathExpandedPanel()
        XCTAssertEqual(
            panel.constraints.first { $0.firstAttribute == .height && $0.relation == .greaterThanOrEqual }?.constant,
            304)
        XCTAssertTrue(
            owner.keyboardHeightConstraints.contains {
                $0.rows == 4 && $0.extraHeight == 26 && $0.constraint?.constant == 306
            })
        assertRowConstraints(owner, rowHeight: 70)
    }

    @MainActor
    func testPathAppearanceRecomputesCapWithoutChangingPreference() {
        let owner = makeOwner(saved: 100, nineKey: true)
        install(owner)
        XCTAssertEqual(owner.keyHeight, 87)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 422)
        showPath(owner)
        layout(owner)
        XCTAssertEqual(owner.keyHeight, 78)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 420)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 100)
        assertRowConstraints(owner, rowHeight: 78)
    }

    @MainActor
    func testRotationAndHostCompressionDoNotWriteBackOrReloadRows() {
        let owner = makeOwner(saved: 70)
        install(owner)
        let originalRows = owner.rootStack.arrangedSubviews.map(ObjectIdentifier.init)
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 390, isLandscape: true) }
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 45)
        assertRowConstraints(owner, rowHeight: 45)
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 70)
        owner.keyboardAcceptedHeight = 274
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 50)
        XCTAssertEqual(owner.preferredKeyboardHeight, 274)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 70)
        XCTAssertEqual(owner.rootStack.arrangedSubviews.map(ObjectIdentifier.init), originalRows)
        assertRowConstraints(owner, rowHeight: 50)
    }

    @MainActor
    func testNextAppearanceReadsNewValueBeforeUpdatingExistingRows() {
        let owner = makeOwner(saved: 60)
        var saved = 60
        owner.keyboardRowHeightSource = { saved }
        install(owner)
        saved = 70
        owner.prepareKeyboardHeightForAppearance()
        XCTAssertEqual(owner.keyHeight, 60)
        owner.keyboardHeightNeedsRead = true
        owner.prepareKeyboardHeightForAppearance()
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
        assertRowConstraints(owner, rowHeight: 70)
    }

    @MainActor
    func testImpossibleHostBudgetIsReportedWithoutLoweringMinimum() {
        let owner = makeOwner(saved: 70)
        install(owner)
        owner.keyboardAcceptedHeight = 216
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertFalse(owner.keyboardHeightConstraint?.isActive ?? true)
        XCTAssertGreaterThanOrEqual(owner.keyHeight, CGFloat(KeyboardHeightSettings.minimumRowHeight))
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 70)
    }

    @MainActor
    func testRotationCompletionPromotesConstraintOnceWithoutWritingPreference() throws {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        let request = try XCTUnwrap(owner.keyboardHeightConstraint)
        let coordinator = HeightRotationCoordinator()
        owner.viewWillTransition(to: CGSize(width: 390, height: 254), with: coordinator)
        XCTAssertEqual(request.priority, .defaultHigh)
        coordinator.complete()
        XCTAssertEqual(request.priority.rawValue, 999)
        XCTAssertEqual(request.constant, 314)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
        XCTAssertEqual(writes, 0)
        // 外部改变优先级后重复同一个完成回调，不能再次补请求。
        request.priority = .defaultHigh
        coordinator.complete()
        XCTAssertEqual(request.priority, .defaultHigh)
    }

    @MainActor
    func testRotationPriorityRestoresOnEveryExitAndRejectsLateCompletion() throws {
        for exit in ["nextTransition", "disappear", "replacement", "windowRemoved"] {
            let (owner, window) = makeRotationOwner()
            defer { window.isHidden = true }
            let request = try XCTUnwrap(owner.keyboardHeightConstraint)
            let coordinator = HeightRotationCoordinator()
            owner.viewWillTransition(to: CGSize(width: 390, height: 254), with: coordinator)
            coordinator.complete()
            XCTAssertEqual(request.priority.rawValue, 999, exit)
            switch exit {
            case "nextTransition":
                owner.viewWillTransition(to: CGSize(width: 844, height: 254), with: HeightRotationCoordinator())
            case "disappear":
                owner.viewWillDisappear(false)
            case "replacement":
                request.isActive = false
                let replacement = owner.view.heightAnchor.constraint(equalToConstant: 314)
                replacement.priority = .defaultHigh
                owner.keyboardHeightConstraint = replacement
            default:
                owner.view.removeFromSuperview()
            }
            XCTAssertEqual(request.priority, .defaultHigh, exit)
            coordinator.complete()
            XCTAssertEqual(request.priority, .defaultHigh, exit)
            XCTAssertEqual(owner.keyboardHeightConstraint?.priority, .defaultHigh, exit)
            XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60, exit)
        }
    }

    @MainActor
    func testRotationDoesNotPromoteWhenAnyEligibilityConditionIsMissing() throws {
        for missing in ["window", "visible", "notCancelled", "mismatch", "constraint"] {
            let (owner, window) = makeRotationOwner()
            defer { window.isHidden = true }
            let request = try XCTUnwrap(owner.keyboardHeightConstraint)
            let coordinator = HeightRotationCoordinator()
            switch missing {
            case "window": owner.view.removeFromSuperview()
            case "visible": owner.hostLifecycleRecoveryGate.noteViewWillDisappear()
            case "notCancelled": coordinator.isCancelled = true
            case "mismatch": owner.view.bounds.size.height = 314
            default: owner.keyboardHeightConstraint = nil
            }
            owner.viewWillTransition(to: CGSize(width: 390, height: 254), with: coordinator)
            coordinator.complete()
            XCTAssertEqual(request.priority, .defaultHigh, missing)
            XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60, missing)
        }
    }

    @MainActor
    func testElevatedRequestStillAcceptsRealHostCompressionWithoutSaving() throws {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        var writes = 0
        owner.keyboardRowHeightSink = { _ in writes += 1 }
        let request = try XCTUnwrap(owner.keyboardHeightConstraint)
        let coordinator = HeightRotationCoordinator()
        owner.viewWillTransition(to: CGSize(width: 390, height: 254), with: coordinator)
        coordinator.complete()
        XCTAssertEqual(request.priority.rawValue, 999)
        owner.view.bounds.size.height = 274
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.heightBudgetFrames.settle()
        XCTAssertEqual(owner.keyboardAcceptedHeight, 274)
        XCTAssertEqual(owner.keyHeight, 50)
        XCTAssertEqual(request.constant, 314)
        XCTAssertEqual(request.priority.rawValue, 999)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
        XCTAssertEqual(writes, 0)
        owner.view.bounds.size.height = 216
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.heightBudgetFrames.settle()
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertFalse(request.isActive)
        XCTAssertGreaterThanOrEqual(owner.keyHeight, 40)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
        XCTAssertEqual(writes, 0)
    }

    @MainActor
    func testSuspendRestoresHeldRotationLeaseAndRejectsLateCompletion() throws {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        let request = try XCTUnwrap(owner.keyboardHeightConstraint)
        let coordinator = HeightRotationCoordinator()
        owner.viewWillTransition(to: CGSize(width: 390, height: 254), with: coordinator)
        coordinator.complete()
        XCTAssertEqual(request.priority.rawValue, 999)
        owner.suspendKeyboardRuntime(reason: "syntheticHostResign", updateUI: false)
        XCTAssertEqual(request.priority, .defaultHigh)
        coordinator.complete()
        XCTAssertEqual(request.priority, .defaultHigh)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
    }

    @MainActor
    func testSuspendInvalidatesPendingRotationCompletion() throws {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        let request = try XCTUnwrap(owner.keyboardHeightConstraint)
        let coordinator = HeightRotationCoordinator()
        owner.viewWillTransition(to: CGSize(width: 390, height: 254), with: coordinator)
        owner.suspendKeyboardRuntime(reason: "syntheticHostResign", updateUI: false)
        coordinator.complete()
        XCTAssertEqual(request.priority, .defaultHigh)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 60)
    }

    @MainActor
    func testGrowthIgnoresFirstOldBoundsAndAcceptsSecondLargerLayout() throws {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.view.bounds.size.height = 314
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.keyboardHeightSettings = KeyboardHeightSettings(savedRowHeight: 70)
        owner.synchronizeKeyboardHeightLayout()
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(owner.view.alpha, 1)
        owner.view.bounds.size.height = 354
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
    }

    @MainActor
    func testNewAppearanceRenegotiatesEvenWhenSavedRequestIsUnchanged() {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.view.bounds.size.height = 314
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertNil(owner.keyboardHeightBudgetRequest)
        owner.keyboardHeightNeedsRead = true
        owner.prepareKeyboardHeightForAppearance()
        owner.view.bounds.size.height = 254
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.view.alpha, 1)
        owner.view.bounds.size.height = 314
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertNil(owner.keyboardAcceptedHeight)
    }

    @MainActor
    func testStableOldBudgetCompressesWithoutChangingSavedIntentAndCanRecover() {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.view.bounds.size.height = 314
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.keyboardHeightSettings = KeyboardHeightSettings(savedRowHeight: 70)
        owner.synchronizeKeyboardHeightLayout()
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertEqual(owner.keyHeight, 70)
        // Ordinary refreshes are not extra host layout observations.
        for _ in 0..<5 { owner.synchronizeKeyboardHeightLayout() }
        XCTAssertNil(owner.keyboardAcceptedHeight)
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.heightBudgetFrames.settle()
        XCTAssertEqual(owner.keyboardAcceptedHeight, 314)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 70)
        owner.view.bounds.size.height = 216
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.heightBudgetFrames.settle()
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertEqual(owner.view.alpha, 0)
        owner.view.bounds.size.height = 354
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertEqual(owner.keyboardHeightStatus, "ready")
        XCTAssertEqual(owner.view.alpha, 1)
        XCTAssertEqual(owner.keyHeight, 70)
    }

    @MainActor
    func testPathGrowthKeepsKeysHittableAndControlActionsDeliverUntilHostSettles() throws {
        for grows in [true, false] {
            let owner = makeOwner(saved: 43, nineKey: true)
            install(owner)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 500))
            let host = UIViewController()
            window.rootViewController = host
            host.view.addSubview(owner.view)
            window.isHidden = false
            defer { window.isHidden = true }
            owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
            owner.hostLifecycleRecoveryGate.noteViewDidAppear(hasWindow: true)
            owner.view.bounds.size.height = 246
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            showPath(owner)
            owner.view.bounds.size.height = 246
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            XCTAssertEqual(owner.keyHeight, 43)
            XCTAssertNil(owner.keyboardAcceptedHeight)
            XCTAssertEqual(owner.view.alpha, 1)
            XCTAssertTrue(owner.keyboardHeightConstraint?.isActive == true)
            owner.rootStack.layoutIfNeeded()
            let key = try XCTUnwrap(
                descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.first {
                    $0.accessibilityIdentifier == "6"
                })
            let point = key.convert(CGPoint(x: key.bounds.midX, y: key.bounds.midY), to: owner.view)
            let hit = owner.view.hitTest(point, with: nil)
            XCTAssertTrue(hit === key || hit?.isDescendant(of: key) == true)
            let receiver = HeightControlReceiver()
            key.removeTarget(nil, action: nil, for: .allEvents)
            // Hostless XCTest 没有 UIApplication selector 派发器；UIAction 仍走 UIControl 事件派发。
            key.addAction(UIAction { _ in receiver.receive() }, for: .touchUpInside)
            for _ in 0..<3 { key.sendActions(for: .touchUpInside) }
            XCTAssertEqual(receiver.count, 3)
            owner.view.bounds.size.height = grows ? 280 : 246
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 43)
            if grows {
                XCTAssertEqual(owner.keyHeight, 43)
                XCTAssertEqual(owner.view.alpha, 1)
                XCTAssertNil(owner.keyboardAcceptedHeight)
            } else {
                owner.heightBudgetFrames.settle()
                XCTAssertEqual(owner.keyboardAcceptedHeight, 246)
                XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
                XCTAssertEqual(owner.view.alpha, 0)
                XCTAssertFalse(owner.keyboardHeightConstraint?.isActive ?? true)
            }
        }
    }

    @MainActor
    func testFrameClockKeepsThirtyToFiftyMillisecondHostGrowthUncompressed() {
        for delay in [0.03, 0.04, 0.05] {
            let (owner, window) = makeRotationOwner()
            defer { window.isHidden = true }
            owner.view.bounds.size.height = 314
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            owner.keyboardHeightSettings = KeyboardHeightSettings(savedRowHeight: 70)
            owner.synchronizeKeyboardHeightLayout()
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            let start = owner.heightBudgetFrames.now
            for frame in 1...5 {
                owner.heightBudgetFrames.advance(to: start + delay * Double(frame) / 6)
                // Repeated self/host layout calls cannot accelerate the frame clock.
                owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
                XCTAssertNil(owner.keyboardAcceptedHeight)
                XCTAssertEqual(owner.keyHeight, 70)
                XCTAssertEqual(owner.view.alpha, 1)
            }
            // One old host callback was enough to start the observer. No callback accompanies the new bounds.
            owner.view.bounds.size.height = 354
            owner.heightBudgetFrames.advance(to: start + delay)
            XCTAssertNil(owner.keyboardAcceptedHeight)
            XCTAssertEqual(owner.keyHeight, 70)
            XCTAssertEqual(owner.view.alpha, 1)
            XCTAssertTrue(owner.heightBudgetFrames.observations.last?.invalidated == true)
        }
    }

    @MainActor
    func testPostSettlementLowReadingUsesSameTrustWindow() {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.view.bounds.size.height = 274
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        owner.heightBudgetFrames.settle()
        XCTAssertEqual(owner.keyboardAcceptedHeight, 274)
        XCTAssertEqual(owner.keyHeight, 50)
        owner.view.bounds.size.height = 216
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let start = owner.heightBudgetFrames.now
        owner.heightBudgetFrames.advance(to: start + 0.05)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.view.alpha, 1)
        owner.heightBudgetFrames.advance(to: start + 0.08)
        XCTAssertEqual(owner.keyboardAcceptedHeight, 216)
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
    }

    @MainActor
    func testOscillatingHostStopsAtBoundWithoutSelfSchedulingLayouts() throws {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.view.bounds.size.height = 246
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let start = owner.heightBudgetFrames.now
        let layouts = owner.layoutCount
        for frame in 1...17 {
            owner.view.bounds.size.height = frame.isMultiple(of: 2) ? 246 : 250
            owner.heightBudgetFrames.advance(to: start + Double(frame) / 120)
        }
        XCTAssertTrue(owner.keyboardHeightBudgetObservationExhausted)
        XCTAssertNotNil(owner.keyboardHeightBudgetFrameObservation)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.view.alpha, 1)
        XCTAssertEqual(owner.keyHeight, 60)
        XCTAssertEqual(owner.layoutCount, layouts)
        // 耗尽恢复等待不被100次布局提前执行。
        owner.view.bounds.size.height = try XCTUnwrap(owner.keyboardHeightBudgetExhaustedHeight)
        let observations = owner.heightBudgetFrames.observations.count
        for _ in 0..<100 { owner.synchronizeKeyboardHeightLayout(isHostLayout: true) }
        XCTAssertEqual(owner.heightBudgetFrames.observations.count, observations)
        XCTAssertEqual(owner.layoutCount, layouts)
        XCTAssertNil(owner.keyboardAcceptedHeight)
    }

    @MainActor
    func testExhaustedOscillationReobservesChangedStableLowBudget() {
        let owner = makeOwner(saved: 43, nineKey: true)
        install(owner)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 500))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(owner.view)
        window.isHidden = false
        defer { window.isHidden = true }
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.hostLifecycleRecoveryGate.noteViewDidAppear(hasWindow: true)
        owner.view.bounds.size = CGSize(width: 390, height: 246)
        showPath(owner)
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        XCTAssertEqual(owner.keyboardUncompressedHeight, 280)
        let start = owner.heightBudgetFrames.now
        let layouts = owner.layoutCount
        // 外部宿主逐帧变化300ms；仅真实变化可重新取得一个有界观察窗口。
        for frame in 1...36 {
            owner.view.bounds.size.height = frame.isMultiple(of: 2) ? 250 : 254
            owner.heightBudgetFrames.advance(to: start + Double(frame) / 120)
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            XCTAssertNil(owner.keyboardAcceptedHeight)
            XCTAssertEqual(owner.view.alpha, 1)
        }
        XCTAssertLessThanOrEqual(owner.heightBudgetFrames.observations.count, 3)
        XCTAssertGreaterThanOrEqual(owner.heightBudgetFrames.observations.count, 2)
        XCTAssertEqual(owner.layoutCount, layouts)
        owner.view.bounds.size.height = 246
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let settledStart = owner.heightBudgetFrames.now
        owner.heightBudgetFrames.advance(to: settledStart + 0.01)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        owner.heightBudgetFrames.advance(to: settledStart + 0.03)
        XCTAssertEqual(owner.keyboardAcceptedHeight, 246)
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertNil(owner.keyboardHeightBudgetFrameObservation)
        let observations = owner.heightBudgetFrames.observations.count
        for _ in 0..<100 { owner.synchronizeKeyboardHeightLayout(isHostLayout: true) }
        XCTAssertEqual(owner.heightBudgetFrames.observations.count, observations)
        XCTAssertEqual(owner.layoutCount, layouts)
    }

    @MainActor
    func testLateStableExhaustedReadingGetsOneTimedRecovery() {
        let owner = makeOwner(saved: 43, nineKey: true)
        install(owner)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 500))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(owner.view)
        window.isHidden = false
        defer { window.isHidden = true }
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.hostLifecycleRecoveryGate.noteViewDidAppear(hasWindow: true)
        owner.view.bounds.size = CGSize(width: 390, height: 246)
        showPath(owner)
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let start = owner.heightBudgetFrames.now
        // 窗口最后两帧才稳定，无法满足原16.7ms稳定门槛。
        for frame in 1...16 {
            owner.view.bounds.size.height = frame >= 15 ? 246 : (frame.isMultiple(of: 2) ? 250 : 254)
            owner.heightBudgetFrames.advance(to: start + Double(frame) / 120)
        }
        XCTAssertTrue(owner.keyboardHeightBudgetObservationExhausted)
        XCTAssertEqual(owner.keyboardHeightBudgetExhaustedHeight, 246)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        owner.heightBudgetFrames.advance(to: start + 0.142)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        owner.heightBudgetFrames.advance(to: start + 0.16)
        owner.heightBudgetFrames.advance(to: start + 0.18)
        owner.heightBudgetFrames.advance(to: start + 0.205)
        owner.heightBudgetFrames.advance(to: start + 0.225)
        owner.heightBudgetFrames.advance(to: start + 0.285)
        XCTAssertEqual(owner.keyboardAcceptedHeight, 246)
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertNil(owner.keyboardHeightBudgetFrameObservation)
    }

    @MainActor
    func testContinuousOscillationEndsAfterOneRecoveryWindow() {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.view.bounds.size.height = 246
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let start = owner.heightBudgetFrames.now
        let layouts = owner.layoutCount
        for frame in 1...48 {
            owner.view.bounds.size.height = frame.isMultiple(of: 2) ? 246 : 250
            owner.heightBudgetFrames.advance(to: start + Double(frame) / 120)
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
            if frame == 42 {
                // 350ms内初始窗口、等待、唯一恢复窗口均停止（总预算上限400ms）。
                XCTAssertNil(owner.keyboardHeightBudgetFrameObservation)
                XCTAssertTrue(owner.keyboardHeightBudgetObservationExhausted)
            }
        }
        XCTAssertEqual(owner.heightBudgetFrames.observations.count, 3)
        XCTAssertTrue(owner.heightBudgetFrames.observations.allSatisfy { $0.invalidated })
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.layoutCount, layouts)
        for frame in 49...120 {
            owner.view.bounds.size.height = frame.isMultiple(of: 2) ? 246 : 250
            owner.heightBudgetFrames.advance(to: start + Double(frame) / 120)
            owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        }
        XCTAssertEqual(owner.heightBudgetFrames.observations.count, 3)
        XCTAssertNil(owner.keyboardHeightBudgetFrameObservation)
        XCTAssertEqual(owner.view.alpha, 1)
    }

    @MainActor
    func testFrameSampleCapAndLateCallbacksCannotReviveCancelledRequest() {
        let (owner, window) = makeRotationOwner()
        defer { window.isHidden = true }
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let start = owner.heightBudgetFrames.now
        for frame in 1...KeyboardHeightBudgetRequest.maximumFrameSamples {
            owner.view.bounds.size.height = frame.isMultiple(of: 2) ? 246 : 250
            owner.heightBudgetFrames.advance(to: start)
        }
        XCTAssertTrue(owner.keyboardHeightBudgetObservationExhausted)
        XCTAssertTrue(owner.heightBudgetFrames.observations.first?.invalidated == true)
        XCTAssertEqual(owner.heightBudgetFrames.observations.count, 2)
        owner.resetKeyboardHeightBudgetTrust()
        let previous = owner.heightBudgetFrames.observations.last
        previous?.handler(start + 1)
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertNil(owner.keyboardHeightBudgetFrameObservation)
    }

    @MainActor
    func testF1DelayedHostGrowthDoesNotTrustSelfScheduledLayout() throws {
        // 该方法同时在 R0 / R1 编译运行，不依赖 R1 的时钟或调度器 API。
        let owner = HeightLayoutController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = .nineKey
        owner.cachedT9ReadinessMatched = true
        owner.keyboardRowHeightSource = { 43 }
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        owner.prepareKeyboardHeightForAppearance()
        owner.installPreferredKeyboardHeight()
        owner.installKeyboardUIIfNeeded()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 500))
        let host = UIViewController()
        window.rootViewController = host
        host.addChild(owner)
        host.view.addSubview(owner.view)
        owner.didMove(toParent: host)
        owner.view.translatesAutoresizingMaskIntoConstraints = false
        let hostHeight = owner.view.heightAnchor.constraint(equalToConstant: 246)
        NSLayoutConstraint.activate([
            owner.view.bottomAnchor.constraint(equalTo: host.view.bottomAnchor),
            owner.view.leadingAnchor.constraint(equalTo: host.view.leadingAnchor),
            owner.view.widthAnchor.constraint(equalToConstant: 390), hostHeight,
        ])
        window.isHidden = false
        defer { window.isHidden = true }
        host.view.layoutIfNeeded()
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.hostLifecycleRecoveryGate.noteViewDidAppear(hasWindow: true)
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        owner.controller.state.t9PinyinPathState = .init(trackedRawInput: "64")
        owner.refreshT9PinyinPathBar()
        // 只主动送一次旧 bounds 布局；随后让真正的主队列和显示帧执行。
        owner.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        owner.view.layoutIfNeeded()
        owner.synchronizeKeyboardHeightLayout(isHostLayout: true)
        let started = CACurrentMediaTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            hostHeight.constant = 280
            host.view.setNeedsLayout()
            host.view.layoutIfNeeded()
            owner.view.setNeedsLayout()
            owner.view.layoutIfNeeded()
            print("F1_HOST_RAISED elapsed=\(CACurrentMediaTime() - started)")
        }
        for _ in 0..<10 {
            RunLoop.main.run(until: Date().addingTimeInterval(0.003))
            print(
                "F1_SAMPLE elapsed=\(CACurrentMediaTime() - started) accepted=\(String(describing: owner.keyboardAcceptedHeight)) alpha=\(owner.view.alpha)"
            )
            XCTAssertNil(owner.keyboardAcceptedHeight)
            XCTAssertEqual(owner.keyHeight, 43)
            XCTAssertEqual(owner.view.alpha, 1)
            XCTAssertTrue(owner.keyboardHeightConstraint?.isActive == true)
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.06))
        XCTAssertNil(owner.keyboardAcceptedHeight)
        XCTAssertEqual(owner.keyHeight, 43)
        XCTAssertEqual(owner.view.alpha, 1)
        XCTAssertEqual(owner.view.bounds.height, 280)
    }

    @MainActor
    private func makeRotationOwner() -> (HeightLayoutController, UIWindow) {
        let owner = makeOwner(saved: 60)
        install(owner)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 500))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(owner.view)
        window.isHidden = false
        owner.hostLifecycleRecoveryGate.noteViewWillAppear(context: nil)
        owner.hostLifecycleRecoveryGate.noteViewDidAppear(hasWindow: true)
        owner.view.bounds.size = CGSize(width: 390, height: 254)
        return (owner, window)
    }

    @MainActor
    private func makeOwner(saved: Int?, nineKey: Bool = false) -> HeightLayoutController {
        let owner = HeightLayoutController()
        owner.heightBudgetFrames.attach(to: owner)
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
        owner.cachedT9ReadinessMatched = nineKey
        owner.keyboardRowHeightSource = { saved }
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        return owner
    }

    @MainActor
    private func install(_ owner: KeyboardViewController) {
        owner.prepareKeyboardHeightForAppearance()
        owner.installPreferredKeyboardHeight()
        owner.installKeyboardUIIfNeeded()
        layout(owner)
    }

    @MainActor
    private func showPath(_ owner: KeyboardViewController) {
        owner.controller.state.t9PinyinPathState = .init(trackedRawInput: "64")
        owner.refreshT9PinyinPathBar()
    }

    @MainActor
    private func layout(_ owner: KeyboardViewController) {
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: owner.preferredKeyboardHeight)
        owner.view.setNeedsLayout()
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
    }

    @MainActor
    private func assertRowConstraints(
        _ owner: KeyboardViewController, rowHeight: CGFloat,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        for entry in owner.keyboardHeightConstraints where entry.constraint?.isActive == true {
            XCTAssertEqual(
                entry.constraint?.constant, rowHeight * entry.rows + entry.extraHeight,
                file: file, line: line)
        }
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }

    @MainActor
    private func attachLayout(_ owner: KeyboardViewController, name: String) {
        let image = UIGraphicsImageRenderer(size: owner.view.bounds.size).image { context in
            owner.view.layer.render(in: context.cgContext)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = "ui4-p2-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

@MainActor
private final class HeightLayoutController: KeyboardViewController {
    // The original #244 transition fixtures intentionally exercise archived growth.
    override var t9PathRowReservation: T9PathRowReservation { .adaptive }
    let heightBudgetFrames = HeightBudgetTestFrames()
    var layoutCount = 0
    override func viewDidLayoutSubviews() {
        layoutCount += 1
        super.viewDidLayoutSubviews()
    }
    override func viewDidLoad() {
        // 只验证布局，不启动 RIME 或共享存储链路。
    }
}

/// 通过真实UIKit生命周期入口注册完成回调；只控制完成时点/取消，不替代高度规则。
@MainActor
private final class HeightRotationCoordinator: NSObject, UIViewControllerTransitionCoordinator {
    var isAnimated: Bool { true }
    var presentationStyle: UIModalPresentationStyle { .none }
    var initiallyInteractive: Bool { false }
    var isInterruptible: Bool { true }
    var isInteractive: Bool { false }
    var isCancelled = false
    var transitionDuration: TimeInterval { 0 }
    var percentComplete: CGFloat { 1 }
    var completionVelocity: CGFloat { 0 }
    var completionCurve: UIView.AnimationCurve { .linear }
    let containerView = UIView()
    var targetTransform: CGAffineTransform { .identity }
    private var completions: [((any UIViewControllerTransitionCoordinatorContext) -> Void)] = []

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? { nil }
    func view(forKey key: UITransitionContextViewKey) -> UIView? { nil }
    func animate(
        alongsideTransition animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
        completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)? = nil
    ) -> Bool {
        if let completion { completions.append(completion) }
        return true
    }
    func animateAlongsideTransition(
        in view: UIView?, animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
        completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)? = nil
    ) -> Bool {
        animate(alongsideTransition: animation, completion: completion)
    }
    func notifyWhenInteractionEnds(_ handler: @escaping (any UIViewControllerTransitionCoordinatorContext) -> Void) {}
    func notifyWhenInteractionChanges(_ handler: @escaping (any UIViewControllerTransitionCoordinatorContext) -> Void) {
    }
    func complete() {
        for completion in completions { completion(self) }
    }
}

@MainActor
private final class HeightControlReceiver: NSObject {
    var count = 0
    @objc func receive() { count += 1 }
}

/// 注入的是帧调度器与单调时钟；emit 实际执行生产 handler，而非手调布局冒充帧。
@MainActor
final class HeightBudgetTestFrames {
    final class Observation: KeyboardHeightBudgetFrameObservation {
        let handler: KeyboardHeightBudgetFrameHandler
        private(set) var invalidated = false
        init(handler: @escaping KeyboardHeightBudgetFrameHandler) { self.handler = handler }
        func invalidate() { invalidated = true }
    }

    var now: CFTimeInterval = 0
    private(set) var observations: [Observation] = []

    func attach(to owner: KeyboardViewController) {
        owner.keyboardHeightBudgetNow = { self.now }
        owner.keyboardHeightBudgetFrameSource = { handler in
            let observation = Observation(handler: handler)
            self.observations.append(observation)
            return observation
        }
    }

    func advance(to timestamp: CFTimeInterval) {
        now = timestamp
        for observation in observations where !observation.invalidated { observation.handler(timestamp) }
    }

    func settle() {
        let start = now
        advance(to: start + 0.02)
        advance(to: start + 0.08)
    }
}
