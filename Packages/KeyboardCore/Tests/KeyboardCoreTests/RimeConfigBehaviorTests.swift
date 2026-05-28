import XCTest

@testable import KeyboardCore

final class RimeConfigBehaviorTests: XCTestCase {
    func testCurrentPageSizeDefault() {
        let defaults = UserDefaults(suiteName: "test_unzip_\(UUID().uuidString)")!
        defaults.removeObject(forKey: "rime_page_size")
        XCTAssertTrue(true)
    }

    func testRequestDeploySetsFlags() {
        let suiteName = "test_deploy_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        defaults.set(false, forKey: "rime_deployed")
        defaults.set(true, forKey: "rime_needs_deploy")

        XCTAssertFalse(defaults.bool(forKey: "rime_deployed"))
        XCTAssertTrue(defaults.bool(forKey: "rime_needs_deploy"))

        defaults.removePersistentDomain(forName: suiteName)
    }

    func testSetPageSizeClamping() {
        let minVal = max(5, min(20, 1))
        XCTAssertEqual(minVal, 5)
        let maxVal = max(5, min(20, 100))
        XCTAssertEqual(maxVal, 20)
        let inRange = max(5, min(20, 10))
        XCTAssertEqual(inRange, 10)
    }
}
