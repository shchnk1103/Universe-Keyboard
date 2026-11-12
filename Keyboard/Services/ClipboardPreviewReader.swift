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

/// Production stays false until S13–S17 pass and a later change turns this on.
/// Tests inject `PasteToolbarSession.emptyDetectionEnabled` instead of editing it.
nonisolated enum ClipboardEmptyDetection {
    static let emptyDetectionProbesPassed = false
}

nonisolated struct ClipboardCountSample: Sendable, Equatable {
    var itemCount: Int
    var changeCountBefore: Int
    var changeCountAfter: Int
}

/// Counts and versions only. Implementations must not read string, items, or type payloads.
nonisolated protocol ClipboardMetadataReading: Sendable {
    func readCounts() -> ClipboardCountSample
    func readChangeCount() -> Int
}

nonisolated struct SystemClipboardMetadataReader: ClipboardMetadataReading {
    func readCounts() -> ClipboardCountSample {
        let board = UIPasteboard.general
        let before = board.changeCount
        let itemCount = board.numberOfItems
        let after = board.changeCount
        return ClipboardCountSample(itemCount: itemCount, changeCountBefore: before, changeCountAfter: after)
    }

    func readChangeCount() -> Int { UIPasteboard.general.changeCount }
}

nonisolated enum PasteDisplayDecision: Equatable { case wait, omit, fallback, preview, hidden }

nonisolated struct PasteDisplayFacts: Equatable {
    enum Content: Equatable { case pending, denied, blank, text, discarded, timedOut }
    enum Metadata: Equatable {
        case notRequested, pending, empty(version: Int), nonempty, unavailable, timedOut
    }
    enum FinalVersion: Equatable { case notNeeded, pending, equal, mismatch, incomparable, timedOut }
    var probesPassed = false
    var enabled = true
    var fullAccess = true
    var generationCurrent = true
    var suspended = false
    var eligible = true
    var armed = true
    var content: Content = .pending
    var metadata: Metadata = .notRequested
    var finalVersion: FinalVersion = .notNeeded
}

/// P1-A rules 0→6. Rule 7 is enforced by the session once a decision is sealed.
nonisolated enum PasteDisplayPlanner {
    static func decide(_ facts: PasteDisplayFacts) -> PasteDisplayDecision {
        if !facts.enabled || !facts.fullAccess || !facts.generationCurrent || facts.suspended || !facts.eligible
            || !facts.armed
        {
            return .omit
        }
        switch facts.content {
        case .denied, .discarded, .timedOut: return .fallback
        case .pending: return .wait
        case .blank, .text: break
        }
        if case .empty = facts.metadata {
            switch facts.finalVersion {
            case .mismatch, .incomparable, .timedOut: return .fallback
            case .pending, .notNeeded: return .wait
            case .equal: break
            }
        }
        switch facts.metadata {
        case .timedOut: return .fallback
        case .pending: return .wait
        case .notRequested, .nonempty, .unavailable, .empty: break
        }
        if case .text = facts.content { return .preview }
        if facts.probesPassed, case .empty = facts.metadata, case .equal = facts.finalVersion { return .hidden }
        return .fallback
    }
}

/// Serial worker with a revocable gate checked immediately before the getter.
nonisolated final class ClipboardPreviewGate: @unchecked Sendable {
    private let lock = NSLock()
    private var active = true
    private var started = false
    private let deadline: UInt64
    private var checksSnapshot = false
    private var expectedToken: UInt64 = 0
    private var expectedGeneration: UInt64 = 0
    private var liveEnabled = false
    private var liveFullAccess = false
    private var liveEligible = false
    private var liveGeneration: UInt64 = 0
    private var liveToken: UInt64 = 0

    init(deadline: UInt64) { self.deadline = deadline }

    func adopt(token: UInt64, generation: UInt64, enabled: Bool, fullAccess: Bool, eligible: Bool) {
        lock.lock()
        checksSnapshot = true
        expectedToken = token
        expectedGeneration = generation
        liveToken = token
        liveGeneration = generation
        liveEnabled = enabled
        liveFullAccess = fullAccess
        liveEligible = eligible
        lock.unlock()
    }

    func updateLive(token: UInt64, generation: UInt64, enabled: Bool, fullAccess: Bool, eligible: Bool) {
        lock.lock()
        liveToken = token
        liveGeneration = generation
        liveEnabled = enabled
        liveFullAccess = fullAccess
        liveEligible = eligible
        lock.unlock()
    }

    func begin() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard active, !started, DispatchTime.now().uptimeNanoseconds < deadline else { return false }
        if checksSnapshot {
            guard snapshotMatches else { return false }
        }
        started = true
        return true
    }

    /// Metadata may sample twice (counts, then the final change count). Each call rechecks the lock.
    func authorizeMetadata() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard active, DispatchTime.now().uptimeNanoseconds < deadline, checksSnapshot, snapshotMatches else {
            return false
        }
        return true
    }

    func cancel() {
        lock.lock()
        active = false
        lock.unlock()
    }

    private var snapshotMatches: Bool {
        liveEnabled && liveFullAccess && liveEligible && liveGeneration == expectedGeneration
            && liveToken == expectedToken
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

/// Separate serial queue so a blocked content read cannot delay the count check, or the reverse.
nonisolated final class ClipboardMetadataWorker: Sendable {
    static let shared = ClipboardMetadataWorker()
    private let queue = DispatchQueue(label: "keyboard.clipboard.metadata")

    func submitCounts(
        reader: any ClipboardMetadataReading,
        gate: ClipboardPreviewGate,
        completion: @escaping @Sendable (ClipboardCountSample) -> Void
    ) {
        queue.async {
            guard gate.authorizeMetadata() else { return }
            completion(reader.readCounts())
        }
    }

    func submitChangeCount(
        reader: any ClipboardMetadataReading,
        gate: ClipboardPreviewGate,
        completion: @escaping @Sendable (Int) -> Void
    ) {
        queue.async {
            guard gate.authorizeMetadata() else { return }
            completion(reader.readChangeCount())
        }
    }
}
