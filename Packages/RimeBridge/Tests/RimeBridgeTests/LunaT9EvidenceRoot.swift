import Darwin
import Foundation

enum LunaT9EvidenceRoot {
    private static let root: Result<URL, Error> = Result {
        let manager = FileManager.default
        let configured = ProcessInfo.processInfo.environment["LUNA_T9_EVIDENCE_ROOT"]
        let parent: URL
        if let configured, !configured.isEmpty {
            parent = URL(fileURLWithPath: configured, isDirectory: true)
            try manager.createDirectory(at: parent, withIntermediateDirectories: true)
        } else {
            parent = manager.temporaryDirectory.appendingPathComponent("LunaT9-\(UUID().uuidString)", isDirectory: true)
            try createExclusiveDirectory(parent)
        }
        print("LUNA_T9_RESOLVED_PARENT \(parent.path)")
        let run = parent.appendingPathComponent("run-\(UUID().uuidString)", isDirectory: true)
        try createExclusiveDirectory(run)
        print("LUNA_T9_RUN_ROOT \(run.path)")
        return run
    }

    static func createExclusiveDirectory(_ url: URL) throws {
        guard mkdir(url.path, 0o700) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
    }

    static func directory(_ name: String) throws -> URL {
        let url = try root.get().appendingPathComponent(name, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
