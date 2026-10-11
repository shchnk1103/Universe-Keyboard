#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import XCTest
    @testable import KeyboardCore

    nonisolated final class QueryCostTouchLedgerTests: XCTestCase {
        func testEndAndCancellationRetireConcurrentKeyAndCandidateTouches() {
            let key = NSObject(), candidate = NSObject()
            var ledger = QueryCostTouchLedger()
            XCTAssertTrue(ledger.isIdle)
            ledger.begin(ObjectIdentifier(key), isOwnControl: false)
            ledger.begin(ObjectIdentifier(candidate), isOwnControl: false)
            XCTAssertEqual(ledger.activeCount, 2)
            XCTAssertFalse(ledger.isIdle)
            ledger.retire(ObjectIdentifier(key))
            XCTAssertFalse(ledger.isIdle)
            ledger.retire(ObjectIdentifier(candidate))
            XCTAssertTrue(ledger.isIdle)
            XCTAssertFalse(ledger.hasUnknownState)
        }
        func testOwnControlIsExcludedWithoutHidingConcurrentObservedTouch() {
            let control = NSObject(), key = NSObject()
            var ledger = QueryCostTouchLedger()
            XCTAssertFalse(QueryCostTouchLedger.shouldObserve(isOwnControl: true))
            XCTAssertTrue(QueryCostTouchLedger.shouldObserve(isOwnControl: false))
            ledger.begin(ObjectIdentifier(control), isOwnControl: true)
            XCTAssertTrue(ledger.isIdle)
            ledger.begin(ObjectIdentifier(key), isOwnControl: false)
            ledger.begin(ObjectIdentifier(control), isOwnControl: true)
            XCTAssertEqual(ledger.activeCount, 1)
            XCTAssertFalse(ledger.isIdle)
            ledger.retire(ObjectIdentifier(key))
            XCTAssertTrue(ledger.isIdle)
        }
        func testDuplicateBeginMakesUncertaintyStickyAfterRetirementAndReset() {
            let touch = NSObject()
            var ledger = QueryCostTouchLedger()
            ledger.begin(ObjectIdentifier(touch), isOwnControl: false)
            ledger.begin(ObjectIdentifier(touch), isOwnControl: false)
            XCTAssertEqual(ledger.activeCount, 1)
            ledger.retire(ObjectIdentifier(touch))
            ledger.reset()
            XCTAssertTrue(ledger.hasUnknownState)
            XCTAssertFalse(ledger.isIdle)
        }
        func testUnknownEndOrCancellationNeverEstablishesIdle() {
            let unknown = NSObject()
            var ledger = QueryCostTouchLedger()
            ledger.retire(ObjectIdentifier(unknown))
            XCTAssertEqual(ledger.activeCount, 0)
            XCTAssertTrue(ledger.hasUnknownState)
            XCTAssertFalse(ledger.isIdle)
        }
        func testSixteenTouchesFitButSeventeenthCannotBeSilentlyDropped() {
            let touches = (0...QueryCostTouchLedger.capacity).map { _ in NSObject() }
            var ledger = QueryCostTouchLedger()
            for touch in touches.prefix(QueryCostTouchLedger.capacity) {
                ledger.begin(ObjectIdentifier(touch), isOwnControl: false)
            }
            XCTAssertEqual(ledger.activeCount, 16)
            XCTAssertFalse(ledger.hasUnknownState)
            ledger.begin(ObjectIdentifier(touches[16]), isOwnControl: false)
            XCTAssertEqual(ledger.activeCount, 16)
            XCTAssertTrue(ledger.hasUnknownState)
            for touch in touches.prefix(16) { ledger.retire(ObjectIdentifier(touch)) }
            XCTAssertFalse(ledger.isIdle)
        }
        func testUnexpectedResetPreservesLiveIdentityAndStickyUncertainty() {
            let touch = NSObject()
            var ledger = QueryCostTouchLedger()
            ledger.begin(ObjectIdentifier(touch), isOwnControl: false)
            ledger.reset()
            XCTAssertEqual(ledger.activeCount, 1)
            ledger.retire(ObjectIdentifier(touch))
            XCTAssertEqual(ledger.activeCount, 0)
            XCTAssertTrue(ledger.hasUnknownState)
            XCTAssertFalse(ledger.isIdle)
        }
        func testOrdinaryIdleResetAndRepeatedLifetimesRemainKnown() {
            let touch = NSObject()
            var ledger = QueryCostTouchLedger()
            ledger.reset()
            for _ in 0..<32 {
                ledger.begin(ObjectIdentifier(touch), isOwnControl: false)
                ledger.retire(ObjectIdentifier(touch))
                ledger.reset()
                XCTAssertTrue(ledger.isIdle)
            }
        }
    }
#endif
