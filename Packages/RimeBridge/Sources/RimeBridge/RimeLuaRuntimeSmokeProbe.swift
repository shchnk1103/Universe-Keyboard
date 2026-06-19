import Foundation
import KeyboardCore
import RimeBridgeObjC

public struct RimeLuaRuntimeSmokeProbe: Sendable {
    public struct CaseResult: Equatable, Sendable {
        public let input: String
        public let candidateCount: Int
        public let candidateSamples: [String]
        public let dynamicCandidateFound: Bool
        public let dynamicSamples: [String]
        public let rawInput: String?
        public let preedit: String?
    }

    public struct Result: Equatable, Sendable {
        public let schemaID: String
        public let selectedSchemaID: String?
        public let luaModuleRegistered: Bool
        public let caseResults: [CaseResult]

        public var passed: Bool {
            selectedSchemaID == schemaID
                && luaModuleRegistered
                && caseResults.allSatisfy(\.dynamicCandidateFound)
        }

        public var developerSummary: String {
            let cases = caseResults.map { result in
                let samples = result.candidateSamples.joined(separator: "|")
                let dynamicSamples = result.dynamicSamples.joined(separator: "|")
                return "\(result.input):count=\(result.candidateCount),dynamic=\(result.dynamicCandidateFound),dynamicSample=\(dynamicSamples),sample=\(samples),raw=\(result.rawInput ?? "nil"),preedit=\(result.preedit ?? "nil")"
            }.joined(separator: ";")
            return "rime_ice lua smoke: passed=\(passed);schema=\(schemaID);selected=\(selectedSchemaID ?? "nil");luaModuleRegistered=\(luaModuleRegistered);cases=\(cases)"
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
            schemaID: schemaID,
            selectedSchemaID: selectedSchemaID,
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
        let dynamicCandidates = allCandidates
            .map(\.text)
            .filter { isDynamicDateTimeCandidate($0, for: input) }
        let samples = allCandidates.prefix(5).map(\.text)
        let result = CaseResult(
            input: input,
            candidateCount: allCandidates.count,
            candidateSamples: Array(samples),
            dynamicCandidateFound: !dynamicCandidates.isEmpty,
            dynamicSamples: Array(dynamicCandidates.prefix(3)),
            rawInput: output.rawInput,
            preedit: output.composition?.preeditText
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
            return candidate.range(of: #"20\d{2}[-/]\d{1,2}[-/]\d{1,2}[ T]\d{1,2}:\d{2}"#, options: .regularExpression) != nil
        default:
            return false
        }
    }
}
