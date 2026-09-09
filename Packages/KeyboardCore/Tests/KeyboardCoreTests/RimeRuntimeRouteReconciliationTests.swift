import XCTest

@testable import KeyboardCore

final class RimeRuntimeRouteReconciliationTests: XCTestCase {
    func testRemovingActiveIceNineKeyRouteClearsDependenciesAndSelectsLuna() throws {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .nineKey,
                effectiveRoute: effectiveRoute(schemaID: "t9", layout: .nineKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice"
        )

        let mutation = try XCTUnwrap(result.successValue)
        XCTAssertEqual(mutation.after.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(mutation.after.selectedLayoutStyle, .twentySixKey)
        XCTAssertEqual(mutation.after.effectiveRoute.layoutStyle, .twentySixKey)
        XCTAssertEqual(mutation.after.effectiveRoute.state, .ready)
        XCTAssertEqual(
            mutation.bindingMutations,
            [
                RimeRuntimeRouteBindingMutation(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "luna_pinyin"
                ),
                RimeRuntimeRouteBindingMutation(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding9,
                    schemaID: nil
                ),
            ]
        )
    }

    func testRemovingActiveIceTwentySixKeyRouteClearsDependentNineKeyBinding() throws {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice"
        )

        let mutation = try XCTUnwrap(result.successValue)
        XCTAssertEqual(mutation.after.selectedLayoutStyle, .twentySixKey)
        XCTAssertEqual(mutation.after.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(
            mutation.bindingMutations,
            [
                RimeRuntimeRouteBindingMutation(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "luna_pinyin"
                ),
                RimeRuntimeRouteBindingMutation(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding9,
                    schemaID: nil
                ),
            ]
        )
    }

    func testReadinessFailClosedUsesEffectiveTwentySixKeyRouteForActivity() throws {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .nineKey,
                effectiveRoute: RimeRuntimeEffectiveRoute(
                    schemaID: "wanxiang",
                    layoutStyle: .twentySixKey,
                    usesT9InputSemantics: false,
                    state: .failClosed
                ),
                activeSchemaID: "wanxiang",
                binding26: "wanxiang",
                binding9: "t9"
            ),
            removedSchemaID: "wanxiang"
        )

        let mutation = try XCTUnwrap(result.successValue)
        XCTAssertEqual(mutation.before.effectiveRoute.layoutStyle, .twentySixKey)
        XCTAssertEqual(mutation.before.effectiveRoute.state, .failClosed)
        XCTAssertEqual(mutation.after.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(mutation.after.selectedLayoutStyle, .twentySixKey)
        XCTAssertEqual(
            mutation.bindingMutations,
            [
                RimeRuntimeRouteBindingMutation(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "luna_pinyin"
                )
            ]
        )
    }

    func testReadinessFailClosedMakesIceRemovalInactiveWhenWanxiangIsEffective() {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .nineKey,
                effectiveRoute: RimeRuntimeEffectiveRoute(
                    schemaID: "wanxiang",
                    layoutStyle: .twentySixKey,
                    usesT9InputSemantics: false,
                    state: .failClosed
                ),
                activeSchemaID: "wanxiang",
                binding26: "wanxiang",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(result.failureValue, .selectedRouteDoesNotReferenceRemovedSchema)
    }

