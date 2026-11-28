import KeyboardCore
import RimeBridge
import UIKit
import os

// MARK: - PB-016 PR-2: quick menu controller wiring
//
// Owns the mutable four-state presentation machine (r3 §3.2/§4.2), the six
// dismiss paths, the entry-visibility hook implementation (r3 §4.1) and the
// four row actions. The layout row rides the existing realized-selection
// pipeline (local preference → refreshCachedSettings → applyRealized… →
// reloadKeyboard); the T/S row rides PR1's RimeSessionCommandGateway with the
// three-state rollback (r3 §5.1). PR1 pipeline/bridge files are untouched.

/// MainActor state box for the quick menu. Swift extensions cannot declare
/// stored properties on `KeyboardViewController`, and the frozen ≤8-file
/// boundary excludes the main class file, so the box rides an associated
/// object; every access is MainActor-confined.
@MainActor
final class QuickMenuStateBox {
    var state: QuickMenuPresentationState = .idle
    var panel: QuickMenuPanelView?
    var scrim: UIView?
    var coveredAccessibilityViews: [(UIView, Bool)] = []
    /// Last known engine simplification value (fallback when no synchronous
    /// engine read-back is available, e.g. thread-affine owner not ready).
    var simplificationEngineValue: Bool?

    private static nonisolated(unsafe) var storageKey: UInt8 = 0

    static func box(for owner: KeyboardViewController) -> QuickMenuStateBox {
        if let existing = objc_getAssociatedObject(owner, &storageKey) as? QuickMenuStateBox {
            return existing
        }
        let box = QuickMenuStateBox()
        objc_setAssociatedObject(owner, &storageKey, box, .OBJC_ASSOCIATION_RETAIN)
        return box
    }
}

/// Shared App Group key mirrored from the main App's `RimeSettingsStore`
/// (rime_simplification: `true` = 简体 output at next deploy).
private let quickMenuRimeSimplificationPreferenceKey = "rime_simplification"

extension KeyboardViewController {
    var quickMenuState: QuickMenuPresentationState {
        QuickMenuStateBox.box(for: self).state
    }

    // MARK: - Entry visibility hook (r3 §4.1: pure recompute, single hook)

    /// Called only from `refreshPasteToolbar(on:)` entry, from the cleanup /
    /// reload direct calls, and from the menu completion paths themselves.
    func refreshQuickMenuEntryVisibility(on targetBar: CandidateBarView? = nil) {
        let bar = targetBar ?? candidateBar as? CandidateBarView
        // Dismiss path #4: composition (or pending symbol) changes collapse the
        // menu non-manually; the menu only lives in an idle-composition state.
        if quickMenuState != .idle, isQuickMenuCompositionActive {
            forceDismissQuickMenu()
        }
        let visible = QuickMenuEntryVisibility.isVisible(
            quickMenuState: quickMenuState,
            isCandidateExpanded: isCandidateExpanded,
            isPinyinPathExpanded: isPinyinPathExpanded,
            isNumberPadShortcutStripActive: isT9NumberPadShortcutStripActive,
            isRecoveryBlocked: shouldBlockT9RecoveryPresentation
        )
        bar?.setUkQuickMenuVisible(visible)
    }

    private var isQuickMenuCompositionActive: Bool {
        let state = controller.state
        return !state.currentComposition.isEmpty || state.insertedPreeditCount > 0
            || state.pendingPunctuation != nil || state.pendingKaomoji != nil
    }

    // MARK: - Present / dismiss

    func toggleQuickMenu() {
        if quickMenuState == .idle {
            presentQuickMenu()
        } else {
            // Dismiss path #1: tapping the entry again while the menu is open.
            forceDismissQuickMenu()
        }
    }

