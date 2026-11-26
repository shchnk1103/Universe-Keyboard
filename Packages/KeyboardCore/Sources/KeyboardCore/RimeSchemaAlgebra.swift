import Foundation

/// Minimal interpreter for the RIME `speller/algebra` rule chain used by the
/// built-in schema templates (PB-017).
///
/// Supports the rule kinds present in those templates: `erase`, `derive`,
/// `xform`, `xlit` (plus `abbrev` for completeness). Rules apply, in order, to
/// the set of spellings of a single syllable — matching librime's algebra
/// semantics closely enough to unit-test template behavior (determinism,
/// shape invariants, upstream key mappings) without opening librime.
/// Pure Foundation; no UIKit; no extension-side deployment (ADR 0001).
public struct RimeSchemaAlgebraTransformer: Sendable, Equatable {
    /// Algebra rule kinds understood by this interpreter.
    public enum RuleKind: String, Sendable, Equatable {
        case erase
        case derive
        case xform
        case xlit
        case abbrev
    }

    /// One parsed algebra rule.
    public struct Rule: Sendable, Equatable, Hashable {
        public let kind: RuleKind
        /// Regex pattern (erase/derive/xform/abbrev) or source characters (xlit).
        public let pattern: String
        /// Replacement template or target characters (xlit); empty for `erase`.
        public let replacement: String

        public init(kind: RuleKind, pattern: String, replacement: String) {
            self.kind = kind
            self.pattern = pattern
            self.replacement = replacement
        }
    }

    /// Parsed rule chain, in template order.
    public let rules: [Rule]

    public init(rules: [Rule]) {
        self.rules = rules
    }

    /// Parses the `speller: algebra:` block out of a generated schema template.
    /// Unrecognized rule lines are skipped; the block ends at the next YAML key.
    public init(schemaYaml: String) {
        self.rules = Self.parseAlgebraRules(from: schemaYaml)
    }

    /// Applies the full rule chain to the set of spellings of one syllable.
    ///
    /// Deterministic: the same input set always yields the same output set.
    /// `derive`/`abbrev` retain the source spelling and add the derived one,
    /// `xform` replaces in place, `erase` drops matches, `xlit` transliterates
    /// character-by-character.
    public func transform(_ spellings: Set<String>) -> Set<String> {
        var current = spellings
        for rule in rules {
            current = apply(rule, to: current)
        }
        return current
    }

    // MARK: - Private

    private static func parseAlgebraRules(from yaml: String) -> [Rule] {
        var rules: [Rule] = []
        var inAlgebra = false
        for rawLine in yaml.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            guard inAlgebra else {
                if line == "algebra:" { inAlgebra = true }
                continue
            }
            if line.isEmpty || line.hasPrefix("#") { continue }
            guard line.hasPrefix("- ") else { break }
            if let rule = parseRule(line.dropFirst(2)) {
                rules.append(rule)
            }
        }
        return rules
    }

    private static func parseRule(_ body: Substring) -> Rule? {
        let parts = body.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard let kind = parts.first.flatMap(RuleKind.init(rawValue:)), parts.count >= 2 else {
            return nil
        }
        switch kind {
        case .erase:
            return Rule(kind: .erase, pattern: parts[1], replacement: "")
        case .derive, .xform, .abbrev, .xlit:
            guard parts.count >= 3 else { return nil }
            return Rule(kind: kind, pattern: parts[1], replacement: parts[2])
        }
    }

    private func apply(_ rule: Rule, to spellings: Set<String>) -> Set<String> {
        switch rule.kind {
        case .erase:
            guard let regex = makeRegex(rule.pattern) else { return spellings }
            return Set(spellings.filter { firstMatchRange(of: regex, in: $0) == nil })
        case .xform:
            guard let regex = makeRegex(rule.pattern) else { return spellings }
            return Set(
                spellings.map {
                    regex.stringByReplacingMatches(in: $0, range: matchRange($0), withTemplate: rule.replacement)
                })
        case .derive, .abbrev:
            guard let regex = makeRegex(rule.pattern) else { return spellings }
            var result = spellings
            for spelling in spellings {
                let derived = regex.stringByReplacingMatches(
                    in: spelling,
                    range: matchRange(spelling),
                    withTemplate: rule.replacement
                )
                if derived != spelling {
                    result.insert(derived)
                }
            }
            return result
        case .xlit:
            let source = rule.pattern.map(String.init)
            let target = rule.replacement.map(String.init)
            var mapping: [String: String] = [:]
            for (index, character) in source.enumerated() where index < target.count {
                mapping[character] = target[index]
            }
            return Set(
                spellings.map { spelling in
                    spelling.map { mapping[String($0)] ?? String($0) }.joined()
                })
        }
    }

    private func makeRegex(_ pattern: String) -> NSRegularExpression? {
        try? NSRegularExpression(pattern: pattern, options: [])
    }

    private func matchRange(_ spelling: String) -> NSRange {
        NSRange(location: 0, length: (spelling as NSString).length)
    }

    private func firstMatchRange(of regex: NSRegularExpression, in spelling: String) -> NSRange? {
        let range = regex.rangeOfFirstMatch(in: spelling, options: [], range: matchRange(spelling))
        return range.location == NSNotFound ? nil : range
    }
}
