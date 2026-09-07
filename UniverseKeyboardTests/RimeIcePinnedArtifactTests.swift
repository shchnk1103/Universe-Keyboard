import Foundation
import KeyboardCore
import RimeBridge
import XCTest

@testable import Universe_Keyboard

@MainActor
final class RimeIcePinnedArtifactTests: XCTestCase {
    func testCatalogUsesDatedReleaseWithBoundDiagnostics() throws {
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice"))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        XCTAssertEqual(manifest.version, "2026.06.30")
        for source in manifest.sourceVariants {
            XCTAssertFalse(source.downloadURL.path.contains("nightly"))
            XCTAssertTrue(source.downloadURL.path.contains("2026.06.30"))
            let identity = try manifest.resolvedStagedIdentity(for: source)
            XCTAssertNotNil(SchemeDeliveryDiagnosticMapper.context(operationID: UUID(), identity: identity))
        }
    }

    /// Opt-in source evidence uses downloaded artifacts, never network access from the test host.
    /// The local release gate sets TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT; ordinary CI retains the unit tests.
    func testVerifiedOfficialAndMirrorArchivesConvergeAfterProductionProcessing() throws {
        guard let path = ProcessInfo.processInfo.environment["SCHEME_PIN_ARCHIVE_ROOT"] else {
            throw XCTSkip("Set TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT to the independently downloaded source archives")
        }
        let entry = try XCTUnwrap(RimeSchemeCatalog.entry(for: "rime_ice"))
        let manifest = try XCTUnwrap(entry.distribution?.manifest)
        let plan = try XCTUnwrap(entry.installationPlan)
        let verifier = SchemaArtifactVerifier()
        for source in manifest.sourceVariants {
            let archive = URL(fileURLWithPath: path).appendingPathComponent("\(source.id).zip")
            XCTAssertEqual(try verifier.verifyArchive(at: archive, source: source), source.archiveSHA256)
            for luaAvailable in [true, false] {
                let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
                defer { try? FileManager.default.removeItem(at: root) }
                _ = try Unzip.extract(zipPath: archive.path, to: root)
                let schema = root.appendingPathComponent(plan.schemaFileName)
                if !luaAvailable {
                    let processed = RimeConfigPostProcessor.stripLuaDependencies(
                        from: try String(contentsOf: schema, encoding: .utf8))
                    XCTAssertTrue(RimeConfigPostProcessor.validateStrippedSchema(processed))
                    try processed.write(to: schema, atomically: true, encoding: .utf8)
                }
                let t9 = root.appendingPathComponent("t9.schema.yaml")
                try T9SchemaCompatibility.makeCompatibleSchema(
                    fromUpstreamYAML: String(contentsOf: t9, encoding: .utf8)
                )
                .write(to: t9, atomically: true, encoding: .utf8)
                try RimeIceSharedDefaultAdapter.apply(in: root)
                for schemaName in [
                    "rime_ice.schema.yaml",
                    "t9.schema.yaml",
                    "melt_eng.schema.yaml",
                    "radical_pinyin.schema.yaml",
                ] {
                    let yaml = try String(
                        contentsOf: root.appendingPathComponent(schemaName),
                        encoding: .utf8
                    )
                    XCTAssertFalse(yaml.contains("__include: default:/"), schemaName)
                    XCTAssertNil(
                        yaml.range(
                            of: #"import_preset:\s*default\b"#,
                            options: .regularExpression
                        ),
                        schemaName
                    )
                }
                let identity = try manifest.resolvedStagedIdentity(for: source)
                XCTAssertEqual(
                    try verifier.stagedContentSHA256(in: root, plan: plan, luaAvailable: luaAvailable),
                    luaAvailable ? identity.stagedContentSHA256WithLua : identity.stagedContentSHA256WithoutLua)
            }
        }
    }
}
