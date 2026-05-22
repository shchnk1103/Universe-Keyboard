//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by DoubleShy0N on 5/10/26.
//
//  UIInputViewController 主控：管理键盘生命周期、根布局和 UI 刷新。
//  所有状态逻辑委托给 KeyboardCore.KeyboardController。
//  按键动作 → KeyboardViewController+Actions.swift
//  UI 工厂方法 → KeyboardViewController+Layout.swift
//

import UIKit
import KeyboardCore

class KeyboardViewController: UIInputViewController {

    // MARK: - 视图引用

    var rootStack: UIStackView!
    var candidateBar: UIView!
    var candidateScrollView: UIScrollView!
    var candidateStack: UIStackView!
    var nextKeyboardButton: UIButton!
    var shiftButton: UIButton!
    var returnButton: UIButton!
    var letterButtons: [UIButton] = []

    // MARK: - 控制器

    var controller: KeyboardController!

    // MARK: - 删除相关（UI 层）

    var deleteRepeatTimer: Timer?
    var isDeleteRepeatActive = false

    // MARK: - 长按变体字符

    var variantPopupView: KeyPopupView?
    var longPressedButton: UIButton?
    var candidateFadeGradient: CAGradientLayer?
    var candidateExpandedPanel: UIView?
    var candidateExpandButton: UIButton?
    var candidateExpandButtonWidthConstraint: NSLayoutConstraint?
    var isCandidateExpanded = false
    var keyTouchDownTimes: [ObjectIdentifier: CFTimeInterval] = [:]
    private var hasViewAppeared = false
    private var hasShownKeyboard = false

    // MARK: - 缓存的设置（避免每次按键都通过 XPC 访问 UserDefaults）

    private var cachedKeyClickEnabled: Bool = true
    private var cachedHapticEnabled: Bool = false

    // MARK: - 布局常量

    let candidateBarHeight: CGFloat = 36
    let keyHeight: CGFloat = 44
    let keySpacing: CGFloat = 6
    let keyCornerRadius: CGFloat = 9

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        let startupTime = CACurrentMediaTime()

        view.backgroundColor = keyboardBackgroundColor
        inputView?.allowsSelfSizing = true
        // iPhone 13 Pro 原生键盘约 260pt；实际高度由 iOS 根据设备决定
        let totalHeight = candidateBarHeight + keyHeight * 4 + keySpacing * 4 + 14  // 36+176+24+14=250
        preferredContentSize = CGSize(width: 0, height: totalHeight)

        // 隐藏键盘直到首次 layout 完成 — 避免 3 阶段 resize 中内容跳动
        view.alpha = 0

        let keyboardType = KeyboardType.from(uiKeyboardType: textDocumentProxy.keyboardType)
        let state = KeyboardState(activeKeyboardType: keyboardType)
        controller = KeyboardController(state: state)
        controller.textClient = UITextDocumentProxyAdapter(proxy: textDocumentProxy)

        Logger.shared.info("viewDidLoad, keyboardType=\(keyboardType)", category: .general)

        // 始终尝试创建真实 RIME 引擎
        if let (sharedDir, userDir) = RimeConfigManager.prepareDirectories() {
            Logger.shared.info("App Group available, creating RimeEngineImpl", category: .engine)
            controller.rimeEngine = RimeEngineImpl(sharedDataDir: sharedDir, userDataDir: userDir)

            // 健康检查
            var testOutput = controller.rimeEngine!.processKey("n")
            Logger.shared.info("processKey(n) → preedit: \(testOutput.composition?.preeditText ?? "nil"), candidates: \(testOutput.candidates.count)", category: .engine)
            testOutput = controller.rimeEngine!.processKey("i")
            Logger.shared.info("processKey(i) → preedit: \(testOutput.composition?.preeditText ?? "nil"), candidates: \(testOutput.candidates.count)", category: .engine)
            controller.rimeEngine!.resetSession()

            if testOutput.candidates.isEmpty {
                Logger.shared.warning("No candidates on first check; engine will deploy on keystroke", category: .engine)
            } else {
                Logger.shared.info("RIME ready, candidates: \(testOutput.candidates.count)", category: .engine)
            }
        } else {
            controller.enableDefaultRimeEngine()
            Logger.shared.warning("App Group unavailable, using Fake adapter", category: .engine)
        }

