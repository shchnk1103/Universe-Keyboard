import CoreFoundation
import KeyboardCore
import RimeBridge
import UIKit

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
        hapticGenerator.impactOccurred(intensity: intensity ?? cachedHapticIntensity)
        hapticGenerator.prepare()
    }

    func playModeEnterHaptic() {
        // 调节态的按键触觉防御；不据此推断系统震动的来源。
        guard !isKeyboardHeightAdjusting else { return }
        guard cachedHapticEnabled else {
            return
        }
        modeEnterHapticGenerator.impactOccurred(intensity: 1.0)
        modeEnterHapticGenerator.prepare()
    }

    /// One click per scrub step or repeat tick. The press click is separate and
    /// must not be counted here. Tap lift does not call this.
    func playRepeatFeedback(effectiveDeleteCount: Int) {
        playKeyClick()
        if effectiveDeleteCount.isMultiple(of: 4) {
            playHaptic(intensity: max(0.25, cachedHapticIntensity * 0.7))
        }
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
