import Foundation

public final class KeyboardController {

    // MARK: - Public properties

    public internal(set) var state: KeyboardState
    public var textClient: TextInputClient?
    public let candidateProvider: CandidateProvider
    public var rimeEngine: RimeEngine?

    public var currentDate: () -> Date = { Date() }

    // MARK: - Init

    public init(
        state: KeyboardState = KeyboardState(),
        candidateProvider: CandidateProvider = FakeCandidateProvider()
    ) {
        self.state = state
        self.candidateProvider = candidateProvider
    }

    /// 启用基于 CandidateProvider 的 RIME 适配器引擎。
    /// 在真正的 librime 就绪之前，此方法将现有的 FakeCandidateProvider 包装为 RimeEngine，
    /// 使键盘通过新架构运行，但行为与当前完全一致。
    public func enableDefaultRimeEngine() {
        rimeEngine = CandidateProviderRimeAdapter(candidateProvider: candidateProvider)
    }

    // MARK: - Public entry point

    @discardableResult
    public func handle(_ action: KeyboardAction) -> KeyboardEffect {
        switch action {
        case .insertKey(let key):
            return handleInsertKey(key)
        case .insertCandidate(let candidate, let kind):
            return handleInsertCandidate(candidate, kind: kind)
        case .insertDirectText(let text):
            return handleInsertDirectText(text)
        case .toggleShift:
            return handleToggleShift()
        case .togglePage:
            return handleTogglePage()
        case .toggleInputMode:
            return handleToggleInputMode()
        case .insertSpace:
            return handleInsertSpace()
        case .insertReturn:
            return handleInsertReturn()
        case .deleteBackward:
            return handleDeleteBackward()
        case .keyboardTypeChanged(let type):
            return handleKeyboardTypeChanged(type)
        }
    }
}

// MARK: - Key insertion

extension KeyboardController {

    func handleInsertKey(_ key: String) -> KeyboardEffect {
        if state.currentPage == .letters && state.inputMode == .chinese {
            if let engine = rimeEngine {
                let output = engine.processKey(key)
                state.lastRimeOutput = output
                state.currentComposition = output.composition?.preeditText ?? ""
                updateInlinePreedit(state.currentComposition)
                if let commit = output.committedText {
                    insertText(commit)
                }
                return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
            }
            if state.currentComposition.isEmpty && state.shiftState != .off {
                state.currentComposition += key
            } else {
                state.currentComposition += key.lowercased()
            }
            updateInlinePreedit(state.currentComposition)
            return consumeSingleUseShiftIfNeeded().union(.compositionChanged)
        } else {
            insertText(key)
            var effects = consumeSingleUseShiftIfNeeded()
            if state.inputMode == .english && Self.isSentenceTerminator(key) {
                state.shiftState = .singleUse
                effects.insert(.shiftStateChanged)
            }
            return effects
        }
    }

    /// 处理候选词/拼音组合的点击。
    ///
    /// 根据 CandidateKind 枚举进行三路分支：
    /// - .placeholder: 不执行任何操作（UI 层已禁用这些按钮，此处是安全兜底）
    /// - .composition: 把原始拼音串直接上屏（用于用户不想选候选而直接提交拼音的场景）
    /// - .candidate: 插入选中的候选词，然后清除拼音组合缓冲区
    ///
    /// 为什么用 switch 而不是 if/else？
    /// switch 在枚举上是"穷尽性"的 —— 如果将来有人给 CandidateKind 新增了一个 case，
    /// 编译器会在此处报错，强制开发者处理新分支。字符串 if/else 做不到这一点。
    func handleInsertCandidate(_ candidate: String, kind: CandidateKind) -> KeyboardEffect {
        switch kind {
        case .placeholder:
            return []
        case .composition:
            commitComposition()
            rimeEngine?.resetSession()
            state.lastRimeOutput = nil
        case .candidate:
            if let engine = rimeEngine,
               let output = state.lastRimeOutput,
               let idx = output.candidates.firstIndex(where: { $0.text == candidate }) {
                let result = engine.selectCandidate(at: idx)
                state.lastRimeOutput = result
                state.currentComposition = result.composition?.preeditText ?? ""
                deleteInlinePreedit()
                if let commit = result.committedText {
                    insertText(commit)
                }
            } else {
                deleteInlinePreedit()
                insertText(candidate)
                state.currentComposition = ""
                state.lastRimeOutput = nil
            }
        }
        return .compositionChanged
    }

