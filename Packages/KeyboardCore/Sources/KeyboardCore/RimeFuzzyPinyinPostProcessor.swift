import Foundation

public struct RimeFuzzyPinyinPostProcessResult: Equatable, Sendable {
    public enum Status: Equatable, Sendable {
        case updated
        case unchanged
        case removed
        case skippedNoSpeller
    }

    public let yaml: String
    public let status: Status
}

/// Inserts Universe-managed traditional fuzzy pinyin rules into a RIME schema.
///
/// The processor only owns the marked block. Existing schema `speller/algebra`
/// rules remain untouched so upstream schema behavior stays under RIME's control.
public struct RimeFuzzyPinyinPostProcessor {
    public static let beginMarker = "# universe:fuzzy-pinyin begin"
    public static let endMarker = "# universe:fuzzy-pinyin end"

    public static func apply(
        settings: RimeFuzzyPinyinSettings,
        to yaml: String
    ) -> RimeFuzzyPinyinPostProcessResult {
        let originalLines = yaml.components(separatedBy: "\n")
        let linesWithoutManagedBlock = removingManagedBlock(from: originalLines)
        let removedExistingBlock = linesWithoutManagedBlock != originalLines

        guard settings.hasEnabledRules else {
            let output = linesWithoutManagedBlock.joined(separator: "\n")
            return RimeFuzzyPinyinPostProcessResult(
                yaml: output,
                status: removedExistingBlock ? .removed : .unchanged
            )
        }

        guard let spellerIndex = topLevelSectionIndex(named: "speller", in: linesWithoutManagedBlock) else {
            return RimeFuzzyPinyinPostProcessResult(yaml: yaml, status: .skippedNoSpeller)
        }

        var lines = linesWithoutManagedBlock
        let spellerEnd = topLevelSectionEnd(startingAt: spellerIndex, in: lines)
        if let algebraIndex = algebraIndex(in: lines, spellerStart: spellerIndex, spellerEnd: spellerEnd) {
            let insertionIndex = algebraListEnd(startingAt: algebraIndex, spellerEnd: spellerEnd, in: lines)
            lines.insert(contentsOf: managedBlockLines(rules: settings.algebraRules, indent: 4), at: insertionIndex)
        } else {
            lines.insert(contentsOf: algebraSectionLines(rules: settings.algebraRules), at: spellerEnd)
        }

        let output = lines.joined(separator: "\n")
        return RimeFuzzyPinyinPostProcessResult(
            yaml: output,
            status: output == yaml ? .unchanged : .updated
        )
    }

    private static func removingManagedBlock(from lines: [String]) -> [String] {
        var output: [String] = []
        var skipping = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == beginMarker {
                skipping = true
                continue
            }
            if skipping {
                if trimmed == endMarker {
                    skipping = false
                }
                continue
            }
            output.append(line)
        }

        return output
    }

    private static func topLevelSectionIndex(named name: String, in lines: [String]) -> Int? {
        lines.firstIndex { line in
            line.trimmingCharacters(in: .whitespaces) == "\(name):" && indentation(of: line) == 0
        }
    }

    private static func topLevelSectionEnd(startingAt index: Int, in lines: [String]) -> Int {
        guard index + 1 < lines.count else { return lines.count }
        for currentIndex in (index + 1)..<lines.count {
            let line = lines[currentIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if indentation(of: line) == 0 && !trimmed.hasPrefix("#") {
                return currentIndex
            }
        }
        return lines.count
    }

    private static func algebraIndex(in lines: [String], spellerStart: Int, spellerEnd: Int) -> Int? {
        guard spellerStart + 1 < spellerEnd else { return nil }
        return lines[(spellerStart + 1)..<spellerEnd].firstIndex { line in
            line.trimmingCharacters(in: .whitespaces) == "algebra:" && indentation(of: line) > 0
        }
    }

    private static func algebraListEnd(startingAt algebraIndex: Int, spellerEnd: Int, in lines: [String]) -> Int {
        let algebraIndent = indentation(of: lines[algebraIndex])
        guard algebraIndex + 1 < spellerEnd else { return spellerEnd }

        for currentIndex in (algebraIndex + 1)..<spellerEnd {
            let line = lines[currentIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if indentation(of: line) <= algebraIndent && !trimmed.hasPrefix("#") {
                return currentIndex
            }
        }
        return spellerEnd
    }

    private static func algebraSectionLines(rules: [String]) -> [String] {
        ["  algebra:"] + managedBlockLines(rules: rules, indent: 4)
    }

    private static func managedBlockLines(rules: [String], indent: Int) -> [String] {
        let padding = String(repeating: " ", count: indent)
        return [padding + beginMarker]
            + rules.map { padding + "- \($0)" }
            + [padding + endMarker]
    }

    private static func indentation(of line: String) -> Int {
        line.prefix { $0 == " " || $0 == "\t" }.count
    }
}
