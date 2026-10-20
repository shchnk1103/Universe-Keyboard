import UIKit
import XCTest

@testable import KeyboardCore

/// Compiles the original CandidatePaging.swift against a test-only owner.
/// This exercises the consumer methods, not the real Extension controller or views.
nonisolated final class CandidatePagingConsumerFixtureTests: XCTestCase {
    @MainActor
    func testAffineMissingOriginDoesNotReadOrConsume() {
        let owner = KeyboardViewController()
        let engine = BoundPagingWindowEngine()
        owner.controller.rimeEngine = engine
        owner.loadMoreCandidates(mode: .bar)
        XCTAssertEqual(engine.readCount, 0)
        XCTAssertEqual(engine.consumeCount, 0)
        XCTAssertTrue(owner.accumulatedCandidates.isEmpty)
        XCTAssertFalse(owner.isLoadingMoreCandidates)
    }

    @MainActor
    func testAffineConsumptionRejectionDoesNotAppendOrEndPaging() {
        let owner = KeyboardViewController()
        let engine = BoundPagingWindowEngine()
        engine.decision = .rejected(.stale)
        owner.controller.rimeEngine = engine
        owner.candidateSnapshotOrigin = engine.origin
        owner.loadMoreCandidates(mode: .bar)
        XCTAssertEqual(engine.readCount, 1)
        XCTAssertEqual(engine.consumeCount, 1)
        XCTAssertTrue(owner.accumulatedCandidates.isEmpty)
        XCTAssertEqual(owner.nextCandidateGlobalIndex, 0)
        XCTAssertTrue(owner.hasMoreCandidates, "Rejected read is not a successful last page")
        XCTAssertFalse(owner.isLoadingMoreCandidates)
        XCTAssertTrue(owner.barAppends.isEmpty)
    }

    @MainActor
    func testAffineAcceptedWindowCommitsRealStoreAndRetainsOriginOnEveryItem() {
        let owner = KeyboardViewController()
        let engine = BoundPagingWindowEngine()
        owner.controller.rimeEngine = engine
        owner.candidateSnapshotOrigin = engine.origin
        owner.loadMoreCandidates(mode: .bar)
        XCTAssertEqual(engine.readCount, 1)
        XCTAssertEqual(engine.consumeCount, 1)
        XCTAssertEqual(owner.accumulatedCandidates.count, 2)
        XCTAssertTrue(
            owner.accumulatedCandidates.allSatisfy { $0.selectionReference?.candidateOrigin == engine.origin })
        XCTAssertEqual(owner.candidatePresentationStore.page.items, owner.accumulatedCandidates)
        XCTAssertEqual(owner.nextCandidateGlobalIndex, 2)
        XCTAssertFalse(owner.hasMoreCandidates)
        XCTAssertEqual(owner.barAppends, [2])
    }

    @MainActor
    func testCheckpointFailureBlocksProductionPrefetchWithoutR174() {
        for mode in [CandidatePrefetchMode.bar, .expanded] {
            let owner = KeyboardViewController()
            let engine = PagingWindowEngine()
            owner.controller.rimeEngine = engine
            owner.isCandidateExpanded = mode == .expanded
            owner.controller.partialCommitFailureRecovery = .init(ownerID: UUID(), editingGeneration: 0)
            XCTAssertFalse(owner.controller.isT9InputRecoveryPending)
            owner.loadMoreCandidates(mode: mode)
            XCTAssertEqual(engine.readCount, 0)
            XCTAssertTrue(owner.accumulatedCandidates.isEmpty)
            XCTAssertFalse(owner.isLoadingMoreCandidates)
            XCTAssertTrue(owner.controller.isCompositionInputRecoveryPending)
        }
    }

    @MainActor
    func testGenerationChangeDuringReadDiscardsWindowAndAllowsRetry() {
        assertStaleWindowIsDiscarded { state in state.generation += 1 }
    }

    @MainActor
    func testRawInputChangeDuringReadDiscardsWindowAndAllowsRetry() {
        assertStaleWindowIsDiscarded { state in state.rawInput = "changed" }
    }

    @MainActor
    func testSnapshotRevisionChangeDuringReadDiscardsWindowAndAllowsRetry() {
        assertStaleWindowIsDiscarded { state in state.revision += 1 }
    }

    @MainActor
    func testCoreRevisionChangeDuringReadDiscardsWindowAndAllowsRetry() {
        // Swap the exposed real Core snapshot at the read boundary. This is a
        // controlled consumer input, not proof of a natural Core transition.
        let replacement = KeyboardController(state: KeyboardState(compositionRevision: 1))
        assertStaleWindowIsDiscarded { state in state.controller = replacement }
    }

    @MainActor
    func testBarWindowDeduplicatesGlobalIndices() {
        assertValidWindow(mode: .bar)
    }

    @MainActor
    func testExpandedWindowDeduplicatesGlobalIndices() {
        assertValidWindow(mode: .expanded)
    }

    @MainActor
    func testScheduledWindowRejectsChangedGenerationAndAllowsNextRequest() async {
        await assertScheduledRequestIsRejected(reason: .generation)
    }

    @MainActor
    func testScheduledWindowRejectsChangedSerialAndAllowsNextRequest() async {
        await assertScheduledRequestIsRejected(reason: .serial)
    }

    @MainActor
    func testScheduledWindowRejectsChangedModeAndAllowsNextRequest() async {
        await assertScheduledRequestIsRejected(reason: .mode)
    }

    @MainActor
    func testScheduledWindowRejectsRecoveryStateAndAllowsNextRequest() async {
        await assertScheduledRequestIsRejected(reason: .recovery)
    }

    @MainActor
    func testRecoveryPreventsDirectWindowRead() {
        for mode in [CandidatePrefetchMode.bar, .expanded] {
            let owner = KeyboardViewController()
            let engine = PagingWindowEngine()
            owner.controller.rimeEngine = engine
            owner.isCandidateExpanded = mode == .expanded
            freezeForRecovery(owner.controller)
            owner.loadMoreCandidates(mode: mode)
            XCTAssertEqual(engine.readCount, 0)
            XCTAssertTrue(owner.accumulatedCandidates.isEmpty)
            XCTAssertFalse(owner.isLoadingMoreCandidates)
            owner.controller.t9ExactRetypeRecovery = T9ExactRetypeRecovery()
            owner.loadMoreCandidates(mode: mode)
            XCTAssertEqual(engine.readCount, 1)
            assertAcceptedWindow(owner, mode: mode)
        }
    }

    @MainActor
    func testRecoveryAtWindowReturnDiscardsCandidates() {
        for mode in [CandidatePrefetchMode.bar, .expanded] {
            let owner = KeyboardViewController()
            let engine = PagingWindowEngine()
            owner.controller.rimeEngine = engine
            owner.isCandidateExpanded = mode == .expanded
            engine.beforeReturn = { self.freezeForRecovery(owner.controller) }
            owner.loadMoreCandidates(mode: mode)
            XCTAssertEqual(engine.readCount, 1)
            XCTAssertTrue(owner.accumulatedCandidates.isEmpty)
            XCTAssertTrue(owner.barAppends.isEmpty)
            XCTAssertTrue(owner.expandedAppends.isEmpty)
            XCTAssertEqual(owner.nextCandidateGlobalIndex, 0)
            XCTAssertFalse(owner.isLoadingMoreCandidates)
            owner.controller.t9ExactRetypeRecovery = T9ExactRetypeRecovery()
            owner.loadMoreCandidates(mode: mode)
            XCTAssertEqual(engine.readCount, 2)
            assertAcceptedWindow(owner, mode: mode)
        }
    }

    /// Controlled pure-policy state, not evidence of a natural Extension fault.
    @MainActor
    private func freezeForRecovery(_ controller: KeyboardController) {
        controller.t9ExactRetypeRecovery.freeze(
            verifiedDigits: "94624",
            namespace: .init(ownerID: UUID(), sessionEpoch: 1, editingGeneration: 0),
            terminal: false)
    }

    private enum ScheduledInvalidation {
        case generation
        case serial
        case mode
        case recovery
    }

    @MainActor
    private func assertScheduledRequestIsRejected(reason: ScheduledInvalidation) async {
        for mode in [CandidatePrefetchMode.bar, .expanded] {
            let owner = KeyboardViewController()
            let engine = PagingWindowEngine()
            owner.controller.rimeEngine = engine
            owner.isCandidateExpanded = mode == .expanded
            let forbiddenRead = XCTestExpectation(description: "invalidated scheduled request must not read")
            forbiddenRead.isInverted = true
            engine.onRead = { forbiddenRead.fulfill() }
            owner.scheduleCandidatePrefetch(mode: mode)

            // Change only the selected input after scheduling; the production
            // method, including its timer/run-loop/MainActor hop, remains intact.
            let scheduledSerial = owner.candidatePrefetchRequestSerial
            let scheduledGeneration = owner.candidateSnapshotGeneration
            switch reason {
            case .generation:
                owner.candidateSnapshotGeneration += 1
                XCTAssertEqual(owner.candidatePrefetchRequestSerial, scheduledSerial)
            case .serial:
                owner.candidatePrefetchRequestSerial += 1
                XCTAssertEqual(owner.candidateSnapshotGeneration, scheduledGeneration)
            case .mode:
                owner.isCandidateExpanded.toggle()
                XCTAssertEqual(owner.candidatePrefetchRequestSerial, scheduledSerial)
                XCTAssertEqual(owner.candidateSnapshotGeneration, scheduledGeneration)
            case .recovery:
                freezeForRecovery(owner.controller)
                XCTAssertEqual(owner.candidatePrefetchRequestSerial, scheduledSerial)
                XCTAssertEqual(owner.candidateSnapshotGeneration, scheduledGeneration)
            }

            // This is a bounded observation, not a guarantee about every possible
            // scheduler delay. The following valid request also proves progress.
            let rejectedResult = await XCTWaiter.fulfillment(of: [forbiddenRead], timeout: 0.4)
            XCTAssertEqual(rejectedResult, .completed)
            XCTAssertEqual(engine.readCount, 0)
            XCTAssertTrue(owner.accumulatedCandidates.isEmpty)
            XCTAssertTrue(owner.barAppends.isEmpty)
            XCTAssertTrue(owner.expandedAppends.isEmpty)
            XCTAssertEqual(owner.nextCandidateGlobalIndex, 0)
            XCTAssertTrue(owner.hasMoreCandidates)
            XCTAssertFalse(owner.isLoadingMoreCandidates)
            XCTAssertNil(owner.deferredCandidatePrefetchMode)

            owner.controller.t9ExactRetypeRecovery = T9ExactRetypeRecovery()
            owner.isCandidateExpanded = mode == .expanded
            let validRead = XCTestExpectation(description: "subsequent scheduled request reads a valid window")
            engine.onRead = { validRead.fulfill() }
            owner.scheduleCandidatePrefetch(mode: mode)
            let acceptedResult = await XCTWaiter.fulfillment(of: [validRead], timeout: 2)
            XCTAssertEqual(acceptedResult, .completed)
            engine.onRead = nil
            XCTAssertEqual(engine.readCount, 1)
            assertAcceptedWindow(owner, mode: mode)
        }
    }

    @MainActor
    private func assertStaleWindowIsDiscarded(
        invalidate: @escaping (PagingSnapshotFixture) -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for mode in [CandidatePrefetchMode.bar, .expanded] {
            let owner = KeyboardViewController()
            let engine = PagingWindowEngine()
            owner.controller.rimeEngine = engine
            owner.isCandidateExpanded = mode == .expanded
            let snapshot = owner.snapshot
            engine.beforeReturn = { invalidate(snapshot) }

            owner.loadMoreCandidates(mode: mode)

            XCTAssertEqual(engine.readCount, 1, file: file, line: line)
            XCTAssertTrue(owner.accumulatedCandidates.isEmpty, file: file, line: line)
            XCTAssertEqual(owner.nextCandidateGlobalIndex, 0, file: file, line: line)
            XCTAssertTrue(owner.hasMoreCandidates, file: file, line: line)
            XCTAssertEqual(owner.candidatePageDepth, 0, file: file, line: line)
            XCTAssertTrue(owner.barAppends.isEmpty, file: file, line: line)
            XCTAssertTrue(owner.expandedAppends.isEmpty, file: file, line: line)
            XCTAssertFalse(owner.isLoadingMoreCandidates, file: file, line: line)

            // A valid subsequent response must work, not remain permanently fenced.
            owner.controller.rimeEngine = engine
            owner.candidateSnapshotCompositionRevision = owner.controller.state.compositionRevision
            owner.loadMoreCandidates(mode: mode)
            XCTAssertEqual(engine.readCount, 2, file: file, line: line)
            assertAcceptedWindow(owner, mode: mode, file: file, line: line)
        }
    }

    @MainActor
    private func assertValidWindow(mode: CandidatePrefetchMode) {
        let owner = KeyboardViewController()
        let engine = PagingWindowEngine()
        owner.controller.rimeEngine = engine
        owner.isCandidateExpanded = mode == .expanded
        owner.loadMoreCandidates(mode: mode)
        XCTAssertEqual(engine.readCount, 1)
        assertAcceptedWindow(owner, mode: mode)
    }

    @MainActor
    private func assertAcceptedWindow(
        _ owner: KeyboardViewController,
        mode: CandidatePrefetchMode,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(owner.accumulatedCandidates.map(\.title), ["甲", "乙"], file: file, line: line)
        XCTAssertEqual(
            owner.accumulatedCandidates.compactMap { $0.selectionReference?.globalIndex },
            [0, 1], file: file, line: line
        )
        XCTAssertEqual(owner.nextCandidateGlobalIndex, 2, file: file, line: line)
        XCTAssertFalse(owner.hasMoreCandidates, file: file, line: line)
        XCTAssertFalse(owner.isLoadingMoreCandidates, file: file, line: line)
        XCTAssertEqual(owner.barAppends, mode == .bar ? [2] : [], file: file, line: line)
        XCTAssertEqual(owner.expandedAppends, mode == .expanded ? [2] : [], file: file, line: line)
    }
}

