import Foundation
import KeyboardCore
import XCTest

@testable import RimeBridge

final class LunaT9VerifySeamTests: XCTestCase {
    func testVerifyEntryContracts() async throws {
        let schema = "luna_pinyin_t9"
        let entry = NineKeyScheme(
            schemaID: schema, familyID: "luna_pinyin", markerKey: "test_luna_verify_unique_marker",
            compatibilityVersion: "1")
        var repository = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 { repository.deleteLastPathComponent() }
        let builtin = repository.appendingPathComponent("Universe Keyboard/RimeBuiltin", isDirectory: true)
        let source = String(
            decoding: try LunaT9SchemaCompatibility.rewrite(
                Data(contentsOf: builtin.appendingPathComponent("luna_pinyin.schema.yaml"))), as: UTF8.self)
        let root = try LunaT9EvidenceRoot.directory("verify-seam").appendingPathComponent(
            UUID().uuidString, isDirectory: true)
        try LunaT9EvidenceRoot.createExclusiveDirectory(root)
        let shared = root.appendingPathComponent("shared", isDirectory: true)
        let user = root.appendingPathComponent("user", isDirectory: true)
        try FileManager.default.copyItem(at: builtin, to: shared)
        try FileManager.default.createDirectory(at: user, withIntermediateDirectories: true)
        try source.write(to: shared.appendingPathComponent(schema + ".schema.yaml"), atomically: false, encoding: .utf8)
        let defaults = shared.appendingPathComponent("default.yaml")
        var text = try String(contentsOf: defaults, encoding: .utf8)
        let start = try XCTUnwrap(text.range(of: "schema_list:\n"))
        let end = try XCTUnwrap(text.range(of: "\nswitcher:"))
        text.replaceSubrange(
            start.lowerBound..<end.lowerBound,
            with: "schema_list:\n  - schema: luna_pinyin\n  - schema: luna_pinyin_t9\n")
        try text.write(to: defaults, atomically: false, encoding: .utf8)
        let target = RimeConfigManager.SchemaSwitchTarget(
            schemaID: schema, userDictionarySchemaID: "luna_pinyin", sourceText: source, wanxiangFamily: false)
        let plan = RimeConfigManager.planSchemaCustomYamlFiles(
            targets: [target], simplificationEnabled: false,
            userDictionarySettings: RimeUserDictionarySettings(lunaPinyinEnabled: false, rimeIceEnabled: false),
            compileInputProven: true)
        let overlay = try XCTUnwrap(plan.first)
        try overlay.content.write(to: user.appendingPathComponent(overlay.filename), atomically: false, encoding: .utf8)
        let deployment = try await RimeDeploymentService().deploy(
            RimeDeploymentRequest(
                mode: .testFixtureMaintenanceOnly, sharedDataURL: shared, userDataURL: user,
                runtimeSmokeSchemaID: nil))
        XCTAssertTrue(deployment.succeeded, deployment.diagnosticMessage)
        func verify(_ input: String, _ registry: [NineKeyScheme], sharedPath: String? = nil, userPath: String? = nil)
            -> Bool
        {
            RimeT9SmokeProbe.verify(
                sharedDataDir: sharedPath ?? shared.path, userDataDir: userPath ?? user.path,
                schemaID: schema, input: input, registry: registry)
        }
        let positive = verify("6446", [entry])
        print("LUNA_SEAM positive registry=luna result=\(positive)")
        XCTAssertTrue(positive)
        let publicResult = RimeT9SmokeProbe.verify(
            sharedDataDir: shared.path, userDataDir: user.path, schemaID: schema, input: "6446")
        print("LUNA_SEAM A registry=production result=\(publicResult)")
        XCTAssertFalse(publicResult)
        XCTAssertNil(NineKeySchemeRegistry.scheme(schema))
        XCTAssertFalse(NineKeySchemeRegistry.entries.contains { $0.schemaID == schema })
        let invalid = verify("6446", [entry, entry])
        print("LUNA_SEAM B registry=duplicate-schema result=\(invalid)")
        XCTAssertFalse(invalid)
        let absent = verify("6446", NineKeySchemeRegistry.entries)
        print("LUNA_SEAM C registry=production-without-luna result=\(absent)")
        XCTAssertFalse(absent)
        let missingShared = root.appendingPathComponent("missing-shared", isDirectory: true)
        let missingUser = root.appendingPathComponent("missing-user", isDirectory: true)
        try FileManager.default.createDirectory(at: missingShared, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: missingUser, withIntermediateDirectories: true)
        let missing = verify("6446", [entry], sharedPath: missingShared.path, userPath: missingUser.path)
        print("LUNA_SEAM D registry=luna missing-schema result=\(missing)")
        XCTAssertFalse(missing)
        let empty = verify("", [entry])
        print("LUNA_SEAM E registry=luna empty-input result=\(empty)")
        XCTAssertFalse(empty)
        let entries = NineKeySchemeRegistry.entries
        let absentPublic = RimeT9SmokeProbe.verify(
            sharedDataDir: shared.path, userDataDir: user.path, schemaID: "no_such_schema", input: "6446")
        let absentSnapshot = RimeT9SmokeProbe.verify(
            sharedDataDir: shared.path, userDataDir: user.path, schemaID: "no_such_schema", input: "6446",
            registry: entries)
        let existingID = try XCTUnwrap(entries.first?.schemaID)
        let emptyPublic = RimeT9SmokeProbe.verify(
            sharedDataDir: shared.path, userDataDir: user.path, schemaID: existingID, input: "")
        let emptySnapshot = RimeT9SmokeProbe.verify(
            sharedDataDir: shared.path, userDataDir: user.path, schemaID: existingID, input: "", registry: entries)
        print(
            "LUNA_SEAM default-equivalence registry=production missing=\(absentPublic),\(absentSnapshot) empty=\(emptyPublic),\(emptySnapshot)"
        )
        XCTAssertFalse(absentPublic); XCTAssertFalse(absentSnapshot)
        XCTAssertFalse(emptyPublic); XCTAssertFalse(emptySnapshot)
    }
}
