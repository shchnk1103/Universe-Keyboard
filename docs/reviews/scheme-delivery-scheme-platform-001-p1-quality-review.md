# SCHEME-DELIVERY-SCHEME-PLATFORM-001 — P1 Independent Quality Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | Independent Quality（read-only; this review session） |
| Date / timezone | `2026-09-12 Asia/Shanghai` |
| Frozen commit | `3cfa35515656cf7ac31a3dae3fd64960ecfc37f4` (`3cfa355`) on `codex/scheme-platform-001` |
| Engineering subjects | P1-1…P1-5 extract tips: `7a50165` · `5bba4d2` · `22c6b79` · `5c42546` · `3cfa355`（+ merges `d8e8299` / `82bdd60`） |
| Assignment / plan | [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) · [`P1 extract plan §4 Ice regression`](../plans/scheme-platform-p1-extract-plan-2026-09-10.md) · [`P1 summary`](../plans/scheme-platform-p1-summary-2026-09-12.md) |
| Objects | `SchemeAdapter.swift` · `SchemeUninstallHooks.swift` · `ResourceOwnership.swift` · `RimeIceSharedDefaultAdapter.swift` · `RimeRuntimeSelection.swift` · `SchemaArchiveInstaller.swift` · `SchemaManager+Download.swift` / `+Installation.swift` / `+T9Layout.swift` · KeyboardCore tests `SchemeAdapterRegistryTests` / `ResourceOwnershipStrategyTests` / `SchemeUninstallHooksTests` · App `SchemaManagerTests` / coexistence anchors |
| Independence | 生产 Swift **只读**。未为 Pass 改代码或弱化测试。唯一写入：本审查文件 + Assignment / ACTIVE_WORK / KOS / P1 summary 治理联动（P1-6 docs）。 |
| Scope | P1 Ice-as-reference platform extract（registry → LayoutCapability → SharedDefault Ice privatePreset → ResourceOwnership dual → UninstallHooks Ice layout fallback）。**不是** ADR Accept；**不是** Product Gate；**不是** Assignment Close；**不是** P2 / Discovery UI / Wanxiang nine-key。 |

**HEAD 核对：** `git fetch` 后 `git rev-parse HEAD` = `3cfa35515656cf7ac31a3dae3fd64960ecfc37f4`；与 `origin/codex/scheme-platform-001` 一致（P1-5 already on remote）。`.codex-p4-wip.patch` 保持 **untracked**（不纳入本审查 / 不 commit）。

---

## Verdict

**Pass with conditions**

P1 extract on freeze tip `3cfa355` meets the Ice-as-reference contract for Independent Quality: no open **P0 / P1** findings **in P1 extract scope**. Registry + adapters mirror today’s Ice / Wanxiang / Luna hardcodes; LayoutCapability keeps Ice-only nine-key (`t9`) and Wanxiang `supportsNineKey=false`; SharedDefault extracts Ice `privatePreset` only（Wanxiang `consumePrelude` transitional）; ResourceOwnership keeps long-term dual `namedList` + `exactHash` without whole-dir wipe; UninstallHooks shapes Ice layout fallback only（26-key + invalidate readiness）without Discovery A/B UI.

Finding counts at freeze `3cfa355`: **P0: 0 · P1: 0 · P2: 2 · P3: 4**（见 Findings / Residuals；均有显式 disposition，**未**静默关闭）.

本 Verdict：

- **不是** ADR 0034 Accept；**不是** undraft/merge draft #101；
- **不是** Product Gate / Device-attested / TestFlight / App Release；
- **不是** Assignment Exit Criteria 满足 → **不** Assignment Close（Exit 仍要求 P2/P3；建议保持 **Active**，记录 P1 Done + IQ）；
- **不** enable Wanxiang nine-key；**不**宣称 Discovery UI 已交付；
- **不**把 Pause 的 Wanxiang P4 / A34-R1 写成 Closed/Done。

### Conditions（保持有效方可维持 Pass with conditions）

