# CHANGELOG

Change history for Universe Keyboard. Entries are in reverse chronological order.

> **AI agents**: Load this file only when investigating historical decisions, debugging regressions, or understanding why a specific implementation approach was chosen. Do not load for routine coding tasks.

---

## 2026-07-14 — 修复键盘预创建与挂起阶段的 RIME 文件锁终止

- 真机高频切换验收定位到 Keyboard Extension 被 RunningBoard 以 `0xdead10cc` 终止；系统可在 `viewWillAppear` 前预创建并直接挂起扩展，因此仅在隐藏回调中 finalize 不能覆盖该路径。
- `viewDidLoad` 现在只解析只读运行时目录并使用内存回退引擎；librime 仅在 `viewDidAppear` 确认键盘已实际呈现后才初始化、创建 session 并打开用户词典。
- 进程内仍保持 librime 单一 owner；正常隐藏路径同步清理输入状态并 finalize runtime，重新显示时再初始化 runtime、创建 session 并恢复活动输入方案，不依赖时机不确定的 `deinit`。
- 诊断 writer 增加可见性生命周期屏障：挂起前丢弃待写批次并阻止延迟 App Group 写入，恢复显示后再接受日志，避免诊断副作用跨入系统挂起阶段。
- 增加 RIME 可见性生命周期与日志挂起/恢复测试；真机高频切换与 AirPods 双设备路由仍需完成最终回归。

## 2026-07-14 — 完整修复系统点击音输入视图造成的空白键盘崩溃

- Device Hub 复现并定位到 `KeyboardViewController+Presentation.swift:80`：点击音承载视图在控制器 `init` 中直接赋给 `inputView`，使 UIKit 可能在 `viewDidLoad` / KeyboardCore bootstrap 前进入 `viewWillAppear`；此前仅保护 `textDidChange` 不能覆盖这条生命周期路径。
- 点击音承载视图改为通过标准 `loadView` 创建，恢复 `loadView -> viewDidLoad -> viewWillAppear` 顺序，同时继续使用 `UIInputViewAudioFeedback` / `UIDevice.playInputClick()`，没有重新引入 Extension 自有音频会话。
- Device Hub 两次冷启动均成功；英文输入、`nihao -> 你好` 候选提交、`zhongguo` 候选展开和切走时组合清理通过，隔离冷启动 UI 测试及严格 Release Simulator 构建通过。物理 iPhone/iPad 当时不可用，AirPods 与真机持续输入仍待验收。

## 2026-07-14 — 候选呈现路径剩余性能优化

- 候选触控诊断开关改为随键盘设置快照刷新；`pointInside` / `hitTest` 不再轮询时间或读取 App Group 偏好。
- collection 数据源直接复用重建边界已经清理过的候选快照，不再在计数、复用和尺寸查询时反复过滤；尺寸缓存改用结构化键，避免拼接含候选文本的临时字符串。
- 后续候选分页使用一次全局索引集合完成去重，展开面板布局按 `IndexPath` 索引属性缓存；内存警告会释放可重建的候选尺寸缓存。
- KeyboardCore 全量测试、99 项 Xcode 工程测试、隔离冷启动 UI 测试及严格 Debug/Release Simulator 构建通过；Device Hub 已完成 Simulator 启动、输入、候选提交与展开验证。物理 iPhone 当前不可用，因此真机持续输入、AirPods 路由与性能结论仍待验收。

## 2026-07-13 — 阶段性保护启动前文本回调

- 物理设备崩溃报告表明 UIKit 可能在 `viewDidLoad` 前发送 `textDidChange`；增加 bootstrap 前保护，避免该回调访问尚未创建的 KeyboardCore controller。后续 Device Hub 验证发现 `viewWillAppear` 仍存在独立的提前到达路径，完整根因与修复记录在 2026-07-14 条目。
- bootstrap 前的文档变化回调现在会安全忽略；正式 bootstrap 仍会读取当前键盘类型与自动大写上下文，不改变正常输入语义。
- 通过 iPhone 物理设备崩溃报告定位到 `synchronizeAfterTextChange()`，并完成 Debug 真机构建、安装及 Release 通用 iOS 构建；持续输入仍需真机人工验收。

## 2026-07-13 — 键盘输入热路径优化

- 键盘命中区域改为每次布局后生成一次触控单元快照；正常命中测试直接复用，不再逐次递归发现、排序按键并重设触控背景。
- Release 构建移除逐键、逐候选的成功明细日志，保留慢输入、慢候选刷新、慢候选预取及失败告警；Debug 继续提供完整时序诊断。
- 诊断写入器改为按顺序异步批处理，多条记录共用一次格式化和日志存储读写，同时保留条数上限、类别过滤、清空与显式刷新语义。
- KeyboardCore 全量测试与 Debug/Release Simulator 构建通过；按键边缘、行间空隙和持续中英文输入仍需真机验收。

## 2026-07-13 — 键盘冷启动与系统点击音优化

- 键盘 Extension 改用 UIKit 系统输入点击音，不再创建或激活自己的音频会话，也不再生成 WAV、写临时音频文件或预热双播放器；避免键盘启动主动争抢 AirPods 音频路由。
- 主 App 移除无法控制系统点击音的五档音量界面，保留独立开关并明确静音、音量和音频路由由 iOS 管理。
- RIME 健康冷启动改为 schema 选择快速路径，不再枚举全部 schema 或合成 `ni` 功能自测；完整功能验证继续保留在异常恢复路径。
- 首次显示复用同一设置快照，布局材质开关改为缓存读取，触感关闭时不再预热；Release librime 日志降为 Error/Fatal 且不再创建启动日志目录，逐键成功诊断仅保留在 Debug。
- 自动化测试和 Debug/Release 构建用于实现验证；AirPods 双设备路由与冷/暖启动性能仍需真机验收。

## 2026-07-13 — 安全的 RIME 自动同步与同步提醒

- 完成一次用户确认的 RIME 标准同步后，默认启用自动同步；用户可改为每天或每 7 天一次，并可随时关闭。
- 新增 iOS 后台处理任务、键盘活动心跳和本地通知：系统只在合适的空闲机会运行；键盘正在使用、目录授权失效或冷却期未结束时会安全跳过。开始与完成提醒需要用户单独授权。
- 自动路径继续使用 librime `sync_user_data` 快照合并，不复制运行中的 `*.userdb*`，不自动导入其他设备 YAML，也不进入键盘按键路径。
- 更新同步、隐私、架构、调试和发布文档，明确后台任务不保证固定时刻或实时完成。

## 2026-07-12 — RIME standard sync as the interoperability path

