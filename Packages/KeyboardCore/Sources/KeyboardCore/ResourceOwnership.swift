import CryptoKit
import Foundation

/// Declarative ResourceCapability for lua / opencc / dicts ownership (P1-4).
///
/// OpenCC: Wanxiang may keep `admitted=false` while still using the same API.
public struct SchemeResourceCapability: Sendable, Equatable {
    public let ownershipStrategyID: SchemeOwnershipStrategyID
    /// Whether OpenCC paths may be admitted via ownership strategies.
    /// Ice namedList admits plan OpenCC paths; Wanxiang exactHash keeps false.
    public let admitsOpenCC: Bool

    public init(ownershipStrategyID: SchemeOwnershipStrategyID, admitsOpenCC: Bool) {
        self.ownershipStrategyID = ownershipStrategyID
        self.admitsOpenCC = admitsOpenCC
    }
}

/// How an owned path was matched under preserve rules.
public enum SchemeOwnershipMatch: Sendable, Equatable {
    /// Ice reference / plan removable named paths (and directory-owned dicts).
    case namedList
    /// Wanxiang exact content hash (pin-bound).
    case exactHash(String)
    /// Directory-owned under plan (e.g. `cn_dicts/` / `dicts/`) — not whole lua/opencc.
    case directoryOwned
}

public struct OwnedResourcePath: Sendable, Equatable {
    public let relativePath: String
    public let match: SchemeOwnershipMatch

    public init(relativePath: String, match: SchemeOwnershipMatch) {
        self.relativePath = relativePath
        self.match = match
    }
}

/// Minimal installation-plan view for ownership strategies (App plans adapt in).
public struct SchemeOwnershipPlanView: Sendable, Equatable {
    public let schemaFileName: String
    public let revision: String
    public let removableFiles: [String]
    public let removableDirectories: [String]

    public init(
        schemaFileName: String,
        revision: String,
        removableFiles: [String],
        removableDirectories: [String]
    ) {
        self.schemaFileName = schemaFileName
        self.revision = revision
        self.removableFiles = removableFiles
        self.removableDirectories = removableDirectories
    }
}

/// Unified ResourceOwnership strategy API (long-term dual: namedList + exactHash).
public protocol ResourceOwnershipStrategy: Sendable {
    var strategyID: SchemeOwnershipStrategyID { get }

    /// Paths eligible for uninstall / upgrade-checkpoint capture under preserve rules.
    /// Never whole-dir wipe of `lua/` / `opencc/`; no filename-heuristic auto-remove.
    func ownedPaths(
        sharedRoot: URL,
        plan: SchemeOwnershipPlanView,
        fileManager: FileManager
    ) throws -> [OwnedResourcePath]
}

/// Ice reference — plan `removableFiles` / `removableDirectories` as named list.
public struct NamedListResourceOwnershipStrategy: ResourceOwnershipStrategy {
    public static let shared = NamedListResourceOwnershipStrategy()

    public let strategyID: SchemeOwnershipStrategyID = .namedList

    public init() {}

    public func ownedPaths(
        sharedRoot: URL,
        plan: SchemeOwnershipPlanView,
        fileManager: FileManager
    ) throws -> [OwnedResourcePath] {
        _ = sharedRoot
        _ = fileManager
        let candidates = plan.removableDirectories + plan.removableFiles
        let relativePaths = candidates.filter { path in
            !candidates.contains { other in
                other != path && path.hasPrefix(other + "/")
            }
        }
        return relativePaths.map { path in
            let match: SchemeOwnershipMatch =
                plan.removableDirectories.contains(path) ? .directoryOwned : .namedList
            return OwnedResourcePath(relativePath: path, match: match)
        }
    }
}

