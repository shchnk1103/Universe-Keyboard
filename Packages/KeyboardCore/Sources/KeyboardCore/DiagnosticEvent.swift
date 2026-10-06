import Foundation

/// 本地诊断 journal 的内容无关事件。
///
/// 这个类型是跨 target 的持久化协议，不接受自由文本。若需要新的诊断维度，
/// 必须先扩展下面的受控枚举并经过 ADR 0027 要求的字段审查。
public struct DiagnosticEvent: Codable, Sendable, Equatable {
    public static let schemaVersion = 5

    // Reader compatibility is independent of the production writer. Never admit future versions
    // implicitly: each supported version must retain its own code/payload contract.
    static func supportsReading(schemaVersion: Int) -> Bool {
        [3, 4, 5, 6].contains(schemaVersion)
    }

    static func supportsWakeMarkers(schemaVersion: Int) -> Bool {
        schemaVersion == 4 || schemaVersion == 6
    }

    static func supportsTypoRecall(schemaVersion: Int) -> Bool {
        schemaVersion == 5 || schemaVersion == 6
    }

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
        case runtimeRoutePhaseChanged = "runtime_route.phase_changed"
        case rimeSyncInvoked = "rime_sync.invoked"
        case rimeSyncPhaseChanged = "rime_sync.phase_changed"
        case rimeSyncSkipped = "rime_sync.skipped"
        case rimeSyncTerminal = "rime_sync.terminal"
        /// INT-003: debounce work-item armed after eligibility (HF-gated).
        case typoRecallDebounceScheduled = "typo_recall.debounce_scheduled"
        /// INT-003: prior pending debounce cancelled on re-schedule or invalidate.
        case typoRecallDebounceCancelled = "typo_recall.debounce_cancelled"
        /// INT-003: hard invalidate bumped recallEpoch.
        case typoRecallEpochBumped = "typo_recall.epoch_bumped"
        /// INT-003: in-flight fence / yield / apply discarded as stale.
        case typoRecallFenceDiscarded = "typo_recall.fence_discarded"
        /// INT-003: contextual correction query about to run.
        case typoRecallQueryBegin = "typo_recall.query_begin"
        /// INT-003: contextual correction query finished with a finite Reason.
        case typoRecallQueryOutcome = "typo_recall.query_outcome"
        /// INT-003 P1: one content-free terminal measurement per facade invocation.
        case typoRecallQueryMeasured = "typo_recall.query_measured"
        case keyboardLifecyclePhaseChanged = "keyboard.lifecycle.phase_changed"
        case rimeResumePhaseChanged = "rime.resume.phase_changed"
        case textProxyOperationPhaseChanged = "text_proxy.operation_phase_changed"
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
        /// INT-003 query outcome: fence held and candidates returned.
        case typoRecallQuerySucceeded = "typo_recall_query_succeeded"
        /// INT-003 query outcome: fence mismatch / stale discard after query.
        case typoRecallQueryDiscarded = "typo_recall_query_discarded"
        /// INT-003 query outcome: operation cancelled before/during query.
        case typoRecallQueryCancelled = "typo_recall_query_cancelled"
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
        /// Typo-recall fence epoch (content-free).
        case recallEpoch = "recall_epoch"
        /// Typo-recall composition revision (content-free).
        case compositionRevision = "composition_revision"
        /// Typo-recall operation ordinal (content-free).
        case operationOrdinal = "operation_ordinal"
        /// Normalized composition length only — never the text itself.
        case compositionLength = "composition_length"
        /// FNV-1a 32-bit of normalized composition; correlation fingerprint only.
        case compositionFingerprint = "composition_fingerprint"
    }

    public enum DurationMetric: String, Codable, CaseIterable, Sendable {
        case elapsedMilliseconds = "elapsed_ms"
        case presentationAgeMilliseconds = "presentation_age_ms"
    }

    public enum TypoRecallCandidateBucket: String, Codable, CaseIterable, Sendable {
        case zero
        case oneToThree = "one_to_three"
        case notApplicable = "not_applicable"

        public static func classify(
            candidates: [RimeCandidate],
            resultState: TypoCorrectionQueryResultState
        ) -> Self {
            guard resultState == .candidatesReturned else { return .notApplicable }
            return candidates.prefix(TypoCorrectionRecallRuntimeBudget.candidateLimit).isEmpty
                ? .zero
                : .oneToThree
        }
    }

    public enum TypoRecallQueryDisposition: String, Codable, CaseIterable, Sendable {
        case applied
        case discardedAfterFacade = "discarded_after_facade"
    }

    public enum TypoRecallQueryDurationState: String, Codable, CaseIterable, Sendable {
        case measured
        case saturated
        case clockRegression = "clock_regression"
    }

    public enum KeyboardLifecyclePhase: String, Codable, CaseIterable, Sendable {
        case viewWillAppear = "view_will_appear"
        case viewDidAppear = "view_did_appear"
        case viewWillDisappear = "view_will_disappear"
        case hostWillResignActive = "host_will_resign_active"
        case hostDidBecomeActive = "host_did_become_active"
    }

    public struct KeyboardLifecyclePayload: Codable, Sendable, Equatable {
        public let phase: KeyboardLifecyclePhase

        public init(phase: KeyboardLifecyclePhase) {
            self.phase = phase
        }
    }

    public enum RimeResumePhase: String, Codable, CaseIterable, Sendable {
        case started
        case sessionCreated = "session_created"
        case schemaSelected = "schema_selected"
        case ownerReady = "owner_ready"
        case completed
        case failed
    }

    public enum RimeResumeFailure: String, Codable, CaseIterable, Sendable {
        case engineUnavailable = "engine_unavailable"
        case sessionCreationFailed = "session_creation_failed"
        case schemaSelectionFailed = "schema_selection_failed"
        case ownerNotReady = "owner_not_ready"
    }

    public struct RimeResumePayload: Codable, Sendable, Equatable {
        public let phase: RimeResumePhase
        public let failure: RimeResumeFailure?
        public let sessionEpoch: UInt64?
        public let revision: UInt64?

        public init(
            phase: RimeResumePhase,
            failure: RimeResumeFailure? = nil,
            sessionEpoch: UInt64? = nil,
            revision: UInt64? = nil
        ) {
            precondition((phase == .failed) == (failure != nil))
            self.phase = phase
            self.failure = failure
            self.sessionEpoch = sessionEpoch
            self.revision = revision
        }

        fileprivate var isValid: Bool {
            (phase == .failed) == (failure != nil)
        }
    }

    public enum TextProxyOperation: String, Codable, CaseIterable, Sendable {
        case setMarkedText = "set_marked_text"
        case insertText = "insert_text"
        case unmarkText = "unmark_text"
    }

    public enum TextProxyPhase: String, Codable, CaseIterable, Sendable {
        case entered
        case returned
    }

    public struct TextProxyPayload: Codable, Sendable, Equatable {
        public let operation: TextProxyOperation
        public let phase: TextProxyPhase

        public init(operation: TextProxyOperation, phase: TextProxyPhase) {
            self.operation = operation
            self.phase = phase
        }
    }

    /// Closed query metadata. This intentionally has no field for input, candidates,
    /// host content or a composition fingerprint.
    public struct TypoRecallQueryPayload: Codable, Sendable, Equatable {
        public let operationOrdinal: UInt64
        public let stage: TypoCorrectionRecallStage
        public let readiness: TypoCorrectionQueryReadiness
        public let resultState: TypoCorrectionQueryResultState
        public let returnedCandidateBucket: TypoRecallCandidateBucket
        public let disposition: TypoRecallQueryDisposition
        public let facadeElapsedMicroseconds: UInt32
        public let durationState: TypoRecallQueryDurationState

        public init(
            operationOrdinal: UInt64,
            stage: TypoCorrectionRecallStage,
            readiness: TypoCorrectionQueryReadiness,
            resultState: TypoCorrectionQueryResultState,
            returnedCandidateBucket: TypoRecallCandidateBucket,
            disposition: TypoRecallQueryDisposition,
            facadeElapsedMicroseconds: UInt32,
            durationState: TypoRecallQueryDurationState
        ) {
            precondition(
                Self.isValid(
                    readiness: readiness,
                    resultState: resultState,
                    returnedCandidateBucket: returnedCandidateBucket,
                    facadeElapsedMicroseconds: facadeElapsedMicroseconds,
                    durationState: durationState
                ),
                "Invalid typo-recall query measurement"
            )
            self.operationOrdinal = operationOrdinal
            self.stage = stage
            self.readiness = readiness
            self.resultState = resultState
            self.returnedCandidateBucket = returnedCandidateBucket
            self.disposition = disposition
            self.facadeElapsedMicroseconds = facadeElapsedMicroseconds
            self.durationState = durationState
        }

        private enum CodingKeys: String, CodingKey {
            case operationOrdinal, stage, readiness, resultState
            case returnedCandidateBucket, disposition, facadeElapsedMicroseconds, durationState
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let operationOrdinal = try container.decode(UInt64.self, forKey: .operationOrdinal)
            let stage = try container.decode(TypoCorrectionRecallStage.self, forKey: .stage)
            let readiness = try container.decode(
                TypoCorrectionQueryReadiness.self,
                forKey: .readiness
            )
            let resultState = try container.decode(
                TypoCorrectionQueryResultState.self,
                forKey: .resultState
            )
            let bucket = try container.decode(
                TypoRecallCandidateBucket.self,
                forKey: .returnedCandidateBucket
            )
            let disposition = try container.decode(
                TypoRecallQueryDisposition.self,
                forKey: .disposition
            )
            let elapsed = try container.decode(UInt32.self, forKey: .facadeElapsedMicroseconds)
            let durationState = try container.decode(
                TypoRecallQueryDurationState.self,
                forKey: .durationState
            )
            guard
                Self.isValid(
                    readiness: readiness,
                    resultState: resultState,
                    returnedCandidateBucket: bucket,
                    facadeElapsedMicroseconds: elapsed,
                    durationState: durationState
                )
            else {
                throw DecodingError.dataCorruptedError(
                    forKey: .resultState,
                    in: container,
                    debugDescription: "Invalid typo-recall query measurement"
                )
            }
            self.operationOrdinal = operationOrdinal
            self.stage = stage
            self.readiness = readiness
            self.resultState = resultState
            returnedCandidateBucket = bucket
            self.disposition = disposition
            facadeElapsedMicroseconds = elapsed
            self.durationState = durationState
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(operationOrdinal, forKey: .operationOrdinal)
            try container.encode(stage, forKey: .stage)
            try container.encode(readiness, forKey: .readiness)
            try container.encode(resultState, forKey: .resultState)
            try container.encode(returnedCandidateBucket, forKey: .returnedCandidateBucket)
            try container.encode(disposition, forKey: .disposition)
            try container.encode(facadeElapsedMicroseconds, forKey: .facadeElapsedMicroseconds)
            try container.encode(durationState, forKey: .durationState)
        }

        private static func isValid(
            readiness: TypoCorrectionQueryReadiness,
            resultState: TypoCorrectionQueryResultState,
            returnedCandidateBucket: TypoRecallCandidateBucket,
            facadeElapsedMicroseconds: UInt32,
            durationState: TypoRecallQueryDurationState
        ) -> Bool {
            let resultIsValid: Bool
            switch resultState {
            case .candidatesReturned:
                resultIsValid =
                    (readiness == .ready || readiness == .unknown)
                    && (returnedCandidateBucket == .zero || returnedCandidateBucket == .oneToThree)
            case .sidecarUnavailable:
                resultIsValid =
                    readiness == .unavailable
                    && returnedCandidateBucket == .notApplicable
            case .contextUnavailable:
                resultIsValid =
                    readiness == .ready
                    && returnedCandidateBucket == .notApplicable
            case .emptyInput, .zeroLimit:
                resultIsValid =
                    readiness == .unknown
                    && returnedCandidateBucket == .notApplicable
            }
            guard resultIsValid else { return false }
            switch durationState {
            case .measured:
                return true
            case .saturated:
                return facadeElapsedMicroseconds == UInt32.max
            case .clockRegression:
                return facadeElapsedMicroseconds == 0
            }
        }
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
        case typoRecallQuery(TypoRecallQueryPayload)

        private enum CodingKeys: String, CodingKey {
            case type
            case name
            case integerValue
            case booleanValue
            case reason
            case typoRecallQuery
        }

        private enum Kind: String, Codable {
            case count
            case duration
            case flag
            case reason
            case typoRecallQuery
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
            case .typoRecallQuery:
                self = .typoRecallQuery(
                    try container.decode(TypoRecallQueryPayload.self, forKey: .typoRecallQuery)
                )
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
            case let .typoRecallQuery(payload):
                try container.encode(Kind.typoRecallQuery, forKey: .type)
                try container.encode(payload, forKey: .typoRecallQuery)
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
        case keychainAccessDenied = "keychain_access_denied"
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
        case rimeIce20260630675D23B0 = "rime_ice_20260630_675d23b0"
        case rimeIceNightlyF60AA4F3 = "rime_ice_nightly_f60aa4f3"
        case wanxiang1759CNB9BFCGitHub73F8 = "wanxiang_17_5_9_cnb9bfc_github73f8"
    }

    public enum SchemeStagedIdentity: String, Codable, Sendable {
        case rimeIce20260630Plan1Post1 = "rime_ice_20260630_plan1_post1"
        case rimeIce20260630Plan2Post2 = "rime_ice_20260630_plan2_post2"
        case rimeIceNightlyPlan1Post1 = "rime_ice_nightly_plan1_post1"
        case wanxiang1759Plan1Post1 = "wanxiang_17_5_9_plan1_post1"
        case wanxiang1759Plan2Post2 = "wanxiang_17_5_9_plan2_post2"
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

    /// Content-free route reconciliation phases owned by the Main App.
    public enum RuntimeRoutePhase: String, Codable, Sendable {
        case before
        case reconciliation
        case fallbackDeploy = "fallback_deploy"
        case staging
        case commit
        case rollbackDeploy = "rollback_deploy"
        case inactive
    }

    public enum RuntimeRouteResult: String, Codable, Sendable {
        case started
        case succeeded
        case failed
        case skipped
        case recoveryIncomplete = "recovery_incomplete"
    }

    public enum RuntimeRouteSchema: String, Codable, Sendable {
        case lunaPinyin = "luna_pinyin"
        case rimeIce = "rime_ice"
        case wanxiang
        case t9
    }

    public enum RuntimeRouteLayout: String, Codable, Sendable {
        case twentySixKey = "26_key"
        case nineKey = "9_key"
    }

    public enum RuntimeRouteState: String, Codable, Sendable {
        case ready
        case failClosed = "fail_closed"
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
        case sourceArtifactChanged = "source_artifact_changed"
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

    /// Bounded probe metadata only: never include a raw URL, error string or input text.
    public enum SchemeSourceProbeFailure: String, Codable, Sendable {
        case transport
        case nonHTTP = "non_http"
        case httpStatus = "http_status"
        case redirectHost = "redirect_host"
        case archiveSize = "archive_size"
    }

    public struct SchemeDeliveryPhaseEvent: Codable, Sendable, Equatable {
        public let context: SchemeDeliveryContext
        public let attempt: SchemeDeliveryAttempt?
        public let source: SchemeSource?
        public let host: SchemeHost?
        public let phase: SchemeDeliveryPhase
        public let result: SchemeDeliveryResult
        public let probeFailure: SchemeSourceProbeFailure?

        public init(
            context: SchemeDeliveryContext,
            attempt: SchemeDeliveryAttempt?,
            source: SchemeSource?,
            host: SchemeHost?,
            phase: SchemeDeliveryPhase,
            result: SchemeDeliveryResult,
            probeFailure: SchemeSourceProbeFailure? = nil
        ) {
            self.context = context
            self.attempt = attempt
            self.source = source
            self.host = host
            self.phase = phase
            self.result = result
            self.probeFailure = probeFailure
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
                guard event.probeFailure == nil || (event.phase == .selecting && event.result == .failed) else {
                    return false
                }
                switch event.phase {
                case .selecting:
                    // Selection starts without a source and completes with one,
                    // before an archive attempt exists.
                    return event.attempt == nil && event.host == nil
                        && ((event.result == .started && event.source == nil)
                            || (event.result == .succeeded && event.source != nil)
                            || (event.result == .failed && event.source != nil && event.probeFailure != nil))
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

    public struct RuntimeRoutePhaseEvent: Codable, Sendable, Equatable {
        public let operationID: UUID
        public let phase: RuntimeRoutePhase
        public let result: RuntimeRouteResult
        public let schema: RuntimeRouteSchema
        public let layout: RuntimeRouteLayout
        public let state: RuntimeRouteState
        /// Monotonic elapsed time since the owning uninstall operation began.
        /// It contains no user content and is bounded at construction.
        public let elapsedMilliseconds: Int

        public init(
            operationID: UUID,
            phase: RuntimeRoutePhase,
            result: RuntimeRouteResult,
            schema: RuntimeRouteSchema,
            layout: RuntimeRouteLayout,
            state: RuntimeRouteState,
            elapsedMilliseconds: Int = 0
        ) {
            precondition((0...600_000).contains(elapsedMilliseconds))
            self.operationID = operationID
            self.phase = phase
            self.result = result
            self.schema = schema
            self.layout = layout
            self.state = state
            self.elapsedMilliseconds = elapsedMilliseconds
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
    public let runtimeRoutePayload: RuntimeRoutePhaseEvent?
    public let rimeSyncPayload: RimeSyncPayload?
    public let keyboardLifecyclePayload: KeyboardLifecyclePayload?
    public let rimeResumePayload: RimeResumePayload?
    public let textProxyPayload: TextProxyPayload?

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
        runtimeRoutePayload: RuntimeRoutePhaseEvent? = nil,
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
            runtimeRoutePayload == nil || (code == .runtimeRoutePhaseChanged && fields.isEmpty),
            "DiagnosticEvent code and runtime-route payload must match"
        )
        precondition(
            [schemeDeliveryPayload != nil, runtimeRoutePayload != nil, rimeSyncPayload != nil]
                .filter { $0 }.count <= 1,
            "DiagnosticEvent cannot contain multiple composite payloads"
        )
        precondition(
            !Self.v4OnlyCodes.contains(code),
            "Wake diagnostic marker codes are reader-only in the v5 candidate"
        )
        precondition(
            Self.isValidTypoRecallQuery(code: code, schemaVersion: Self.schemaVersion, fields: fields),
            "Typo-recall query measurement requires one schema-v5 typed field"
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
        self.runtimeRoutePayload = runtimeRoutePayload
        self.rimeSyncPayload = rimeSyncPayload
        keyboardLifecyclePayload = nil
        rimeResumePayload = nil
        textProxyPayload = nil
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
    private static let runtimeRouteCodes: Set<Code> = [.runtimeRoutePhaseChanged]
    fileprivate static let v4OnlyCodes: Set<Code> = [
        .keyboardLifecyclePhaseChanged,
        .rimeResumePhaseChanged,
        .textProxyOperationPhaseChanged,
    ]

    static func isWakeMarkerCode(_ code: Code) -> Bool {
        v4OnlyCodes.contains(code)
    }
    fileprivate static let v5OnlyCodes: Set<Code> = [
        .typoRecallDebounceScheduled,
        .typoRecallDebounceCancelled,
        .typoRecallEpochBumped,
        .typoRecallFenceDiscarded,
        .typoRecallQueryBegin,
        .typoRecallQueryOutcome,
        .typoRecallQueryMeasured,
    ]
    private static let v5OnlyReasons: Set<Reason> = [
        .typoRecallQuerySucceeded,
        .typoRecallQueryDiscarded,
        .typoRecallQueryCancelled,
    ]
    private static let v5OnlyCountMetrics: Set<CountMetric> = [
        .recallEpoch,
        .compositionRevision,
        .operationOrdinal,
        .compositionLength,
        .compositionFingerprint,
    ]
    var isWritableV5: Bool {
        schemaVersion == Self.schemaVersion
            && !Self.v4OnlyCodes.contains(code)
            && keyboardLifecyclePayload == nil
            && rimeResumePayload == nil
            && textProxyPayload == nil
    }

    /// Normalizes only new records. Retained v3/v4 events stay readable but cannot be
    /// relabeled by a writer; v5 ordinary events may be explicitly promoted to v6.
    func normalizedForWriting(
        as writerVersion: DiagnosticsJournalWriterVersion,
        origin expectedOrigin: Origin,
        processInstanceID expectedProcessInstanceID: UUID
    ) -> DiagnosticEvent? {
        guard origin == expectedOrigin else { return nil }

        switch writerVersion {
        case .v5:
            guard isWritableV5 else { return nil }
        case .v6:
            guard schemaVersion == 5 || schemaVersion == 6 else { return nil }
            if hasWakeMarkerData {
                guard isValidV6WakeMarker else { return nil }
            }
        }

        return DiagnosticEvent(
            schemaVersion: writerVersion.rawValue,
            copying: self,
            origin: expectedOrigin,
            processInstanceID: expectedProcessInstanceID
        )
    }

    private var hasWakeMarkerData: Bool {
        Self.isWakeMarkerCode(code)
            || keyboardLifecyclePayload != nil
            || rimeResumePayload != nil
            || textProxyPayload != nil
    }

    private var isValidV6WakeMarker: Bool {
        guard
            schemaVersion == 6,
            origin == .keyboardExtension,
            level == .debug,
            fields.isEmpty,
            [
                keyboardLifecyclePayload != nil,
                rimeResumePayload != nil,
                textProxyPayload != nil,
            ].filter({ $0 }).count == 1,
            schemeDeliveryPayload == nil,
            runtimeRoutePayload == nil,
            rimeSyncPayload == nil
        else { return false }

        if keyboardLifecyclePayload != nil {
            return code == .keyboardLifecyclePhaseChanged && category == .display
        }
        if let rimeResumePayload {
            return code == .rimeResumePhaseChanged
                && category == .engine
                && rimeResumePayload.isValid
        }
        if textProxyPayload != nil {
            return code == .textProxyOperationPhaseChanged && category == .display
        }
        return false
    }

    static func makeV6KeyboardLifecycleEvent(
        phase: KeyboardLifecyclePhase,
        utcTimestamp: Date,
        monotonicNanoseconds: UInt64,
        origin: Origin,
        processInstanceID: UUID,
        localSequence: UInt64,
        appearanceID: UUID?
    ) -> DiagnosticEvent? {
        guard origin == .keyboardExtension else { return nil }
        return DiagnosticEvent(
            schemaVersion: 6,
            utcTimestamp: utcTimestamp,
            monotonicNanoseconds: monotonicNanoseconds,
            origin: origin,
            processInstanceID: processInstanceID,
            localSequence: localSequence,
            appearanceID: appearanceID,
            actionSequence: nil,
            code: .keyboardLifecyclePhaseChanged,
            level: .debug,
            category: .display,
            fields: [],
            schemeDeliveryPayload: nil,
            runtimeRoutePayload: nil,
            rimeSyncPayload: nil,
            keyboardLifecyclePayload: KeyboardLifecyclePayload(phase: phase),
            rimeResumePayload: nil,
            textProxyPayload: nil
        )
    }

    static func makeV6RimeResumeEvent(
        phase: RimeResumePhase,
        failure: RimeResumeFailure?,
        sessionEpoch: UInt64?,
        revision: UInt64?,
        utcTimestamp: Date,
        monotonicNanoseconds: UInt64,
        origin: Origin,
        processInstanceID: UUID,
        localSequence: UInt64,
        appearanceID: UUID?
    ) -> DiagnosticEvent? {
        guard origin == .keyboardExtension, (phase == .failed) == (failure != nil) else { return nil }
        return DiagnosticEvent(
            schemaVersion: 6,
            utcTimestamp: utcTimestamp,
            monotonicNanoseconds: monotonicNanoseconds,
            origin: origin,
            processInstanceID: processInstanceID,
            localSequence: localSequence,
            appearanceID: appearanceID,
            actionSequence: nil,
            code: .rimeResumePhaseChanged,
            level: .debug,
            category: .engine,
            fields: [],
            schemeDeliveryPayload: nil,
            runtimeRoutePayload: nil,
            rimeSyncPayload: nil,
            keyboardLifecyclePayload: nil,
            rimeResumePayload: RimeResumePayload(
                phase: phase,
                failure: failure,
                sessionEpoch: sessionEpoch,
                revision: revision
            ),
            textProxyPayload: nil
        )
    }

    static func makeV6TextProxyEvent(
        operation: TextProxyOperation,
        phase: TextProxyPhase,
        actionSequence: UInt64?,
        utcTimestamp: Date,
        monotonicNanoseconds: UInt64,
        origin: Origin,
        processInstanceID: UUID,
        localSequence: UInt64,
        appearanceID: UUID?
    ) -> DiagnosticEvent? {
        guard origin == .keyboardExtension else { return nil }
        return DiagnosticEvent(
            schemaVersion: 6,
            utcTimestamp: utcTimestamp,
            monotonicNanoseconds: monotonicNanoseconds,
            origin: origin,
            processInstanceID: processInstanceID,
            localSequence: localSequence,
            appearanceID: appearanceID,
            actionSequence: actionSequence,
            code: .textProxyOperationPhaseChanged,
            level: .debug,
            category: .display,
            fields: [],
            schemeDeliveryPayload: nil,
            runtimeRoutePayload: nil,
            rimeSyncPayload: nil,
            keyboardLifecyclePayload: nil,
            rimeResumePayload: nil,
            textProxyPayload: TextProxyPayload(operation: operation, phase: phase)
        )
    }

    private init(
        schemaVersion: Int,
        copying event: DiagnosticEvent,
        origin: Origin,
        processInstanceID: UUID
    ) {
        self.schemaVersion = schemaVersion
        utcTimestamp = event.utcTimestamp
        monotonicNanoseconds = event.monotonicNanoseconds
        self.origin = origin
        self.processInstanceID = processInstanceID
        localSequence = event.localSequence
        appearanceID = event.appearanceID
        actionSequence = event.actionSequence
        code = event.code
        level = event.level
        category = event.category
        fields = event.fields
        schemeDeliveryPayload = event.schemeDeliveryPayload
        runtimeRoutePayload = event.runtimeRoutePayload
        rimeSyncPayload = event.rimeSyncPayload
        keyboardLifecyclePayload = event.keyboardLifecyclePayload
        rimeResumePayload = event.rimeResumePayload
        textProxyPayload = event.textProxyPayload
    }

    private init(
        schemaVersion: Int,
        utcTimestamp: Date,
        monotonicNanoseconds: UInt64,
        origin: Origin,
        processInstanceID: UUID,
        localSequence: UInt64,
        appearanceID: UUID?,
        actionSequence: UInt64?,
        code: Code,
        level: Logger.Level,
        category: Logger.Category,
        fields: [Field],
        schemeDeliveryPayload: SchemeDeliveryPayload?,
        runtimeRoutePayload: RuntimeRoutePhaseEvent?,
        rimeSyncPayload: RimeSyncPayload?,
        keyboardLifecyclePayload: KeyboardLifecyclePayload?,
        rimeResumePayload: RimeResumePayload?,
        textProxyPayload: TextProxyPayload?
    ) {
        self.schemaVersion = schemaVersion
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
        self.runtimeRoutePayload = runtimeRoutePayload
        self.rimeSyncPayload = rimeSyncPayload
        self.keyboardLifecyclePayload = keyboardLifecyclePayload
        self.rimeResumePayload = rimeResumePayload
        self.textProxyPayload = textProxyPayload
    }

    private static func isValidTypoRecallQuery(
        code: Code,
        schemaVersion: Int,
        fields: [Field]
    ) -> Bool {
        let queryFields = fields.filter {
            if case .typoRecallQuery = $0 { return true }
            return false
        }
        if code == .typoRecallQueryMeasured {
            guard Self.supportsTypoRecall(schemaVersion: schemaVersion), fields.count == 1 else { return false }
            if case .typoRecallQuery = fields[0] { return true }
            return false
        }
        return queryFields.isEmpty
    }

    private static func isLegacyCompatibleField(_ field: Field) -> Bool {
        switch field {
        case .count(let name, _):
            return !v5OnlyCountMetrics.contains(name)
        case .reason(let reason):
            return !v5OnlyReasons.contains(reason)
        case .typoRecallQuery:
            return false
        case .duration, .flag:
            return true
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, utcTimestamp, monotonicNanoseconds, origin, processInstanceID
        case localSequence, appearanceID, actionSequence, code, level, category, fields
        case schemeDeliveryPayload, runtimeRoutePayload, rimeSyncPayload
        case keyboardLifecyclePayload, rimeResumePayload, textProxyPayload
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        guard Self.supportsReading(schemaVersion: schemaVersion) else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported diagnostic schema version"
            )
        }
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
        runtimeRoutePayload = try container.decodeIfPresent(
            RuntimeRoutePhaseEvent.self,
            forKey: .runtimeRoutePayload
        )
        rimeSyncPayload = try container.decodeIfPresent(
            RimeSyncPayload.self,
            forKey: .rimeSyncPayload
        )
        keyboardLifecyclePayload = try container.decodeIfPresent(
            KeyboardLifecyclePayload.self,
            forKey: .keyboardLifecyclePayload
        )
        rimeResumePayload = try container.decodeIfPresent(
            RimeResumePayload.self,
            forKey: .rimeResumePayload
        )
        textProxyPayload = try container.decodeIfPresent(
            TextProxyPayload.self,
            forKey: .textProxyPayload
        )
        let containsV4OnlyKey = [
            CodingKeys.keyboardLifecyclePayload,
            .rimeResumePayload,
            .textProxyPayload,
        ].contains(where: container.contains)
        guard
            Self.supportsWakeMarkers(schemaVersion: schemaVersion)
                || (!Self.v4OnlyCodes.contains(code) && !containsV4OnlyKey)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Wake marker data requires schema v4 or v6"
            )
        }
        guard
            Self.supportsTypoRecall(schemaVersion: schemaVersion)
                || !Self.v5OnlyCodes.contains(code)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "v5-only diagnostic code cannot be labeled as an older schema"
            )
        }
        guard
            Self.supportsTypoRecall(schemaVersion: schemaVersion)
                || fields.allSatisfy(Self.isLegacyCompatibleField)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .fields,
                in: container,
                debugDescription: "v5-only diagnostic field cannot be labeled as an older schema"
            )
        }
        guard
            keyboardLifecyclePayload != nil
                ? (code == .keyboardLifecyclePhaseChanged && Self.supportsWakeMarkers(schemaVersion: schemaVersion))
                : code != .keyboardLifecyclePhaseChanged
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .keyboardLifecyclePayload,
                in: container,
                debugDescription: "Keyboard lifecycle code and payload do not match"
            )
        }
        guard
            rimeResumePayload != nil
                ? (code == .rimeResumePhaseChanged && Self.supportsWakeMarkers(schemaVersion: schemaVersion))
                : code != .rimeResumePhaseChanged
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .rimeResumePayload,
                in: container,
                debugDescription: "RIME resume code and payload do not match"
            )
        }
        guard
            textProxyPayload != nil
                ? (code == .textProxyOperationPhaseChanged && Self.supportsWakeMarkers(schemaVersion: schemaVersion))
                : code != .textProxyOperationPhaseChanged
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .textProxyPayload,
                in: container,
                debugDescription: "Text proxy code and payload do not match"
            )
        }
        guard
            [
                keyboardLifecyclePayload != nil,
                rimeResumePayload != nil,
                textProxyPayload != nil,
            ].filter({ $0 }).count <= 1,
            keyboardLifecyclePayload == nil || fields.isEmpty,
            rimeResumePayload.map({ fields.isEmpty && $0.isValid }) ?? true,
            textProxyPayload == nil || fields.isEmpty
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .keyboardLifecyclePayload,
                in: container,
                debugDescription: "Invalid wake marker payload pairing or generic fields"
            )
        }
        if keyboardLifecyclePayload != nil {
            guard origin == .keyboardExtension, level == .debug, category == .display else {
                throw DecodingError.dataCorruptedError(
                    forKey: .keyboardLifecyclePayload,
                    in: container,
                    debugDescription: "Invalid keyboard lifecycle event envelope"
                )
            }
        }
        if rimeResumePayload != nil {
            guard origin == .keyboardExtension, level == .debug, category == .engine else {
                throw DecodingError.dataCorruptedError(
                    forKey: .rimeResumePayload,
                    in: container,
                    debugDescription: "Invalid RIME resume event envelope"
                )
            }
        }
        if textProxyPayload != nil {
            guard origin == .keyboardExtension, level == .debug, category == .display else {
                throw DecodingError.dataCorruptedError(
                    forKey: .textProxyPayload,
                    in: container,
                    debugDescription: "Invalid text proxy event envelope"
                )
            }
        }
        guard Self.isValidTypoRecallQuery(code: code, schemaVersion: schemaVersion, fields: fields)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .fields,
                in: container,
                debugDescription: "Invalid typo-recall query code, schema or typed fields"
            )
        }
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
            runtimeRoutePayload != nil
                ? (code == .runtimeRoutePhaseChanged && fields.isEmpty)
                : !Self.runtimeRouteCodes.contains(code)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .runtimeRoutePayload,
                in: container,
                debugDescription: "DiagnosticEvent code and runtime-route payload do not match"
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
        guard
            [schemeDeliveryPayload != nil, runtimeRoutePayload != nil, rimeSyncPayload != nil]
                .filter({ $0 }).count <= 1
        else {
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
        try container.encodeIfPresent(runtimeRoutePayload, forKey: .runtimeRoutePayload)
        try container.encodeIfPresent(rimeSyncPayload, forKey: .rimeSyncPayload)
        try container.encodeIfPresent(keyboardLifecyclePayload, forKey: .keyboardLifecyclePayload)
        try container.encodeIfPresent(rimeResumePayload, forKey: .rimeResumePayload)
        try container.encodeIfPresent(textProxyPayload, forKey: .textProxyPayload)
    }
}
