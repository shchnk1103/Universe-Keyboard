import Foundation

private let runtimeDirectoriesAppGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

extension RimeConfigManager {
    /// Resolves existing deployed runtime directories without writing files.
    ///
    /// Input-view presentation can use this method safely because missing
    /// resources are surfaced back to the main app instead of being generated
    /// while the user is waiting to type.
    public static func runtimeDirectories() -> (sharedDir: String, userDir: String)? {
        guard
            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: runtimeDirectoriesAppGroupID
            )
        else { return nil }

        let sharedDir = containerURL.appendingPathComponent("Rime/shared")
        let userDir = containerURL.appendingPathComponent("Rime/user")
        guard
            FileManager.default.fileExists(atPath: sharedDir.path),
            FileManager.default.fileExists(atPath: userDir.path)
        else { return nil }

        return (sharedDir.path, userDir.path)
    }
}
