import XCTest

@testable import Universe_Keyboard

final class AppAboutContactTests: XCTestCase {
    func testFeedbackMailSubjectIncludesVersionAndBuild() {
        XCTAssertEqual(
            AppAboutContact.feedbackMailSubject(version: "1.0", build: "55"),
            "Universe Keyboard 反馈 · 1.0 (Build 55)"
        )
    }

    func testFeedbackMailtoUsesLockedAddressAndPrefillsSubject() {
        let url = AppAboutContact.feedbackMailtoURL(version: "1.0", build: "55")
        XCTAssertEqual(url?.scheme, "mailto")
        XCTAssertEqual(url?.path, AppAboutContact.emailAddress)
        XCTAssertEqual(AppAboutContact.emailAddress, "doubleshy0n@gmail.com")
        let subject = URLComponents(url: url!, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "subject" })?
            .value
        XCTAssertEqual(subject, "Universe Keyboard 反馈 · 1.0 (Build 55)")
    }

    func testXiaohongshuURLMatchesTheLockedShortLink() {
        XCTAssertEqual(
            AppAboutContact.xiaohongshuURL.absoluteString,
            "https://xhslink.cn/o/7lEn4EM0BtP"
        )
    }
}