/// Wanxiang exact-hash lua ownership for the pinned 17.5.9 CNB archive.
///
/// Source bytes are not changed by the Wanxiang post-processor. Unknown or
/// edited files remain untouched; this is not a general ownership receipt.
/// OpenCC stays `admitted=false` (no paths here).
public struct ExactHashResourceOwnershipStrategy: ResourceOwnershipStrategy {
    /// Bounded cleanup for SHA-256
    /// 9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732.
    public static let wanxiangPinnedArchive = ExactHashResourceOwnershipStrategy(
        expectedSchemaFileName: "wanxiang.schema.yaml",
        expectedRevision: "wanxiang-plan-1",
        sha256ByPath: WanxiangExactHashOwnership.sha256ByPath
    )

    public let strategyID: SchemeOwnershipStrategyID = .exactHash
    public let expectedSchemaFileName: String
    public let expectedRevision: String
    public let sha256ByPath: [String: String]

    public init(
        expectedSchemaFileName: String,
        expectedRevision: String,
        sha256ByPath: [String: String]
    ) {
        self.expectedSchemaFileName = expectedSchemaFileName
        self.expectedRevision = expectedRevision
        self.sha256ByPath = sha256ByPath
    }

    public func ownedPaths(
        sharedRoot: URL,
        plan: SchemeOwnershipPlanView,
        fileManager: FileManager
    ) throws -> [OwnedResourcePath] {
        // Thin plan-identity bridge (P1). P2 may drop schemaFileName/revision
        // special-case once Wanxiang is fully on the platform path.
        guard plan.schemaFileName == expectedSchemaFileName,
            plan.revision == expectedRevision
        else {
            return []
        }

        var matched: [OwnedResourcePath] = []
        for path in sha256ByPath.keys.sorted() {
            let url = sharedRoot.appendingPathComponent(path)
            guard fileManager.fileExists(atPath: url.path) else { continue }
            // Do not follow a user-created link out of the owned resource tree.
            guard url.resolvingSymlinksInPath().path == url.standardizedFileURL.path else {
                continue
            }
            let digest = SHA256.hash(data: try Data(contentsOf: url))
                .map { String(format: "%02x", $0) }.joined()
            if digest == sha256ByPath[path] {
                matched.append(OwnedResourcePath(relativePath: path, match: .exactHash(digest)))
            }
        }
        return matched
    }
}

