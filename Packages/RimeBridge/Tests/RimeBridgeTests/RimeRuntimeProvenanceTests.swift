import KeyboardCore
import RimeBridgeObjC
import XCTest

@testable import RimeBridge

final class RimeRuntimeProvenanceTests: XCTestCase {
    func testDownloadedReceiptRoundTripsOnlyWithCompleteIdentity() throws {
        let digest = String(repeating: "a", count: 64)
        let receipt = RimeRuntimeProvenanceReceipt(
            receiptID: UUID(),
            generatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            schemeID: "rime_ice",
            activeSchemaID: "rime_ice",
            source: .downloaded,
            sourceVariantID: "github-release-20260630",
            upstreamRevision: "675d23b0",
            artifactVersion: "2026.06.30",
            artifactIdentityID: "rime-ice-20260630-675d23b0",
            stagedIdentityID: "rime-ice-staged-20260630",
            archiveSHA256: digest,
            stagedContentSHA256: digest,
            installedContentSHA256: digest,
            installationPlanRevision: "rime-ice-plan-2",
            postProcessingRevision: "rime-ice-post-2",
            luaAvailable: true,
            librimeVersion: "1.9.5",
            runtimeSmokePassed: true,
            luaRuntimeSmokePassed: true,
            installedFiles: [
                RimeRuntimeProvenanceFile(
                    relativePath: "build/ice.schema.yaml",
                    byteCount: 12,
                    sha256: digest
                ),
                RimeRuntimeProvenanceFile(
                    relativePath: "lua/ice.lua",
                    byteCount: 34,
                    sha256: digest
                ),
            ]
        )
        XCTAssertTrue(receipt.isValid)

        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-provenance-(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        try RimeRuntimeProvenanceStore.write(receipt, to: root)
        XCTAssertEqual(RimeRuntimeProvenanceStore.load(from: root), receipt)
        XCTAssertEqual(receipt.identity.receiptID, receipt.receiptID)
        XCTAssertEqual(receipt.identity.stagedContentSHA256, digest)
    }

    func testIncompleteDownloadedReceiptCannotBePersistedOrLoaded() throws {
        let receipt = RimeRuntimeProvenanceReceipt(
            schemeID: "rime_ice",
            activeSchemaID: "rime_ice",
            source: .downloaded,
            luaAvailable: true,
            librimeVersion: "1.9.5",
            runtimeSmokePassed: true
        )
        XCTAssertFalse(receipt.isValid)

        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("rime-provenance-invalid-(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        XCTAssertThrowsError(try RimeRuntimeProvenanceStore.write(receipt, to: root))
        XCTAssertNil(RimeRuntimeProvenanceStore.load(from: root))
    }

    func testBuiltinReceiptRequiresRuntimeSmoke() {
        let receipt = RimeRuntimeProvenanceReceipt(
            schemeID: "luna_pinyin",
            activeSchemaID: "luna_pinyin",
            source: .builtin,
            luaAvailable: false,
            librimeVersion: "1.9.5",
            runtimeSmokePassed: false
        )

        XCTAssertFalse(receipt.isValid)
    }

    func testSidecarDiagnosticParserBindsEverySessionAndProvenanceIdentity() throws {
        let receiptID = UUID()
        var raw: [AnyHashable: Any] = [
            RimeKeyCorrectionQuerySequence: NSNumber(value: 9),
            RimeKeyCorrectionQueryInputLength: NSNumber(value: 18),
            RimeKeyCorrectionQueryLimit: NSNumber(value: 3),
            RimeKeyCorrectionQueryResultCount: NSNumber(value: 2),
            RimeKeyCorrectionQueryElapsedMilliseconds: NSNumber(value: 11),
            RimeKeyCorrectionQueryLiveSessionIDBefore: NSNumber(value: 101),
            RimeKeyCorrectionQueryLiveSessionIDAfter: NSNumber(value: 101),
            RimeKeyCorrectionQueryLiveSessionValidBefore: NSNumber(value: true),
            RimeKeyCorrectionQueryLiveSessionValidAfter: NSNumber(value: true),
            RimeKeyCorrectionQuerySidecarSessionIDBefore: NSNumber(value: 0),
            RimeKeyCorrectionQuerySidecarSessionIDAfter: NSNumber(value: 202),
            RimeKeyCorrectionQuerySchemaID: "rime_ice",
            RimeKeyCorrectionQueryOutcome: "returned",
        ]

        let diagnostic = try XCTUnwrap(
            RimeEngineImpl.parseCorrectionQueryDiagnostic(
                raw,
                provenanceReceiptID: receiptID
            )
        )
        XCTAssertEqual(diagnostic.route, .realRimeSidecar)
        XCTAssertEqual(diagnostic.sequence, 9)
        XCTAssertEqual(diagnostic.liveSessionIDBefore, 101)
        XCTAssertEqual(diagnostic.liveSessionIDAfter, 101)
        XCTAssertNil(diagnostic.sidecarSessionIDBefore)
        XCTAssertEqual(diagnostic.sidecarSessionIDAfter, 202)
        XCTAssertEqual(diagnostic.provenanceReceiptID, receiptID)
        XCTAssertEqual(diagnostic.outcome, .returned)

        raw[RimeKeyCorrectionQueryInputLength] = NSNumber(value: 31)
        XCTAssertNil(
            RimeEngineImpl.parseCorrectionQueryDiagnostic(
                raw,
                provenanceReceiptID: receiptID
            )
        )
    }
}
