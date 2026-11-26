import UIKit
import XCTest

@testable import KeyboardCore

/// PB-019-PR1-KEY-POPUP-CORE-001 red tests.
///
/// Covers `KeyCalloutView` (single-instance character key callout):
/// top-row/edge 3pt clamp + pointer offset geometry, Reduce Transparency /
/// Reduce Motion degradation, rollover migration without animation, and
/// force-hide / conditional dismiss semantics.
nonisolated final class KeyCalloutViewTests: XCTestCase {
    private let containerBounds = CGRect(x: 0, y: 0, width: 390, height: 260)

    // MARK: - Geometry (clamp + pointer offset)

    @MainActor
    func testTopRowLeadingKeyClampsBubbleToLeftEdgeAndOffsetsPointer() {
        // Key flush with the container edge: raw origin 0 must clamp to 3pt.
        let keyFrame = CGRect(x: 0, y: 56, width: 33, height: 45)
        let bubble = KeyCalloutView.bubbleFrame(for: keyFrame, containerBounds: containerBounds)

        XCTAssertEqual(bubble.minX, KeyCalloutView.edgeInset, accuracy: 0.001)
        XCTAssertEqual(bubble.width, keyFrame.width, accuracy: 0.001)
        XCTAssertEqual(bubble.height, KeyCalloutView.preferredHeight, accuracy: 0.001)
        XCTAssertEqual(bubble.maxY, keyFrame.minY - KeyCalloutView.gapAboveKey, accuracy: 0.001)

        let offset = KeyCalloutView.pointerOffset(for: keyFrame, bubbleFrame: bubble)
        // Bubble was clamped right of the key, so the arrow must point left.
        XCTAssertLessThan(offset, 0)
        XCTAssertEqual(offset, keyFrame.midX - bubble.midX, accuracy: 0.001)
    }

    @MainActor
    func testTopRowTrailingKeyClampsBubbleToRightEdgeAndOffsetsPointer() {
        // Key flush with the trailing edge: raw maxX must clamp to width - 3pt.
        let keyFrame = CGRect(x: 390 - 33, y: 56, width: 33, height: 45)
        let bubble = KeyCalloutView.bubbleFrame(for: keyFrame, containerBounds: containerBounds)

        XCTAssertEqual(bubble.maxX, containerBounds.width - KeyCalloutView.edgeInset, accuracy: 0.001)

        let offset = KeyCalloutView.pointerOffset(for: keyFrame, bubbleFrame: bubble)
        // Bubble was clamped left of the key, so the arrow must point right.
        XCTAssertGreaterThan(offset, 0)
        XCTAssertEqual(offset, keyFrame.midX - bubble.midX, accuracy: 0.001)
    }

    @MainActor
    func testMiddleKeyCentersBubbleWithoutPointerOffset() {
        let keyFrame = CGRect(x: 178.5, y: 150, width: 33, height: 45)
        let bubble = KeyCalloutView.bubbleFrame(for: keyFrame, containerBounds: containerBounds)

        XCTAssertEqual(bubble.midX, keyFrame.midX, accuracy: 0.001)
        let offset = KeyCalloutView.pointerOffset(for: keyFrame, bubbleFrame: bubble)
        XCTAssertEqual(offset, 0, accuracy: 0.001)
    }

    // MARK: - Reuse-pool lifecycle

    @MainActor
    func testShowFromHiddenAnimatesUnlessReduceMotion() {
        let callout = KeyCalloutView()
        callout.isHidden = true
        callout.reduceMotionOverride = false
        callout.show(
            character: "Q",
            keyFrame: CGRect(x: 4, y: 56, width: 33, height: 45),
            containerBounds: containerBounds
        )
        XCTAssertFalse(callout.isHidden)
        XCTAssertTrue(callout.lastTransitionAnimated)

        callout.dismiss()
        XCTAssertTrue(callout.isHidden)
        callout.reduceMotionOverride = true
        callout.show(
            character: "P",
            keyFrame: CGRect(x: 353, y: 56, width: 33, height: 45),
            containerBounds: containerBounds
        )
        XCTAssertFalse(callout.isHidden)
        XCTAssertFalse(callout.lastTransitionAnimated)
        XCTAssertEqual(callout.alpha, 1)
        XCTAssertEqual(callout.transform, .identity)
    }

    @MainActor
    func testMigrationWhileVisibleUpdatesTextAndFrameWithoutAnimation() {
        let callout = KeyCalloutView()
        callout.isHidden = true
        let firstKey = CGRect(x: 4, y: 56, width: 33, height: 45)
        let secondKey = CGRect(x: 200, y: 100, width: 33, height: 45)
        callout.reduceMotionOverride = false
        callout.show(character: "Q", keyFrame: firstKey, containerBounds: containerBounds)
        XCTAssertTrue(callout.lastTransitionAnimated)

        callout.show(character: "W", keyFrame: secondKey, containerBounds: containerBounds)
        XCTAssertFalse(callout.lastTransitionAnimated)
        XCTAssertEqual(callout.characterText, "W")
        XCTAssertEqual(
            callout.frame,
            KeyCalloutView.bubbleFrame(for: secondKey, containerBounds: containerBounds)
        )
    }

    @MainActor
    func testDismissIfSourceOnlyHidesMatchingSource() {
        let callout = KeyCalloutView()
        let source = UIButton()
        let other = UIButton()
        callout.sourceButton = source
        callout.isHidden = false

        callout.dismissIfSource(other)
        XCTAssertFalse(callout.isHidden)
        XCTAssertTrue(callout.sourceButton === source)

        callout.dismissIfSource(source)
        XCTAssertTrue(callout.isHidden)
        XCTAssertNil(callout.sourceButton)
    }

    @MainActor
    func testForceDismissClearsSourceAndHides() {
        let callout = KeyCalloutView()
        let source = UIButton()
        callout.sourceButton = source
        callout.isHidden = false

        callout.dismiss()
        XCTAssertTrue(callout.isHidden)
        XCTAssertNil(callout.sourceButton)
    }

    // MARK: - Passive overlay contract

    @MainActor
    func testCalloutIsPureDisplayLayer() {
        let callout = KeyCalloutView()
        XCTAssertFalse(callout.isUserInteractionEnabled)
        XCTAssertFalse(callout.isAccessibilityElement)
        XCTAssertFalse(callout.point(inside: CGPoint(x: 5, y: 5), with: nil))
    }

    @MainActor
    func testCharacterTypographyIsFixedSizeSemiboldLabel() {
        let callout = KeyCalloutView()
        callout.show(
            character: "A",
            keyFrame: CGRect(x: 100, y: 56, width: 33, height: 45),
            containerBounds: containerBounds
        )
        XCTAssertEqual(callout.characterText, "A")
        let font = try? XCTUnwrap(callout.characterFont)
        XCTAssertEqual(font?.pointSize, 22)
        let traits = font?.fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
        XCTAssertEqual(traits?[.weight] as? UIFont.Weight, .semibold)
    }

    // MARK: - Reduce Transparency degradation

    @MainActor
    func testReduceTransparencyDegradesToSolidFill() {
        let callout = KeyCalloutView()
        callout.reduceTransparencyOverride = true
        callout.applyChromeIfNeeded()

        let light = UITraitCollection(userInterfaceStyle: .light)
        let fill = callout.materialFillView.backgroundColor?
            .resolvedColor(with: light)
        let expected = UIColor.secondarySystemGroupedBackground.resolvedColor(with: light)
        XCTAssertEqual(fill, expected)
        XCTAssertNil(callout.materialFillView.effect)
        XCTAssertGreaterThan(callout.materialFillView.layer.borderWidth, 0)
    }

    @MainActor
    func testNonReducedTransparencyUsesMaterialEffect() {
        let callout = KeyCalloutView()
        callout.reduceTransparencyOverride = false
        callout.applyChromeIfNeeded()

        if #available(iOS 26.0, *) {
            XCTAssertTrue(callout.materialFillView.effect is UIGlassEffect)
        } else {
            XCTAssertTrue(callout.materialFillView.effect is UIBlurEffect)
        }
        XCTAssertEqual(
            callout.materialFillView.backgroundColor?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
                .cgColor.alpha,
            0
        )
    }
}
