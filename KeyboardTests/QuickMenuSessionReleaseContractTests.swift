import XCTest

/// PB-016 PR-1 §3.2: release hooks must exist at exactly the lifecycle
/// boundaries the design table names. Keyboard.appex is not linkable from
/// XCTest, so these are source-contract checks over the Extension sources.
final class QuickMenuSessionReleaseContractTests: XCTestCase {
    private func sourceFile(_ relativePath: String) throws -> String {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectRoot = testsDirectory.deletingLastPathComponent()
        return try String(
            contentsOf: projectRoot.appendingPathComponent(relativePath),
            encoding: .utf8
        )
    }

    /// §3.2 #4: visibility/document/reload cleanup releases the in-flight
    /// quick-menu selection.
    func testCleanupTransientKeyboardStateAbandonsInFlightSelection() throws {
        let source = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+Bootstrap.swift"
        )
        let cleanupRange = try rangeOfFunction("func cleanupTransientKeyboardState", in: source)
        let body = String(source[cleanupRange])
        XCTAssertTrue(
            body.contains("quickMenuSessionCommandConsumer?.abandonInFlightSelection()"),
            "cleanup must release the in-flight quick-menu selection (§3.2 #4)"
        )
    }

    /// §3.2 #5: a direct `reloadKeyboard()` releases the in-flight selection.
    func testReloadKeyboardAbandonsInFlightSelection() throws {
        let source = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+Presentation.swift"
        )
        let reloadRange = try rangeOfFunction("func reloadKeyboard()", in: source)
        let body = String(source[reloadRange])
        XCTAssertTrue(
            body.contains("quickMenuSessionCommandConsumer?.abandonInFlightSelection()"),
            "reloadKeyboard must release the in-flight quick-menu selection (§3.2 #5)"
        )
    }

    /// The gateway is installed once at controller bootstrap and is the single
    /// consumer KeyboardCore delivers command results to.
    func testBootstrapInstallsGatewayAsCommandConsumer() throws {
        let source = try sourceFile(
            "Keyboard/Controllers/KeyboardViewController+Bootstrap.swift"
        )
        XCTAssertTrue(source.contains("RimeSessionCommandGateway(controller: controller)"))
        XCTAssertTrue(
            source.contains("controller.quickMenuSessionCommandConsumer = RimeSessionCommandGateway")
        )
    }

    /// Arch r3 Note-2: the gateway must re-query gates/owner readiness on every
    /// dispatch and must never store a mode decision.
    func testGatewayRequeriesModeOnEveryDispatchAndConsumesByContract() throws {
        let source = try sourceFile("Keyboard/Controllers/RimeSessionCommandGateway.swift")
        XCTAssertTrue(
            source.contains("final class RimeSessionCommandGateway: RimeSessionCommandConsuming")
        )
        let dispatchRange = try rangeOfFunction("private func dispatch", in: source)
        let dispatchBody = String(source[dispatchRange])
        XCTAssertTrue(
            dispatchBody.contains("controller.isResponsiveRimePipelineEnabled"),
            "dispatch must re-query the responsive gate per call"
        )
        XCTAssertTrue(
            dispatchBody.contains("controller.isThreadAffineRimeOwnerEnabled"),
            "dispatch must re-query the thread-affine gate per call"
        )
        XCTAssertTrue(
            dispatchBody.contains("owner.isOwnerReady"),
            "dispatch must re-query owner readiness per call"
        )
        XCTAssertFalse(
            source.contains("var cachedMode") || source.contains("cachedDispatchMode"),
            "the gateway must not cache a mode decision"
        )
        // §3.2: release paths clear the gate without a chrome rebuild callback.
        XCTAssertTrue(source.contains("func abandonInFlightSelection()"))
    }

    private func rangeOfFunction(_ signature: String, in source: String) throws -> Range<
        String.Index
    > {
        guard let start = source.range(of: signature) else {
            throw NSError(
                domain: "QuickMenuSessionReleaseContractTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "missing signature: \(signature)"]
            )
        }
        // Contract bodies are small; scanning to the next member declaration is
        // a sufficient boundary for these checks. Substring indices share the
        // parent string's index space, so the match bound is directly usable.
        let bodyStart = start.upperBound
        let nextMember = source[bodyStart...].range(of: "\n    func ")
        let end = nextMember?.lowerBound ?? source.endIndex
        return bodyStart..<end
    }
}
