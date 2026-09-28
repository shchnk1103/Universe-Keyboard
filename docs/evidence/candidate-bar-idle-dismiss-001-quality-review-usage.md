# CANDIDATE-BAR-IDLE-DISMISS-001 Quality review — usage

| Field | Value |
|---|---|
| Lane | `CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY-001` Round 1 |
| Reviewer identity | Fresh independent Quality, Performance & Release Maintainer runtime（Grok Build subagent）。**不是** 实施 idle dismiss 的 Executor |
| Worktree | `/private/tmp/universe-keyboard-candidate-bar-idle-dismiss-001` |
| Branch / HEAD | `grok/candidate-bar-idle-dismiss-001` / `fbb4eb3bbbc2926ff6e248db9dcdfdf6a331f821` = `origin/main` |
| AUTH | [`AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY`](../authorizations/AUTH-CANDIDATE-BAR-IDLE-DISMISS-001-QUALITY.md) — active/unconsumed；本 lane 未回写 consumption |
| Packet | [`candidate-bar-idle-dismiss-001-quality-review-packet.md`](../reviews/candidate-bar-idle-dismiss-001-quality-review-packet.md) |
| Packet digest（独立复现） | `5adecb81985d91de0022471e74702181975c332589cac149643285da69718c28` |
| Start | `2026-09-28T22:01:40+08:00` |
| End | `2026-09-28T22:07:10+08:00` |
| Elapsed active | ~5.5 min 墙钟（含独立 `swift test` CandidateKindTests ~0.8 s build + 17 条；独立 `xcodebuild test` testing elapsed 28.864 s）。未触 60 min 上限 |
| Tool-call count | **36**（预算 40；含 packet 核验、身份 `shasum`、源码/文档阅读、grep、lint、KeyboardCore 过滤测试、独立 `xcodebuild`、两份产出写入） |
| Token usage | `unknown` |
| Stop reason | 八条 packet claims 均已覆盖并写出审查记录。非 exhaustion 的 Partial/incomplete |

## Checkpoints

| When | Tool calls (cumulative) | Clock | Claims covered | Notes |
|---|---:|---|---|---|
| Start | 0 | `22:01:40+08:00` | 0 | 先读 packet / AUTH-QUALITY / 模板。禁止评 claims 直到 digest 与身份表核完 |
| CP-1 | 10 | `22:02:31+08:00` | 0（核验中） | Packet digest 独立复现匹配；十三份身份表 `shasum -a 256` 全部匹配冻结值。`HEAD`/`分支` 匹配。继续评 claims |
| CP-2 | 22 | `22:03:20+08:00` | 1–5、7 源码中 | 读 CandidateBar / panel / CandidateKind / 合同测试；`git diff -- Packages/RimeBridge/` 空；KeyboardCore 仅分类属性 |
| CP-3 | 27 | lint + SPM 完成后 | 1–5、7 初评；6 部分 | `swift-format lint --strict` 六文件 exit 0；`CandidateKindTests` 17 / 0 |
| CP-4 | 30 | `22:04:51+08:00` 测试结束 | 1–7 机器证据 | `** TEST SUCCEEDED **`：UniverseKeyboardTests 410 / 10 skipped；KeyboardTests 16；`CandidateBarIdleDismissContractTests` 1。xcresult `…/Test-Universe Keyboard-2026.09.28_22-04-17-+0800.xcresult`。destination 仅 iPhone 17 `D3C353BE-3AA6-499B-8F87-349073D65BE4`。未打 iPhone 17 Pro |
| End | 36 | `22:07:10+08:00` | 1–8 全部 | 写入 review + 本 usage。未改 Swift / packet / AUTH consumption / Assignment |

## Claims covered

| # | Claim | Result at stop |
|---|---|---|
| 1 | One trailing control | Pass |
| 2 | Expandable content | Pass |
| 3 | Gestures and panel | Pass |
| 4 | Idle icon compositing | Pass |
| 5 | Accessibility | Pass |
| 6 | Tests（独立 lint + KeyboardCore + xcodebuild，不复用 Executor 410/16） | Pass |
| 7 | KeyboardCore boundary | Pass |
| 8 | Non-claims（含 `CBID-CORNER` accept，不授予 Gate） | Pass |

Remaining claims at stop：**none**。Verdict：**Pass with conditions**（残差 `CBID-01`、`CBID-02`、`CBID-CORNER`、`CBID-03`、`CBID-04` 均 `accept`）。

## Independent machine evidence (this lane)

```text
xcrun swift-format lint --strict --configuration .swift-format \
  Keyboard/Views/CandidateBar/CandidateBarView.swift \
  Keyboard/Controllers/KeyboardViewController+CandidateBar.swift \
  Keyboard/Controllers/KeyboardViewController+ExpandedCandidatePanel.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/CandidateItem.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/CandidateKindTests.swift \
  KeyboardTests/CandidateBarIdleDismissContractTests.swift
# exit 0

swift test --package-path Packages/KeyboardCore --filter CandidateKindTests
# Executed 17, failed 0

xcodebuild -project "Universe Keyboard.xcodeproj" \
  -scheme "Universe Keyboard" -configuration Debug \
  -destination 'platform=iOS Simulator,id=D3C353BE-3AA6-499B-8F87-349073D65BE4' \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 \
  SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES test
# ** TEST SUCCEEDED **  exit 0
# UniverseKeyboardTests Executed 410, skipped 10, failed 0
# KeyboardTests Executed 16, failed 0
# CandidateBarIdleDismissContractTests 1 passed
# xcresult: /Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-dxwhfzxqseyzcuclkhpyzjwydgfz/Logs/Test/Test-Universe Keyboard-2026.09.28_22-04-17-+0800.xcresult
```

Destination：**仅** `iPhone 17` / `D3C353BE-3AA6-499B-8F87-349073D65BE4`（审查时 simctl **Booted**）。**未** 打 `iPhone 17 Pro` / `8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2`。SDK `iPhoneSimulator27.0`。

未跑：RimeBridgeTests、Release `build`、hosted CI、Simulator 目视关闭键、圆角透白修复。

## Outputs written

- `docs/reviews/candidate-bar-idle-dismiss-001-quality-review.md`
- `docs/evidence/candidate-bar-idle-dismiss-001-quality-review-usage.md`

Not written / not edited：product Swift、tests、packet、AUTH consumption、Assignment、ACTIVE_WORK、Dashboard、CHANGELOG、UI_STYLE_GUIDE。无 commit / push / Product Gate / TestFlight / Release。
