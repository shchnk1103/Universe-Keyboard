# RELEASE-2026-0801-06 — Residual Review 2026-08-23

> **Evidence grade:** `Executor-recorded` source review plus copy change; VoiceOver speech is `Device-attested` / Human Simulator
>
> **Assignment:** [`RELEASE-2026-0801-06`](../assignments/release-2026-08-01-06-product-polish.md)
>
> **Product decision:** Human Product Owner, `2026-08-23 Asia/Shanghai`: keep 智能纠错 / 输入洞察; copy must remain a non-AI promise; authorize R-06-05 Diagnostics breadth review and R-06-06 VoiceOver order smoke

## Non-claims

Not a complete accessibility certification, physical-device visual Gate, RC freeze, or Xcode 26.6 iOS runtime close.

## R-06-07 — keep entries, non-AI copy

Settings destinations remain. Copy now states the local, non-AI boundary:

| Surface | Change |
|---|---|
| Settings 输入体验 footer | States these are on-device typing habits, not AI |
| 智能纠错 row / Search catalog | Subtitle: 本地邻键旁路建议，不自动改写 |
| 输入洞察 row / Search catalog | Subtitle: 本机字符计数，不是人工智能 |
| 智能纠错 status paragraph | Adds 本机邻键规则，不是人工智能，也不会联网推断 |
| 输入洞察 enable caption | Adds 不是人工智能分析 |
| Home count-card hint | 打开本地输入统计、字符构成与数据管理 |

`swift-format lint --strict` passed on the five Swift files.

## R-06-05 — Diagnostics breadth (source)

Reviewed current Settings → 诊断 and related views. No visible no-op control found.

| Surface | Observation |
|---|---|
| Settings 诊断 group | Footer says open only when troubleshooting; subtitle 本机记录、分类与高级排查 |
| `DiagnosticsSettingsView` status | Local App Group storage; no upload; master toggle 记录诊断数据 |
| Categories | Per-category enable map; not a fake progress affordance |
| 查看记录 → `DiagnosticsView` | Day picker, summary filters, search, refresh/copy/clear with destructive confirm |
| Debug-only 短时采样 / 按键检查 | Explicitly Debug; Release has no those toggles |
| 高级 force_gc | Real schema-hygiene actions with App Group / file results, not a dead button |
| `T9DevicePreflightEvidenceView` | Launch-environment evidence, not a Settings no-op |

iOS 18 iPad Simulator visual walk of Diagnostics was not repeated in this slice (no iPad 18 instance was booted; a foreign iPhone 17 Pro Max / iOS 27 Simulator was booted and ignored). Source review closes the “unreviewed” residual at code grade only.

## R-06-06 — VoiceOver order (source + Human protocol)

Keyboard accessibility ownership from source, top to bottom when those chrome are visible:

1. T9 Path chips: `accessibilityTraits = .button` (+ `.selected` when active); idle hint is hidden when unused
2. Compact candidates: cell is an accessibility element with `.button` and hint 双击选择候选词 (R-06-01 closed)
3. Expand control: UIButton, label 展开更多候选词
4. Expanded panel collapse: 收起候选面板
5. Keys: `.keyboardKey` with labels for delete/shift/space/return/language/digits
6. 九键 选拼音 / 颜表情 / 表情 have explicit labels

Main App Settings/Home rows use `SettingsNavigationLink` / button hints. Diagnostics status section combines children.

**Human smoke (required to close speech, not just source):** on iOS 18 Simulator with VoiceOver on, synthetic input only:

1. Home count card — expect 今日已输入… / 未开启, hint mentions 本地输入统计
2. Settings → 智能纠错 / 输入洞察 — expect subtitles above, no “AI 分析/自动改写”
3. Settings → 诊断 → 查看记录 — expect 查看记录 is actionable
4. Keyboard: candidate, expand, one letter key, delete, space — expect role + hint; do not click candidates unless checking commit

### Human speech report — `2026-08-23 Asia/Shanghai`

| Step | Reported speech | Disposition |
|---|---|---|
| 1 Home count card | 今日输入；今天尚未输入；连续记录 0 天；本地统计未开启；需要时在输入趋势里开启即可 | Pass for local-count / disabled state. Caption still said 输入趋势; Executor then aligned it to 输入洞察 |
| 2 Settings rows | 可听到新副标题，末尾说明是按钮 | Pass; no AI-analysis / auto-rewrite speech |
| 3 查看记录 | 查看记录，实时预览，按钮 | Pass |
| 4 Candidate | ni，按钮，双击选择候选词 | Pass role + hint (same contract as R-06-01) |
| 4 Expand | 展开更多候选词，按钮，双击以查看更多列表 | Pass |
| 4 Letter `h` | h，hotel | Pass; NATO phonetic is system VoiceOver, not an Extension defect |
| 4 Delete | 删除；删除光标前的字符；按住可连续删除 | Pass |
| 4 Space | 空格；拼音输入；插入空格；左右滑动可移动光标 | Pass; 拼音输入 is the Chinese-mode space title |

R-06-06 is closed at Human Simulator smoke grade only.

## Remaining

- **R-06-08 / R-06-09:** Human Product Owner, `2026-08-23 Asia/Shanghai`, deferred physical-device visual and complete accessibility certification to testers after TestFlight upload because the available physical-device set is too small. This is a 06 polish deferral, not an acceptance or skip of [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md) or TD-003/004/005.
- **R-06-10:** Not a missing phone. Local Xcode 26.6 cannot execute iOS Simulator gates until the iOS 26.5 Simulator runtime/platform is installed (macOS 27 also cannot launch Xcode 26.6 as the daily iOS host). The Xcode Cloud no-distribution Archive pilot on `4fd3ce7` already ran Xcode 26.6. Local Xcode 27 evidence must not be relabeled as that runtime gate.
- R-06-05 iPad visual walk of Diagnostics remains optional.
