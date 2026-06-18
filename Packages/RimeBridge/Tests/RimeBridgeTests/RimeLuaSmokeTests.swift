import Foundation
import XCTest

@testable import RimeBridge

final class RimeLuaSmokeTests: XCTestCase {
    func testRimeIceLuaDynamicCandidatesWhenRuntimeFixtureIsProvided() throws {
        let directories = try luaSmokeRuntimeDirectories()
        let engine = RimeEngineImpl(
            sharedDataDir: directories.sharedDir,
            userDataDir: directories.userDir
        )

        guard engine.bridge.selectSchema("rime_ice") else {
            return XCTFail("rime_ice schema could not be selected from the provided smoke-test runtime.")
        }

        assertLuaCandidate(
            input: "rq",
            engine: engine,
            description: "date",
            matches: { candidates in
                let year = String(Calendar.current.component(.year, from: Date()))
                return candidates.contains { $0.contains(year) }
            }
        )
        assertLuaCandidate(input: "sj", engine: engine, description: "time")
        assertLuaCandidate(input: "xq", engine: engine, description: "weekday")
        assertLuaCandidate(input: "dt", engine: engine, description: "datetime")
        assertLuaCandidate(
            input: "ts",
            engine: engine,
            description: "timestamp",
            matches: { candidates in
                candidates.contains { $0.filter(\.isNumber).count >= 10 }
            }
        )
        assertLuaCandidate(
            input: "R123",
            engine: engine,
            description: "number uppercase",
            matches: { candidates in
                candidates.contains { $0.contains("壹") || $0.contains("一百") }
            }
        )
        assertLuaCandidate(
            input: "cC1+1",
            engine: engine,
            description: "calculator",
            matches: { candidates in
                candidates.contains { $0.contains("2") }
            }
        )
    }

    private func luaSmokeRuntimeDirectories() throws -> (sharedDir: String, userDir: String) {
        let env = ProcessInfo.processInfo.environment
        let sharedDir = env["UK_RIME_LUA_SMOKE_SHARED_DIR"] ?? env["TEST_RUNNER_UK_RIME_LUA_SMOKE_SHARED_DIR"]
        let userDir = env["UK_RIME_LUA_SMOKE_USER_DIR"] ?? env["TEST_RUNNER_UK_RIME_LUA_SMOKE_USER_DIR"]

        guard let sharedDir, let userDir else {
            throw XCTSkip("Set UK_RIME_LUA_SMOKE_SHARED_DIR and UK_RIME_LUA_SMOKE_USER_DIR to run the real Lua smoke test.")
        }

        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: sharedDir), fileManager.fileExists(atPath: userDir) else {
            throw XCTSkip("Provided RIME Lua smoke-test directories do not exist.")
        }
        guard fileManager.fileExists(atPath: "\(sharedDir)/rime_ice.schema.yaml"),
              fileManager.fileExists(atPath: "\(sharedDir)/lua/date_translator.lua")
        else {
            throw XCTSkip("Provided RIME runtime does not contain complete rime_ice Lua files.")
        }

        return (sharedDir, userDir)
    }

    private func assertLuaCandidate(
        input: String,
        engine: RimeEngineImpl,
        description: String,
        matches: ([String]) -> Bool = { !$0.isEmpty }
    ) {
        engine.resetSession()
        var outputCandidates: [String] = []
        for character in input {
            let output = engine.processKey(String(character))
            outputCandidates = output.candidates.map(\.text)
        }
        XCTAssertTrue(
            matches(outputCandidates),
            "Expected \(description) Lua candidates for '\(input)', got: \(outputCandidates)"
        )
    }
}
