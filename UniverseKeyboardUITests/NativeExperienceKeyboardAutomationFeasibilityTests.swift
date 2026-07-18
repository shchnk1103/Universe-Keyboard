import CoreFoundation
import XCTest

@MainActor
final class NativeExperienceKeyboardAutomationFeasibilityTests: XCTestCase {
    private let messagesBundleIdentifier = "com.apple.MobileSMS"
    private let springboardBundleIdentifier = "com.apple.springboard"
    private let conversationListIdentifier = "ConversationList"
    private let deterministicConversationLabel = "+1 (888) 555-1212"
    private let composerIdentifier = "messageBodyField"
    private let keyboardEvidenceKeyLabels = ["q", "w", "e"]
    private let knownKeyboardIdentityTerms = [
        "Universe Keyboard",
        "English (US)",
        "English",
        "英语（美国）",
        "英语",
    ]
    private let baselineKeyboardTerms = [
        "English (US)",
        "English",
        "英语（美国）",
        "英语",
    ]

    private let keyboardSwitcherTerms = [
        "Next Keyboard",
        "Globe",
        "下一个键盘",
        "地球",
    ]
    private let appleSystemKeyboardSwitcherTerms = [
        "Next Keyboard",
        "下一个键盘",
    ]
    private let appleSystemKeyboardLayoutIdentifiers = [
        "UIKeyboardLayoutStar Preview",
    ]
    private let universeKeyboardSurfaceTerms = [
        "切换键盘",
        "键盘页面",
        "输入语言",
    ]
    private let requiredUniverseKeyboardSurfaceTerms = [
        "键盘页面",
        "输入语言",
    ]
    private let universeKeyboardSelectionTerms = ["Universe Keyboard"]
    private let coldActivationRunEnvironmentKey = "NE1_COLD_ACTIVATION_RUN"
    private let traceHandshakeEnvironmentKey = "NE1_TRACE_HANDSHAKE"
    private let traceRunTokenEnvironmentKey = "NE1_TRACE_RUN_TOKEN"
    private let tracePreferencesDomainEnvironmentKey = "NE1_TRACE_PREFERENCES_DOMAIN"
    private let t9CrashRegressionRunEnvironmentKey = "T9_CRASH_REGRESSION_RUN"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testMessagesLaunchAvailability() {
        let messages = launchMessages()

        recordProbe(
            purpose: "Only verify that XCUITest can launch Messages and observe the app process.",
            name: "Messages launch availability",
            app: messages,
            failureBoundary: "Messages launch completed.",
            limitationClassification: "No XCTest limitation observed for host-app launch."
        )

        XCTAssertEqual(messages.state, .runningForeground)
    }

    func testMessagesAccessibilitySnapshot() {
        let messages = launchMessages()

        print(messages.debugDescription)
        recordProbe(
            purpose: "Collect the Messages accessibility hierarchy without tapping dynamic controls.",
            name: "Messages accessibility snapshot",
            app: messages,
            failureBoundary: "Snapshot collected without SearchField, text-input, or keyboard interaction.",
            limitationClassification: "No product behavior evaluated; this is host-app accessibility evidence only.",
            extraSections: [
                "app.debugDescription": messages.debugDescription,
            ]
        )

        XCTAssertTrue(messages.exists)
    }

    func testMessagesConversationKeyboardPreparation() {
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)

        recordProbe(
            purpose: "Reproduce the Messages user state used by manual NE1 collection before any keyboard switching attempt.",
            name: "Messages conversation keyboard preparation",
            app: messages,
            failureBoundary: preparation.failureBoundary,
            limitationClassification: preparation.classification,
            includeScreenshot: true,
            extraSections: preparation.metadata
        )

