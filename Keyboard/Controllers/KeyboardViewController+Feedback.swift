import CoreFoundation
import Foundation
import KeyboardCore
import RimeBridge
import UIKit

// MARK: - PB-001 Option A: audio/haptics sync hygiene

/// Injectable monotonic clock for feedback decisions. Production reads
/// `CACurrentMediaTime`; tests can substitute a deterministic time source.
struct KeyboardFeedbackClock: Sendable {
    var now: @Sendable () -> TimeInterval

    static let monotonic = KeyboardFeedbackClock(now: { CACurrentMediaTime() })
}

/// PB-001 A2: narrow tap→commit dedup guard. On fast typing the key-down
/// `.tap` and the trailing candidate `.commit` land within tens of
/// milliseconds of each other and double-fire the shared click/haptic
/// fan-out, which reads as a desynced double beat.
struct KeyboardFeedbackTapCommitDedup: Equatable, Sendable {
    /// A few tens of milliseconds: wide enough to cover the commit that
    /// trails its own key-down tap, narrow enough to keep normal cadence.
    static let dedupWindow: TimeInterval = 0.06

    private(set) var lastTapTimestamp: TimeInterval?

    /// Returns false only when the event must stay silent: a `.commit`
    /// arriving inside the window after an emitted `.tap`.
    func shouldEmit(_ event: KeyboardFeedbackEvent, at timestamp: TimeInterval) -> Bool {
        switch event {
        case .commit:
            guard let lastTapTimestamp else { return true }
            return timestamp - lastTapTimestamp >= Self.dedupWindow
        case .tap, .modeEnter, .`repeat`, .preview:
            return true
        }
    }

    /// Record emitted events only; a suppressed commit leaves the guard so
    /// the next window check still measures from the original tap.
    mutating func record(_ event: KeyboardFeedbackEvent, at timestamp: TimeInterval) {
        switch event {
        case .tap:
            lastTapTimestamp = timestamp
        case .commit:
            lastTapTimestamp = nil
        case .modeEnter, .`repeat`, .preview:
            break
        }
    }
}

/// PB-001 A1: repeat/scrub rhythm. Click and haptic fire on the same tick;
/// the haptic runs lighter than a full-press impact so the tick pattern
/// stays legible during long-delete scrubbing.
enum KeyboardFeedbackRepeatRhythm {
    static let hapticIntensityScale: CGFloat = 0.7
    static let minimumHapticIntensity: CGFloat = 0.25

    static func repeatHapticIntensity(baseIntensity: CGFloat) -> CGFloat {
        max(minimumHapticIntensity, baseIntensity * hapticIntensityScale)
    }
}

/// Per-controller guard state. `KeyboardViewController` declares its stored
/// properties in its own file; this extension keeps its mutable dedup guard
/// in a weak-keyed side table so no other production file has to change.
private final class KeyboardFeedbackGuardBox {
    var dedup = KeyboardFeedbackTapCommitDedup()
    var clock = KeyboardFeedbackClock.monotonic
}

private enum KeyboardFeedbackGuardStorage {
    @MainActor
    static let boxes = NSMapTable<NSObject, KeyboardFeedbackGuardBox>(
        keyOptions: [.weakMemory, .objectPointerPersonality],
        valueOptions: [.strongMemory]
    )

    @MainActor
    static func guardBox(for controller: NSObject) -> KeyboardFeedbackGuardBox {
        if let existing = boxes.object(forKey: controller) { return existing }
        let box = KeyboardFeedbackGuardBox()
        boxes.setObject(box, forKey: controller)
        return box
    }
}

extension KeyboardViewController {
    func emitKeyPressFeedback() {
        emitFeedback(for: .tap)
    }

    func emitKeyPressFeedbackIfNeeded(for sender: UIButton) {
        let identifier = ObjectIdentifier(sender)
        guard keyPressFeedbackEmittedButtonIDs.remove(identifier) == nil else {
            return
        }
        emitKeyPressFeedback()
    }

