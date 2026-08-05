import Foundation

/// Shared allow-list for the internal device-preflight content-free export.
///
/// Keeping this rule in KeyboardCore lets the App diagnostics surface and the
/// regression tests use the same marker set. Privacy validation remains a
/// separate step; this filter only decides which marker-shaped lines to retain.
public enum T9DevicePreflightEvidenceLineFilter {
    public static func retains(_ line: String) -> Bool {
        line.contains("T9DEVICE ")
            || line.contains("T9GEOM ")
            || line.contains("T9SEG ")
            || line.contains("T9AUTO ")
            || line.contains("T9ARM ")
            || line.contains("T9RESP ")
            || line.contains("SLOW RIME ")
    }
}
