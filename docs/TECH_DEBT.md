# Technical Debt

## Purpose

This is the canonical register for known engineering risks that have an accepted direction but are not implemented or fully evidenced. A debt item is not a statement that the recommended fix already exists.

Creation, repayment and removal follow `docs/DOCUMENTATION_GOVERNANCE.md`. Plans and changelog entries may link here but must not maintain a competing debt status.

## TD-001: Atomic Schema Installation

- **Priority:** High
- **Risk:** File-by-file replacement can leave a mixed or partial scheme installation after interruption.
- **Current mitigation:** Main-App-only installation, deployment pending flags, redownload/reinstall recovery and release checks.
- **Recommended fix:** Stage and validate a complete scheme, then atomically switch directories or use an equivalent commit/rollback transaction.
- **Owner area:** Main App `SchemaArchiveInstaller` / schema deployment.
- **Trigger to resolve:** Before supporting unattended scheme updates, multiple downloadable schemes or production recovery guarantees.

## TD-002: Validate RIME/User Concurrent Access

- **Priority:** High
- **Risk:** Main-App backup/restore/configuration or automatic standard sync can overlap with another foreground/background main-App operation or with Extension/librime writes to `Rime/user`. Per-instance actor serialization does not prove process-wide or cross-process exclusion.
- **Current mitigation:** Heavy user-dictionary operations remain in the main App and are not run from the key hot path; automatic standard sync checks the keyboard-activity heartbeat; documentation advises avoiding active-session overlap. These controls reduce opportunity but are not a mutual-exclusion proof.
- **Recommended fix:** Establish one process-wide main-App synchronization gate, define librime-supported cross-process semantics, and add file/process coordination or an explicit quiesce workflow where required.
- **Owner area:** RimeBridge, main-App user dictionary, Extension lifecycle.
- **Trigger to resolve:** Before Product acceptance of unattended standard sync, enabling background/automatic restore, or claiming safe operation while another main-App operation or the Keyboard Extension may be writing.

## TD-003: Collect Extension Performance Baseline

- **Priority:** High
- **Risk:** Startup, input, candidate or memory regressions cannot be judged against evidence; jetsam may be mistaken for an ordinary lifecycle exit.
- **Current mitigation:** Coarse performance logging and manual release checks.
- **Current evidence status (`2026-08-24`):** Frozen Build 7 P4 reached an independently reviewed iPhone 13 Pro / iOS 27 cold baseline, but current Beta Time Profiler ended both allowed machine arms at about `1.3 s` with `Device disconnected` before any Human instruction. Both traces are excluded; this is an evidence-environment blocker, not a performance pass/fail. See [`P4 evidence`](evidence/release-2026-08-01-04-build7-device-run-p4-2026-08-24.md).
- **Recommended fix:** Collect the metrics and traces defined in `docs/PERFORMANCE_BASELINE.md`, then review evidence before setting budgets.
- **Owner area:** Keyboard Extension, KeyboardCore, RimeBridge, test/release.
- **Trigger to resolve:** Before TestFlight expansion, App Store submission or accepting a performance-sensitive architecture change.

## TD-004: Implement Full Access Degradation Matrix

- **Priority:** High
- **Risk:** Shared features can fail silently or UI may claim a capability is active when App Group access is unavailable; design matrix may overstate RIME-off without FA on some OS builds.
- **Current mitigation:** `RequestsOpenAccess=true`, activation Guide + `ONBOARDING_ACTIVATION.md` under `RELEASE-2026-0801-03` (Conditional Product Gate). Device matrix on iPhone 13 Pro / iOS 27 beta 3 shows basic+RIME `nihao` still works with FA off when 雾凇 is pre-deployed; **haptics** are the clear FA-linked gap; no Extension degradation banner.
- **Current evidence status (`2026-08-24`):** Build 7 P4 froze Full Access off with Apple keyboard current and Universe process zero, but Time Profiler failed before the first keyboard switch. No new off/on behavior evidence was produced; TD-004 remains open and the prior conditional matrix is not upgraded.
- **Recommended fix:** (1) Architecture-verify App Group / `runtimeDirectories` under FA off after cold Extension launch; (2) rewrite user-facing matrix around **observed** dependencies (feedback first); (3) add Extension-visible degraded cue when shared feedback/settings fail; (4) re-run on/off evidence before claiming self-diagnosing setup.
- **Owner area:** Main App onboarding/settings, Keyboard Extension bootstrap, diagnostics.
- **Trigger to resolve:** Before broad external testing or any claim that setup failures are self-diagnosing.

## TD-005: Complete Crash, Jetsam And Symbolication Handbook

- **Priority:** High
- **Status:** Procedure implemented; frozen Build 7 Archive/dSYM mapping retained;
  current iPhone 13 Pro / iOS 27 collection/classification exercise remains open. P4 retained unchanged pre-run crash/Jetsam
  lists (`11/62`), but the Time Profiler environment failed before Human input, so no post-run classification window exists.
