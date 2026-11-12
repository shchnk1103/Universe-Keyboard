import Foundation
import UIKit

/// Values returned from the worker never retain an oversized clipboard payload.
nonisolated enum ClipboardPreviewResult: Sendable, Equatable {
    case unavailable
    case denied
    case text(full: String, summary: String, isLink: Bool)
    case oversized(summary: String, utf16Length: Int, isLink: Bool)
}

nonisolated protocol ClipboardPreviewReading: Sendable {
    func read() -> ClipboardPreviewResult
}

/// The only keyboard source allowed to access the system pasteboard.
nonisolated struct ClipboardPreviewReader: ClipboardPreviewReading {
    func read() -> ClipboardPreviewResult {
        guard let text = UIPasteboard.general.string else { return .denied }
        return ClipboardPreviewFormatter.makeResult(text)
    }
}

nonisolated enum ClipboardPreviewFormatter {
    static func makeResult(_ text: String) -> ClipboardPreviewResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .unavailable }
        let summary = String(mask(trimmed, characterCount: text.count).prefix(64))
        let length = text.utf16.count
        let url = URLComponents(string: trimmed)
        let isLink = ["http", "https"].contains(url?.scheme?.lowercased() ?? "") && url?.host != nil
        if length > 8_000 { return .oversized(summary: summary, utf16Length: length, isLink: isLink) }
        return .text(full: text, summary: summary, isLink: isLink)
    }

    private static func mask(_ text: String, characterCount: Int) -> String {
        let masked = "••••••（\(characterCount) 字）"
        if text.contains("-----BEGIN ") || isCard(text) { return masked }
        var words: [String] = []
        for word in text.split(whereSeparator: { $0.isWhitespace }).map(String.init) {
            if let components = URLComponents(string: word),
                let scheme = components.scheme?.lowercased(),
                (scheme == "http" || scheme == "https"), let host = components.host
            {
                let displayHost = host.lowercased().hasPrefix("www.") ? String(host.dropFirst(4)) : host
                let path = components.percentEncodedPath.split(
                    separator: "/", omittingEmptySubsequences: false
                ).map { part in
                    let segment = String(part).removingPercentEncoding ?? String(part)
                    return isSensitive(segment) ? "…" : segment
                }.joined(separator: "/")
                words.append(displayHost + path)
            } else {
                if isSensitive(word) { return masked }
                words.append(word)
            }
        }
        return words.joined(separator: " ")
    }

    private static func isCard(_ value: String) -> Bool {
        let digits = value.filter { $0 != " " && $0 != "-" && $0 != "." }
        return (13...19).contains(digits.count) && digits.allSatisfy(\.isNumber)
    }

    private static func isSensitive(_ word: String) -> Bool {
        if isCard(word) { return true }
        if word.range(of: #"^[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}$"#, options: .regularExpression)
            != nil
        {
            return true
        }
        if word.range(of: #"^(?:AKIA|ASIA)[0-9A-Z]{16}$"#, options: .regularExpression) != nil {
            return true
        }
        let chars = Array(word)
        let hasLetter = chars.contains(where: \.isLetter)
        let hasDigit = chars.contains(where: \.isNumber)
        if chars.count >= 32 && hasLetter && hasDigit { return true }
        if chars.count >= 20 && hasLetter && hasDigit {
            let kinds = chars.compactMap { character -> Int? in
                if character.isLetter { return 1 }
                if character.isNumber { return 2 }
                return nil
            }
            let transitions = zip(kinds, kinds.dropFirst()).filter { $0 != $1 }.count
            if transitions >= 3 { return true }
        }
        if (8...19).contains(chars.count), hasDigit,
            chars.contains(where: \.isLowercase),
            chars.contains(where: \.isUppercase),
            chars.contains(where: { !$0.isLetter && !$0.isNumber && !"-_.".contains($0) })
        {
            return true
        }
        return false
    }
}

/// Serial worker with a revocable gate checked immediately before the getter.
nonisolated final class ClipboardPreviewGate: @unchecked Sendable {
    private let lock = NSLock()
    private var active = true
    private var started = false
    private let deadline: UInt64

    init(deadline: UInt64) { self.deadline = deadline }

    func begin() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard active, !started, DispatchTime.now().uptimeNanoseconds < deadline else { return false }
        started = true
        return true
    }

    func cancel() {
        lock.lock()
        active = false
        lock.unlock()
    }
}

nonisolated final class ClipboardPreviewWorker: Sendable {
    static let shared = ClipboardPreviewWorker()
    private let queue = DispatchQueue(label: "keyboard.clipboard.preview")

    func submit(
        reader: any ClipboardPreviewReading,
        gate: ClipboardPreviewGate,
        completion: @escaping @Sendable (ClipboardPreviewResult) -> Void
    ) {
        queue.async {
            guard gate.begin() else { return }
            let result = reader.read()
            completion(result)
        }
    }
}