    func emitFeedback(for event: KeyboardFeedbackEvent) {
        // 调节态的按键触觉防御；不据此推断系统震动的来源。
        guard !isKeyboardHeightAdjusting else { return }
        switch event {
        case .tap, .commit:
            let box = KeyboardFeedbackGuardStorage.guardBox(for: self)
            let timestamp = box.clock.now()
            // PB-001 A2: a `.commit` hot on the heels of a `.tap` stays
            // silent so the shared click/haptic fan-out does not double-fire.
            guard box.dedup.shouldEmit(event, at: timestamp) else { return }
            box.dedup.record(event, at: timestamp)
            playHaptic()
            playKeyClick()

        case .modeEnter:
            playModeEnterHaptic()

        case .`repeat`:
            break

        case .preview:
            break
        }
    }

    func playKeyClick() {
        guard cachedKeyClickEnabled else {
            return
        }
        UIDevice.current.playInputClick()
    }

    func playHaptic(intensity: CGFloat? = nil) {
        // 调节态的按键触觉防御；不据此推断系统震动的来源。
        guard !isKeyboardHeightAdjusting else { return }
        guard cachedHapticEnabled else {
            return
        }
        // PB-001 A3: prepare ahead of the impact so the first tap after a
        // style swap or an idle stretch is not the generator's warm-up tap;
        // prepare again afterwards so the next event finds it ready.
        hapticGenerator.prepare()
        hapticGenerator.impactOccurred(intensity: intensity ?? cachedHapticIntensity)
        hapticGenerator.prepare()
    }

    func playModeEnterHaptic() {
        // 调节态的按键触觉防御；不据此推断系统震动的来源。
        guard !isKeyboardHeightAdjusting else { return }
        guard cachedHapticEnabled else {
            return
        }
        modeEnterHapticGenerator.prepare()
        modeEnterHapticGenerator.impactOccurred(intensity: 1.0)
        modeEnterHapticGenerator.prepare()
    }

    /// One click per scrub step or repeat tick, with a matching lighter
    /// haptic on the same tick (PB-001 A1: click and haptic rhythms are
    /// aligned — previously the haptic only fired every 4th tick). The press
    /// click is separate and must not be counted here. Tap lift does not
    /// call this.
    func playRepeatFeedback(effectiveDeleteCount: Int) {
        playKeyClick()
        playHaptic(
            intensity: KeyboardFeedbackRepeatRhythm.repeatHapticIntensity(
                baseIntensity: cachedHapticIntensity
            )
        )
    }

    /// One heavier confirmation when the finger enters the trash bubble.
    func playDeleteBubbleArmedFeedback() {
        playKeyClick()
        playHaptic(intensity: 1.0)
    }

    func refreshCachedSettings(source: String = "unspecified") {
        let defaults = sharedDefaults
        let previewEnabled: Bool
        if let value = defaults?.object(forKey: KeyboardInputSettingsKey.clipboardPreviewEnabled) as? NSNumber,
            CFGetTypeID(value) == CFBooleanGetTypeID()
        {
            previewEnabled = value.boolValue
        } else {
            previewEnabled = false
        }
        if !previewEnabled || !hasFullAccess { pasteSession.discardPreview() }
        cachedPasteToolbarEnabled = previewEnabled
        defer { refreshPasteToolbar() }

        // 诊断开关与反馈设置使用同一生命周期快照；候选触控链路不自行轮询共享偏好。
        CandidateTouchDiagnostics.refreshFromSharedSettings()
        #if DEBUG
            applyDebugKeyHitboxOverlaySetting()
        #endif

        let rawSound = defaults?.object(forKey: KeyboardFeedbackSettingsKey.keyClickEnabled)
        let rawHaptic = defaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticEnabled)
        let rawHapticLevel = defaults?.object(forKey: KeyboardFeedbackSettingsKey.hapticLevel)
        let rawPairedSymbolCompletion = defaults?.object(
            forKey: KeyboardInputSettingsKey.pairedSymbolCompletionEnabled
        )
        let rawPostCommitContinuation = defaults?.object(
            forKey: KeyboardInputSettingsKey.postCommitContinuationEnabled
        )
        let typoExperimentSettings = TypoCorrectionExperimentalSettings.load(from: defaults)

