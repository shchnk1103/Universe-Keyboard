import Foundation
import Observation
import UIKit

/// 发布证据的业务阶段。阶段只描述证据的归属，不代表已经通过对应的人类门禁。
nonisolated enum ReleaseEvidenceLane: String, CaseIterable, Codable, Identifiable, Sendable {
    case dailyBeta = "daily_beta"
    case externalCandidate = "external_candidate"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dailyBeta:
            return "日常 Beta"
        case .externalCandidate:
            return "正式外部候选"
        }
    }

    var detail: String {
        switch self {
        case .dailyBeta:
            return "记录每次迭代的当前证据，可作为后续候选的基线。"
        case .externalCandidate:
            return "复用或引用 Beta 证据后，单独补齐外部候选检查。"
        }
    }
}

/// 根据变更范围选择的验证档位。它不改变现有 CI 分类：源代码改动仍需完整 CI。
nonisolated enum ReleaseValidationProfile: String, CaseIterable, Codable, Identifiable, Sendable {
    case delta
    case triggered
    case baseline

    var id: String { rawValue }

    var title: String {
        switch self {
        case .delta:
            return "变更增量"
        case .triggered:
            return "触发边界"
        case .baseline:
            return "基线重验"
        }
    }

    var detail: String {
        switch self {
        case .delta:
            return "只刷新变更路径与受影响功能的证据。"
        case .triggered:
            return "触及键盘、运行时或生命周期边界，扩大到触发用例。"
        case .baseline:
            return "涉及产物、工具链、权限或 RIME 边界，需要重新建立基线。"
        }
    }
}

nonisolated enum ReleaseEvidenceOutcome: String, CaseIterable, Codable, Identifiable, Sendable {
    case pass
    case partial
    case fail
    case inconclusive
    case notRun = "not-run"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pass:
            return "通过"
        case .partial:
            return "部分完成"
        case .fail:
            return "失败"
        case .inconclusive:
            return "未定"
        case .notRun:
            return "未执行"
        }
    }
}

/// Main App 内可记录的有限证据项。故意不包含用户输入、候选文字或文件内容。
nonisolated enum ReleaseEvidenceScope: String, CaseIterable, Codable, Identifiable, Sendable {
    case candidateIdentity = "candidate_identity"
    case changedPathValidation = "changed_path_validation"
    case affectedPathSmoke = "affected_path_smoke"
    case evidenceReuse = "evidence_reuse"
    case triggeredBoundary = "triggered_boundary"
    case baselineBoundary = "baseline_boundary"
    case externalReadiness = "external_candidate_readiness"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .candidateIdentity:
            return "候选身份"
        case .changedPathValidation:
            return "修改路径验证"
        case .affectedPathSmoke:
            return "受影响功能冒烟"
        case .evidenceReuse:
            return "Beta 证据引用"
        case .triggeredBoundary:
            return "触发边界"
        case .baselineBoundary:
            return "基线边界"
        case .externalReadiness:
            return "外部候选就绪"
        }
    }

    var detail: String {
        switch self {
        case .candidateIdentity:
            return "版本与构建号已记录；提交和产物映射需在 Candidate receipt 中核对。"
        case .changedPathValidation:
            return "本次改动直接覆盖的路径已验证。"
        case .affectedPathSmoke:
            return "受影响的用户路径完成最小冒烟。"
        case .evidenceReuse:
            return "沿用 Beta 证据的依据已核对。"
        case .triggeredBoundary:
            return "键盘、运行时或生命周期触发检查已完成。"
        case .baselineBoundary:
            return "产物、工具链、权限或 RIME 边界已重新核对。"
        case .externalReadiness:
            return "外部候选专属的检查已独立完成。"
        }
    }

    static func defaultScopes(
        lane: ReleaseEvidenceLane,
        profile: ReleaseValidationProfile
    ) -> [ReleaseEvidenceScope] {
        var scopes: [ReleaseEvidenceScope] = [
            .candidateIdentity,
            .changedPathValidation,
            .affectedPathSmoke,
        ]
        if lane == .externalCandidate {
            scopes.append(.evidenceReuse)
        }
        if profile == .triggered {
            scopes.append(.triggeredBoundary)
        } else if profile == .baseline {
            scopes.append(.baselineBoundary)
        }
        if lane == .externalCandidate {
            scopes.append(.externalReadiness)
        }
        return scopes
    }
}

nonisolated enum ReleaseEvidencePromotionMode: String, Codable, Sendable {
    case pendingArtifactMatch = "pending_artifact_match"
    case contractBaseline = "contract_baseline"
    case exactArtifact = "exact_artifact"
}

