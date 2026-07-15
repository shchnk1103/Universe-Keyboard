import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// Installs content inside the system-provided input region without requesting a custom height.
    func setupRootStack() {
        keyboardSurfaceView = UIView()
        keyboardSurfaceView.translatesAutoresizingMaskIntoConstraints = false

        keyboardSurfaceMaterialView = UIVisualEffectView(effect: nil)
        keyboardSurfaceMaterialView.translatesAutoresizingMaskIntoConstraints = false

        keyboardSurfaceFillView = UIView()
        keyboardSurfaceFillView.translatesAutoresizingMaskIntoConstraints = false

        keyboardSurfaceHighlightView = UIView()
        keyboardSurfaceHighlightView.translatesAutoresizingMaskIntoConstraints = false

        rootStack = KeyboardInputHitAreaStackView()
        rootStack.axis = .vertical
        rootStack.spacing = keySpacing
        rootStack.distribution = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.clipsToBounds = true
        applyKeyboardSurfaceStyle()

        view.addSubview(keyboardSurfaceView)
        keyboardSurfaceView.addSubview(keyboardSurfaceMaterialView)
        keyboardSurfaceView.addSubview(keyboardSurfaceFillView)
        keyboardSurfaceView.addSubview(keyboardSurfaceHighlightView)
        keyboardSurfaceView.addSubview(rootStack)
        NSLayoutConstraint.activate([
            keyboardSurfaceView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardSurfaceView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardSurfaceView.topAnchor.constraint(equalTo: view.topAnchor),
            keyboardSurfaceView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            keyboardSurfaceMaterialView.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor),
            keyboardSurfaceMaterialView.trailingAnchor.constraint(equalTo: keyboardSurfaceView.trailingAnchor),
            keyboardSurfaceMaterialView.topAnchor.constraint(equalTo: keyboardSurfaceView.topAnchor),
            keyboardSurfaceMaterialView.bottomAnchor.constraint(equalTo: keyboardSurfaceView.bottomAnchor),

            keyboardSurfaceFillView.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor),
            keyboardSurfaceFillView.trailingAnchor.constraint(equalTo: keyboardSurfaceView.trailingAnchor),
            keyboardSurfaceFillView.topAnchor.constraint(equalTo: keyboardSurfaceView.topAnchor),
            keyboardSurfaceFillView.bottomAnchor.constraint(equalTo: keyboardSurfaceView.bottomAnchor),

            keyboardSurfaceHighlightView.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor, constant: 18),
            keyboardSurfaceHighlightView.trailingAnchor.constraint(equalTo: keyboardSurfaceView.trailingAnchor, constant: -18),
            keyboardSurfaceHighlightView.topAnchor.constraint(equalTo: keyboardSurfaceView.topAnchor, constant: 1),
            keyboardSurfaceHighlightView.heightAnchor.constraint(equalToConstant: 1),

            rootStack.leadingAnchor.constraint(equalTo: keyboardSurfaceView.leadingAnchor, constant: 7),
            rootStack.trailingAnchor.constraint(equalTo: keyboardSurfaceView.trailingAnchor, constant: -7),
            rootStack.topAnchor.constraint(equalTo: keyboardSurfaceView.topAnchor, constant: keyboardContentTopInset),
            rootStack.bottomAnchor.constraint(equalTo: keyboardSurfaceView.bottomAnchor, constant: -keyboardContentBottomInset),
        ])
        Logger.shared.debug(
            "setupRootStack: transparent surface, content top+\(keyboardContentTopInset), "
                + "bottom-\(keyboardContentBottomInset), hMargin=7",
            category: .display
        )
    }

    func reloadKeyboard() {
        isCandidateExpanded = false
        candidateExpandedPanel?.removeFromSuperview()
        candidateExpandedPanel = nil
        candidateCollectionView = nil
        expandedPanelScrollView = nil
        expandedCandidateCollectionView = nil
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        rootStack.alpha = 1
        rootStack.isUserInteractionEnabled = true
        clearAllRows()
        candidateBar = makeCandidateBar()
        rootStack.addArrangedSubview(candidateBar)
        rootStack.setCustomSpacing(0, after: candidateBar)
        addKeyboardRows(for: controller.state)
        updateReturnKeyAppearance()
        Logger.shared.debug(
            "reloadKeyboard: candidateBar=\(candidateBar != nil ? "OK" : "nil"), rows=\(rootStack.arrangedSubviews.count)",
            category: .display
        )
    }

    func installKeyboardUIIfNeeded() {
        guard !isKeyboardUIInstalled else { return }
        isKeyboardUIInstalled = true
        view.backgroundColor = .clear
        setupRootStack()
        UIView.performWithoutAnimation {
            reloadKeyboard()
            view.layoutIfNeeded()
        }
        Logger.shared.debug("installKeyboardUI: systemBounds=\(view.bounds)", category: .display)
        Logger.shared.requestFlush()
    }

    func reloadKeyboardContent(with precomputedCandidates: [CandidateItem]? = nil) {
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        clearAllRows()
        if isCandidateExpanded {
            let panel = makeExpandedCandidatePanel(with: precomputedCandidates)
            rootStack.addArrangedSubview(panel)
            candidateExpandedPanel = panel
        } else {
            candidateBar = makeCandidateBar()
            rootStack.addArrangedSubview(candidateBar)
            rootStack.setCustomSpacing(0, after: candidateBar)
            addKeyboardRows(for: controller.state)
        }
    }

    func addKeyboardRows(for state: KeyboardState) {
        letterButtons.removeAll()
        candidateExpandedPanel = nil
        expandedPanelScrollView = nil
        switch state.currentPage {
        case .letters:
            rootStack.addArrangedSubview(makeLetterRow(["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]))
            rootStack.addArrangedSubview(
                makeLetterRow(["a", "s", "d", "f", "g", "h", "j", "k", "l"], horizontalInset: 18)
            )
            let thirdRow = makeLetterThirdRow()
            rootStack.addArrangedSubview(thirdRow)
            rootStack.setCustomSpacing(keyboardGroupSpacing, after: thirdRow)
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: false))
        case .numbers:
            rootStack.addArrangedSubview(makeTextRow(["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]))
            if state.inputMode == .chinese {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", "：", "；", "（", "）", "¥", "@", "“", "”"]))
                let thirdRow = makeChineseNumbersThirdRow()
                rootStack.addArrangedSubview(thirdRow)
                rootStack.setCustomSpacing(keyboardGroupSpacing, after: thirdRow)
                rootStack.addArrangedSubview(makeSymbolicBottomRow(languageTitle: "拼音"))
            } else {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", ":", ";", "(", ")", "$", "&", "@", "”"], actionOverrides: [
                    "”": #selector(insertSmartDoubleQuote(_:))
                ]))
                let thirdRow = makeEnglishNumbersThirdRow()
                rootStack.addArrangedSubview(thirdRow)
                rootStack.setCustomSpacing(keyboardGroupSpacing, after: thirdRow)
                rootStack.addArrangedSubview(makeSymbolicBottomRow(languageTitle: "English"))
            }
        case .symbols:
            if state.inputMode == .chinese {
                rootStack.addArrangedSubview(makeTextRow(["【", "】", "｛", "｝", "#", "%", "^", "*", "+", "="]))
                rootStack.addArrangedSubview(makeTextRow(["_", "—", "\\", "｜", "～", "《", "》", "$", "&", "·"]))
                let thirdRow = makeChineseSymbolsThirdRow()
                rootStack.addArrangedSubview(thirdRow)
                rootStack.setCustomSpacing(keyboardGroupSpacing, after: thirdRow)
                rootStack.addArrangedSubview(makeSymbolicBottomRow(languageTitle: "拼音"))
            } else {
                rootStack.addArrangedSubview(makeTextRow(["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]))
                rootStack.addArrangedSubview(makeTextRow(["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"]))
                let thirdRow = makeEnglishSymbolsThirdRow()
                rootStack.addArrangedSubview(thirdRow)
                rootStack.setCustomSpacing(keyboardGroupSpacing, after: thirdRow)
                rootStack.addArrangedSubview(makeSymbolicBottomRow(languageTitle: "English"))
            }
        case .emoji:
            rootStack.addArrangedSubview(makeEmojiPage())
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        }
    }

    func clearAllRows() {
        candidateCellSizeCache.removeAll(keepingCapacity: true)
        for view in rootStack.arrangedSubviews {
            rootStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        expandedPanelScrollView = nil
        expandedCandidateCollectionView = nil
    }

    func removeContentRows() {
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

    func syncUI(with effects: KeyboardEffect) {
#if DEBUG
        let startTime = CACurrentMediaTime()
        defer { logKeyPerformance("syncUI \(effects)", startTime: startTime) }
#endif
        updateReturnKeyAppearance()
        if effects.contains(.pageChanged) || effects.contains(.inputModeChanged)
            || effects.contains(.keyboardTypeChanged)
        {
            if effects.contains(.compositionChanged) {
                resetCandidateSnapshotFromController()
            }
            if hasViewAppeared {
                reloadKeyboard()
            } else {
                UIView.performWithoutAnimation { reloadKeyboard() }
            }
            return
        }
        if effects.contains(.compositionChanged) {
            refreshCandidateBar()
            scheduleContextualTypoCorrectionRefresh()
        }
        if effects.contains(.shiftStateChanged) {
            refreshLetterButtons()
            updateShiftButtonAppearance()
        }
    }
}
