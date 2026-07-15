# PROJECT_CONTEXT.md

> **Maintenance Rule:** Do NOT add "Recent changes", chronological logs, or dated current-status snapshots to this file. All historical changes and status updates must go to `CHANGELOG.md`. Keep this file focused on permanent architecture, design decisions, and implementation constraints.

Documentation ownership and update triggers are defined in `docs/DOCUMENTATION_GOVERNANCE.md`; this file is the architecture overview, not the source for history, debugging procedures or release evidence.

This file provides durable project context for AI assistants working with code in this repository.

## Project Overview

Universe Keyboard is an iOS third-party custom keyboard with RIME-powered Chinese input. It has two product targets plus four test targets (`RimeBridgeTests`, `UniverseKeyboardTests`, `KeyboardTests`, and `UniverseKeyboardUITests`):

- **`Universe Keyboard`** (main App) — SwiftUI app (two tabs: Guide / Settings) for keyboard setup, RIME deployment, and feedback configuration.
- **`Keyboard`** (Keyboard Extension, `Keyboard.appex`) — the actual keyboard that appears in other apps. Built with UIKit (`UIInputViewController`). Primary language: `zh-Hans`.

The original development plan is archived as a historical reference in `docs/plans/ios-rime-keyboard-development-plan.md` (Superseded). Current architecture and decisions are governed by this document, `docs/architecture/` (including ADRs), `CONTEXT_INDEX.md`, and the Knowledge OS system.

## UI Style Guide

All UI work must follow `docs/UI_STYLE_GUIDE.md`.

- Read it before changing `Universe Keyboard/` SwiftUI screens or `Keyboard/` UIKit views.
- Keep the keyboard close to native iOS keyboard appearance: system gray surface, high-contrast keys, readable candidates, compact stable layout.
- Keep the main app close to native iOS Settings: grouped backgrounds, compact rows, reusable components, no marketing-style decoration.
- After UI code changes, build with:

```bash
xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'generic/platform=iOS Simulator' build
```

## Status And History

This file does not track the latest project status. Use `CHANGELOG.md` for recent changes, milestone progress, and dated status snapshots.

The durable implementation constraints are:

- Both targets are expected to build with Swift 6 strict concurrency.
- RIME production bridge code belongs in `Packages/RimeBridge`; do not recreate bridge sources in app or extension targets.
- Do not silence concurrency issues with `@unchecked Sendable` or unsafe isolation.
- Full RIME deployment is owned by the main App; the Keyboard Extension runtime path is session-only.
- Lua and release-readiness validation status belongs in `CHANGELOG.md` and `docs/architecture/swift6-manual-acceptance.md`.


## Build & Run

- Open `Universe Keyboard.xcodeproj` in Xcode (requires Xcode 26.4+, iOS 26.4+ deployment target).
- Bundle ID: `com.DoubleShy0N.Universe-Keyboard`, Keyboard extension: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Team: `C33N6HTS9N`, code signing is automatic.
- To test the keyboard: run the Keyboard extension target on a simulator/device, then enable it in Settings → General → Keyboard → Keyboards → Add New Keyboard → Keyboard.
- Build with `xcodebuild -project "Universe Keyboard.xcodeproj" -scheme "Universe Keyboard" -destination 'generic/platform=iOS Simulator' build`
- KeyboardCore has unit tests under `Packages/KeyboardCore/Tests/`. Run `swift test --package-path Packages/KeyboardCore` for the current count and result.
- `RimeBridgeTests` is an iOS Simulator Xcode test target because the pinned RIME xcframework inventory is iOS-only; do not replace it with macOS `swift test --package-path Packages/RimeBridge`.
- A **macOS verification tool** at `Packages/RimeBridge/TestTool/` validates the bridge code against real librime 1.16.1. Run with `cd Packages/RimeBridge/TestTool && make && ./test_rime`.

## Architecture

### Keyboard Extension — file layout

The keyboard is split by presentation, input action, candidate paging, feedback, and accessibility responsibilities:

