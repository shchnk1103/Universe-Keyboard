import UIKit
import XCTest

@testable import KeyboardCore

/// Uses the production key class, AX configuration and recovery adapter.
/// The lightweight owner supplies selectors only; this is not Extension activation.
nonisolated final class KeyRecoveryAccessibilityTests: XCTestCase {
    @MainActor
    func testDisabledProductionKeysRejectHitsAndPublishUnavailable() throws {
        let fixture = Fixture()
        fixture.freeze()
        fixture.owner.refreshT9InputRecoveryPresentation()
        fixture.attachSnapshot("disabled")
        for key in [fixture.space, fixture.returnKey] {
            XCTAssertFalse(key.isEnabled)
            XCTAssertFalse(key.point(inside: fixture.center(of: key), with: nil))
            XCTAssertFalse(fixture.owner.view.hitTest(key.center, with: nil) === key)
            XCTAssertTrue(key.accessibilityTraits.contains(.keyboardKey))
            // A disabled keyboard key must also publish the unavailable trait.
            XCTAssertTrue(key.accessibilityTraits.contains(.notEnabled))
        }
    }

    @MainActor
    func testRecoveryRestoresHitRoutingAndTargetRegistration() throws {
        let fixture = Fixture()
        fixture.freeze()
        fixture.owner.refreshT9InputRecoveryPresentation()
        fixture.owner.controller.t9ExactRetypeRecovery = T9ExactRetypeRecovery()
        fixture.owner.refreshT9InputRecoveryPresentation()
        fixture.attachSnapshot("restored")
        for key in [fixture.space, fixture.returnKey] {
            XCTAssertTrue(key.isEnabled)
            XCTAssertTrue(key.point(inside: fixture.center(of: key), with: nil))
            XCTAssertTrue(fixture.owner.view.hitTest(key.center, with: nil) === key)
            XCTAssertFalse(key.accessibilityTraits.contains(.notEnabled))
            // A hostless component proves registration, not UIApplication event delivery.
            let action = key === fixture.space ? "insertSpace:" : "insertReturn:"
            XCTAssertEqual(key.actions(forTarget: fixture.owner, forControlEvent: .touchUpInside), [action])
        }
    }

    @MainActor
    func testMetadataRefreshPreservesDisabledKeySemantics() throws {
        let fixture = Fixture()
        fixture.freeze()
        fixture.owner.refreshT9InputRecoveryPresentation()
        fixture.configureMetadata()
        fixture.owner.refreshT9InputRecoveryPresentation()
        fixture.attachSnapshot("metadata-refreshed-then-disabled")
        XCTAssertFalse(fixture.space.isEnabled)
        XCTAssertFalse(fixture.space.point(inside: fixture.center(of: fixture.space), with: nil))
        XCTAssertTrue(fixture.space.accessibilityTraits.contains(.notEnabled))
        XCTAssertFalse(fixture.returnKey.isEnabled)
        XCTAssertTrue(fixture.returnKey.accessibilityTraits.contains(.notEnabled))
    }

    @MainActor
    private final class Fixture {
        let owner = KeyboardViewController()
        let space = KeyboardKeyButton(type: .custom)
        let returnKey = KeyboardKeyButton(type: .custom)
        let select = UIButton(type: .custom)

        init() {
            owner.view.frame = CGRect(x: 0, y: 0, width: 390, height: 200)
            owner.controller.state.inputMode = .chinese
            owner.controller.state.currentPage = .letters
            space.frame = CGRect(x: 10, y: 10, width: 140, height: 45)
            returnKey.frame = CGRect(x: 160, y: 10, width: 76, height: 100)
            select.frame = CGRect(x: 10, y: 130, width: 90, height: 45)
            for key in [space, returnKey, select] { owner.view.addSubview(key) }
            owner.t9SpaceButton = space
            owner.returnButton = returnKey
            owner.t9SelectPinyinButton = select
            configureMetadata()
            space.addTarget(owner, action: #selector(KeyboardViewController.insertSpace(_:)), for: .touchUpInside)
            returnKey.addTarget(owner, action: #selector(KeyboardViewController.insertReturn(_:)), for: .touchUpInside)
        }

        func configureMetadata() {
            owner.configureKeyAccessibility(
                space, title: "选定", action: #selector(KeyboardViewController.insertSpace(_:)))
            owner.configureKeyAccessibility(
                returnKey, title: "return", action: #selector(KeyboardViewController.insertReturn(_:)))
        }

        func freeze() {
            owner.controller.t9ExactRetypeRecovery.freeze(
                verifiedDigits: "94624",
                namespace: T9ExactRetypeRecovery.Namespace(ownerID: UUID(), sessionEpoch: 1, editingGeneration: 0),
                terminal: false)
        }

        func center(of key: UIButton) -> CGPoint {
            CGPoint(x: key.bounds.midX, y: key.bounds.midY)
        }

        func attachSnapshot(_ phase: String) {
            let states = [space, returnKey].map { key in
                "id=\(key.accessibilityIdentifier ?? "missing");enabled=\(key.isEnabled)"
                    + ";keyboardKey=\(key.accessibilityTraits.contains(.keyboardKey))"
                    + ";notEnabled=\(key.accessibilityTraits.contains(.notEnabled))"
                    + ";pointInside=\(key.point(inside: center(of: key), with: nil))"
            }
            let attachment = XCTAttachment(string: (["phase=" + phase] + states).joined(separator: "\n"))
            attachment.name = "Real key recovery UIKit state - " + phase
            attachment.lifetime = .keepAlways
            XCTContext.runActivity(named: "Capture actual key state before assertions") { $0.add(attachment) }
        }
    }
}

// Compile-only selector dependencies of the production AX configuration. Only
// Space/Return registrations are inspected above; system event delivery is separate.
extension KeyboardViewController {
    @objc func deleteKeyTouchUpInside(_ sender: UIButton, forEvent event: UIEvent) {}
    @objc func toggleShift(_ sender: UIButton) {}
    @objc func handleInputModeList(from sender: UIView, with event: UIEvent) {}
    @objc func toggleKeyboardPage(_ sender: UIButton) {}
    @objc func toggleInputMode(_ sender: UIButton) {}
    @objc func insertSpace(_ sender: UIButton) {}
    @objc func insertReturn(_ sender: UIButton) {}
    @objc func insertKaomoji(_ sender: UIButton) {}
    @objc func showKaomojiCandidatesPlaceholder(_ sender: UIButton) {}
}