    func presentQuickMenu() {
        guard quickMenuState == .idle else { return }
        // Door guards (r2 §1): no menu over the expanded panels or recovery.
        guard !isCandidateExpanded, !isPinyinPathExpanded, !shouldBlockT9RecoveryPresentation,
            let surface = keyboardSurfaceView, let bar = candidateBar as? CandidateBarView
        else { return }

        let box = QuickMenuStateBox.box(for: self)
        box.state = .menuOpening

        let scrim = UIView()
        scrim.translatesAutoresizingMaskIntoConstraints = false
        scrim.backgroundColor = keyboardSurfaceFillView.backgroundColor ?? .systemBackground
        scrim.accessibilityElementsHidden = true
        let outsideTap = UITapGestureRecognizer()
        outsideTap.cancelsTouchesInView = false
        outsideTap.addTarget(self, action: #selector(quickMenuScrimTapped))
        scrim.addGestureRecognizer(outsideTap)
        view.addSubview(scrim)

        let panel = QuickMenuPanelView(models: quickMenuRowModels())
        panel.onSelectRow = { [weak self] row in
            self?.handleQuickMenuRowTap(row)
        }
        panel.onDismissRequest = { [weak self] in
            // Dismiss path #3: VoiceOver escape.
            self?.forceDismissQuickMenu()
        }
        view.addSubview(panel)

        NSLayoutConstraint.activate([
            scrim.leadingAnchor.constraint(equalTo: surface.leadingAnchor),
            scrim.trailingAnchor.constraint(equalTo: surface.trailingAnchor),
            scrim.topAnchor.constraint(equalTo: bar.bottomAnchor),
            scrim.bottomAnchor.constraint(equalTo: surface.bottomAnchor),

            panel.leadingAnchor.constraint(equalTo: surface.leadingAnchor, constant: 8),
            panel.trailingAnchor.constraint(equalTo: surface.trailingAnchor, constant: -8),
            panel.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 6),
        ])

        box.scrim = scrim
        box.panel = panel
        // VoiceOver: covered rows hide while the compact T9 path bar stays
        // focusable and interactive outside the overlay (r3 §4.3).
        hideCoveredAccessibility(in: rootStack, keeping: t9PinyinPathBarView)
        UIAccessibility.post(notification: .layoutChanged, argument: panel)
    }

    @objc private func quickMenuScrimTapped() {
        // Dismiss path #2: tapping outside the menu.
        forceDismissQuickMenu()
    }

    /// r3 §4.2 forceDismiss table. Idempotent: `.idle` with a completed
    /// teardown is the only no-op; every other state tears the panel down
    /// synchronously and releases to idle (the in-flight layout transaction
    /// releases through its own §3.2 paths, never revived here).
    func forceDismissQuickMenu() {
        let box = QuickMenuStateBox.box(for: self)
        switch box.state {
        case .idle:
            return
        case .menuOpening, .closing, .layoutSwitching:
            teardownQuickMenuPanel()
            box.state = .idle
            refreshQuickMenuEntryVisibility()
            restoreQuickMenuEntryFocus()
        }
    }

    /// Synchronous teardown shared by every dismiss path (r3 §4.2): skips any
    /// remaining animation, removes the panel, restores mask and accessibility
    /// exactly once.
    private func teardownQuickMenuPanel() {
        let box = QuickMenuStateBox.box(for: self)
        restoreCoveredAccessibility()
        box.panel?.removeFromSuperview()
        box.panel = nil
        box.scrim?.removeFromSuperview()
        box.scrim = nil
    }

    // MARK: - VoiceOver coverage (r3 §4.3, +ExpandedCandidatePanel precedent)

    private func hideCoveredAccessibility(in root: UIStackView, keeping pathBar: UIView?) {
        let box = QuickMenuStateBox.box(for: self)
        box.coveredAccessibilityViews = root.arrangedSubviews.compactMap { view in
            guard view !== pathBar else { return nil }
            return (view, view.accessibilityElementsHidden)
        }
        for (view, _) in box.coveredAccessibilityViews {
            view.accessibilityElementsHidden = true
        }
    }

    private func restoreCoveredAccessibility() {
        let box = QuickMenuStateBox.box(for: self)
        for (view, previous) in box.coveredAccessibilityViews {
            view.accessibilityElementsHidden = previous
        }
        box.coveredAccessibilityViews = []
    }

    private func restoreQuickMenuEntryFocus() {
        guard UIAccessibility.isVoiceOverRunning,
            let entryButton = (candidateBar as? CandidateBarView)?.ukQuickMenuEntryButton,
            !entryButton.isHidden
        else { return }
        UIAccessibility.post(notification: .layoutChanged, argument: entryButton)
    }

    // MARK: - Rows

    private func handleQuickMenuRowTap(_ row: QuickMenuRow) {
        switch row {
        case .layoutToggle:
            beginQuickMenuLayoutSwitch()
        case .simplification:
            toggleQuickMenuSimplification()
        case .keyClick:
            toggleQuickMenuFeedbackSwitch(KeyboardFeedbackSettingsKey.keyClickEnabled) { cached in
                cached.cachedKeyClickEnabled
            }
        case .haptic:
            toggleQuickMenuFeedbackSwitch(KeyboardFeedbackSettingsKey.hapticEnabled) { cached in
                cached.cachedHapticEnabled
            }
        }
    }

