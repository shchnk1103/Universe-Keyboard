import Foundation

/// Pure rewrite of the Wanxiang nine-key schema text.
///
/// Three idempotent edits, applied together or not at all:
/// delete the single `t9_processor` under `engine/processors`, insert the two
/// abbreviation algebra lines above the unique digit `xlit` line, and delete
/// the single `super_replacer/rules` item that starts `- option: abbrev`.
/// A failed step returns `.failed` and leaves the caller's text unchanged.
public enum WanxiangT9SchemaCompatibility {
    public static let schemaID = "wanxiang_t9i"
    public static let xlitLineBody =
        "- xlit/ABCDEFGHIJKLMNOPQRSTUVWXYZ/22233344455566677778889999/"
    public static let initialAbbrevLineBody = "- abbrev/^([A-Z]).+$/$1/"
    public static let compoundAbbrevLineBody = "- abbrev/^([ZCS]H).+$/$1/"

    public enum Reason: String, Equatable, Sendable, Error {
        case unsupportedLineEndings
        case multipleT9Processors
        case missingEngineProcessors
        case unlocatableProcessorsSequence
        case xlitLineNotUnique
        case abbrevLinesNotReady
        case multipleAbbrevOptions
        case unlocatableSuperReplacerRules
    }

    public enum Rewrite: Equatable, Sendable {
        case rewritten(String)
        case alreadyCompatible
        case failed(Reason)
    }

    public static func rewrite(_ yaml: String) -> Rewrite {
        if yaml.unicodeScalars.contains(where: { $0.value == 13 }) { return .failed(.unsupportedLineEndings) }
        if yaml.contains("\t") {
            return .failed(.unlocatableProcessorsSequence)
        }
        let newline = "\n"
        let hadTrailingNewline = yaml.hasSuffix(newline)
        var lines = yaml.components(separatedBy: newline)
        if hadTrailingNewline, lines.last == "" {
            lines.removeLast()
        }

        let processorRemoval: Range<Int>
        switch processorRemovalRange(lines) {
        case .failure(let reason):
            return .failed(reason)
        case .success(let range):
            processorRemoval = range
        }

        let abbrevInsertion: Insertion
        switch abbrevInsertionLines(lines) {
        case .failure(let reason):
            return .failed(reason)
        case .success(let insertion):
            abbrevInsertion = insertion
        }

        let optionRemoval: Range<Int>
        switch abbrevOptionRemovalRange(lines) {
        case .failure(let reason):
            return .failed(reason)
        case .success(let range):
            optionRemoval = range
        }

        var edits: [(index: Int, remove: Int, insert: [String])] = []
        if !processorRemoval.isEmpty {
            edits.append((processorRemoval.lowerBound, processorRemoval.count, []))
        }
        if !abbrevInsertion.lines.isEmpty {
            edits.append((abbrevInsertion.index, 0, abbrevInsertion.lines))
        }
        if !optionRemoval.isEmpty {
            edits.append((optionRemoval.lowerBound, optionRemoval.count, []))
        }
        if edits.isEmpty {
            return .alreadyCompatible
        }
        for edit in edits.sorted(by: { $0.index > $1.index }) {
            lines.replaceSubrange(
                edit.index..<(edit.index + edit.remove),
                with: edit.insert
            )
        }
        var text = lines.joined(separator: newline)
        if hadTrailingNewline {
            text.append(newline)
        }
        return .rewritten(text)
    }

    private struct Insertion {
        var index: Int
        var lines: [String]
    }

    private static func processorRemovalRange(_ lines: [String]) -> Result<Range<Int>, Reason> {
        let engineIndexes = lines.indices.filter { isRootKey($0, lines, key: "engine") }
        guard engineIndexes.count == 1, let engineIndex = engineIndexes.first else {
            return .failure(.unlocatableProcessorsSequence)
        }
        let engineEnd = blockEnd(after: engineIndex, lines: lines, parentIndent: 0)
        guard let childIndent = directChildIndent(after: engineIndex, end: engineEnd, lines: lines) else {
            return .failure(.unlocatableProcessorsSequence)
        }
        let processorIndexes = lines[engineIndex + 1..<engineEnd].indices.filter { index in
            isNamedKey(lines[index], key: "processors") && indentWidth(lines[index]) == childIndent
        }
        guard processorIndexes.count == 1, let processorsIndex = processorIndexes.first else {
            return processorIndexes.isEmpty
                ? .failure(.missingEngineProcessors) : .failure(.unlocatableProcessorsSequence)
        }
        guard isBareKey(lines[processorsIndex], key: "processors") else {
            return .failure(.unlocatableProcessorsSequence)
        }
        switch sequenceItems(from: processorsIndex, lines: lines) {
        case .failure:
            return .failure(.unlocatableProcessorsSequence)
        case .success(let items):
            let matches = items.filter { scalarToken(lines[$0.start]) == "t9_processor" }
            if matches.count > 1 { return .failure(.multipleT9Processors) }
            guard let match = matches.first else { return .success(0..<0) }
            if match.end > match.start + 1,
                lines[match.start + 1..<match.end].contains(where: {
                    !isComment($0) && !$0.trimmingCharacters(in: .whitespaces).isEmpty
                })
            {
                return .failure(.unlocatableProcessorsSequence)
            }
            return .success(match.start..<match.end)
        }
    }

