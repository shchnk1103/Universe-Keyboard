import Foundation

public struct RimeFuzzyPinyinPostProcessResult: Equatable, Sendable {
    public enum Status: Equatable, Sendable {
        case updated
        case unchanged
        case removed
        case skippedNoSpeller
        case skippedUnsupportedAlgebra
        case skippedMalformedManagedBlock
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
        guard let linesWithoutManagedBlock = removingManagedBlock(from: originalLines) else {
            return RimeFuzzyPinyinPostProcessResult(yaml: yaml, status: .skippedMalformedManagedBlock)
        }
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
        let isWanxiangSchema = hasTopLevelSchemaID("wanxiang", in: lines)
        let spellerEnd = topLevelSectionEnd(startingAt: spellerIndex, in: lines)
        if let algebraIndex = algebraIndex(in: lines, spellerStart: spellerIndex, spellerEnd: spellerEnd) {
            guard
                let insertionPoint = algebraInsertionPoint(
                    startingAt: algebraIndex,
                    spellerEnd: spellerEnd,
                    in: lines,
                    isWanxiangSchema: isWanxiangSchema
                )
            else {
                return RimeFuzzyPinyinPostProcessResult(
                    yaml: yaml,
                    status: .skippedUnsupportedAlgebra
                )
            }
            lines.insert(
                contentsOf: managedBlockLines(
                    rules: insertionPoint.ruleFormat.rules(for: settings),
                    indent: insertionPoint.indent
                ),
                at: insertionPoint.index
            )
        } else if !isWanxiangSchema {
            lines.insert(contentsOf: algebraSectionLines(rules: settings.algebraRules), at: spellerEnd)
        } else {
            return RimeFuzzyPinyinPostProcessResult(
                yaml: yaml,
                status: .skippedUnsupportedAlgebra
            )
        }

        let output = lines.joined(separator: "\n")
        return RimeFuzzyPinyinPostProcessResult(
            yaml: output,
            status: output == yaml ? .unchanged : .updated
        )
    }

