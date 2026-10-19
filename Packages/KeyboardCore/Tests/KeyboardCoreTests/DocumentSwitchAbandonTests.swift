import XCTest

@testable import KeyboardCore

/// The host switch sequence unbinds the old client before abandoning composition,
/// then binds the new client. The old epoch must not paint through the new client.
@MainActor
final class DocumentSwitchAbandonTests: XCTestCase {
    func testDocumentSwitchAbandonsOldEpochBeforeBindingNewClient() async {
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let oldClient = FakeTextInputClient()
        let newClient = FakeTextInputClient()
        let controller = KeyboardController()
        controller.textClient = oldClient
        controller.isResponsiveRimePipelineEnabled = true
        controller.isThreadAffineRimeOwnerEnabled = true
        controller.threadAffineEngineBootstrap = AnyThreadAffineRimeEngineBootstrap(
            BlockingBootstrap(processEntered: entered, releaseFirst: release)
        )
        var presentationCount = 0
        controller.onResponsivePresentationNeeded = { _ in
            presentationCount += 1
        }
        controller.rebuildResponsiveRimeCoordinatorIfNeeded()

        _ = controller.handle(.insertKey("n"))
        XCTAssertEqual(entered.wait(timeout: .now() + 1), .success)

        oldClient.setMarkedText("previous", selectedRange: 8..<8)
        controller.state.insertedPreeditText = "previous"
        controller.state.insertedPreeditCount = 8
        controller.state.currentComposition = "previous"
        let oldEpoch = controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch
        controller.textClient = nil
        _ = controller.abandonCompositionForVisibilityChange()
        controller.textClient = newClient
        XCTAssertGreaterThan(
            controller.threadAffineRimeCoordinator?.diagnostics.sessionEpoch ?? 0,
            oldEpoch ?? 0
        )
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(controller.state.insertedPreeditText, "")
        XCTAssertTrue(newClient.markedTextHistory.isEmpty)

        release.signal()
        let deadline = Date().addingTimeInterval(2)
        while Date() < deadline {
            if (controller.threadAffineRimeCoordinator?.completedPublishCount ?? 0) >= 1 {
                break
            }
            try? await Task.sleep(nanoseconds: 1_000_000)
        }
        XCTAssertGreaterThanOrEqual(
            controller.threadAffineRimeCoordinator?.completedPublishCount ?? 0,
            1
        )
        XCTAssertEqual(presentationCount, 0, "the old epoch must not reach presentation")
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertTrue(
            newClient.markedTextHistory.isEmpty,
            "invalidating the old document must not write through the new proxy"
        )
        controller.suspendRimeForVisibilityChange()
    }
}

private struct BlockingBootstrap: ThreadAffineRimeEngineBootstrap {
    let processEntered: DispatchSemaphore
    let releaseFirst: DispatchSemaphore

    func makeEngineOnOwnerThread() -> any RimeEngine {
        BlockingEngine(processEntered: processEntered, releaseFirst: releaseFirst)
    }
}

private final class BlockingEngine: RimeEngine {
    private let delegate = FakeRimeEngine(dictionary: ["n": ["你"]])
    private let processEntered: DispatchSemaphore
    private let releaseFirst: DispatchSemaphore
    private var didBlock = false

    init(processEntered: DispatchSemaphore, releaseFirst: DispatchSemaphore) {
        self.processEntered = processEntered
        self.releaseFirst = releaseFirst
    }

    func processKey(_ key: String) -> RimeOutput {
        if !didBlock {
            didBlock = true
            processEntered.signal()
            releaseFirst.wait()
        }
        return delegate.processKey(key)
    }

    func selectCandidate(at index: Int) -> RimeOutput { delegate.selectCandidate(at: index) }
    func selectCandidate(globalIndex index: Int) -> RimeOutput { delegate.selectCandidate(globalIndex: index) }
    func candidateWindow(from globalIndex: Int, limit: Int) -> RimeCandidateWindow {
        delegate.candidateWindow(from: globalIndex, limit: limit)
    }
    func deleteBackward() -> RimeOutput { delegate.deleteBackward() }
    func replaceInput(_ input: String) -> RimeOutput { delegate.replaceInput(input) }
    func resetSession() { delegate.resetSession() }
    func recoverSession() { delegate.recoverSession() }
    func suspendForVisibilityChange() { delegate.suspendForVisibilityChange() }
    func resumeAfterVisibilityChange() { delegate.resumeAfterVisibilityChange() }
    var runtimeSelection: RimeRuntimeSelection? { delegate.runtimeSelection }
    var diagnosticSessionSnapshot: RimeSessionDiagnosticSnapshot? { delegate.diagnosticSessionSnapshot }
    var onRuntimeSelectionChanged: ((RimeRuntimeSelection) -> Void)? {
        get { delegate.onRuntimeSelectionChanged }
        set { delegate.onRuntimeSelectionChanged = newValue }
    }
    func isComposing() -> Bool { delegate.isComposing() }
    func pageUp() -> RimeOutput { delegate.pageUp() }
    func pageDown() -> RimeOutput { delegate.pageDown() }
}