- **Risk:** Extension termination cannot be reliably classified or traced to an exact release build.
- **Current mitigation:** [`CRASH_JETSAM_SYMBOLICATION.md`](CRASH_JETSAM_SYMBOLICATION.md)
  defines acquisition, classification, UUID/dSYM matching, Xcode/`atos`
  symbolication, privacy-safe storage and receipts. Frozen RC Build 7 retains
  matching App/Keyboard dSYMs and exports. The current physical-device path has
  not yet been exercised, so this debt is not repaid.
- **Recommended fix:** Exercise the documented collection/classification path on
  the frozen Build 7 ad hoc package with iPhone 13 Pro / iOS 27, retain a
  privacy-safe receipt and prove that any matching report can be bound to the
  exact App/Keyboard UUID and dSYM.
- **Owner area:** Test/release and Keyboard Extension operations.
- **Trigger to resolve:** Before TestFlight or immediately after the first unexplained production/TestFlight termination.

## TD-006: Reproducible xcframework Build And SBOM

- **Priority:** High
- **Risk:** Pinned hashes verify downloaded bytes but do not prove reproducible provenance or provide dependency/security inventory.
- **Current mitigation:** Fixed release asset, SHA-256 manifest, required-framework inventory and local receipt verification.
- **Recommended fix:** Pin toolchains/sources/build flags, automate reproducibility comparison, generate an SBOM and define vulnerability response.
- **Owner area:** RimeBridge artifacts and release engineering.
- **Trigger to resolve:** Before publishing a new vendor artifact version or App Store release relying on rebuilt dependencies.

## TD-008: Complete Portable RIME Data Compatibility

- **Priority:** High
- **Risk:** Standard RIME sync now exports per-device YAML/TXT backups and merges user-dictionary snapshots, but safe cross-device YAML import, full scheme portability and evidence across iOS, macOS, Windows, Linux and Android clients remain incomplete.
- **Current mitigation:** librime handles user-dictionary snapshots; Universe keeps encrypted private settings separate and does not auto-import YAML, copy live databases or copy full scheme directories.
- **Recommended fix:** Publish cross-platform fixtures and a compatibility matrix, add allowlisted staged custom-file import with diff/recovery, then verify representative RIME frontends and scheme installers.
- **Owner area:** Main App data operations, RIME Platform and cross-platform compatibility tooling.
- **Trigger to resolve:** Before claiming full RIME configuration or learned-dictionary parity across every target platform.

## TD-009: Multi-Scheme Download Toast Name And Progress

- **Priority:** Medium
- **Status:** **Repaid 2026-08-08**
- **Risk (historical):** Toast always said 雾凇; progress stuck at 0%.
- **Fix landed:**
  1. `DownloadState` carries `schemeName` on all active phases; toast messages use catalog display names.
  2. `downloading.progress` is `Double?` — `nil` = indeterminate (no fake `0%`); byte progress via `URLSessionDownloadDelegate` (throttled ~1%).
  3. `SchemaArchiveDownloading` takes optional `onProgress` callback.
- **Remaining:** rename `rimeIceDownloadState` → generic name (optional); further progress UX polish.
- **Owner area:** Main App toast + `SchemaManager+Download`.
- **Related:** R-02; `docs/RIME_SCHEME_MANAGEMENT.md`.

## TD-010: Per-Scheme Capability Gates In Settings UX

- **Priority:** Medium (product honesty; not install-path blocking)
- **Status:** **Repaid 2026-08-08** (V1 settings honesty for 模糊音 + 高级输入).
- **Risk (historical):** Settings looked global while only some schemes productize features.
- **Fix landed:**
  1. `RimeSchemeCapabilityMatrix` (KeyboardCore): per-schema flags; layout-bound `settingsCapabilitySchemaID` (26-key binding / nine-key → fog).
  2. V1 matrix: `rime_ice` fuzzy+advanced; `luna_pinyin` fuzzy only; `wanxiang` neither (TD-011 later for real 万象 Lua).
  3. Fuzzy + advanced settings: disabled toggles, status copy, alert on enable attempt; **no** preference wipe; **no** deploy write when unsupported.
  4. Settings tab subtitles show “当前方案暂不支持” when gated.
- **Remaining:** extend matrix to future features; productize 万象 advanced/fuzzy when TD-011/fuzzy evidence reopens claims.
- **Owner area:** Main App settings + KeyboardCore matrix.
- **Related:** R-05; TD-011.

## TD-011: Multi-Scheme Lua / Advanced-Input Compatibility (雾凇 ↔ 万象)

