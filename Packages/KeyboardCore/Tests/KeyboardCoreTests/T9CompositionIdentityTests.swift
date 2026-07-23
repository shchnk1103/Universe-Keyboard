import XCTest
@testable import KeyboardCore

/// Pure identity contracts for Gate 5 Partial / residual-B Path-ledger peel.
final class T9CompositionIdentityTests: XCTestCase {
    private let qingWeiFanDaoSource = "74649343263269698454"

    func testAfterPartialCommitUnchangedMixedRawFailsClosed() {
        let identity = T9CompositionIdentity.afterPartialCommit(
            previousSource: qingWeiFanDaoSource,
            previousConfirmed: ["qing", "wei", "fan", "dao"],
            remainingRaw: "qing'wei'fan'dao'9698454"
        )
        XCTAssertNil(
            identity,
            "engine-only unchanged-raw must fail-closed; Path peel is a separate API"
        )
    }

    func testAfterPathLedgerPeelSingleSyllableDeviceB() {
        let identity = T9CompositionIdentity.afterPathLedgerPeel(
            previousSource: qingWeiFanDaoSource,
            previousConfirmed: ["qing", "wei", "fan", "dao"],
            peelSyllableCount: 1
        )
        XCTAssertEqual(identity?.sourceDigits, "9343263269698454")
        XCTAssertEqual(identity?.confirmedSyllables, ["wei", "fan", "dao"])
        XCTAssertEqual(identity?.focusedSegmentIndex, 3)
        XCTAssertEqual(identity?.remainingDigits, "9698454")
        XCTAssertEqual(identity?.replacementRawInput, "wei'fan'dao'9698454")
    }

    func testAfterPathLedgerPeelRejectsEmptyConfirmed() {
        XCTAssertNil(
            T9CompositionIdentity.afterPathLedgerPeel(
                previousSource: qingWeiFanDaoSource,
                previousConfirmed: [],
                peelSyllableCount: 1
            )
        )
    }

    func testAfterPathLedgerPeelRejectsConsumingEntireSource() {
        // Only one confirmed syllable whose letters equal full source — cannot peel.
        let short = "7464"
        XCTAssertNil(
            T9CompositionIdentity.afterPathLedgerPeel(
                previousSource: short,
                previousConfirmed: ["qing"],
                peelSyllableCount: 1
            ),
            "must leave a non-empty remaining digit source"
        )
    }

    func testAfterPathLedgerPeelRejectsPeelBeyondConfirmed() {
        XCTAssertNil(
            T9CompositionIdentity.afterPathLedgerPeel(
                previousSource: qingWeiFanDaoSource,
                previousConfirmed: ["qing"],
                peelSyllableCount: 2
            )
        )
    }

    func testAfterPathLedgerPeelRejectsCatalogMismatch() {
        // "qing" letters do not match digit slice starting at 9…
        XCTAssertNil(
            T9CompositionIdentity.afterPathLedgerPeel(
                previousSource: "9343263269698454",
                previousConfirmed: ["qing", "wei"],
                peelSyllableCount: 1
            )
        )
    }

    func testAfterPathLedgerPeelTwoSyllables() {
        let identity = T9CompositionIdentity.afterPathLedgerPeel(
            previousSource: qingWeiFanDaoSource,
            previousConfirmed: ["qing", "wei", "fan", "dao"],
            peelSyllableCount: 2
        )
        XCTAssertEqual(identity?.sourceDigits, "3263269698454")
        XCTAssertEqual(identity?.confirmedSyllables, ["fan", "dao"])
    }
}