The following trees are responsibility maps, not exhaustive file inventories. Use `rg --files Keyboard`, `rg --files 'Universe Keyboard'`, and `rg --files Packages` for the current file list.

```
Keyboard/
├── Controllers/
│   ├── KeyboardViewController.swift          — 主控：生命周期、引擎选择、UI 同步
│   ├── KeyboardViewController+Display.swift   — 按钮标题计算 + 状态刷新
│   ├── KeyboardViewController+KeyFactory.swift — 按键工厂方法
│   ├── KeyboardViewController+CandidateBar.swift — 候选栏薄适配
│   ├── KeyboardViewController+CandidatePaging.swift — 候选分页
│   ├── KeyboardViewController+ExpandedCandidatePanel.swift — 展开面板
│   ├── KeyboardViewController+InputActions.swift — 输入动作
│   ├── KeyboardViewController+DeleteActions.swift — 删除交互
│   ├── KeyboardViewController+Presentation.swift — 展示布局
│   ├── KeyboardViewController+Bootstrap.swift — 轻量会话启动
│   └── KeyboardViewController+KeyAccessibility.swift — 无障碍语义
├── Views/
│   ├── KeyboardAudioFeedbackInputView.swift  — UIKit 系统输入点击音承载视图
│   ├── KeyPopupView.swift                    — 变体弹出面板
│   └── CandidateBar/
│       ├── CandidateBarView.swift             — 候选栏容器
│       ├── CandidateCell.swift                — 候选单元格
│       ├── CandidateScrollViewStyle.swift      — 候选滚动视图外观防护
│       └── CandidateBarDataSource.swift       — 候选数据源（RIME 优先，回退 Fake）
├── Services/
│   └── UITextDocumentProxyAdapter.swift      — 文本代理适配器
├── Bridge/
│   ├── KeyboardType+UIKit.swift              — 类型桥接
├── Info.plist
└── Keyboard.entitlements
```

**Main App additions**:

```
Universe Keyboard/
├── App/
│   ├── Universe_KeyboardApp.swift        — @main 入口
│   └── ContentView.swift                 — 双 Tab 布局（引导 / 设置）
├── Views/
│   ├── Components/
│   │   ├── AppActionButton.swift         — 主 App 内容操作按钮（Liquid Glass + fallback）
│   │   ├── InfoSection.swift             — 信息卡片容器
│   │   ├── ToggleRow.swift               — 设置开关行
│   │   ├── BulletRow.swift               — 项目符号行（dot / checkmark）
│   │   ├── CapsuleBadge.swift            — 胶囊标签（filled / tinted）
│   │   └── SettingsNavigationLink.swift   — 设置导航行
│   ├── Guide/
│   │   └── GuideTab.swift                — 首次启用与系统设置引导
│   ├── Settings/
│   │   ├── SettingsTab.swift             — 设置导航
│   │   ├── RimeSettings*.swift           — RIME 多方案设置与状态
│   │   └── *SettingsView.swift           — 反馈、外观、高级输入、模糊音、用户词典与纠错
│   ├── Diagnostics/
│   │   └── Diagnostics*.swift            — 诊断日志查看、过滤与存储
│   ├── Dictionary/                         — 本地词典扫描、索引与浏览
│   └── License/
│       └── LicenseView.swift             — GPL-3.0 许可证查看
├── Services/
│   ├── SchemaManager*.swift              — 方案、下载、安装、部署与 Lua 诊断
│   └── RimeUserDictionaryBackupService.swift — 用户词典备份/恢复
└── Universe Keyboard.entitlements
```

**Testing**:

- `RimeBridgeTests` — iOS Simulator Xcode tests for the iOS-only RIME bridge package.
- `UniverseKeyboardTests` — main-App unit tests hosted by `Universe Keyboard.app`.
- `KeyboardTests` — keyboard contract/unit tests that do not launch the extension UI.
- `UniverseKeyboardUITests` — NE1 tooling-only XCUITest feasibility probes for Messages/system keyboard automation. These probes are run through the dedicated `UniverseKeyboardUITests` scheme and are not product or performance evidence by themselves.