/// Only fixture storage: no generation/revision guards or pagination logic.
/// The synchronous scripted engine mutates it before returning its window.
nonisolated final class PagingSnapshotFixture {
    var generation = 0
    var rawInput: String? = "synthetic"
    var revision: UInt64 = 0
    var controller: KeyboardController

    init(controller: KeyboardController) {
        self.controller = controller
    }
}

enum CandidatePrefetchMode {
    case bar
    case expanded
}

@MainActor
final class KeyboardViewController: UIViewController {
    let snapshot = PagingSnapshotFixture(controller: KeyboardController())
    var controller: KeyboardController { snapshot.controller }
    var candidateSnapshotGeneration: Int {
        get { snapshot.generation }
        set { snapshot.generation = newValue }
    }
    var candidateSnapshotRawInput: String? {
        get { snapshot.rawInput }
        set { snapshot.rawInput = newValue }
    }
    var candidateSnapshotCompositionRevision: UInt64 {
        get { snapshot.revision }
        set { snapshot.revision = newValue }
    }
    let pinyinPathCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let candidateScrollView = UIScrollView()
    let expandedPanelScrollView = UIScrollView()
    var isCandidateScrollInteracting = false
    var isPinyinPathExpanded = false
    var pinyinPathHasMore = false
    var isCandidateExpanded = false
    let candidatePresentationStore: RimeCandidatePresentationStore = {
        let store = RimeCandidatePresentationStore()
        store.page.hasMore = true
        return store
    }()
    var candidateSnapshotOrigin: RimeOutputOrigin?
    var hasMoreCandidates: Bool {
        get { candidatePresentationStore.page.hasMore }
        set { candidatePresentationStore.page.hasMore = newValue }
    }
    var isLoadingMoreCandidates = false
    var accumulatedCandidates: [CandidateItem] {
        get { candidatePresentationStore.page.items }
        set { candidatePresentationStore.page.items = newValue }
        _modify { yield &candidatePresentationStore.page.items }
    }
    var candidatePrefetchRequestSerial = 0
    var deferredCandidatePrefetchMode: CandidatePrefetchMode?
    var candidatePrefetchMode: CandidatePrefetchMode = .bar
    var lastT9DigitKeyTime: CFTimeInterval?
    var nextCandidateGlobalIndex: Int {
        get { candidatePresentationStore.page.nextIndex }
        set { candidatePresentationStore.page.nextIndex = newValue }
    }
    var candidatePageDepth: Int {
        get { candidatePresentationStore.page.depth }
        set { candidatePresentationStore.page.depth = newValue }
    }
    var barAppends: [Int] = []
    var expandedAppends: [Int] = []
    var pinyinPathLoads = 0

