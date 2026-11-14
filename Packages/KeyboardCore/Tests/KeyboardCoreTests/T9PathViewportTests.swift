import XCTest

@testable import KeyboardCore

final class T9PathViewportTests: XCTestCase {
    private func offset(
        _ current: Double, _ start: Double?, _ end: Double?, _ index: Int?, _ changed: Bool = true,
        _ listChanged: Bool = false
    ) -> Double {
        T9PathViewport.offset(
            current: current, viewportWidth: 100, contentWidth: 300,
            selectedStart: start, selectedEnd: end, selectedIndex: index,
            selectionChanged: changed, listChanged: listChanged)
    }
    func testVisibilityAndReset() {
        XCTAssertEqual(offset(30, 50, 80, 2), 30)
        XCTAssertEqual(offset(30, 115, 145, 3), 45)
        XCTAssertEqual(offset(80, 35, 65, 1), 35)
        XCTAssertEqual(offset(80, 4, 30, 0), 0)
        XCTAssertEqual(offset(80, nil, nil, nil), 0)
        XCTAssertEqual(offset(80, 90, 120, 2, true, true), 0)
        XCTAssertEqual(offset(80, 90, 120, 2, false), 80)
        XCTAssertEqual(offset(80, 4, 30, 0, false), 80)
    }
}