nonisolated struct ReleaseEvidenceStep: Codable, Equatable, Identifiable, Sendable {
    static let maximumNoteLength = 160

    let scope: ReleaseEvidenceScope
    var outcome: ReleaseEvidenceOutcome
    var note: String

    var id: String { scope.rawValue }

    init(
        scope: ReleaseEvidenceScope,
        outcome: ReleaseEvidenceOutcome = .notRun,
        note: String = ""
    ) {
        self.scope = scope
        self.outcome = outcome
        self.note = Self.normalizedNote(note)
    }

    private enum CodingKeys: String, CodingKey {
        case scope
        case outcome
        case note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scope = try container.decode(ReleaseEvidenceScope.self, forKey: .scope)
        outcome = try container.decode(ReleaseEvidenceOutcome.self, forKey: .outcome)
        note = Self.normalizedNote(try container.decodeIfPresent(String.self, forKey: .note) ?? "")
    }

    private static func normalizedNote(_ note: String) -> String {
        String(note.prefix(maximumNoteLength))
    }
}

nonisolated struct ReleaseEvidenceRun: Codable, Equatable, Identifiable, Sendable {
    static let currentSchemaVersion = 1
    static let currentEvidenceContractVersion = "release-evidence-v1"
    static let currentBehaviorContract = "keyboard-behavior-v1"
    static let unknownBehaviorContract = "UNKNOWN"

    let schemaVersion: Int
    let id: UUID
    let createdAt: Date
    var updatedAt: Date
    let lane: ReleaseEvidenceLane
    let profile: ReleaseValidationProfile
    let appVersion: String
    let appBuild: String
    let deviceModel: String
    let osVersion: String
    let candidateID: String
    let behaviorContract: String
    let promotionSourceRunID: UUID?
    let promotionMode: ReleaseEvidencePromotionMode?
    var steps: [ReleaseEvidenceStep]

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        lane: ReleaseEvidenceLane,
        profile: ReleaseValidationProfile,
        appVersion: String,
        appBuild: String,
        deviceModel: String,
        osVersion: String,
        candidateID: String,
        behaviorContract: String = Self.currentBehaviorContract,
        promotionSourceRunID: UUID? = nil,
        promotionMode: ReleaseEvidencePromotionMode? = nil,
        steps: [ReleaseEvidenceStep]
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
        self.lane = lane
        self.profile = profile
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.deviceModel = deviceModel
        self.osVersion = osVersion
        self.candidateID = candidateID
        self.behaviorContract = behaviorContract
        self.promotionSourceRunID = promotionSourceRunID
        self.promotionMode = promotionMode
        self.steps = steps
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case id
        case createdAt
        case updatedAt
        case lane
        case profile
        case appVersion
        case appBuild
        case deviceModel
        case osVersion
        case candidateID
        case behaviorContract
        case promotionSourceRunID
        case promotionMode
        case steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        lane = try container.decode(ReleaseEvidenceLane.self, forKey: .lane)
        profile = try container.decode(ReleaseValidationProfile.self, forKey: .profile)
        appVersion = try container.decode(String.self, forKey: .appVersion)
        appBuild = try container.decode(String.self, forKey: .appBuild)
        deviceModel = try container.decode(String.self, forKey: .deviceModel)
        osVersion = try container.decode(String.self, forKey: .osVersion)
        candidateID = try container.decode(String.self, forKey: .candidateID)
        behaviorContract =
            try container.decodeIfPresent(String.self, forKey: .behaviorContract)
            ?? Self.unknownBehaviorContract
        promotionSourceRunID = try container.decodeIfPresent(UUID.self, forKey: .promotionSourceRunID)
        promotionMode = try container.decodeIfPresent(
            ReleaseEvidencePromotionMode.self,
            forKey: .promotionMode
        )
        steps = try container.decode([ReleaseEvidenceStep].self, forKey: .steps)
    }

    var outcome: ReleaseEvidenceOutcome {
        guard !steps.isEmpty else { return .notRun }
        if steps.contains(where: { $0.outcome == .fail }) {
            return .fail
        }
        if steps.contains(where: { $0.outcome == .inconclusive }) {
            return .inconclusive
        }
        if steps.contains(where: { $0.outcome == .partial || $0.outcome == .notRun }) {
            return .partial
        }
        // The Main App cannot verify the archive/package identity on its own.
        // A promoted external session therefore stays non-passing until a
        // separately generated Candidate receipt proves the exact artifact.
        if lane == .externalCandidate && promotionMode != .exactArtifact {
            return .partial
        }
        return .pass
    }

    var isCompletePass: Bool {
        // Current-proof is a CLI receipt claim. The Main App may create and
        // edit daily Beta evidence, but it cannot assert external identity.
        lane == .dailyBeta && !steps.isEmpty && steps.allSatisfy { $0.outcome == .pass }
    }
}

nonisolated struct ReleaseEvidenceArchive: Codable, Sendable {
    let schemaVersion: Int
    var runs: [ReleaseEvidenceRun]
}

