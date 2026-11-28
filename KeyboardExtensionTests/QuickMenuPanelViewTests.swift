import KeyboardCore
import UIKit
import XCTest

/// PB-016 PR-2: quick-menu presentation model and pure view behavior.
///
/// The panel view source is compiled into this target (project exception,
/// PR1 pattern), so these are real behavior tests over the pure row model,
/// the four-state machine, the entry-visibility resolver, the T/S
/// capability gate and the three-state rollback policy (r3 §2.1/§3.2/§4.2/§5.1).
nonisolated
final class QuickMenuPanelViewTests: XCTestCase {
    // MARK: - Row model (design r1 §3.2 minimal set: exactly four rows)

    func testPanelRowModelContainsExactlyFourRowsInFrozenOrder() {
        XCTAssertEqual(QuickMenuRow.allCases, [.layoutToggle, .simplification, .keyClick, .haptic])
    }

    @MainActor
    func testPanelViewBuildsAccessibilityElementsInRowOrder() {
        let panel = QuickMenuPanelView(models: QuickMenuPanelViewTests.makeModels())
        panel.layoutIfNeeded()

        let elements = panel.accessibilityElements?.compactMap { $0 as? UIView } ?? []
        XCTAssertEqual(elements.count, 4, "each menu row is one VoiceOver element, in row order")
        XCTAssertEqual(elements.compactMap(\.accessibilityIdentifier), [
            "quickMenu.row.layoutToggle",
            "quickMenu.row.simplification",
            "quickMenu.row.keyClick",
            "quickMenu.row.haptic",
        ])
        XCTAssertFalse(panel.isAccessibilityElement, "the container itself must not steal focus")
    }

    @MainActor
    func testPanelSupportsVoiceOverEscapeAsDismissPath3() {
        let panel = QuickMenuPanelView(models: QuickMenuPanelViewTests.makeModels())
        var escapeCount = 0
        panel.onDismissRequest = { escapeCount += 1 }

        XCTAssertTrue(panel.accessibilityPerformEscape(), "escape must be consumed as a dismiss")
        XCTAssertEqual(escapeCount, 1, "escape must route to the controller dismiss path")
    }

    @MainActor
    func testDisabledRowIsNotTappableAndReadsAsDisabled() {
        var models = QuickMenuPanelViewTests.makeModels()
        models[1] = QuickMenuRowModel(
            row: .simplification, title: models[1].title, valueText: models[1].valueText, isEnabled: false)
        let panel = QuickMenuPanelView(models: models)
        panel.layoutIfNeeded()

        guard case let rows = panel.accessibilityElements?.compactMap({ $0 as? UIControl }) ?? [],
            rows.count == 4
        else { return XCTFail("panel must expose its four rows") }
        XCTAssertFalse(rows[1].isEnabled, "capability-gated row must be disabled (ambiguity fail-closed)")
        XCTAssertEqual(rows[1].accessibilityValue, nil, "disabled row reads no state value")
    }

    // MARK: - Four-state machine (r3 §4.2 forceDismiss table)

    func testForceDismissOnIdleIsTheOnlyNoOp() {
        XCTAssertEqual(QuickMenuPresentationState.idle.forceDismissOutcome, .none)
    }

    func testForceDismissOnOpeningAndClosingIsSynchronousTeardown() {
        XCTAssertEqual(QuickMenuPresentationState.menuOpening.forceDismissOutcome, .teardownPanel)
        XCTAssertEqual(QuickMenuPresentationState.closing.forceDismissOutcome, .teardownPanel)
    }

    func testForceDismissOnLayoutSwitchingTearsPanelDownAndReleasesState() {
        XCTAssertEqual(QuickMenuPresentationState.layoutSwitching.forceDismissOutcome, .teardownPanel)
    }

    func testPanelPresentedOnlyInOpeningAndClosingStates() {
        XCTAssertFalse(QuickMenuPresentationState.idle.isPanelPresented)
        XCTAssertTrue(QuickMenuPresentationState.menuOpening.isPanelPresented)
        XCTAssertTrue(QuickMenuPresentationState.closing.isPanelPresented)
        XCTAssertFalse(QuickMenuPresentationState.layoutSwitching.isPanelPresented)
    }

    // MARK: - Entry visibility (r3 §4.1 pure recompute, S1 early-return branch)

    func testEntryVisibleInIdleWithoutMutexStates() {
        XCTAssertTrue(Self.entryVisible(state: .idle))
    }

    func testEntryStaysVisibleWhileMenuIsOpenForToggleDismiss() {
        XCTAssertTrue(Self.entryVisible(state: .menuOpening), "tap-UK-again is dismiss path #1")
    }

    func testEntryHiddenDuringClosingAndLayoutSwitching() {
        XCTAssertFalse(Self.entryVisible(state: .closing))
        XCTAssertFalse(Self.entryVisible(state: .layoutSwitching))
    }

