import Foundation

public final class KeyboardController {

    // MARK: - Public properties

    public internal(set) var state: KeyboardState
    public var textClient: TextInputClient?
    public let candidateProvider: CandidateProvider

    public var currentDate: () -> Date = { Date() }

    // MARK: - Init

    public init(
        state: KeyboardState = KeyboardState(),
        candidateProvider: CandidateProvider = FakeCandidateProvider()
    ) {
        self.state = state
        self.candidateProvider = candidateProvider
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
            if state.currentComposition.isEmpty && state.shiftState != .off {
                // 首字母大写进拼音组合，但不匹配中文候选。
                // 用户想打英文就按回车，误触就删掉重新输入小写。
                state.currentComposition += key
            } else {
                state.currentComposition += key.lowercased()
            }
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

    func handleInsertCandidate(_ candidate: String, kind: String) -> KeyboardEffect {
        guard kind != "placeholder" else { return [] }

        if kind == "composition" {
            commitComposition()
        } else {
            insertText(candidate)
            state.currentComposition = ""
        }
        return .compositionChanged
    }

    func handleInsertDirectText(_ text: String) -> KeyboardEffect {
        var effects: KeyboardEffect = []
        if !state.currentComposition.isEmpty {
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

        if isDoubleTap {
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
            if !state.currentComposition.isEmpty {
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

    func handleToggleInputMode() -> KeyboardEffect {
        var effects: KeyboardEffect = []

        if !state.currentComposition.isEmpty {
            insertText(state.currentComposition)
            state.currentComposition = ""
            effects.insert(.compositionChanged)
        }

        state.inputMode = state.inputMode == .chinese ? .english : .chinese
        effects.insert(.inputModeChanged)

        if state.currentPage != .letters {
            state.currentPage = .letters
            effects.insert(.pageChanged)
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
        if !state.currentComposition.isEmpty {
            let first = candidateProvider.candidates(for: state.currentComposition).first ?? state.currentComposition
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
            insertText(state.currentComposition)
            state.currentComposition = ""
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
        if !state.currentComposition.isEmpty {
            state.currentComposition.removeLast()
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
                insertText(state.currentComposition)
                state.currentComposition = ""
                effects.insert(.compositionChanged)
            }
            state.inputMode = .english
            effects.insert(.inputModeChanged)
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
        insertText(state.currentComposition)
        state.currentComposition = ""
    }

    func insertText(_ text: String) {
        textClient?.insertText(text)
    }
}
