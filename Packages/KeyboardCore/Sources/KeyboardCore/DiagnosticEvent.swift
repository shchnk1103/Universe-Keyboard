import Foundation

/// 本地诊断 journal 的内容无关事件。
///
/// 这个类型是跨 target 的持久化协议，不接受自由文本。若需要新的诊断维度，
/// 必须先扩展下面的受控枚举并经过 ADR 0027 要求的字段审查。
public struct DiagnosticEvent: Codable, Sendable, Equatable {
    public static let schemaVersion = 3

    public enum Origin: String, Codable, CaseIterable, Sendable {
        case mainApp = "main_app"
        case keyboardExtension = "keyboard_extension"
    }

    public enum Code: String, Codable, CaseIterable, Sendable {
        case journalStarted = "journal.started"
        case journalResumed = "journal.resumed"
        case journalDropped = "journal.dropped"
        case journalUnavailable = "journal.unavailable"
        case presentationAppeared = "presentation.appeared"
        case presentationFrame = "presentation.frame"
        case touchTerminal = "touch.terminal"
        case inputAction = "input.action"
        case rimeOwnerPublished = "rime.owner.published"
        case uiApplied = "ui.applied"
        case candidateVisibilityChanged = "candidate.visibility_changed"
        case candidateTouchRouted = "candidate.touch_routed"
        case candidateGestureTerminal = "candidate.gesture_terminal"
        case candidateSelectionDelivered = "candidate.selection_delivered"
        case schemeDeliveryPhaseChanged = "scheme_delivery.phase_changed"
        case schemeDeliveryIntegrityFailed = "scheme_delivery.integrity_failed"
        case schemeDeliveryFallback = "scheme_delivery.fallback"
        case schemeDeliveryTerminal = "scheme_delivery.terminal"
        case rimeSyncInvoked = "rime_sync.invoked"
        case rimeSyncPhaseChanged = "rime_sync.phase_changed"
        case rimeSyncSkipped = "rime_sync.skipped"
        case rimeSyncTerminal = "rime_sync.terminal"
    }

    public enum Reason: String, Codable, CaseIterable, Sendable {
        case queueFull = "queue_full"
        case suspended = "suspended"
        case appGroupUnavailable = "app_group_unavailable"
        case directoryUnavailable = "directory_unavailable"
        case lockBusy = "lock_busy"
        case diskFull = "disk_full"
        case ioFailure = "io_failure"
        case generationChanged = "generation_changed"
        case writerReclaimed = "writer_reclaimed"
        case highFidelityExpired = "high_fidelity_expired"
    }

    public enum CountMetric: String, Codable, CaseIterable, Sendable {
        case droppedEventCount = "dropped_event_count"
        case queueDepth = "queue_depth"
        case candidateCount = "candidate_count"
        case visibleCandidateCellCount = "visible_candidate_cell_count"
        case highlightedKeyCount = "highlighted_key_count"
        case revision = "revision"
        case sessionEpoch = "session_epoch"
        case generation = "generation"
        /// 0 = upper, 1 = middle, 2 = lower. Kept coarse so diagnostics never
        /// persist precise pointer coordinates.
        case candidateTouchBand = "candidate_touch_band"
    }

    public enum DurationMetric: String, Codable, CaseIterable, Sendable {
        case elapsedMilliseconds = "elapsed_ms"
        case presentationAgeMilliseconds = "presentation_age_ms"
    }

    public enum Flag: String, Codable, CaseIterable, Sendable {
        case isHighFidelityEnabled = "high_fidelity_enabled"
        case isCandidateBarVisible = "candidate_bar_visible"
        case isKeyHighlighted = "key_highlighted"
        case didHitCandidateCell = "candidate_cell_hit"
        case didCandidatePanBegin = "candidate_pan_began"
        case wasCandidateTouchCancelled = "candidate_touch_cancelled"
    }

    /// Content-free vertical bucket used by the Debug candidate touch probe.
    public enum CandidateTouchBand: Int, Codable, CaseIterable, Sendable {
        case upper = 0
        case middle = 1
        case lower = 2

