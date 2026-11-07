import CryptoKit
import Foundation

/// Closed subset reader for a schema's top-level `switches` list.
///
/// This is not a YAML parser. Nested `__include` / `__patch` outside `switches`
/// are left untouched and are not expanded. A top-level marker fails closed,
/// except the pinned Luna patch exemption.
public enum SchemaSwitchResolver {
    public static let builtinLunaSHA256 =
        "668b4d4957e4cc8f9cea32ed3f08f0ecf4a7be8cdba058700507487bd96dd5c7"

    public enum Failure: String, Error, Equatable, Sendable {
        case missingSwitches
        case duplicateTopKey
        case duplicateField
        case unsupportedSyntax
        case switchesPatched
        case nonMappingItem
        case ambiguousScalar
        case notUniqueCandidate
        case directionUnproven
        case emojiDirectionUnproven
    }

    public struct Item: Equatable, Sendable {
        public let index: Int
        public let name: String?
        public let options: [String]?
        public let states: [String]?
        public let reset: Int?
        public let abbrev: [String]?
    }

    public struct Simplification: Equatable, Sendable {
        public let index: Int
        public let simplifiedReset: Int
        public let traditionalReset: Int

        public var key: String { "switches/@\(index)/reset" }
    }

    public struct EmojiReset: Equatable, Sendable {
        public let index: Int
        public let reset: Int

        public var key: String { "switches/@\(index)/reset" }
    }

    /// Parse only. Does not apply the Luna exemption.
    public static func recognize(_ source: String) -> Result<[Item], Failure> {
        parse(source, allowingPinnedLunaPatch: false)
    }

