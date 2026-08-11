import Foundation

/// 本地诊断 journal 的内容无关事件。
///
/// 这个类型是跨 target 的持久化协议，不接受自由文本。若需要新的诊断维度，
/// 必须先扩展下面的受控枚举并经过 ADR 0027 要求的字段审查。
public struct DiagnosticEvent: Codable, Sendable, Equatable {
    public static let schemaVersion = 1

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
    }

    public enum DurationMetric: String, Codable, CaseIterable, Sendable {
        case elapsedMilliseconds = "elapsed_ms"
        case presentationAgeMilliseconds = "presentation_age_ms"
    }

    public enum Flag: String, Codable, CaseIterable, Sendable {
        case isHighFidelityEnabled = "high_fidelity_enabled"
        case isCandidateBarVisible = "candidate_bar_visible"
        case isKeyHighlighted = "key_highlighted"
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
        fields: [Field] = []
    ) {
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
    }
}