`KeyboardCore` unit test layout:

```
Packages/KeyboardCore/Tests/KeyboardCoreTests/
├── AutoCapitalizeTests.swift             ├── CompositionTests.swift
├── DeleteTests.swift                     ├── InputModeTests.swift
├── KeyboardTypeTests.swift               ├── LoggerTests.swift
├── PageSwitchTests.swift                 ├── RimeConfigPostProcessor*Tests.swift
├── RimeConfig*Tests.swift                ├── RimeController*Tests.swift
├── ShiftStateTests.swift                 ├── SpaceReturnTests.swift
├── Unzip*Tests.swift
```

All state is managed in `KeyboardCore.KeyboardState` (via `KeyboardController`), not in the view controller. The VC delegates to `controller.handle(_:)` for all business logic and calls `syncUI(with:)` to refresh views.

### RIME Architecture (Phase 3 + librime-lua)

The keyboard uses a **dual-path** design in `KeyboardController`:

- **RIME path** (`rimeEngine != nil`): delegates composition and candidate lookup to the engine. Keystrokes never run deployment or configuration file synchronization.
- **Fallback path** (`rimeEngine == nil`): uses `CandidateProvider` + manual composition (original behavior).

**librime-lua integration**: `Packages/RimeBridge/Vendor/` expects 11 xcframeworks (9 original + `liblua.xcframework` + `librime-lua.xcframework`). The lua module is registered at runtime via `RIME_HAS_LUA=1` preprocessor macro. Full Lua behavior remains subject to a real-artifact schema smoke test before release.

**Inline preedit / marked text**: Chinese-mode composition uses `UITextDocumentProxy.setMarkedText` for system composing underline. RIME `rawInput` and display `preeditText` must remain separate. Full pipeline and invariants: [`input-pipeline-and-marked-text.md`](architecture/input-pipeline-and-marked-text.md).

**Key files for RIME**:
- `KeyboardCore/Sources/KeyboardCore/RimeEngine.swift` — protocol definition
- `KeyboardCore/Sources/KeyboardCore/RimeOutput.swift` — output data model
- `KeyboardCore/Sources/KeyboardCore/CandidateProviderRimeAdapter.swift` — Fake → RimeEngine adapter
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m` — ObjC wrapper around librime C API
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift` — Swift session engine implementation
- `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` — app-side full-deployment API

**macOS verification**: `Packages/RimeBridge/TestTool/main.cpp` tests the bridge code against Homebrew librime 1.16.1.

### KeyboardCore (pure logic, testable)

A local Swift Package at `Packages/KeyboardCore/`. Contains:

- **`KeyboardController`** — central state machine. Exposes `handle(_ action) -> KeyboardEffect` as the single entry point.
- **`KeyboardState`** — variables: `currentPage`, `inputMode`, `shiftState`, `currentComposition`, transient `continuation`, plus `activeKeyboardType` and timestamp fields. All enums (`KeyboardPage`, `InputMode`, `ShiftState`, `KeyboardType`) are co-located in this file.
- **`KeyboardAction`** — enum of all possible user actions (insertKey, toggleShift, togglePage, etc.). `insertCandidate` uses `CandidateKind` enum for type-safe dispatch.
- **`KeyboardEffect`** — OptionSet returned by `handle(_:)` to tell the UI what to refresh.
- **`CandidateItem`** — `CandidateKind` distinguishes normal RIME, composition, placeholder, typo-correction and post-commit continuation items. `CandidateKind` uses `Int` rawValue so it maps directly to `UIButton.tag`, avoiding the misuse of `accessibilityIdentifier` for business data.
- **`BundledContinuationSuggestionProvider`** — validates and decodes a small versioned bundled resource once, then performs bounded longest-suffix lookup in memory. V1.1 fails closed on invalid size/structure and protects reviewed synthetic Top-3 cases through [`POST_COMMIT_CONTINUATION_QUALITY.md`](POST_COMMIT_CONTINUATION_QUALITY.md). It never reads host context or persists committed text.
- **`CandidateProvider`** — protocol for candidate lookup (currently `FakeCandidateProvider`; will be replaced by RIME).
- **`TextInputClient`** — protocol abstracting `UITextDocumentProxy` insertion, deletion, cursor movement, text-presence checks, and marked text APIs (enables unit testing with `FakeTextInputClient`).
- **`Logger`** — lightweight `Sendable` facade backed by a FIFO serial writer. Log filtering, bounded buffering and persistence run away from the keyboard input path; `requestFlush()` never synchronously blocks a key event.
- **`Unzip` / `ZipArchiveReader` / `ZipBinaryReader` / `ZipInflater`** — minimal ZIP extraction boundary using system libz (raw deflate), with parsing, binary reads and inflate responsibilities split for focused tests.
- **`RimeConfigTemplateGenerator` / template files** — pure YAML generation logic plus schema, OpenCC and fallback dictionary templates extracted from `RimeConfigManager`.
- **`RimeConfigPostProcessor`** — canonical Lua stripping and schema repair logic used from the main App deployment preparation path; the Keyboard Extension does not repair files while opening a session.
- **`AutoCapitalizationRules`** — pure static auto-capitalization logic, extracted from `KeyboardController`.
- **`ZLib`** — pure Swift `@_silgen_name` declarations for zlib types (`z_stream`, `uInt`), functions (`inflateInit2_`, `inflate`, `inflateEnd`, `deflateInit2_`, `deflate`, `deflateEnd`), and constants. Eliminates the CZLib SPM C-target to avoid Xcode 26 explicit-module-build issues.

### Main App

```
Universe Keyboard/
├── App/
│   ├── Universe_KeyboardApp.swift        — @main 入口
│   └── ContentView.swift                 — 双 Tab 布局（引导 / 设置）
├── Views/
│   ├── Components/                       — shared SwiftUI components
│   ├── Settings/                         — 3 setting views
│   ├── Diagnostics/                      — log viewer
│   └── License/                          — GPL-3.0 viewer
└── Services/
    ├── SchemaManager.swift               — schema download + deploy orchestrator
    └── RimeDeploymentService.swift       — main-app-side full deployment API
```

### Shared infrastructure

Both targets share App Group `group.com.DoubleShy0N.Universe-Keyboard` (container layout and ownership rules: ADR 0003 and [`shared-container-and-rime-lifecycle.md`](architecture/shared-container-and-rime-lifecycle.md)).

Full Access: without it, App Group-dependent RIME runtime/configuration, shared settings, diagnostics, persisted feedback, and user-dictionary management are unavailable or degraded. Privacy boundary: all typed content, user dictionaries, logs, and correction-learning records remain on-device; network access is limited to explicit main-App download operations. Full contract: ADR 0007.

### Early planned architecture (historical reference only)

The following diagram is an early direction, not the current module layout. `KeyboardUI` and `SwipeEngine` do not currently exist as packages. Do not use this diagram to locate production code or infer an approved refactor.

```
Main App (SwiftUI) → settings, config import, onboarding
Keyboard Extension (UIInputViewController) → thin UI + state machine
  └─ KeyboardCore (pure logic, testable) → KeyboardAction, KeyboardState, CompositionState
  └─ KeyboardUI (views) → KeyButtonView, CandidateBarView, KeyboardPageView
  └─ RimeBridge (ObjC++ wrapper) → RimeEngine, librime.xcframework
  └─ SwipeEngine → trajectory → key sequence → candidate merging
```

## Key Design Decisions