    /// Local App Group switches (key click / haptic). Write → snapshot → the
    /// snapshot path refreshes chrome through the single visibility hook.
    private func toggleQuickMenuFeedbackSwitch(
        _ key: String,
        readCurrent: (KeyboardViewController) -> Bool
    ) {
        let next = !readCurrent(self)
        sharedDefaults?.set(next, forKey: key)
        refreshCachedSettings(source: "quickMenuFeedbackSwitch")
        redrawQuickMenuPanel()
    }

    private func redrawQuickMenuPanel() {
        QuickMenuStateBox.box(for: self).panel?.update(models: quickMenuRowModels())
    }

    private func quickMenuRowModels() -> [QuickMenuRowModel] {
        let target: KeyboardLayoutStyle = cachedLayoutStyle == .nineKey ? .twentySixKey : .nineKey
        let capability = QuickMenuSimplificationCapability.resolve(schemaID: activeQuickMenuSchemaID())
        let engineValue = currentSimplificationEngineValue(capability: capability)
        let displayText = engineValue.map { value -> String in
            let traditional = capability?.engineValueMeansTraditional(value) ?? value
            return traditional ? "繁" : "简"
        }
        return [
            QuickMenuRowModel(
                row: .layoutToggle,
                title: target == .nineKey ? "切换布局（九键）" : "切换布局（26键）",
                valueText: nil,
                isEnabled: true
            ),
            QuickMenuRowModel(
                row: .simplification,
                title: "简繁切换",
                valueText: displayText,
                // Capability gate (r3 §2.1): unregistered schemas fail closed.
                isEnabled: capability != nil
            ),
            QuickMenuRowModel(
                row: .keyClick,
                title: "按键音",
                valueText: cachedKeyClickEnabled ? "开" : "关",
                isEnabled: true
            ),
            QuickMenuRowModel(
                row: .haptic,
                title: "触感反馈",
                valueText: cachedHapticEnabled ? "开" : "关",
                isEnabled: true
            ),
        ]
    }

    // MARK: - Layout switch (existing realized-selection pipeline)

    private func beginQuickMenuLayoutSwitch() {
        let box = QuickMenuStateBox.box(for: self)
        guard box.state == .menuOpening else { return }
        let target: KeyboardLayoutStyle = cachedLayoutStyle == .nineKey ? .twentySixKey : .nineKey

        box.state = .layoutSwitching
        // layoutSwitching tears only the panel down; the switch transaction
        // releases through the §3.2 paths (reloadKeyboard / cleanup).
        teardownQuickMenuPanel()
        sharedDefaults?.set(target.rawValue, forKey: KeyboardLayoutSettingsKey.layoutStyle)
        // Existing chain: snapshot → resolveRegistered → applyRealized… →
        // reloadKeyboard (which force-dismisses and releases the state).
        refreshCachedSettings(source: "quickMenuLayoutSwitch")
        box.state = .idle
    }

    // MARK: - Simplification (PR1 gateway, r3 §5.1 three-state)

    private func activeQuickMenuSchemaID() -> String {
        let engine = controller.underlyingRimeEngine as? RimeEngineImpl
        return engine?.runtimeSelection?.effectiveSchemaID ?? "rime_ice"
    }

    /// Synchronous engine read-back when an owner can answer without leaving
    /// the MainActor contract; `nil` falls back to the last tracked value.
    private func readBackSimplificationValue(optionName: String) -> Bool? {
        if !controller.isResponsiveRimePipelineEnabled {
            guard case .confirmed(let value) = controller.underlyingRimeEngine?.getOption(optionName)
            else { return nil }
            return value
        }
        guard let snapshot = readBackSimplificationSnapshot(optionName: optionName),
            case .confirmed(let value) = snapshot.optionResult
        else { return nil }
        return value
    }

    private func currentSimplificationEngineValue(capability: QuickMenuSimplificationCapability?) -> Bool? {
        guard let capability else { return nil }
        if let value = readBackSimplificationValue(optionName: capability.optionName) {
            QuickMenuStateBox.box(for: self).simplificationEngineValue = value
            return value
        }
        return QuickMenuStateBox.box(for: self).simplificationEngineValue
    }

    private func toggleQuickMenuSimplification() {
        guard let capability = QuickMenuSimplificationCapability.resolve(schemaID: activeQuickMenuSchemaID())
        else { return }
        let previous = currentSimplificationEngineValue(capability: capability) ?? false
        let target = !previous

        let outcome = dispatchSimplificationOption(
            capability: capability, value: target, allowRecoveryRetry: true)
        applySimplificationOutcome(outcome, capability: capability, previousEngineValue: previous)
    }

