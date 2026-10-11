#if DEBUG
    /// Finite observation of an existing correction session, never a session creator.
    public struct TypoCorrectionQueryDebugScope: Equatable, Sendable {
        public enum Schema: UInt64, Sendable { case unknown = 0, lunaPinyin = 1 }
        public let sessionOrdinal: UInt64
        public let schema: Schema
        public init(sessionOrdinal: UInt64, schema: Schema) {
            self.sessionOrdinal = sessionOrdinal
            self.schema = schema
        }
    }

    public protocol TypoCorrectionQueryDebugScoping: AnyObject {
        @MainActor func existingCorrectionQueryDebugScope() -> TypoCorrectionQueryDebugScope?
    }
#endif
