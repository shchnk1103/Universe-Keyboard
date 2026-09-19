import Foundation
import KeyboardCore
import XCTest

@testable import Universe_Keyboard

@MainActor
final class DiagnosticsRuntimeRouteDisplayTests: XCTestCase {
    func testRuntimeRouteLineExposesFiniteFieldsWithoutUserContent() {
        let operationID = UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!
        let event = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 0),
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .runtimeRoutePhaseChanged,
            level: .info,
            category: .deployment,
            runtimeRoutePayload: .init(
                operationID: operationID,
                phase: .fallbackDeploy,
                result: .succeeded,
                schema: .lunaPinyin,
                layout: .twentySixKey,
                state: .ready,
                elapsedMilliseconds: 37
            )
        )
        let line = DiagnosticsEventDisplayFormatter.line(event)
        XCTAssertTrue(line.contains("runtime_route.phase_changed"))
        XCTAssertTrue(line.contains("operation=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"))
        XCTAssertTrue(line.contains("phase=fallback_deploy"))
        XCTAssertTrue(line.contains("result=succeeded"))
        XCTAssertTrue(line.contains("schema=luna_pinyin"))
        XCTAssertTrue(line.contains("layout=26_key"))
        XCTAssertTrue(line.contains("state=ready"))
        XCTAssertTrue(line.contains("elapsed_ms=37"))
        XCTAssertFalse(line.contains("ni"))
        XCTAssertFalse(line.contains("候选"))
        XCTAssertFalse(line.contains("/var"))
        XCTAssertFalse(line.contains("https://"))

        let items = DiagnosticsEventDisplayFormatter.runtimeRouteDetailItems(from: line)
        let map = Dictionary(uniqueKeysWithValues: (items ?? []).map { ($0.title, $0.value) })
        XCTAssertEqual(map["operation"], "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
        XCTAssertEqual(map["phase"], "fallback_deploy")
        XCTAssertEqual(map["elapsed_ms"], "37")
        XCTAssertNil(
            DiagnosticsEventDisplayFormatter.runtimeRouteDetailItems(
                from:
                    "[00:00:00.000] [info] [deployment] rime_sync.terminal operation=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
            )
        )
    }

    func testTypoCorrectionLineExposesRouteAndSidecarIdentityWithoutUserContent() throws {
        let receiptID = UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!
        let diagnostic = TypoCorrectionQueryDiagnostic(
            sequence: 7,
            inputLength: 18,
            limit: 3,
            resultCount: 3,
            elapsedMilliseconds: 2,
            liveSessionIDBefore: 101,
            liveSessionIDAfter: 101,
            liveSessionValidBefore: true,
            liveSessionValidAfter: true,
            sidecarSessionIDBefore: nil,
            sidecarSessionIDAfter: 202,
            schemaID: "rime_ice",
            provenanceReceiptID: receiptID,
            outcome: .returned
        )
        let sidecar = try XCTUnwrap(
            DiagnosticEvent.TypoCorrectionSidecarQueryEvent(diagnostic: diagnostic)
        )
        let event = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 0),
            monotonicNanoseconds: 1,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .typoCorrectionSidecarQuery,
            level: .info,
            category: .engine,
            typoCorrectionPayload: .sidecarQuery(sidecar)
        )

        let line = DiagnosticsEventDisplayFormatter.line(event)
        XCTAssertTrue(line.contains("typo_correction.sidecar_query"))
        XCTAssertTrue(line.contains("route=real_rime_sidecar"))
        XCTAssertTrue(line.contains("seq=7"))
        XCTAssertTrue(line.contains("input_len=18"))
        XCTAssertTrue(line.contains("results=3"))
        XCTAssertTrue(line.contains("schema=rime_ice"))
        XCTAssertTrue(line.contains("receipt=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"))
        XCTAssertTrue(line.contains("outcome=returned"))
        XCTAssertFalse(line.contains("候选"))
        XCTAssertFalse(line.contains("/var"))
        XCTAssertFalse(line.contains("https://"))
    }
}
