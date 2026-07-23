import Foundation
import KeyboardCore

extension RimeEngineImpl {
    /// Converts the bridge dictionary into the typed state consumed by KeyboardCore.
    func parseOutput(_ raw: [AnyHashable: Any]) -> KeyboardCore.RimeOutput {
        Self.parseOutputDictionary(raw)
    }

    /// Pure parsing entry point used by contract tests without creating a live librime session.
    static func parseOutputDictionary(_ raw: [AnyHashable: Any]) -> KeyboardCore.RimeOutput {
        let preedit = raw[RimeKey.preedit] as? String
        let cursorPosition = (raw[RimeKey.cursorPosition] as? NSNumber)?.intValue ?? 0
        // Optional: older dictionaries may omit selStart/selEnd entirely.
        let selectionStart = optionalInt(raw[RimeKey.selStart])
        let selectionEnd = optionalInt(raw[RimeKey.selEnd])
        let compositionLength = optionalInt(raw[RimeKey.compositionLength])
        let composition = preedit.flatMap { value -> KeyboardCore.RimeComposition? in
            guard !value.isEmpty else { return nil }
            return KeyboardCore.RimeComposition(
                preeditText: value,
                cursorPosition: cursorPosition,
                selectionStart: selectionStart,
                selectionEnd: selectionEnd,
                length: compositionLength
            )
        }

        let candidates = parseCandidates(raw[RimeKey.candidates])

        let isLastPage = (raw[RimeKey.isLastPage] as? NSNumber)?.boolValue ?? true
        return KeyboardCore.RimeOutput(
            rawInput: raw[RimeKey.rawInput] as? String,
            composition: composition,
            candidates: candidates,
            committedText: raw[RimeKey.commit] as? String,
            hasMorePages: !isLastPage,
            highlightedIndex: (raw[RimeKey.highlightedIndex] as? NSNumber)?.intValue ?? -1,
            candidatePageNumber: (raw[RimeKey.pageNumber] as? NSNumber)?.intValue ?? 0,
            caretPositionInRaw: optionalInt(raw[RimeKey.caretPos]),
            commitPreviewLength: optionalInt(raw[RimeKey.commitPreviewLen])
        )
    }

    static func parseCandidateWindowDictionary(_ raw: [AnyHashable: Any]) -> KeyboardCore.RimeCandidateWindow {
        let candidates = parseCandidates(raw[RimeKey.candidates])
        let startIndex = (raw[RimeKey.windowStartIndex] as? NSNumber)?.intValue ?? 0
        let nextIndex = (raw[RimeKey.windowNextIndex] as? NSNumber)?.intValue ?? startIndex + candidates.count
        let hasMore = (raw[RimeKey.windowHasMore] as? NSNumber)?.boolValue ?? false
        return KeyboardCore.RimeCandidateWindow(
            candidates: candidates,
            startIndex: startIndex,
            nextIndex: nextIndex,
            hasMoreCandidates: hasMore
        )
    }

    /// ObjC bridge returns Foundation collections. Avoid depending on one
    /// specific Swift generic cast, otherwise a valid RIME candidate array can
    /// be parsed as empty on a different bridge shape.
    private static func parseCandidates(_ rawValue: Any?) -> [KeyboardCore.RimeCandidate] {
        let rawItems: [Any]
        if let array = rawValue as? [Any] {
            rawItems = array
        } else if let array = rawValue as? NSArray {
            rawItems = array.map { $0 }
        } else {
            return []
        }

        return rawItems.compactMap { rawItem in
            let item = normalizedCandidateDictionary(rawItem)
            let text = item[RimeKey.candidateText] as? String
            guard let text, !text.isEmpty else { return nil }
            return KeyboardCore.RimeCandidate(
                text: text,
                comment: item[RimeKey.candidateComment] as? String,
                globalIndex: (item[RimeKey.candidateGlobalIndex] as? NSNumber)?.intValue
                    ?? item[RimeKey.candidateGlobalIndex] as? Int
            )
        }
    }

    private static func normalizedCandidateDictionary(_ rawItem: Any) -> [String: Any] {
        if let item = rawItem as? [String: Any] { return item }
        if let item = rawItem as? [AnyHashable: Any] {
            return item.reduce(into: [:]) { result, pair in
                guard let key = pair.key as? String else { return }
                result[key] = pair.value
            }
        }
        if let item = rawItem as? NSDictionary {
            var result: [String: Any] = [:]
            item.forEach { key, value in
                guard let key = key as? String else { return }
                result[key] = value
            }
            return result
        }
        return [:]
    }

    /// Accepts NSNumber / Int from ObjC or pure-Swift dictionaries; missing → nil.
    private static func optionalInt(_ value: Any?) -> Int? {
        if let number = value as? NSNumber {
            return number.intValue
        }
        if let intValue = value as? Int {
            return intValue
        }
        return nil
    }
}

private enum RimeKey {
    static let preedit = "preedit"
    static let cursorPosition = "cursorPos"
    static let selStart = "selStart"
    static let selEnd = "selEnd"
    static let compositionLength = "compositionLength"
    static let caretPos = "caretPos"
    static let commitPreviewLen = "commitPreviewLen"
    static let rawInput = "rawInput"
    static let candidates = "candidates"
    static let candidateText = "text"
    static let candidateComment = "comment"
    static let candidateGlobalIndex = "globalIndex"
    static let commit = "commit"
    static let isLastPage = "isLastPage"
    static let highlightedIndex = "highlightedIndex"
    static let pageNumber = "pageNo"
    static let windowStartIndex = "startIndex"
    static let windowNextIndex = "nextIndex"
    static let windowHasMore = "hasMoreCandidates"
}