        public static func classify(y: Double, height: Double) -> Self {
            guard height > 0 else { return .middle }
            let normalizedY = min(max(y / height, 0), 1)
            if normalizedY < 1.0 / 3.0 { return .upper }
            if normalizedY < 2.0 / 3.0 { return .middle }
            return .lower
        }
    }

    /// 每个字段的 name、type 和允许值均由枚举约束，避免日志绕过隐私审查。
    public enum Field: Codable, Sendable, Equatable {
        case count(CountMetric, Int)
        case duration(DurationMetric, Int)
        case flag(Flag, Bool)
        case reason(Reason)

        private enum CodingKeys: String, CodingKey {
            case type
            case name
            case integerValue
            case booleanValue
            case reason
        }

        private enum Kind: String, Codable {
            case count
            case duration
            case flag
            case reason
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            switch try container.decode(Kind.self, forKey: .type) {
            case .count:
                self = .count(
                    try container.decode(CountMetric.self, forKey: .name),
                    try container.decode(Int.self, forKey: .integerValue)
                )
            case .duration:
                self = .duration(
                    try container.decode(DurationMetric.self, forKey: .name),
                    try container.decode(Int.self, forKey: .integerValue)
                )
            case .flag:
                self = .flag(
                    try container.decode(Flag.self, forKey: .name),
                    try container.decode(Bool.self, forKey: .booleanValue)
                )
            case .reason:
                self = .reason(try container.decode(Reason.self, forKey: .reason))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .count(name, value):
                try container.encode(Kind.count, forKey: .type)
                try container.encode(name, forKey: .name)
                try container.encode(value, forKey: .integerValue)
            case let .duration(name, value):
                try container.encode(Kind.duration, forKey: .type)
                try container.encode(name, forKey: .name)
                try container.encode(value, forKey: .integerValue)
            case let .flag(name, value):
                try container.encode(Kind.flag, forKey: .type)
                try container.encode(name, forKey: .name)
                try container.encode(value, forKey: .booleanValue)
            case let .reason(reason):
                try container.encode(Kind.reason, forKey: .type)
                try container.encode(reason, forKey: .reason)
            }
        }
    }

    public enum RimeSyncSource: String, Codable, CaseIterable, Sendable {
        case foregroundAutomatic = "foreground_automatic"
        case backgroundAutomatic = "background_automatic"
    }

    public enum RimeSyncPhase: String, Codable, CaseIterable, Sendable {
        case standardRimeData = "standard_rime_data"
        case privateSettings = "private_settings"
    }

    public enum RimeSyncPhaseResult: String, Codable, CaseIterable, Sendable {
        case started
        case completed
    }

    public enum RimeSyncSkipReason: String, Codable, CaseIterable, Sendable {
        case disabled
        case standardRimeDataDisabled = "standard_rime_data_disabled"
        case privateSettingsDisabled = "private_settings_disabled"
        case notConfigured = "not_configured"
        case waitingForFirstManualSync = "waiting_for_first_manual_sync"
        case coolingDown = "cooling_down"
        case keyboardActive = "keyboard_active"
        case processBusy = "process_busy"
        case modelBusy = "model_busy"
    }

    public enum RimeSyncTerminalResult: String, Codable, CaseIterable, Sendable {
        case completed
        case failed
        case cancelled
        case expired
    }

    /// Finite failure classes only. Raw error domains, paths and provider text
    /// are intentionally excluded from the persisted protocol.
    public enum RimeSyncFailure: String, Codable, CaseIterable, Sendable {
        case accessDenied = "access_denied"
        case invalidInstallationID = "invalid_installation_id"
        case invalidInstallationConfiguration = "invalid_installation_configuration"
        case unavailableUserDirectory = "unavailable_user_directory"
        case unavailableSyncDirectory = "unavailable_sync_directory"
        case standardSynchronizationFailed = "standard_synchronization_failed"
        case missingEncryptionKey = "missing_encryption_key"
        case unsupportedFormat = "unsupported_format"
        case packageTooLarge = "package_too_large"
        case corruptedPackage = "corrupted_package"
        case remoteConflict = "remote_conflict"
        case transport
        case localIO = "local_io"
        case unknown
    }