    // Dependencies for the production recovery-UI adapter. These record
    // external panel/selection callbacks, not real Extension lifecycle.
    var wasT9RecoveryPresentationBlocked = false
    var candidateCellSizeCache: [String: CGSize] = [:]
    var candidateBar: UIView?
    var candidateCollectionView: UICollectionView?
    var expandedCandidateCollectionView: UICollectionView?
    var t9PinyinPathBarView: UIView?
    var t9SpaceButton: UIButton?
    var t9SelectPinyinButton: UIButton?
    var returnButton: UIButton?
    var candidatePanelDismissals = 0
    var pathPanelDismissals = 0
    var selectionAvailabilityRefreshes = 0
    var selectionShouldBeAvailable = true

    func dismissExpandedCandidatePanel(animated: Bool) {
        candidatePanelDismissals += 1
        isCandidateExpanded = false
    }
    func dismissPinyinPathExpandedPanel(animated: Bool) {
        pathPanelDismissals += 1
        isPinyinPathExpanded = false
    }
    // The real Controller layout is covered by KeyboardLayoutIntegrationTests.
    func refreshT9PinyinPathBarVisibility() {}

    func updateSelectPinyinButtonAvailability() {
        selectionAvailabilityRefreshes += 1
        t9SelectPinyinButton?.isEnabled = selectionShouldBeAvailable
        t9SelectPinyinButton?.alpha = selectionShouldBeAvailable ? 1 : 0.45
    }

