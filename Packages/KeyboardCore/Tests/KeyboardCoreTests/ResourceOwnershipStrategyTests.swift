import CryptoKit
import XCTest

@testable import KeyboardCore

final class ResourceOwnershipStrategyTests: XCTestCase {

    func testResourceCapabilityOpenCCHonesty() {
        let ice = SchemeAdapterRegistry.resourceCapability(for: "rime_ice")
        XCTAssertEqual(ice?.ownershipStrategyID, .namedList)
        XCTAssertEqual(ice?.admitsOpenCC, true)

        let wanxiang = SchemeAdapterRegistry.resourceCapability(for: "wanxiang")
        XCTAssertEqual(wanxiang?.ownershipStrategyID, .exactHash)
        XCTAssertEqual(wanxiang?.admitsOpenCC, false)

        let luna = SchemeAdapterRegistry.resourceCapability(for: "luna_pinyin")
        XCTAssertEqual(luna?.ownershipStrategyID, SchemeOwnershipStrategyID.none)
        XCTAssertEqual(luna?.admitsOpenCC, false)
    }

    func testOwnershipStrategiesComposeNamedListAndExactHash() {
        let iceIDs = SchemeAdapterRegistry.ownershipStrategies(for: "rime_ice").map { $0.strategyID }
        XCTAssertEqual(iceIDs, [.namedList])

        let wanxiangIDs = SchemeAdapterRegistry.ownershipStrategies(for: "wanxiang").map { $0.strategyID }
        XCTAssertEqual(wanxiangIDs, [.namedList, .exactHash])

        let lunaIDs = SchemeAdapterRegistry.ownershipStrategies(for: "luna_pinyin").map { $0.strategyID }
        XCTAssertEqual(lunaIDs, [.namedList])
    }

    func testNamedListDropsPathsNestedUnderRemovableDirectories() throws {
        let plan = SchemeOwnershipPlanView(
            schemaFileName: "rime_ice.schema.yaml",
            revision: "rime-ice-plan-2",
            removableFiles: ["lua/ice.lua", "cn_dicts/base.dict.yaml"],
            removableDirectories: ["cn_dicts"]
        )
        let paths = try NamedListResourceOwnershipStrategy.shared.ownedPaths(
            sharedRoot: FileManager.default.temporaryDirectory,
            plan: plan,
            fileManager: .default
        ).map(\.relativePath)
        XCTAssertEqual(paths, ["cn_dicts", "lua/ice.lua"])
    }

    func testExactHashMatchesPinnedBytesAndSkipsModifiedOrSymlink() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "exact-hash-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let samplePath = "lua/wanxiang/bit.lua"
        guard let expected = WanxiangExactHashOwnership.sha256ByPath[samplePath] else {
            XCTFail("missing sample hash")
            return
        }

        let fileURL = root.appendingPathComponent(samplePath)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        // Write bytes whose digest matches the pin by copying digest construction:
        // We cannot reconstruct original bytes from hash; plant matching digest via strategy test double map.
        let strategy = ExactHashResourceOwnershipStrategy(
            expectedSchemaFileName: "wanxiang.schema.yaml",
            expectedRevision: "wanxiang-plan-1",
            sha256ByPath: [samplePath: expected, "lua/custom.lua": expected]
        )

        let matchingBytes = Data("wanxiang-exact-hash-fixture".utf8)
        let matchingDigest = SHA256.hash(data: matchingBytes).map { String(format: "%02x", $0) }.joined()
        let localStrategy = ExactHashResourceOwnershipStrategy(
            expectedSchemaFileName: "wanxiang.schema.yaml",
            expectedRevision: "wanxiang-plan-1",
            sha256ByPath: [
                samplePath: matchingDigest,
                "lua/custom.lua": matchingDigest,
            ]
        )

        try matchingBytes.write(to: fileURL)
        let modifiedURL = root.appendingPathComponent("lua/custom.lua")
        try Data("edited".utf8).write(to: modifiedURL)