- **Priority:** Medium–High for product parity later; **not** blocking 万象 V1 catalog/install (PD Q4 still deferred).
- **Status:** **Partial** — freeze A + usage copy **repaid 2026-08-08** (PR #54); B–D still open.
- **Product freeze (2026-08-08, option A):** **Keep native triggers per scheme** (fog bare `rq` vs 万象 `/rq`·`orq`). **Do not** unify or silently remap triggers. Ordinary users learn via **per-scheme settings copy** (`RimeSchemeNativeUsageGuide`). Compatibility mapping / single-prefix unification is **out of scope** unless Product reopens.
- **Slice landed (A — copy only):** scheme-specific「怎么使用」tips + status notes on advanced-input settings; fog product toggles still only for `rime_ice` (TD-010).
- **Context (research 2026-08-07):** Upstream [amzxyz/rime-wanxiang](https://github.com/amzxyz/rime-wanxiang) **does** ship rich Lua (“魔法扩展”), but it is **not** the same module set or trigger contract as 雾凇 `rime-ice`.

### Upstream 万象 (schema `wanxiang`) — facts

| Area | 万象 (base.zip / wanxiang.schema.yaml) | 雾凇 (productized in Universe today) |
|---|---|---|
| Lua layout | Namespaced `lua/wanxiang/*` + `lua/data/*` | Flat components e.g. `lua/date_translator.lua`, `calc_translator`, … |
| Schema refs | `lua_translator@*wanxiang.shijian`, `*wanxiang.super_calculator`, `*wanxiang.unicode`, many `lua_processor@*wanxiang.*` | `lua_translator@*date_translator`, `*calc_translator`, `*uuid`, … |
| 日期/时间 | **`shijian`**: triggers **`/` or `o` + fixed suffix** — e.g. `/rq` / `orq` 日期，`/sj` 时间，`/nl` 农历，`/xq` 星期，`/jq` 节气… (**not** bare `rq`) | Bare **`rq` / `sj` / …** via `date_translator` (product copy) |
| 计算器 | **`V…`** → `wanxiang.super_calculator` | `calc_translator` (+ product mapping) |
| 数字/金额大写 | **`R…`** → `number_translator` | `number_translator` (name may match, wiring differs) |
| Unicode | **`U…`** → `wanxiang.unicode` | `unicode` component |
| 其它 | 预测、super_tips、符号库、简繁 replacer 链、Compose `C…`、输入统计 `/rtj`… | 高级输入开关子集；无万象整套 |

Grammar block references `wanxiang-lts-zh-hans` — **`.gram` still not in V1 install** (separate from Lua).

### Universe code — hard coupling to 雾凇

1. **`supportedAdvancedInputFeatures`**: only `rime_ice` gets full feature set; any other schema → empty set.
2. **`applyAdvancedInputPostProcessing`**: early-return unless `activeSchema == "rime_ice"`.
3. **Component map** (`RimeAdvancedInputFeature.componentNames`): 雾凇 module names only — **cannot** strip/restore `wanxiang.shijian` / `super_calculator` by flipping the same switches.
4. **Diagnostics** (`rimeIceLuaCapabilityDiagnostic`): schema file hard-coded `rime_ice.schema.yaml`; smoke keys `rime_ice_lua_smoke_*`; `date_translator.lua` existence check.
5. **Settings UX / copy**: **partially fixed** — `RimeSchemeNativeUsageGuide` + advanced status notes teach fog vs 万象 native triggers; product **toggles/deploy** still fog-only (`rime_ice`).
6. **Shared `Rime/shared/lua/`**: both catalogs use `luaDirectoryPrefix: "lua/"`. 万象 is mostly under `lua/wanxiang/` (good isolation), but **shared `lua/data/`** and any root scripts risk **install/uninstall clobber** if both schemes coexist — needs install-plan audit (atomic install TD-001 adjacent).
7. **Strip Lua when `rime_lua_available == false`**: path is generic strip of lua_* lines; OK in principle, but must be validated per-schema so 万象 is not left half-broken.

### Why Human saw “rq works on fog, not 万象”

Even with perfect install of 万象 Lua: product/user test of bare **`rq`** is **fog-specific**. 万象 expects **`/rq` or `orq`**. Separately, advanced-input deploy **never** touches `wanxiang.schema.yaml`, so Universe toggles do not gate 万象 modules today.

### Recommended follow-up architecture (later WI; ordered)

| Phase | Work | Notes |
|---|---|---|
| A | **Capability matrix + trigger cheatsheet** | **Partial done:** TD-010 matrix + freeze A `RimeSchemeNativeUsageGuide` (fog `rq` vs 万象 `/rq`). Full fog↔万象 **component name map** still open with B–C. |
| B | **Diagnose + smoke per active/layout-bound scheme** | **Open** — generalize Lua diagnostic off `rime_ice`; smoke key per schema; verify `lua/wanxiang/shijian.lua` etc. |
| C | **Deploy post-process multi-schema** | **Open** — enable/disable by **per-scheme component names** on `rime_ice` **and** `wanxiang` when installed. |
| D | **Install isolation** | **Open** — one scheme must not delete the other’s `lua/` subtree; `lua/data` merge policy. |
| E | **UX** | **Partial done:** (2) TD-010 disable + native tips under freeze A. Full (1) 万象 feature toggles still open with B–C. |
| F | **Device evidence** | **Open optional** — fog `rq`/`sj`; 万象 `/rq`/`orq`, `V1+1`, `R12`, `U62fc`; toggle/redeploy when B–C ship. |

### Explicit non-goals (freeze A + until Product reopens)

- Claiming “万象高级输入与雾凇开关 1:1 对齐”
- Porting fog `date_translator` into 万象 or rewriting 万象 triggers to bare `rq`
- **Unifying triggers** or silent `rq`↔`/rq` compatibility layer (rejected for V1; option A)
- Bundling LMDG `.gram` as part of Lua work

- **Remaining phases:** B–D (diagnose/deploy/install isolation) if Product later productizes 万象 toggles; F device evidence.
- **Owner area:** RIME Platform + Main App settings; catalog; deploy post-processors; RimeBridge smoke.
- **Trigger to resolve remaining:** Product reopens 万象 advanced-input **controls** (not just copy); keep freeze A unless explicit supersession.
- **Related:** RIME-SCHEME-WANXIANG-001 residual **R-06**; PD Q4; TD-010; `docs/RIME_SCHEME_MANAGEMENT.md` Advanced Input.

## TD-012: Optional RIME Grammar Model (万象 LMDG / `.gram`) Integration

- **Priority:** Medium for long-sentence quality; **High risk** for Extension memory/jetsam if bundled naively. **Not** blocking 万象 V1 base.zip path (PD already defers `.gram`).
- **Context (research 2026-08-07, no code change):** “万象模型”在社区语境里主要指 **RIME 语法模型（Grammar / Gram）**，仓库 **[amzxyz/RIME-LMDG](https://github.com/amzxyz/RIME-LMDG)**（Language / Model / Dictionary / Grammar）。它 **不是** 在线大模型 API，也 **不是** 我们 App 内的另一套候选引擎。
- **G0 result (2026-08-09):** **No-Go for the pre-G1 vendor.** 旧 pin `rime-vendor-ios-1.16.1-lua.1` 虽含核心 `Grammar` 接口与 `ContextualTranslation`，但 11-framework inventory、`librime.a` archive 成员和强制注册符号均没有 octagram；运行时仅配置 `core + dict + gears + lua`。详见 [G0 artifact audit](evidence/td-012-g0-octagram-artifact-audit-2026-08-09.md)。
- **Vendor G1 (2026-08-10, Closed):** New pin `rime-vendor-ios-1.16.1-lua.1-octagram.1` adds `librime-octagram.xcframework` (device arm64 + sim arm64/x86_64), force-load/shim/traits registration, and registry discovery of the concrete `grammar` component **without** any `.gram` file. Recipe: `config/rime-octagram-vendor-build.env` + `scripts/build_rime_octagram_plugin.sh`. Evidence: [G1 build](evidence/td-012-g1-octagram-vendor-build-2026-08-10.md). Independent [Architecture Conditional Accept](assignments/td-012-octagram-vendor-g1-architecture-review.md) + [Quality Conditional Accept](assignments/td-012-octagram-vendor-g1-quality-review.md). Assignment [`TD-012-OCTAGRAM-VENDOR-G1`](assignments/td-012-octagram-vendor-g1.md) **Closed**. **Does not** authorize model download or user feature; Jetsam measurement remains a pre-G2 residual on this debt.
- **Model G2 (2026-08-12, Closed — Product Hold):** Product authorized the minimal G2 asset-pin + device-viability gate in [`PD-TD-012-LMDG-MODEL-G2`](product-decisions/TD-012-LMDG-MODEL-G2-authorization.md). G2-A exact-byte receipt **Pass**: `420251692` bytes, SHA-256 `90d2385f65337f8b8c7b1ba5cbe874df3f2d91b462d68fa2f9fe90c57aa3bc66`; see [asset evidence](evidence/td-012-lmdg-model-g2-asset-pin-2026-08-11.md). The latest device run observed no Keyboard crash/Jetsam or basic-input regression, but stage testing re-linked and installed a different Debug dylib between arms, invalidating attribution; see [invalidated evidence](evidence/td-012-lmdg-model-g2-device-ab-2026-08-12.md). Human Product Lead chose Hold: no more G2 testing and no G3. Future reopening requires a new Product Decision. No installer, persistence, schema/UI, default-on or other-scheme enablement is authorized.
- **许可证来源审计 (2026-08-09):** 上游在 PR #8 公开收集三名记录贡献者同意后，将根 LICENSE 改为 BSD-3-Clause；但 `grammar_module.cc` 的 GPL 文件头仍未同步。详见 [provenance audit](evidence/td-012-octagram-license-provenance-audit-2026-08-09.md)。Product 已接受该来源作为 G1 vendor artifact 依据；notice 随 artifact 保留。

### What the model is

| Item | Fact |
|---|---|
| Artifact | Binary **`*.gram`** file (e.g. **`wanxiang-lts-zh-hans.gram`** 简体；**`wanxiang-lts-zh-hant.gram`** 繁体) |
| Source | GitHub Releases under RIME-LMDG (`LTS` tag commonly used; **note:** community reports LTS asset may be **re-overwritten** → pin by **content hash** for reproducible App builds, see Nixpkgs discussion) |
| Engine role | librime **collocation / sentence ranking** at translator stage: combines existing dict pieces into longer phrases; improves **整句正确率** (upstream compare tables ~+15% sentence accuracy when gram is present vs same schema without) |
| Size class | **Large** (order of tens–hundreds of MB class historically; treat as optional heavy download — exact bytes must be re-measured at pin time) |
| Schema wiring | `grammar: language: <stem>` must match file stem: `wanxiang-lts-zh-hans.gram` → `language: wanxiang-lts-zh-hans` |
| Parameters | `collocation_max_length` / `min_length`, penalties, and often `translator/contextual_suggestions` (万象 upstream schema already embeds a `grammar:` block + translator knobs; desktop docs also show `__include: octagram` patterns) |
| Runtime dependency | Desktop Linux often needs **`librime-plugin-octagram`（八股文）**. Weasel/Squirrel “direct config” assumes a build that already understands grammar. **Universe G1 pin** 已包含 iOS static octagram + registration path；**仍禁止**在未通过 G2+ 门禁前把 `.gram` 当作产品能力。 |

### Relation to 万象拼音 scheme (already in App)

- Catalog V1 installs **`rime-wanxiang-base.zip`** only; description already says grammar is optional.
- Installed `wanxiang.schema.yaml` **declares** grammar language `wanxiang-lts-zh-hans` (and collocation params). Without the `.gram` file, users still type with **dicts only** (your earlier “long sentence differs a bit, not dramatically” matches **schema+dict without gram**).
- **Installing `.gram` is the main missing piece** for “大厂感”整句；Lua (TD-011) is orthogonal.

### Can other schemes use this model?

| Scheme | Can attach 万象 `.gram`? | Notes |
|---|---|---|
| **万象 `wanxiang`** | **Primary / best-fit** | Trained & tuned with 万象词库+参数；schema already points at LTS stem |
| **雾凇 `rime_ice` / 白霜 / 薄荷等拼音方案** | **Yes, community practice** | Patch via `{schema}.custom.yaml` `grammar: language: wanxiang-lts-zh-hans` + length/penalty; frost **with** gram shows large accuracy jump in LMDG’s own tables. Author: best with 万象词库; other pinyin dicts OK with **retuned** params |
| **朙月 `luna_pinyin`** | Technically yes if engine supports gram | Same patch pattern; quality not guaranteed without tuning |
| **形码 / 非拼音序列** | **Not recommended** | LMDG docs: optimized for **pinyin weight sequences**, not shape codes |
| **九键 `t9`** | Unknown / high risk | Would need product+arch spike; digit raw + path semantics may interact poorly — do not assume fog T9 + LTS gram without evidence |

**Product implication:** Gram is a **shared RIME resource** (one file in shared/user dir) that **multiple schemas can reference by name**. It is **not** locked to schema_id `wanxiang` only. Optional UX: “安装万象语法模型” as a **catalog add-on** usable by 万象 and, later, optionally by 雾凇.

### How Universe should integrate later (phased; no code now)

| Phase | Work | Risks / gates |
|---|---|---|
| **G0** | **Engine capability gate** | **Done (No-Go on old pin).** See artifact audit. |
| **Vendor G1** | **octagram static plugin + registration** | **Closed 2026-08-10** (Arch+Quality Conditional Accept; pin + Bridge on `main`). No `.gram`. |
| **Model G2** | **Asset pin + device viability gate** | **Closed — Product Hold 2026-08-12:** G2-A **Pass**；G2-B invalidated because stage testing changed the Debug dylib between arms. Product stopped testing; no G3. No product install path. |
| **G3** | **Optional catalog / download path** | Separate from base.zip (user-initiated); App Group place under Rime **shared or user** per librime search rules; disk-space check; progress UX (TD-009 adjacent) |
| **G4** | **Schema config** | Ensure `wanxiang` grammar block matches pinned stem; optional `rime_ice.custom.yaml` (or post-process) only if Product enables “雾凇也可用万象模型” |
| **G5** | **Memory / jetsam** | Device budget: Extension cold start + long composition with gram mapped; PERFORMANCE_BASELINE evidence; may restrict to Main-App deploy + shared mmap semantics as upstream claims |
| **G6** | **Deploy & verify + Product UX** | After copy, full main-App deploy; smoke long sentence A/B; uninstall/copy honesty; TD-010 gates |

### Explicit non-goals until Product opens a WI

- Bundling multi-hundred-MB `.gram` inside the App binary
- Claiming neural LLM / cloud rewriting
- Auto-enabling gram on every scheme without opt-in
- Treating missing gram as install failure of base 万象

- **Owner area:** RIME Platform, RimeBridge artifacts, Main App catalog/download, Test/Release performance.
- **Trigger to resolve:** G1 may establish vendor capability. G2–G6 still require a new Product/Architecture decision, a pinned model asset, deployment contract and device memory evidence; until then no `.gram` may be downloaded, deployed or advertised.
- **Related:** [`PD-TD-012-OCTAGRAM-VENDOR-G1`](product-decisions/TD-012-OCTAGRAM-VENDOR-G1-authorization.md); TD-009 (download UX); TD-001 (atomic install); `docs/RIME_SCHEME_MANAGEMENT.md`.

## TD-013: Diagnostics v1 P1 查询、生命周期与迁移硬化

- **Priority:** Medium. 不阻塞已交付的本地诊断 P0，也不改变键盘输入或 RIME 运行语义。
- **Risk:** 现有 v1 已能以有界、内容无关的事件支持启动与候选异常排查，但长期大量日志、复杂 suspend/reclaim 竞争、旧自由文本收敛和细粒度故障归因仍有可维护性与证据缺口。
- **Current mitigation:** 当前 generation 使用有界 tail、查询快照和分页 UI；writer 使用 stable lock、lease/fence、tombstone 和保守 reclaim；Main App 启动时执行 retention；legacy 仅只读回退而不写入 v1；Debug 首屏高保真窗口会自动到期。
- **Recommended fix:**
  1. 让分页成为严格全局 newest-first 的 segment k-way merge，并在 cursor 所指段被清理时向 UI 报告受控失效，而非静默截断。
  2. 记录受控 `journal.identity_rotated` / lifecycle health，使 reclaim 后的新 writer identity 和关键恢复路径可被直接审计。
  3. 将 retention 从仅 App 启动扩展为受控 cadence；补齐 admission → suspend → writer 竞争、主动 seal/revoke 策略和失败重试矩阵。
  4. 将 `journalUnavailable`、锁忙、I/O、磁盘空间和 ingress overload 统一接入内容无关 health/drop 摘要，并补故障注入测试。
  5. 按 cohort 审计和迁移其余 legacy `Logger(String)` producer，最终移除 `rime_diag_log` 的兼容读取；任何新字段继续经过 typed allowlist/隐私审查。
  6. 为进入诊断页、手动刷新、日期 catalog、当日快照、分页扩展与筛选各阶段增加内容无关耗时/状态证据，定位真机长时间空白究竟来自 I/O、快照 fence、分页、MainActor 状态提交还是 UI 渲染；不得在 Extension 热路径同步计时或写额外自由文本。
  7. 明确搜索范围、水位与完整性状态：当页面已显示有界 500 条记录而查询无匹配时，UI 必须区分“当前窗口无匹配”“仍在扩展历史”“日志源未写入该事件”与“查询失败”，避免把部分窗口的空结果呈现为全部历史无记录。
- **Current status:** `2026-08-11 Asia/Shanghai` P1 已完成本地质量门、独立 Architecture `Pass`、Quality `Pass with conditions` 与 Human Product Gate；权威记录为 [`TD-013-DIAGNOSTICS-V1-P1`](assignments/td-013-diagnostics-v1-p1.md)。`2026-08-15 Asia/Shanghai` 新增 Human-attested 真机 residual：进入诊断页、手动刷新或等待均可能长时间才显示；当天页面最终显示 `500` 条记录后搜索 `TOUCHPROBE` 仍显示“当前筛选无匹配日志”。截图不证明 producer 未写入，也不证明搜索已覆盖完整当天历史；该缺口一度阻断 `KEY-TOUCH-FILL-001` 的日志探针取证，后者已通过 LLDB 分层证据与 Human 真机 Product Gate 独立完成。通用 fault-injection matrix、真机三模式性能、搜索完整性/阶段耗时与广泛 legacy cohort migration/删除保持后续技术债。
- **Owner area:** KeyboardCore diagnostics journal、Main App diagnostics repository/settings、Quality/Release evidence。
- **Trigger to resolve:** 获得明确实现授权后，按 P1 Assignment 的 phase/门禁推进；日志量/导出需求增长或再次出现无法归因的视觉异常可触发 Product revalidation。
- **Related:** ADR 0027、`DIAGNOSTICS-OBSERVABILITY-001`、[`PD-TD-013-DIAGNOSTICS-V1-P1`](product-decisions/TD-013-DIAGNOSTICS-V1-P1-authorization.md)、`docs/DEBUGGING.md`。

## TD-014: KOS 2.2 AUTH consumption_state 卫生

- **Priority:** Low. 不阻塞本次 advisory pin、PR #84 Product Gate，或诊断查看实现授权。
- **Risk:** `AUTH-KOS-UPGRADE-UK-001` 与 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001-IMPLEMENT` 的 `consumption_state` 仍为 `unconsumed`，而对应 bounded action（钉住 Kit advisory / 实现并合并诊断查看修复）均已完成。Kit 把 consumption 当审计观察、不提供 replay 保护；正文也否定 bearer token。若不改，后续 agent 可能把未消费收据误读成可反复执行的许可。
- **Current mitigation:** 建立 Assignment 的 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001` 已标 `consumed`；implement 收据 exclusions 含 `required_mode` / `merge` / `release` / `scheme_download_fix` / `pr_83_merge`，正文明确已完成 bounded action 且不得重放。当前 advisory validator 要求 Assignment 引用 `active` AUTH，即使 Assignment 已 `closed`；直接将 implement AUTH 标为 `consumed` 会产生 `KOS2437`，因此暂不伪造绿色状态。
- **Current status:** 部分偿还。剩余是 KOS 升级 Assignment 与已关闭 diagnostics Assignment 的 AUTH 消费/终态绑定语义。
- **Recommended fix:** 在后续 Envelope 卫生中明确 terminal Assignment 对 consumed AUTH 的合法绑定，升级 validator 后再把已完成 bounded action 的 AUTH 标为 `consumed`；或形成等价的不可重放规则。不要把这次改正做成 `required` 切仓或扩大 include glob。
- **Owner area:** KOS 2.2 records（`docs/authorizations/`）与 Architecture & Knowledge Steward。
- **Trigger to resolve:** 下一次触及这些 AUTH 的 Envelope 卫生；切 `required` 之前必须先处理。
- **Related:** [`KOS-UPGRADE-UK-001`](assignments/kos-upgrade-uk-001.md)、[`A-P2-01`](reviews/KOS-UPGRADE-UK-001-architecture-review.md)、[`Q-P2-01`](reviews/KOS-UPGRADE-UK-001-quality-review.md)。

## TD-015: 方案交付日志未进入诊断 v1 journal

- **Priority:** High for INTEGRITY-001 / 万象失败分类。不阻塞 `DIAGNOSTICS-VIEWER-LOAD-001` Product Gate 或 PR #85 merge。
- **Risk:** 诊断页只读 `Diagnostics/v1`。主 App `Logger.shared` 仍写入 legacy `rime_diag_log`；`DiagnosticsJournalRuntime` 明确不桥接 legacy Logger。`SchemaManager+Download` 下载/解压/安装路径没有 `Logger` 打点。结果：记录开、部署分类开、高保真关时，万象下载并部署成功也可以在 v1 里看不到「万象 / 下载 / 部署」。无法用 journal 区分网络、校验、解压、安装、部署。开高保真不能补上这条管道。
- **Current mitigation:** UI `DownloadState` / toast 仍能显示成功或失败。部署阶段 `deployRimeConfig` 会打 `Logger` `DEPLOY`，但只落在 UserDefaults，v1 有记录后查看器不再回退 legacy。
- **Current evidence status (`2026-08-28`):** [`SCHEME-DELIVERY-JOURNAL-001`](assignments/scheme-delivery-journal-001.md) Closed。PR #83 merged `e9aea57`。Human 在 v1 中看到失败链 `staged_content` 与成功链 `terminal completed`。显示层搜索 `scheme_delivery` / `wanxiang`。legacy Logger 仍不桥进 v1。
- **Recommended fix:** 已由 #83 交付下载/完整性/安装/部署 typed events。后续若要把其余 DEPLOY 自由文本迁出 `rime_diag_log`，另立 TD-013 item 5 工作，不要改高保真规则。
- **Owner area:** Main App scheme download/deploy、KeyboardCore diagnostics journal allowlist、诊断查看（只读）。
- **Trigger to resolve:** 本项实现 Assignment 已 Closed。剩余是其它 DEPLOY 路径的 legacy Logger 迁移（TD-013），不是再开一条下载修复。
- **Related:** ADR 0027、TD-013 item 5（legacy Logger 迁移）、[`DIAGNOSTICS-VIEWER-LOAD-001`](assignments/diagnostics-viewer-load-001.md)、PR #83。

## TD-016: CI 变更分级与文档提交快速门禁

- **Priority:** Medium。主要降低纯文档提交的反馈等待与 CI 资源消耗；不得以提速为由削弱代码、工程配置、资源或治理变更的合并门禁。
- **Risk:** 当前 `Swift 6 Quality` 对普通文档补录也会运行 KeyboardCore、RimeBridge、完整 App 测试及 Debug/Release 构建，单次可能持续十几分钟。连续文档修订还会产生过期运行；AI 若持续轮询，会额外消耗交互时间与 token。反向风险是粗暴使用 `paths-ignore` 后误跳过必要测试，或让被完全跳过的 required workflow 永久 pending。
- **Current mitigation:** 推送后由 Human 查看 GitHub 状态，AI 不持续轮询；现有完整 CI 保持 fail-closed，不根据文件扩展名自动降级。
- **Authorized implementation:** 设计并实现一个可审计的变更分类器和分级门禁：
  1. 所有 PR 始终运行轻量公共门禁（变更分类、`git diff --check`、文档/链接、KOS validator、安全扫描）。
  2. 经审查的普通文档或治理文档只运行对应文档/KOS 检查；Assignment、Authorization、ADR 仍需治理一致性验证，但不因此启动 `xcodebuild`。
  3. Swift、测试、Package/Xcode 工程、RIME/Lua/词典、Assets/AppIcon、构建脚本、workflow，以及任何未知路径均运行完整 Swift 6 门禁；未知分类必须 fail closed。
  4. 使用始终运行的聚合 `final-quality-gate` 处理“重任务合法 skipped”，避免 required check 因整个 workflow 被 paths-ignore 而悬空。
  5. 为同一 PR 设置 `concurrency` + `cancel-in-progress`，取消旧提交的过期运行；AI 默认推送后交回，不做高频轮询。
- **Current status (`2026-08-28`):** 实现 Assignment [`TD-016-CI-TIERING-001`](assignments/td-016-ci-tiering-001.md) 已 Closed。PR [#86](https://github.com/shchnk1103/Universe-Keyboard/pull/86) merged `78ed5b5`；PR [#87](https://github.com/shchnk1103/Universe-Keyboard/pull/87) merged `11fa096`。fail-closed 分类、轻量检查、条件 heavy job 与 `final-quality-gate` 已在 `main`。本项剩余工作是 required-check trust root（A-P2-02）：classifier/workflow/final Gate 仍来自 PR head。`main` 当前无 branch protection；未修改 required checks。私有 KOS Kit 无无密钥的远端分发路径，完整 validator 暂保持本地 merge 前门禁并作为显式残余。
- **Required-check migration residual:** 当前 classifier、workflow 与 final Gate 均来自 PR head，本身不是独立 trust root。未来若要把 `final-quality-gate` 设为 required，必须另行授权并增加 CODEOWNERS/强制审查、受保护 reusable workflow 或等价的 baseline-owned guard；在此之前不得把当前绿色结果当成不可绕过的强制边界。
- **Owner area:** Quality, Performance & Release Maintainer（CI/test selection）+ Architecture & Knowledge Steward（KOS/治理分类边界）。
- **Trigger to resolve:** 仅当 Human 另行授权 required-check 迁移，并增加 CODEOWNERS/强制审查、受保护 reusable workflow 或等价 baseline-owned guard。
- **Related:** `.github/workflows/swift6-quality.yml`、`docs/ASSIGNMENT_POLICY.md`、KOS 2.2 advisory、TD-014。

## TD-017: Investigate Background Sync Sandbox Extension Consume Failure

- **Priority:** Low–Medium。当前不阻塞 RIME 后台回调崩溃修复或强制真机同步通过；若与自然后台失败、目录授权失效或缺失输出同时出现则升级。
- **Risk:** `2026-08-29` 真机强制后台同步在 librime 已报告 `3 tasks ran: 3 success, 0 failure` 且完成通知已生成后，控制台出现 `sandbox_extension_consume failed: 22 (Invalid argument)`。当前没有证据说明它来自 App、文件提供器、系统安全作用域实现或 librime，也没有证据证明它完全无害。若它代表 security-scoped resource 使用不对称，未来可能在自然后台或不同文件提供器上表现为目录访问失败。
- **Current mitigation:** 标准同步仍由主 App 执行；文件夹 bookmark、写入预检和运行时目录访问失败会 fail closed 并暂停自动同步；本次真实 RIME 备份、完成通知及下一周期重排均成功。
- **Recommended fix:** 在不改变同步语义的前提下先做只读归因：保留该行前后的系统日志时间窗，绑定调用阶段与文件提供器，检查 `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` 配对及 bookmark 解析生命周期；必要时用符号断点或最小诊断点区分系统、File Provider 与 App producer。只有建立因果关系后才实现修复，不因单条系统日志猜改目录访问逻辑。
- **Owner area:** Main App RIME sync folder access、File Provider/security-scoped bookmark、RimeBridge diagnostics。
- **Trigger to resolve:** 自然后台运行再次出现该行；同步同时报告 access denied、目录暂停、缺少快照输出或崩溃；切换到非 iCloud 文件提供器可稳定复现；或发布前需要声明后台文件夹访问健壮性。
- **Related:** [`RIME-SYNC-001`](assignments/rime-sync-001.md)、[`forced-launch evidence`](evidence/rime-background-sync-crash-fix-2026-08-29.md)、TD-002。

## Maintenance Rules

- Update an item when priority, mitigation, owner area or trigger changes.
- Remove an item only after implementation and verification are recorded in `CHANGELOG.md` and relevant architecture docs.
- New plans must link to the debt item they resolve; plans do not replace this register.
