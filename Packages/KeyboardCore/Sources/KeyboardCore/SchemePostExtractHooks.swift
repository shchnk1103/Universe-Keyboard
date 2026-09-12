import Foundation

/// Ice-reference post-extract / pre-deploy T9 hook kind (P3).
///
/// Declares whether Download should run Ice T9 sanitize on extract and
/// `ensureCompatibleT9Schema` before deploy. Actual YAML rewrite stays in App
/// (`T9SchemaCompatibility` / `T9DeploymentSupport`) — this type only removes
/// literal `schemaID == "rime_ice"` branching from the production pipeline.
public enum SchemePostExtractHookKind: String, Sendable, Equatable {
    /// Ice today: sanitize `t9.schema.yaml` in the extract dir, then ensure a
    /// compatible T9 schema under shared data before deploy.
    case iceT9SanitizeAndPreDeploy
    /// No post-extract / pre-deploy T9 hooks (Wanxiang / Luna / unknown).
    case none
}

/// Declarative post-extract hook capability on a scheme adapter (P3).
public struct SchemePostExtractHooks: Sendable, Equatable {
    public let kind: SchemePostExtractHookKind

    public init(kind: SchemePostExtractHookKind) {
        self.kind = kind
    }

    public static let ice = SchemePostExtractHooks(kind: .iceT9SanitizeAndPreDeploy)
    public static let none = SchemePostExtractHooks(kind: .none)
}

extension SchemeAdapterRegistry {
    /// Post-extract hooks for known adapters (Ice T9 sanitize/pre-deploy only in P3).
    ///
    /// `t9` resolves to the Ice family (same as uninstall hooks) so alias lookups
    /// stay consistent; Download production paths still pass letter ids.
    public static func postExtractHooks(for schemaID: String) -> SchemePostExtractHooks {
        guard let adapter = adapter(for: schemaID) else { return .none }
        switch adapter.schemaID {
        case "rime_ice":
            return .ice
        default:
            return .none
        }
    }

    /// Whether Download should sanitize `t9.schema.yaml` after extract (Ice only).
    public static func shouldSanitizeT9OnExtract(for schemaID: String) -> Bool {
        postExtractHooks(for: schemaID).kind == .iceT9SanitizeAndPreDeploy
    }

    /// Whether Download should ensure a compatible T9 schema before deploy (Ice only).
    public static func shouldEnsureCompatibleT9PreDeploy(for schemaID: String) -> Bool {
        postExtractHooks(for: schemaID).kind == .iceT9SanitizeAndPreDeploy
    }
}