    public struct RimeSyncContext: Codable, Sendable, Equatable {
        public let operationID: UUID
        public let source: RimeSyncSource

        public init(operationID: UUID, source: RimeSyncSource) {
            self.operationID = operationID
            self.source = source
        }
    }

    public struct RimeSyncInvocationEvent: Codable, Sendable, Equatable {
        public let context: RimeSyncContext
        public let requestedPhases: [RimeSyncPhase]

        public init(context: RimeSyncContext, requestedPhases: [RimeSyncPhase]) {
            self.context = context
            self.requestedPhases = requestedPhases
        }

        fileprivate var isValid: Bool {
            !requestedPhases.isEmpty && Set(requestedPhases).count == requestedPhases.count
        }
    }

    public struct RimeSyncPhaseEvent: Codable, Sendable, Equatable {
        public let context: RimeSyncContext
        public let phase: RimeSyncPhase
        public let result: RimeSyncPhaseResult

        public init(
            context: RimeSyncContext,
            phase: RimeSyncPhase,
            result: RimeSyncPhaseResult
        ) {
            self.context = context
            self.phase = phase
            self.result = result
        }
    }

    public struct RimeSyncSkippedEvent: Codable, Sendable, Equatable {
        public let context: RimeSyncContext
        public let reason: RimeSyncSkipReason

        public init(context: RimeSyncContext, reason: RimeSyncSkipReason) {
            self.context = context
            self.reason = reason
        }
    }

    public struct RimeSyncTerminalEvent: Codable, Sendable, Equatable {
        public let context: RimeSyncContext
        public let result: RimeSyncTerminalResult
        public let phase: RimeSyncPhase?
        public let failure: RimeSyncFailure?

        public init(
            context: RimeSyncContext,
            result: RimeSyncTerminalResult,
            phase: RimeSyncPhase? = nil,
            failure: RimeSyncFailure? = nil
        ) {
            self.context = context
            self.result = result
            self.phase = phase
            self.failure = failure
        }

        fileprivate var isValid: Bool {
            switch result {
            case .completed:
                return phase == nil && failure == nil
            case .failed:
                return phase != nil && failure != nil
            case .cancelled, .expired:
                return failure == nil
            }
        }
    }

    public enum RimeSyncPayload: Codable, Sendable, Equatable {
        case invoked(RimeSyncInvocationEvent)
        case phaseChanged(RimeSyncPhaseEvent)
        case skipped(RimeSyncSkippedEvent)
        case terminal(RimeSyncTerminalEvent)

        var code: Code {
            switch self {
            case .invoked: .rimeSyncInvoked
            case .phaseChanged: .rimeSyncPhaseChanged
            case .skipped: .rimeSyncSkipped
            case .terminal: .rimeSyncTerminal
            }
        }

        var isValid: Bool {
            switch self {
            case .invoked(let event): event.isValid
            case .phaseChanged, .skipped: true
            case .terminal(let event): event.isValid
            }
        }
    }

    public enum SchemeArtifactIdentity: String, Codable, Sendable {
        case rimeIceNightlyF60AA4F3 = "rime_ice_nightly_f60aa4f3"
        case wanxiang1759CNB9BFCGitHub73F8 = "wanxiang_17_5_9_cnb9bfc_github73f8"
    }

    public enum SchemeStagedIdentity: String, Codable, Sendable {
        case rimeIceNightlyPlan1Post1 = "rime_ice_nightly_plan1_post1"
        case wanxiang1759Plan1Post1 = "wanxiang_17_5_9_plan1_post1"
    }

    public enum SchemeSource: String, Codable, Sendable {
        case nju
        case github
        case cnb
    }

    public enum SchemeHost: String, Codable, Sendable {
        case nju = "mirror.nju.edu.cn"
        case github = "github.com"
        case githubRelease = "release-assets.githubusercontent.com"
        case githubObjects = "objects.githubusercontent.com"
        case cnb = "cnb.cool"
        case cnbAsset = "asset.cnb.cool"
    }