    private static func abbrevInsertionLines(_ lines: [String]) -> Result<Insertion, Reason> {
        guard let algebra = block(lines, root: "speller", child: "algebra") else {
            return .failure(.xlitLineNotUnique)
        }
        let xlitIndexes = Array(algebra.range).filter {
            lines[$0].trimmingCharacters(in: .whitespaces) == xlitLineBody
        }
        guard xlitIndexes.count == 1, let xlitIndex = xlitIndexes.first else {
            return .failure(.xlitLineNotUnique)
        }
        let indent = indentWidth(lines[xlitIndex])
        let first = String(repeating: " ", count: indent) + initialAbbrevLineBody
        let second = String(repeating: " ", count: indent) + compoundAbbrevLineBody
        let initialCount = algebra.range.filter {
            lines[$0].trimmingCharacters(in: .whitespaces) == initialAbbrevLineBody
        }.count
        let compoundCount = algebra.range.filter {
            lines[$0].trimmingCharacters(in: .whitespaces) == compoundAbbrevLineBody
        }.count
        let alreadyPlaced =
            xlitIndex >= algebra.range.lowerBound + 2
            && lines[xlitIndex - 2].trimmingCharacters(in: .whitespaces) == initialAbbrevLineBody
            && lines[xlitIndex - 1].trimmingCharacters(in: .whitespaces) == compoundAbbrevLineBody
            && initialCount == 1
            && compoundCount == 1
        if alreadyPlaced {
            return .success(Insertion(index: xlitIndex, lines: []))
        }
        if initialCount == 0 && compoundCount == 0 {
            return .success(Insertion(index: xlitIndex, lines: [first, second]))
        }
        return .failure(.abbrevLinesNotReady)
    }

    private static func abbrevOptionRemovalRange(_ lines: [String]) -> Result<Range<Int>, Reason> {
        guard let rules = block(lines, root: "super_replacer", child: "rules") else {
            return .failure(.unlocatableSuperReplacerRules)
        }
        switch sequenceItems(from: rules.keyIndex, lines: lines) {
        case .failure:
            return .failure(.unlocatableSuperReplacerRules)
        case .success(let items):
            let matches = items.filter {
                isAbbrevOption(lines[$0.start])
            }
            if matches.count > 1 { return .failure(.multipleAbbrevOptions) }
            guard let match = matches.first else { return .success(0..<0) }
            return .success(match.start..<match.end)
        }
    }

    private struct Block {
        var keyIndex: Int
        var range: Range<Int>
    }

    private static func block(_ lines: [String], root: String, child: String) -> Block? {
        let roots = lines.indices.filter { isRootKey($0, lines, key: root) }
        guard roots.count == 1, let rootIndex = roots.first else { return nil }
        let rootEnd = blockEnd(after: rootIndex, lines: lines, parentIndent: 0)
        guard let childIndent = directChildIndent(after: rootIndex, end: rootEnd, lines: lines) else { return nil }
        let children = lines[rootIndex + 1..<rootEnd].indices.filter { index in
            isNamedKey(lines[index], key: child) && indentWidth(lines[index]) == childIndent
        }
        guard children.count == 1, let childIndex = children.first,
            isBareKey(lines[childIndex], key: child)
        else { return nil }
        let end = blockEnd(after: childIndex, lines: lines, parentIndent: indentWidth(lines[childIndex]))
        return Block(keyIndex: childIndex, range: (childIndex + 1)..<end)
    }

    private struct SequenceSpan {
        var start: Int
        var end: Int
    }