nonisolated enum ReleaseEvidenceStoreError: Error, Equatable {
    case appGroupUnavailable
    case invalidArchive
}

/// Main App 独占的证据存储。与诊断 JSONL 分开，清空日志不会删除发布证据。
actor ReleaseEvidenceFileStore {
    static let maximumRunCount = 50
    private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"
    private static let corruptArchivePrefix = "records.corrupt."

    private let fileURL: URL?

    init(fileURL: URL?) {
        self.fileURL = fileURL
    }

    static func live() -> ReleaseEvidenceFileStore {
        let fileURL =
            FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupID)?
            .appendingPathComponent("Diagnostics/v1/release-evidence/records.json")
        return ReleaseEvidenceFileStore(fileURL: fileURL)
    }

    func load() throws -> [ReleaseEvidenceRun] {
        guard let fileURL else { throw ReleaseEvidenceStoreError.appGroupUnavailable }
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let archive = try decoder.decode(ReleaseEvidenceArchive.self, from: data)
            guard archive.schemaVersion == ReleaseEvidenceRun.currentSchemaVersion else {
                throw ReleaseEvidenceStoreError.invalidArchive
            }
            return normalized(archive.runs)
        } catch let error as ReleaseEvidenceStoreError {
            throw error
        } catch {
            throw ReleaseEvidenceStoreError.invalidArchive
        }
    }

    func save(_ run: ReleaseEvidenceRun) throws {
        guard let fileURL else { throw ReleaseEvidenceStoreError.appGroupUnavailable }

        var runs: [ReleaseEvidenceRun]
        do {
            runs = try load()
        } catch ReleaseEvidenceStoreError.invalidArchive {
            // Preserve the operator's original evidence for inspection, then
            // allow a deliberate new session to establish a clean archive.
            try quarantineCorruptArchive(at: fileURL)
            runs = []
        }
        if let index = runs.firstIndex(where: { $0.id == run.id }) {
            runs[index] = run
        } else {
            runs.append(run)
        }

        let archive = ReleaseEvidenceArchive(
            schemaVersion: ReleaseEvidenceRun.currentSchemaVersion,
            runs: normalized(runs)
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(archive)

        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        // Data's atomic option keeps a partially written JSON file from being
        // observed after an app termination during a save.
        try data.write(to: fileURL, options: .atomic)
    }

    private func quarantineCorruptArchive(at fileURL: URL) throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        let quarantineURL =
            fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("\(Self.corruptArchivePrefix)\(UUID().uuidString).json")
        try FileManager.default.moveItem(at: fileURL, to: quarantineURL)
    }

    private func normalized(_ runs: [ReleaseEvidenceRun]) -> [ReleaseEvidenceRun] {
        Array(
            runs
                .sorted { left, right in left.updatedAt > right.updatedAt }
                .prefix(Self.maximumRunCount)
        )
    }
}

nonisolated struct ReleaseEvidenceExport: Codable, Sendable {
    let schemaVersion: Int
    let evidenceContractVersion: String
    let recordType: String
    let run: ReleaseEvidenceRun
    let outcome: ReleaseEvidenceOutcome
    let nonClaims: [String]

    init(run: ReleaseEvidenceRun) {
        schemaVersion = ReleaseEvidenceRun.currentSchemaVersion
        evidenceContractVersion = ReleaseEvidenceRun.currentEvidenceContractVersion
        recordType = "release_evidence_run"
        self.run = run
        outcome = run.outcome
        nonClaims = [
            "does_not_replace_existing_ci_gate",
            "does_not_grant_independent_quality_pass",
            "does_not_grant_product_or_release_gate_pass",
            "external_actions_remain_separately_authorized",
        ]
    }
}

/// 发布证据页面的 MainActor 状态。所有写盘通过 actor，避免阻塞输入热路径。
@MainActor
@Observable
final class ReleaseEvidenceSessionModel {
    static let shared = ReleaseEvidenceSessionModel()

    var runs: [ReleaseEvidenceRun] = []
    var selectedRunID: UUID?
    var selectedLane: ReleaseEvidenceLane = .dailyBeta
    var selectedProfile: ReleaseValidationProfile = .delta
    var candidateID = ""
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var candidateIDError: String?

    let appVersion: String
    let appBuild: String
    let deviceModel: String
    let osVersion: String

    private let storage: ReleaseEvidenceFileStore
    private var didLoad = false

    init(
        storage: ReleaseEvidenceFileStore = .live(),
        bundle: Bundle = .main,
        deviceModel: String = UIDevice.current.model,
        osVersion: String = UIDevice.current.systemVersion
    ) {
        self.storage = storage
        appVersion = Self.infoValue("CFBundleShortVersionString", in: bundle)
        appBuild = Self.infoValue("CFBundleVersion", in: bundle)
        self.deviceModel = deviceModel
        self.osVersion = osVersion
    }

