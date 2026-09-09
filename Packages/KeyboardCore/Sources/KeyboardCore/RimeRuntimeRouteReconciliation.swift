import Foundation

/// A persisted layout slot and the facts required to decide whether removing a
/// schema makes that slot unusable.
///
/// The Main App creates this snapshot from App Group preferences. KeyboardCore
/// deliberately does not read or write those preferences: reconciliation must
/// be deterministic before an uninstall transaction changes files or deploys.
public struct RimeRuntimeRouteSlot: Sendable, Equatable {
    /// Stable App Group preference key owned by the caller.
    public let preferenceKey: String
    public let layoutStyle: KeyboardLayoutStyle
    /// The schema identity currently stored in this slot, if any.
    public let boundSchemaID: String?
    /// Schemas that this slot can represent as a selected runtime route.
    public let supportedSchemaIDs: [String]
    /// Resources logically required by this route in addition to its binding.
    /// For example, the `t9` route depends on the Ice resource closure.
    public let dependencySchemaIDs: [String]
    /// The approved route to select if this slot is the active route at removal.
    public let fallback: RimeRuntimeRouteFallback?

    public init(
        preferenceKey: String,
        layoutStyle: KeyboardLayoutStyle,
        boundSchemaID: String?,
        supportedSchemaIDs: [String],
        dependencySchemaIDs: [String] = [],
        fallback: RimeRuntimeRouteFallback? = nil
    ) {
        self.preferenceKey = Self.normalizedSchemaID(preferenceKey)
        self.layoutStyle = layoutStyle
        // Keep nil distinct from an explicitly supplied empty value. The
        // reconciler can then reject malformed descriptors without changing
        // the meaning of an unbound optional slot.
        self.boundSchemaID = boundSchemaID.map(Self.normalizedSchemaID)
        self.supportedSchemaIDs = supportedSchemaIDs.map(Self.normalizedSchemaID)
        self.dependencySchemaIDs = dependencySchemaIDs.map(Self.normalizedSchemaID)
        self.fallback = fallback
    }

    fileprivate func references(_ schemaID: String) -> Bool {
        boundSchemaID == schemaID || dependencySchemaIDs.contains(schemaID)
    }

