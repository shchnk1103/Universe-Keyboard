import KeyboardCore
import XCTest

@testable import RimeBridge

final class WanxiangT9SwitchTargetTests: XCTestCase {
    private let schemaID = WanxiangT9SchemaCompatibility.schemaID

    func testTargetSetFollowsInstallAndPending() throws {
        let root = try emptyRoot()
        let installed = RimeConfigManager.schemaSwitchTargets(
            rimeRoot: root,
            iceInstalled: false,
            wanxiangInstalled: true,
            pendingSchemaID: nil
        )
        assertNineKey(in: installed, present: true)
        let pending = RimeConfigManager.schemaSwitchTargets(
            rimeRoot: root,
            iceInstalled: false,
            wanxiangInstalled: false,
            pendingSchemaID: "wanxiang"
        )
        assertNineKey(in: pending, present: true)
        let absent = RimeConfigManager.schemaSwitchTargets(
            rimeRoot: root,
            iceInstalled: true,
            wanxiangInstalled: false,
            pendingSchemaID: "rime_ice"
        )
        assertNineKey(in: absent, present: false)
        XCTAssertTrue(absent.contains { $0.schemaID == "t9" && $0.wanxiangFamily == false })
    }

    func testFixedSourceWritesSimplificationAndEmojiAndKeepsSwitchesEquivalent() throws {
        guard let path = ProcessInfo.processInfo.environment["WANXIANG_T9I_SOURCE"] else {
            throw XCTSkip("WANXIANG_T9I_SOURCE unset")
        }
        let source = try String(contentsOfFile: path, encoding: .utf8)
        guard case .rewritten(let rewritten) = WanxiangT9SchemaCompatibility.rewrite(source) else {
            return XCTFail("fixed source must rewrite")
        }
        guard case .success(let beforeItems) = SchemaSwitchResolver.recognize(source),
            case .success(let afterItems) = SchemaSwitchResolver.recognize(rewritten)
        else {
            return XCTFail("fixed source switches must parse")
        }
        XCTAssertEqual(switchIdentity(beforeItems), switchIdentity(afterItems))

        let root = try emptyRoot()
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        try FileManager.default.createDirectory(at: shared, withIntermediateDirectories: true)
        try source.write(
            to: shared.appendingPathComponent("\(schemaID).schema.yaml"),
            atomically: true,
            encoding: .utf8
        )
        let targets = RimeConfigManager.schemaSwitchTargets(
            rimeRoot: root,
            iceInstalled: false,
            wanxiangInstalled: true,
            pendingSchemaID: nil
        )
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: targets.filter { $0.schemaID == schemaID },
            simplificationEnabled: true,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: true)
        )
        let body = try XCTUnwrap(plan.first?.content)
        XCTAssertTrue(body.contains("switches/@8/reset"))
        XCTAssertTrue(body.contains("switches/@3/reset"))
        XCTAssertTrue(body.contains("enable_user_dict"))
    }

    func testMissingSourceKeepsManagedKeysAndOmitsSwitches() {
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schemaID,
            userDictionarySchemaID: "rime_ice",
            sourceText: nil,
            wanxiangFamily: true
        )
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target],
            simplificationEnabled: true,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: false)
        )
        let body = plan[0].content
        XCTAssertTrue(body.contains("enable_user_dict"))
        XCTAssertTrue(body.contains("false"))
        XCTAssertFalse(body.contains("switches/"))
    }

    func testT9RemainsSwitchesPatched() {
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: "t9",
            userDictionarySchemaID: "rime_ice",
            sourceText: "switches:\n  - name: simplification\n    states: [繁, 简]\n",
            wanxiangFamily: false
        )
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target],
            simplificationEnabled: true,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: true, rimeIceEnabled: true)
        )
        XCTAssertFalse(plan[0].content.contains("switches/"))
        XCTAssertTrue(plan[0].content.contains("enable_user_dict"))
    }

    private func assertNineKey(in targets: [RimeConfigManager.SchemaSwitchTarget], present: Bool) {
        let match = targets.filter { $0.schemaID == schemaID }
        if present {
            XCTAssertEqual(match.count, 1)
            XCTAssertEqual(match.first?.userDictionarySchemaID, "rime_ice")
            XCTAssertEqual(match.first?.wanxiangFamily, true)
        } else {
            XCTAssertTrue(match.isEmpty)
        }
    }

    private func switchIdentity(_ items: [SchemaSwitchResolver.Item]) -> [String] {
        items.map { item in
            "\(item.index)|\(item.name ?? "")|\(item.options?.joined(separator: ",") ?? "")"
        }
    }

    private func emptyRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "wanxiang-t9-targets-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }
}
