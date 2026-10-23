import UIKit
import XCTest

@testable import Universe_Keyboard

nonisolated final class KeyboardHeightSettingsTests: XCTestCase {
    @MainActor
    func testEntryAndSearchUseHeightDestinationAndFixedFullAccessCopy() throws {
        let entries = SettingsSearchCatalog.all.filter { $0.destination == .keyboardHeight }
        XCTAssertEqual(entries.count, 1)
        let item = try XCTUnwrap(entries.first)
        XCTAssertEqual(item.id, "keyboardHeight")
        XCTAssertEqual(item.title, "键盘高度")
        XCTAssertEqual(KeyboardHeightSettingsCopy.title, item.title)
        XCTAssertEqual(
            KeyboardHeightSettingsCopy.fullAccessExplanation,
            "开启完全访问可让设置更可靠；未开启也能调节并保存。")
        for query in ["键盘高度", "行高", "height"] {
            XCTAssertTrue(SettingsSearchCatalog.matches(query: query).contains(item))
        }
        XCTAssertEqual(Set(SettingsSearchCatalog.all.map(\.id)).count, SettingsSearchCatalog.all.count)
        XCTAssertNil(KeyboardHeightSettingsCopy.instructions.rangeOfCharacter(from: .decimalDigits))
    }

    @MainActor
    func testEachPageEntryGetsFreshMarkerButRedrawKeepsItStable() throws {
        let session = KeyboardHeightAdjustmentPageSession()
        XCTAssertNil(session.marker)
        session.beginIfNeeded()
        let first = try XCTUnwrap(session.marker)
        let prefix = "universe-keyboard:height-adjustment:v1:"
        XCTAssertTrue(first.hasPrefix(prefix))
        XCTAssertNotNil(UUID(uuidString: String(first.dropFirst(prefix.count))))
        session.beginIfNeeded()
        XCTAssertEqual(session.marker, first)
        session.end()
        XCTAssertNil(session.marker)
        session.beginIfNeeded()
        XCTAssertNotEqual(session.marker, first)
        let secondPage = KeyboardHeightAdjustmentPageSession()
        secondPage.beginIfNeeded()
        XCTAssertNotEqual(secondPage.marker, session.marker)
    }

    @MainActor
    func testInvisibleFieldHidesTextCaretSelectionAndAccessibility() {
        let host = KeyboardHeightInputHostView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        host.update(marker: marker())
        host.layoutIfNeeded()
        let field = host.textField
        XCTAssertTrue(host.accessibilityElementsHidden)
        XCTAssertFalse(host.isAccessibilityElement)
        XCTAssertTrue(field.accessibilityElementsHidden)
        XCTAssertFalse(field.isAccessibilityElement)
        XCTAssertNil(field.accessibilityValue)
        XCTAssertEqual(field.textColor, .clear)
        XCTAssertEqual(field.tintColor, .clear)
        XCTAssertEqual(field.borderStyle, .none)
        XCTAssertFalse(field.isHidden)
        XCTAssertTrue(field.isEnabled)
        XCTAssertFalse(field.isSecureTextEntry)
        XCTAssertFalse(host.point(inside: .zero, with: nil))
        XCTAssertEqual(field.caretRect(for: field.endOfDocument), .zero)
        if let range = field.textRange(from: field.beginningOfDocument, to: field.endOfDocument) {
            XCTAssertTrue(field.selectionRects(for: range).isEmpty)
        } else {
            XCTFail("Expected the synthetic marker range")
        }
        XCTAssertFalse(field.canPerformAction(#selector(UIResponderStandardEditActions.copy(_:)), withSender: nil))
    }

    @MainActor
    func testMarkerIsPreparedBeforeFocusAndCannotBeEditedByUserInput() {
        let host = HeightInputFocusSpy()
        let token = marker()
        host.update(marker: token)
        XCTAssertEqual(host.textField.text, token)
        XCTAssertEqual(host.focusRequests, 0)
        XCTAssertFalse(
            host.textField(
                host.textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "x"))
        XCTAssertEqual(host.textField.text, token)
        host.stop()
        XCTAssertNil(host.marker)
        XCTAssertTrue(host.textField.text?.isEmpty != false)
        XCTAssertFalse(host.textField.isFirstResponder)
    }

    @MainActor
    func testWindowAttachmentRequestsFocusOnceAndUpdateDoesNotReopen() async {
        let host = HeightInputFocusSpy()
        let token = marker()
        host.update(marker: token)
        let window = attach(host)
        defer { host.stop(); window.isHidden = true }
        await waitForFocus(host, count: 1)
        host.update(marker: token)
        await Task.yield()
        XCTAssertEqual(host.focusRequests, 1)
        XCTAssertEqual(host.markerAtFocus, token)
        host.stop()
        host.update(marker: token)
        await Task.yield()
        XCTAssertEqual(host.focusRequests, 1)
        host.update(marker: marker())
        await waitForFocus(host, count: 2)
        XCTAssertEqual(host.focusRequests, 2)
    }

    @MainActor
    func testEndAndDismantleCancelPendingFocusAndClearMarker() async {
        let session = KeyboardHeightAdjustmentPageSession()
        let host = HeightInputFocusSpy()
        session.inputHost = host
        session.beginIfNeeded()
        let window = attach(host)
        defer { window.isHidden = true }
        session.end()
        await Task.yield()
        XCTAssertNil(session.marker)
        XCTAssertNil(host.marker)
        XCTAssertEqual(host.focusRequests, 0)
        XCTAssertTrue(host.textField.text?.isEmpty != false)
        host.update(marker: marker())
        KeyboardHeightInputHost.dismantleUIView(host, coordinator: ())
        await Task.yield()
        XCTAssertNil(host.marker)
        XCTAssertEqual(host.focusRequests, 0)
    }

    @MainActor
    func testWindowRemovalStopsInputWithoutWaitingForSwiftUI() async {
        let host = HeightInputFocusSpy()
        host.update(marker: marker())
        let window = attach(host)
        defer { window.isHidden = true }
        await waitForFocus(host, count: 1)
        host.removeFromSuperview()
        XCTAssertNil(host.marker)
        XCTAssertTrue(host.textField.text?.isEmpty != false)
        XCTAssertFalse(host.textField.isFirstResponder)
    }

    @MainActor
    func testExplicitReopenUsesNewMarkerAndCloseClearsHostSynchronously() throws {
        let session = KeyboardHeightAdjustmentPageSession()
        let host = HeightInputFocusSpy()
        session.inputHost = host
        session.beginIfNeeded()
        let first = try XCTUnwrap(session.marker)
        XCTAssertEqual(host.textField.text, first)
        session.reopen()
        XCTAssertNotEqual(session.marker, first)
        XCTAssertEqual(host.textField.text, session.marker)
        session.end()
        XCTAssertNil(session.marker)
        XCTAssertNil(host.marker)
        XCTAssertTrue(host.textField.text?.isEmpty != false)
    }

    @MainActor
    private func marker() -> String {
        KeyboardHeightSettingsCopy.markerPrefix + UUID().uuidString
    }

    @MainActor
    private func attach(_ host: UIView) -> UIWindow {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = UIViewController()
        window.rootViewController?.view.addSubview(host)
        host.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        window.isHidden = false
        return window
    }

    @MainActor
    private func waitForFocus(_ host: HeightInputFocusSpy, count: Int) async {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(1))
        while host.focusRequests < count, clock.now < deadline { await Task.yield() }
        XCTAssertEqual(host.focusRequests, count)
    }
}

@MainActor
private final class HeightInputFocusSpy: KeyboardHeightInputHostView {
    var focusRequests = 0
    var markerAtFocus: String?
    override func requestInputFocus() {
        focusRequests += 1
        markerAtFocus = textField.text
    }
}