/// Pin-bound Wanxiang lua exact-hash map (moved from App `WanxiangLuaOwnership`).
public enum WanxiangExactHashOwnership {
    public static let sha256ByPath: [String: String] = [
        "lua/data/HKVariants.txt": "b7e17af05b30fcd90537877d956bb424414bb2a9265f2237886c6587bbaee22e",
        "lua/data/STCharacters.txt": "f9efb8da1b11ed4f872e102e5734cba6cc3c45fac75b54ff531ae2fd8f8891aa",
        "lua/data/STPhrases.txt": "745c82756ddf338ce0dd53909997bd31698f8dda499cb8a5eec91da1d59fe419",
        "lua/data/TWVariants.txt": "30e6f8395edbfdd74e293fd8b9c62105d787c849fbb208d2a7832eac696734d7",
        "lua/data/abbrev.txt": "e698cc0ea4d33e7deae48fa9a4831c54454f2f2f9a8b25a7feb376bbdda01631",
        "lua/data/chaifen.txt": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        "lua/data/charset.reverse.bin": "dbf8049c1f2f616a0a2ebd7b439cc94ea188805fd2c4b8dba2c4cabdf55de9e8",
        "lua/data/chengyu.txt": "cec93d482969f59e39916cad70cbfbe3db0277c1ce0d5d95131a02f423a1c726",
        "lua/data/chinese_english.txt": "4898e9434908bb9fac9c1d30f3011b0720dee06c2cc6029c72cb59a6c0f0ece9",
        "lua/data/codex_emoji.txt": "2229432a9f74e32ab5a08255cb3dd311f7749c7414c4d7c9f70e63c07a414681",
        "lua/data/codex_sym.txt": "859ea5a9f63f24d336d4fd7cd73d621584aa549ea724ce65dbbc494e0d331f4c",
        "lua/data/emoji.txt": "637a2aafb329e892aab9b537dc35ae6b7fc3a491cbc3b9edcc541c95f15f518a",
        "lua/data/en_abbrev.txt": "418f3e6faa65928e5f0684269492d839c2ca4116e98ecd16cf1ac390f58be689",
        "lua/data/english_chinese.txt": "4e75a70acbbc2f4c9ee6e060413ce5129eac0e671292ab70c829f02d5c53a361",
        "lua/data/others.txt": "6ac94247cffbeb6dc96e00785b06e5e356f2e04ded2b20066b439d477be89bc8",
        "lua/data/t9_abbrev.txt": "708acedd4730f7f8408d6c31466747e6473cf096e01371e95fa5b0dc65491d03",
        "lua/data/tips_show.txt": "d2cefab0135e6a9c6b377e618a372a41fd909f1075c92f0fe56ba1345e90a2b2",
        "lua/wanxiang/auto_phrase.lua": "0ff93805a6ec9e94c7fe032a72b3cb2a7f38a006f2c61ea7002197259599390b",
        "lua/wanxiang/bit.lua": "7dedb1ed31a31c2c254fcf26a23e77fc428ebeaa091336f2545cb5d5fc4f03ca",
        "lua/wanxiang/charset_filter.lua": "6f753b8503226e4259511cb2d7e4fd4ac6423207cf4769af02becede77e998ac",
        "lua/wanxiang/force_upper_aux.lua": "a4eb25f3b7cea2b16ae8deff13df9a1218872880a838b397d3a01ae70dc99db6",
        "lua/wanxiang/input_statistics.lua": "f8c44a26f86d3ccf0b84737e6c81c880c8c4e07641aea8f70e5eb1a5a31d3d34",
        "lua/wanxiang/key_binder.lua": "19844dfc6cb7a9278321d5a57df3b7603b89f264656936b22a028ec7064457cf",
        "lua/wanxiang/librime.lua": "f0f490a3ae792f4deea49ebf6397811e1e14969caf9f606ddfa0527b6367a74e",
        "lua/wanxiang/number_conversion.lua": "4cc3f75f4ec1b3d6860259db7b868003a707dff8a4e2462511d26b35d8b1d02e",
        "lua/wanxiang/partial_commit.lua": "f78ecf8c454351fe135de594e7553a364d677d3b31357010d533b82032ca708b",
        "lua/wanxiang/set_schema.lua": "b8ff023826c6c5ff8828f65557c0e3fc7803f40885055580c5a3719d83a22f24",
        "lua/wanxiang/shijian.lua": "5cab436f5d5fee416bbf31b404d7dae568c5b79f311da00c18531a5b246ba73b",
        "lua/wanxiang/super_calculator.lua": "9b1a0e5625dff95b9d208087e9e0d2f2452ab87081fa08515c318542f291b693",
        "lua/wanxiang/super_comment_preedit.lua":
            "150181f04bda7849925da827ba38e43efa2221e7345ef3450f1b60c4f0d1f896",
        "lua/wanxiang/super_english.lua": "523fd30446cf32d2e9646a890d68297b26e160d06ef466f3091a3e846375af71",
        "lua/wanxiang/super_filter.lua": "0983d0292224d6bb201d5b7965ef3cfe37b75396df9e97c74037fe3d50c5c37e",
        "lua/wanxiang/super_lookup.lua": "4baff714b722280056067a0802ea11ac555543c15302b57b64b85b44466cefe7",
        "lua/wanxiang/super_processor.lua": "abaf2652550b77e4183fea83795738202092e9b72c9cd5876fa6e11d48552c73",
        "lua/wanxiang/super_replacer.lua": "bfcfb6e42c431b4053045e37e73a90d5b9d0f4a92d2cab1e8849ba634111cc50",
        "lua/wanxiang/super_sequence.lua": "3823326d7fd00fcbf12db18591563f6c736328554dae8ea1172d33806cc351ea",
        "lua/wanxiang/super_symbols.lua": "ab21b6d26e7904474ec7ac7f5006ddb23873eca49be49ef22b35b0f2a218d7a6",
        "lua/wanxiang/super_tips.lua": "28702bc7c91d50915be246ac8ae2c082bbb7f6472d78510082f782626ec8e81a",
        "lua/wanxiang/unicode_conversion.lua": "5a8c8d799ee0aeb41f71d0bdd66453773b34bc0c8efd9c4a93f403b478462527",
        "lua/wanxiang/user_predict.lua": "714209e8b746cb231724df6aa32f93ba6c2fdd388e887f9930a782389eaa08ea",
        "lua/wanxiang/userdb.lua": "81e3cc8d4030301da6a37febf023cf11c334412251d9311c4ea933f12e973160",
        "lua/wanxiang/version_display.lua": "8d0c83f7f4e361f3b9b1eb8c2c6181fdba1a8d8de1f472801092f29348c47e18",
        "lua/wanxiang/wanxiang.lua": "f1718c55812ef2c9d373c4b3b799c94319d9d3a83810128aaa9dd1cc03919f25",
    ]
}