        cachedKeyClickEnabled = rawSound as? Bool ?? true
        // PB-019 PR-2: snapshot the key-popup switch next to the other feedback
        // switches; the press hot path only reads this cache.
        cachedKeyPopupEnabled = KeyboardKeyPopupSettings.isEnabled(
            stored: defaults?.object(forKey: KeyboardKeyPopupSettings.enabledKey)
        )
        cachedHapticEnabled = rawHaptic as? Bool ?? false
        cachedHapticLevel = feedbackLevelValue(rawHapticLevel)
        cachedHapticIntensity = CGFloat(KeyboardFeedbackSettingsStore.readContinuousIntensity(from: defaults))
        applyHapticHardwareStyle(KeyboardFeedbackIntensity.hardwareStyle(for: Double(cachedHapticIntensity)))
        let storedLiquidGlass =
            defaults?.bool(
                forKey: KeyboardAppearanceSettingsKey.liquidGlassMaterialEnabled
            ) ?? false
        #if DEBUG
            let liquidGlassDebugBuild = true
        #else
            let liquidGlassDebugBuild = false
        #endif
        cachedLiquidGlassMaterialEnabled = liquidGlassMaterialEffectivelyEnabled(
            storedValue: storedLiquidGlass,
            isDebugBuild: liquidGlassDebugBuild
        )
        controller.isPairedSymbolCompletionEnabled = rawPairedSymbolCompletion as? Bool ?? true
        controller.mixedScriptSpacingEnabled = MixedScriptSpacing.isEnabled(
            stored: defaults?.object(forKey: KeyboardInputSettingsKey.mixedScriptSpacingEnabled),
            hasFullAccess: hasFullAccess
        )
        controller.englishCandidateAutospaceEnabled = EnglishAutospace.isEnabled(
            stored: defaults?.object(forKey: KeyboardInputSettingsKey.englishCandidateAutospaceEnabled),
            hasFullAccess: hasFullAccess
        )
        controller.setPostCommitContinuationEnabled(rawPostCommitContinuation as? Bool ?? true)
        controller.typoCorrectionLearningSnapshot = typoCorrectionLearningStore.snapshot()
        cachedTypingIntelligenceEnabled =
            defaults?.bool(
                forKey: TypingStatisticsStorageKey.enabled
            ) ?? false
        cachedTypingIntelligenceResetEpoch =
            defaults?.integer(
                forKey: TypingStatisticsStorageKey.resetEpoch
            ) ?? 0