    func testEntryHiddenUnderEveryMutexState() {
        XCTAssertTrue(Self.entryVisible(state: .idle))
        XCTAssertFalse(
            Self.entryVisible(state: .idle, isCandidateExpanded: true), "candidate panel is mutually exclusive")
        XCTAssertFalse(
            Self.entryVisible(state: .idle, isPinyinPathExpanded: true), "expanded path panel forbids the menu")
        XCTAssertFalse(
            Self.entryVisible(state: .idle, isNumberPadShortcutStripActive: true),
            "number-pad shortcut strip (early-return branch) must still hide the entry")
        XCTAssertFalse(
            Self.entryVisible(state: .idle, isRecoveryBlocked: true), "input recovery blocks the menu")
    }

    private static func entryVisible(
        state: QuickMenuPresentationState,
        isCandidateExpanded: Bool = false,
        isPinyinPathExpanded: Bool = false,
        isNumberPadShortcutStripActive: Bool = false,
        isRecoveryBlocked: Bool = false
    ) -> Bool {
        QuickMenuEntryVisibility.isVisible(
            quickMenuState: state,
            isCandidateExpanded: isCandidateExpanded,
            isPinyinPathExpanded: isPinyinPathExpanded,
            isNumberPadShortcutStripActive: isNumberPadShortcutStripActive,
            isRecoveryBlocked: isRecoveryBlocked
        )
    }

    // MARK: - T/S capability gate (r3 §2.1: ice/luna mapping, ambiguity disabled)

    func testSimplificationCapabilityForIceMapsTraditionalizationStates() {
        let capability = QuickMenuSimplificationCapability.resolve(schemaID: "rime_ice")
        XCTAssertEqual(capability?.optionName, "traditionalization")
        XCTAssertEqual(capability?.engineValueMeansTraditional, true, "ice: value true → 繁")
    }

    func testSimplificationCapabilityForLunaMapsSimplificationStates() {
        let capability = QuickMenuSimplificationCapability.resolve(schemaID: "luna_pinyin")
        XCTAssertEqual(capability?.optionName, "simplification")
        XCTAssertEqual(capability?.engineValueMeansTraditional, false, "luna: value true → 简")
    }

    func testSimplificationCapabilityNormalizesNineKeyBindingToIceFamily() {
        XCTAssertEqual(
            QuickMenuSimplificationCapability.resolve(schemaID: "t9")?.optionName, "traditionalization",
            "nine-key fog binding resolves to the rime_ice family without hardcoding at call sites")
    }

    func testSimplificationCapabilityIsDisabledForUnregisteredSchemas() {
        XCTAssertNil(QuickMenuSimplificationCapability.resolve(schemaID: "wanxiang"))
        // Empty schema IDs normalize to the builtin luna fallback (shared
        // `RimeSchemeCapabilityMatrix` semantics), never to a disabled row.
        XCTAssertEqual(
            QuickMenuSimplificationCapability.resolve(schemaID: "")?.optionName, "simplification")
    }

    // MARK: - Three-state rollback policy (r3 §5.1, R2)

    func testConfirmedValueCommitsAndAllowsPreferenceWriteBack() {
        let resolution = QuickMenuSimplificationResolution.resolve(
            outcome: .confirmed(true), previousEngineValue: false)
        XCTAssertEqual(resolution, .confirmed(engineValue: true))
        XCTAssertTrue(resolution.shouldWritePreferenceBack)
        XCTAssertFalse(resolution.shouldRollBackRowValue)
    }

    func testConfirmedFalseIsALegalTrueValueNotAFailure() {
        // 简 direction: `confirmed(false)` is the legitimate simplified result
        // (r3 §5.1 case 2), not a rollback.
        let resolution = QuickMenuSimplificationResolution.resolve(
            outcome: .confirmed(false), previousEngineValue: true)
        XCTAssertEqual(resolution, .confirmed(engineValue: false))
        XCTAssertTrue(resolution.shouldWritePreferenceBack)
        XCTAssertFalse(resolution.shouldRollBackRowValue)
    }

    func testSessionInvalidRollsBackWithoutPreferenceWriteBack() {
        let resolution = QuickMenuSimplificationResolution.resolve(
            outcome: .sessionInvalid, previousEngineValue: true)
        XCTAssertEqual(resolution, .rolledBack(previousEngineValue: true))
        XCTAssertFalse(resolution.shouldWritePreferenceBack, "failure must never write the preference back")
        XCTAssertTrue(resolution.shouldRollBackRowValue)
    }

    func testBridgeErrorRollsBackWithoutPreferenceWriteBack() {
        let resolution = QuickMenuSimplificationResolution.resolve(
            outcome: .bridgeError, previousEngineValue: false)
        XCTAssertEqual(resolution, .rolledBack(previousEngineValue: false))
        XCTAssertFalse(resolution.shouldWritePreferenceBack)
        XCTAssertTrue(resolution.shouldRollBackRowValue)
    }

    // MARK: Fixtures

    private static func makeModels() -> [QuickMenuRowModel] {
        QuickMenuRow.allCases.map { row in
            QuickMenuRowModel(row: row, title: row.title, valueText: "开", isEnabled: true)
        }
    }
}