    func handleInsertDirectText(_ text: String) -> KeyboardEffect {
        var effects: KeyboardEffect = []
        if !state.currentComposition.isEmpty {
            deleteInlinePreedit()
            insertText(state.currentComposition)
            state.currentComposition = ""
            effects.insert(.compositionChanged)
        }
        insertText(text)
        return effects
    }
}

// MARK: - Shift / Page / InputMode

extension KeyboardController {

    func handleToggleShift() -> KeyboardEffect {
        let now = currentDate()
        let isDoubleTap = state.lastShiftTapTime.map { now.timeIntervalSince($0) < 0.35 } ?? false
        state.lastShiftTapTime = now

        if isDoubleTap && state.shiftState != .capsLock {
            state.shiftState = .capsLock
        } else {
            switch state.shiftState {
            case .off:
                state.shiftState = .singleUse
            case .singleUse, .capsLock:
                state.shiftState = .off
            }
        }

        return .shiftStateChanged
    }

    func handleTogglePage() -> KeyboardEffect {
        var effects: KeyboardEffect = []

        switch state.currentPage {
        case .letters:
            effects = resetShiftState()
            if let engine = rimeEngine, engine.isComposing() {
                deleteInlinePreedit()
                insertText(state.currentComposition)
                engine.resetSession()
                state.currentComposition = ""
                state.lastRimeOutput = nil
                effects.insert(.compositionChanged)
            } else if !state.currentComposition.isEmpty {
                deleteInlinePreedit()
                insertText(state.currentComposition)
                state.currentComposition = ""
                effects.insert(.compositionChanged)
            }
            state.currentPage = .numbers
        case .numbers:
            state.currentPage = .symbols
        case .symbols:
            state.currentPage = .letters
        }

        effects.insert(.pageChanged)
        return effects
    }

    /// 切换中英文输入模式。
    ///
    /// 副作用：
    /// - 如果有未完成的拼音组合，先上屏再切换
    /// - 如果当前不在字母页，切回字母页
    /// - 切换到中文时，自动重置大写状态（auto-cap 只在英文模式有效）
    func handleToggleInputMode() -> KeyboardEffect {
        var effects: KeyboardEffect = []

        if let engine = rimeEngine, engine.isComposing() {
            deleteInlinePreedit()
            insertText(state.currentComposition)
            engine.resetSession()
            state.currentComposition = ""
            state.lastRimeOutput = nil
            effects.insert(.compositionChanged)
        } else if !state.currentComposition.isEmpty {
            deleteInlinePreedit()
            insertText(state.currentComposition)
            state.currentComposition = ""
            effects.insert(.compositionChanged)
        }

        let switchingToChinese = state.inputMode == .english
        state.inputMode = switchingToChinese ? .chinese : .english
        effects.insert(.inputModeChanged)
        Logger.shared.debug("Input mode switched to \(switchingToChinese ? "中文" : "英文")", category: .general)

        if state.currentPage != .letters {
            state.currentPage = .letters
            effects.insert(.pageChanged)
        }

        // 切换到中文模式时清除之前英文模式下设置的自动大写（单次大写 / Caps Lock）
        // 这是正确的行为：中文输入不涉及字母大小写，保留大写状态会让用户困惑
        if switchingToChinese && state.shiftState != .off {
            state.shiftState = .off
            state.lastShiftTapTime = nil
            effects.insert(.shiftStateChanged)
        }

        return effects
    }

    func consumeSingleUseShiftIfNeeded() -> KeyboardEffect {
        guard state.shiftState == .singleUse else { return [] }
        state.shiftState = .off
        state.lastShiftTapTime = nil
        return .shiftStateChanged
    }

    func resetShiftState() -> KeyboardEffect {
        let wasActive = state.shiftState != .off
        state.shiftState = .off
        state.lastShiftTapTime = nil
        return wasActive ? .shiftStateChanged : []
    }
}

// MARK: - Space / Return

extension KeyboardController {