- **All committed text insertion goes through `textDocumentProxy.insertText()`**; active Chinese composition uses the public `UITextDocumentProxy.setMarkedText(_:selectedRange:)` / `unmarkText()` APIs so host text fields can render the system composing underline. Never manipulate host app text directly.
- **The globe key (`nextKeyboardButton`) is mandatory** — Apple requires third-party keyboards to provide a way to switch to the next keyboard. Its visibility is managed in `viewWillLayoutSubviews()` via `needsInputModeSwitchKey`.
- **`RequestsOpenAccess` is `true`** — required for features that rely on the shared App Group container, including main-app-managed feedback settings and diagnostics.
- **Composition-first deletion**: when `currentComposition` is non-empty, delete key removes from the pinyin buffer first. Only after composition is empty does it call `textDocumentProxy.deleteBackward()`.
- **Email keyboard type auto-switches to English mode** and shows `@`/`.` shortcut keys in the bottom row.
- **URL/webSearch keyboard type auto-switches to English mode** and shows `/`/`.com` shortcut keys in the bottom row.
- **Number and symbol pages are context-aware**: Chinese mode mirrors native Chinese symbol ordering with a `#+=` second-level symbol key, `123` return key, kaomoji placeholder entry (`^_^`), and a `拼音 / emoji / space / return` bottom row. English mode uses matching first/second-level symbol layouts with `English / emoji / space / return`.
- **Symbol-page one-shot input**: number/symbol pages use mode-specific one-shot whitelists. Chinese mode returns `currentPage` to `.letters` only for `；（）@“”。，、？！【】｛｝#%^*+=_\｜《》&·`; the ASCII period `.` and Chinese `‘` key are intentionally not one-shot in Chinese mode. English mode keeps half-width punctuation semantics, so `.` behaves as an English period and returns to letters. Digits and non-whitelisted symbols never auto-return. Left paired symbols (`（`, `“`, `【`, `｛`, `《` and English equivalents) insert both sides and move the cursor between them when `paired_symbol_completion_enabled` is enabled; the App Group-backed setting defaults to on and can be disabled from the main App settings. During active Chinese composition, ordinary punctuation first commits the first RIME candidate, then inserts the symbol/pair. Ordinary lowercase pinyin followed by number-page digits keeps the inline preedit as raw input such as `nihao123` while showing a transformed first candidate such as `你好123`; delete removes raw input in reverse order, and candidate/space confirmation commits the transformed candidate. Advanced inputs such as `N20260619` and `cC1+2` stay on the RIME raw-input path. The Chinese `‘` key is special: during composition it is sent to RIME as an ASCII apostrophe separator and returns to letters without committing; outside composition it remains a normal symbol and stays on the current symbol page. Emoji page insertion is separate and does not use this one-shot behavior.
- **Smart quote key on English number page**: the visible `”` key inserts `“` first, then `”`; once an open/close pair exists in the context, repeated presses insert `”` until both quotes are deleted from the context.
- **Dynamic page switch button** title: "123" on letters page, "#+=" on numbers page, emoji on symbols page, and "ABC" on emoji page.
- **Return key title** dynamically reflects `textDocumentProxy.returnKeyType` (return, search, go, send, etc.).
- **Shift double-tap** (within 0.35s) enters Caps Lock. Single tap cycles between off and single-use uppercase.
- **Double-space period** (within 0.45s) is enabled only in English mode with empty composition.
- **Auto-capitalization** applies at sentence start (after `.`, `!`, `?`, `。`, `！`, `？`) and on empty/new documents. It triggers when switching input mode to English (checks current text context) and after each delete operation (defensive check in `performDeleteBackward` in addition to `textDidChange`, because `UITextDocumentProxy.documentContextBeforeInput` can be stale when `textDidChange` fires). When switching back to Chinese mode, any active shift state (singleUse or capsLock) is automatically reset to off — auto-cap is explicitly English-mode-only.
- **Long-press letter keys** (0.3s) shows a popup with diacritic variants (e.g., a → à á â ä æ). 19 letters have variants. Selection follows finger position; releasing outside the popup cancels. Variants respect Shift state (uppercase/lowercase).
- **Feedback settings model**: key click and haptic feedback each have an independent enabled switch. Haptic feedback retains five discrete levels (`light`, `softer`, `normal`, `stronger`, `heavy`) stored as `haptic_level` values `1...5`, with intensity curve `0.35 / 0.5 / 0.65 / 0.82 / 1.0`. Legacy `haptic_intensity` is migrated to the nearest level and kept for rollback compatibility. Key-click volume is system-owned and is not presented as an App-controlled level.
- **Keyboard click sound** uses UIKit `UIInputViewAudioFeedback` and `UIDevice.playInputClick()`. The Extension does not create an `AVAudioSession`, generate WAV data, write a temporary audio file or own an audio player. iOS controls whether the click is audible and owns silent-mode and audio-route behavior; the App-level switch can further disable click requests.
- **Feedback event model**: `KeyboardFeedbackEvent` separates `tap`, `modeEnter`, `repeat`, `commit`, and `preview`. Standard tap feedback remains touch-down based; candidate and variant selection use `commit`; space long-press emits one stronger `modeEnter` haptic when cursor movement mode actually begins; haptic settings preview is handled by the main-app preview coordinator with same-level suppression and throttling.
- **Haptic feedback** uses `UIImpactFeedbackGenerator` with the five-level model above plus an independent `haptic_enabled` switch. Generators are prepared only when haptics are enabled; the space cursor mode-enter path uses a separate `.heavy` generator.
- **Delete Repeat UX Phase 1.1**: long-press delete keeps the existing 0.5s delay and 0.08s repeat tick. The first touch-down still performs one delete with normal tap feedback. Repeat feedback is emitted only after a conservatively detected effective delete, using UI-layer signals (`currentComposition`, inline preedit count, or `documentContextBeforeInput`) rather than changing the KeyboardCore delete contract. System input click is requested on the first effective repeat and every second effective repeat; repeat haptic plays every fourth effective repeat at `max(0.25, tapIntensity * 0.7)`. Empty-field long press is silent after the first tap feedback.
- **Future Full Access onboarding**: full onboarding is intentionally deferred. Future options include TipKit, first-launch guidance, illustrated permission instructions, and a system Settings entry point. Phase 1 keeps only simple Full Access text because the main app cannot reliably query the keyboard extension's real-time Full Access state before the keyboard has run.
- **Candidate bar**: horizontal `UICollectionView` with infinite scroll, accumulated candidates, and expanded panel (no page buttons). Rendering rules (`UILabel`, no `UIButton.Configuration`), iOS 26 scroll edge effect guard (`CandidateScrollViewStyle`), and layout requirements: [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md) §Candidate Bar.
- **Post-commit continuation**: after a successful Chinese final commit, the inactive-composition candidate bar may show bounded suggestions from a bundled resource. Context is process-local, capped at 32 `Character` values, and cleared at documented edit/mode/lifecycle boundaries. Contract: [`POST_COMMIT_CONTINUATION.md`](POST_COMMIT_CONTINUATION.md); decision: ADR 0017.
- **Typo correction**: conservative one-edit engine with adjacent-key substitution and repeated-final deletion. Rules, benchmark, and contract/case registry: [`TYPO_BENCHMARK.md`](TYPO_BENCHMARK.md) and [`TYPO_BENCHMARK_REGISTRY.md`](TYPO_BENCHMARK_REGISTRY.md); source-of-truth decision: ADR 0009.