    private static func removingManagedBlock(from lines: [String]) -> [String]? {
        let beginIndices = lines.indices.filter {
            lines[$0].trimmingCharacters(in: .whitespaces) == beginMarker
        }
        let endIndices = lines.indices.filter {
            lines[$0].trimmingCharacters(in: .whitespaces) == endMarker
        }
        guard beginIndices.count == endIndices.count else { return nil }
        guard beginIndices.count <= 1 else { return nil }
        if let beginIndex = beginIndices.first, let endIndex = endIndices.first {
            guard beginIndex < endIndex else { return nil }
            guard indentation(of: lines[beginIndex]) == indentation(of: lines[endIndex]) else {
                return nil
            }
            guard let spellerIndex = topLevelSectionIndex(named: "speller", in: lines) else {
                return nil
            }
            let spellerEnd = topLevelSectionEnd(startingAt: spellerIndex, in: lines)
            guard beginIndex > spellerIndex, endIndex < spellerEnd else { return nil }
        }

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

    private static func hasTopLevelSchemaID(_ schemaID: String, in lines: [String]) -> Bool {
        guard let schemaIndex = topLevelSectionIndex(named: "schema", in: lines) else { return false }
        let schemaEnd = topLevelSectionEnd(startingAt: schemaIndex, in: lines)
        guard schemaIndex + 1 < schemaEnd else { return false }
        return lines[(schemaIndex + 1)..<schemaEnd].contains { line in
            line.trimmingCharacters(in: .whitespaces) == "schema_id: \(schemaID)"
                && indentation(of: line) > 0
        }
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

    private struct InsertionPoint {
        enum RuleFormat {
            case algebra
            case wanxiangPatchReferences

            func rules(for settings: RimeFuzzyPinyinSettings) -> [String] {
                switch self {
                case .algebra:
                    return settings.algebraRules
                case .wanxiangPatchReferences:
                    var references: [String] = []
                    if settings.zhZEnabled { references.append("wanxiang_algebra:/模糊音_z_zh") }
                    if settings.chCEnabled { references.append("wanxiang_algebra:/模糊音_c_ch") }
                    if settings.shSEnabled { references.append("wanxiang_algebra:/模糊音_s_sh") }
                    if settings.nLEnabled { references.append("wanxiang_algebra:/模糊音_nl") }
                    return references
                }
            }
        }

        let index: Int
        let indent: Int
        let ruleFormat: RuleFormat
    }

    private static func algebraInsertionPoint(
        startingAt algebraIndex: Int,
        spellerEnd: Int,
        in lines: [String],
        isWanxiangSchema: Bool
    ) -> InsertionPoint? {
        let algebraIndent = indentation(of: lines[algebraIndex])
        guard algebraIndex + 1 < spellerEnd else {
            return isWanxiangSchema
                ? nil
                : InsertionPoint(index: spellerEnd, indent: algebraIndent + 2, ruleFormat: .algebra)
        }

        let algebraEnd = nestedSectionEnd(
            startingAt: algebraIndex,
            parentIndent: algebraIndent,
            upperBound: spellerEnd,
            in: lines
        )
        guard
            let firstChildIndex = firstContentIndex(
                after: algebraIndex,
                upperBound: algebraEnd,
                in: lines
        )
        else {
            return isWanxiangSchema
                ? nil
                : InsertionPoint(index: algebraEnd, indent: algebraIndent + 2, ruleFormat: .algebra)
        }

        let firstChild = lines[firstChildIndex].trimmingCharacters(in: .whitespaces)
        let firstChildIndent = indentation(of: lines[firstChildIndex])
        if firstChild.hasPrefix("-") {
            return isWanxiangSchema
                ? nil
                : InsertionPoint(index: algebraEnd, indent: firstChildIndent, ruleFormat: .algebra)
        }

        // Some schemas, including 万象, express algebra through a nested
        // `__patch` sequence. Rules must be inserted inside that sequence;
        // placing list items beside `__patch` produces invalid YAML.
        guard isWanxiangSchema, firstChild == "__patch:" else { return nil }
        let patchEnd = nestedSectionEnd(
            startingAt: firstChildIndex,
            parentIndent: firstChildIndent,
            upperBound: algebraEnd,
            in: lines
        )
        guard
            let firstPatchItemIndex = firstContentIndex(
                after: firstChildIndex,
                upperBound: patchEnd,
                in: lines
            )
        else {
            return nil
        }
        let firstPatchItem = strippingYAMLInlineComment(from: lines[firstPatchItemIndex])
            .trimmingCharacters(in: .whitespaces)
        guard firstPatchItem == "- wanxiang_algebra:/base/全拼" else { return nil }
        return InsertionPoint(
            index: patchEnd,
            indent: indentation(of: lines[firstPatchItemIndex]),
            ruleFormat: .wanxiangPatchReferences
        )
    }

    /// In plain YAML scalars, `#` starts a comment only when separated from
    /// the value by whitespace. A glued hash remains part of the scalar.
    private static func strippingYAMLInlineComment(from line: String) -> String {
        guard
            let commentIndex = line.indices.first(where: { index in
                guard line[index] == "#", index != line.startIndex else { return false }
                return line[line.index(before: index)].isWhitespace
            })
        else {
            return line
        }
        return String(line[..<commentIndex])
    }

    private static func firstContentIndex(after index: Int, upperBound: Int, in lines: [String]) -> Int? {
        guard index + 1 < upperBound else { return nil }
        return lines[(index + 1)..<upperBound].firstIndex { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return !trimmed.isEmpty && !trimmed.hasPrefix("#")
        }
    }

    private static func nestedSectionEnd(
        startingAt index: Int,
        parentIndent: Int,
        upperBound: Int,
        in lines: [String]
    ) -> Int {
        guard index + 1 < upperBound else { return upperBound }

        for currentIndex in (index + 1)..<upperBound {
            let line = lines[currentIndex]
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            if indentation(of: line) <= parentIndent && !trimmed.hasPrefix("#") {
                return currentIndex
            }
        }
        return upperBound
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
