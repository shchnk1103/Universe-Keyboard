import KeyboardCore

/// Installs the synchronous engine only after the responsive owner path has exited.
/// Owner teardown and UIKit lifecycle remain the caller's responsibility.
@MainActor
public enum SynchronousRimeFallbackInstaller {
    public static func install<Engine: RimeEngine>(
        on controller: KeyboardController,
        makeEngine: () -> Engine,
        onRuntimeSelectionChanged: @escaping (RimeRuntimeSelection) -> Void
    ) -> Engine? {
        guard !controller.isResponsiveRimePipelineEnabled,
            !controller.isThreadAffineRimeOwnerEnabled,
            controller.threadAffineEngineBootstrap == nil,
            controller.responsiveRimeCoordinator == nil,
            controller.threadAffineRimeCoordinator == nil,
            !(controller.rimeEngine is ResponsiveRimeEngineBridge),
            !(controller.rimeEngine is ThreadAffineRimeEngineBridge)
        else { return nil }

        // Connect recovery/resume publication before exposing the new engine.
        let engine = makeEngine()
        engine.onRuntimeSelectionChanged = onRuntimeSelectionChanged
        controller.rimeEngine = engine
        return engine
    }
}
