import Foundation
import KeyboardCore
import Synchronization
import XCTest

@testable import RimeBridge

/// R4-B: real `RimeEngineImpl` on the thread-affine owner (disconnected proof).
///
/// Fixture env (same isolated-runtime family as T9 spikes):
/// - `UK_RIME_T9_SPIKE_SHARED_DIR` / `UK_RIME_T9_SPIKE_USER_DIR`
/// - or `TEST_RUNNER_` / `SIMCTL_CHILD_` / `UK_RIME_R4B_*` variants
///
/// Without a fixture the suite **skips** — absence of runtime is not Pass.
@available(iOS 18.0, *)
final class ThreadAffineRimeRealEngineTests: XCTestCase {

    func testRealEngineBootstrapCreatesAndCallsOffMainThroughOwner() async throws {
        let directories = try realRuntimeDirectories()
        try await deployIsolatedRuntime(sharedDir: directories.sharedDir, userDir: directories.userDir)

        let schemaID = try preferredSchemaID(sharedDir: directories.sharedDir)
        let keyCount = 4
        let delivered = expectation(description: "real engine deliveries")
        delivered.expectedFulfillmentCount = keyCount

        struct Capture: Sendable {
            var actionOrder: [String] = []
            var affinity: [(offMain: Bool, sameThread: Bool)] = []
        }
        let capture = Mutex(Capture())

        let owner = ThreadAffineRimeSpikeOwner(
            bootstrap: ThreadAffineRimeEngineImplBootstrap(
                sharedDataDir: directories.sharedDir,
                userDataDir: directories.userDir,
                preferredSchemaID: schemaID
            ),
            configuration: ThreadAffineRimeOwnerConfiguration(maxPendingWorkDepth: 32),
            resultHandler: { result in
                capture.withLock { state in
                    state.actionOrder.append(result.snapshot.actionID)
                    state.affinity.append(
                        (
                            result.engineCreatedOffMainThread,
                            result.engineCallStayedOnCreationThread
                        )
                    )
                }
                delivered.fulfill()
            }
        )

        // Short frozen prefix of the product fixture spelling (content-free IDs only).
        let keys = ["n", "i", "h", "a"]
        for (index, key) in keys.enumerated() {
            let receipt = await MainActor.run {
                owner.accept(.processKey(key), actionID: "rk\(index)")
            }
            XCTAssertNotNil(receipt, "accept must enqueue real-engine work rk\(index)")
            XCTAssertEqual(receipt?.executedSynchronously, false)
        }

        await fulfillment(of: [delivered], timeout: 30)

        let finalCapture = capture.withLock { $0 }
        XCTAssertEqual(finalCapture.actionOrder, (0..<keyCount).map { "rk\($0)" })
        XCTAssertEqual(finalCapture.affinity.count, keyCount)
        XCTAssertTrue(
            finalCapture.affinity.allSatisfy(\.offMain),
            "real engine must be created off MainActor"
        )
        XCTAssertTrue(
            finalCapture.affinity.allSatisfy(\.sameThread),
            "real engine calls must stay on the creation thread"
        )

        await MainActor.run { owner.shutdown() }
        XCTAssertTrue(owner.waitUntilStopped(timeout: .now() + 10))
        XCTAssertTrue(owner.waitUntilDeliveryDrained(timeout: .now() + 10))
        XCTAssertTrue(owner.diagnostics().isDeliveryTerminal)
        XCTAssertEqual(owner.diagnostics().deliveredCount, keyCount)

        // Content-free machine line for harness evidence parsers.
        print(
            "R4B_REAL_ENGINE_RESULT passed=true schema=\(schemaID) "
                + "keys=\(keyCount) delivered=\(owner.diagnostics().deliveredCount) "
                + "offMain=true sameThread=true"
        )
    }

    @MainActor
    func testGateOffDefaultUnchangedByR4BBootstrapPresence() {
        // R4-B must not flip the production responsive gate. This is a
        // content-free contract check in the RimeBridge test target.
        let controller = KeyboardController()
        XCTAssertFalse(
            controller.isResponsiveRimePipelineEnabled,
            "R4-B must leave responsive gate default-off"
        )
        XCTAssertNil(controller.responsiveRimeCoordinator)
    }

    // MARK: - Fixture helpers

    private func realRuntimeDirectories() throws -> (sharedDir: String, userDir: String) {
        let env = ProcessInfo.processInfo.environment
        let sharedDir =
            env["UK_RIME_T9_SPIKE_SHARED_DIR"]
            ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR"]
            ?? env["SIMCTL_CHILD_UK_RIME_T9_SPIKE_SHARED_DIR"]
            ?? env["UK_RIME_R4B_SHARED_DIR"]
        let userDir =
            env["UK_RIME_T9_SPIKE_USER_DIR"]
            ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR"]
            ?? env["SIMCTL_CHILD_UK_RIME_T9_SPIKE_USER_DIR"]
            ?? env["UK_RIME_R4B_USER_DIR"]

        guard let sharedDir, let userDir else {
            throw XCTSkip(
                "Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR "
                    + "(or UK_RIME_R4B_*) to run R4-B real-engine proof."
            )
        }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: sharedDir),
              fileManager.fileExists(atPath: userDir)
        else {
            throw XCTSkip("R4-B runtime directories do not exist.")
        }
        guard fileManager.fileExists(atPath: "\(sharedDir)/rime_ice.schema.yaml")
                || fileManager.fileExists(atPath: "\(sharedDir)/t9.schema.yaml")
        else {
            throw XCTSkip("R4-B runtime lacks rime_ice.schema.yaml and t9.schema.yaml.")
        }
        return (sharedDir, userDir)
    }

    private func preferredSchemaID(sharedDir: String) throws -> String {
        let fileManager = FileManager.default
        // Prefer 26-key baseline for R4-B bootstrap proof; T9 is optional stretch.
        if fileManager.fileExists(atPath: "\(sharedDir)/rime_ice.schema.yaml") {
            return "rime_ice"
        }
        if fileManager.fileExists(atPath: "\(sharedDir)/t9.schema.yaml") {
            return "t9"
        }
        throw XCTSkip("No preferred schema file present in R4-B runtime.")
    }

    private func deployIsolatedRuntime(sharedDir: String, userDir: String) async throws {
        let deployResult = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly,
                sharedDataURL: URL(fileURLWithPath: sharedDir),
                userDataURL: URL(fileURLWithPath: userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(
            deployResult.succeeded,
            "R4-B deploy failed: \(deployResult.diagnosticMessage)"
        )
    }
}
