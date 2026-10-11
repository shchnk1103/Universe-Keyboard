#if DEBUG && KEYBOARD_QUERY_COST_PROBE
    import Foundation
    import XCTest

    nonisolated final class TypoCorrectionCallbackLedgerTests: XCTestCase {
        @MainActor func testCompletedNonNilAliasesAreQuiescent() throws {
            let ledger = TypoCorrectionCallbackLedger()
            let item = DispatchWorkItem {}
            let token = try XCTUnwrap(ledger.schedule())
            ledger.bind(item, to: token)
            XCTAssertFalse(ledger.quiescent(aliases: [item, item]))
            ledger.enter(token)
            ledger.complete(token)
            XCTAssertTrue(ledger.quiescent(aliases: [item, item]))
            ledger.cancelObserved(item)
            ledger.cancelObserved(item)
            XCTAssertTrue(ledger.quiescent(aliases: [item, item]))
        }
        @MainActor func testCancelBeforeEntryDeduplicatesAliasesButUnexpectedEntryInvalidates() throws {
            let ledger = TypoCorrectionCallbackLedger()
            let item = DispatchWorkItem {}
            let token = try XCTUnwrap(ledger.schedule())
            ledger.bind(item, to: token)
            ledger.cancelObserved(item)
            ledger.cancelObserved(item)
            XCTAssertTrue(ledger.quiescent(aliases: [item, item]))
            ledger.enter(token)
            XCTAssertFalse(ledger.quiescent(aliases: [item]))
        }
        @MainActor func testRunningCancellationRemainsPendingUntilNaturalCompletion() throws {
            let ledger = TypoCorrectionCallbackLedger()
            let item = DispatchWorkItem {}
            let token = try XCTUnwrap(ledger.schedule())
            ledger.bind(item, to: token)
            ledger.enter(token)
            ledger.cancelObserved(item)
            XCTAssertFalse(ledger.quiescent(aliases: [nil, nil]))
            ledger.complete(token)
            XCTAssertTrue(ledger.quiescent(aliases: [item, item]))
        }
        @MainActor func testRunLoopAndTaskHandoffCannotBeRetiredByOperationInvalidation() throws {
            let ledger = TypoCorrectionCallbackLedger()
            let token = try XCTUnwrap(ledger.schedule(.runLoopPending))
            XCTAssertFalse(ledger.quiescent(aliases: [nil]))
            token.observeRunLoopHandoff()
            XCTAssertFalse(ledger.quiescent(aliases: [nil]))
            ledger.handoff(token)
            XCTAssertFalse(ledger.quiescent(aliases: [nil]))
            ledger.enter(token)
            XCTAssertTrue(ledger.hasPotentialWork)
            ledger.complete(token)
            XCTAssertTrue(ledger.quiescent(aliases: [nil]))
        }
        @MainActor func testMissingHandoffOrForeignTokenIsUnknown() throws {
            let ledger = TypoCorrectionCallbackLedger()
            let token = try XCTUnwrap(ledger.schedule(.runLoopPending))
            ledger.handoff(token)
            XCTAssertTrue(ledger.hasPotentialWork)
            let first = TypoCorrectionCallbackLedger()
            let second = TypoCorrectionCallbackLedger()
            let foreign = try XCTUnwrap(first.schedule())
            _ = second.schedule()
            second.enter(foreign)
            XCTAssertTrue(second.hasPotentialWork)
            XCTAssertFalse(second.quiescent(aliases: []))
        }
        @MainActor func testTerminalAliasReplacementRetiresOnlyTerminalEntry() throws {
            let ledger = TypoCorrectionCallbackLedger()
            let old = DispatchWorkItem {}
            let new = DispatchWorkItem {}
            let first = try XCTUnwrap(ledger.schedule())
            ledger.bind(old, to: first)
            ledger.cancelObserved(old)
            let second = try XCTUnwrap(ledger.schedule())
            ledger.bind(new, to: second)
            ledger.enter(second)
            ledger.complete(second)
            XCTAssertTrue(ledger.quiescent(aliases: [new, new]))
            XCTAssertFalse(ledger.quiescent(aliases: [old]))  // Old identity is not inferred as the new body.
        }
        @MainActor func testUnknownAliasPendingNilAndCapacityFailClosed() {
            let ledger = TypoCorrectionCallbackLedger()
            _ = ledger.schedule()
            XCTAssertFalse(ledger.quiescent(aliases: [nil, nil]))
            XCTAssertFalse(ledger.quiescent(aliases: [DispatchWorkItem {}]))
            let full = TypoCorrectionCallbackLedger()
            for _ in 0..<64 { XCTAssertNotNil(full.schedule(.runLoopPending)) }
            XCTAssertNil(full.schedule())
            XCTAssertTrue(full.hasPotentialWork)
            full.invalidate()
            XCTAssertFalse(full.quiescent(aliases: []))
        }
    }
#endif
