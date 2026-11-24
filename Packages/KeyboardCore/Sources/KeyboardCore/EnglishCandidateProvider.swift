import Foundation

/// English-mode prefix candidate contract. Implementations are read-only and
/// must index their wordlist once during initialization; per-query lookups are
/// pure memory (no file IO on the typing hot path, ADR 0007 discipline).
public protocol EnglishCandidateProviding: Sendable {
    /// Identity of the wordlist the candidates come from. Suggestions stored
    /// in `KeyboardState` are bound to this version so a provider swap cannot
    /// silently re-authorize stale candidates.
    var sourceVersion: String { get }

    func candidates(for prefix: String, limit: Int) -> [String]
}

public extension EnglishCandidateProviding {
    func candidates(for prefix: String) -> [String] {
        candidates(
            for: prefix,
            limit: EnglishCandidateState.maximumSuggestionCount
        )
    }
}

/// In-memory snapshot of the English word being typed and its prefix
/// candidates. Mirrors `ContinuationState`: never persisted, fully owned by
/// the controller, cleared on the documented invalidation events.
public struct EnglishCandidateState: Equatable, Sendable {
    public static let maximumPrefixLength = 32
    public static let maximumSuggestionCount = 8

    /// The ASCII word currently being typed, exactly as entered (case kept
    /// for display alignment; lookups lowercase it).
    public var prefix: String
    public var suggestions: [String]
    public var sourceVersion: String

    public var isEmpty: Bool {
        prefix.isEmpty && suggestions.isEmpty && sourceVersion.isEmpty
    }

    public init(prefix: String = "", suggestions: [String] = [], sourceVersion: String = "") {
        self.prefix = prefix
        self.suggestions = suggestions
        self.sourceVersion = sourceVersion
    }
}

enum EnglishWordlistValidationError: Error, Equatable {
    case tooManyEntries(Int)
    case invalidWord(index: Int, word: String)
    case duplicateWord(String)
}

enum EnglishWordlistValidator {
    /// The v1 wordlist holds ~21k entries. Raising this ceiling or the byte
    /// cap below requires new Extension startup and memory evidence, matching
    /// the continuation lexicon policy.
    static let maximumEntryCount = 32_768
    /// The v1 generation pipeline already excludes single-letter entries;
    /// enforcing the floor here keeps the pinned resource and hand-built
    /// lists on the same contract.
    static let minimumWordLength = 2
    static let maximumWordLength = 12

    static func validate(_ words: [String]) throws {
        guard words.count <= maximumEntryCount else {
            throw EnglishWordlistValidationError.tooManyEntries(words.count)
        }

        var seen = Set<String>()
        for (index, word) in words.enumerated() {
            guard isValidWord(word) else {
                throw EnglishWordlistValidationError.invalidWord(index: index, word: word)
            }
            guard seen.insert(word).inserted else {
                throw EnglishWordlistValidationError.duplicateWord(word)
            }
        }
    }

    private static func isValidWord(_ word: String) -> Bool {
        guard word.count >= minimumWordLength, word.count <= maximumWordLength else { return false }
        return word.unicodeScalars.allSatisfy { scalar in
            (0x61...0x7A).contains(scalar.value)  // lowercase ASCII a-z only
        }
    }
}

/// Aligns a lowercase wordlist entry to the case the user typed.
public enum EnglishCandidateCase {
    /// "ap" → "apple", "Ap" → "Apple", "AP" → "APPLE". Prefixes containing
    /// non-letter scalars never rewrite the stored word.
    public static func aligned(prefix: String, word: String) -> String {
        guard let first = prefix.unicodeScalars.first, !word.isEmpty else { return word }
        guard prefix.unicodeScalars.allSatisfy(Self.isASCIILetter) else { return word }

        if prefix.unicodeScalars.allSatisfy({ (0x41...0x5A).contains($0.value) }) {
            return word.uppercased()
        }
        if (0x41...0x5A).contains(first.value) {
            return word.prefix(1).uppercased() + word.dropFirst()
        }
        return word
    }

    private static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        (0x41...0x5A).contains(scalar.value) || (0x61...0x7A).contains(scalar.value)
    }
}

/// A deterministic, read-only English wordlist provider.
///
/// Words are sorted once during initialization; every lookup is a binary
/// search over that array and never scans or reads files in the key path.
public struct BundledEnglishCandidateProvider: EnglishCandidateProviding, Sendable {
    public static let shared = BundledEnglishCandidateProvider.loadBundledResource()

    static let maximumBundledResourceBytes = 256 * 1_024
    public static let resourceVersion = 1
    public static let contentVersion = "1.0.0"

    private struct Resource: Decodable {
        let version: Int
        let contentVersion: String
        let words: [String]
    }

    private let sortedWords: [String]

    public let sourceVersion: String

    var wordCount: Int { sortedWords.count }

    /// Lenient constructor: filters empty and non-lowercase-ASCII entries and
    /// dedupes, mirroring `BundledContinuationSuggestionProvider.init(entries:)`.
    public init(words: [String], sourceVersion: String) {
        self.sourceVersion = sourceVersion
        sortedWords = Set(
            words.filter { word in
                !word.isEmpty
                    && word.unicodeScalars.allSatisfy { (0x61...0x7A).contains($0.value) }
            }
        )
        .sorted()
    }

    /// Strict constructor used by the bundled resource loader and tests.
    init(validating words: [String]) throws {
        try EnglishWordlistValidator.validate(words)
        self.init(words: words, sourceVersion: BundledEnglishCandidateProvider.contentVersion)
    }

    public func candidates(for prefix: String, limit: Int) -> [String] {
        let key = prefix.lowercased()
        guard !key.isEmpty, limit > 0, !sortedWords.isEmpty else { return [] }

        var results: [String] = []
        var index = lowerBound(of: key)
        while index < sortedWords.count, sortedWords[index].hasPrefix(key) {
            results.append(sortedWords[index])
            if results.count == limit { break }
            index += 1
        }
        return results
    }

    /// First index whose word is >= `key` (binary search; pure memory).
    private func lowerBound(of key: String) -> Int {
        var low = 0
        var high = sortedWords.count
        while low < high {
            let middle = (low + high) / 2
            if sortedWords[middle] < key {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low
    }

    private static func loadBundledResource() -> Self {
        guard
            let url = Bundle.module.url(
                forResource: "english_wordlist_v1",
                withExtension: "json"
            ),
            let data = try? Data(contentsOf: url),
            let provider = provider(fromResourceData: data)
        else {
            return Self(words: [], sourceVersion: contentVersion)
        }

        return provider
    }

    static func provider(fromResourceData data: Data) -> Self? {
        guard
            data.count <= maximumBundledResourceBytes,
            let resource = try? JSONDecoder().decode(Resource.self, from: data),
            resource.version == resourceVersion,
            resource.contentVersion == contentVersion,
            let provider = try? Self(validating: resource.words)
        else {
            return nil
        }

        return provider
    }
}
