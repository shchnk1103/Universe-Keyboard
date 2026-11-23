import Foundation

/// One-scalar boundary decision between the committed left neighbor and the
/// text about to be committed. Returns "" or a single ASCII space. The
/// function reads only the boundary scalars and never logs text (ADR 0007).
public enum MixedScriptSpacing {
    /// Empty `before`, a `nil` read, whitespace on either side, and
    /// same-script or punctuation boundaries all return "".
    public static func leadingSpace(before: String?, committing: String) -> String {
        guard let neighbor = before?.unicodeScalars.last,
            let first = committing.unicodeScalars.first
        else { return "" }
        if neighbor.properties.isWhitespace || first.properties.isWhitespace { return "" }
        let han = isHanScalar(neighbor)
        let hanFirst = isHanScalar(first)
        let latinNeighbor = isASCIILetter(neighbor)
        let latinFirst = isASCIILetter(first)
        let digitNeighbor = isASCIIDigit(neighbor)
        let digitFirst = isASCIIDigit(first)
        // Han <-> ASCII letter/digit inserts; English<->digit never does.
        if han && (latinFirst || digitFirst) { return " " }
        if (latinNeighbor || digitNeighbor) && hanFirst { return " " }
        return ""
    }

    /// Stored values are honored only when they are true CF booleans
    /// (`CFGetTypeID == CFBooleanGetTypeID`). Missing keys, integers wrapped
    /// in NSNumber, and any other type all stay enabled. Without full access
    /// the switch is forced on and nothing is written back.
    public static func isEnabled(stored: Any?, hasFullAccess: Bool) -> Bool {
        if !hasFullAccess { return true }
        guard let stored,
            CFGetTypeID(stored as CFTypeRef) == CFBooleanGetTypeID()
        else { return true }
        return (stored as? NSNumber)?.boolValue ?? true
    }

    private static func isHanScalar(_ scalar: Unicode.Scalar) -> Bool {
        (0x3400...0x4DBF).contains(scalar.value) || (0x4E00...0x9FFF).contains(scalar.value)
    }

    private static func isASCIILetter(_ scalar: Unicode.Scalar) -> Bool {
        (0x41...0x5A).contains(scalar.value) || (0x61...0x7A).contains(scalar.value)
    }

    private static func isASCIIDigit(_ scalar: Unicode.Scalar) -> Bool {
        (0x30...0x39).contains(scalar.value)
    }
}
