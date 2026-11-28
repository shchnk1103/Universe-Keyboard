import XCTest

/// PB-016 PR-2: UI wiring contracts for the quick menu. Keyboard.appex is not
/// linkable from XCTest, so these are source-contract checks over the
/// Extension sources (PR1 `QuickMenuSessionReleaseContractTests` pattern).
/// Every missing declaration fails the test: the contract demands the code.
final class QuickMenuUIContractTests: XCTestCase {
    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectRoot = testsDirectory.deletingLastPathComponent()
        return try String(
            contentsOf: projectRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }

    /// Extracts a function body by brace matching. A missing declaration
    /// yields an empty body so the enclosing assertions fail (red), never skip.
    private func rangeOfFunction(_ declaration: String, in source: String) -> Range<String.Index> {
        guard let start = source.range(of: declaration)?.lowerBound,
            let openBrace = source[start...].firstIndex(of: "{")
        else { return source.startIndex..<source.startIndex }
        var depth = 0
        var index = openBrace
        while index < source.endIndex {
            let character = source[index]
            if character == "{" { depth += 1 }
            if character == "}" {
                depth -= 1
                if depth == 0 { return start..<source.index(after: index) }
            }
            index = source.index(after: index)
        }
        return source.startIndex..<source.startIndex
    }

    private func body(ofFunction declaration: String, in source: String) throws -> String {
        let range = rangeOfFunction(declaration, in: source)
        if range.isEmpty, source.contains(declaration) == false {
            throw XCTUnwrapFailure("missing declaration: \(declaration)")
        }
        return String(source[range])
    }

    private func body(ofFunction declaration: String, file: String) throws -> String {
        try body(ofFunction: declaration, in: sourceFile(file))
    }

    private func XCTUnwrapFailure(_ message: String) -> NSError {
        NSError(domain: "QuickMenuUIContractTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }

    // MARK: - Single visibility hook (design r1 §3.1, r3 §4.1 rule 1)

    /// The hook sits at `refreshPasteToolbar(on:)` entry: after the controller
    /// guard, BEFORE the number-pad shortcut strip early return, so that the
    /// early-return branch still refreshes entry visibility (r3 S1 增补).
    /// Re-pinned by arch r4: hook function measured at
    /// `KeyboardViewController+CandidateBar.swift:375` on `d2bfe17`.
    func testVisibilityHookIsSingleAndSitsBeforeShortcutStripEarlyReturn() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+CandidateBar.swift")
        let hookBody = try body(
            ofFunction: "func refreshPasteToolbar(on newBar: CandidateBarView? = nil)",
            in: source)

        let hookCalls = hookBody.components(separatedBy: "refreshQuickMenuEntryVisibility(").count - 1
        XCTAssertEqual(hookCalls, 1, "the visibility hook must be wired exactly once")

        let hookPosition = try XCTUnwrap(
            hookBody.range(of: "refreshQuickMenuEntryVisibility(")?.lowerBound,
            "the visibility hook call must exist at refreshPasteToolbar entry"
        )
        let guardPosition = try XCTUnwrap(
            hookBody.range(of: "guard controller != nil")?.lowerBound,
            "the controller guard must precede the hook"
        )
        let earlyReturnPosition = try XCTUnwrap(
            hookBody.range(of: "syncT9NumberPadShortcutStrip")?.lowerBound,
            "the shortcut-strip branch must follow the hook"
        )
        XCTAssertLessThan(guardPosition, hookPosition, "hook comes after the controller guard")
        XCTAssertLessThan(hookPosition, earlyReturnPosition, "hook comes before the early-return branch")

        // All other visibility refreshes ride the same function; no second hook
        // may be added to `fillCandidateBar` or `makeCandidateBar`.
        let fillBody = try body(
            ofFunction: "func fillCandidateBar(keepScrollPosition: Bool = false",
            file: "Keyboard/Controllers/KeyboardViewController+CandidateBar.swift")
        XCTAssertFalse(
            fillBody.contains("refreshQuickMenuEntryVisibility"),
            "fillCandidateBar must reach the hook only via its refreshPasteToolbar defer"
        )
        let makeBody = try body(
            ofFunction: "func makeCandidateBar()",
            file: "Keyboard/Controllers/KeyboardViewController+CandidateBar.swift")
        XCTAssertFalse(
            makeBody.contains("setUkQuickMenuVisible"),
            "makeCandidateBar must reach the hook only via its refreshPasteToolbar call"
        )
    }

    // MARK: - Release/teardown direct calls (r3 §4.1 rule 2, dismiss paths #4–#6)

    func testCleanupTransientKeyboardStateForceDismissesTheMenu() throws {
        let cleanupBody = try body(
            ofFunction: "func cleanupTransientKeyboardState",
            file: "Keyboard/Controllers/KeyboardViewController+Bootstrap.swift")
        XCTAssertTrue(
            cleanupBody.contains("forceDismissQuickMenu()"),
            "cleanup path must tear the panel down"
        )
    }

    func testReloadKeyboardForceDismissesTheMenu() throws {
        let reloadBody = try body(
            ofFunction: "func reloadKeyboard()",
            file: "Keyboard/Controllers/KeyboardViewController+Presentation.swift")
        XCTAssertTrue(
            reloadBody.contains("forceDismissQuickMenu()"),
            "direct reload must tear the panel down"
        )
    }

    func testForceDismissIsIdempotentByStateGuard() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        let dismissBody = try body(ofFunction: "func forceDismissQuickMenu", in: source)
        XCTAssertTrue(
            dismissBody.contains("case .idle"),
            "forceDismiss must guard on the presentation state (idle is the only no-op)"
        )
    }