    func loadMorePinyinPathsIfNeeded() { pinyinPathLoads += 1 }
    func appendToCandidateBar(insertedCount: Int) { barAppends.append(insertedCount) }
    func appendToExpandedCandidatePanel(insertedCount: Int) { expandedAppends.append(insertedCount) }
}

nonisolated private final class PagingWindowEngine: RimeEngine {
    var beforeReturn: (() -> Void)?
    var onRead: (() -> Void)?
    private(set) var readCount = 0
    var runtimeSelection: RimeRuntimeSelection? { nil }
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?

    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        readCount += 1
        onRead?()
        let callback = beforeReturn
        beforeReturn = nil
        callback?()
        return RimeCandidateWindow(
            candidates: [
                RimeCandidate(text: "甲", globalIndex: 0),
                RimeCandidate(text: "乙", globalIndex: 1),
                RimeCandidate(text: "重复乙", globalIndex: 1),
            ], startIndex: 0, nextIndex: 2, hasMoreCandidates: false
        )
    }

    func processKey(_ key: String) -> RimeOutput { RimeOutput() }
    func selectCandidate(at index: Int) -> RimeOutput { RimeOutput() }
    func selectCandidate(globalIndex index: Int) -> RimeOutput { RimeOutput() }
    func deleteBackward() -> RimeOutput { RimeOutput() }
    func replaceInput(_ input: String) -> RimeOutput { RimeOutput() }
    func resetSession() {}
    func recoverSession() {}
    func suspendForVisibilityChange() {}
    func resumeAfterVisibilityChange() {}
    func isComposing() -> Bool { false }
    func pageUp() -> RimeOutput { RimeOutput() }
    func pageDown() -> RimeOutput { RimeOutput() }
}

