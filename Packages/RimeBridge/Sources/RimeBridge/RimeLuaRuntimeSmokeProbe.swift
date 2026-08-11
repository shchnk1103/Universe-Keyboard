import Foundation
import KeyboardCore
import RimeBridgeObjC

public struct RimeLuaRuntimeSmokeProbe: Sendable {
    public struct CaseResult: Equatable, Sendable {
        public let candidateCount: Int
        public let dynamicCandidateFound: Bool
    }

    public struct Result: Equatable, Sendable {
        public let selectedRequestedSchema: Bool
        public let luaModuleRegistered: Bool
        public let caseResults: [CaseResult]

        public var passed: Bool {
            selectedRequestedSchema
                && luaModuleRegistered
                && caseResults.allSatisfy(\.dynamicCandidateFound)
        }
    }

    public static func run(
        sharedDataDir: String,
        userDataDir: String,
        schemaID: String,
        inputs: [String] = ["rq", "sj", "xq", "dt"]
    ) -> Result {
        let bridge = RimeSessionManager()
        bridge.setup(withSharedDataDir: sharedDataDir, userDataDir: userDataDir)
        bridge.initializeEngine()
        bridge.createSession()
        defer { bridge.finalize() }

        _ = bridge.selectSchema(schemaID)
        let selectedSchemaID = bridge.currentSchemaID()
        let caseResults = inputs.map { input in
            smokeCase(input, bridge: bridge)
        }

        return Result(
            selectedRequestedSchema: selectedSchemaID == schemaID,
            luaModuleRegistered: RimeBridgeCapabilities.luaModuleRegistered,
            caseResults: caseResults
        )
    }

    private static func smokeCase(_ input: String, bridge: RimeSessionManager) -> CaseResult {
        bridge.clearComposition()
        var output = RimeOutput()
        for character in input {
            let raw = bridge.processKey(RimeEngineImpl.keycode(for: String(character)), modifiers: 0)
            output = RimeEngineImpl.parseOutputDictionary(raw)
        }
        let window = RimeEngineImpl.parseCandidateWindowDictionary(
            bridge.candidates(from: 0, limit: 80)
        )
        let allCandidates = window.candidates.isEmpty ? output.candidates : window.candidates
        let dynamicCandidates =
            allCandidates
            .map(\.text)
            .filter { isDynamicDateTimeCandidate($0, for: input) }
        let result = CaseResult(
            candidateCount: allCandidates.count,
            dynamicCandidateFound: !dynamicCandidates.isEmpty
        )
        bridge.clearComposition()
        return result
    }

    private static func isDynamicDateTimeCandidate(_ candidate: String, for input: String) -> Bool {
        switch input {
        case "rq":
            return candidate.range(of: #"20\d{2}[-/年.]\d{1,2}[-/月.]\d{1,2}"#, options: .regularExpression) != nil
        case "sj":
            return candidate.range(of: #"\d{1,2}:\d{2}"#, options: .regularExpression) != nil
        case "xq":
            return candidate.range(
                of: #"^(星期|礼拜|周)[日一二三四五六天]$"#,
                options: .regularExpression
            ) != nil
        case "dt":
            return candidate.range(of: #"20\d{2}[-/]\d{1,2}[-/]\d{1,2}[ T]\d{1,2}:\d{2}"#, options: .regularExpression)
                != nil
        default:
            return false
        }
    }
}