        let elapsed = (CACurrentMediaTime() - startupTime) * 1000
        Logger.shared.performance("viewDidLoad complete", durationMs: elapsed)

        if controller.state.inputMode == .english {
            let context = textDocumentProxy.documentContextBeforeInput
            _ = controller.applyAutoCapitalization(contextBeforeInput: context)
        }

        refreshCachedSettings()
        observeSettingsChanges()
        hapticGenerator.prepare()

        setupRootStack()
        UIView.performWithoutAnimation {
            reloadKeyboard()
        }
    }

    deinit {
        Logger.shared.flush()
        stopDeleteRepeat()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasViewAppeared = true
        Logger.shared.debug("viewDidAppear: bounds=\(view.bounds)", category: .display)
    }

    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新候选栏右侧渐隐遮罩
        if let gradient = candidateFadeGradient, let scrollView = candidateScrollView {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradient.frame = scrollView.bounds
            CATransaction.commit()
        }
        Logger.shared.debug("viewDidLayoutSubviews: view.bounds=\(view.bounds), rootStack.frame=\(rootStack?.frame ?? .zero), candidateBar.frame=\(candidateBar?.frame ?? .zero)", category: .display)

        // 仅在 viewDidAppear 之后、高度已稳定到合理范围（< 400pt 过滤掉 844/445 中间态）
        // 时才将 alpha 还原为 1。避免 3 阶段 resize 过程中键盘在错误高度短暂可见。
        if !hasShownKeyboard, hasViewAppeared, view.bounds.height > 0, view.bounds.height < 400 {
            hasShownKeyboard = true
            view.alpha = 1
            Logger.shared.info("keyboard revealed at h=\(view.bounds.height)", category: .display)
        }
    }

    override func textWillChange(_ textInput: UITextInput?) {
    }

    override func textDidChange(_ textInput: UITextInput?) {
        let proxy = self.textDocumentProxy
        let textColor: UIColor = proxy.keyboardAppearance == .dark ? .white : .black
        nextKeyboardButton.setTitleColor(textColor, for: [])
        updateReturnKeyAppearance()

        let keyboardType = KeyboardType.from(uiKeyboardType: proxy.keyboardType)
        var effects = controller.handle(.keyboardTypeChanged(keyboardType))

        let context = proxy.documentContextBeforeInput
        let autoCapEffect = controller.applyAutoCapitalization(contextBeforeInput: context)
        effects.formUnion(autoCapEffect)

        guard !effects.isEmpty else { return }
        syncUI(with: effects)
    }

    // MARK: - 根布局

    func setupRootStack() {
        rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = keySpacing
        rootStack.distribution = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.clipsToBounds = true
        view.addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])

        Logger.shared.debug("setupRootStack: top+6, bottom-8", category: .display)
    }

    func reloadKeyboard() {
        isCandidateExpanded = false
        clearAllRows()
        candidateBar = makeCandidateBar()
        rootStack.addArrangedSubview(candidateBar)
        addKeyboardRows(for: controller.state)
        updateReturnKeyAppearance()
        Logger.shared.debug("reloadKeyboard: candidateBar=\(candidateBar != nil ? "OK" : "nil"), rows=\(rootStack.arrangedSubviews.count)", category: .display)
    }

    /// 仅重建键盘内容区（保留候选栏），用于展开/收起候选面板
    func reloadKeyboardContent(with precomputedCandidates: [CandidateItem]? = nil) {
        removeContentRows()

        if isCandidateExpanded {
            let panel = makeExpandedCandidatePanel(with: precomputedCandidates)
            rootStack.addArrangedSubview(panel)
            candidateExpandedPanel = panel
        } else {
            addKeyboardRows(for: controller.state)
        }
    }

    // MARK: - 键盘行构建（私有）

    private func addKeyboardRows(for state: KeyboardState) {
        letterButtons.removeAll()
        candidateExpandedPanel = nil

        switch state.currentPage {
        case .letters:
            rootStack.addArrangedSubview(makeLetterRow(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]))
            rootStack.addArrangedSubview(makeLetterRow(["a", "s", "d", "f", "g", "h", "j", "k", "l"], horizontalInset: 18))
            rootStack.addArrangedSubview(makeLetterThirdRow())
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: false))
        case .numbers:
            rootStack.addArrangedSubview(makeTextRow(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]))
            if state.inputMode == .chinese {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", "：", "；", "（", "）", "¥", "\u{201C}", "\u{201D}", "\u{2018}"]))
                rootStack.addArrangedSubview(makeTextRow(["。", "，", "、", "？", "！", "…", "·", "《", "》"]))
            } else {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]))
                rootStack.addArrangedSubview(makeTextRow([".", ",", "?", "!", "'", "\"", "—", "…", "~"]))
            }
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        case .symbols:
            rootStack.addArrangedSubview(makeTextRow(["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]))
            rootStack.addArrangedSubview(makeTextRow(["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "&"]))
            rootStack.addArrangedSubview(makeTextRow(["·", "•", "…", "—", "–", "/", "'", "\"", "!", "?"]))
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        }
    }

    private func clearAllRows() {
        for view in rootStack.arrangedSubviews {
            rootStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func removeContentRows() {
        var foundBar = false
        for view in rootStack.arrangedSubviews {
            if view === candidateBar {
                foundBar = true
                continue
            }
            if foundBar {
                rootStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }
    }

    // MARK: - 按键反馈

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private let clickPlayer = KeyClickPlayer()
    private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    private var cachedKeyClickVolume: Float = 0.8
    private var cachedHapticIntensity: CGFloat = 0.5

    func playKeyClick() {
        guard cachedKeyClickEnabled else { return }
        clickPlayer.play(volume: cachedKeyClickVolume)
    }

    func playHaptic() {
        guard cachedHapticEnabled else { return }
        hapticGenerator.impactOccurred(intensity: cachedHapticIntensity)
        hapticGenerator.prepare()
    }

    private func refreshCachedSettings() {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        cachedKeyClickEnabled = defaults?.bool(forKey: "key_click_enabled") ?? true
        cachedHapticEnabled = defaults?.bool(forKey: "haptic_enabled") ?? false
        let volume = defaults?.double(forKey: "key_click_volume") ?? 0
        cachedKeyClickVolume = volume > 0 ? Float(volume) : 0.8
        let intensity = defaults?.double(forKey: "haptic_intensity") ?? 0
        cachedHapticIntensity = intensity > 0 ? CGFloat(intensity) : 0.5
    }

    private func observeSettingsChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: UserDefaults.didChangeNotification,
            object: UserDefaults(suiteName: Self.appGroupID)
        )
    }

    @objc private func handleSettingsChanged() {
        refreshCachedSettings()
    }

    // MARK: - UI 同步

    func syncUI(with effects: KeyboardEffect) {
        let startTime = CACurrentMediaTime()
        defer {
            logKeyPerformance("syncUI \(effects)", startTime: startTime)
        }

        updateReturnKeyAppearance()

        if effects.contains(.pageChanged) || effects.contains(.inputModeChanged) || effects.contains(.keyboardTypeChanged) {
            if hasViewAppeared {
                reloadKeyboard()
            } else {
                UIView.performWithoutAnimation {
                    reloadKeyboard()
                }
            }
            return
        }
        if effects.contains(.compositionChanged) {
            refreshCandidateBar()
        }
        if effects.contains(.shiftStateChanged) {
            refreshLetterButtons()
            updateShiftButtonAppearance()
        }
    }

    func logKeyPerformance(_ message: String, startTime: CFTimeInterval) {
        guard Logger.shared.isEnabled else { return }
        let elapsed = (CACurrentMediaTime() - startTime) * 1000
        Logger.shared.performance("\(message) (\(String(format: "%.1f", elapsed))ms)")
    }
}