    /// Dispatches the option write through the PR1 gateway. Fail-closed answers
    /// synchronously; a gate-on queue is confirmed by an ordered get read-back
    /// (r3 §5.1: the read-back value is authoritative).
    private func dispatchSimplificationOption(
        capability: QuickMenuSimplificationCapability,
        value: Bool,
        allowRecoveryRetry: Bool
    ) -> RimeOptionResult {
        guard let gateway = controller.quickMenuSessionCommandConsumer as? RimeSessionCommandGateway
        else { return .bridgeError }
        switch gateway.setOption(name: capability.optionName, value: value) {
        case .option(let result):
            if case .sessionInvalid = result, allowRecoveryRetry {
                // r3 §5.1: one recoverSession retry, never a loop.
                controller.underlyingRimeEngine?.recoverSession()
                return dispatchSimplificationOption(
                    capability: capability, value: value, allowRecoveryRetry: false)
            }
            return result
        case .queued:
            guard let snapshot = readBackSimplificationSnapshot(optionName: capability.optionName),
                let optionResult = snapshot.optionResult
            else { return .bridgeError }
            if case .sessionInvalid = optionResult, allowRecoveryRetry {
                controller.responsiveRimeCoordinator?.performOrderedNow(
                    .recoverSession, actionIDPrefix: "command-option")
                return dispatchSimplificationOption(
                    capability: capability, value: value, allowRecoveryRetry: false)
            }
            return optionResult
        case .unavailable, .schema:
            return .bridgeError
        }
    }

    private func readBackSimplificationSnapshot(optionName: String) -> ResponsiveRimeSnapshot? {
        // The two owners are distinct classes, so the dispatch is split per
        // branch (the TypoCorrection sidecar-route precedent) instead of a
        // ternary, which has no common type.
        if controller.isThreadAffineRimeOwnerEnabled {
            return controller.threadAffineRimeCoordinator?.performOrderedNow(
                .getOption(optionName), actionIDPrefix: "command-option")
        }
        return controller.responsiveRimeCoordinator?.performOrderedNow(
            .getOption(optionName), actionIDPrefix: "command-option")
    }

    /// Three-state landing (r3 §5.1). Confirmed commits and writes the shared
    /// preference back so the next deploy keeps the choice; a real `false`
    /// value is the legitimate simplified result, not a failure. Failure rolls
    /// the row back, announces, and never writes the preference.
    func applySimplificationOutcome(
        _ outcome: RimeOptionResult,
        capability: QuickMenuSimplificationCapability,
        previousEngineValue: Bool
    ) {
        let resolution = QuickMenuSimplificationTransaction.resolve(
            outcome: outcome, previousEngineValue: previousEngineValue)
        let box = QuickMenuStateBox.box(for: self)
        switch resolution {
        case .confirmed(let engineValue):
            box.simplificationEngineValue = engineValue
            if resolution.shouldWritePreferenceBack {
                let traditional = capability.engineValueMeansTraditional(engineValue)
                sharedDefaults?.set(!traditional, forKey: quickMenuRimeSimplificationPreferenceKey)
            }
            replayQuickMenuCompositionIfFailClosed(outcome: outcome)
        case .rolledBack:
            box.simplificationEngineValue = previousEngineValue
            UIAccessibility.post(notification: .announcement, argument: "切换未生效")
        }
        redrawQuickMenuPanel()
    }

    /// Gate-on owners replay the live composition inside `setOption` handling
    /// (PR1); the fail-closed direct-held engine needs the explicit replay.
    private func replayQuickMenuCompositionIfFailClosed(outcome: RimeOptionResult) {
        guard case .confirmed = outcome, !controller.isResponsiveRimePipelineEnabled else { return }
        let effects = controller.replayCompositionAfterQuickMenuOptionChange()
        if !effects.isEmpty {
            syncUI(with: effects)
        }
    }
}

// MARK: - Three-state policy namespace
//
// `QuickMenuSimplificationTransaction` keeps the controller-side call site
// speaking the frozen contract vocabulary (resolve → confirmed / rolledBack);
// the pure implementation is `QuickMenuSimplificationResolution` in
// QuickMenuPanelView.swift, where it is unit-tested against the r3 §5.1 table.
enum QuickMenuSimplificationTransaction {
    static func resolve(
        outcome: RimeOptionResult,
        previousEngineValue: Bool
    ) -> QuickMenuSimplificationResolution {
        QuickMenuSimplificationResolution.resolve(
            outcome: outcome, previousEngineValue: previousEngineValue)
    }
}