    /// Limited exemption from design §F: not proof that the custom patch is inert.
    /// `grammarYamlPresent` means either the shared or the user directory has `grammar.yaml`.
    public static func recognizeLuna(
        source: String,
        sourceSHA256: String,
        grammarYamlPresent: Bool
    ) -> Result<[Item], Failure> {
        let digest = SHA256.hash(data: Data(source.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        guard sourceSHA256 == builtinLunaSHA256, digest == builtinLunaSHA256, !grammarYamlPresent
        else {
            return .failure(.switchesPatched)
        }
        return parse(source, allowingPinnedLunaPatch: true)
    }

    /// Accept only the pinned two-item `__patch`. This does not apply Luna's hash exemption.
    /// The caller has to prove the source hash before treating the result as a compile input.
    public static func recognizePinnedPatch(_ source: String) -> Result<[Item], Failure> {
        parse(source, allowingPinnedLunaPatch: true)
    }

    public static func simplification(in items: [Item]) -> Result<Simplification, Failure> {
        var candidates: [Candidate] = []
        for item in items {
            if let group = groupCandidate(item) {
                candidates.append(group)
            }
            if let named = namedCandidate(item) {
                candidates.append(named)
            }
        }
        guard candidates.count == 1, let only = candidates.first else {
            return .failure(.notUniqueCandidate)
        }
        switch only {
        case .unproven:
            return .failure(.directionUnproven)
        case .ready(let selection):
            return .success(selection)
        }
    }

    /// Non-万象 callers do not query emoji. A 万象 caller with an unproven emoji gets a failure.
    public static func emojiReset(in items: [Item], wanxiangFamily: Bool) -> Result<EmojiReset?, Failure> {
        guard wanxiangFamily else { return .success(nil) }
        let matches = items.filter { $0.name == "emoji" }
        guard matches.count == 1, let emoji = matches.first, emoji.states == ["表情关", "表情开"] else {
            return .failure(.emojiDirectionUnproven)
        }
        return .success(EmojiReset(index: emoji.index, reset: 1))
    }
}

extension SchemaSwitchResolver {
    fileprivate enum Candidate {
        case ready(Simplification)
        case unproven
    }

    fileprivate static func groupCandidate(_ item: Item) -> Candidate? {
        guard let options = item.options else { return nil }
        func positions(_ token: String) -> [Int] { options.indices.filter { options[$0] == token } }
        let hans = positions("zh_hans")
        let hant = positions("zh_hant")
        let s2s = positions("s2s")
        let s2t = positions("s2t")
        let hansPair = hans.count == 1 && hant.count == 1
        let s2Pair = s2s.count == 1 && s2t.count == 1
        // A repeated member, or both pair kinds on one item, voids that candidate.
        if hans.count > 1 || hant.count > 1 || s2s.count > 1 || s2t.count > 1 { return nil }
        if hansPair && s2Pair { return nil }
        guard hansPair || s2Pair else { return nil }
        guard let states = item.states else { return .unproven }
        let simplified = hansPair ? hans[0] : s2s[0]
        let traditional = hansPair ? hant[0] : s2t[0]
        guard simplified < states.count, traditional < states.count else { return .unproven }
        return .ready(
            Simplification(index: item.index, simplifiedReset: simplified, traditionalReset: traditional)
        )
    }

    fileprivate static func namedCandidate(_ item: Item) -> Candidate? {
        guard let name = item.name, name == "traditionalization" || name == "simplification" else {
            return nil
        }
        guard item.states?.count == 2 else { return nil }
        if name == "traditionalization" && item.states == ["简", "繁"] {
            return .ready(Simplification(index: item.index, simplifiedReset: 0, traditionalReset: 1))
        }
        if name == "simplification" && item.states == ["繁", "简"] {
            return .ready(Simplification(index: item.index, simplifiedReset: 1, traditionalReset: 0))
        }
        return .unproven
    }
}

extension SchemaSwitchResolver {
    fileprivate struct RawLine {
        let indent: Int
        let body: String
    }

    fileprivate static let patchMarkers = ["__include", "__patch", "__append", "__merge"]
    fileprivate static let pinnedPatch = ["grammar:/hant?", "luna_pinyin.custom:/patch?"]
    fileprivate static let fieldNames = ["name", "options", "states", "reset", "abbrev"]

    fileprivate static func parse(_ source: String, allowingPinnedLunaPatch: Bool) -> Result<[Item], Failure> {
        let normalized = source.hasPrefix("\u{feff}") ? String(source.dropFirst()) : source
        let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var raw: [RawLine] = []
        for line in lines {
            let stripped = line.hasSuffix("\r") ? String(line.dropLast()) : line
            if stripped.trimmingCharacters(in: .whitespaces).isEmpty { continue }
            let indent = stripped.prefix { $0 == " " }.count
            let body = String(stripped.dropFirst(indent))
            if body.hasPrefix("#") { continue }
            // Other schema nodes may use deeper indentation. The 2/4/6 rule
            // applies only while reading the switches list.
            raw.append(RawLine(indent: indent, body: body))
        }

        var index = 0
        var seenTop: Set<String> = []
        var switches: [Item]?
        var sawPinnedPatch = false
        while index < raw.count {
            let line = raw[index]
            guard line.indent == 0 else { return .failure(.unsupportedSyntax) }
            guard let colon = line.body.firstIndex(of: ":") else { return .failure(.unsupportedSyntax) }
            let key = String(line.body[..<colon])
            let inline = String(line.body[line.body.index(after: colon)...])
            if !seenTop.insert(key).inserted { return .failure(.duplicateTopKey) }
            if patchMarkers.contains(key) {
                if allowingPinnedLunaPatch && key == "__patch" {
                    let consumed = consumePinnedPatch(raw, from: index + 1)
                    guard case .success(let next) = consumed else { return .failure(.switchesPatched) }
                    sawPinnedPatch = true
                    index = next
                    continue
                }
                return .failure(.switchesPatched)
            }
            if key == "switches" {
                if commentStripped(inline) != nil && !commentStripped(inline)!.isEmpty {
                    return .failure(.unsupportedSyntax)
                }
                let parsed = parseSwitches(raw, from: index + 1)
                switch parsed {
                case .failure(let failure):
                    return .failure(failure)
                case .success(let value):
                    switches = value.items
                    index = value.next
                }
                continue
            }
            // Markers under another top-level key are not expanded and do not
            // reject the file. Fixed rime-ice and 万象 keep punctuation includes.
            index += 1
            while index < raw.count && raw[index].indent > 0 {
                index += 1
            }
        }
        if allowingPinnedLunaPatch && !sawPinnedPatch { return .failure(.switchesPatched) }
        guard let switches else { return .failure(.missingSwitches) }
        return .success(switches)
    }

    /// Nested markers outside `switches` are ignored. Markers inside the section fail.
    fileprivate static func containsMarker(_ text: String) -> Bool {
        patchMarkers.contains { text.contains($0) }
    }

    fileprivate static func consumePinnedPatch(
        _ lines: [RawLine],
        from start: Int
    ) -> Result<Int, Failure> {
        var index = start
        var items: [String] = []
        while index < lines.count && lines[index].indent > 0 {
            let line = lines[index]
            if line.indent == 2 && line.body.hasPrefix("- ") {
                let value = commentStripped(String(line.body.dropFirst(2))) ?? ""
                items.append(value)
                index += 1
                continue
            }
            return .failure(.switchesPatched)
        }
        guard items == pinnedPatch else { return .failure(.switchesPatched) }
        return .success(index)
    }

    fileprivate static func parseSwitches(
        _ lines: [RawLine],
        from start: Int
    ) -> Result<(items: [Item], next: Int), Failure> {
        var index = start
        var items: [Item] = []
        while index < lines.count && lines[index].indent > 0 {
            let line = lines[index]
            if line.body.contains("\t") { return .failure(.unsupportedSyntax) }
            if containsMarker(line.body) { return .failure(.switchesPatched) }
            guard line.indent == 2, line.body.hasPrefix("- ") else {
                return .failure(.unsupportedSyntax)
            }
            let payload = String(line.body.dropFirst(2))
            if payload.hasPrefix("{") || payload.hasPrefix("[") {
                return .failure(.unsupportedSyntax)
            }
            var fields: [(String, Value)] = []
            if !payload.trimmingCharacters(in: .whitespaces).isEmpty {
                if !payload.contains(":") { return .failure(.nonMappingItem) }
                switch parseField(payload, lines: lines, index: &index) {
                case .failure(let failure):
                    return .failure(failure)
                case .success(let field):
                    fields.append(field)
                }
            } else {
                index += 1
            }
            while index < lines.count && lines[index].indent >= 4 {
                let fieldLine = lines[index]
                if containsMarker(fieldLine.body) { return .failure(.switchesPatched) }
                guard fieldLine.indent == 4 else { return .failure(.unsupportedSyntax) }
                switch parseField(fieldLine.body, lines: lines, index: &index) {
                case .failure(let failure):
                    return .failure(failure)
                case .success(let field):
                    fields.append(field)
                }
            }
            switch makeItem(fields, index: items.count) {
            case .failure(let failure):
                return .failure(failure)
            case .success(let item):
                items.append(item)
            }
        }
        return .success((items, index))
    }

    fileprivate enum Value {
        case scalar(String)
        case list([String])
        case integer(Int)
    }

    fileprivate static func parseField(
        _ text: String,
        lines: [RawLine],
        index: inout Int
    ) -> Result<(String, Value), Failure> {
        guard let colon = text.firstIndex(of: ":") else { return .failure(.unsupportedSyntax) }
        let key = String(text[..<colon])
        guard fieldNames.contains(key) else { return .failure(.unsupportedSyntax) }
        let rawValue = String(text[text.index(after: colon)...])
        let inline = commentStripped(rawValue) ?? ""
        if inline.hasPrefix("[") {
            guard let list = flowList(inline) else {
                return inline.contains("]") ? .failure(.ambiguousScalar) : .failure(.unsupportedSyntax)
            }
            index += 1
            return .success((key, .list(list)))
        }
        if inline.isEmpty {
            index += 1
            var values: [String] = []
            while index < lines.count && lines[index].indent == 6 && lines[index].body.hasPrefix("- ") {
                let element = commentStripped(String(lines[index].body.dropFirst(2))) ?? ""
                switch scalar(element) {
                case .failure(let failure):
                    return .failure(failure)
                case .success(let text):
                    values.append(text)
                }
                index += 1
            }
            if values.isEmpty { return .failure(.unsupportedSyntax) }
            return .success((key, .list(values)))
        }
        switch scalar(inline) {
        case .failure(let failure):
            return .failure(failure)
        case .success(let text):
            index += 1
            if key == "reset", let number = Int(text), text.allSatisfy({ $0.isNumber || $0 == "-" }) {
                return .success((key, .integer(number)))
            }
            return .success((key, .scalar(text)))
        }
    }

    fileprivate static func makeItem(_ fields: [(String, Value)], index: Int) -> Result<Item, Failure> {
        var seen: Set<String> = []
        var name: String?
        var options: [String]?
        var states: [String]?
        var reset: Int?
        var abbrev: [String]?
        for (key, value) in fields {
            if !seen.insert(key).inserted { return .failure(.duplicateField) }
            switch (key, value) {
            case ("name", .scalar(let text)):
                name = text
            case ("options", .list(let list)):
                options = list
            case ("states", .list(let list)):
                states = list
            case ("abbrev", .list(let list)):
                abbrev = list
            case ("reset", .integer(let number)):
                reset = number
            default:
                return .failure(.unsupportedSyntax)
            }
        }
        let hasName = name != nil
        let hasOptions = options != nil
        guard hasName != hasOptions else { return .failure(.unsupportedSyntax) }
        if let options, let states, options.count != states.count {
            return .failure(.unsupportedSyntax)
        }
        if let abbrev {
            let expected = states?.count ?? 1
            if abbrev.count != expected || abbrev.isEmpty { return .failure(.unsupportedSyntax) }
        }
        if options?.isEmpty == true || states?.isEmpty == true {
            return .failure(.unsupportedSyntax)
        }
        return .success(
            Item(index: index, name: name, options: options, states: states, reset: reset, abbrev: abbrev)
        )
    }

    fileprivate static func flowList(_ text: String) -> [String]? {
        guard text.hasPrefix("["), let end = text.firstIndex(of: "]") else { return nil }
        let trailing = commentStripped(String(text[text.index(after: end)...])) ?? ""
        if !trailing.isEmpty { return nil }
        let inside = String(text[text.index(after: text.startIndex)..<end])
        if inside.trimmingCharacters(in: .whitespaces).isEmpty { return [] }
        var parts: [String] = []
        var current = ""
        var quote: Character?
        var escaped = false
        for character in inside {
            if quote != nil {
                current.append(character)
                if escaped {
                    escaped = false
                    continue
                }
                if character == "\\" && quote == "\"" {
                    escaped = true
                    continue
                }
                if character == quote { quote = nil }
                continue
            }
            if character == "\"" || character == "'" {
                quote = character
                current.append(character)
                continue
            }
            if character == "," {
                parts.append(current.trimmingCharacters(in: .whitespaces))
                current = ""
                continue
            }
            current.append(character)
        }
        if quote != nil { return nil }
        let tail = current.trimmingCharacters(in: .whitespaces)
        if !tail.isEmpty { parts.append(tail) }
        var decoded: [String] = []
        for part in parts {
            switch scalar(part) {
            case .failure:
                return nil
            case .success(let text):
                decoded.append(text)
            }
        }
        return decoded
    }

    fileprivate static func scalar(_ text: String) -> Result<String, Failure> {
        if text.hasPrefix("'") {
            guard text.hasSuffix("'"), text.count >= 2 else { return .failure(.ambiguousScalar) }
            let inner = String(text.dropFirst().dropLast())
            if inner.contains("'") && !inner.contains("''") { return .failure(.ambiguousScalar) }
            return .success(inner.replacingOccurrences(of: "''", with: "'"))
        }
        if text.hasPrefix("\"") {
            guard text.hasSuffix("\""), text.count >= 2 else { return .failure(.ambiguousScalar) }
            return decodeDoubleQuoted(String(text.dropFirst().dropLast()))
        }
        let forbidden = CharacterSet(charactersIn: ":#[],{}'\"*&!|>@")
        if text.isEmpty
            || text.unicodeScalars.contains(where: { forbidden.contains($0) || CharacterSet.whitespaces.contains($0) })
        {
            return .failure(.unsupportedSyntax)
        }
        return .success(text)
    }

    fileprivate static func decodeDoubleQuoted(_ inner: String) -> Result<String, Failure> {
        var output = ""
        var escaped = false
        for character in inner {
            if escaped {
                switch character {
                case "n": output.append("\n")
                case "t": output.append("\t")
                case "\\", "\"", "'": output.append(character)
                default: return .failure(.ambiguousScalar)
                }
                escaped = false
                continue
            }
            if character == "\\" {
                escaped = true
                continue
            }
            output.append(character)
        }
        if escaped { return .failure(.ambiguousScalar) }
        return .success(output)
    }

    fileprivate static func commentStripped(_ text: String) -> String? {
        var quote: Character?
        var escaped = false
        var kept = ""
        for character in text {
            if quote != nil {
                kept.append(character)
                if escaped {
                    escaped = false
                    continue
                }
                if character == "\\" && quote == "\"" {
                    escaped = true
                    continue
                }
                if character == quote { quote = nil }
                continue
            }
            if character == "#" { break }
            if character == "\"" || character == "'" { quote = character }
            kept.append(character)
        }
        return kept.trimmingCharacters(in: .whitespaces)
    }
}
