import XCTest

nonisolated final class CandidatePrefetchUIContractTests: XCTestCase {
    /// Keep this hostless bundle independent of the Extension module. The
    /// target builds the appex as a dependency, but XCTest cannot link it as a
    /// host; this assertion only verifies the test bundle itself loads.
    func testExtensionTestBundleIsLoadable() {
        XCTAssertNotNil(Bundle(for: Self.self).bundleIdentifier)
    }
}