- Added a main-App-only bridge to librime `sync_user_data` and configured its standard `sync_dir` / installation ID through a user-selected file-provider folder.
- Made standard sync an explicitly confirmed manual operation: it refreshes managed `.custom.yaml`, merges official user-dictionary snapshots and backs up RIME YAML/TXT without copying live `*.userdb*` files.
- Kept `universe-rime-sync` as a separate encrypted auxiliary package. WebDAV continues to carry only that private package and is not presented as an interoperable RIME `sync_dir`.
- Added fail-closed `installation.yaml` preservation checks, clear privacy copy and no-auto-sync boundaries. Physical-device, multi-frontend and configuration-import evidence remain open.
- Consolidated the two visible sync commands into one staged `立即同步` flow: standard-folder users see RIME user-data sync followed by encrypted private-settings sync, with each state shown through the shared global toast.
- Coordinated all local-folder and standard-sync writes with `NSFileCoordinator` and the file provider's supplied URL, fixing provider paths that could create folders but rejected saving `format.json` during atomic writes.
- Added a coordinated write/read/delete preflight before switching standard folders. The file-picker callback now holds the security-scoped directory access through preflight and bookmark persistence, which fixes iCloud Drive selections that could become unavailable after the callback returns. A failed selection pauses sync, retains the old directory only as recovery reference, and records a non-sensitive diagnostic phase/error code instead of silently continuing to the old directory.
- Moved candidate learning into “数据与同步” as “RIME 用户词典”, aligned the RIME 云同步 icon with the app's neutral settings-icon style, and clarified that cross-device learned-dictionary exchange uses standard RIME sync.
- Hardened local user-dictionary restore and reset: both now create and verify a distinct recovery backup before modifying live `userdb` files, abort safely on preparation failure, and attempt rollback after a failed replacement.

## 2026-07-12 — Portable encrypted RIME settings sync V1

- Added a main-App-only RIME sync coordinator with deterministic field-level logical versions, unknown-field preservation and conflict-safe retries.
- Added ChaCha20-Poly1305 end-to-end encryption, a device-local Keychain key, an exportable recovery code and fail-closed handling for wrong keys or damaged packages.
- Added WebDAV transport with HTTPS enforcement, Basic authentication, ETag conditional writes and remote deletion, plus a security-scoped local-folder transport with atomic writes.
- Added a native Settings page for provider setup, stable sync status, explicit content scope, recovery information, foreground/manual synchronization and destructive data controls.
- Kept user dictionaries, Typing Intelligence, diagnostics, Typo learning, typed text and custom YAML files outside V1; keyboard input remains offline and unchanged.
- Added focused merge, crypto, local-folder, conflict-retry and WebDAV request-contract tests. Real provider, physical-device, accessibility and cross-platform client evidence remain open before Product acceptance.

## 2026-07-11 — Local Typing Intelligence implementation

- Added a final-commit observation contract that classifies committed graphemes into irreversible local aggregates without persisting raw text, candidates, composition or host context.
- Added a bounded, versioned App Group statistics store with asynchronous coalescing, 365-day retention, corruption recovery and reset-epoch protection against stale queued writes.
- Added disabled, empty, active and failure-state main-App views for local typing trends, composition, activity, privacy controls and permanent clearing; collection remains disabled by default.
- Added a top-level Home tab with a single, tappable daily aggregate card that leads to detailed insights.
- Added target privacy manifests, prohibited-payload tests, exactly-once commit tests, store/model coverage and synthetic Release performance evidence.
- Preserved RIME, candidate generation and keyboard lifecycle behavior. Physical-device Full Access, process-death, sustained-typing, appearance and final review gates remain open before release acceptance.

## 2026-07-08 — Knowledge OS 2.0 Zero-Context Startup Layer

- Published `KOS-BOOT-001` as the accepted and closed Assignment for Zero-Context Startup governance bootstrap.
- Added `docs/kos/zero-context-startup.md` to define startup reading order, repository discovery, Work Item/lifecycle/role/repository-truth discovery, startup validation and prompt compression.
- Linked the startup layer through Knowledge OS navigation and synchronized the Engineering Dashboard closure state without beginning Repository Migration, implementation, Benchmark work or Task 7.

---

## 2026-06-30 — Typo Correction Benchmark Registry v1.0

- Published the accepted `TC-CTR-*`, `TC-CASE-*` and `TC-PERF::*` namespaces as the repository Source of Truth in `docs/TYPO_BENCHMARK_REGISTRY.md`.
- Added ADR 0009 for independent, versioned Registry ownership and linked benchmark, performance, Partial Commit, navigation and governance documents without copying authority.
- Preserved historical aliases, independent `nihoa-satisfied`/`nihoa-unsatisfied` Cases, cross-layer coverage rules and the Task 7 prohibition; publication does not claim current evidence passed.

---

## 2026-06-29 — Executable subagent playbooks

- Added nine domain playbooks with explicit mission, scope, forbidden changes, evidence, output, stop, escalation and documentation-impact rules.
- Separated multi-agent orchestration in `AI_WORKFLOW.md` from executable domain boundaries in `docs/playbooks/`.
- Connected playbooks to the Knowledge Index, Reading Maps, documentation graph/dependencies and health dashboard without copying architecture facts.

---

## 2026-06-29 — Knowledge OS v1.0