1. Hosted CI on prior merge tips used as machine evidence: `5bba4d2`（P1-2）、`d8e8299`（post–P1-3 merge）、`82bdd60`（post–P1-4 merge）— `classify-change` / `lightweight-checks` / `build-and-test` / `final-quality-gate` / GitGuardian **success**. Freeze tip `3cfa355` at review time: classify / lightweight / GitGuardian **success**；**`build-and-test` still in progress** — residual **SP-P1-IQ-01**（不得静默当绿）.
2. IQ **未**独立重跑全量 `xcodebuild` / Simulator NineKey suite；采信 prior-slice 测试源码 + 上述 hosted CI + KeyboardCore 单元锚点审查。
3. 环境性 iOS 26 / XCTest-host **malloc** flake、fixture `XCTSkip` 路径、Discovery / P2 / A34-R1 等保持开放（见 Residuals）.

---

## Ice regression checklist（plan §4）— IQ re-check

Source: [`scheme-platform-p1-extract-plan-2026-09-10.md` §4](../plans/scheme-platform-p1-extract-plan-2026-09-10.md).  
**Method:** read-only code/test review + prior slice / hosted CI evidence. Items marked **Evidence** cite what supports them; **Not re-run** lists what this IQ did **not** execute locally.

### 4.1 Always (every Swift slice P1-1…P1-5)

| Item | IQ disposition |
|---|---|
| swift-format format + `lint --strict` on touched | **Evidence (hosted):** `lightweight-checks` success on `5bba4d2` / `d8e8299` / `82bdd60`；`3cfa355` lightweight **success**. **Not re-run:** local `xcrun swift-format` this session. |
| Focused `xcodebuild` / package tests | **Evidence:** KeyboardCore unit suites landed with slices；hosted `build-and-test` green on merge tips above. **Not re-run:** local xcodebuild / full App+Keyboard this session. Freeze-tip full suite → **SP-P1-IQ-01**. |
| No Prelude `default.yaml` overwrite；no whole-`lua/`/`opencc/` wipe | **Pass (code):** SharedDefault Ice path → private preset；ownership strategies stage named/exact paths only（P1-4）. |
| No Wanxiang nine-key enable；no Discovery layout-picker UI | **Pass (code + scope):** `wanxiang.supportsNineKey=false`；`nineKeySchemaIDs=[]`；UninstallHooks Ice-only；no Discovery UI files in P1-5 diff. |
| Local commit / ask before push；no ADR Accept | **Pass (process):** Assignment / KOS record ask-before-push；ADR remains Proposed；#101 left alone. |

### 4.2 Capability / layout honesty (P1-1, P1-2)

| Item | IQ disposition |
|---|---|
| `isNineKeyCapable("t9")` true；Wanxiang false | **Pass (code + tests):** `SchemeAdapterRegistry.isNineKeyCapable`；`SchemeAdapterRegistryTests` asserts `t9` true / `wanxiang`/`wanxiang_t9`/`luna_pinyin` false；`RimeRuntimeSelection` routes through registry. |
| `isTwentySixKeyCapable` matches today’s Ice/Wanxiang/Luna | **Pass (code + tests):** adapter `supportsTwentySixKey`；registry tests equality with runtime selection. |
| Registry lookup == today’s hardcodes | **Pass:** P1-1 Done-when tests (`testIceAdapterMirrorsTodaysHardcodes` / Wanxiang / Luna). |
| `NineKeyEnableTransactionTests` green | **Evidence (hosted CI prior tips):** covered under App/Keyboard `build-and-test` on green merge tips. **Not re-run:** focused NineKey class this session. Env malloc flake → **SP-P1-IQ-02**. |
| Binding9 rejects non-capable；Ice uninstall layout unchanged | **Pass (code):** capability guards via registry；P1-5 `IceUninstallLayoutFallback` = 26-key + invalidate readiness；`SchemeUninstallHooksTests` + `SchemaManagerTests` anchors. |

### 4.3 SharedDefault / preset (P1-3)

