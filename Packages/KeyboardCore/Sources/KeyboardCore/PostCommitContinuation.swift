import Foundation

public struct ContinuationEntry: Codable, Equatable, Sendable {
    public let context: String
    public let suggestions: [String]

    public init(context: String, suggestions: [String]) {
        self.context = context
        self.suggestions = suggestions
    }
}

public protocol ContinuationSuggestionProviding: Sendable {
    func suggestions(for context: String, limit: Int) -> [String]
}

enum ContinuationLexiconValidationError: Error, Equatable {
    case tooManyEntries(Int)
    case invalidContext(index: Int)
    case duplicateContext(String)
    case invalidSuggestionCount(context: String, count: Int)
    case invalidSuggestion(context: String, index: Int)
    case duplicateSuggestion(context: String, suggestion: String)
}

enum ContinuationLexiconValidator {
    /// V1.3 intentionally remains below a few thousand entries. Raising this
    /// ceiling requires new Extension startup and memory evidence.
    static let maximumEntryCount = 4_096
    static let maximumTextLength = ContinuationState.maximumContextLength
    static let maximumSuggestionCount = ContinuationState.maximumSuggestionCount

    static func validate(_ entries: [ContinuationEntry]) throws {
        guard entries.count <= maximumEntryCount else {
            throw ContinuationLexiconValidationError.tooManyEntries(entries.count)
        }

        var contexts = Set<String>()
        for (entryIndex, entry) in entries.enumerated() {
            guard isValidText(entry.context), contexts.insert(entry.context).inserted else {
                if contexts.contains(entry.context) {
                    throw ContinuationLexiconValidationError.duplicateContext(entry.context)
                }
                throw ContinuationLexiconValidationError.invalidContext(index: entryIndex)
            }
            guard (1...maximumSuggestionCount).contains(entry.suggestions.count) else {
                throw ContinuationLexiconValidationError.invalidSuggestionCount(
                    context: entry.context,
                    count: entry.suggestions.count
                )
            }

            var suggestions = Set<String>()
            for (suggestionIndex, suggestion) in entry.suggestions.enumerated() {
                guard isValidText(suggestion) else {
                    throw ContinuationLexiconValidationError.invalidSuggestion(
                        context: entry.context,
                        index: suggestionIndex
                    )
                }
                guard suggestions.insert(suggestion).inserted else {
                    throw ContinuationLexiconValidationError.duplicateSuggestion(
                        context: entry.context,
                        suggestion: suggestion
                    )
                }
            }
        }
    }

    private static func isValidText(_ text: String) -> Bool {
        !text.isEmpty
            && text.count <= maximumTextLength
            && !text.contains(where: { $0 == "\n" || $0 == "\r" })
    }
}

/// A deterministic, read-only continuation provider.
///
/// Entries are indexed once during initialization. A lookup walks suffix lengths
/// from longest to shortest and never scans or reads files in the key path.
public struct BundledContinuationSuggestionProvider: ContinuationSuggestionProviding, Sendable {
    public static let shared = BundledContinuationSuggestionProvider.loadBundledResource()

    static let maximumBundledResourceBytes = 512 * 1_024

    private struct Resource: Decodable {
        let version: Int
        let contentVersion: String
        let entries: [ContinuationEntry]
    }

    private let suggestionsByContext: [String: [String]]
    private let maximumContextLength: Int

    var indexedEntryCount: Int { suggestionsByContext.count }

    public init(entries: [ContinuationEntry]) {
        var index: [String: [String]] = [:]
        var maximumLength = 0

        for entry in entries where !entry.context.isEmpty && index[entry.context] == nil {
            var seen = Set<String>()
            let suggestions = entry.suggestions.filter { !$0.isEmpty && seen.insert($0).inserted }
            guard !suggestions.isEmpty else { continue }
            index[entry.context] = suggestions
            maximumLength = max(maximumLength, entry.context.count)
        }

        suggestionsByContext = index
        maximumContextLength = maximumLength
    }

    init(validating entries: [ContinuationEntry]) throws {
        try ContinuationLexiconValidator.validate(entries)
        self.init(entries: entries)
    }

    public func suggestions(for context: String, limit: Int = 8) -> [String] {
        guard !context.isEmpty, limit > 0, maximumContextLength > 0 else { return [] }

        let upperBound = min(context.count, maximumContextLength)
        for length in stride(from: upperBound, through: 1, by: -1) {
            let suffix = String(context.suffix(length))
            if let suggestions = suggestionsByContext[suffix] {
                return Array(suggestions.prefix(limit))
            }
        }
        return []
    }

    private static func loadBundledResource() -> Self {
        guard let url = Bundle.module.url(
            forResource: "post_commit_continuations_v1_3",
            withExtension: "json"
        ),
        let data = try? Data(contentsOf: url),
        let provider = provider(fromResourceData: data)
        else {
            return Self(entries: [])
        }

        return provider
    }

    static func provider(fromResourceData data: Data) -> Self? {
        guard data.count <= maximumBundledResourceBytes,
        let resource = try? JSONDecoder().decode(Resource.self, from: data),
        resource.version == 1,
        resource.contentVersion == "1.3.0",
        let provider = try? Self(validating: resource.entries)
        else {
            return nil
        }

        return provider
    }
}

public struct ContinuationState: Equatable, Sendable {
    public static let maximumContextLength = 32
    public static let maximumSuggestionCount = 8

    public var context: String
    public var suggestions: [String]

    public init(context: String = "", suggestions: [String] = []) {
        self.context = context
        self.suggestions = suggestions
    }

    public var isEmpty: Bool {
        context.isEmpty && suggestions.isEmpty
    }
}
