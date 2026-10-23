import UIKit
import XCTest

@testable import KeyboardCore

/// 真实 UIKit 约束测试；省略引擎 bootstrap，不等同于系统激活的扩展。
nonisolated final class KeyboardHeightControllerTests: XCTestCase {
    @MainActor
    func testUnpreparedHeightManagementKeepsSceneLessWindowTouchable() throws {
        let owner = makeOwner(saved: nil, nineKey: true)
        owner.keyboardHeightGeometrySource = { nil }
        owner.setupRootStack()
        owner.reloadKeyboard()
        layout(owner)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        let host = UIViewController()
        window.rootViewController = host
        host.view.addSubview(owner.view)
        window.isHidden = false
        defer { window.isHidden = true }
        owner.synchronizeKeyboardHeightLayout()
        layout(owner)
        let key = try XCTUnwrap(
            descendants(owner.rootStack).compactMap { $0 as? KeyboardKeyButton }.first {
                $0.accessibilityIdentifier == "6"
            })
        let point = key.convert(CGPoint(x: key.bounds.midX, y: key.bounds.midY), to: owner.view)
        let hit = owner.view.hitTest(point, with: nil)
        XCTAssertFalse(owner.isKeyboardHeightManaged)
        XCTAssertNil(owner.keyboardHeightStatus)
        XCTAssertEqual(owner.view.alpha, 1)
        XCTAssertTrue(owner.keyboardHeightConstraint?.isActive == true)
        XCTAssertTrue(hit === key || hit?.isDescendant(of: key) == true)
    }

    @MainActor
    func testMissingSceneDefersFirstRequestAndReadsPreferenceOnlyOnce() throws {
        let owner = makeOwner(saved: nil)
        var reads = 0
        owner.keyboardRowHeightSource = {
            reads += 1; return 70
        }
        owner.keyboardHeightGeometrySource = { nil }
        owner.prepareKeyboardHeightForAppearance()
        owner.installPreferredKeyboardHeight()
        owner.installKeyboardUIIfNeeded()
        XCTAssertNil(owner.keyboardHeightConstraint)
        XCTAssertFalse(owner.isKeyboardUIInstalled)
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertEqual(owner.keyboardHeightStatus, "waitingForWindowScene")
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
        XCTAssertTrue(owner.isKeyboardUIInstalled)
        XCTAssertEqual(owner.view.alpha, 1)
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(reads, 1)
    }

    @MainActor
    func testDefaultPagesKeepOriginalGeometry() throws {
        XCTAssertEqual(KeyboardHeightSettings.defaultRowHeight, 45)
        XCTAssertEqual(KeyboardDesignTokens.CandidateBar.totalHeight, 46)
        XCTAssertEqual(KeyboardDesignTokens.T9PinyinBar.visibleHeight, 34)
        XCTAssertEqual(KeyboardViewController.defaultKeyboardHeightWithoutPath, 254)
        for page in [KeyboardPage.letters, .numbers, .symbols, .emoji] {
            let owner = makeOwner(saved: nil)
            owner.controller.state.currentPage = page
            install(owner)
            XCTAssertEqual(owner.keyHeight, 45)
            XCTAssertEqual(owner.preferredKeyboardHeight, 254)
            XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 254)
            XCTAssertEqual(owner.candidateBarHeight, 46)
            assertRowConstraints(owner, rowHeight: 45)
            attachLayout(owner, name: "default-\(page)")
        }
        let nineKey = makeOwner(saved: nil, nineKey: true)
        install(nineKey)
        showPath(nineKey)
        layout(nineKey)
        XCTAssertEqual(nineKey.preferredKeyboardHeight, 288)
        XCTAssertEqual(nineKey.keyboardHeightConstraint?.constant, 288)
        XCTAssertEqual(nineKey.t9PinyinPathBarView?.frame.height, 34)
        assertRowConstraints(nineKey, rowHeight: 45)
        attachLayout(nineKey, name: "default-nine-key-path")
    }

    @MainActor
    func testSavedHeightDrivesAllPagesAndDerivedConstraints() {
        for page in [KeyboardPage.letters, .numbers, .symbols, .emoji] {
            let owner = makeOwner(saved: 70)
            owner.controller.state.currentPage = page
            install(owner)
            XCTAssertEqual(owner.keyHeight, 70)
            XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
            assertRowConstraints(owner, rowHeight: 70)
            if page == .emoji {
                XCTAssertTrue(
                    owner.keyboardHeightConstraints.contains {
                        $0.rows == 3 && $0.constraint?.constant == 226
                    })
            }
            attachLayout(owner, name: "row70-\(page)")
        }
        let owner = makeOwner(saved: 70, nineKey: true)
        install(owner)
        showPath(owner)
        let panel = owner.makePinyinPathExpandedPanel()
        XCTAssertEqual(
            panel.constraints.first { $0.firstAttribute == .height && $0.relation == .greaterThanOrEqual }?.constant,
            304)
        XCTAssertTrue(
            owner.keyboardHeightConstraints.contains {
                $0.rows == 4 && $0.extraHeight == 26 && $0.constraint?.constant == 306
            })
        assertRowConstraints(owner, rowHeight: 70)
    }

    @MainActor
    func testPathAppearanceRecomputesCapWithoutChangingPreference() {
        let owner = makeOwner(saved: 100, nineKey: true)
        install(owner)
        XCTAssertEqual(owner.keyHeight, 87)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 422)
        showPath(owner)
        layout(owner)
        XCTAssertEqual(owner.keyHeight, 78)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 420)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 100)
        assertRowConstraints(owner, rowHeight: 78)
    }

    @MainActor
    func testRotationAndHostCompressionDoNotWriteBackOrReloadRows() {
        let owner = makeOwner(saved: 70)
        install(owner)
        let originalRows = owner.rootStack.arrangedSubviews.map(ObjectIdentifier.init)
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 390, isLandscape: true) }
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 45)
        assertRowConstraints(owner, rowHeight: 45)
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 70)
        owner.keyboardAcceptedHeight = 274
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 50)
        XCTAssertEqual(owner.preferredKeyboardHeight, 274)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 70)
        XCTAssertEqual(owner.rootStack.arrangedSubviews.map(ObjectIdentifier.init), originalRows)
        assertRowConstraints(owner, rowHeight: 50)
    }

    @MainActor
    func testNextAppearanceReadsNewValueBeforeUpdatingExistingRows() {
        let owner = makeOwner(saved: 60)
        var saved = 60
        owner.keyboardRowHeightSource = { saved }
        install(owner)
        saved = 70
        owner.prepareKeyboardHeightForAppearance()
        XCTAssertEqual(owner.keyHeight, 60)
        owner.keyboardHeightNeedsRead = true
        owner.prepareKeyboardHeightForAppearance()
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyHeight, 70)
        XCTAssertEqual(owner.keyboardHeightConstraint?.constant, 354)
        assertRowConstraints(owner, rowHeight: 70)
    }

    @MainActor
    func testImpossibleHostBudgetIsReportedWithoutLoweringMinimum() {
        let owner = makeOwner(saved: 70)
        install(owner)
        owner.keyboardAcceptedHeight = 216
        owner.synchronizeKeyboardHeightLayout()
        XCTAssertEqual(owner.keyboardHeightStatus, "hostBudgetBelowMinimum")
        XCTAssertEqual(owner.view.alpha, 0)
        XCTAssertFalse(owner.keyboardHeightConstraint?.isActive ?? true)
        XCTAssertGreaterThanOrEqual(owner.keyHeight, CGFloat(KeyboardHeightSettings.minimumRowHeight))
        XCTAssertEqual(owner.keyboardHeightSettings.savedRowHeight, 70)
    }

    @MainActor
    private func makeOwner(saved: Int?, nineKey: Bool = false) -> HeightLayoutController {
        let owner = HeightLayoutController()
        owner.loadViewIfNeeded()
        owner.controller = KeyboardController(state: KeyboardState())
        owner.cachedLayoutStyle = nineKey ? .nineKey : .twentySixKey
        owner.cachedT9ReadinessMatched = nineKey
        owner.keyboardRowHeightSource = { saved }
        owner.keyboardHeightGeometrySource = { .init(screenHeight: 844, isLandscape: false) }
        return owner
    }

    @MainActor
    private func install(_ owner: KeyboardViewController) {
        owner.prepareKeyboardHeightForAppearance()
        owner.installPreferredKeyboardHeight()
        owner.installKeyboardUIIfNeeded()
        layout(owner)
    }

    @MainActor
    private func showPath(_ owner: KeyboardViewController) {
        owner.controller.state.t9PinyinPathState = .init(trackedRawInput: "64")
        owner.refreshT9PinyinPathBar()
    }

    @MainActor
    private func layout(_ owner: KeyboardViewController) {
        owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: owner.preferredKeyboardHeight)
        owner.view.setNeedsLayout()
        owner.view.layoutIfNeeded()
        owner.rootStack.layoutIfNeeded()
    }

    @MainActor
    private func assertRowConstraints(
        _ owner: KeyboardViewController, rowHeight: CGFloat,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        for entry in owner.keyboardHeightConstraints where entry.constraint?.isActive == true {
            XCTAssertEqual(
                entry.constraint?.constant, rowHeight * entry.rows + entry.extraHeight,
                file: file, line: line)
        }
    }

    @MainActor
    private func descendants(_ view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants($0) }
    }

    @MainActor
    private func attachLayout(_ owner: KeyboardViewController, name: String) {
        let image = UIGraphicsImageRenderer(size: owner.view.bounds.size).image { context in
            owner.view.layer.render(in: context.cgContext)
        }
        let attachment = XCTAttachment(image: image)
        attachment.name = "ui4-p2-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

@MainActor
private final class HeightLayoutController: KeyboardViewController {
    override func viewDidLoad() {
        // 只验证布局，不启动 RIME 或共享存储链路。
    }
}
