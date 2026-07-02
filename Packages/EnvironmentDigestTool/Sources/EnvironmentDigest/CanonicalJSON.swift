import Foundation

enum CanonicalJSON {
    indirect enum Value {
        case object([String: Value])
        case array([Value])
        case string(String)
        case bool(Bool)
        case integer(UInt64)
        case null
    }

    static func encode(_ value: Value) -> Data {
        var output = render(value)
        output.append("\n")
        return Data(output.utf8)
    }

    private static func render(_ value: Value) -> String {
        switch value {
        case let .object(object):
            let members = object.keys.sorted(by: utf8LessThan).map { key in
                "\(quoted(key)):\(render(object[key]!))"
            }
            return "{\(members.joined(separator: ","))}"
        case let .array(array):
            return "[\(array.map(render).joined(separator: ","))]"
        case let .string(string):
            return quoted(string)
        case let .bool(value):
            return value ? "true" : "false"
        case let .integer(value):
            return String(value)
        case .null:
            return "null"
        }
    }

    static func utf8LessThan(_ lhs: String, _ rhs: String) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }

    private static func quoted(_ string: String) -> String {
        var result = "\""
        for scalar in string.unicodeScalars {
            switch scalar.value {
            case 0x22: result += "\\\""
            case 0x5c: result += "\\\\"
            case 0x08: result += "\\b"
            case 0x0c: result += "\\f"
            case 0x0a: result += "\\n"
            case 0x0d: result += "\\r"
            case 0x09: result += "\\t"
            case 0x00...0x1f:
                result += String(format: "\\u%04x", scalar.value)
            default:
                result.unicodeScalars.append(scalar)
            }
        }
        result.append("\"")
        return result
    }
}
