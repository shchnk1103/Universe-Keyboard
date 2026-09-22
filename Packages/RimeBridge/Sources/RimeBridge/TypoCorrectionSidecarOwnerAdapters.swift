import KeyboardCore

/// Route-aware factory over an already-installed query facade. The adapter
/// never exposes a raw session, creates a second session or invents an epoch.
public enum TypoCorrectionSidecarOwnerAdapters {
    public static func wrapping(
        _ query: TypoCorrectionCandidateQuerying,
        route: TypoCorrectionSidecarRoute = .defaultMainActor,
        routeLocalOwnerEpochProvider: @escaping @MainActor () -> UInt64? = { nil }
    ) -> InstalledTypoCorrectionSidecarOwner {
        InstalledTypoCorrectionSidecarOwner(
            query: query,
            route: route,
            routeLocalOwnerEpochProvider: routeLocalOwnerEpochProvider
        )
    }
}

extension RimeEngineImpl {
    public func makeTypoCorrectionSidecarOwner() -> InstalledTypoCorrectionSidecarOwner {
        TypoCorrectionSidecarOwnerAdapters.wrapping(self, route: .defaultMainActor)
    }
}
