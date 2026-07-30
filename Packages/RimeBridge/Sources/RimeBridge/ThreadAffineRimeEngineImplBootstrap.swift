import Foundation
import KeyboardCore

/// R4-B config-only bootstrap for a real `RimeEngineImpl` on the thread-affine owner.
///
/// This value type is deliberately limited to path / schema configuration.
/// It must never capture a live engine, session handle, or other non-Sendable
/// RIME object. The owner thread is the only site that materializes the engine.
///
/// Deploy / fullCheck of the runtime tree remains a separate Main-App-shaped
/// step performed by the test harness **before** the owner starts.
@available(iOS 18.0, macOS 15.0, *)
public struct ThreadAffineRimeEngineImplBootstrap: ThreadAffineRimeEngineBootstrap, Sendable {
    public let sharedDataDir: String
    public let userDataDir: String
    /// Optional schema to select immediately after session creation on the owner thread.
    public let preferredSchemaID: String?

    public init(
        sharedDataDir: String,
        userDataDir: String,
        preferredSchemaID: String? = nil
    ) {
        self.sharedDataDir = sharedDataDir
        self.userDataDir = userDataDir
        self.preferredSchemaID = preferredSchemaID
    }

    public func makeEngineOnOwnerThread() -> any RimeEngine {
        let engine = RimeEngineImpl(
            sharedDataDir: sharedDataDir,
            userDataDir: userDataDir
        )
        if let preferredSchemaID, !preferredSchemaID.isEmpty {
            _ = engine.bridge.selectSchema(preferredSchemaID)
        }
        return engine
    }
}