- **RIME raw input and display preedit are separate contracts**: `RimeOutput.rawInput` is the unformatted input source for composition restoration; `composition.preeditText` may contain display-oriented segmentation or selected Chinese segments. Never reconstruct raw input from display preedit. Full semantics: [`input-pipeline-and-marked-text.md`](architecture/input-pipeline-and-marked-text.md) §Composition State.
- **Partial Commit**: selecting a shorter RIME candidate inside active composition may keep remaining composition active, with reversible Delete-restore semantics. Feature matrix, eligibility gates, typo-correction interaction, and checkpoint contract: [`partial-commit.md`](architecture/partial-commit.md) and [`input-pipeline-and-marked-text.md`](architecture/input-pipeline-and-marked-text.md) §Partial Commit Invariants.
- **Inline preedit / marked text**: active composition displayed as system marked text via `UITextDocumentProxy.setMarkedText`. Full semantics, invariants, Partial Commit interaction, and finalization rules: [`input-pipeline-and-marked-text.md`](architecture/input-pipeline-and-marked-text.md).
- **Long-press delete**: Touch-down immediately performs the first delete. After 0.5s, auto-repeat starts at 0.08s intervals (matching native iOS keyboard behavior).
- **Key-click enablement, haptic settings, post-commit-continuation enablement, Typing Intelligence state, typo-learning snapshot and appearance settings are cached** as one VC-level snapshot on `viewDidLoad` (not read from `UserDefaults(suiteName:)` on every keypress/layout pass). The first `viewDidAppear` reuses that snapshot; later real visibility returns refresh it. Process-local `UserDefaults.didChangeNotification` is intentionally not used for cross-process main-App writes or heartbeat updates.
- **Layout extraction**: `reloadKeyboard()` and `reloadKeyboardContent()` share keyboard row construction through `addKeyboardRows(for:)`. No duplicated layout code.
- **iOS 26 native appearance**: key buttons use `KeyVisualStyle` enum for consistent styling (`.character`/`.function`/`.space`/`.returnKey`/`.active`). Dark/light mode custom colors for keyboard background, character keys, function keys, and highlighted state. Keys use `.continuous` corner curve with 9pt radius. The system now provides the outer rounded keyboard container; keep `view.backgroundColor` clear and avoid drawing a second large rounded surface inside the extension. Touch feedback uses instantaneous `backgroundColor` + `CGAffineTransform(scaleX: 0.96)` — no Core Animation transactions.
- Keyboard uses programmatic UIKit layout (UIStackView-based rows, no Storyboards). Frozen baseline geometry and typography: [`UI_STYLE_GUIDE.md`](UI_STYLE_GUIDE.md) §V1 UI Freeze. Future UI changes must have a specific usability reason; avoid cosmetic tuning while the V1 UI freeze is active.
- **iPhone 17 final keyboard height may be 216pt** (vs. standard 250–268pt on iOS 26 non-adapted apps). Never use a fixed-height constraint larger than `viewHeight - bottomMargin`. The current approach — `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews` (guard: `height > 0 && height < 400`) — handles all device/OS height variations correctly.
- **Visibility changes abandon unfinished composition instead of restoring it.** Decision: ADR 0002. Lifecycle details (first presentation, disappearance, return, process death, runtime session recovery): [`shared-container-and-rime-lifecycle.md`](architecture/shared-container-and-rime-lifecycle.md) §Keyboard Lifecycle.