    func testRemovingActiveWanxiangPreservesUnrelatedNineKeyBinding() throws {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "wanxiang", layout: .twentySixKey),
                activeSchemaID: "wanxiang",
                binding26: "wanxiang",
                binding9: "t9"
            ),
            removedSchemaID: "wanxiang"
        )

        let mutation = try XCTUnwrap(result.successValue)
        XCTAssertEqual(mutation.after.selectedLayoutStyle, .twentySixKey)
        XCTAssertEqual(mutation.after.activeSchemaID, "luna_pinyin")
        XCTAssertEqual(
            mutation.bindingMutations,
            [
                RimeRuntimeRouteBindingMutation(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "luna_pinyin"
                )
            ]
        )
        XCTAssertEqual(
            mutation.after.bindings.first(where: {
                $0.preferenceKey == KeyboardLayoutSettingsKey.schemeBinding9
            })?.schemaID,
            "t9"
        )
    }

    func testInactiveUninstallRouteStopsWithoutChangingBindings() {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "wanxiang", layout: .twentySixKey),
                activeSchemaID: "wanxiang",
                binding26: "wanxiang",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(result.failureValue, .selectedRouteDoesNotReferenceRemovedSchema)
    }

    func testBeforeStatePreservesLegacyAliasAndEveryBindingForRollback() throws {
        let snapshot = makeSnapshot(
            selectedLayout: .nineKey,
            effectiveRoute: effectiveRoute(schemaID: "t9", layout: .nineKey),
            activeSchemaID: "rime_ice",
            binding26: "rime_ice",
            binding9: "t9"
        )
        let mutation = try XCTUnwrap(
            RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
                snapshot: snapshot,
                removedSchemaID: "rime_ice"
            ).successValue
        )

        XCTAssertEqual(mutation.before.selectedLayoutStyle, .nineKey)
        XCTAssertEqual(mutation.before.activeSchemaID, "rime_ice")
        XCTAssertEqual(mutation.before.effectiveRoute.schemaID, "t9")
        XCTAssertEqual(
            mutation.before.bindings,
            [
                RimeRuntimeRouteBinding(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "rime_ice"
                ),
                RimeRuntimeRouteBinding(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding9,
                    schemaID: "t9"
                ),
            ]
        )
    }

    func testAfterStateResolvesToLunaTwentySixKeyRoute() throws {
        let mutation = try XCTUnwrap(
            RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
                snapshot: makeSnapshot(
                    selectedLayout: .nineKey,
                    effectiveRoute: effectiveRoute(schemaID: "t9", layout: .nineKey),
                    activeSchemaID: "rime_ice",
                    binding26: "rime_ice",
                    binding9: "t9"
                ),
                removedSchemaID: "rime_ice"
            ).successValue
        )
        let binding26 = mutation.after.bindings.first {
            $0.preferenceKey == KeyboardLayoutSettingsKey.schemeBinding26
        }?.schemaID
        let binding9 = mutation.after.bindings.first {
            $0.preferenceKey == KeyboardLayoutSettingsKey.schemeBinding9
        }?.schemaID

        let resolved = RimeRuntimeSelection(
            baseSchemaID: mutation.after.activeSchemaID,
            layoutStyle: mutation.after.selectedLayoutStyle,
            t9ReadinessMatched: true,
            schemeBinding26: binding26,
            schemeBinding9: binding9
        )

        XCTAssertEqual(resolved.effectiveSchemaID, "luna_pinyin")
        XCTAssertEqual(resolved.effectiveLayoutStyle, .twentySixKey)
        XCTAssertFalse(resolved.usesT9InputSemantics)
    }

    func testUnknownSelectedSlotWithoutFallbackStopsBeforeAnyMutation() {
        let unknownSlot = RimeRuntimeRouteSlot(
            preferenceKey: "future_layout_scheme",
            layoutStyle: .nineKey,
            boundSchemaID: "future_ice_route",
            supportedSchemaIDs: ["future_ice_route"],
            dependencySchemaIDs: ["rime_ice"]
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: RimeRuntimeRouteSnapshot(
                selectedLayoutStyle: .nineKey,
                effectiveRoute: effectiveRoute(schemaID: "future_ice_route", layout: .nineKey),
                activeSchemaID: "future_ice_route",
                slots: [unknownSlot]
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(result.failureValue, .missingFallback(preferenceKey: "future_layout_scheme"))
    }

    func testEmptyRemovedSchemaIsInvalidInputAndNotInactiveUninstall() {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9"
            ),
            removedSchemaID: "   "
        )

        XCTAssertEqual(result.failureValue, .invalidInput(.emptyRemovedSchemaID))
    }

    func testFallbackCannotBeTheRemovedSchema() {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice",
            fallbackSchemaID: "t9"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidInput(.fallbackSchemaMatchesRemoved(schemaID: "t9"))
        )
    }

    func testNonLunaFallbackIsRejectedByLunaOnlyPolicy() {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice",
            fallbackSchemaID: "wanxiang"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidInput(.fallbackSchemaNotApproved(schemaID: "wanxiang"))
        )
    }

    func testEmptyDescriptorFailsClosed() {
        let emptySlot = RimeRuntimeRouteSlot(
            preferenceKey: "  ",
            layoutStyle: .twentySixKey,
            boundSchemaID: "rime_ice",
            supportedSchemaIDs: ["rime_ice"],
            fallback: lunaFallback()
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: RimeRuntimeRouteSnapshot(
                selectedLayoutStyle: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                slots: [emptySlot]
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidSnapshot(.emptyPreferenceKey(index: 0))
        )
    }

    func testDuplicatePreferenceKeyFailsClosed() {
        let first = RimeRuntimeRouteSlot(
            preferenceKey: "duplicate",
            layoutStyle: .twentySixKey,
            boundSchemaID: "rime_ice",
            supportedSchemaIDs: ["rime_ice", "luna_pinyin"],
            fallback: lunaFallback()
        )
        let second = RimeRuntimeRouteSlot(
            preferenceKey: "duplicate",
            layoutStyle: .nineKey,
            boundSchemaID: "t9",
            supportedSchemaIDs: ["t9"],
            dependencySchemaIDs: ["rime_ice"],
            fallback: lunaFallback()
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: RimeRuntimeRouteSnapshot(
                selectedLayoutStyle: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                slots: [first, second]
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(result.failureValue, .invalidSnapshot(.duplicatePreferenceKey("duplicate")))
    }

    func testDuplicateLayoutDescriptorFailsClosed() {
        let first = RimeRuntimeRouteSlot(
            preferenceKey: "first",
            layoutStyle: .twentySixKey,
            boundSchemaID: "rime_ice",
            supportedSchemaIDs: ["rime_ice", "luna_pinyin"],
            fallback: lunaFallback()
        )
        let second = RimeRuntimeRouteSlot(
            preferenceKey: "second",
            layoutStyle: .twentySixKey,
            boundSchemaID: "wanxiang",
            supportedSchemaIDs: ["wanxiang"],
            fallback: lunaFallback()
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: RimeRuntimeRouteSnapshot(
                selectedLayoutStyle: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                slots: [first, second]
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidSnapshot(.duplicateLayoutStyle(.twentySixKey))
        )
    }

    func testFallbackLayoutMustMatchTargetSlot() {
        let mismatchedFallback = RimeRuntimeRouteFallback(
            layoutStyle: .nineKey,
            preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
            schemaID: "luna_pinyin",
            availability: .available
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9",
                fallbackFor26: mismatchedFallback
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidSnapshot(
                .fallbackLayoutMismatch(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    targetPreferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    declared: .nineKey,
                    actual: .twentySixKey
                )
            )
        )
    }

    func testFallbackTargetSchemaMustBeSupportedByTargetSlot() {
        let unsupportedFallback = RimeRuntimeRouteFallback(
            layoutStyle: .twentySixKey,
            preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
            schemaID: "luna_pinyin",
            availability: .available
        )
        let snapshot = makeSnapshot(
            selectedLayout: .twentySixKey,
            effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
            activeSchemaID: "rime_ice",
            binding26: "rime_ice",
            binding9: "t9",
            fallbackFor26: unsupportedFallback,
            supported26: ["rime_ice"]
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: snapshot,
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidSnapshot(
                .fallbackSchemaUnsupported(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "luna_pinyin"
                )
            )
        )
    }

    func testUnavailableFallbackFailsClosed() {
        let unavailable = RimeRuntimeRouteFallback(
            layoutStyle: .twentySixKey,
            preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
            schemaID: "luna_pinyin",
            availability: .unavailable
        )
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "rime_ice", layout: .twentySixKey),
                activeSchemaID: "rime_ice",
                binding26: "rime_ice",
                binding9: "t9",
                fallbackFor26: unavailable
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidSnapshot(
                .unavailableFallback(preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26)
            )
        )
    }

    func testEffectiveRouteMustBeExplicitlySupportedByItsSlot() {
        let result = RimeRuntimeRouteReconciler.reconcileAfterSchemaRemoval(
            snapshot: makeSnapshot(
                selectedLayout: .twentySixKey,
                effectiveRoute: effectiveRoute(schemaID: "not_supported", layout: .twentySixKey),
                activeSchemaID: "not_supported",
                binding26: "rime_ice",
                binding9: "t9"
            ),
            removedSchemaID: "rime_ice"
        )

        XCTAssertEqual(
            result.failureValue,
            .invalidSnapshot(
                .effectiveRouteSchemaUnsupported(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    schemaID: "not_supported"
                )
            )
        )
    }

    private func makeSnapshot(
        selectedLayout: KeyboardLayoutStyle,
        effectiveRoute: RimeRuntimeEffectiveRoute,
        activeSchemaID: String,
        binding26: String,
        binding9: String,
        fallbackFor26: RimeRuntimeRouteFallback? = nil,
        supported26: [String] = ["luna_pinyin", "rime_ice", "wanxiang"]
    ) -> RimeRuntimeRouteSnapshot {
        let fallback = fallbackFor26 ?? lunaFallback()
        return RimeRuntimeRouteSnapshot(
            selectedLayoutStyle: selectedLayout,
            effectiveRoute: effectiveRoute,
            activeSchemaID: activeSchemaID,
            slots: [
                RimeRuntimeRouteSlot(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
                    layoutStyle: .twentySixKey,
                    boundSchemaID: binding26,
                    supportedSchemaIDs: supported26,
                    fallback: fallback
                ),
                RimeRuntimeRouteSlot(
                    preferenceKey: KeyboardLayoutSettingsKey.schemeBinding9,
                    layoutStyle: .nineKey,
                    boundSchemaID: binding9,
                    supportedSchemaIDs: ["t9"],
                    dependencySchemaIDs: ["rime_ice"],
                    fallback: lunaFallback()
                ),
            ]
        )
    }

    private func effectiveRoute(
        schemaID: String,
        layout: KeyboardLayoutStyle,
        state: RimeRuntimeEffectiveRoute.State = .ready
    ) -> RimeRuntimeEffectiveRoute {
        RimeRuntimeEffectiveRoute(
            schemaID: schemaID,
            layoutStyle: layout,
            usesT9InputSemantics: layout == .nineKey,
            state: state
        )
    }

    private func lunaFallback() -> RimeRuntimeRouteFallback {
        RimeRuntimeRouteFallback(
            layoutStyle: .twentySixKey,
            preferenceKey: KeyboardLayoutSettingsKey.schemeBinding26,
            schemaID: "luna_pinyin",
            availability: .available
        )
    }
}

private extension Result
where
    Success == RimeRuntimeRouteMutation,
    Failure == RimeRuntimeRouteReconciliationFailure
{
    var successValue: RimeRuntimeRouteMutation? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    var failureValue: RimeRuntimeRouteReconciliationFailure? {
        guard case let .failure(value) = self else { return nil }
        return value
    }
}
