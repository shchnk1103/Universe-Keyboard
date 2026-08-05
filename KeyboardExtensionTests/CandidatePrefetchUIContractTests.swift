import XCTest

@testable import Keyboard

nonisolated final class CandidatePrefetchUIContractTests: XCTestCase {
    /// The Extension target is built as a dependency of this test target. The
    /// test itself intentionally avoids referencing an appex symbol because an
    /// app extension is not a linkable XCTest host.
    func testExtensionTestBundleIsLoadable() {
        XCTAssertNotNil(Bundle(for: Self.self).bundleIdentifier)
    }
}