- Added a pure navigation index, task reading maps, documentation graph, dependency routing and change decision trees.
- Added staged onboarding, a project glossary and an ADR-linked architecture timeline without replacing current architecture sources.
- Added a reproducible documentation-health dashboard and recorded the current governance debt instead of hiding it.
- Changed the new-thread entry path to `AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → `docs/READING_MAPS.md`; retained `CONTEXT_INDEX.md` as the detailed legacy registry.

---

## 2026-06-29 — Documentation governance baseline

- Established one Source of Truth per knowledge category, mandatory documentation triggers, ADR requirements and volatile-data rules.
- Defined plan lifecycle metadata, changelog boundaries, subagent playbook boundaries and monthly/milestone Knowledge Audit outputs.
- Connected governance checks to pre-push review without duplicating the full rules across project documents.

---

## 2026-06-29 — Decision lock-in and ADR baseline

- Accepted eight ADRs covering deployment ownership, visibility cleanup, shared-container ownership, RIME sessions, restore safety, transactional schema installation, Full Access/privacy and fallback semantics.
- Locked the long-term user-dictionary rule: create and verify a safety backup before restore; current implementation remains explicitly tracked as debt.
- Added a measurement-only Extension performance baseline without invented latency or memory budgets.
- Added the canonical technical-debt register for schema transactions, `Rime/user` coordination, performance evidence, Full Access degradation, crash/jetsam operations and reproducible RIME artifacts.
- Adopted the current minimum acceptance matrix: primary development device, current development iOS and one available Simulator; expansion is required before broader TestFlight/App Store release.

---

## 2026-06-29 — Critical documentation stabilization

- Corrected the keyboard visibility contract: returning/disappearing keyboards abandon unfinished composition and marked preedit; runtime session recovery remains a separate in-presentation path.
- Removed current hardcoded test counts, refreshed README architecture/feature status, and standardized build destinations versus concrete simulator test destinations.
- Marked completed Lua and typo-correction implementation plans as archived historical references.
- Added durable documentation for the shared-container/RIME lifecycle, input and marked-text invariants, debugging flows, and release acceptance.
- Refreshed `CONTEXT_INDEX.md` so future work loads these documents instead of relying on stale summaries.

---

## 2026-06-28 — Typo correction V0.9a/V0.9b transposition value

- Moved eligible adjacent-transposition correction candidates into the near-front area without default first-position promotion.
- Reused the bounded V0.8b learning store for explicit transposition selections; three selections may enable conservative learned promotion under existing assessment and prefix guards.
- Preserved the normal-RIME satisfaction gate: when RIME already returns the corrected best candidate first, the entire transposition suggestion remains suppressed.
- Kept Release defaults off and kept substitution, deletion, rejected, and multi-edit corrections outside local learning.
- Validated on a real device that `zohngguo -> 中国` enters the front area, accumulates local selections, reaches first position after repeated explicit choices, and preserves the `nihoa` normal-RIME suppression path.

---

## 2026-06-28 — Typo correction V0.9 transposition preflight

- Added a long-pinyin transposition audit case, `zohngguo -> zhongguo -> 中国`, because real RIME already handles the original `nihoa -> 你好` example in some environments.
- Suppressed the entire corrected-input suggestion when normal RIME already returns the corrected best candidate first, preventing low-value secondary candidates such as `拟好` or `你号` from leaking into the candidate bar.
- Added assessment-level short-input protection and kept transposition Debug-only, display-only, non-promoting, and excluded from V0.8b local learning.

---

## 2026-06-28 — Typo correction V0.8b local selection learning

- Added bounded, local learning for explicit insertion-correction selections without writing RIME weights, schemas, user dictionaries, surrounding text, or telemetry.
- Kept V0.8a ranking as the default: early selections only prioritize near-front correction candidates, while three explicit selections can promote an eligible insertion correction under conservative prefix guards.
- Added 90-day expiry, a 64-record limit, malformed-store fallback, and a Debug-only reset action on the smart-correction page.
- Kept substitution, deletion, transposition, multi-edit, rejected corrections, and Release-default behavior outside V0.8b learning.
- Validated on a real device that repeated explicit selection moves `niho -> 你好` to first position without regressing existing normal-input behavior.

---

## 2026-06-21 — Typo correction internal experiment switches

- Added Debug-only main-App switches for local insertion and transposition typo correction experiments, so real-device validation no longer requires temporary code edits.
- Kept Release behavior stable: experiment keys are ignored outside Debug builds and all experimental typo edits remain disabled by default.
- Wired the Keyboard Extension to refresh experiment settings through the existing App Group settings path, without changing RIME, candidate UI, ranking rules, or production typo behavior.

---

## 2026-06-21 — Typo correction V0.8a insertion display value

- Made eligible conservative near-final insertion correction candidates rank near the front when the experimental insertion flag is enabled, without allowing first-position promotion.
- Kept production typo correction defaults unchanged and kept transposition benchmark-only.
- Added ranker regression tests for insertion near-front placement and transposition non-promotion.

---

## 2026-06-21 — Typo correction V0.8 staging plan

- Recorded the V0.8 flag-on real-device finding: `niho -> nihao` is safe but appears too far back in the candidate list, while `nihoa -> 你好` is already handled by normal RIME behavior on device.
- Split the next insertion work into V0.8a front-display optimization and V0.8b local correction-selection learning, keeping both separate from RIME weights, RIME user dictionaries, telemetry, and production defaults.

---

## 2026-06-21 — Typo correction experimental audit gate

- Added a local flag-on audit for default-off V0.8/V0.9 insertion and transposition experiments, keeping production typo correction behavior unchanged.
- Extended the main-App 智能纠错 page with a read-only "实验开关审计" section that reports target coverage, normal-input regression, false positives, dangerous corrections, and device-validation readiness.
- Documented that passing the audit only qualifies a feature for real-device validation; it does not approve production enablement.

---

## 2026-06-21 — Typo correction V0.6 quality gates

- Added a pure KeyboardCore benchmark evaluator and result model so smart-correction coverage can be checked without runtime telemetry or real user input.
- Extended the main-App 智能纠错 page with a local read-only evaluation section showing pass status, expected/actual results, confidence, promotion, and assessment reason.
- Added assessment reason summaries and default-off experimental edit flags for future insertion and transposition validation without changing production keyboard behavior.
- Documented the V0.6-V0.9 quality-gate roadmap and kept RIME schema, RIME weights, candidate UI, and Typo Partial Commit defaults unchanged.

---

## 2026-06-21 — Typo correction V0.5 prioritized recall

- Prioritized safe single-edit typo suggestions before applying the fixed lookup window, so long-pinyin back-half mistakes such as `zhonghuo -> zhongguo -> 中国` can be resolved without increasing hot-path lookup volume.
- Preserved existing safety boundaries: no omitted-character, transposition, multi-edit, RIME schema, RIME weight, ranking, or candidate UI changes.
- Updated the smart-correction benchmark and read-only main-App explanation page to mark `zhonghuo -> zhongguo` as supported near-front coverage.
- Added the V0.5 prioritized-recall plan for future benchmark-driven typo correction work.

---

## 2026-06-21 — Typo correction V0.4 scoring and benchmark UI

- Added an explicit typo-correction assessment model for confidence tier, score, display eligibility, promotion eligibility, and reject reasons.
- Kept RIME weighting and typo scoring separate: RIME continues ranking candidates for the same input code, while typo correction only decides whether a corrected input code can contribute an optional side-channel candidate.
- Added a read-only main-App 智能纠错 page that explains local correction behavior, benchmark examples, scoring principles, unsupported boundaries, and the relationship to RIME candidate learning.
- Documented the V0.4 plan and updated the typo benchmark with assessment tiers and rejection reasons.

---

## 2026-06-21 — Typo correction V0.3 coverage

- Expanded the KeyboardCore typo-correction engine from final-character-only substitution to conservative all-position single-character adjacent-key substitution, covering examples such as `bihao -> nihao` and `nigao -> nihao`.
- Kept correction behavior benchmark-driven and optional: corrected inputs must still resolve through the candidate provider/RIME flow, and normal RIME candidates remain preserved.
- Added conservative ranking so final high-confidence corrections can still be promoted ahead of longer expansions, while initial and middle corrections enter the front area without blindly replacing the normal top candidate.
- Preserved safety boundaries: repeated-final deletion remains conservative, very short inputs are protected, and omitted characters, transpositions, multi-edit corrections, and unsafe non-final consonant/vowel cross-class replacements remain unsupported.
- Refined correction-candidate rendering so a first-position correction uses the same preferred candidate emphasis while showing the typo hint as a small secondary label instead of truncating the candidate text.
- Documented the V0.3 coverage plan and updated the typo benchmark to distinguish typo correction from traditional RIME fuzzy pinyin and Lua advanced input.

---

## 2026-06-19 — Advanced input settings and Settings cleanup

- Added a shared advanced-input settings model for user-facing features such as 日期与时间、计算器、数字大写、随机编号, and candidate optimization without exposing internal Lua component names in the UI.
- Added a global Advanced Input settings page that disables controls when the active scheme does not support them, while preserving the user's choices for supported schemes.
- Added plain-language usage guidance for advanced input examples such as date/time shortcuts, calculation results, number formatting, random identifiers, and special content.
- Reorganized the main Settings tab into clearer sections for input experience, input schemes, tools, and diagnostics.
- Moved diagnostic logging controls into a second-level diagnostics settings page so the Settings tab keeps only one entry point.
- Fixed the app appearance setting to update the active root view reliably and migrated any previous standard-defaults value into the shared settings store.
- Split the `rime_ice` advanced-input settings and diagnostics links into separate Form rows to avoid overlapping tap targets.
- Made deployment apply advanced-input preferences before full RIME deployment, preserving a restorable source schema so disabled features can be turned back on without redownloading.
- Expanded dynamic-input diagnostics and compatibility post-processing to cover the full processor/segmentor/translator/filter component family.
- Prevented app launch/settings refresh from showing a stale "RIME 设置已生效" toast when the app merely reads an already-deployed state from shared storage.
- Removed the duplicate Advanced Input entry from the RIME scheme settings page; advanced-input switches now stay in the main Settings tab while scheme pages focus on scheme state and recovery actions.
- Kept number and calculator-style symbol keys inside the active Chinese RIME composition so inputs such as `N20260619` and `cC1+2` are not split by the symbol page, while ordinary punctuation still commits the current candidate first.
- For ordinary pinyin followed by number-page digits, keep the inline preedit as raw input such as `nihao123` while showing the transformed first candidate such as `你好123`, avoiding librime's default number-key candidate selection until the user confirms.
- Preserved raw-input deletion and highlighted candidates for ordinary pinyin-number suffix input, so `nihao123` deletes as `3`, `2`, `1`, `o`... while the candidate bar updates or clears at the right composition boundary.
- Updated RIME scheme-management docs, the Lua capability plan, and the Swift 6 manual acceptance record with the partial physical-device Lua smoke evidence and remaining coverage gaps.

---

## 2026-06-18 — RIME Lua diagnostics and deploy module alignment

- Added a main-App `rime_ice` Lua capability diagnostic that distinguishes unavailable engine support, stripped schema files, missing Lua files, pending deployment, inactive schema, and ready states without touching the keyboard input path.
- Exposed RimeBridge Lua capability metadata so tests and main-App diagnostics can verify the compiled bridge and deployment module list.
- Aligned `RimeDeployer` with the keyboard session engine by loading the `lua` module under `RIME_HAS_LUA` during full main-App deployment.
- Added a conservative "高级输入功能" status section on the `rime_ice` detail page with recovery actions for selecting the scheme, reapplying RIME settings, redownloading incomplete files, and opening diagnostics.
- Documented the scheme-detail status boundary in `docs/RIME_SCHEME_MANAGEMENT.md`; the UI says "基础检查通过" instead of claiming Lua dynamic candidates are fully available before real smoke testing.
- Expanded Lua file diagnostics to derive required `lua/*.lua` files from schema `lua_processor` / `lua_translator` / `lua_filter` references.
- Cleared scheme-specific RIME build cache entries before forced redownloads so old compiled artifacts do not mask recovered schema files.
- Added an opt-in iOS Simulator Lua smoke-test skeleton gated by `UK_RIME_LUA_SMOKE_SHARED_DIR` and `UK_RIME_LUA_SMOKE_USER_DIR`; it skips without a real runtime fixture.
- Added simulator and service tests for deployment module coverage and the new Lua diagnostic states.
- Recorded the staged 雾凇拼音 Lua implementation plan in `docs/plans/rime-ice-lua-full-capability-plan.md`; real Lua smoke testing remains pending.

---

## 2026-06-14 — RIME scheme operation feedback V1.2

- Added a shared in-flight operation state for scheme-side effects such as checking updates, downloading, redownloading, and uninstalling.
- Prevented repeated taps from starting duplicate scheme operations; repeated taps while a scheme operation or download is active now show a throttled global toast instead of creating extra tasks.
- Added loading labels and disabled states to scheme management buttons while an operation is running.
- Moved scheme operation results into the global bottom toast, including up-to-date, update-check failure, download start/completion/failure, redownload start, and uninstall completion messages.
- Split update checking into explicit results for update available, already current, and failed, so network failures no longer look like "already current".
- Added regression coverage for duplicate update taps, update-check failure release, and uninstall toast/release behavior.

---

## 2026-06-14 — RIME multi-scheme management V1.1 infrastructure

- Added a catalog-backed RIME scheme model covering scheme metadata, download distribution, storage keys, license metadata, user-dictionary capability, and installation plans.
- Moved rime_ice download, version, ETag, installation, uninstall, and update checks onto generic schema-ID based manager methods while preserving the existing user-facing 雾凇 behavior.
- Generalized archive installer boundaries so cache paths, extraction directories, installed-file checks, install filters, uninstall cleanup, and build-cache cleanup come from each scheme's installation plan.
- Kept the V1 list/detail UI visually stable while making download cards, license acceptance, update checks, redownload, and uninstall actions use the current scheme metadata and schema ID.
- Expanded SchemaManager coverage to assert catalog metadata reaches the scheme list and kept the existing update, install, uninstall, and deployment tests passing.

---

## 2026-06-14 — RIME multi-scheme management V1

- Reworked the main RIME settings page into a scalable scheme list with per-scheme detail pages, preparing the UI for more open-source schemes without making the top-level settings page long.
- Moved scheme-specific actions such as setting the active scheme, downloading, updating, redownloading, uninstalling, and viewing the license into the matching scheme detail page.
- Kept global RIME preferences and deployment status on the top-level RIME settings page because they apply across schemes rather than belonging to one scheme.
- Added compact per-scheme status text and icons for current, installed, downloadable, downloading, and failed states.
- Documented the V1 scheme-management structure and future extension rules in `docs/RIME_SCHEME_MANAGEMENT.md`.

---

## 2026-06-13 — RIME candidate learning V1.1 backup basics

- Refined the candidate learning settings page with plain-language status text for whether learning is on, whether there is anything learned, and whether a backup exists.
- Added per-schema local backup and latest-backup restore actions for the built-in `luna_pinyin` scheme and the downloaded `rime_ice` scheme.
- Added backup manifests so the settings page can disable redundant backups when the latest backup already matches current learning data.
- Added an off-by-default automatic backup switch that runs only from the main App at low-risk moments and skips duplicate backups.
- Reworked the candidate learning UI into a scalable scheme list with per-scheme detail pages, so future open-source schemes do not repeat across multiple long sections.
- Moved candidate-learning operation feedback into the shared global bottom toast and kept scheme rows focused on short status text plus a compact status icon.
- Made restore replace the matching scheme learning data and mark RIME for the same automatic main-app apply flow used by candidate learning and fuzzy pinyin settings.
- Added regression coverage for backup, restore, no-backup, status-copy, and file-level `{schema}.userdb*` restore behavior.

---

## 2026-06-13 — RIME candidate learning settings

- Added a main Settings entry for candidate learning, covering the built-in `luna_pinyin` scheme and the downloaded `rime_ice` scheme separately.
- Added per-schema user dictionary learning switches that write `translator/enable_user_dict` into schema custom YAML during the main-app deployment path.
- Added per-schema learning-record reset actions that remove only the matching `{schema}.userdb*` data from the App Group RIME user directory.
- Extended the pending-deploy flow so candidate-learning changes use the same automatic apply behavior and global bottom toast as fuzzy pinyin settings.

---

## 2026-06-13 — RIME fuzzy pinyin UX refinement

- Moved fuzzy pinyin settings out of the RIME scheme page and into the main Settings page as an input-habit preference.
- Added a master fuzzy pinyin switch while preserving detailed `zh/z`, `ch/c`, `sh/s`, and `n/l` preferences.
- Replaced the fuzzy page deploy button with pending-deploy scheduling on page exit/app lifecycle, guarded by a fuzzy settings deployment signature to avoid unnecessary redeploys.
- Added a main-app global bottom deployment toast for RIME applying/success/failure states; the Keyboard Extension continues using the last compiled config and does not block input while deployment is pending.
- Refined the RIME scheme management UI with non-cramped two-column action buttons and made the scheme deployment page rely on the shared global deployment toast for transient progress/results.
- Added a reusable `AppActionButton` so main-app content actions share one Liquid Glass style across RIME download, deployment, retry, reset, destructive management, and license acceptance flows.

---

## 2026-06-13 — RIME fuzzy pinyin Phase 1

- Added traditional RIME fuzzy pinyin settings for `zh/z`, `ch/c`, `sh/s`, and `n/l`, defaulting the four common initial-consonant groups to enabled.
- Added active-schema-only deployment post-processing that preserves existing `speller/algebra` rules and manages only the `# universe:fuzzy-pinyin begin/end` block.
- Added a dedicated main-app fuzzy pinyin settings page; toggles save App Group settings and mark RIME as needing redeploy instead of compiling on every change.
- Documented the separation between RIME fuzzy pinyin and small-screen typo correction in `docs/RIME_FUZZY_PINYIN.md`, `CONTEXT_INDEX.md`, and `docs/TYPO_BENCHMARK.md`.

---

## 2026-06-13 — Context-aware symbol page input

- Added a main App input setting for paired-symbol auto-completion, stored as `paired_symbol_completion_enabled` and defaulting to enabled.
- Strengthened number/symbol page one-shot behavior with mode-specific whitelists: Chinese mode uses `；（）@“”。，、？！【】｛｝#%^*+=_\｜《》&·`, while English mode keeps half-width punctuation such as `.` as one-shot.
- Fixed Chinese-mode ASCII period and non-composition `‘` handling so they no longer return to letters, while symbols such as `#`, `（`, and `“` do.
- Added digit-key protection so symbol-page numbers never auto-return to letters.
- Added paired-symbol insertion for left paired marks such as `（`, `“`, `【`, `｛`, and `《`, placing the cursor between the inserted pair when the setting is enabled.
- Chinese composition now stays alive when switching from letters to the number page; pressing ordinary punctuation commits the first RIME candidate before inserting the symbol, while active-composition `‘` is routed to RIME as an apostrophe separator for inputs such as `wa'o` and then returns to letters.
- Fixed Partial Commit + paired-symbol ordering so selecting a prefix candidate and then pressing a left paired symbol commits the remaining first candidate before inserting the pair, for example `还找` + `（` becomes `还找得到（|）`.
- Cleared stale candidate presentation when symbol input both commits composition and returns to letters, so the candidate bar reflects the same state as a first-candidate confirmation.
- Expanded KeyboardCore regression coverage for empty-context symbols, digit symbols, paired-symbol cursor placement, RIME composition + punctuation commit, and the Chinese apostrophe separator path.

---

## 2026-06-12 — Marked text composing underline

- Replaced the plain inline preedit rewrite path with `UITextDocumentProxy.setMarkedText(_:selectedRange:)` / `unmarkText()`, allowing host text fields to show the system composing underline for active Chinese input.
- Return now commits non-partial RIME composition using `rawInput` instead of display `preeditText`, so segmented preedit such as `ni h` confirms as `nih` and clears the underline.
- Number and symbol pages now behave as one-shot symbol layers: after a normal symbol is inserted from either page, the keyboard returns to the letters page while preserving Chinese/English input mode.
- Kept active Partial Commit displays marked until final commit, so selected Chinese segments and the remaining preedit stay visually connected as one unfinished composition.
- Added `TextInputClient` marked-text methods and expanded `FakeTextInputClient` test state so unit tests can distinguish visible text from still-marked composition text.
- Updated regression coverage for normal RIME commits, unknown raw commits, segmented RIME Return commits, Partial Commit, typo Partial Commit, delete restore, mode switch, Return, direct text insertion, one-shot symbol pages, and final-commit fallback paths.

---

## 2026-06-11 — Candidate touch hit-area hardening

- Fixed candidate-gap hit testing in the Keyboard Extension by keeping `UICollectionView` item spacing at zero, preserving the visual gap inside each cell, and retaining a nearly invisible cell backing so the apparent gap is still a valid pan start area on real devices.
- Removed visible red diagnostic backgrounds from candidate cells and expand/collapse chevrons. Candidate touch diagnostics now remain log-only for visuals, so enabling display diagnostics no longer changes the touch surface being tested.
- Expanded the real hit area for the candidate expand/collapse chevrons through button hit testing and invisible backing, preserving the native-looking chevron while improving tap and downward-swipe reliability.
- Applied the same hit-area principle to the key input region across text, symbol, bottom-row, and emoji insertion keys: visual key spacing stays unchanged, while the root keyboard stack splits dead-space touches at adjacent midlines into per-key touch cells, keeps a nearly invisible backing surface always active without red debug overlays, and keeps forwarded touches valid through key tracking.

## 2026-06-09 — Liquid Glass keyboard appearance tuning

- Adapted the keyboard presentation toward the iOS 26/27 system rounded keyboard container while avoiding a second custom rounded surface inside the extension.
- Added a main-app experimental switch for the material-based Liquid Glass path, but kept the default keyboard path conservative so visual regressions can be compared against the system-provided container.
- Reduced the candidate bar height and tightened the candidate/top spacing while keeping key row heights, input logic, RIME, feedback, and delete behavior unchanged.
- Final visual tuning lowers the keyboard by trimming only content insets (`top 2pt`, `bottom 0pt`) while preserving input-row height and candidate-bar height; candidate text was increased slightly for readability.
- Removed the candidate/key separator and expanded the candidate chevron hit area to make candidate expansion easier to trigger.
- Fixed an iOS 26 candidate-list washout: `UICollectionView` inherits `UIScrollView` edge effects, and the new `UIScrollEdgeEffect` visually added a rectangular fade/overlay over the first candidate row. Candidate scroll views now hide all four scroll edge effects on iOS 26+.
- Candidate cells now render with a plain `UILabel` plus an explicit highlighted background view instead of `UIButton.Configuration`, keeping candidate text rendering independent from system button/material compositing.
- Real-device validation confirmed the horizontal candidate overlay disappeared after disabling candidate scroll edge effects.

---

## 2026-06-07 — Feedback UX Phase 1

- Replaced continuous key click and haptic controls with independent switches plus five discrete levels: light, softer, normal, stronger, and heavy.
- Added `KeyboardFeedbackSettings` as the shared feedback settings model, including `KeyboardFeedbackEvent` (`tap`, `modeEnter`, `repeat`, `commit`, `preview`) and migration from legacy `key_click_volume` / `haptic_intensity` values without deleting the old keys.
- Rebuilt the main-app feedback settings UI around list-based level selection with automatic preview, same-level suppression, and preview throttling to avoid click or haptic bursts during rapid changes.
- Added a clear `modeEnter` haptic when space long-press actually enters cursor movement mode; cursor movement itself remains silent.
- Completed Delete Repeat UX Phase 1.1: delete speed stays unchanged, repeat feedback is emitted only after an effective delete, empty-field long press is silent after the first tap feedback, click feedback is more frequent than haptic feedback, and repeat click keeps an independent `tapVolume * 0.60` multiplier.
- Tuned key click audio for long-session comfort: final `ClickSoundGenerator` uses a short native-style 9ms click with 1450Hz fundamental, 2900Hz light harmonic, low noise, softened attack/decay, and a reduced five-level volume curve (`0.15 / 0.24 / 0.36 / 0.48 / 0.60`).
- Real-device validation completed across normal typing, long-press delete, settings preview, and heavy-level click tuning; the final target is light, short, restrained feedback that confirms typing without taking over the interaction.

---

## 2026-06-07 — Native-style symbol page layout refresh

- Reworked Chinese and English number/symbol pages to match native keyboard ordering more closely while keeping the V1 frozen geometry constants unchanged.
- Added first-level and second-level symbol rows with function-wrapped third rows (`#+=` / `123` on the left, Delete on the right) and shared non-letter bottom rows (`拼音` or `English`, emoji, space, dynamic Return).
- Switched emoji page buttons to a template SF Symbol so they follow the same text color as other function keys instead of rendering as a colored emoji glyph.
- Added an English smart double-quote key: the visible `”` key inserts `“` first, then `”`, and returns to opening behavior after the surrounding quotes are deleted from the input context.
- Added a visible `^_^` kaomoji entry point on the Chinese second-level symbol page as a placeholder for a future candidate-bar kaomoji picker.

---

## 2026-06-05 — Partial Commit milestone closure

- Documented the completed Partial Commit milestone across normal RIME candidates, Delete restore, typo correction Partial Commit V1, and Phase 3 V2 stabilization.
- Recorded the current product decision: typo correction Partial Commit keeps Delete restore behavior for now, with no further optimization until English input mode architecture is revisited.
- Added `docs/architecture/partial-commit.md` as the architecture and merge-readiness reference, including feature flag status, known boundaries, and recommended squash-merge/tag strategy.

---

## 2026-06-05 — Typo correction Partial Commit Phase 3 V2 stabilization

- Expanded stabilization coverage for typo correction Partial Commit without changing typo generation, ranking, UI, or the default-off feature flag.
- Added regression coverage for full-commit fallback boundaries: repeated-final deletion, multi-edit corrections, missing corrected candidates, no remaining composition, and typo correction selection during an active partial commit.
- Added lifecycle and parity coverage for final candidate commit, space/return/direct-text commit, visibility recovery, and candidate paging while typo partial commit is active.
- Clarified feature-flag exit requirements and documented that intermediate-syllable typo correction remains outside the current typo engine scope.

---

## 2026-06-05 — Typo correction Partial Commit Phase 3 V1

- Completed a default-off internal path for typo correction candidates to reuse the existing Partial Commit pipeline.
- Typo correction partial commit preserves the exact original typo input as the Delete restore target, continues composition through the corrected RIME input, and invalidates the checkpoint after continued typing.
- Real-device validation passed for flag-off regression behavior and flag-on typo partial commit, Delete restore, and checkpoint invalidation.
- Known boundary: V1 only supports typo correction candidates already produced by the current typo engine. Intermediate-syllable typo correction, such as `nihapanpai -> nihaoanpai`, is not implemented and belongs to a later phase.
- Added regression coverage for flag-off full commit behavior, repeated-final deletion exclusion, corrected-candidate fallback, and real RIME-style selected-segment preedit.

---

## 2026-06-04 — Reversible partial commit for RIME candidates

- Added normal RIME partial commit for selecting a shorter candidate inside an active composition, e.g. `nihaoanpai -> 你好an pai`.
- First Delete restores the previous raw composition and candidate list by rebuilding the RIME session from raw input; subsequent Delete resumes normal RIME deletion.
- Real-device validation confirmed no duplicate selected segment, restored `你好安排` candidates after undo, and normal candidate refresh after the second Delete.

---

## 2026-06-03 — Partial Commit Phase 1 infrastructure

- Added RIME raw-input and candidate-page contracts, plus a `replaceInput` capability for future composition restoration.
- Added stable candidate selection reference metadata and a single-checkpoint `PartialCommitState` model without changing candidate, Delete, UI, or typo-correction behavior.

---

## 2026-06-03 — Segmented RIME preedit typo correction

- Normalized display-oriented segmentation spaces in real RIME preedit before typo matching and corrected-candidate lookup.
- Verified on a real device that `nihap -> nihao -> 你好` appears as a correction candidate, commits immediately, clears composition, and no longer continues matching `安排`.

---

## 2026-06-03 — Feedback settings and RIME management reliability

- Persisted keyboard sound and haptic settings through the shared App Group store, refreshed extension-side cached values when the keyboard appears, and documented the Allow Full Access dependency for shared settings and diagnostics.
- Separated RIME update checks from forced redownloads: update checks now compare the installed release tag and report when rime_ice is already current, while redownload always starts a fresh download.
- Removed temporary runtime diagnostics after validating the App Group and deployment paths.

---

## 2026-06-02 — Typo correction benchmark reference

- Added `docs/TYPO_BENCHMARK.md` as the benchmark reference for fuzzy pinyin typo correction coverage, scoring principles, known unsupported categories, and next milestone guidance.
- Linked typo correction work in `CONTEXT_INDEX.md` and added a long-term `CLAUDE.md` note requiring future correction rules, ranking, and UI work to use `TypoCorrectionTests` plus the benchmark document as the source of truth.

---

## 2026-06-01 — Keyboard UI V1 freeze

- **Frozen layout baseline**: `candidateBarHeight=44`, `keyHeight=45`, `keySpacing=8`, `keyboardGroupSpacing=10`, `keyHorizontalSpacing=6`, `thirdRowFunctionSpacing=10`, `primaryFunctionKeyWidth=46`, `functionKeySymbolPointSize=18`, horizontal margins `7`, `keyCornerRadius=9`.
- **Input feedback baseline**: standard keys emit visual press state, haptic feedback, and key click together from touch-down. Candidate commits and long-press variant commits use the shared feedback helper at commit time. Key click playback keeps the overlapping rapid-typing behavior.
- **V1 UI freeze rule**: keyboard UI is frozen unless a major usability issue is found. Future UI changes must cite a specific usability reason such as mistouch reduction, clipping, accessibility, or interaction regression.
- **Manual verification checklist captured**: slow typing, rapid typing, repeated function keys, long-press delete, edge keys, candidate commits, and accessibility labels.

## 2026-05-25 (evening) — 候选栏滑动检测重构

- **三层滚动检测**: ① `scrollViewDidScroll` 用百分比阈值（>60% 可滚宽度）替代绝对距离 ② `scrollViewWillEndDragging` 预测性触发（Apple 推荐方式，在 deceleration 开始前触发）③ `scrollViewDidEndDragging` overscroll 兜底（>30pt）
- **百分比阈值更可靠**: 候选栏/展开面板统一用 `progress = offset / max(1, scrollableWidth)` > 0.6，不受设备宽度或候选数量绝对值影响
- **新增 6 个 loadMore 流程测试**: pageDown/pageUp 恢复、composing 状态保持、去重逻辑、预加载流程、多次翻页回到页1、深度追踪

**Key Lessons:**
- 百分比阈值优于绝对距离。80pt 阈值在不同设备/不同候选数量下表现不一致，60% 可滚宽度是通用解法。
- 三层检测（scroll + willEndDrag + didEndDrag）互补覆盖所有滚动场景。单靠 `scrollViewDidScroll` 可能在快速滑动时漏检。

---

## 2026-05-25 (afternoon) — 关键 Bug 修复

- **Bug 1 (候选栏滚动后空格失效)**: 预加载和 `loadMoreCandidates` 使用 `controller.handle(.candidatePageDown)` 污染了 `state.lastRimeOutput`（从第1页变为第2/N页）。修复：直接用 `engine.pageDown()`/`pageUp()`，不经过 controller。添加 `candidatePageDepth` 跟踪深度，每次加载后回到第1页。`handleInsertSpace` 改为从 `lastRimeOutput.candidates.first` 直接取最佳候选提交。
- **Bug 2 (首候选背景拉伸)**: 候选栏 `UIStackView` 的 `.fill` distribution 导致单按钮被拉伸至整行宽。修复：在 `fillCandidateBar` 和 `appendToCandidateBar` 末尾添加 low-hugging trailing spacer。
- **Bug 3 (选择候选后删除键重现拼音)**: `handleInsertCandidate` fallback 路径没有调用 `engine.resetSession()`，RIME 残留旧 composition。删除时 `isComposing()` 仍返回 true → 从残留拼音删除 → 重现旧拼音。修复：fallback 路径添加 `rimeEngine?.resetSession()`，`handleInsertSpace` 所有分支都确保重置。
- **Bug 4 (应用切换后无候选词)**: 键盘挂起恢复后 RIME session 可能失效，`viewDidAppear` 未做检查。修复：`viewDidAppear` 调用 `engine.resetSession()` + 清空累积状态。
- 新增 7 个回归测试。Test suite at this point: 341 → 347 tests, 0 failures.

**Key Lessons:**
- 预加载/翻页必须直接用 engine，不能经过 `controller.handle`。`controller.handle(.candidatePageDown)` 会更新 `state.lastRimeOutput`，破坏 UI 层依赖的"第1页"假设。UI 层翻页累积候选词 ≠ RIME 引擎翻页改变内部状态，两者必须解耦。
- 所有候选/空格提交路径都必须 `engine.resetSession()`。无论是 RIME 路径还是 fallback 路径，提交后残留 composition 会导致下次删除从旧拼音删除、重现候选词。
- `.fill` distribution 的 UIStackView 不能有单按钮行。每行末尾加 trailing spacer 是最简单的防御措施。
- `viewDidAppear` 是键盘恢复的最后防线。应用切换后 session 可能丢失，在这里重置保证干净状态。→ *Promoted to Key Design Decisions in CLAUDE.md.*

---

## 2026-05-25 (morning) — 候选栏交互全面重构 + Apple HIG 合规

- **Candidate bar swipe-based pagination**: Removed ◀ ▶ page buttons. Infinite horizontal scroll with auto-load: user scrolls right → near-edge detection triggers RIME page-down → new candidates appended via `appendToCandidateBar()` (no clear+rebuild flash). `scrollViewDidScroll` near-right-edge detection (80pt) + `scrollViewDidEndDragging` overscroll fallback (40pt).
- **Pre-load 2 pages**: `refreshCandidateBar()` immediately fetches RIME page 1 + page 2 on new input, showing ~18 candidates upfront. `loadMoreCandidates()` appends subsequent pages on demand.
- **Expanded panel redesign**: Flow layout replaces fixed 4-column grid. Buttons wrap naturally by text width, trailing spacers prevent `.fill` distribution stretch. Panel fills entire keyboard area (252pt, candidate bar disappears when expanded). Collapse button (chevron.up, 44×44pt) floats top-right above scrollView. Vertical infinite scroll with bottom-edge detection (80pt).
- **Fade mask refined**: Gradient range 82%→92%, last candidate almost fully visible.
- **Apple HIG P0 (Touch Targets)**: `candidateBarHeight: 36→44` (≥44pt). Expand/collapse buttons: 34×36→44×44pt.
- **Apple HIG P0 (VoiceOver)**: All candidate/expand/collapse buttons have `accessibilityLabel` + `accessibilityHint`. Composition items read "提交拼音 X".
- **Apple HIG P1 (Dynamic Type)**: `UIFontMetrics(forTextStyle: .body).scaledFont(for:maximumPointSize: 28)` replaces hardcoded `systemFont(ofSize:)`.
- **Apple HIG P2 (Semantic colors + 8pt grid)**: Highlighted background uses `.systemGray3`/`.systemGray6`. Candidate stack spacing 3→4pt, highlighted insets 6→8pt, vertical panel spacing 5→4pt.
- **Apple HIG P3 (Spring animation + indicator)**: Chevron rotation uses `usingSpringWithDamping: 0.75` spring. "More" indicator `⋯` (U+22EF, `.quaternaryLabel`) appended when `hasMoreCandidates`, removed when exhausted.
- **KeySpacing split**: `keySpacing: 8` (vertical between rows) + `keyHorizontalSpacing: 6` (horizontal within rows). Total height 250→258pt.
- Test suite at this point: 347 KeyboardCore tests, 0 failures.

---

## 2026-05-22 (afternoon) — Flickering 修复 + Session 自动恢复

- **Flickering fix (current approach)**: `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews`. After `viewDidAppear`, the first layout pass with `view.bounds.height` in range (0, 400) sets `view.alpha = 1`. This waits until the 3-phase resize settles to the final height (250pt on iPhone 13 Pro). The intermediate heights (844pt, 445pt) are filtered out by the `< 400` guard.
- **RIME session auto-recovery**: `RimeSessionManager.processKey` now detects `sessionId == 0` and automatically calls `create_session()` + `select_schema()` to recover, instead of returning empty output.
- **Expanded candidate panel height capped**: `makeExpandedCandidatePanel()` container constrained to `keyHeight * 4 + keySpacing * 3` (194pt). Overflow candidates scroll vertically in `UIScrollView`.
- **Logger category enhancement**: Added `Category.display` (DISP). Per-category toggle switches in settings (性能/画面/引擎/配置/部署/通用). `DiagnosticsView` with category filter chips and color-coded log lines (ERROR=red, WARN=orange, PERF=blue, DISP=purple).
- **iPhone 13 Pro**: Primary test device. Final keyboard view height: 258pt (may vary 216–268pt). Layout constants: `candidateBarHeight=44`, `keyHeight=44`, `keySpacing=8` (vertical), `keyHorizontalSpacing=6` (within-row), `keyCornerRadius=9`, horizontal margins 4pt. `preferredContentSize=258pt`.
- **RIME session diagnostics**: NSLog in `RimeSessionManager.m` for `processKey(sessionId=0)`, `createSession`, `destroySession`, plus `select_schema` after auto-recovery.

**Flickering approaches attempted and discarded:**
1. *Alpha=0 + fadeInKeyboardIfNeeded()* (original): iOS presentation animation overrides `view.alpha=0` during the 3-phase resize, causing half-screen flash at 445pt.
2. *Mask overlay*: solid-color mask view covered keyboard content. Mask itself visibly changes size 844→445→250pt — user sees the mask shrinking.
3. *Bottom-anchored layout*: rootStack pinned to view bottom with fixed height. Failed because final view height varies (216–250pt), and fixed content height either clips or leaves too much empty space.
4. *Async alpha in viewDidAppear*: `DispatchQueue.main.async` not guaranteed to land after the final layout pass.
5. *Current approach*: top+bottom pinning (original layout) + `view.alpha = 0` + height-triggered reveal. ✅ Simplest solution that works.

---

## 2026-05-21 (evening) — 性能与稳定性优化

- **Keyboard flickering mitigation**: `view.alpha = 0` + height-stability-detection fade-in (via `fadeInKeyboardIfNeeded()`) to mask iOS system's 3-phase keyboard resize (full-screen → intermediate → final). Apple DTS confirmed no API can prevent the resize itself.
- **Candidate bar simplified**: Removed button reuse + associated-object tracking (`objc_getAssociatedObject` Bool bridging issue). Replaced with simple clear-rebuild each refresh. 20-button creation <0.5ms vs RIME 2–5ms — negligible.
- **Enter key chat-app adaptation**: `updateReturnKeyAppearance()` checks `textDocumentProxy.returnKeyType` and `hasText` — action keys (send/search/go) show blue accent when text present, gray when empty. Called from `textDidChange`, `syncUI`, `reloadKeyboard`.
- **ForEach duplicate ID fix**: `DiagnosticsView.swift` + `RimeSettingsView.swift` — changed `ForEach(lines, id: \.self)` to `ForEach(Array(lines.enumerated()), id: \.offset)` to handle repeated log lines.
- **Performance optimization**: `KeyClickPlayer` audio moved to background serial queue — main-thread blocking reduced from 18–76ms to <1ms per keystroke.
- **Double-tap bug fix**: Removed `UIView.animate` from `keyTouchDown`/`restoreKeyAppearance` — rapid same-key taps now register reliably.
- **Deduplicated data source**: `candidateItems()` called once per keystroke (was twice in expanded mode).
- **Touch feedback**: Instantaneous `transform` + `backgroundColor` (no Core Animation transactions per keystroke).

**Key Lessons:**
- iOS keyboard flickering is unfixable at the API level. Apple DTS engineers confirmed: the keyboard extension runs in a separate process, the system assigns wrong heights (844→445→216) before correcting. No constraint, `intrinsicContentSize`, `allowsSelfSizing`, or `preferredContentSize` prevents it. Only mitigation: alpha fade-in.
- Final keyboard height varies. On iPhone 17 with iOS 26 non-adapted apps, the final height is **216pt** (not the standard 250–268pt). → *Promoted to Key Design Decisions in CLAUDE.md.*
- Do NOT override `loadView` in `UIInputViewController`. It breaks the RIME bridge (processKey returns 0 candidates with 0.0ms bridge time). → *See `docs/architecture/swift6-migration.md` Regression Invariants.*
- Bottom anchoring causes candidate bar clipping at 216pt. `rootStack.height(236) + bottomMargin(8) = 244pt` minimum, but view is only 216pt → top 28pt clipped.
- Associated-object Bool bridging is unreliable. `objc_getAssociatedObject(...) as? Bool` can fail on `__NSCFBoolean`. Simpler: just rebuild.
- Log aggressively. Without `viewDidLayoutSubviews` frame logging, we wouldn't know the final height is 216pt or that `viewDidAppear` fires at intermediate height 445pt.

---

## 2026-05-21 (earlier) — Swift 6 企业级重构 + RIME 统一桥接

- Enterprise-grade refactoring: RIME C/ObjC ownership consolidated in `Packages/RimeBridge`; Swift 6 baseline verified 347 KeyboardCore tests with 0 failures.
- Duplicate WAV generation unified → `ClickSoundGenerator` in KeyboardCore.
- Duplicate Lua stripping removed from SchemaManager → uses `RimeConfigPostProcessor`.
- Schema repair and Lua stripping are performed in the main App preparation/deployment flow; `RimeEngineImpl.init` only starts an input session over prepared data.
- BulletRow + CapsuleBadge patterns unified into shared components (11 call sites updated).
- `RIME_HAS_LUA=1` defined in Keyboard target preprocessor macros.
- `activateRimeIce()` + `deployRimeConfig()` order swapped: schema activated BEFORE deploy, so deploy compiles the correct schema and flags are not overridden.
- `t9.schema.yaml` always installed (was conditionally skipped, causing "missing input schema: t9" in deployment_tasks.cc).
- App-side `RimeConfigManager.prepareDirectories()` schema repair is guarded by `!rimeDeployed` so it respects prior deployment results.
- `RimeSettingsView.deployState` now refreshes via `.onChange(of: rimeIceDownloadState)` instead of only on `onAppear`.
- `RimeDeployer.finalize` renamed to `cleanup` to avoid NSObject deprecated-method collision.
## 2026-06-15 — 输入体验区域重构：简繁转换与候选数量移至设置页顶层

- 将简繁转换和候选数量设置从「RIME 方案设置」内部提升到「设置 > 输入体验」区域，让用户更方便调节日常输入体验。
- 简繁切换和候选数量（松手时）都会自动触发 RIME 部署，无需手动点「应用并重新部署」。
- 候选数量 slider 使用 `onEditingChanged` 防抖，快速拖动不会触发多次部署。
- 修复 RIME 桥接层 `syncSchemaCustomYaml` 中简繁设置只写给当前激活方案的 bug，现在两个拼音方案都写入 `switches/@1/reset`。
- 移除了已无内容的 `RimePreferencesSections.swift`。
- 更新了 RIME 部署页的步骤文案和 footer 说明，删除"修改上方设置"等失效引用。

---
