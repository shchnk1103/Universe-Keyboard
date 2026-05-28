extension RimeEngineImpl {
    /// Translates keyboard action labels into X11 keysyms consumed by librime.
    static func keycode(for key: String) -> Int32 {
        switch key {
        case "BackSpace", "Delete":
            return 0xFF08
        case "Return", "Enter":
            return 0xFF0D
        case "space", " ":
            return 0x0020
        case "Escape":
            return 0xFF1B
        case "Tab":
            return 0xFF09
        default:
            break
        }

        if let scalar = key.unicodeScalars.first,
            key.unicodeScalars.count == 1,
            (0x20...0x7E).contains(scalar.value)
        {
            return Int32(scalar.value)
        }
        if key.count == 1, let byte = key.utf8.first {
            return Int32(byte)
        }
        return 0
    }
}