| Item | IQ disposition |
|---|---|
| Ice skips Prelude `default.yaml`；installs toward `rime_ice_preset` | **Pass (code):** `RimeIceSharedDefaultAdapter` behind registry applicator；Download uses `applySharedDefaultPostExtract`. |
| Ice uninstall removes preset ownership without deleting official `default.yaml` | **Evidence:** coexistence anchors remain in suite（e.g. `testIceUninstallRemovesPresetAndLeavesOfficialDefaultYaml`）；behavior not rewritten in P1-3/P1-5 beyond seam routing. **Not re-run:** coexistence class locally. |
| Pollution recovery fail-closed | **Evidence:** prior SOURCE-STATE / coexistence contracts；P1 did not weaken. **Not re-run** locally. |
| Wanxiang still skips `default.yaml`（no P1 preset migrate） | **Pass:** Wanxiang mode `consumePrelude`；applicator `nil`（no-op）. P2 migrate deferred. |

### 4.4 Ownership / coexistence / uninstall (P1-4, P1-5)

| Item | IQ disposition |
|---|---|
| Ice uninstall stages **namedList** only；does not stage Wanxiang exact-hash paths | **Pass (code + tests):** `NamedListResourceOwnershipStrategy` / `ResourceOwnershipStrategyTests`；coexistence negatives retained. |
| Wanxiang uninstall / checkpoint **exactHash**；unknown/modified/symlink preserved | **Pass (code + tests):** `ExactHashResourceOwnershipStrategy` + pin map；symlink / fixture skips remain honest（**SP-P1-IQ-03**）. |
| CS-01…CS-10 / CS-F* focused set where touched | **Evidence:** hosted full `build-and-test` on merge tips；P1-4/P1-5 did not rewrite matrix policy. **Not re-run:** full CS matrix locally；some CS09 fixtures `XCTSkip` when trees absent. |
| Active uninstall awaits Luna before commit；failure restores | **Evidence:** prior P4 / runtime-route contracts unchanged by P1 extract；installer still strategy-driven staging. **Not re-run:** active-uninstall SchemaManager scenarios locally this session. |
| Ice `prepareRimeIceUninstallWithLayoutFallback` product outcome unchanged | **Pass (code + tests):** `SchemeAdapterRegistry.prepareUninstallLayoutFallback` → `IceUninstallLayoutFallback.apply`；SchemaManager routes Ice through registry. |

### Suggested anchors（plan §4.5）— coverage note

| Area | Anchors | IQ note |
|---|---|---|
| Ice preset / Prelude | coexistence Ice preset / uninstall / pollution | Present in tree；**not** re-executed here |
| Wanxiang ownership | exact-hash stage + Ice-does-not-stage-Wanxiang | Covered by `ResourceOwnershipStrategyTests` + coexistence |
| Coexistence / active uninstall | CS-* / Luna await | Prior CI；not re-run |
| Nine-key / T9 | `NineKeyEnableTransactionTests`；Wanxiang not capable | Registry unit proof + prior CI；NineKey class not re-run |

---

## Findings

### SP-P1-IQ-01 — Freeze tip `3cfa355` hosted `build-and-test` not completed green at IQ time

**Severity: P2**

At review time, GitHub checks on `3cfa355`: `classify-change` / `lightweight-checks` / GitGuardian **success**；**`build-and-test` status `in_progress` / pending**（run `34628171114`）. Prior merge tips `5bba4d2` / `d8e8299` / `82bdd60` were fully green including `final-quality-gate`.

**Disposition:** `open` — Owner: Environment Executor / Human watching draft #102. **Do not** treat freeze tip as hosted-full-green until `build-and-test`（and downstream `final-quality-gate` if required）complete success on **same** `3cfa355`. Does **not** invent a Pass by assuming green.

### SP-P1-IQ-02 — iOS 26 / XCTest-host malloc flake（environment）

**Severity: P2（environment / historical）**

Repo evidence records intermittent XCTest-host **malloc** invalid-free / IOHIDLib-class aborts on iOS 26 Simulator / Xcode beta when running broad App-hosted suites（incl. paths near SchemaManager / coexistence / NineKey）. This is **not** attributed to P1 adapter extract logic by code review.

**Disposition:** `accept` as known environment residual for local full-suite claims — Owner: Environment Executor / Quality. Hosted CI green tips remain the machine gate； local full-suite Pass must not be claimed from this IQ session.

### SP-P1-IQ-03 — Fixture / device `XCTSkip` paths remain

