---
name: keyboard-test-writer
description: Write comprehensive tests for the Universe Keyboard project. Covers KeyboardCore state machine tests (FakeTextInputClient + FakeRimeEngine pattern), RIME bridge integration tests, and unit tests for extractable pure logic from UIKit layer. Use when the user says "加测试", "写测试", "测试覆盖", "add tests", "write tests", or when code changes touch Keyboard/Controllers/, Keyboard/RimeBridge/, or Packages/KeyboardCore/.
---

# Keyboard Test Writer

## Quick start

Tests go under `Packages/KeyboardCore/Tests/KeyboardCoreTests/`. Always use `@testable import KeyboardCore`.

**Standard setUp:**

```swift
var controller: KeyboardController!
var client: FakeTextInputClient!

override func setUp() {
    super.setUp()
    client = FakeTextInputClient()
    controller = KeyboardController()
    controller.textClient = client
}
```

If testing RIME path, add `engine: FakeRimeEngine!` with `controller.rimeEngine = engine`.

**Single test pattern:** precondition → `controller.handle(.action)` → assert `client.text` / `controller.state`.

After writing tests, always run `swift test` in `Packages/KeyboardCore/` to verify.

## Workflows

### 1. Add RIME Bridge Tests (Priority 1)

Target: `RimeEngineImpl.swift` (590 lines, keycode translation, schema verification, output parsing).

Test file: `Packages/KeyboardCore/Tests/KeyboardCoreTests/RimeEngineImplTests.swift`

Focus on pure-logic methods that don't need real librime:
- `keycode(for:)` — map 20+ character/key combinations to X11 keysyms
- `parseOutput(_:)` — though private, test via `processKey` through FakeRimeEngine
- Schema verification logic is tested indirectly via `FakeRimeEngine`

See [REFERENCE.md](REFERENCE.md) for all RimeEngine protocol methods and return types.

### 2. Add KeyboardCore Boundary Tests (Priority 2)

Target: existing test files. Expand coverage for edge cases.

**Candidate insertion:**
- `.insertCandidate` with `.composition` kind (commit raw pinyin)
- `.insertCandidate` with `.placeholder` kind (no-op)
- Candidate selection when composition is empty
- Selecting out-of-range candidate index

**Deletion edge cases:**
- Delete with empty composition AND empty text field
- Delete after committing last character
- Delete with inline preedit tracking (`insertedPreeditCount`)

**Input mode switching:**
- Toggle mode mid-composition → composition should commit
- Output after toggle should reflect new mode

### 3. Add UIKit Pure-Logic Tests (Priority 3)

Extract testable pure logic from `Keyboard/Controllers/`:

| File | Extractable Method | Test File |
|------|-------------------|-----------|
| `CandidateButtonFactory.swift` | `candidateConfiguration()` | `CandidateButtonFactoryTests.swift` |
| `+Display.swift` | `returnKeyTitle`, `pageSwitchTitle`, `shiftButtonTitle` | `DisplayLogicTests.swift` |
| `+KeyFactory.swift` | `displayTitle(for:)`, `backgroundForStyle(_:)` | (existing) |
| `KeyboardType+UIKit.swift` | `KeyboardType.from(uiKeyboardType:)` | `KeyboardTypeUITests.swift` |

See [EXAMPLES.md](EXAMPLES.md) for concrete test implementations.

### 4. Run Verification

```bash
cd Packages/KeyboardCore && swift test
```

All existing tests must still pass. New test file must compile with `@testable import KeyboardCore`.

## Priority order

1. RIME Bridge pure-logic (keycode translation, output parsing)
2. KeyboardController boundary cases (candidate kinds, edge states)
3. UIKit extractable logic (CandidateButtonFactory, display properties)

## Rules

- Never modify existing test behavior — only add new tests
- Always run full test suite after adding tests
- Tests must compile on macOS (KeyboardCore has no iOS-only dependencies)
- Use existing `FakeTextInputClient` and `FakeRimeEngine` — don't create new mocks unless needed
- Keep tests in `Packages/KeyboardCore/Tests/KeyboardCoreTests/`
