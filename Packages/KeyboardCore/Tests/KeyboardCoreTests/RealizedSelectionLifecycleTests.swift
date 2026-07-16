import XCTest

@testable import KeyboardCore

/// Lifecycle paths for realized selection: resume early failure, recovery schema change,
/// and recovery session failure. Uses FakeRimeEngine contracts that mirror production
/// publish/fail-closed behavior (see RimeEngineImpl resume/recovery).
@MainActor
final class RealizedSelectionLifecycleTests: XCTestCase {
    private func matchedT9Selection() -> RimeRuntimeSelection {
        let fingerprint = "lifecycle-fp"
        let marker = RimeT9ReadinessMarker(
            ready: true,
            compatibilityVersion: RimeT9Readiness.currentCompatibilityVersion,
            resourceFingerprint: fingerprint
        )
        return RimeRuntimeSelection.resolve(
            baseSchemaID: "rime_ice",
            layoutRawValue: KeyboardLayoutStyle.nineKey.rawValue,
            readinessMarker: marker,
            onDiskFingerprint: fingerprint
        )
    }

    /// Simulates extension chrome caches driven by `onRuntimeSelectionChanged`.
    private final class ChromeSurface {
        var layoutStyle: KeyboardLayoutStyle = .twentySixKey
        var t9ReadinessMatched = false
        var usesT9InputSemantics = false
        var reloadCount = 0

        func apply(_ selection: RimeRuntimeSelection) {
            let previousLayout = layoutStyle
            let previousSemantics = usesT9InputSemantics
            let surface = selection.surface
            layoutStyle = surface.layoutStyle
            t9ReadinessMatched = surface.t9ReadinessMatched
            usesT9InputSemantics = surface.usesT9InputSemantics
            if previousLayout != layoutStyle || previousSemantics != usesT9InputSemantics {
                reloadCount += 1
            }
        }

        func assertFailClosed(file: StaticString = #filePath, line: UInt = #line) {
            XCTAssertEqual(layoutStyle, .twentySixKey, file: file, line: line)
            XCTAssertFalse(t9ReadinessMatched, file: file, line: line)
            XCTAssertFalse(usesT9InputSemantics, file: file, line: line)
        }
    }

    private func wire(
        engine: FakeRimeEngine,
        controller: KeyboardController,
        chrome: ChromeSurface
    ) {
        engine.onRuntimeSelectionChanged = { selection in
            chrome.apply(selection)
            controller.usesT9InputSemantics = selection.usesT9InputSemantics
        }
        controller.rimeEngine = engine
    }

    func testPreviousT9PlusResumeInitFailurePublishesObservableTwentySixKey() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        let chrome = ChromeSurface()
        wire(engine: engine, controller: controller, chrome: chrome)

        let t9 = matchedT9Selection()
        XCTAssertTrue(t9.usesT9InputSemantics)
        engine.seedRuntimeSelection(t9)
        chrome.apply(t9)
        controller.usesT9InputSemantics = true
        XCTAssertEqual(chrome.layoutStyle, .nineKey)

        engine.resumeInitShouldFail = true
        controller.suspendRimeForVisibilityChange()
        controller.resumeRimeAfterVisibilityChange()

        XCTAssertFalse(controller.usesT9InputSemantics)
        chrome.assertFailClosed()
        XCTAssertEqual(engine.runtimeSelection?.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(engine.runtimeSelection?.usesT9InputSemantics ?? true)
        XCTAssertGreaterThanOrEqual(chrome.reloadCount, 1)
        // Digit policy must not stay on T9 after fail-close.
        XCTAssertEqual(
            T9CompositionCommitPolicy.returnAction(
                usesT9InputSemantics: controller.usesT9InputSemantics,
                rawInput: "64",
                candidates: [],
                highlightedIndex: nil
            ),
            .notT9Composition
        )
    }

    func testPreviousT9PlusResumeSchemaSelectionFailurePublishesObservableTwentySixKey() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        let chrome = ChromeSurface()
        wire(engine: engine, controller: controller, chrome: chrome)