**Severity: P3**

Examples: Ice/Wanxiang extract trees for CS09-10-01；Ice `default.yaml` fingerprint fixture；symlink creation rejected； pin-archive root； TD-012 device-only. Skips are honest when fixtures absent — **not** silent Pass.

**Disposition:** `open` — Owner: Environment Executor when those scenarios are in-scope. Does not block P1 extract IQ.

### SP-P1-IQ-04 — Discovery A/B UI deferred（product）

**Severity: P3（scope / non-claim）**

P1-5 only shapes Ice uninstall layout-fallback hooks. Full Section A/B Discovery layout-picker + A-only uninstall rebind productization remains a **later Assignment**.

**Disposition:** `deferred:Discovery-Assignment` — Owner: Product Lead. Explicitly **not** closed by P1 IQ.

### SP-P1-IQ-05 — Wanxiang SharedDefault migrate / nine-key / A34-R1

**Severity: P3（scope）**

P2 `privatePreset` migrate；Wanxiang nine-key productization；A34-R1 writeback on Paused Wanxiang P4 — all **out of P1 Done-when**.

**Disposition:** `open` / deferred per Assignment — Owners: Human (auth P2) · later Assignments · Wanxiang P4 for A34-R1（still **`open`**）.

### SP-P1-IQ-06 — IQ did not re-run local xcodebuild

**Severity: P3（process）**

Per independence + docs-only P1-6 slice: no local format/xcodebuild re-execution this session.

**Disposition:** `accept` — machine evidence = hosted CI on cited tips + source/test review. Same class as prior scheme-delivery IQ practice.

### SP-P1-IQ-07 — ADR Accept / Product Gate / Assignment Close not authorized

**Severity: P3（governance non-claim）**

Recording only: Exit Criteria for full Assignment still need P2/P3； Human has not authorized ADR Accept / PG / TF / Close.

**Disposition:** `accept` as non-claims — keep Platform **Active**.

---

## Residuals table（explicit； no silent close）

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| `SP-P1-IQ-01` | Env Executor / Human (#102) | `open` | Freeze tip hosted `build-and-test` pending at IQ time |
| `SP-P1-IQ-02` | Env Executor / Quality | `accept` | iOS 26 XCTest-host malloc flake — env residual |
| `SP-P1-IQ-03` | Env Executor | `open` | Fixture / device `XCTSkip` honesty |
| `SP-P1-IQ-04` | Product Lead | `deferred:Discovery` | Discovery A/B UI not in P1 |
| `SP-P1-IQ-05` | Human / Wanxiang P4 | `open` | P2 migrate；nine-key later；A34-R1 still open |
| `SP-P1-IQ-06` | Quality (this review) | `accept` | No local xcodebuild re-run |
| `SP-P1-IQ-07` | Product Lead | `accept` | Not ADR Accept / PG / Assignment Close |
| A34-R1 | Wanxiang P4 (Paused) | `open` | Pause ≠ Done；writeback later |
| A34-R2 / TD-011 / RTRD-* | parallel debt | `open` | Out of P1 |

---

## Explicit non-claims

- Not ADR 0034 Accept； not undraft/merge #101； keep #101 ≠ #102
- Not Product Gate Passed； not Device-attested； not TestFlight / App Release
- Not Assignment Closed / Exit Criteria fully met（P2/P3 pending）
- Not Wanxiang nine-key enabled； not Discovery UI shipped
- Not A34-R1 Closed/Done
- Not “freeze tip fully hosted-green” until SP-P1-IQ-01 clears
- Not a claim that IQ re-ran NineKey / full coexistence / CS matrix locally
- Production Swift unchanged by this review

---

## Handoff

1. Record P1 Done + this IQ on Assignment / ACTIVE_WORK； **keep Active**； next = **P2 awaiting Human auth**.
2. **Ask Human before push** of P1-6 docs tip（and before any further #102 actions）.
3. Watch `3cfa355` `build-and-test` → update SP-P1-IQ-01 disposition when concluded（separate note OK； do not rewrite Pass into unconditional without evidence）.
4. Do **not** start ADR Accept / Product Gate / Assignment Close from this file alone.
