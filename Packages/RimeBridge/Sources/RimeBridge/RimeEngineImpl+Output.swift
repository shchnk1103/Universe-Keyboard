import Foundation
import KeyboardCore

extension RimeEngineImpl {
    /// Converts the bridge dictionary into the typed state consumed by KeyboardCore.
    func parseOutput(_ raw: [AnyHashable: Any]) -> KeyboardCore.RimeOutput {
        let preedit = raw[RimeKey.preedit] as? String
        let cursorPosition = (raw[RimeKey.cursorPosition] as? NSNumber)?.intValue ?? 0
        let composition = preedit.flatMap { value -> KeyboardCore.RimeComposition? in
            guard !value.isEmpty else { return nil }
            return KeyboardCore.RimeComposition(preeditText: value, cursorPosition: cursorPosition)
        }

        let rawCandidates = raw[RimeKey.candidates] as? [[String: String]] ?? []
        let candidates = rawCandidates.map { item in
            KeyboardCore.RimeCandidate(
                text: item[RimeKey.candidateText] ?? "",
                comment: item[RimeKey.candidateComment]
            )
        }

        let isLastPage = (raw[RimeKey.isLastPage] as? NSNumber)?.boolValue ?? true
        return KeyboardCore.RimeOutput(
            composition: composition,
            candidates: candidates,
            committedText: raw[RimeKey.commit] as? String,
            hasMorePages: !isLastPage,
            highlightedIndex: (raw[RimeKey.highlightedIndex] as? NSNumber)?.intValue ?? -1
        )
    }
}

private enum RimeKey {
    static let preedit = "preedit"
    static let cursorPosition = "cursorPos"
    static let candidates = "candidates"
    static let candidateText = "text"
    static let candidateComment = "comment"
    static let commit = "commit"
    static let isLastPage = "isLastPage"
    static let highlightedIndex = "highlightedIndex"
}