        let t9 = matchedT9Selection()
        engine.seedRuntimeSelection(t9)
        chrome.apply(t9)
        controller.usesT9InputSemantics = true

        engine.resumeSchemaSelectShouldFail = true
        controller.suspendRimeForVisibilityChange()
        controller.resumeRimeAfterVisibilityChange()

        XCTAssertFalse(controller.usesT9InputSemantics)
        chrome.assertFailClosed()
        XCTAssertEqual(engine.runtimeSelection?.effectiveLayoutStyle, .twentySixKey)
    }

    func testVisibleT9PlusInPlaceRecoveryToRimeIceConvergesEngineChromeController() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        let chrome = ChromeSurface()
        wire(engine: engine, controller: controller, chrome: chrome)

        let t9 = matchedT9Selection()
        engine.seedRuntimeSelection(t9)
        chrome.apply(t9)
        controller.usesT9InputSemantics = true
        XCTAssertEqual(chrome.layoutStyle, .nineKey)

        // Production recovery path: recoverSession then controller.applyRealizedSelectionFromEngine.
        engine.recoverActualSchemaID = "rime_ice"
        engine.recoverSession()
        controller.applyRealizedSelectionFromEngine()

        XCTAssertEqual(engine.runtimeSelection?.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(engine.runtimeSelection?.usesT9InputSemantics ?? true)
        XCTAssertFalse(controller.usesT9InputSemantics)
        chrome.assertFailClosed()
        XCTAssertGreaterThanOrEqual(chrome.reloadCount, 1)
    }

    func testRecoverySessionRecreationFailureClearsStaleT9Semantics() {
        let engine = FakeRimeEngine()
        let controller = KeyboardController()
        let chrome = ChromeSurface()
        wire(engine: engine, controller: controller, chrome: chrome)

        let t9 = matchedT9Selection()
        engine.seedRuntimeSelection(t9)
        chrome.apply(t9)
        controller.usesT9InputSemantics = true

        engine.recoverSessionShouldFail = true
        engine.recoverSession()
        controller.applyRealizedSelectionFromEngine()

        XCTAssertFalse(controller.usesT9InputSemantics)
        chrome.assertFailClosed()
        XCTAssertEqual(engine.runtimeSelection?.effectiveSchemaID, "rime_ice")
        XCTAssertFalse(engine.runtimeSelection?.usesT9InputSemantics ?? true)
    }

    func testControllerRestoreWithRebuildPropagatesFailClosedRecovery() {
        let engine = FakeRimeEngine()
        let client = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = client
        let chrome = ChromeSurface()
        wire(engine: engine, controller: controller, chrome: chrome)

        let t9 = matchedT9Selection()
        engine.seedRuntimeSelection(t9)
        chrome.apply(t9)
        controller.usesT9InputSemantics = true

        // Seed a composition so rebuild recovery runs through restoreRimeComposition.
        controller.state.inputMode = .chinese
        controller.state.currentComposition = "64"
        engine.recoverActualSchemaID = "rime_ice"

        // processKeysToDrop forces rebuildSession path on next key (invalid session recovery).
        engine.processKeysToDrop = 1
        controller.shouldRestoreRimeComposition = true
        controller.shouldRebuildSessionDuringRestore = true

        // Drive recovery via public API: insert after forced invalid key handling.
        // Directly invoke restore path through handle after marking rebuild flags.
        // Simulate the internal recover call sequence used by restoreRimeComposition.
        let restored = controller.restoreRimeCompositionForTests(
            "6",
            using: engine,
            rebuildSession: true
        )
        // Composition may or may not restore depending on dictionary; selection must converge.
        _ = restored
        XCTAssertFalse(controller.usesT9InputSemantics)
        chrome.assertFailClosed()
    }
}

@MainActor
extension KeyboardController {
    /// Test seam: production `restoreRimeComposition` is internal to the package.
    func restoreRimeCompositionForTests(
        _ text: String,
        using engine: RimeEngine,
        rebuildSession: Bool
    ) -> Bool {
        restoreRimeComposition(text, using: engine, rebuildSession: rebuildSession)
    }
}
