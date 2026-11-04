import Foundation

/// Pure rewrite of the Wanxiang nine-key schema text.
///
/// Deletes the single `t9_processor` element under `engine/processors`.
/// Other lines, including comments and order, stay byte-for-byte. Zero matches
/// is success without a new document. This type does not call
/// `T9SchemaCompatibility`.
public enum WanxiangT9SchemaCompatibility {
    public static let schemaID = "wanxiang_t9i"

    public enum Reason: String, Equatable, Sendable {
        case multipleT9Processors
        case missingEngineProcessors
        case unlocatableProcessorsSequence
    }

    public enum Rewrite: Equatable, Sendable {
        case rewritten(String)
        case alreadyCompatible
        case failed(Reason)
    }

    public static func rewrite(_ yaml: String) -> Rewrite {
        if yaml.contains("\t") {
            return .failed(.unlocatableProcessorsSequence)
        }
        let newline = "\n"
        let hadTrailingNewline = yaml.hasSuffix(newline)
        var lines = yaml.components(separatedBy: newline)
        if hadTrailingNewline, lines.last == "" {
            lines.removeLast()
        }

        let engineIndexes = lines.indices.filter { isRootKey($0, lines, key: "engine") }
        guard engineIndexes.count == 1, let engineIndex = engineIndexes.first else {
            return .failed(.unlocatableProcessorsSequence)
        }
        let engineEnd = blockEnd(after: engineIndex, lines: lines, parentIndent: 0)
        let processorIndexes = lines[engineIndex + 1..<engineEnd].indices.filter { index in
            isNamedKey(lines[index], key: "processors") && indentWidth(lines[index]) > 0
        }
        guard processorIndexes.count == 1, let processorsIndex = processorIndexes.first else {
            return processorIndexes.isEmpty
                ? .failed(.missingEngineProcessors) : .failed(.unlocatableProcessorsSequence)
        }
        guard isBareKey(lines[processorsIndex], key: "processors") else {
            return .failed(.unlocatableProcessorsSequence)
        }
        let processorsIndent = indentWidth(lines[processorsIndex])

        let sequenceEnd = blockEnd(after: processorsIndex, lines: lines, parentIndent: processorsIndent)
        var items: [SequenceItem] = []
        var cursor = processorsIndex + 1
        while cursor < sequenceEnd {
            let line = lines[cursor]
            if line.trimmingCharacters(in: .whitespaces).isEmpty || isComment(line) {
                cursor += 1
                continue
            }
            guard let dash = sequenceDashColumn(line) else {
                return .failed(.unlocatableProcessorsSequence)
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
                if nextIndent == dash { return .failed(.unlocatableProcessorsSequence) }
                itemEnd += 1
            }
            let scalar = scalarToken(line)
            items.append(SequenceItem(start: cursor, end: itemEnd, isT9Processor: scalar == "t9_processor"))
            if scalar == "t9_processor", itemEnd > cursor + 1,
                lines[cursor + 1..<itemEnd].contains(where: {
                    !isComment($0) && !$0.trimmingCharacters(in: .whitespaces).isEmpty
                })
            {
                return .failed(.unlocatableProcessorsSequence)
            }
            cursor = itemEnd
        }

        let matches = items.filter(\.isT9Processor)
        if matches.count > 1 { return .failed(.multipleT9Processors) }
        guard let match = matches.first else { return .alreadyCompatible }
        lines.removeSubrange(match.start..<match.end)
        var text = lines.joined(separator: newline)
        if hadTrailingNewline {
            text.append(newline)
        }
        return .rewritten(text)
    }

    private struct SequenceItem {
        let start: Int
        let end: Int
        let isT9Processor: Bool
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