extension SchemeAdapterRegistry {
    /// ResourceCapability for known adapters (OpenCC honesty included).
    public static func resourceCapability(for schemaID: String) -> SchemeResourceCapability? {
        guard let adapter = adapter(for: schemaID) else { return nil }
        switch adapter.ownershipStrategyID {
        case .namedList:
            return SchemeResourceCapability(ownershipStrategyID: .namedList, admitsOpenCC: true)
        case .exactHash:
            // Wanxiang may keep OpenCC admitted=false.
            return SchemeResourceCapability(ownershipStrategyID: .exactHash, admitsOpenCC: false)
        case .none:
            return SchemeResourceCapability(ownershipStrategyID: .none, admitsOpenCC: false)
        }
    }

    /// Ownership strategies invoked by uninstall / upgrade-checkpoint staging.
    ///
    /// Ice: namedList only. Wanxiang: namedList (plan removable) + exactHash (lua).
    /// Luna / unknown: namedList only (no-op when plan removable lists are empty).
    public static func ownershipStrategies(for schemaID: String) -> [any ResourceOwnershipStrategy] {
        guard let adapter = adapter(for: schemaID) else {
            return [NamedListResourceOwnershipStrategy.shared]
        }
        switch adapter.ownershipStrategyID {
        case .namedList:
            return [NamedListResourceOwnershipStrategy.shared]
        case .exactHash:
            return [
                NamedListResourceOwnershipStrategy.shared,
                ExactHashResourceOwnershipStrategy.wanxiangPinnedArchive,
            ]
        case .none:
            return [NamedListResourceOwnershipStrategy.shared]
        }
    }

    /// Collect owned relative paths via registered strategies (behavior-preserving order).
    public static func ownedRelativePaths(
        for schemaID: String,
        plan: SchemeOwnershipPlanView,
        sharedRoot: URL,
        fileManager: FileManager = .default
    ) throws -> [String] {
        var paths: [String] = []
        var seen = Set<String>()
        for strategy in ownershipStrategies(for: schemaID) {
            for owned in try strategy.ownedPaths(
                sharedRoot: sharedRoot,
                plan: plan,
                fileManager: fileManager
            ) {
                if seen.insert(owned.relativePath).inserted {
                    paths.append(owned.relativePath)
                }
            }
        }
        return paths
    }

    /// Canonical schema id from a plan's `schemaFileName` (`.schema.yaml` suffix).
    public static func schemaID(forOwnershipPlanFileName schemaFileName: String) -> String {
        let suffix = ".schema.yaml"
        if schemaFileName.hasSuffix(suffix) {
            return String(schemaFileName.dropLast(suffix.count))
        }
        return schemaFileName
    }
}