    // MARK: - Composition-change non-manual collapse (dismiss path #4)

    func testCompositionChangeCollapsesTheMenuInsideTheVisibilityHook() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        let hookBody = try body(ofFunction: "func refreshQuickMenuEntryVisibility", in: source)
        XCTAssertTrue(
            hookBody.contains("forceDismissQuickMenu()"),
            "a composition change observed by the hook must collapse the menu"
        )
    }

    // MARK: - VoiceOver invariants (design r1 §3.5, r3 §4.3)

    func testMenuOpenHidesCoveredAccessibilityKeepingPathBar() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        XCTAssertTrue(
            source.contains("hideCoveredAccessibility(in: rootStack, keeping: t9PinyinPathBarView)"),
            "covered rows hide from VoiceOver while the compact T9 path bar stays focusable"
        )
        XCTAssertTrue(
            source.contains("restoreCoveredAccessibility"),
            "every dismiss path must restore the covered accessibility"
        )
    }

    // MARK: - Height invariant (design r1 §3.4: overlay only, zero height contact)

    func testQuickMenuControllerTouchesNoHeightConstraints() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        XCTAssertFalse(
            source.contains("heightAnchor"),
            "the menu is a pure overlay: it must not create or touch any height constraint"
        )
        XCTAssertFalse(
            source.contains("keyboardHeightConstraint"),
            "the rotation-priority height lease must stay untouched"
        )
    }

    // MARK: - Entry button (design r1 §3.1: 44×46pt leading entry + bridge exclusion)

    func testEntryButtonGeometryIsLeading44ByFullBarHeight() throws {
        let source = try sourceFile("Keyboard/Views/CandidateBar/CandidateBarView.swift")
        XCTAssertTrue(source.contains("ukQuickMenuEntryButton"), "the leading entry button exists")
        XCTAssertTrue(
            source.contains("KeyboardDesignTokens.CandidateBar.minimumTouchSize"),
            "entry width is the frozen 44pt minimum touch size"
        )
        let visibilityBody = try body(ofFunction: "func setUkQuickMenuVisible", in: source)
        XCTAssertTrue(
            visibilityBody.contains("candidateLeadingConstraint"),
            "visibility must release the width and move the candidate viewport clip edge"
        )
    }

    func testEntryButtonIsExcludedFromTheGestureBridge() throws {
        let source = try sourceFile("Keyboard/Views/CandidateBar/CandidateBarView.swift")
        let bridgeBody = try body(
            ofFunction: "func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch)",
            in: source)
        XCTAssertTrue(
            bridgeBody.contains("ukQuickMenuEntryButton"),
            "drags/swipes starting on the entry must not be received by bar gestures"
        )
    }

    // MARK: - Gateway wiring (PR1 RimeSessionCommandGateway, zero pipeline changes)

    func testSimplificationRowDispatchesThroughTheGateway() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        XCTAssertTrue(
            source.contains("quickMenuSessionCommandConsumer") && source.contains("setOption(name:"),
            "the T/S row must ride the PR1 gateway"
        )
    }

    func testLayoutSwitchDoesNotReselectSchemaAndRidesTheRealizedPipeline() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        XCTAssertFalse(
            source.contains("reselectSchema"),
            "layout switch is a local preference on the realized-selection chain, never an engine reselect"
        )
        XCTAssertTrue(
            source.contains("KeyboardLayoutSettingsKey.layoutStyle"),
            "layout switch writes the shared layout preference"
        )
        XCTAssertTrue(
            source.contains("refreshCachedSettings"),
            "layout switch rides the existing resolveRegistered → applyRealizedRuntimeSelection → reload pipeline"
        )
    }

    // MARK: - Three-state T/S semantics (r3 §5.1)

    func testSimplificationFailureAnnouncesRollbackWithoutPreferenceWriteBack() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        XCTAssertTrue(source.contains("切换未生效"), "failure must announce the ineffective switch")
        XCTAssertTrue(
            source.contains("recoverSession"),
            "sessionInvalid retries through one recoverSession before reporting failure"
        )
    }

    func testSimplificationPreferenceWritesBackOnlyOnConfirmed() throws {
        let source = try sourceFile("Keyboard/Controllers/KeyboardViewController+QuickMenu.swift")
        let outcomeBody = try body(ofFunction: "func applySimplificationOutcome", in: source)
        XCTAssertTrue(
            outcomeBody.contains("shouldWritePreferenceBack"),
            "preference write-back must be gated on the confirmed branch of the three-state policy"
        )
    }
}
