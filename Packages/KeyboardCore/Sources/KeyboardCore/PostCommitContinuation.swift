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

/// A deterministic, read-only continuation provider.
///
/// Entries are indexed once during initialization. A lookup walks suffix lengths
/// from longest to shortest and never scans or reads files in the key path.
public struct BundledContinuationSuggestionProvider: ContinuationSuggestionProviding, Sendable {
    public static let shared = BundledContinuationSuggestionProvider.loadBundledResource()

    private struct Resource: Decodable {
        let version: Int
        let entries: [ContinuationEntry]
    }

    private let suggestionsByContext: [String: [String]]
    private let maximumContextLength: Int

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
            forResource: "post_commit_continuations_v1",
            withExtension: "json"
        ),
        let data = try? Data(contentsOf: url),
        let resource = try? JSONDecoder().decode(Resource.self, from: data),
        resource.version == 1
        else {
            return Self(entries: [])
        }

        return Self(entries: resource.entries)
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