### RIME Deployment System

Deployment is owned by the main App (ADR 0001); the Keyboard Extension opens prepared runtime directories and creates sessions only. It must never run maintenance or deployment during input.

- **Deployment lifecycle** (prepare → install → deploy → keyboard opens): [`shared-container-and-rime-lifecycle.md`](architecture/shared-container-and-rime-lifecycle.md) §Deployment Lifecycle.
- **Scheme management** (download, install, update, uninstall, settings UI): [`RIME_SCHEME_MANAGEMENT.md`](RIME_SCHEME_MANAGEMENT.md).
- **User dictionary** (learning, backup, restore, reset): [`RIME_USER_DICTIONARY.md`](RIME_USER_DICTIONARY.md).
- **Traditional fuzzy pinyin**: [`RIME_FUZZY_PINYIN.md`](RIME_FUZZY_PINYIN.md).
- **OpenCC integration**: [`opencc-integration.md`](architecture/opencc-integration.md).
- **Diagnostics**: `Logger` (KeyboardCore, `Sendable`, FIFO serial writer, 500-entry ring buffer) writes to App Group `UserDefaults`. Main app `DiagnosticsView` shows logs with refresh/clear. Troubleshooting procedures: [`DEBUGGING.md`](DEBUGGING.md).

## Project Skills

- **`pre-push-review`** (`.claude/skills/pre-push-review/SKILL.md`): automated workflow — scans diff + runs `swift test` + reviews for .bak/.DS_Store + creates commit + pushes. Trigger with "push", "upload to GitHub", "ship it", "commit and push". Blocks on test failures or exclusion-pattern files.
