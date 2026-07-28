#if T9_AUTO_ANCHOR_DEVICE_PREFLIGHT
import Foundation

/// Content-free cross-process envelope used only by the S6-A internal build.
///
/// The serialized value is deliberately small and versioned so both the main
/// App and Keyboard Extension can fail closed on unknown state.
public enum T9DevicePreflightRun {
    public static let envelopeKey = "t9_s6a_run_envelope"
    public static let matrixRegistryKey = "t9_s6a_matrix_tokens"
    public static let tokenPrefix = "S6A-"
    private static let maximumMatrixTokenCount = 64

    public enum State: String, Sendable {
        case prepared
        case consumed
    }

    public struct Envelope: Equatable, Sendable {
        public let state: State
        public let token: String

        public init(state: State, token: String) {
            self.state = state
            self.token = token
        }

        public init?(serialized: String) {
            let fields = serialized.split(
                separator: "|",
                omittingEmptySubsequences: false
            )
            guard fields.count == 3,
                  fields[0] == "v1",
                  let state = State(rawValue: String(fields[1])),
                  T9DevicePreflightRun.isCanonicalToken(String(fields[2]))
            else {
                return nil
            }
            self.state = state
            token = String(fields[2])
        }

        public var serialized: String {
            "v1|\(state.rawValue)|\(token)"
        }
    }

    public struct Consumption: Equatable, Sendable {
        public let token: String
        public let consumedEnvelope: Envelope

        fileprivate init(token: String) {
            self.token = token
            consumedEnvelope = Envelope(state: .consumed, token: token)
        }
    }

    /// Bounded, content-free identity registry for the current physical matrix.
    ///
    /// It is not a transfer channel. Its only purpose is preventing reuse after
    /// an older arm has rolled out of the retained diagnostic log.
    public struct MatrixRegistry: Equatable, Sendable {
        public let tokens: [String]

        public init() {
            tokens = []
        }

        private init(tokens: [String]) {
            self.tokens = tokens
        }

        public init?(serialized: String) {
            let fields = serialized.split(
                separator: "|",
                omittingEmptySubsequences: false
            )
            guard fields.count == 2, fields[0] == "v1" else {
                return nil
            }
            let parsedTokens = fields[1].isEmpty
                ? []
                : fields[1].split(separator: ",").map(String.init)
            guard parsedTokens.count <= maximumMatrixTokenCount,
                  Set(parsedTokens).count == parsedTokens.count,
                  parsedTokens.allSatisfy(T9DevicePreflightRun.isCanonicalToken)
            else {
                return nil
            }
            tokens = parsedTokens
        }

        public var serialized: String {
            "v1|\(tokens.joined(separator: ","))"
        }

        public func appending(_ token: String) -> MatrixRegistry? {
            guard T9DevicePreflightRun.isCanonicalToken(token),
                  !tokens.contains(token),
                  tokens.count < maximumMatrixTokenCount
            else {
                return nil
            }
            return MatrixRegistry(tokens: tokens + [token])
        }
    }

    public static func makeToken() -> String {
        tokenPrefix
            + UUID().uuidString
                .replacingOccurrences(of: "-", with: "")
                .uppercased()
    }

    public static func isCanonicalToken(_ token: String) -> Bool {
        guard token.count == 36, token.hasPrefix(tokenPrefix) else {
            return false
        }
        let uppercaseHexCharacters = Set("0123456789ABCDEF")
        return token.dropFirst(tokenPrefix.count).allSatisfy(
            uppercaseHexCharacters.contains
        )
    }

    /// Produces a fresh prepared envelope or rejects stale/reused identity.
    ///
    /// A different existing token is treated as crash residue and may be
    /// replaced atomically by the caller. The same token may never resume.
    public static func makePreparedEnvelope(
        token: String,
        existingSerializedEnvelope: String?,
        retainedEvidence: String,
        currentMatrixTokens: Set<String>
    ) -> Envelope? {
        guard isCanonicalToken(token),
              !retainedEvidence.contains("run=\(token)"),
              !currentMatrixTokens.contains(token)
        else {
            return nil
        }
        if let existingSerializedEnvelope {
            guard let existing = Envelope(
                serialized: existingSerializedEnvelope
            ), existing.token != token else {
                return nil
            }
        }
        return Envelope(state: .prepared, token: token)
    }

    /// Consumes only a canonical prepared envelope. A reconstructed Extension
    /// therefore cannot resume a token already marked as consumed.
    public static func consumePreparedEnvelope(
        serialized: String?
    ) -> Consumption? {
        guard let serialized,
              let envelope = Envelope(serialized: serialized),
              envelope.state == .prepared
        else {
            return nil
        }
        return Consumption(token: envelope.token)
    }

    /// Cleanup is intentionally narrow: only the matching consumed token may
    /// be removed from the App Group.
    public static func canRemoveConsumedEnvelope(
        serialized: String?,
        token: String
    ) -> Bool {
        guard isCanonicalToken(token),
              let serialized,
              let envelope = Envelope(serialized: serialized)
        else {
            return false
        }
        return envelope.state == .consumed && envelope.token == token
    }
}
#endif