    public enum SchemeDeliveryPhase: String, Codable, Sendable {
        case selecting
        case downloading
        case verifyingArchiveSize = "verifying_archive_size"
        case verifyingArchiveDigest = "verifying_archive_digest"
        case cleanup
        case extracting
        case postProcessing = "post_processing"
        case verifyingStagedContent = "verifying_staged_content"
        case installing
        case deploying
        case committingReceipt = "committing_receipt"
    }

    public enum SchemeDeliveryResult: String, Codable, Sendable {
        case started
        case succeeded
        case failed
        case cancelled
    }

    public enum SchemeDeliveryFallbackReason: String, Codable, Sendable {
        case archiveSize = "archive_size"
        case archiveDigest = "archive_digest"
        case transport
    }

    public enum SchemeDeliveryTerminalResult: String, Codable, Sendable {
        case completed
        case failed
        case cancelled
    }

    /// Finite terminal classification for local diagnosis. It deliberately
    /// carries no raw NSError text, URL or file path.
    public enum SchemeDeliveryTerminalFailure: String, Codable, Sendable {
        case transport
        case allSourcesUnavailable = "all_sources_unavailable"
        case allSourcesArchiveSize = "all_sources_archive_size"
        case allSourcesArchiveDigest = "all_sources_archive_digest"
        case allSourcesMixedIntegrity = "all_sources_mixed_integrity"
        case archiveSize = "archive_size"
        case archiveDigest = "archive_digest"
        case stagedContent = "staged_content"
        case invalidManifest = "invalid_manifest"
        case temporaryArtifact = "temporary_artifact"
        case cleanup
        case extraction
        case postProcessing = "post_processing"
        case localIO = "local_io"
        case deployment
    }

    public struct SchemeDeliveryAttempt: Codable, Sendable, Equatable {
        public let value: Int

        public init?(_ value: Int) {
            guard (1...8).contains(value) else { return nil }
            self.value = value
        }