    private static func normalizedSchemaID(_ schemaID: String?) -> String {
        schemaID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

/// A product-approved, compatible fallback route for one layout slot.
public struct RimeRuntimeRouteFallback: Sendable, Equatable {
    public enum Availability: Sendable, Equatable {
        case available
        case unavailable
    }

    public let layoutStyle: KeyboardLayoutStyle
    public let preferenceKey: String
    public let schemaID: String
    public let availability: Availability

    public init(
        layoutStyle: KeyboardLayoutStyle,
        preferenceKey: String,
        schemaID: String,
        availability: Availability = .available
    ) {
        self.layoutStyle = layoutStyle
        self.preferenceKey = preferenceKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaID = schemaID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.availability = availability
    }
}

/// The route already resolved from layout, binding and readiness facts.
///
/// `selectedLayoutStyle` in the snapshot is the persisted preference. This
/// value is the runtime fact and may intentionally point at the 26-key slot
/// when nine-key readiness has failed closed.
public struct RimeRuntimeEffectiveRoute: Sendable, Equatable {
    public enum State: Sendable, Equatable {
        case ready
        case failClosed
    }

    public let schemaID: String
    public let layoutStyle: KeyboardLayoutStyle
    public let usesT9InputSemantics: Bool
    public let state: State

    public init(
        schemaID: String,
        layoutStyle: KeyboardLayoutStyle,
        usesT9InputSemantics: Bool,
        state: State
    ) {
        self.schemaID = schemaID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.layoutStyle = layoutStyle
        self.usesT9InputSemantics = usesT9InputSemantics
        self.state = state
    }
}

/// Complete input to the active-uninstall route decision.
public struct RimeRuntimeRouteSnapshot: Sendable, Equatable {
    public let selectedLayoutStyle: KeyboardLayoutStyle
    public let effectiveRoute: RimeRuntimeEffectiveRoute
    /// Legacy `rime_active_schema` alias. It is retained as persistent state
    /// for rollback even when the effective route is the logical `t9` route.
    public let activeSchemaID: String
    public let slots: [RimeRuntimeRouteSlot]

    public init(
        selectedLayoutStyle: KeyboardLayoutStyle,
        effectiveRoute: RimeRuntimeEffectiveRoute,
        activeSchemaID: String,
        slots: [RimeRuntimeRouteSlot]
    ) {
        self.selectedLayoutStyle = selectedLayoutStyle
        self.effectiveRoute = effectiveRoute
        self.activeSchemaID = activeSchemaID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.slots = slots
    }
}

/// A persisted layout binding. `schemaID == nil` means the slot is unbound.
public struct RimeRuntimeRouteBinding: Sendable, Equatable {
    public let preferenceKey: String
    public let schemaID: String?

    public init(preferenceKey: String, schemaID: String?) {
        self.preferenceKey = preferenceKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaID = schemaID.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

/// The final value for one binding. `schemaID == nil` means clear that binding.
public struct RimeRuntimeRouteBindingMutation: Sendable, Equatable {
    public let preferenceKey: String
    public let schemaID: String?

    public init(preferenceKey: String, schemaID: String?) {
        self.preferenceKey = preferenceKey
        self.schemaID = schemaID
    }
}

/// Complete persistent route state used by the future Main-App transaction.
/// Keeping every binding and the legacy alias in both states makes rollback
/// independent of which individual keys the transaction touched.
public struct RimeRuntimeRouteState: Sendable, Equatable {
    public let selectedLayoutStyle: KeyboardLayoutStyle
    public let effectiveRoute: RimeRuntimeEffectiveRoute
    public let activeSchemaID: String
    public let bindings: [RimeRuntimeRouteBinding]

    public init(
        selectedLayoutStyle: KeyboardLayoutStyle,
        effectiveRoute: RimeRuntimeEffectiveRoute,
        activeSchemaID: String,
        bindings: [RimeRuntimeRouteBinding]
    ) {
        self.selectedLayoutStyle = selectedLayoutStyle
        self.effectiveRoute = effectiveRoute
        self.activeSchemaID = activeSchemaID
        self.bindings = bindings
    }
}

/// Pure mutation to persist as one Main-App transaction before fallback deploy.
public struct RimeRuntimeRouteMutation: Sendable, Equatable {
    public let before: RimeRuntimeRouteState
    public let after: RimeRuntimeRouteState
    public let bindingMutations: [RimeRuntimeRouteBindingMutation]

    public init(
        before: RimeRuntimeRouteState,
        after: RimeRuntimeRouteState,
        bindingMutations: [RimeRuntimeRouteBindingMutation],
    ) {
        self.before = before
        self.after = after
        self.bindingMutations = bindingMutations
    }

    /// Read-only compatibility accessors for the original mutation seam.
    public var selectedLayoutStyle: KeyboardLayoutStyle { after.selectedLayoutStyle }
    public var activeSchemaID: String { after.activeSchemaID }
}

public enum RimeRuntimeRouteInputFailure: Error, Sendable, Equatable {
    case emptyRemovedSchemaID
    case emptyFallbackSchemaID
    case fallbackSchemaMatchesRemoved(schemaID: String)
    case fallbackSchemaNotApproved(schemaID: String)
}

public enum RimeRuntimeRouteSnapshotFailure: Error, Sendable, Equatable {
    case emptyActiveSchemaID
    case emptyEffectiveRouteSchemaID
    case emptyPreferenceKey(index: Int)
    case emptyBoundSchemaID(index: Int)
    case emptySupportedSchemaID(index: Int)
    case emptyDependencySchemaID(index: Int)
    case duplicatePreferenceKey(String)
    case duplicateLayoutStyle(KeyboardLayoutStyle)
    case missingEffectiveRouteSlot(KeyboardLayoutStyle)
    case effectiveRouteSchemaUnsupported(preferenceKey: String, schemaID: String)
    case effectiveRouteBindingMismatch(
        preferenceKey: String,
        schemaID: String,
        boundSchemaID: String?
    )
    case emptyFallbackPreferenceKey(index: Int)
    case emptyFallbackSchema(preferenceKey: String)
    case missingFallback(preferenceKey: String)
    case fallbackPreferenceKeyMissing(preferenceKey: String)
    case fallbackLayoutMismatch(
        preferenceKey: String,
        targetPreferenceKey: String,
        declared: KeyboardLayoutStyle,
        actual: KeyboardLayoutStyle
    )
    case fallbackSchemaMismatch(
        preferenceKey: String,
        expected: String,
        actual: String
    )
    case fallbackSchemaUnsupported(preferenceKey: String, schemaID: String)
    case unavailableFallback(preferenceKey: String)
}

/// Reasons that active-uninstall reconciliation cannot produce a safe pure mutation.
public enum RimeRuntimeRouteReconciliationFailure: Error, Sendable, Equatable {
    /// The requested scheme is not part of the already-resolved runtime route.
    case inactiveRoute
    case invalidInput(RimeRuntimeRouteInputFailure)
    case invalidSnapshot(RimeRuntimeRouteSnapshotFailure)

    /// Compatibility names for callers migrating from the initial seam.
    public static var inactiveUninstall: Self { .inactiveRoute }
    public static var selectedRouteDoesNotReferenceRemovedSchema: Self { .inactiveRoute }

    public static func missingFallback(preferenceKey: String) -> Self {
        .invalidSnapshot(.missingFallback(preferenceKey: preferenceKey))
    }

    public static func unsupportedFallback(preferenceKey: String, schemaID: String) -> Self {
        .invalidSnapshot(.fallbackSchemaUnsupported(preferenceKey: preferenceKey, schemaID: schemaID))
    }

    public static func duplicatePreferenceKey(_ key: String) -> Self {
        .invalidSnapshot(.duplicatePreferenceKey(key))
    }

    public static func duplicateLayoutStyle(_ style: KeyboardLayoutStyle) -> Self {
        .invalidSnapshot(.duplicateLayoutStyle(style))
    }
}

/// Reconciles an *active* runtime route before its schema resources are removed.
///
/// It intentionally has no knowledge of UserDefaults, deployment, or staging.
/// The caller must apply the returned mutation atomically, then deploy the
/// returned active schema while the uninstall transaction still owns its lease.
public enum RimeRuntimeRouteReconciler {
    public static func reconcileAfterSchemaRemoval(
        snapshot: RimeRuntimeRouteSnapshot,
        removedSchemaID: String,
        fallbackSchemaID: String = "luna_pinyin"
    ) -> Result<RimeRuntimeRouteMutation, RimeRuntimeRouteReconciliationFailure> {
        let removed = normalizedSchemaID(removedSchemaID)
        let fallbackSchema = normalizedSchemaID(fallbackSchemaID)
        guard !removed.isEmpty else {
            return .failure(.invalidInput(.emptyRemovedSchemaID))
        }
        guard !fallbackSchema.isEmpty else {
            return .failure(.invalidInput(.emptyFallbackSchemaID))
        }
        guard canonicalSchemaID(fallbackSchema) != canonicalSchemaID(removed) else {
            return .failure(.invalidInput(.fallbackSchemaMatchesRemoved(schemaID: fallbackSchema)))
        }
        guard fallbackSchema == "luna_pinyin" else {
            return .failure(.invalidInput(.fallbackSchemaNotApproved(schemaID: fallbackSchema)))
        }

        if let failure = validate(snapshot: snapshot) {
            return .failure(failure)
        }

        guard
            let effectiveSlot = snapshot.slots.first(where: {
                $0.layoutStyle == snapshot.effectiveRoute.layoutStyle
            })
        else {
            return .failure(
                .invalidSnapshot(
                    .missingEffectiveRouteSlot(snapshot.effectiveRoute.layoutStyle)
                )
            )
        }

        guard effectiveSlot.references(removed) else {
            return .failure(.inactiveRoute)
        }

        guard let routeFallback = effectiveSlot.fallback else {
            return .failure(.missingFallback(preferenceKey: effectiveSlot.preferenceKey))
        }
        guard routeFallback.availability == .available else {
            return .failure(
                .invalidSnapshot(.unavailableFallback(preferenceKey: routeFallback.preferenceKey))
            )
        }
        guard routeFallback.schemaID == fallbackSchema else {
            return .invalidFailure(
                .fallbackSchemaMismatch(
                    preferenceKey: effectiveSlot.preferenceKey,
                    expected: fallbackSchema,
                    actual: routeFallback.schemaID
                )
            )
        }
        guard
            let fallbackSlot = snapshot.slots.first(where: {
                $0.preferenceKey == routeFallback.preferenceKey
            })
        else {
            return .failure(
                .invalidSnapshot(
                    .fallbackPreferenceKeyMissing(preferenceKey: routeFallback.preferenceKey)
                )
            )
        }

        guard fallbackSlot.layoutStyle == routeFallback.layoutStyle else {
            return .failure(
                .invalidSnapshot(
                    .fallbackLayoutMismatch(
                        preferenceKey: effectiveSlot.preferenceKey,
                        targetPreferenceKey: routeFallback.preferenceKey,
                        declared: routeFallback.layoutStyle,
                        actual: fallbackSlot.layoutStyle
                    )
                )
            )
        }
        guard fallbackSlot.layoutStyle == .twentySixKey else {
            return .failure(
                .invalidSnapshot(
                    .fallbackSchemaUnsupported(
                        preferenceKey: routeFallback.preferenceKey,
                        schemaID: fallbackSchema
                    )
                )
            )
        }
        guard fallbackSlot.supportedSchemaIDs.contains(fallbackSchema) else {
            return .failure(
                .invalidSnapshot(
                    .fallbackSchemaUnsupported(
                        preferenceKey: routeFallback.preferenceKey,
                        schemaID: fallbackSchema
                    )
                )
            )
        }

        let beforeBindings = snapshot.slots.map {
            RimeRuntimeRouteBinding(preferenceKey: $0.preferenceKey, schemaID: $0.boundSchemaID)
        }
        let afterBindings = snapshot.slots.map { slot in
            let schemaID: String?
            if slot.preferenceKey == routeFallback.preferenceKey {
                schemaID = fallbackSchema
            } else if slot.references(removed) {
                schemaID = nil
            } else {
                schemaID = slot.boundSchemaID
            }
            return RimeRuntimeRouteBinding(preferenceKey: slot.preferenceKey, schemaID: schemaID)
        }
        let mutations = zip(beforeBindings, afterBindings).compactMap {
            before, after -> RimeRuntimeRouteBindingMutation? in
            guard before.schemaID != after.schemaID else { return nil }
            return RimeRuntimeRouteBindingMutation(
                preferenceKey: after.preferenceKey,
                schemaID: after.schemaID
            )
        }

        let before = RimeRuntimeRouteState(
            selectedLayoutStyle: snapshot.selectedLayoutStyle,
            effectiveRoute: snapshot.effectiveRoute,
            activeSchemaID: snapshot.activeSchemaID,
            bindings: beforeBindings
        )
        let after = RimeRuntimeRouteState(
            selectedLayoutStyle: routeFallback.layoutStyle,
            effectiveRoute: RimeRuntimeEffectiveRoute(
                schemaID: fallbackSchema,
                layoutStyle: routeFallback.layoutStyle,
                usesT9InputSemantics: false,
                state: .ready
            ),
            activeSchemaID: fallbackSchema,
            bindings: afterBindings
        )

        return .success(
            RimeRuntimeRouteMutation(
                before: before,
                after: after,
                bindingMutations: mutations,
            )
        )
    }

    private static func validate(
        snapshot: RimeRuntimeRouteSnapshot
    ) -> RimeRuntimeRouteReconciliationFailure? {
        guard !snapshot.activeSchemaID.isEmpty else {
            return .invalidSnapshot(.emptyActiveSchemaID)
        }
        guard !snapshot.effectiveRoute.schemaID.isEmpty else {
            return .invalidSnapshot(.emptyEffectiveRouteSchemaID)
        }
        var preferenceKeys = Set<String>()
        var layoutStyles: [KeyboardLayoutStyle] = []
        for (index, slot) in snapshot.slots.enumerated() {
            guard !slot.preferenceKey.isEmpty else {
                return .invalidSnapshot(.emptyPreferenceKey(index: index))
            }
            guard preferenceKeys.insert(slot.preferenceKey).inserted else {
                return .invalidSnapshot(.duplicatePreferenceKey(slot.preferenceKey))
            }
            guard !layoutStyles.contains(slot.layoutStyle) else {
                return .invalidSnapshot(.duplicateLayoutStyle(slot.layoutStyle))
            }
            layoutStyles.append(slot.layoutStyle)
            if let boundSchemaID = slot.boundSchemaID, boundSchemaID.isEmpty {
                return .invalidSnapshot(.emptyBoundSchemaID(index: index))
            }
            if slot.supportedSchemaIDs.isEmpty {
                return .invalidSnapshot(.emptySupportedSchemaID(index: index))
            }
            if slot.supportedSchemaIDs.contains(where: { $0.isEmpty }) {
                return .invalidSnapshot(.emptySupportedSchemaID(index: index))
            }
            if slot.dependencySchemaIDs.contains(where: { $0.isEmpty }) {
                return .invalidSnapshot(.emptyDependencySchemaID(index: index))
            }
            if let fallback = slot.fallback {
                if fallback.preferenceKey.isEmpty {
                    return .invalidSnapshot(.emptyFallbackPreferenceKey(index: index))
                }
                if fallback.schemaID.isEmpty {
                    return .invalidSnapshot(
                        .emptyFallbackSchema(preferenceKey: slot.preferenceKey)
                    )
                }
            }
        }
        guard
            let effectiveSlot = snapshot.slots.first(where: {
                $0.layoutStyle == snapshot.effectiveRoute.layoutStyle
            })
        else {
            return .invalidSnapshot(
                .missingEffectiveRouteSlot(snapshot.effectiveRoute.layoutStyle)
            )
        }
        guard effectiveSlot.supportedSchemaIDs.contains(snapshot.effectiveRoute.schemaID) else {
            return .invalidSnapshot(
                .effectiveRouteSchemaUnsupported(
                    preferenceKey: effectiveSlot.preferenceKey,
                    schemaID: snapshot.effectiveRoute.schemaID
                )
            )
        }
        guard effectiveSlot.boundSchemaID == snapshot.effectiveRoute.schemaID else {
            return .invalidSnapshot(
                .effectiveRouteBindingMismatch(
                    preferenceKey: effectiveSlot.preferenceKey,
                    schemaID: snapshot.effectiveRoute.schemaID,
                    boundSchemaID: effectiveSlot.boundSchemaID
                )
            )
        }
        return nil
    }

    private static func normalizedSchemaID(_ schemaID: String) -> String {
        schemaID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func canonicalSchemaID(_ schemaID: String) -> String {
        RimeSchemeCapabilityMatrix.normalizeSchemaID(schemaID)
    }
}

private extension Result
where
    Success == RimeRuntimeRouteMutation,
    Failure == RimeRuntimeRouteReconciliationFailure
{
    static func invalidFailure(
        _ snapshotFailure: RimeRuntimeRouteSnapshotFailure
    ) -> Self {
        .failure(.invalidSnapshot(snapshotFailure))
    }
}
