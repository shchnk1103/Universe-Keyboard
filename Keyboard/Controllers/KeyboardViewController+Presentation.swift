import KeyboardCore
import UIKit

extension KeyboardViewController {
    /// Installs content inside the system-provided input region without requesting a custom height.
    func setupRootStack() {
        rootStack = UIStackView()
        rootStack.axis = .vertical
        rootStack.spacing = keySpacing
        rootStack.distribution = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        view.clipsToBounds = true
        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 7),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -7),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2),
        ])
        Logger.shared.debug("setupRootStack: system height, top+4, bottom-2, hMargin=7", category: .display)
    }

    func reloadKeyboard() {
        isCandidateExpanded = false
        candidateExpandedPanel?.removeFromSuperview()
        candidateExpandedPanel = nil
        candidateCollectionView = nil
        expandedPanelScrollView = nil
        expandedCandidateCollectionView = nil
        rootStack.alpha = 1
        rootStack.isUserInteractionEnabled = true
        clearAllRows()
        candidateBar = makeCandidateBar()
        rootStack.addArrangedSubview(candidateBar)
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
        view.backgroundColor = keyboardBackgroundColor
        setupRootStack()
        UIView.performWithoutAnimation {
            reloadKeyboard()
            view.layoutIfNeeded()
        }
        Logger.shared.debug("installKeyboardUI: systemBounds=\(view.bounds)", category: .display)
        Logger.shared.requestFlush()
    }

    func reloadKeyboardContent(with precomputedCandidates: [CandidateItem]? = nil) {
        clearAllRows()
        if isCandidateExpanded {
            let panel = makeExpandedCandidatePanel(with: precomputedCandidates)
            rootStack.addArrangedSubview(panel)
            candidateExpandedPanel = panel
        } else {
            candidateBar = makeCandidateBar()
            rootStack.addArrangedSubview(candidateBar)
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
                rootStack.addArrangedSubview(makeTextRow(["-", "/", "：", "；", "（", "）", "¥", "“", "”", "‘"]))
                rootStack.addArrangedSubview(makeTextRow(["。", "，", "、", "？", "！", "…", "·", "《", "》"]))
            } else {
                rootStack.addArrangedSubview(makeTextRow(["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]))
                rootStack.addArrangedSubview(makeTextRow([".", ",", "?", "!", "'", "\"", "—", "…", "~"]))
            }
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        case .symbols:
            if state.inputMode == .chinese {
                rootStack.addArrangedSubview(makeTextRow(["【", "】", "「", "」", "『", "』", "《", "》", "［", "］"]))
                rootStack.addArrangedSubview(makeTextRow(["～", "—", "…", "·", "￥", "$", "€", "£", "¥", "&"]))
                rootStack.addArrangedSubview(makeTextRow(["#", "%", "^", "*", "+", "=", "｜", "\\", "/", "<"]))
            } else {
                rootStack.addArrangedSubview(makeTextRow(["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]))
                rootStack.addArrangedSubview(makeTextRow(["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "&"]))
                rootStack.addArrangedSubview(makeTextRow(["·", "•", "…", "—", "–", "/", "'", "\"", "!", "?"]))
            }
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        case .emoji:
            rootStack.addArrangedSubview(makeEmojiPage())
            rootStack.addArrangedSubview(makeBottomRow(pageSwitchTitle: pageSwitchTitle, includeDelete: true))
        }
    }

    func clearAllRows() {
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
        let startTime = CACurrentMediaTime()
        defer { logKeyPerformance("syncUI \(effects)", startTime: startTime) }
        updateReturnKeyAppearance()
        if effects.contains(.pageChanged) || effects.contains(.inputModeChanged)
            || effects.contains(.keyboardTypeChanged)
        {
            if hasViewAppeared {
                reloadKeyboard()
            } else {
                UIView.performWithoutAnimation { reloadKeyboard() }
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
}
