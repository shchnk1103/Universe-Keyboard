import XCTest

@testable import KeyboardCore

final class DiagnosticEventTests: XCTestCase {
    func testRoundTripPreservesOnlyTypedContentFreeFields() throws {
        let appearanceID = UUID()
        let event = DiagnosticEvent(
            utcTimestamp: Date(timeIntervalSince1970: 1_723_123_456),
            monotonicNanoseconds: 123_456,
            origin: .keyboardExtension,
            processInstanceID: UUID(),
            localSequence: 42,
            appearanceID: appearanceID,
            actionSequence: 7,
            code: .candidateVisibilityChanged,
            level: .info,
            category: .display,
            fields: [
                .count(.candidateCount, 3),
                .count(.visibleCandidateCellCount, 2),
                .flag(.isCandidateBarVisible, true),
                .reason(.generationChanged),
            ]
        )

        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(DiagnosticEvent.self, from: encoded)

        XCTAssertEqual(decoded, event)
        XCTAssertEqual(decoded.appearanceID, appearanceID)
    }

    func testFieldEncodingDoesNotProvideFreeTextPayload() throws {
        let event = DiagnosticEvent(
            utcTimestamp: .now,
            monotonicNanoseconds: 1,
            origin: .mainApp,
            processInstanceID: UUID(),
            localSequence: 1,
            code: .journalDropped,
            level: .warning,
            category: .performance,
            fields: [.reason(.queueFull), .count(.droppedEventCount, 1)]
        )

        let object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(event)) as? [String: Any]
        let fields = try XCTUnwrap(object?["fields"] as? [[String: Any]])

        let encodedKeys = Set(fields.flatMap { $0.keys })
        XCTAssertEqual(encodedKeys, ["type", "name", "integerValue", "reason"])
        XCTAssertFalse(encodedKeys.contains("message"))
        XCTAssertFalse(encodedKeys.contains("text"))
    }
}