    var selectedRun: ReleaseEvidenceRun? {
        guard let selectedRunID else { return nil }
        return runs.first { $0.id == selectedRunID }
    }

    var canPromoteSelectedRun: Bool {
        guard let selectedRun else { return false }
        return !isSaving && selectedRun.lane == .dailyBeta && selectedRun.isCompletePass
    }

    func load() {
        guard !didLoad, !isLoading else { return }
        didLoad = true
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }
            do {
                let loadedRuns = try await storage.load()
                runs = loadedRuns
                if selectedRunID == nil {
                    selectedRunID = loadedRuns.first?.id
                }
            } catch {
                errorMessage = Self.message(for: error)
            }
            isLoading = false
        }
    }

    func startSession() {
        let normalizedID = candidateID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidCandidateID(normalizedID) else {
            candidateIDError = "请输入 1–64 位字母、数字、点、下划线或短横线。"
            return
        }

        candidateID = normalizedID
        candidateIDError = nil
        errorMessage = nil
        let run = ReleaseEvidenceRun(
            lane: selectedLane,
            profile: selectedProfile,
            appVersion: appVersion,
            appBuild: appBuild,
            deviceModel: deviceModel,
            osVersion: osVersion,
            candidateID: normalizedID,
            steps: ReleaseEvidenceScope.defaultScopes(
                lane: selectedLane,
                profile: selectedProfile
            ).map { ReleaseEvidenceStep(scope: $0) }
        )
        runs.insert(run, at: 0)
        runs = Array(runs.prefix(ReleaseEvidenceFileStore.maximumRunCount))
        selectedRunID = run.id
        persist(run)
    }

    func setOutcome(
        _ outcome: ReleaseEvidenceOutcome,
        for scope: ReleaseEvidenceScope,
        in runID: UUID
    ) {
        guard !isSaving, let runIndex = runs.firstIndex(where: { $0.id == runID }) else {
            return
        }
        guard let stepIndex = runs[runIndex].steps.firstIndex(where: { $0.scope == scope }) else {
            return
        }
        runs[runIndex].steps[stepIndex].outcome = outcome
        runs[runIndex].updatedAt = Date()
        persist(runs[runIndex])
    }

    func promoteSelectedRun() {
        guard canPromoteSelectedRun, let source = selectedRun else { return }
        let now = Date()
        var promotedSteps = source.steps
        if !promotedSteps.contains(where: { $0.scope == .evidenceReuse }) {
            promotedSteps.append(
                ReleaseEvidenceStep(
                    scope: .evidenceReuse,
                    outcome: .pass,
                    note: "已复用日常 Beta 的完整会话记录；当前候选仍需核对产物身份。"
                )
            )
        }
        promotedSteps.append(
            ReleaseEvidenceStep(
                scope: .externalReadiness,
                note: "已从日常 Beta 复制；等待当前外部候选的产物身份核对。"
            )
        )
        let promoted = ReleaseEvidenceRun(
            createdAt: now,
            updatedAt: now,
            lane: .externalCandidate,
            profile: source.profile,
            appVersion: source.appVersion,
            appBuild: source.appBuild,
            deviceModel: deviceModel,
            osVersion: osVersion,
            candidateID: source.candidateID,
            behaviorContract: source.behaviorContract,
            promotionSourceRunID: source.id,
            promotionMode: .pendingArtifactMatch,
            steps: promotedSteps
        )
        runs.insert(promoted, at: 0)
        runs = Array(runs.prefix(ReleaseEvidenceFileStore.maximumRunCount))
        selectedRunID = promoted.id
        persist(promoted)
    }

    var exportText: String {
        guard let selectedRun else { return "" }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(ReleaseEvidenceExport(run: selectedRun)) else {
            return ""
        }
        return String(decoding: data, as: UTF8.self)
    }

    private func persist(_ run: ReleaseEvidenceRun) {
        guard !isSaving else { return }
        isSaving = true
        Task { [weak self] in
            guard let self else { return }
            do {
                try await storage.save(run)
            } catch {
                errorMessage = Self.message(for: error)
            }
            isSaving = false
        }
    }

    private func isValidCandidateID(_ value: String) -> Bool {
        value.range(of: #"^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$"#, options: .regularExpression) != nil
    }

    private static func infoValue(_ key: String, in bundle: Bundle) -> String {
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
            return "UNKNOWN"
        }
        return value
    }

    private static func message(for error: Error) -> String {
        switch error {
        case ReleaseEvidenceStoreError.appGroupUnavailable:
            return "App Group 不可用，证据尚未写入。"
        case ReleaseEvidenceStoreError.invalidArchive:
            return "发布证据文件无法读取；开始新会话时会保留原文件为隔离副本，并建立新的记录文件。"
        default:
            return "发布证据保存失败，请稍后重试。"
        }
    }
}
