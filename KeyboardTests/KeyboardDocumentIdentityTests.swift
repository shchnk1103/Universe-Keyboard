import Foundation
import XCTest

@MainActor
final class KeyboardDocumentIdentityTests: XCTestCase {
    func testNilObjectiveCGetterDoesNotTrapWhenReadThroughNullableBridge() {
        let proxy = KeyboardMakeIdentityProxy(nil)
        XCTAssertNil(KeyboardReadDocumentIdentifier(proxy))
    }

    func testValidObjectiveCIdentifierIsPreserved() {
        let identity = UUID()
        let proxy = KeyboardMakeIdentityProxy(identity)
        XCTAssertEqual(KeyboardReadDocumentIdentifier(proxy), identity)
    }

    func testUnavailableStartupDoesNotEstablishAFalseBaseline() {
        var tracker = KeyboardDocumentIdentityTracker()
        XCTAssertEqual(tracker.observe(nil), .unavailable)
        XCTAssertNil(tracker.identifier)
        let identity = UUID()
        XCTAssertEqual(tracker.observe(identity), .initial)
        XCTAssertEqual(tracker.observe(identity), .unchanged)
    }

    func testUnavailableSamplePreservesBaselineAndLaterHostChange() {
        let first = UUID()
        let second = UUID()
        var tracker = KeyboardDocumentIdentityTracker()
        XCTAssertEqual(tracker.observe(first), .initial)
        XCTAssertEqual(tracker.observe(nil), .unavailable)
        XCTAssertEqual(tracker.identifier, first)
        XCTAssertEqual(tracker.observe(second), .changed)
        XCTAssertEqual(tracker.identifier, second)
        XCTAssertEqual(tracker.observe(second), .unchanged)
    }
}
