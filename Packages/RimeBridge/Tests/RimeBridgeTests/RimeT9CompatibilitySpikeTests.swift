import Foundation
import XCTest

@testable import RimeBridge

/// Isolated T9 compatibility Spike required by KEYBOARD-LAYOUT-9KEY-001.
///
/// Preconditions (prepared by `scripts/run_t9_compatibility_spike.sh`):
/// - `UK_RIME_T9_SPIKE_SHARED_DIR` / `UK_RIME_T9_SPIKE_USER_DIR` point to a
///   temporary deploy tree that already contains rime-ice assets and a
///   patched `t9.schema.yaml` with unsupported `t9_processor` removed.
/// - The directories must not be the user's formal App Group runtime.
///
/// Pass criteria require real T9 algebra output: non-empty candidates **and**
/// non-empty composition/preedit. Raw-digit buffering alone is not enough.
final class RimeT9CompatibilitySpikeTests: XCTestCase {
    func testPinnedLibrimeCanSelectT9AndProcessDigitSequenceAfterRemovingUnsupportedProcessor() async throws {
        let directories = try spikeRuntimeDirectories()
        try assertSpikeSchemaIsPatched(sharedDir: directories.sharedDir)

        let deployService = RimeDeploymentService()
        let deployResult = try await deployService.deploy(
            RimeDeploymentRequest(
                mode: .fullCheck,
                sharedDataURL: URL(fileURLWithPath: directories.sharedDir),
                userDataURL: URL(fileURLWithPath: directories.userDir),
                runtimeSmokeSchemaID: nil
            )
        )
        XCTAssertTrue(
            deployResult.succeeded,
            "T9 Spike deploy failed: \(deployResult.diagnosticMessage)"
        )

        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )
        defer {
            engine.bridge.clearComposition()
            engine.bridge.finalize()
        }

        let selected = engine.bridge.selectSchema("t9")
        let currentSchema = engine.bridge.currentSchemaID()
        XCTAssertTrue(selected, "selectSchema(t9) returned false")
        XCTAssertEqual(currentSchema, "t9", "Pinned librime did not keep schema t9 selected")

        engine.bridge.clearComposition()
        var afterDigits = engine.processKey("6")
        afterDigits = engine.processKey("4")

        let rawAfterDigits = afterDigits.rawInput ?? ""
        let preeditAfterDigits = afterDigits.composition?.preeditText ?? ""
        let candidates = afterDigits.candidates
        let firstComment = candidates.first?.comment ?? ""

        XCTAssertEqual(
            rawAfterDigits,
            "64",
            "Expected raw digit composition '64', got '\(rawAfterDigits)'"
        )
        XCTAssertFalse(
            preeditAfterDigits.isEmpty,
            """
            T9 Spike requires non-empty composition/preedit after 64; \
            raw-only buffering is insufficient. raw=\(rawAfterDigits)
            """
        )
        XCTAssertFalse(
            candidates.isEmpty,
            """
            T9 Spike requires non-empty candidates after 64 to prove digit algebra \
            produced lookup results. raw=\(rawAfterDigits) preedit=\(preeditAfterDigits)
            """
        )

        let afterDelete = engine.processDeletion()
        let rawAfterDelete = afterDelete.rawInput ?? ""
        XCTAssertEqual(
            rawAfterDelete.count,
            rawAfterDigits.count - 1,
            """
            BackSpace must remove exactly one raw digit. \
            before=\(rawAfterDigits) after=\(rawAfterDelete)
            """
        )
        XCTAssertEqual(rawAfterDelete, "6")

        engine.bridge.clearComposition()
        let cleared = engine.bridge.currentSchemaID()
        XCTAssertEqual(cleared, "t9")

        let summary = """
        T9_SPIKE_RESULT passed=true \
        librime=\(engine.bridge.librimeVersion()) \
        schema=\(currentSchema) \
        rawAfter64=\(rawAfterDigits) \
        preeditAfter64=\(preeditAfterDigits) \
        candidateCount=\(candidates.count) \
        candidateSample=\(candidates.prefix(5).map(\.text).joined(separator: "|")) \
        firstCandidateComment=\(firstComment.isEmpty ? "empty" : firstComment) \
        rawAfterDelete=\(rawAfterDelete) \
        deploy=\(deployResult.diagnosticMessage)
        """
        fputs(summary + "\n", stderr)
        print(summary)
        NSLog("%@", summary)
    }

    private func spikeRuntimeDirectories() throws -> (sharedDir: String, userDir: String) {
        let env = ProcessInfo.processInfo.environment
        let sharedDir = env["UK_RIME_T9_SPIKE_SHARED_DIR"] ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_SHARED_DIR"]
        let userDir = env["UK_RIME_T9_SPIKE_USER_DIR"] ?? env["TEST_RUNNER_UK_RIME_T9_SPIKE_USER_DIR"]

        guard let sharedDir, let userDir else {
            throw XCTSkip(
                "Set UK_RIME_T9_SPIKE_SHARED_DIR and UK_RIME_T9_SPIKE_USER_DIR to run the T9 compatibility Spike."
            )
        }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: sharedDir), fileManager.fileExists(atPath: userDir) else {
            throw XCTSkip("Provided T9 Spike directories do not exist.")
        }
        guard fileManager.fileExists(atPath: "\(sharedDir)/t9.schema.yaml"),
              fileManager.fileExists(atPath: "\(sharedDir)/rime_ice.schema.yaml")
        else {
            throw XCTSkip("T9 Spike fixture is incomplete (needs t9.schema.yaml and rime_ice.schema.yaml).")
        }

        return (sharedDir, userDir)
    }

    private func assertSpikeSchemaIsPatched(sharedDir: String) throws {
        let schemaPath = "\(sharedDir)/t9.schema.yaml"
        let contents = try String(contentsOfFile: schemaPath, encoding: .utf8)
        XCTAssertFalse(
            contents.contains("t9_processor"),
            "Spike fixture must remove unsupported t9_processor before using the pinned librime."
        )
        XCTAssertTrue(
            contents.contains("schema_id: t9") || contents.contains("schema_id:t9"),
            "Spike fixture must remain schema_id t9."
        )
        XCTAssertTrue(
            contents.contains("derive/[abc]/2/"),
            "Spike fixture must retain T9 digit algebra mappings."
        )
    }
}