    func handleInsertSpace() -> KeyboardEffect {
        if let engine = rimeEngine, engine.isComposing() {
            let result = engine.selectCandidate(at: 0)
            state.lastRimeOutput = result
            state.currentComposition = result.composition?.preeditText ?? ""
            deleteInlinePreedit()
            if let commit = result.committedText {
                insertText(commit)
            }
            state.lastSpaceTapTime = nil
            return .compositionChanged
        }
        if !state.currentComposition.isEmpty {
            let first = candidateProvider.candidates(for: state.currentComposition).first ?? state.currentComposition
            deleteInlinePreedit()
            insertText(first)
            state.currentComposition = ""
            state.lastSpaceTapTime = nil
            return .compositionChanged
        }

        guard state.currentPage == .letters && state.inputMode == .english else {
            state.lastSpaceTapTime = nil
            insertText(" ")
            return []
        }

        let now = currentDate()
        let isDoubleSpace = state.lastSpaceTapTime.map { now.timeIntervalSince($0) < 0.45 } ?? false
        state.lastSpaceTapTime = now

        if isDoubleSpace {
            textClient?.deleteBackward()
            insertText(". ")
            state.lastSpaceTapTime = nil
        } else {
            insertText(" ")
        }

        return []
    }

    func handleInsertReturn() -> KeyboardEffect {
        if !state.currentComposition.isEmpty {
            deleteInlinePreedit()
            insertText(state.currentComposition)
            state.currentComposition = ""
            state.lastRimeOutput = nil
            state.insertedPreeditCount = 0
            rimeEngine?.resetSession()
            return .compositionChanged
        } else {
            insertText("\n")
            return []
        }
    }
}

// MARK: - Delete

extension KeyboardController {

    func handleDeleteBackward() -> KeyboardEffect {
        if let engine = rimeEngine, engine.isComposing() {
            let result = engine.deleteBackward()
            state.lastRimeOutput = result
            state.currentComposition = result.composition?.preeditText ?? ""
            updateInlinePreedit(state.currentComposition)
            return .compositionChanged
        }
        if !state.currentComposition.isEmpty {
            state.currentComposition.removeLast()
            updateInlinePreedit(state.currentComposition)
            return .compositionChanged
        } else {
            textClient?.deleteBackward()
            return []
        }
    }
}

// MARK: - Keyboard type

extension KeyboardController {

    func handleKeyboardTypeChanged(_ type: KeyboardType) -> KeyboardEffect {
        guard type != state.activeKeyboardType else { return [] }
        state.activeKeyboardType = type
        var effects: KeyboardEffect = .keyboardTypeChanged

        if type == .emailAddress || type == .URL || type == .webSearch {
            if !state.currentComposition.isEmpty {
                deleteInlinePreedit()
                insertText(state.currentComposition)
                state.currentComposition = ""
                effects.insert(.compositionChanged)
            }
            state.inputMode = .english
            effects.insert(.inputModeChanged)
            Logger.shared.debug("Input mode auto-switched to English for keyboard type \(type)", category: .general)
        }

        return effects
    }
}

// MARK: - Auto-capitalization

extension KeyboardController {

    static let sentenceTerminators: Set<Character> = [
        ".", "!", "?", "。", "！", "？"
    ]

    static func isSentenceTerminator(_ text: String) -> Bool {
        text.count == 1 && sentenceTerminators.contains(text.first!)
    }

    public func shouldAutoCapitalize(contextBeforeInput: String?) -> Bool {
        guard let context = contextBeforeInput else {
            return true
        }
        if context.isEmpty {
            return true
        }
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let lastChar = trimmed.last else {
            return true
        }
        return Self.sentenceTerminators.contains(lastChar)
    }

    @discardableResult
    public func applyAutoCapitalization(contextBeforeInput: String?) -> KeyboardEffect {
        guard state.inputMode == .english else { return [] }
        guard state.shiftState == .off else { return [] }
        guard shouldAutoCapitalize(contextBeforeInput: contextBeforeInput) else { return [] }

        state.shiftState = .singleUse
        return .shiftStateChanged
    }
}

// MARK: - Private helpers

extension KeyboardController {

    func commitComposition() {
        guard !state.currentComposition.isEmpty else { return }
        deleteInlinePreedit()
        insertText(state.currentComposition)
        state.currentComposition = ""
    }

    func insertText(_ text: String) {
        textClient?.insertText(text)
    }

    // MARK: - Inline preedit

    /// 更新输入框中显示的拼音串：先删除旧的，再插入新的。
    /// 实现类似原生键盘的 inline composition 效果。
    func updateInlinePreedit(_ text: String) {
        deleteInlinePreedit()
        guard !text.isEmpty else { return }
        insertText(text)
        state.insertedPreeditCount = text.count
    }

    /// 从输入框中删除当前已插入的拼音串。
    func deleteInlinePreedit() {
        guard state.insertedPreeditCount > 0 else { return }
        for _ in 0..<state.insertedPreeditCount {
            textClient?.deleteBackward()
        }
        state.insertedPreeditCount = 0
    }
}