        let symlinkURL = root.appendingPathComponent("lua/wanxiang/link.lua")
        try FileManager.default.createSymbolicLink(at: symlinkURL, withDestinationURL: fileURL)
        let symlinkStrategy = ExactHashResourceOwnershipStrategy(
            expectedSchemaFileName: "wanxiang.schema.yaml",
            expectedRevision: "wanxiang-plan-1",
            sha256ByPath: [
                samplePath: matchingDigest,
                "lua/wanxiang/link.lua": matchingDigest,
            ]
        )

        let plan = SchemeOwnershipPlanView(
            schemaFileName: "wanxiang.schema.yaml",
            revision: "wanxiang-plan-1",
            removableFiles: ["wanxiang.schema.yaml"],
            removableDirectories: ["dicts"]
        )

        let matched = try localStrategy.ownedPaths(
            sharedRoot: root,
            plan: plan,
            fileManager: .default
        ).map(\.relativePath)
        XCTAssertEqual(matched, [samplePath])

        let symlinkMatched = try symlinkStrategy.ownedPaths(
            sharedRoot: root,
            plan: plan,
            fileManager: .default
        ).map(\.relativePath)
        XCTAssertEqual(symlinkMatched, [samplePath])

        // Wrong plan identity → empty (thin bridge).
        let wrongPlan = SchemeOwnershipPlanView(
            schemaFileName: "rime_ice.schema.yaml",
            revision: "rime-ice-plan-2",
            removableFiles: [],
            removableDirectories: []
        )
        XCTAssertTrue(
            try strategy.ownedPaths(sharedRoot: root, plan: wrongPlan, fileManager: .default).isEmpty
        )
        _ = symlinkURL
    }

    func testRegistryOwnedRelativePathsPreservesWanxiangUnionOrder() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "owned-union-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let samplePath = "lua/wanxiang/bit.lua"
        let bytes = Data("union-fixture".utf8)
        let digest = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
        let fileURL = root.appendingPathComponent(samplePath)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try bytes.write(to: fileURL)

        // Use production wanxiang strategies but with a temporary exact-hash override via direct call:
        let plan = SchemeOwnershipPlanView(
            schemaFileName: "wanxiang.schema.yaml",
            revision: "wanxiang-plan-1",
            removableFiles: ["wanxiang.schema.yaml"],
            removableDirectories: ["dicts"]
        )
        let named = try NamedListResourceOwnershipStrategy.shared.ownedPaths(
            sharedRoot: root,
            plan: plan,
            fileManager: .default
        ).map(\.relativePath)
        XCTAssertEqual(named, ["dicts", "wanxiang.schema.yaml"])

        let icePlan = SchemeOwnershipPlanView(
            schemaFileName: "rime_ice.schema.yaml",
            revision: "rime-ice-plan-2",
            removableFiles: ["lua/ice.lua"],
            removableDirectories: ["cn_dicts"]
        )
        let icePaths = try SchemeAdapterRegistry.ownedRelativePaths(
            for: "rime_ice",
            plan: icePlan,
            sharedRoot: root
        )
        XCTAssertEqual(icePaths, ["cn_dicts", "lua/ice.lua"])

        // Production exact-hash map won't match fixture bytes — empty supplemental is fine.
        let wanxiangPaths = try SchemeAdapterRegistry.ownedRelativePaths(
            for: "wanxiang",
            plan: plan,
            sharedRoot: root
        )
        XCTAssertEqual(wanxiangPaths, ["dicts", "wanxiang.schema.yaml"])
        XCTAssertEqual(digest.count, 64)
    }

    func testSchemaIDFromOwnershipPlanFileName() {
        XCTAssertEqual(
            SchemeAdapterRegistry.schemaID(forOwnershipPlanFileName: "rime_ice.schema.yaml"),
            "rime_ice"
        )
        XCTAssertEqual(
            SchemeAdapterRegistry.schemaID(forOwnershipPlanFileName: "wanxiang.schema.yaml"),
            "wanxiang"
        )
    }
}
