# Testing Patterns Reference

## Mock Infrastructure

### FakeTextInputClient

Located at `Packages/KeyboardCore/Sources/KeyboardCore/FakeTextInputClient.swift` (in Sources, not Tests — production code can also use it).

```swift
public final class FakeTextInputClient: TextInputClient {
    public internal(set) var text: String = ""
    public internal(set) var deletedCount = 0
}
```

- `text` accumulates all `insertText` calls (appends, never clears)
- `deletedCount` counts `deleteBackward` calls
- Tests can set `client.text = ""` to reset

### FakeRimeEngine

Located at `Packages/KeyboardCore/Tests/KeyboardCoreTests/FakeRimeEngine.swift`.

Hardcoded dictionary: `"ni" → ["你","呢","尼"]`, `"hao" → ["好","号","浩"]`, `"nihao" → ["你好","拟好","你号"]`, `"shi" → ["是","时","事"]`, `"wo" → ["我","握","窝"]`.

- `processKey` accumulates characters into composition (lowercased)
- `selectCandidate` commits dictionary text and clears composition
- `sessionResetCount` tracks `resetSession()` calls (not in protocol — extra tracking)
- Unknown compositions produce empty candidates with `highlightedIndex: -1`

## RimeEngine Protocol

```swift
public protocol RimeEngine: AnyObject {
    func processKey(_ key: String) -> RimeOutput
    func selectCandidate(at index: Int) -> RimeOutput
    func deleteBackward() -> RimeOutput
    func resetSession()
    func isComposing() -> Bool
}
```

## RimeOutput Structure

```swift
public struct RimeOutput {
    public let composition: RimeComposition?    // nil = no active composition
    public let candidates: [RimeCandidate]      // empty = no candidates
    public let committedText: String?           // nil = nothing committed yet
    public let hasMorePages: Bool               // default false
    public let highlightedIndex: Int            // -1 = no highlight
}

public struct RimeComposition {
    public let preeditText: String
    public let cursorPosition: Int
}

public struct RimeCandidate {
    public let text: String
    public let comment: String?
}
```

## KeyboardAction Enum (all cases)

```swift
public enum KeyboardAction {
    case insertKey(String)                              // "a", "H", "BackSpace"
    case insertSpace
    case insertReturn
    case deleteBackward
    case insertCandidate(String, kind: CandidateKind)   // .candidate / .composition / .placeholder
    case insertDirectText(String)                       // "@", ".", ".com"
    case toggleShift
    case togglePage
    case toggleInputMode
    case keyboardTypeChanged(KeyboardType)
}
```

## CandidateKind Enum

```swift
public enum CandidateKind: Int {
    case candidate = 0    // normal selectable candidate
    case composition = 1  // raw pinyin string (can commit as-is)
    case placeholder = 2  // visual placeholder, no-op on tap
}
```

## KeyboardEffect OptionSet

```swift
public struct KeyboardEffect: OptionSet {
    public let rawValue: Int
    public static let compositionChanged = KeyboardEffect(rawValue: 1 << 0)
    public static let pageChanged        = KeyboardEffect(rawValue: 1 << 1)
    public static let inputModeChanged   = KeyboardEffect(rawValue: 1 << 2)
    public static let shiftStateChanged  = KeyboardEffect(rawValue: 1 << 3)
    public static let keyboardTypeChanged = KeyboardEffect(rawValue: 1 << 4)
}
```

## State Properties to Assert On

```swift
controller.state.currentComposition  // String — pinyin buffer
controller.state.inputMode           // .chinese / .english
controller.state.shiftState          // .off / .singleUse / .capsLock
controller.state.currentPage         // .letters / .numbers / .symbols
controller.state.activeKeyboardType  // .default / .emailAddress / .URL / .webSearch
controller.state.lastRimeOutput      // RimeOutput? — nil when RIME not active
controller.state.insertedPreeditCount // Int — inline preedit tracking
```

## RimeEngineImpl Keycode Translation

```swift
static func keycode(for key: String) -> Int32
```

Mappings:
- `"BackSpace"` / `"Delete"` → `0xFF08`
- `"Return"` / `"Enter"` → `0xFF0D`
- `"space"` / `" "` → `0x0020`
- `"Escape"` → `0xFF1B`
- `"Tab"` → `0xFF09`
- Single ASCII char (`a-z`, `A-Z`, `0-9`, punctuation) → Unicode scalar value

## RimeConfigManager Testable Pure Logic

```swift
static func currentPageSize() -> Int       // reads UserDefaults, returns 5-20
static func currentSimplification() -> Bool // default true
static func setPageSize(_ value: Int)       // clamps 5-20, writes custom.yaml
static func setSimplification(_ simplified: Bool)
```

## Existing Test Files (14 files, 225 tests)

| File | Test Count | Domain |
|------|-----------|--------|
| UnzipTests.swift | 37 | ZIP extraction |
| AutoCapitalizeTests.swift | 29 | Auto-cap rules |
| RimeConfigTests.swift | 27 | Config YAML generation |
| RimeControllerTests.swift | 27 | RIME engine integration via controller |
| RimeConfigPostProcessorTests.swift | 25 | Lua stripping + schema repair |
| CompositionTests.swift | 23 | Pinyin composition |
| ShiftStateTests.swift | 12 | Shift toggle logic |
| PageSwitchTests.swift | 12 | Letter/number/symbol pages |
| SpaceReturnTests.swift | 9 | Space + Return behavior |
| LoggerTests.swift | 7 | Ring buffer logging |
| InputModeTests.swift | 6 | Chinese/English toggle |
| KeyboardTypeTests.swift | 6 | Keyboard type handling |
| DeleteTests.swift | 5 | Backspace logic |
| FakeRimeEngine.swift | 0 | Mock (helper, not tests) |

## Running Tests

```bash
cd Packages/KeyboardCore && swift test
```