        public init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer().decode(Int.self)
            guard let validated = Self(value) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "attempt outside 1...8")
                )
            }
            self = validated
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    public struct DigestPrefix16: Codable, Sendable, Equatable {
        public let value: String

        public init?(fullDigest: String) {
            guard fullDigest.count == 64 else { return nil }
            self.init(rawValue: String(fullDigest.prefix(16)))
        }

        public init?(rawValue: String) {
            let allowed = CharacterSet(charactersIn: "0123456789abcdef")
            guard rawValue.count == 16,
                rawValue.unicodeScalars.allSatisfy(allowed.contains)
            else { return nil }
            value = rawValue
        }

        public init(from decoder: Decoder) throws {
            let value = try decoder.singleValueContainer().decode(String.self)
            guard let validated = Self(rawValue: value) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "invalid digest prefix")
                )
            }
            self = validated
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    public struct SchemeDeliveryContext: Codable, Sendable, Equatable {
        public let operationID: UUID
        public let artifact: SchemeArtifactIdentity
        public let stagedIdentity: SchemeStagedIdentity

        public init(
            operationID: UUID,
            artifact: SchemeArtifactIdentity,
            stagedIdentity: SchemeStagedIdentity
        ) {
            self.operationID = operationID
            self.artifact = artifact
            self.stagedIdentity = stagedIdentity
        }
    }

    public struct SchemeDeliveryPhaseEvent: Codable, Sendable, Equatable {
        public let context: SchemeDeliveryContext
        public let attempt: SchemeDeliveryAttempt?
        public let source: SchemeSource?
        public let host: SchemeHost?
        public let phase: SchemeDeliveryPhase
        public let result: SchemeDeliveryResult

        public init(
            context: SchemeDeliveryContext,
            attempt: SchemeDeliveryAttempt?,
            source: SchemeSource?,
            host: SchemeHost?,
            phase: SchemeDeliveryPhase,
            result: SchemeDeliveryResult
        ) {
            self.context = context
            self.attempt = attempt
            self.source = source
            self.host = host
            self.phase = phase
            self.result = result
        }
    }

    public enum SchemeIntegrityObservation: Codable, Sendable, Equatable {
        case archiveSize(expected: Int64, actual: Int64)
        case archiveDigest(expected: DigestPrefix16, actual: DigestPrefix16)
        case stagedContent(expected: DigestPrefix16, actual: DigestPrefix16)
    }

    public struct SchemeDeliveryIntegrityEvent: Codable, Sendable, Equatable {
        public let context: SchemeDeliveryContext
        public let attempt: SchemeDeliveryAttempt
        public let source: SchemeSource
        public let host: SchemeHost
        public let phase: SchemeDeliveryPhase
        public let observation: SchemeIntegrityObservation

        public init(
            context: SchemeDeliveryContext,
            attempt: SchemeDeliveryAttempt,
            source: SchemeSource,
            host: SchemeHost,
            observation: SchemeIntegrityObservation
        ) {
            self.context = context
            self.attempt = attempt
            self.source = source
            self.host = host
            switch observation {
            case .archiveSize: phase = .verifyingArchiveSize
            case .archiveDigest: phase = .verifyingArchiveDigest
            case .stagedContent: phase = .verifyingStagedContent
            }
            self.observation = observation
        }
    }

    public struct SchemeDeliveryFallbackEvent: Codable, Sendable, Equatable {
        public let context: SchemeDeliveryContext
        public let fromAttempt: SchemeDeliveryAttempt
        public let toAttempt: SchemeDeliveryAttempt
        public let from: SchemeSource
        public let to: SchemeSource
        public let fromHost: SchemeHost?
        public let toHost: SchemeHost?
        public let reason: SchemeDeliveryFallbackReason

        public init(
            context: SchemeDeliveryContext,
            fromAttempt: SchemeDeliveryAttempt,
            toAttempt: SchemeDeliveryAttempt,
            from: SchemeSource,
            to: SchemeSource,
            fromHost: SchemeHost?,
            toHost: SchemeHost?,
            reason: SchemeDeliveryFallbackReason
        ) {
            precondition(from != to, "fallback source must change")
            precondition(toAttempt.value > fromAttempt.value, "fallback attempt must advance")
            self.context = context
            self.fromAttempt = fromAttempt
            self.toAttempt = toAttempt
            self.from = from
            self.to = to
            self.fromHost = fromHost
            self.toHost = toHost
            self.reason = reason
        }
    }

    public struct SchemeDeliveryTerminalEvent: Codable, Sendable, Equatable {
        public let context: SchemeDeliveryContext
        public let result: SchemeDeliveryTerminalResult
        public let installed: Bool
        public let deployed: Bool
        public let failure: SchemeDeliveryTerminalFailure?

        public init(
            context: SchemeDeliveryContext,
            result: SchemeDeliveryTerminalResult,
            installed: Bool,
            deployed: Bool,
            failure: SchemeDeliveryTerminalFailure? = nil
        ) {
            precondition(!deployed || installed, "deployed delivery must also be installed")
            precondition(
                result != .completed || (installed && deployed),
                "completed delivery must be installed and deployed"
            )
            precondition(
                (result == .failed) == (failure != nil),
                "only failed delivery has a terminal failure classification"
            )
            self.context = context
            self.result = result
            self.installed = installed
            self.deployed = deployed
            self.failure = failure
        }

        public init(context: SchemeDeliveryContext, result: SchemeDeliveryTerminalResult) {
            switch result {
            case .completed:
                self.init(context: context, result: result, installed: true, deployed: true)
            case .cancelled:
                self.init(context: context, result: result, installed: false, deployed: false)
            case .failed:
                preconditionFailure("failed terminal event requires a classification")
            }
        }
    }

    public enum SchemeDeliveryPayload: Codable, Sendable, Equatable {
        case phaseChanged(SchemeDeliveryPhaseEvent)
        case integrityFailed(SchemeDeliveryIntegrityEvent)
        case fallback(SchemeDeliveryFallbackEvent)
        case terminal(SchemeDeliveryTerminalEvent)

        var code: Code {
            switch self {
            case .phaseChanged: .schemeDeliveryPhaseChanged
            case .integrityFailed: .schemeDeliveryIntegrityFailed
            case .fallback: .schemeDeliveryFallback
            case .terminal: .schemeDeliveryTerminal
            }
        }

        var isValid: Bool {
            switch self {
            case .phaseChanged(let event):
                switch event.phase {
                case .selecting:
                    // Selection starts without a source and completes with one,
                    // before an archive attempt exists.
                    return event.attempt == nil && event.host == nil
                        && ((event.result == .started && event.source == nil)
                            || (event.result == .succeeded && event.source != nil))
                case .downloading:
                    return event.attempt != nil && event.source != nil
                        && (event.result == .started || event.result == .succeeded)
                        && (event.result != .succeeded || event.host != nil)
                case .committingReceipt:
                    return event.attempt == nil && event.source == nil && event.host == nil
                        && (event.result == .started || event.result == .succeeded)
                case .verifyingArchiveSize, .verifyingArchiveDigest, .cleanup, .extracting,
                    .postProcessing, .verifyingStagedContent, .installing, .deploying:
                    return event.attempt != nil && event.source != nil && event.host != nil
                        && (event.result == .started || event.result == .succeeded)
                }
            case .integrityFailed:
                return true
            case .fallback(let event):
                return event.from != event.to && event.toAttempt.value > event.fromAttempt.value
            case .terminal(let event):
                return (!event.deployed || event.installed)
                    && (event.result != .completed || (event.installed && event.deployed))
                    && ((event.result == .failed) == (event.failure != nil))
            }
        }
    }

    public let schemaVersion: Int
    public let utcTimestamp: Date
    public let monotonicNanoseconds: UInt64
    public let origin: Origin
    public let processInstanceID: UUID
    public let localSequence: UInt64
    public let appearanceID: UUID?
    public let actionSequence: UInt64?
    public let code: Code
    public let level: Logger.Level
    public let category: Logger.Category
    public let fields: [Field]
    public let schemeDeliveryPayload: SchemeDeliveryPayload?
    public let rimeSyncPayload: RimeSyncPayload?

    public init(
        utcTimestamp: Date,
        monotonicNanoseconds: UInt64,
        origin: Origin,
        processInstanceID: UUID,
        localSequence: UInt64,
        appearanceID: UUID? = nil,
        actionSequence: UInt64? = nil,
        code: Code,
        level: Logger.Level,
        category: Logger.Category,
        fields: [Field] = [],
        schemeDeliveryPayload: SchemeDeliveryPayload? = nil,
        rimeSyncPayload: RimeSyncPayload? = nil
    ) {
        precondition(
            schemeDeliveryPayload?.code == code
                || (schemeDeliveryPayload == nil && !Self.schemeDeliveryCodes.contains(code)),
            "DiagnosticEvent code and scheme-delivery payload must match"
        )
        precondition(
            schemeDeliveryPayload == nil || (fields.isEmpty && schemeDeliveryPayload!.isValid),
            "Scheme-delivery payload must be valid and cannot use generic fields"
        )
        precondition(
            rimeSyncPayload?.code == code
                || (rimeSyncPayload == nil && !Self.rimeSyncCodes.contains(code)),
            "DiagnosticEvent code and RIME-sync payload must match"
        )
        precondition(
            rimeSyncPayload == nil || (fields.isEmpty && rimeSyncPayload!.isValid),
            "RIME-sync payload must be valid and cannot use generic fields"
        )
        precondition(
            schemeDeliveryPayload == nil || rimeSyncPayload == nil,
            "DiagnosticEvent cannot contain multiple composite payloads"
        )
        schemaVersion = Self.schemaVersion
        self.utcTimestamp = utcTimestamp
        self.monotonicNanoseconds = monotonicNanoseconds
        self.origin = origin
        self.processInstanceID = processInstanceID
        self.localSequence = localSequence
        self.appearanceID = appearanceID
        self.actionSequence = actionSequence
        self.code = code
        self.level = level
        self.category = category
        self.fields = fields
        self.schemeDeliveryPayload = schemeDeliveryPayload
        self.rimeSyncPayload = rimeSyncPayload
    }

    private static let schemeDeliveryCodes: Set<Code> = [
        .schemeDeliveryPhaseChanged,
        .schemeDeliveryIntegrityFailed,
        .schemeDeliveryFallback,
        .schemeDeliveryTerminal,
    ]

    private static let rimeSyncCodes: Set<Code> = [
        .rimeSyncInvoked,
        .rimeSyncPhaseChanged,
        .rimeSyncSkipped,
        .rimeSyncTerminal,
    ]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, utcTimestamp, monotonicNanoseconds, origin, processInstanceID
        case localSequence, appearanceID, actionSequence, code, level, category, fields
        case schemeDeliveryPayload, rimeSyncPayload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        utcTimestamp = try container.decode(Date.self, forKey: .utcTimestamp)
        monotonicNanoseconds = try container.decode(UInt64.self, forKey: .monotonicNanoseconds)
        origin = try container.decode(Origin.self, forKey: .origin)
        processInstanceID = try container.decode(UUID.self, forKey: .processInstanceID)
        localSequence = try container.decode(UInt64.self, forKey: .localSequence)
        appearanceID = try container.decodeIfPresent(UUID.self, forKey: .appearanceID)
        actionSequence = try container.decodeIfPresent(UInt64.self, forKey: .actionSequence)
        code = try container.decode(Code.self, forKey: .code)
        level = try container.decode(Logger.Level.self, forKey: .level)
        category = try container.decode(Logger.Category.self, forKey: .category)
        fields = try container.decode([Field].self, forKey: .fields)
        schemeDeliveryPayload = try container.decodeIfPresent(
            SchemeDeliveryPayload.self,
            forKey: .schemeDeliveryPayload
        )
        rimeSyncPayload = try container.decodeIfPresent(
            RimeSyncPayload.self,
            forKey: .rimeSyncPayload
        )
        guard
            schemeDeliveryPayload?.code == code
                || (schemeDeliveryPayload == nil && !Self.schemeDeliveryCodes.contains(code))
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemeDeliveryPayload,
                in: container,
                debugDescription: "DiagnosticEvent code and scheme-delivery payload do not match"
            )
        }
        guard schemeDeliveryPayload == nil || (fields.isEmpty && schemeDeliveryPayload!.isValid) else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemeDeliveryPayload,
                in: container,
                debugDescription: "Invalid scheme-delivery payload or forbidden generic fields"
            )
        }
        guard
            rimeSyncPayload?.code == code
                || (rimeSyncPayload == nil && !Self.rimeSyncCodes.contains(code))
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .rimeSyncPayload,
                in: container,
                debugDescription: "DiagnosticEvent code and RIME-sync payload do not match"
            )
        }
        guard rimeSyncPayload == nil || (fields.isEmpty && rimeSyncPayload!.isValid) else {
            throw DecodingError.dataCorruptedError(
                forKey: .rimeSyncPayload,
                in: container,
                debugDescription: "Invalid RIME-sync payload or forbidden generic fields"
            )
        }
        guard schemeDeliveryPayload == nil || rimeSyncPayload == nil else {
            throw DecodingError.dataCorruptedError(
                forKey: .rimeSyncPayload,
                in: container,
                debugDescription: "DiagnosticEvent contains multiple composite payloads"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(utcTimestamp, forKey: .utcTimestamp)
        try container.encode(monotonicNanoseconds, forKey: .monotonicNanoseconds)
        try container.encode(origin, forKey: .origin)
        try container.encode(processInstanceID, forKey: .processInstanceID)
        try container.encode(localSequence, forKey: .localSequence)
        try container.encodeIfPresent(appearanceID, forKey: .appearanceID)
        try container.encodeIfPresent(actionSequence, forKey: .actionSequence)
        try container.encode(code, forKey: .code)
        try container.encode(level, forKey: .level)
        try container.encode(category, forKey: .category)
        try container.encode(fields, forKey: .fields)
        try container.encodeIfPresent(schemeDeliveryPayload, forKey: .schemeDeliveryPayload)
        try container.encodeIfPresent(rimeSyncPayload, forKey: .rimeSyncPayload)
    }
}