    private static func sequenceItems(from keyIndex: Int, lines: [String]) -> Result<[SequenceSpan], Reason> {
        let sequenceEnd = blockEnd(after: keyIndex, lines: lines, parentIndent: indentWidth(lines[keyIndex]))
        var items: [SequenceSpan] = []
        var cursor = keyIndex + 1
        while cursor < sequenceEnd {
            let line = lines[cursor]
            if line.trimmingCharacters(in: .whitespaces).isEmpty || isComment(line) {
                cursor += 1
                continue
            }
            guard let dash = sequenceDashColumn(line) else {
                return .failure(.unlocatableProcessorsSequence)
            }
            var itemEnd = cursor + 1
            while itemEnd < sequenceEnd {
                let next = lines[itemEnd]
                if next.trimmingCharacters(in: .whitespaces).isEmpty || isComment(next) {
                    itemEnd += 1
                    continue
                }
                let nextIndent = indentWidth(next)
                if nextIndent < dash { break }
                if nextIndent == dash, sequenceDashColumn(next) != nil { break }
                if nextIndent == dash { return .failure(.unlocatableProcessorsSequence) }
                itemEnd += 1
            }
            // Separate trailing trivia without losing comments owned by the item.
            var contentEnd = itemEnd
            while contentEnd > cursor + 1 {
                let line = lines[contentEnd - 1]
                if line.trimmingCharacters(in: .whitespaces).isEmpty || isComment(line) {
                    contentEnd -= 1
                } else {
                    break
                }
            }
            var retained = false
            var removalEnd = itemEnd
            for index in contentEnd..<itemEnd {
                let line = lines[index]
                let keep = line.trimmingCharacters(in: .whitespaces).isEmpty || indentWidth(line) <= dash
                if keep {
                    if !retained { removalEnd = index }
                    retained = true
                } else if retained {
                    return .failure(.unlocatableProcessorsSequence)
                }
            }
            items.append(SequenceSpan(start: cursor, end: removalEnd))
            cursor = itemEnd
        }
        return .success(items)
    }

    private static func directChildIndent(after index: Int, end: Int, lines: [String]) -> Int? {
        guard
            let first = (index + 1..<end).first(where: {
                !isComment(lines[$0]) && !lines[$0].trimmingCharacters(in: .whitespaces).isEmpty
            })
        else { return nil }
        let indent = indentWidth(lines[first])
        return indent > indentWidth(lines[index]) ? indent : nil
    }

    private static func isAbbrevOption(_ line: String) -> Bool {
        let body = line.trimmingCharacters(in: .whitespaces)
        guard body.hasPrefix("- option:") else { return false }
        let value = body.dropFirst("- option:".count).trimmingCharacters(in: .whitespaces)
        guard value.hasPrefix("abbrev") else { return false }
        let suffix = value.dropFirst("abbrev".count)
        if suffix.isEmpty { return true }
        guard suffix.first?.isWhitespace == true else { return false }
        let rest = suffix.trimmingCharacters(in: .whitespaces)
        return rest.isEmpty || rest.hasPrefix("#")
    }

    private static func isRootKey(_ index: Int, _ lines: [String], key: String) -> Bool {
        isKey(lines[index], indent: 0, key: key)
    }

    private static func isKey(_ line: String, indent: Int, key: String) -> Bool {
        guard indentWidth(line) == indent else { return false }
        return isNamedKey(line, key: key)
    }

    private static func isNamedKey(_ line: String, key: String) -> Bool {
        guard !isComment(line) else { return false }
        let body = line.trimmingCharacters(in: .whitespaces)
        return body == "\(key):" || body.hasPrefix("\(key):")
    }

    private static func isBareKey(_ line: String, key: String) -> Bool {
        let body = stripInlineComment(line.trimmingCharacters(in: .whitespaces))
        return body == "\(key):"
    }

    private static func blockEnd(after index: Int, lines: [String], parentIndent: Int) -> Int {
        var end = index + 1
        while end < lines.count {
            let line = lines[end]
            if line.trimmingCharacters(in: .whitespaces).isEmpty || isComment(line) {
                end += 1
                continue
            }
            if indentWidth(line) <= parentIndent { break }
            end += 1
        }
        return end
    }

    private static func isComment(_ line: String) -> Bool {
        line.trimmingCharacters(in: .whitespaces).hasPrefix("#")
    }

    private static func indentWidth(_ line: String) -> Int {
        line.prefix(while: { $0 == " " }).count
    }

    private static func sequenceDashColumn(_ line: String) -> Int? {
        let indent = indentWidth(line)
        let rest = line.dropFirst(indent)
        guard rest.hasPrefix("-") else { return nil }
        return indent
    }

    private static func scalarToken(_ line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("-") else { return nil }
        var body = trimmed.dropFirst()
        if body.hasPrefix(" ") { body = body.drop(while: { $0 == " " }) }
        let token = stripInlineComment(String(body))
        if token.isEmpty || token.hasPrefix("{") || token.hasPrefix("[") || token.hasPrefix("|")
            || token.hasPrefix(">") || token.hasPrefix("&") || token.hasPrefix("*")
            || token.hasPrefix("!") || token.contains(":")
        {
            return nil
        }
        if token.hasPrefix("'"), token.hasSuffix("'"), token.count >= 2 {
            return String(token.dropFirst().dropLast())
        }
        if token.hasPrefix("\""), token.hasSuffix("\""), token.count >= 2 {
            return String(token.dropFirst().dropLast())
        }
        return token
    }

    private static func stripInlineComment(_ text: String) -> String {
        guard let hash = text.firstIndex(of: "#") else {
            return text.trimmingCharacters(in: .whitespaces)
        }
        return text[..<hash].trimmingCharacters(in: .whitespaces)
    }
}
