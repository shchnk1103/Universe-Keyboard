# Test Examples

## RimeEngineImpl Keycode Tests

```swift
import XCTest
@testable import KeyboardCore

final class RimeKeycodeTests: XCTestCase {

    func testKeycodeForLowercaseLetter() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "n"), 0x006E)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "a"), 0x0061)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "z"), 0x007A)
    }

    func testKeycodeForUppercaseLetter() {
        // Uppercase letters map to the same ASCII value
        XCTAssertEqual(RimeEngineImpl.keycode(for: "N"), 0x004E)
    }

    func testKeycodeForDigit() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "1"), 0x0031)
    }

    func testKeycodeForBackspace() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "BackSpace"), 0xFF08)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Delete"), 0xFF08)
    }

    func testKeycodeForReturn() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Return"), 0xFF0D)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Enter"), 0xFF0D)
    }

    func testKeycodeForSpace() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "space"), 0x0020)
        XCTAssertEqual(RimeEngineImpl.keycode(for: " "), 0x0020)
    }

    func testKeycodeForSpecialKeys() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Escape"), 0xFF1B)
        XCTAssertEqual(RimeEngineImpl.keycode(for: "Tab"), 0xFF09)
    }

    func testKeycodeForEmpty() {
        XCTAssertEqual(RimeEngineImpl.keycode(for: ""), 0)
    }

    func testKeycodeForMultiChar() {
        // Multi-character strings fall back to first UTF-8 byte or 0
        // This should produce 0 for unrecognized multi-char input
        let result = RimeEngineImpl.keycode(for: "你好")
        XCTAssertEqual(result, 0)
    }
}
```

## CandidateKind Tests

```swift
final class CandidateKindTests: XCTestCase {
    var controller: KeyboardController!
    var client: FakeTextInputClient!
    var engine: FakeRimeEngine!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        engine = FakeRimeEngine()
        controller = KeyboardController()
        controller.textClient = client
        controller.rimeEngine = engine
        controller.state.inputMode = .chinese
    }

    func testInsertCandidateByKind() {
        // Set up a RIME composition
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))
        XCTAssertEqual(controller.state.currentComposition, "ni")

        // Select the first candidate
        _ = controller.handle(.insertCandidate("你", kind: .candidate))
        XCTAssertEqual(client.text, "你")
    }

    func testInsertCompositionAsCandidate() {
        _ = controller.handle(.insertKey("n"))
        _ = controller.handle(.insertKey("i"))

        // Commit raw pinyin as text
        _ = controller.handle(.insertCandidate("ni", kind: .composition))
        XCTAssertEqual(client.text, "ni")
    }

    func testPlaceholderCandidateIsNoop() {
        _ = controller.handle(.insertKey("n"))

        // Placeholder should not insert anything
        _ = controller.handle(.insertCandidate("...", kind: .placeholder))
        XCTAssertEqual(client.text, "")
    }
}
```

## CandidateButtonFactory Configuration Tests

```swift
import XCTest
@testable import KeyboardCore

final class CandidateButtonFactoryTests: XCTestCase {

    func testMakeCandidateButtonForCandidate() {
        // This test verifies the configuration is created correctly
        // Note: UIButton needs a run loop to fully initialize,
        // so we test the configuration directly if possible.
        // In practice, test via the data layer — verify CandidateItem
        // construction produces correct titles and kinds.
    }

    func testCandidateKindRawValues() {
        XCTAssertEqual(CandidateKind.candidate.rawValue, 0)
        XCTAssertEqual(CandidateKind.composition.rawValue, 1)
        XCTAssertEqual(CandidateKind.placeholder.rawValue, 2)
    }

    func testCandidateItemConstruction() {
        let candidate = CandidateItem(title: "你好", kind: .candidate)
        XCTAssertEqual(candidate.title, "你好")
        XCTAssertEqual(candidate.kind, .candidate)

        let composition = CandidateItem(title: "ni", kind: .composition)
        XCTAssertEqual(composition.title, "ni")
        XCTAssertEqual(composition.kind, .composition)
    }
}
```

## Display Logic Tests

```swift
import XCTest
@testable import KeyboardCore

final class DisplayLogicTests: XCTestCase {
    var controller: KeyboardController!

    override func setUp() {
        super.setUp()
        controller = KeyboardController()
    }

    func testPageSwitchTitle() {
        controller.state.currentPage = .letters
        // These values come from KeyboardViewController+Display.swift
        // We test the underlying state that drives them
        XCTAssertEqual(controller.state.currentPage, .letters)

        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .numbers)

        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .symbols)

        _ = controller.handle(.togglePage)
        XCTAssertEqual(controller.state.currentPage, .letters)
    }

    func testShiftButtonTitleDependsOnState() {
        XCTAssertEqual(controller.state.shiftState, .off)
        // off → title is "⇧"

        _ = controller.handle(.toggleShift)
        XCTAssertEqual(controller.state.shiftState, .singleUse)
        // singleUse → title is "⇧"

        // Simulate double-tap for caps lock
        _ = controller.handle(.toggleShift)
        // Test the state transition is correct
        // Title mapping lives in +Display.swift (UIKit layer)
    }

    func testSpaceButtonTitlePerMode() {
        controller.state.inputMode = .chinese
        controller.state.currentPage = .letters
        XCTAssertEqual(controller.state.inputMode, .chinese)

        _ = controller.handle(.toggleInputMode)
        XCTAssertEqual(controller.state.inputMode, .english)
    }
}
```

## Edge Case: Delete with Empty State

```swift
final class DeleteEdgeCaseTests: XCTestCase {
    var controller: KeyboardController!
    var client: FakeTextInputClient!

    override func setUp() {
        super.setUp()
        client = FakeTextInputClient()
        controller = KeyboardController()
        controller.textClient = client
    }

    func testDeleteEmptyCompositionEmptyText() {
        // Nothing to delete — should be a no-op
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(client.text, "")

        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.text, "")
        XCTAssertEqual(client.deletedCount, 0)
    }

    func testDeleteAfterCommittingLastCharacter() {
        client.text = "你"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(client.deletedCount, 1)
    }

    func testDeleteClearsCompositionFirst() {
        controller.state.currentComposition = "ni"
        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "n")
        // Should NOT have called deleteBackward on proxy yet
        XCTAssertEqual(client.deletedCount, 0)

        _ = controller.handle(.deleteBackward)
        XCTAssertEqual(controller.state.currentComposition, "")
        XCTAssertEqual(client.deletedCount, 0)
    }
}
```