        // Layout / nine-key readiness: snapshot only — never read UserDefaults on the key path.
        cachedTwentySixKeyNumberPadEnabled =
            defaults?.bool(forKey: KeyboardInputSettingsKey.twentySixKeyNumberPadEnabled) ?? false
        cachedShuangpinSublegendEnabled =
            defaults?.object(forKey: KeyboardLayoutSettingsKey.shuangpinSublegendEnabled) as? Bool ?? true
        cachedLayoutStyle = KeyboardLayoutStyle.resolve(
            defaults?.string(forKey: KeyboardLayoutSettingsKey.layoutStyle)
        )
        // PB-017 PR-3：智能纠错实验编辑按激活 schema 门卫——双拼两键一音使
        // 插入/换位的音节假设失真，激活双拼时 fail-closed 清空；全拼 / T9 / 未知
        // schema 保持原值。九宫格激活时双拼 binding26 休眠，按 binding9 判定。
        controller.typoCorrectionExperimentalEdits = TypoCorrectionExperimentalEdits.gatedForActiveSchema(
            typoExperimentSettings.experimentalEdits,
            activeSchemaID: typoGateActiveSchemaID(
                layoutStyle: cachedLayoutStyle,
                defaults: defaults
            )
        )
        var sharedDataDir: String?
        if let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Self.appGroupID
        ) {
            sharedDataDir = container.appendingPathComponent("Rime/shared", isDirectory: true).path
        }
        // Each registered scheme contributes its own marker key and source fingerprint.
        // Fog bindings still resolve through the legacy contract inside `resolveRegistered`.
        let snapshot = RimeRuntimeSelectionBridge.registeredSnapshot(
            defaults: defaults,
            sharedDataDir: sharedDataDir
        )
        let selection = RimeRuntimeSelection.resolveRegistered(
            baseSchemaID: defaults?.string(forKey: "rime_active_schema"),
            layoutRawValue: defaults?.string(forKey: KeyboardLayoutSettingsKey.layoutStyle),
            readinessMarker: snapshot.fogMarker,
            onDiskFingerprint: snapshot.fogFingerprint,
            schemeBinding26: defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26),
            schemeBinding9: defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9),
            readinessBySchema: snapshot.readinessBySchema,
            installedFamilies: snapshot.installedFamilies
        )
        cachedT9ReadinessMatched = selection.t9ReadinessMatched
        cachedShuangpinLegendTable =
            selection.usesT9InputSemantics
            ? nil
            : ShuangpinLegendTable.table(forSchemaID: selection.effectiveSchemaID)
        // Provisional chrome from readiness (before/while engine is offline).
        // Once librime has a realized selection, that wins over the marker snapshot.
        if selection.usesT9InputSemantics {
            cachedLayoutStyle = .nineKey
        } else {
            cachedLayoutStyle = .twentySixKey
        }
        controller.usesT9InputSemantics = selection.usesT9InputSemantics
        if let engine = controller.underlyingRimeEngine as? RimeEngineImpl {
            applyRealizedRuntimeSelection(from: engine)
        }

        if cachedHapticEnabled {
            hapticGenerator.prepare()
            modeEnterHapticGenerator.prepare()
        }
    }

    /// PB-017 PR-3：纠错实验编辑门卫判定的激活 schema。
    ///
    /// 与 `RimeRuntimeSelection.resolveRegistered` 的槽位语义对齐：九宫格激活时
    /// 双拼 binding26 休眠，按 `schemeBinding9`（缺省 `t9`）判定；全键盘按
    /// `schemeBinding26` 判定。绑定缺失时返回 `nil`，门卫保持原值（fail-open）。
    func typoGateActiveSchemaID(
        layoutStyle: KeyboardLayoutStyle,
        defaults: UserDefaults?
    ) -> String? {
        switch layoutStyle {
        case .nineKey:
            return defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding9) ?? "t9"
        case .twentySixKey:
            return defaults?.string(forKey: KeyboardLayoutSettingsKey.schemeBinding26)
        }
    }

    func applyHapticHardwareStyle(_ style: KeyboardFeedbackHardwareStyle) {
        guard style != appliedHapticHardwareStyle else {
            hapticGenerator.prepare()
            return
        }
        appliedHapticHardwareStyle = style
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: uiStyle = .light
        case .medium: uiStyle = .medium
        case .heavy: uiStyle = .heavy
        }
        hapticGenerator = UIImpactFeedbackGenerator(style: uiStyle)
        hapticGenerator.prepare()
    }

    func feedbackLevelValue(_ rawValue: Any?) -> KeyboardFeedbackLevel {
        if let value = rawValue as? Int {
            return KeyboardFeedbackLevel.clamped(value)
        }
        if let value = rawValue as? NSNumber {
            return KeyboardFeedbackLevel.clamped(value.intValue)
        }
        return .defaultLevel
    }

    func logKeyPerformance(_ message: String, startTime: CFTimeInterval) {
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        Logger.shared.performance("\(message) (\(String(format: "%.1f", elapsed))ms)")
    }

    #if DEBUG
        /// Visibility / settings snapshot only. Never call from `hitTest`.
        func applyDebugKeyHitboxOverlaySetting() {
            let enabled = DebugKeyHitboxConfiguration.isEnabled(
                in: sharedDefaults,
                isDebugBuild: true
            )
            DebugHitboxOverlayPresentation.isShowing = enabled
            (rootStack as? KeyboardInputHitAreaStackView)?
                .setShowsRealTouchRangeOverlay(enabled)
            (candidateBar as? CandidateBarView)?.refreshDebugHitboxOverlay()
            t9PinyinPathBarView?.refreshDebugHitboxOverlay()
            (candidateExpandedPanel as? ExpandedCandidatePanelContainerView)?
                .refreshDebugHitboxOverlay()
        }
    #endif
}