// Scripted capability only tests the production consumer's routing/commit boundary.
// The real owner authority/settlement race is covered separately in Core tests.
nonisolated private final class BoundPagingWindowEngine: RimeEngine, RimeCandidateAuthorityProviding {
    let origin = RimeOutputOrigin(ownerID: UUID(), sessionEpoch: 1, revision: 1)
    let delegate = PagingWindowEngine()
    var decision: RimeCandidateConsumptionDecision = .accepted
    private(set) var readCount = 0
    private(set) var consumeCount = 0
    var runtimeSelection: RimeRuntimeSelection? { nil }
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)?

    func readCandidateWindow(origin: RimeOutputOrigin, from: Int, limit: Int) -> RimeCandidateWindowReadResult {
        readCount += 1
        guard origin == self.origin else { return .rejected(.stale) }
        return .available(
            .init(
                window: delegate.candidateWindow(from: from, limit: limit),
                permit: .init(origin: origin, version: 1)))
    }
    @MainActor
    func consumeCandidateWindow(
        _ window: RimeBoundCandidateWindow, prepared: RimeCandidatePresentationPage,
        into store: RimeCandidatePresentationStore
    ) -> RimeCandidateConsumptionDecision {
        consumeCount += 1
        if decision == .accepted { store.page = prepared }
        return decision
    }
    func selectCandidate(origin: RimeOutputOrigin, pageIndex: Int, globalIndex: Int?)
        -> RimeBoundCandidateSelectionResult
    {
        .rejected(.stale)
    }
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        delegate.candidateWindow(from: globalIndex, limit: limit)
    }
    func processKey(_ key: String) -> RimeOutput { RimeOutput() }
    func selectCandidate(at index: Int) -> RimeOutput { RimeOutput() }
    func selectCandidate(globalIndex index: Int) -> RimeOutput { RimeOutput() }
    func deleteBackward() -> RimeOutput { RimeOutput() }
    func replaceInput(_ input: String) -> RimeOutput { RimeOutput() }
    func resetSession() {}
    func recoverSession() {}
    func suspendForVisibilityChange() {}
    func resumeAfterVisibilityChange() {}
    func isComposing() -> Bool { false }
    func pageUp() -> RimeOutput { RimeOutput() }
    func pageDown() -> RimeOutput { RimeOutput() }
}