        XCTAssertTrue(messages.exists)
    }

    func testInitialKeyboardStateBeforeSwitching() {
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)
        let baseline = observeInitialKeyboardBaseline(
            in: messages,
            keyboardSurface: preparation.keyboardSurface
        )

        recordProbe(
            purpose: "Prove that the first Messages keyboard surface is an Apple system keyboard before any Universe Keyboard switching action.",
            name: "Initial keyboard state before switching",
            app: messages,
            failureBoundary: baseline.failureBoundary(preparation: preparation),
            limitationClassification: baseline.classification(preparation: preparation),
            includeScreenshot: true,
            extraSections: preparation.metadata.merging(baseline.metadata) { _, new in new }.merging([
                "Isolation guarantee": "This test does not press the keyboard switcher, select a keyboard, type text, or launch Universe Keyboard.",
                "Initial direct keyboard identity": preparation.keyboardSurface.directIdentity
                    ?? "No direct active keyboard identity was exposed through accessibility.",
                "Test-order interpretation": "When invoked with -only-testing, no earlier test method can cause this observed keyboard state.",
                "Runner and simulator-state interpretation": "The scheme pre-action prepares persistent input mode before the test session. This XCTest check fails closed if runner installation or cached simulator state still presents Universe Keyboard first.",
            ]) { _, new in new }
        )

        XCTAssertTrue(
            baseline.isKnownNonUniverseBaseline,
            "Cold-start precondition failed: the first keyboard surface was not proven to be a non-Universe Apple keyboard."
        )
    }

    func testKeyboardSwitcherDiscovery() {
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)

        guard preparation.keyboardSurface.isVisible else {
            recordProbe(
                purpose: "Investigate whether a system keyboard reached through the Messages composer exposes an accessible switcher.",
                name: "Keyboard switcher discovery",
                app: messages,
                failureBoundary: preparation.failureBoundary,
                limitationClassification: preparation.classification,
                includeScreenshot: true,
                extraSections: preparation.metadata
            )
            return
        }

        let matches = keyboardSwitcherCandidates(in: messages)
        guard !matches.isEmpty else {
            recordProbe(
                purpose: "Investigate whether a system keyboard reached through the Messages composer exposes an accessible switcher.",
                name: "Keyboard switcher discovery",
                app: messages,
                failureBoundary: "Keyboard surface was visible, but no explicit switcher/globe candidate was exposed.",
                limitationClassification: "XCTest or iOS accessibility exposure boundary; not Universe Keyboard product behavior.",
                includeScreenshot: true,
                extraSections: [
                    "Preparation metadata": preparation.metadataReport,
                    "Keyboard surface metadata": preparation.keyboardSurface.metadataReport,
                ]
            )
            return
        }

        recordProbe(
            purpose: "Investigate whether a system keyboard reached through the Messages composer exposes an accessible switcher.",
            name: "Keyboard switcher discovery",
            app: messages,
            failureBoundary: "Explicit switcher candidate(s) discovered without generic Keyboard-label matching.",
            limitationClassification: "Switcher availability observed; keyboard selection remains a separate capability.",
            includeScreenshot: true,
            extraSections: [
                "Preparation metadata": preparation.metadataReport,
                "Matched switcher candidates": elementList(matches),
                "Keyboard surface metadata": preparation.keyboardSurface.metadataReport,
            ]
        )

        XCTAssertTrue(matches.contains { $0.exists })
    }

    func testKeyboardStateNormalizationFeasibility() {
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)
        let normalization = attemptBaselineKeyboardNormalization(
            in: messages,
            initialSurface: preparation.keyboardSurface
        )

        recordProbe(
            purpose: "Determine whether XCTest can establish a known keyboard baseline before future NE1 measurement scenarios.",
            name: "Keyboard state normalization feasibility",
            app: messages,
            failureBoundary: normalization.failureBoundary,
            limitationClassification: normalization.classification,
            includeScreenshot: true,
            extraSections: preparation.metadata.merging(normalization.metadata) { _, new in new }
        )

        XCTAssertTrue(messages.exists)
    }

    func testUniverseKeyboardActivationFeasibility() {
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)

        recordProbe(
            purpose: "Preserve the activation feasibility boundary while Iteration 4 validates keyboard surface detection and baseline normalization.",
            name: "Universe Keyboard activation feasibility",
            app: messages,
            failureBoundary: preparation.keyboardVisible
                ? "Keyboard surface reached. Universe Keyboard selection is intentionally not used as identity proof in Iteration 4."
                : preparation.failureBoundary,
            limitationClassification: preparation.keyboardVisible
                ? "Keyboard surface capability observed; no Universe Keyboard product behavior or activation proof was evaluated."
                : preparation.classification,
            includeScreenshot: true,
            extraSections: preparation.metadata.merging([
                "System keyboard switcher availability": "Not evaluated in this test.",
                "Universe Keyboard selection success": "Not attempted by Iteration 4 scope.",
                "Universe Keyboard active proof": "No direct accessibility identity was observed.",
            ]) { _, new in new }
        )

        XCTAssertTrue(messages.exists)
    }

    /// Explicit device/simulator fixture gate for the nine-key first-input crash path.
    /// Normal CI skips this because it does not install a deployed T9 runtime or readiness marker.
    func testNineKeyFirstInputCrashRegression() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment[t9CrashRegressionRunEnvironmentKey] == "1",
            "Run only after installing the reviewed T9 runtime fixture and matched readiness marker."
        )

        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)
        let baseline = observeInitialKeyboardBaseline(
            in: messages,
            keyboardSurface: preparation.keyboardSurface
        )
        XCTAssertTrue(
            baseline.isKnownNonUniverseBaseline,
            "Nine-key crash regression requires a known Apple-keyboard baseline."
        )

        guard let switcher = keyboardSwitcherCandidates(in: messages).first(where: \.isHittable) else {
            return XCTFail("No hittable system keyboard switcher was exposed.")
        }
        switcher.press(forDuration: 1.0)

        guard let selection = waitForUniverseKeyboardSelection(in: messages, timeout: 5)
            .first(where: \.isHittable)
        else {
            return XCTFail("Universe Keyboard was not exposed in the system keyboard menu.")
        }
        selection.tap()

        // T9 keys keep the digit as stable UI identity while VoiceOver receives a semantic label.
        let mnoKey = messages.keys["6"].firstMatch
        XCTAssertTrue(mnoKey.waitForExistence(timeout: 15), "The MNO / digit-6 key did not appear.")
        XCTAssertTrue(mnoKey.isHittable, "The MNO / digit-6 key was not hittable.")
        XCTAssertTrue(mnoKey.label.contains("MNO"), "Digit-6 did not expose the expected MNO key label.")

        mnoKey.tap()

        let liveMNOKey = messages.keys["6"].firstMatch
        XCTAssertTrue(
            liveMNOKey.waitForExistence(timeout: 5),
            "Keyboard Extension disappeared after the first nine-key input."
        )
        XCTAssertEqual(messages.state, .runningForeground)

        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "Nine-key first input survived"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testTextInputAfterKeyboardActivation() {
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)
        recordProbe(
            purpose: "Report the text-input precondition without selecting Universe Keyboard during the preparation-only iteration.",
            name: "Text input after keyboard activation",
            app: messages,
            failureBoundary: "Precondition failed: Universe Keyboard active state was not proven after Iteration 4 baseline normalization.",
            limitationClassification: preparation.keyboardVisible
                ? "System keyboard preparation observed; no typing or Universe Keyboard product behavior evaluated."
                : preparation.classification,
            includeScreenshot: true,
            extraSections: preparation.metadata.merging([
                "Activation boundary": preparation.failureBoundary,
                "Universe Keyboard active proof": "No direct accessibility identity was observed.",
            ]) { _, new in new }
        )

        XCTAssertTrue(messages.exists)
    }

    func testNE1ColdActivationAndFirstInput() throws {
        let environment = ProcessInfo.processInfo.environment
        try XCTSkipUnless(
            environment[coldActivationRunEnvironmentKey] == "1",
            "Run this cold-activation scenario in an isolated invocation through the NE1 trace runner."
        )

        let handshakeEnabled = environment[traceHandshakeEnvironmentKey] == "1"
        let traceGates = try makeTraceGates(environment: environment, enabled: handshakeEnabled)
        let messages = launchMessages()
        let preparation = prepareMessagesConversationForKeyboard(in: messages)
        let baseline = observeInitialKeyboardBaseline(
            in: messages,
            keyboardSurface: preparation.keyboardSurface
        )

        guard baseline.isKnownNonUniverseBaseline else {
            recordProbe(
                purpose: "Execute the isolated NE1 Messages cold-activation and first-input flow.",
                name: "NE1 cold activation and first input",
                app: messages,
                failureBoundary: baseline.failureBoundary(preparation: preparation),
                limitationClassification: baseline.classification(preparation: preparation),
                includeScreenshot: true,
                extraSections: preparation.metadata.merging(baseline.metadata) { _, new in new }
            )
            XCTFail("Cold-start precondition failed before trace synchronization or keyboard switching.")
            return
        }

        if let traceGates {
            traceGates.signalUIReady()
            guard traceGates.started.wait(timeout: 60) else {
                recordProbe(
                    purpose: "Execute the isolated NE1 Messages cold-activation and first-input flow.",
                    name: "NE1 cold activation and first input",
                    app: messages,
                    failureBoundary: "Trace handshake failed: XCTest reached the Apple keyboard baseline, but Terminal did not signal that xctrace recording started.",
                    limitationClassification: "Measurement-runner tooling boundary; Universe Keyboard was not activated.",
                    includeScreenshot: true,
                    extraSections: preparation.metadata.merging(baseline.metadata) { _, new in new }
                )
                XCTFail("xctrace did not signal recording start before the bounded timeout.")
                return
            }
        }

        let activationStartedAt = Date()
        let activation = activateUniverseKeyboard(in: messages)
        guard activation.activated else {
            recordProbe(
                purpose: "Execute the isolated NE1 Messages cold-activation and first-input flow.",
                name: "NE1 cold activation and first input",
                app: messages,
                failureBoundary: activation.failureBoundary,
                limitationClassification: activation.classification,
                includeScreenshot: true,
                extraSections: preparation.metadata
                    .merging(baseline.metadata) { _, new in new }
                    .merging(activation.metadata) { _, new in new }
            )
            XCTFail("Universe Keyboard activation was not proven.")
            return
        }

        let inputStartedAt = Date()
        let input = enterFirstNE1Key(in: messages)
        let responseObservedAt = Date()

        var traceFinished = true
        if let traceGates {
            traceFinished = traceGates.finished.wait(timeout: 120)
        }

        let timestamps = [
            "Activation action started": iso8601(activationStartedAt),
            "First key action started": iso8601(inputStartedAt),
            "Candidate response observation completed": iso8601(responseObservedAt),
            "Trace completion handshake": traceFinished ? "completed" : "timed out",
        ]
        let metadata = preparation.metadata
            .merging(baseline.metadata) { _, new in new }
            .merging(activation.metadata) { _, new in new }
            .merging(input.metadata) { _, new in new }
            .merging(timestamps) { _, new in new }

        recordProbe(
            purpose: "Execute the isolated NE1 Messages cold-activation and first-input flow.",
            name: "NE1 cold activation and first input",
            app: messages,
            failureBoundary: input.candidateResponseObserved
                ? "Universe Keyboard activation was proven, the real n key was tapped, and candidate response was observed."
                : input.failureBoundary,
            limitationClassification: input.candidateResponseObserved && traceFinished
                ? "UI automation flow completed. Trace validity and performance conclusions remain separate evidence-review steps."
                : "Tooling or product-response boundary recorded; no performance conclusion is allowed.",
            includeScreenshot: true,
            extraSections: metadata
        )

        XCTAssertTrue(input.realKeyTapped, "The Universe Keyboard n key was not tapped.")
        XCTAssertTrue(input.candidateResponseObserved, "Candidate response was not observed after the real n key tap.")
        XCTAssertTrue(traceFinished, "xctrace did not signal recording completion before the bounded timeout.")
    }

    private func launchMessages() -> XCUIApplication {
        let messages = XCUIApplication(bundleIdentifier: messagesBundleIdentifier)
        messages.launch()
        XCTAssertTrue(
            messages.wait(for: .runningForeground, timeout: 10),
            "XCUITest could not launch Messages into the foreground."
        )
        return messages
    }

    private func prepareMessagesConversationForKeyboard(in messages: XCUIApplication) -> MessageKeyboardPreparationProbeResult {
        let existingComposer = messages.textFields[composerIdentifier]
        if existingComposer.waitForExistence(timeout: 1) {
            let backButton = messages.buttons["BackButton"]
            guard backButton.waitForExistence(timeout: 3), backButton.isHittable else {
                return MessageKeyboardPreparationProbeResult(
                    conversationNavigated: false,
                    composerFound: true,
                    composerTapped: false,
                    keyboardSurface: .absent,
                    composerCandidateSummaries: elementSummaries([existingComposer]),
                    failureBoundary: "A: Messages restored a conversation, but the stable BackButton was not available to return to ConversationList.",
                    classification: "Messages environment/accessibility boundary; not Universe Keyboard product behavior."
                )
            }
            backButton.tap()
        }

        let conversation = messages.collectionViews[conversationListIdentifier]
            .cells
            .matching(NSPredicate(format: "label BEGINSWITH %@", deterministicConversationLabel))
            .firstMatch

        guard conversation.waitForExistence(timeout: 5), waitUntilHittable(conversation, timeout: 3) else {
            return MessageKeyboardPreparationProbeResult(
                conversationNavigated: false,
                composerFound: false,
                composerTapped: false,
                keyboardSurface: .absent,
                composerCandidateSummaries: [],
                failureBoundary: "A: Conversation navigation failed because the deterministic conversation was not exposed in ConversationList.",
                classification: "Messages environment/setup boundary; not Universe Keyboard product behavior."
            )
        }

        conversation.tap()
        let composer = messages.textFields[composerIdentifier]
        guard composer.waitForExistence(timeout: 5) else {
            return MessageKeyboardPreparationProbeResult(
                conversationNavigated: true,
                composerFound: false,
                composerTapped: false,
                keyboardSurface: .absent,
                composerCandidateSummaries: [],
                failureBoundary: "B: Conversation navigation completed, but Messages did not expose the composer with identifier messageBodyField.",
                classification: "XCTest or Messages accessibility boundary; not Universe Keyboard product behavior."
            )
        }

        let composerCandidateSummaries = elementSummaries([composer])

        composer.tap()
        _ = keyboardEvidenceKey(named: keyboardEvidenceKeyLabels[0], in: messages)
            .waitForExistence(timeout: 5)
        let keyboardSurface = observeKeyboardSurface(in: messages)
        guard keyboardSurface.isVisible else {
            return MessageKeyboardPreparationProbeResult(
                conversationNavigated: true,
                composerFound: true,
                composerTapped: true,
                keyboardSurface: keyboardSurface,
                composerCandidateSummaries: composerCandidateSummaries,
                failureBoundary: "C: Composer was tapped, but no keyboard surface was evidenced by the required q/w/e key descendants.",
                classification: "XCTest/system UI boundary; not Universe Keyboard product behavior."
            )
        }

        return MessageKeyboardPreparationProbeResult(
            conversationNavigated: true,
            composerFound: true,
            composerTapped: true,
            keyboardSurface: keyboardSurface,
            composerCandidateSummaries: composerCandidateSummaries,
            failureBoundary: "Keyboard surface boundary reached through q/w/e accessibility descendants after composer activation.",
            classification: keyboardSurface.isInteractable
                ? "Keyboard surface is visible and interactable through accessibility descendants; identity remains independently unproven."
                : "Keyboard surface is visible, but its key descendants are not all hittable; identity remains independently unproven."
        )
    }

    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "hittable == true"),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    private func keyboardSwitcherCandidates(in app: XCUIApplication) -> [XCUIElement] {
        matchingElements(
            in: app,
            terms: keyboardSwitcherTerms,
            types: [.button, .key],
            allowContainsMatch: true
        )
    }

    private func activateUniverseKeyboard(in messages: XCUIApplication) -> UniverseKeyboardActivationProbeResult {
        let switcherCandidates = keyboardSwitcherCandidates(in: messages)
        let switcherSummaries = elementSummaries(switcherCandidates)
        guard let switcher = switcherCandidates.first(where: \.isHittable) else {
            return UniverseKeyboardActivationProbeResult(
                switcherSummaries: switcherSummaries,
                selectionSummaries: [],
                surfaceSummaries: [],
                activated: false,
                failureBoundary: "Keyboard surface was visible, but no hittable Apple system keyboard switcher was exposed.",
                classification: "XCTest/iOS system UI boundary; Universe Keyboard product behavior was not reached."
            )
        }

        switcher.press(forDuration: 1.0)
        let selectionCandidates = waitForUniverseKeyboardSelection(in: messages, timeout: 5)
        let selectionSummaries = elementSummaries(selectionCandidates)
        guard let selection = selectionCandidates.first(where: \.isHittable) else {
            return UniverseKeyboardActivationProbeResult(
                switcherSummaries: switcherSummaries,
                selectionSummaries: selectionSummaries,
                surfaceSummaries: [],
                activated: false,
                failureBoundary: "The system keyboard switcher opened, but no hittable exact Universe Keyboard selection was exposed.",
                classification: "XCTest/iOS system keyboard selection-menu boundary; no product failure inferred."
            )
        }

        selection.tap()
        let surfaceCandidates = waitForUniverseKeyboardSurface(in: messages, timeout: 10)
        let activated = requiredUniverseKeyboardSurfaceTerms.allSatisfy { term in
            surfaceCandidates.contains { element in
                element.label.caseInsensitiveCompare(term) == .orderedSame
                    || element.identifier.caseInsensitiveCompare(term) == .orderedSame
            }
        }

        return UniverseKeyboardActivationProbeResult(
            switcherSummaries: switcherSummaries,
            selectionSummaries: selectionSummaries,
            surfaceSummaries: elementSummaries(surfaceCandidates),
            activated: activated,
            failureBoundary: activated
                ? "Universe Keyboard-specific accessibility controls appeared after system-menu selection."
                : "Universe Keyboard was selected from system UI, but its required accessibility controls did not appear.",
            classification: activated
                ? "Universe Keyboard activation proven through exact product-owned accessibility controls."
                : "Activation result remained unproven; classify as XCTest/system UI or Extension presentation boundary pending evidence review."
        )
    }

    private func waitForUniverseKeyboardSelection(
        in messages: XCUIApplication,
        timeout: TimeInterval
    ) -> [XCUIElement] {
        let springboard = XCUIApplication(bundleIdentifier: springboardBundleIdentifier)
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            let types: [XCUIElement.ElementType] = [.menuItem, .button, .staticText]
            let candidates = matchingElements(
                in: messages,
                terms: universeKeyboardSelectionTerms,
                types: types,
                allowContainsMatch: false
            ) + matchingElements(
                in: springboard,
                terms: universeKeyboardSelectionTerms,
                types: types,
                allowContainsMatch: false
            )
            if candidates.isEmpty == false {
                return candidates
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        return []
    }

    private func waitForUniverseKeyboardSurface(
        in messages: XCUIApplication,
        timeout: TimeInterval
    ) -> [XCUIElement] {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            let candidates = matchingElements(
                in: messages,
                terms: universeKeyboardSurfaceTerms,
                types: [.button, .key],
                allowContainsMatch: false
            )
            let observedTerms = Set(candidates.flatMap { [$0.label, $0.identifier] })
            if requiredUniverseKeyboardSurfaceTerms.allSatisfy({ observedTerms.contains($0) }) {
                return candidates
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        return matchingElements(
            in: messages,
            terms: universeKeyboardSurfaceTerms,
            types: [.button, .key],
            allowContainsMatch: false
        )
    }

    private func enterFirstNE1Key(in messages: XCUIApplication) -> NE1FirstInputProbeResult {
        let key = keyboardEvidenceKey(named: "n", in: messages)
        guard key.waitForExistence(timeout: 5), key.isHittable else {
            return NE1FirstInputProbeResult(
                keySummary: key.exists ? elementSummary(key) : "No exact n key match.",
                candidateSummary: "No candidate response query was attempted.",
                realKeyTapped: false,
                candidateResponseObserved: false,
                failureBoundary: "Universe Keyboard was active, but its exact n key was not hittable."
            )
        }

        let keySummary = elementSummary(key)
        let candidateCellCountBeforeTap = messages.cells.count
        key.tap()
        let deadline = Date().addingTimeInterval(10)
        var candidateCellCountAfterTap = messages.cells.count
        while candidateCellCountAfterTap <= candidateCellCountBeforeTap, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            candidateCellCountAfterTap = messages.cells.count
        }
        let responseObserved = candidateCellCountAfterTap > candidateCellCountBeforeTap

        return NE1FirstInputProbeResult(
            keySummary: keySummary,
            candidateSummary: "Candidate Cell count before tap=\(candidateCellCountBeforeTap), after tap=\(candidateCellCountAfterTap).",
            realKeyTapped: true,
            candidateResponseObserved: responseObserved,
            failureBoundary: responseObserved
                ? "Real n key tap completed and the candidate Cell count increased."
                : "Real n key tap completed, but the candidate Cell count did not increase."
        )
    }

    private func makeTraceGates(
        environment: [String: String],
        enabled: Bool
    ) throws -> TraceNotificationGates? {
        guard enabled else { return nil }

        guard let runToken = environment[traceRunTokenEnvironmentKey],
              let preferencesDomain = environment[tracePreferencesDomainEnvironmentKey]
        else {
            XCTFail("Trace handshake was enabled without a run token and preferences domain.")
            throw TraceHandshakeConfigurationError.invalidEnvironment
        }

        return TraceNotificationGates(
            runToken: runToken,
            started: TracePreferenceGate(
                domain: preferencesDomain,
                key: "TraceStartedToken",
                expectedValue: runToken
            ),
            finished: TracePreferenceGate(
                domain: preferencesDomain,
                key: "TraceFinishedToken",
                expectedValue: runToken
            )
        )
    }

    private func iso8601(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private func observeInitialKeyboardBaseline(
        in app: XCUIApplication,
        keyboardSurface: KeyboardSurfaceObservation
    ) -> InitialKeyboardBaselineObservation {
        guard keyboardSurface.isVisible else {
            return InitialKeyboardBaselineObservation(
                keyboardSurfaceVisible: false,
                appleSystemSwitcherSummaries: [],
                appleSystemLayoutSummaries: [],
                universeSurfaceSummaries: []
            )
        }

        let appleSystemSwitcherCandidates = matchingElements(
            in: app,
            terms: appleSystemKeyboardSwitcherTerms,
            types: [.button, .key],
            allowContainsMatch: false
        )
        let universeSurfaceCandidates = matchingElements(
            in: app,
            terms: universeKeyboardSurfaceTerms,
            types: [.button, .key],
            allowContainsMatch: false
        )
        let appleSystemLayoutCandidates = matchingElements(
            in: app,
            terms: appleSystemKeyboardLayoutIdentifiers,
            types: [.other],
            allowContainsMatch: false
        )

        return InitialKeyboardBaselineObservation(
            keyboardSurfaceVisible: true,
            appleSystemSwitcherSummaries: elementSummaries(appleSystemSwitcherCandidates),
            appleSystemLayoutSummaries: elementSummaries(appleSystemLayoutCandidates),
            universeSurfaceSummaries: elementSummaries(universeSurfaceCandidates)
        )
    }

    private func observeKeyboardSurface(in app: XCUIApplication) -> KeyboardSurfaceObservation {
        // iOS 26.5 can expose keyboard keys while XCUIElementTypeKeyboard is absent.
        let evidenceKeys = keyboardEvidenceKeyLabels.compactMap { label -> XCUIElement? in
            let key = keyboardEvidenceKey(named: label, in: app)
            return key.exists ? key : nil
        }
        let keySummaries = elementSummaries(evidenceKeys)
        let interactableKeySummaries = elementSummaries(evidenceKeys.filter(\.isHittable))

        guard evidenceKeys.count == keyboardEvidenceKeyLabels.count else {
            return KeyboardSurfaceObservation(
                state: .absent,
                evidenceKeySummaries: keySummaries,
                interactableKeySummaries: interactableKeySummaries,
                identityEvidenceSummaries: []
            )
        }

        let identityCandidates = matchingElements(
            in: app,
            terms: knownKeyboardIdentityTerms,
            types: [.button, .staticText, .other],
            allowContainsMatch: false
        )
        let identityEvidenceSummaries = elementSummaries(identityCandidates)
        if let identity = identityCandidates.first(where: { $0.label.isEmpty == false })?.label {
            return KeyboardSurfaceObservation(
                state: .visibleWithKnownIdentity(identity),
                evidenceKeySummaries: keySummaries,
                interactableKeySummaries: interactableKeySummaries,
                identityEvidenceSummaries: identityEvidenceSummaries
            )
        }

        return KeyboardSurfaceObservation(
            state: .visibleUnknownIdentity,
            evidenceKeySummaries: keySummaries,
            interactableKeySummaries: interactableKeySummaries,
            identityEvidenceSummaries: identityEvidenceSummaries
        )
    }

    private func keyboardEvidenceKey(named label: String, in app: XCUIApplication) -> XCUIElement {
        app.keys
            .matching(NSPredicate(
                format: "label ==[c] %@ OR identifier ==[c] %@",
                label,
                label
            ))
            .firstMatch
    }

    private func attemptBaselineKeyboardNormalization(
        in messages: XCUIApplication,
        initialSurface: KeyboardSurfaceObservation
    ) -> KeyboardNormalizationResult {
        guard initialSurface.isVisible else {
            return KeyboardNormalizationResult(
                initialSurface: initialSurface,
                switcherCandidateSummaries: [],
                baselineCandidateSummaries: [],
                finalSurface: initialSurface,
                baselineEstablished: false,
                failureBoundary: "Keyboard surface is absent, so keyboard state cannot be normalized.",
                classification: "XCTest/system UI precondition boundary; no Universe Keyboard product behavior evaluated."
            )
        }

        if case let .visibleWithKnownIdentity(identity) = initialSurface.state,
           baselineKeyboardTerms.contains(identity) {
            return KeyboardNormalizationResult(
                initialSurface: initialSurface,
                switcherCandidateSummaries: [],
                baselineCandidateSummaries: [],
                finalSurface: initialSurface,
                baselineEstablished: true,
                failureBoundary: "Known baseline keyboard identity was directly observed before normalization was needed.",
                classification: "Known baseline established through direct accessibility identity evidence."
            )
        }

        let switcherCandidates = keyboardSwitcherCandidates(in: messages)
        let switcherCandidateSummaries = elementSummaries(switcherCandidates)
        guard let switcher = switcherCandidates.first else {
            return KeyboardNormalizationResult(
                initialSurface: initialSurface,
                switcherCandidateSummaries: switcherCandidateSummaries,
                baselineCandidateSummaries: [],
                finalSurface: initialSurface,
                baselineEstablished: false,
                failureBoundary: "Keyboard surface is visible, but no explicit system keyboard switcher was exposed through accessibility.",
                classification: "XCTest/iOS system UI limitation; deterministic baseline cannot be established."
            )
        }

        switcher.press(forDuration: 1.0)
        let baselineCandidates = baselineKeyboardCandidates(in: messages)
        let baselineCandidateSummaries = elementSummaries(baselineCandidates)
        guard let baseline = baselineCandidates.first else {
            return KeyboardNormalizationResult(
                initialSurface: initialSurface,
                switcherCandidateSummaries: switcherCandidateSummaries,
                baselineCandidateSummaries: baselineCandidateSummaries,
                finalSurface: observeKeyboardSurface(in: messages),
                baselineEstablished: false,
                failureBoundary: "Keyboard switcher was invoked, but no known baseline keyboard item was exposed through accessibility.",
                classification: "XCTest/iOS system UI limitation; selection menu cannot be normalized deterministically."
            )
        }

        let selectedBaselineIdentity = baseline.label
        baseline.tap()
        _ = keyboardEvidenceKey(named: keyboardEvidenceKeyLabels[0], in: messages)
            .waitForExistence(timeout: 5)
        let finalSurface = observeKeyboardSurface(in: messages)
        let baselineEstablished: Bool
        if case let .visibleWithKnownIdentity(identity) = finalSurface.state {
            baselineEstablished = identity == selectedBaselineIdentity
        } else {
            baselineEstablished = false
        }

        return KeyboardNormalizationResult(
            initialSurface: initialSurface,
            switcherCandidateSummaries: switcherCandidateSummaries,
            baselineCandidateSummaries: baselineCandidateSummaries,
            finalSurface: finalSurface,
            baselineEstablished: baselineEstablished,
            failureBoundary: baselineEstablished
                ? "Known baseline keyboard selection completed and post-selection identity was directly observed."
                : "A baseline selection action was attempted, but the post-selection keyboard identity was not directly observable.",
            classification: baselineEstablished
                ? "Deterministic keyboard state preparation is feasible in this run."
                : "Selection action alone is insufficient; deterministic baseline remains unproven and future NE1 measurement must stay blocked."
        )
    }

    private func baselineKeyboardCandidates(in app: XCUIApplication) -> [XCUIElement] {
        let springboard = XCUIApplication(bundleIdentifier: springboardBundleIdentifier)
        let types: [XCUIElement.ElementType] = [.menuItem, .button, .staticText]
        return matchingElements(in: app, terms: baselineKeyboardTerms, types: types, allowContainsMatch: false)
            + matchingElements(in: springboard, terms: baselineKeyboardTerms, types: types, allowContainsMatch: false)
    }

    private func matchingElements(
        in root: XCUIElement,
        terms: [String],
        types: [XCUIElement.ElementType],
        allowContainsMatch: Bool
    ) -> [XCUIElement] {
        var matches: [XCUIElement] = []

        for type in types {
            for term in terms {
                let predicate: NSPredicate
                if allowContainsMatch {
                    predicate = NSPredicate(
                        format: "label CONTAINS[c] %@ OR identifier CONTAINS[c] %@",
                        term,
                        term
                    )
                } else {
                    predicate = NSPredicate(
                        format: "label ==[c] %@ OR identifier ==[c] %@",
                        term,
                        term
                    )
                }
                let element = root.descendants(matching: type).matching(predicate).firstMatch
                if element.exists, !matches.contains(where: { sameElement($0, element) }) {
                    matches.append(element)
                }
            }
        }

        return matches
    }

    private func sameElement(_ lhs: XCUIElement, _ rhs: XCUIElement) -> Bool {
        lhs.elementType == rhs.elementType
            && lhs.label == rhs.label
            && lhs.identifier == rhs.identifier
            && String(describing: lhs.value ?? "") == String(describing: rhs.value ?? "")
    }

    private func recordProbe(
        purpose: String,
        name: String,
        app: XCUIApplication,
        failureBoundary: String,
        limitationClassification: String,
        includeScreenshot: Bool = false,
        extraSections: [String: String] = [:]
    ) {
        var report = """
        Probe: \(name)
        Test purpose: \(purpose)
        Current application: \(messagesBundleIdentifier)
        App state: \(app.state.rawValue)
        Failure boundary: \(failureBoundary)
        Limitation classification: \(limitationClassification)

        Accessibility snapshot:
        \(accessibilitySnapshot(for: app))
        """

        for key in extraSections.keys.sorted() {
            report += "\n\n\(key):\n\(extraSections[key] ?? "")"
        }

        let attachment = XCTAttachment(string: report)
        attachment.name = "NE1 UI Automation - \(name)"
        attachment.lifetime = .keepAlways

        XCTContext.runActivity(named: "NE1 UI Automation - \(name)") { activity in
            activity.add(attachment)
            if includeScreenshot {
                let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
                screenshot.name = "NE1 UI Automation - \(name) screenshot"
                screenshot.lifetime = .keepAlways
                activity.add(screenshot)
            }
        }
    }

    private func accessibilitySnapshot(for element: XCUIElement) -> String {
        truncated(element.debugDescription, limit: 12_000)
    }

    private func elementList(_ elements: [XCUIElement]) -> String {
        summaryList(elementSummaries(elements))
    }

    private func elementSummaries(_ elements: [XCUIElement]) -> [String] {
        elements.map(elementSummary)
    }

    private func summaryList(_ summaries: [String]) -> String {
        guard !summaries.isEmpty else {
            return "No matches."
        }
        return summaries.joined(separator: "\n")
    }

    private func elementSummary(_ element: XCUIElement) -> String {
        let value = element.value.map { String(describing: $0) } ?? ""
        return "type=\(element.elementType) label='\(element.label)' identifier='\(element.identifier)' value='\(value)' hittable=\(element.isHittable)"
    }

    private func truncated(_ value: String, limit: Int) -> String {
        guard value.count > limit else {
            return value
        }

        let endIndex = value.index(value.startIndex, offsetBy: limit)
        return "\(value[..<endIndex])\n... <truncated>"
    }
}

private struct InitialKeyboardBaselineObservation {
    let keyboardSurfaceVisible: Bool
    let appleSystemSwitcherSummaries: [String]
    let appleSystemLayoutSummaries: [String]
    let universeSurfaceSummaries: [String]

    var isKnownNonUniverseBaseline: Bool {
        keyboardSurfaceVisible
            && (appleSystemSwitcherSummaries.isEmpty == false || appleSystemLayoutSummaries.isEmpty == false)
            && universeSurfaceSummaries.isEmpty
    }

    var metadata: [String: String] {
        [
            "Apple system keyboard switcher evidence": summaryList(appleSystemSwitcherSummaries),
            "Apple system keyboard layout evidence": summaryList(appleSystemLayoutSummaries),
            "Universe Keyboard surface evidence": summaryList(universeSurfaceSummaries),
            "Known non-Universe baseline": isKnownNonUniverseBaseline ? "yes" : "no",
        ]
    }

    func failureBoundary(preparation: MessageKeyboardPreparationProbeResult) -> String {
        guard keyboardSurfaceVisible else {
            return preparation.failureBoundary
        }
        guard universeSurfaceSummaries.isEmpty else {
            return "E: Universe Keyboard-specific accessibility controls were visible on the first keyboard presentation. Cold-start baseline preparation failed."
        }
        guard appleSystemSwitcherSummaries.isEmpty == false || appleSystemLayoutSummaries.isEmpty == false else {
            return "D: Keyboard surface was visible, but XCTest could not prove an Apple system keyboard baseline from exact layout or switcher accessibility evidence."
        }
        return "Known non-Universe Apple keyboard baseline was visible before any keyboard switching action."
    }

    func classification(preparation: MessageKeyboardPreparationProbeResult) -> String {
        guard keyboardSurfaceVisible else {
            return preparation.classification
        }
        return isKnownNonUniverseBaseline
            ? "Cold-start environment precondition proven; Universe Keyboard has not been activated by this test."
            : "Environment/tooling precondition failure; no Universe Keyboard product behavior or performance conclusion is allowed."
    }

    private func summaryList(_ summaries: [String]) -> String {
        summaries.isEmpty ? "No matches." : summaries.joined(separator: "\n")
    }
}

private struct UniverseKeyboardActivationProbeResult {
    let switcherSummaries: [String]
    let selectionSummaries: [String]
    let surfaceSummaries: [String]
    let activated: Bool
    let failureBoundary: String
    let classification: String

    var metadata: [String: String] {
        [
            "System keyboard switcher evidence": summaryList(switcherSummaries),
            "Universe Keyboard selection evidence": summaryList(selectionSummaries),
            "Universe Keyboard surface evidence after selection": summaryList(surfaceSummaries),
            "Universe Keyboard activation proven": activated ? "yes" : "no",
        ]
    }

    private func summaryList(_ summaries: [String]) -> String {
        summaries.isEmpty ? "No matches." : summaries.joined(separator: "\n")
    }
}

private struct NE1FirstInputProbeResult {
    let keySummary: String
    let candidateSummary: String
    let realKeyTapped: Bool
    let candidateResponseObserved: Bool
    let failureBoundary: String

    var metadata: [String: String] {
        [
            "Real Universe Keyboard n key": keySummary,
            "Candidate response evidence": candidateSummary,
            "Real key tapped": realKeyTapped ? "yes" : "no",
            "Candidate response observed": candidateResponseObserved ? "yes" : "no",
        ]
    }
}

private struct TraceNotificationGates {
    let runToken: String
    let started: TracePreferenceGate
    let finished: TracePreferenceGate

    func signalUIReady() {
        let marker = "NE1_TRACE_UI_READY:\(runToken)\n"
        FileHandle.standardOutput.write(Data(marker.utf8))
    }
}

private enum TraceHandshakeConfigurationError: Error {
    case invalidEnvironment
}

private struct TracePreferenceGate {
    let domain: String
    let key: String
    let expectedValue: String

    func wait(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            CFPreferencesAppSynchronize(domain as CFString)
            let value = CFPreferencesCopyAppValue(key as CFString, domain as CFString) as? String
            if value == expectedValue {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        return false
    }
}

private struct MessageKeyboardPreparationProbeResult {
    let conversationNavigated: Bool
    let composerFound: Bool
    let composerTapped: Bool
    let keyboardSurface: KeyboardSurfaceObservation
    let composerCandidateSummaries: [String]
    let failureBoundary: String
    let classification: String

    var keyboardVisible: Bool {
        keyboardSurface.isVisible
    }

    var metadata: [String: String] {
        [
            "Conversation navigation": conversationNavigated ? "completed" : "not completed",
            "Composer discovery": composerFound ? "explicit messageBodyField composer found" : "not found",
            "Composer activation": composerTapped ? "tapped" : "not attempted",
            "Composer candidates": summaryList(composerCandidateSummaries),
            "Keyboard surface": keyboardSurface.description,
            "Keyboard surface metadata": keyboardSurface.metadataReport,
        ]
    }

    var metadataReport: String {
        metadata.keys.sorted().map { key in
            "\(key): \(metadata[key] ?? "")"
        }.joined(separator: "\n")
    }

    private func summaryList(_ summaries: [String]) -> String {
        summaries.isEmpty ? "No matches." : summaries.joined(separator: "\n")
    }
}

private enum KeyboardSurfaceState {
    case absent
    case visibleUnknownIdentity
    case visibleWithKnownIdentity(String)
}

private struct KeyboardSurfaceObservation {
    let state: KeyboardSurfaceState
    let evidenceKeySummaries: [String]
    let interactableKeySummaries: [String]
    let identityEvidenceSummaries: [String]

    static let absent = KeyboardSurfaceObservation(
        state: .absent,
        evidenceKeySummaries: [],
        interactableKeySummaries: [],
        identityEvidenceSummaries: []
    )

    var isVisible: Bool {
        if case .absent = state {
            return false
        }
        return true
    }

    var isInteractable: Bool {
        isVisible && evidenceKeySummaries.count == interactableKeySummaries.count
    }

    var directIdentity: String? {
        guard case let .visibleWithKnownIdentity(identity) = state else {
            return nil
        }
        return identity
    }

    var description: String {
        switch state {
        case .absent:
            return "A: keyboard surface not visible"
        case .visibleUnknownIdentity:
            return isInteractable
                ? "C: keyboard surface visible and interactable; identity unknown"
                : "B: keyboard surface visible through descendants; keyboard query intentionally unavailable"
        case let .visibleWithKnownIdentity(identity):
            return isInteractable
                ? "C: keyboard surface visible and interactable; direct identity=\(identity)"
                : "B: keyboard surface visible through descendants; direct identity=\(identity)"
        }
    }

    var metadataReport: String {
        [
            "Keyboard surface classification: \(description)",
            "Evidence keys:\n\(summaryList(evidenceKeySummaries))",
            "Interactable evidence keys:\n\(summaryList(interactableKeySummaries))",
            "Direct identity evidence:\n\(summaryList(identityEvidenceSummaries))",
        ].joined(separator: "\n\n")
    }

    private func summaryList(_ summaries: [String]) -> String {
        summaries.isEmpty ? "No matches." : summaries.joined(separator: "\n")
    }
}

private struct KeyboardNormalizationResult {
    let initialSurface: KeyboardSurfaceObservation
    let switcherCandidateSummaries: [String]
    let baselineCandidateSummaries: [String]
    let finalSurface: KeyboardSurfaceObservation
    let baselineEstablished: Bool
    let failureBoundary: String
    let classification: String

    var metadata: [String: String] {
        [
            "Initial keyboard surface": initialSurface.metadataReport,
            "System keyboard switcher candidates": summaryList(switcherCandidateSummaries),
            "Known baseline candidates": summaryList(baselineCandidateSummaries),
            "Final keyboard surface": finalSurface.metadataReport,
            "Known baseline established": baselineEstablished ? "yes" : "no",
            "Product behavior": "Universe Keyboard activation was not inferred from keyboard surface evidence.",
            "Future NE1 readiness": baselineEstablished
                ? "Known baseline was proven for this run."
                : "Blocked: deterministic keyboard state preparation remains unproven.",
        ]
    }

    private func summaryList(_ summaries: [String]) -> String {
        summaries.isEmpty ? "No matches." : summaries.joined(separator: "\n")
    }
}
