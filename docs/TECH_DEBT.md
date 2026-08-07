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
- **Risk:** Main-App backup/restore/configuration can overlap with Extension/librime writes to `Rime/user`.
- **Current mitigation:** Heavy user-dictionary operations remain in the main App and are not run from the key hot path; documentation advises avoiding active-session overlap.
- **Recommended fix:** Establish librime-supported cross-process semantics and add file/process coordination or an explicit quiesce workflow where required.
- **Owner area:** RimeBridge, main-App user dictionary, Extension lifecycle.
- **Trigger to resolve:** Before enabling background/automatic restore or claiming safe operation while the Keyboard Extension may be writing.

## TD-003: Collect Extension Performance Baseline

- **Priority:** High
- **Risk:** Startup, input, candidate or memory regressions cannot be judged against evidence; jetsam may be mistaken for an ordinary lifecycle exit.
- **Current mitigation:** Coarse performance logging and manual release checks.
- **Recommended fix:** Collect the metrics and traces defined in `docs/PERFORMANCE_BASELINE.md`, then review evidence before setting budgets.
- **Owner area:** Keyboard Extension, KeyboardCore, RimeBridge, test/release.
- **Trigger to resolve:** Before TestFlight expansion, App Store submission or accepting a performance-sensitive architecture change.

## TD-004: Implement Full Access Degradation Matrix

- **Priority:** High
- **Risk:** Shared features can fail silently or UI may claim a capability is active when App Group access is unavailable; design matrix may overstate RIME-off without FA on some OS builds.
- **Current mitigation:** `RequestsOpenAccess=true`, activation Guide + `ONBOARDING_ACTIVATION.md` under `RELEASE-2026-0801-03` (Conditional Product Gate). Device matrix on iPhone 13 Pro / iOS 27 beta 3 shows basic+RIME `nihao` still works with FA off when 雾凇 is pre-deployed; **haptics** are the clear FA-linked gap; no Extension degradation banner.
- **Recommended fix:** (1) Architecture-verify App Group / `runtimeDirectories` under FA off after cold Extension launch; (2) rewrite user-facing matrix around **observed** dependencies (feedback first); (3) add Extension-visible degraded cue when shared feedback/settings fail; (4) re-run on/off evidence before claiming self-diagnosing setup.
- **Owner area:** Main App onboarding/settings, Keyboard Extension bootstrap, diagnostics.
- **Trigger to resolve:** Before broad external testing or any claim that setup failures are self-diagnosing.

## TD-005: Complete Crash, Jetsam And Symbolication Handbook

- **Priority:** High
- **Risk:** Extension termination cannot be reliably classified or traced to an exact release build.
- **Current mitigation:** Minimal guidance in `docs/DEBUGGING.md` and release evidence requirements.
- **Recommended fix:** Document archive retention, dSYM mapping, device-log collection, Organizer workflow, jetsam classification and evidence storage.
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
- **Risk:** Global download toast always shows **雾凇拼音** regardless of which catalog scheme is downloading (e.g. 万象 `wanxiang`). Progress stays at **0%** for the whole transfer, then jumps to extract/deploy—users may think the wrong package is downloading or that the download is stuck.
- **Evidence (2026-08-07):** Human device screenshot while installing 万象全拼: toast “正在下载雾凇拼音… 0%”; download completed then entered deploy flow.
- **Root cause (code):**
  1. `AppOperationToastState(downloadState:)` hardcodes 雾凇 strings; `DownloadState` has no `schemaID` / display name; only `SchemaManager.rimeIceDownloadState` is observed.
  2. `fetchAndDownload` sets `downloading(progress: 0)` once; `URLSessionSchemaArchiveDownloader` uses one-shot `URLSession.shared.download(for:)` with no byte progress callback.
- **Current mitigation:** None for UX. Install path itself is scheme-ID-aware (`fetchAndDownload(schemaID:)`); incorrect toast does not change which archive is installed.
- **Recommended fix:**
  1. Track active download scheme (e.g. `currentDownloadSchemaID` or enrich `DownloadState`) and resolve display name from `RimeSchemeCatalog`.
  2. Either report real progress via `URLSessionDownloadDelegate` (throttled), or stop showing a fake `0%` and use indeterminate copy during transfer.
  3. Optionally rename `rimeIceDownloadState` → scheme-generic download state when touching this area.
- **Owner area:** Main App shell toast (`ContentView` / `RimeDeploymentToast`), `SchemaManager+Download`, `SchemaArchiveDownloading`.
- **Trigger to resolve:** Separate follow-up after 万象 install correctness is closed; do **not** block RIME-SCHEME-WANXIANG-001 catalog/install verification on this polish. Resolve before claiming multi-scheme download UX is production-ready or before shipping many concurrent downloadable schemes.
- **Related:** `docs/RIME_SCHEME_MANAGEMENT.md` (Toast Feedback); Assignment `RIME-SCHEME-WANXIANG-001` residual R-02.

## TD-010: Per-Scheme Capability Gates In Settings UX

- **Priority:** Medium (product honesty; not install-path blocking)
- **Risk:** Settings expose switches that **look global** (模糊音、高级输入/Lua、未来其它壳能力) while runtime only works for some schemes (Human 2026-08-07: **模糊音 currently effective only on 雾凇**; 万象下无效；`rq` 等高级输入亦未对万象声称). Users toggle on 万象 and conclude the feature is broken or that install failed.
- **Evidence:** Human device smoke under RIME-SCHEME-WANXIANG-001 — fuzzy zh/z only works with 雾凇; layout nine-key + 万象 26-key binding fixed separately (not this debt).
- **Product direction (frozen for follow-up WI):** When the **current layout’s effective scheme** does not support a feature:
  1. Keep the control **off / disabled** (not silently “on but no-op”).
  2. On attempt to enable, show a clear message: **当前方案暂不支持该功能** (name the scheme when helpful).
  3. Prefer a single **scheme capability matrix** (catalog / metadata) driving UI + deploy targets, instead of hardcoding `rime_ice` in each settings page.
- **Current mitigation:** Docs/non-claims only (PD Q4 advanced-input deferred; fuzzy deploy may patch multiple YAML files but **effectiveness on 万象 is unproven / not product-claimed**). Layout page already scopes scheme pickers per layout.
- **Recommended fix (later WI, not 万象 catalog focus):**
  1. Define capability flags per `schemaID` (e.g. `supportsFuzzyPinyin`, `supportsAdvancedInputLua`, …).
  2. Settings pages bind enablement to **layout-bound effective scheme** (26-key vs nine-key slot as applicable).
  3. Disable + toast/alert on unsupported enable; do not write pending-deploy that implies support.
  4. Optionally reverse: when user switches **to** an unsupported scheme, force-disable or grey out with explanation (without destroying preferences for when they return to a supported scheme — same pattern as advanced-input “preserve choices”).
- **Owner area:** Main App settings (`RimeFuzzyPinyinSettingsView`, advanced input, catalog metadata), deploy post-processors, docs `RIME_SCHEME_MANAGEMENT.md` / `RIME_FUZZY_PINYIN.md`.
- **Trigger to resolve:** After 万象 V1 install/layout path is closed; before claiming multi-scheme settings parity. **Do not block** current 万象 catalog/install work.
- **Related:** Assignment residuals R-03 / **R-05**; PD-RIME-SCHEME-WANXIANG-001 Q4; research companion **TD-011**.

## TD-011: Multi-Scheme Lua / Advanced-Input Compatibility (雾凇 ↔ 万象)

- **Priority:** Medium–High for product parity later; **not** blocking 万象 V1 catalog/install (PD Q4 still deferred).
- **Context (research 2026-08-07, no code change):** Upstream [amzxyz/rime-wanxiang](https://github.com/amzxyz/rime-wanxiang) **does** ship rich Lua (“魔法扩展”), but it is **not** the same module set or trigger contract as 雾凇 `rime-ice`.

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
5. **Settings UX / copy**: examples and recovery paths assume fog triggers (`rq`, etc.).
6. **Shared `Rime/shared/lua/`**: both catalogs use `luaDirectoryPrefix: "lua/"`. 万象 is mostly under `lua/wanxiang/` (good isolation), but **shared `lua/data/`** and any root scripts risk **install/uninstall clobber** if both schemes coexist — needs install-plan audit (atomic install TD-001 adjacent).
7. **Strip Lua when `rime_lua_available == false`**: path is generic strip of lua_* lines; OK in principle, but must be validated per-schema so 万象 is not left half-broken.

### Why Human saw “rq works on fog, not 万象”

Even with perfect install of 万象 Lua: product/user test of bare **`rq`** is **fog-specific**. 万象 expects **`/rq` or `orq`**. Separately, advanced-input deploy **never** touches `wanxiang.schema.yaml`, so Universe toggles do not gate 万象 modules today.

### Recommended follow-up architecture (later WI; ordered)

| Phase | Work | Notes |
|---|---|---|
| A | **Capability matrix per schemaID** | Extends TD-010: `supportsAdvancedInput`, feature list, **trigger cheatsheet** (fog `rq` vs 万象 `/rq`), component name map (fog names vs `wanxiang.*` paths). |
| B | **Diagnose + smoke per active/layout-bound scheme** | Generalize Lua diagnostic off `rime_ice`; smoke key per schema or shared with schema tag; verify `lua/wanxiang/shijian.lua` etc. |
| C | **Deploy post-process multi-schema** | Apply enable/disable by **per-scheme component names** on `rime_ice.schema.yaml` **and** `wanxiang.schema.yaml` (and only when that scheme is installed). |
| D | **Install isolation** | Ensure install/uninstall of one scheme does not delete the other’s `lua/` subtree; pin allowlists for `lua/data` merge policy. |
| E | **UX** | Settings: when effective scheme is 万象, either (1) scheme-specific feature list + correct examples, or (2) TD-010 disable + “暂不支持/触发不同” until matrix ships. Prefer (1) for date/calc if we claim 万象 advanced input. |
| F | **Device evidence** | Matrix: fog `rq`/`sj`; 万象 `/rq`/`orq`, `V1+1`, `R12`, `U62fc`; after toggle off → redeploy → triggers gone; switch scheme without cross-clobber. |

### Explicit non-goals until Product reopens Q4

- Claiming “万象高级输入与雾凇开关 1:1 对齐”
- Porting fog `date_translator` into 万象 or rewriting 万象 triggers to bare `rq`
- Bundling LMDG `.gram` as part of Lua work

- **Owner area:** RIME Platform + Main App settings; catalog; deploy post-processors; RimeBridge smoke.
- **Trigger to resolve:** Product reopens advanced-input for multi-scheme / after 万象 V1 path closed; coordinate with **TD-010** (honesty gates) so UI never shows fog-only examples while 万象 is active without labeling.
- **Related:** RIME-SCHEME-WANXIANG-001 residual **R-06**; PD Q4; TD-010; `docs/RIME_SCHEME_MANAGEMENT.md` Advanced Input; rime-ice Lua plan historical.

## TD-012: Optional RIME Grammar Model (万象 LMDG / `.gram`) Integration

- **Priority:** Medium for long-sentence quality; **High risk** for Extension memory/jetsam if bundled naively. **Not** blocking 万象 V1 base.zip path (PD already defers `.gram`).
- **Context (research 2026-08-07, no code change):** “万象模型”在社区语境里主要指 **RIME 语法模型（Grammar / Gram）**，仓库 **[amzxyz/RIME-LMDG](https://github.com/amzxyz/RIME-LMDG)**（Language / Model / Dictionary / Grammar）。它 **不是** 在线大模型 API，也 **不是** 我们 App 内的另一套候选引擎。

### What the model is

| Item | Fact |
|---|---|
| Artifact | Binary **`*.gram`** file (e.g. **`wanxiang-lts-zh-hans.gram`** 简体；**`wanxiang-lts-zh-hant.gram`** 繁体) |
| Source | GitHub Releases under RIME-LMDG (`LTS` tag commonly used; **note:** community reports LTS asset may be **re-overwritten** → pin by **content hash** for reproducible App builds, see Nixpkgs discussion) |
| Engine role | librime **collocation / sentence ranking** at translator stage: combines existing dict pieces into longer phrases; improves **整句正确率** (upstream compare tables ~+15% sentence accuracy when gram is present vs same schema without) |
| Size class | **Large** (order of tens–hundreds of MB class historically; treat as optional heavy download — exact bytes must be re-measured at pin time) |
| Schema wiring | `grammar: language: <stem>` must match file stem: `wanxiang-lts-zh-hans.gram` → `language: wanxiang-lts-zh-hans` |
| Parameters | `collocation_max_length` / `min_length`, penalties, and often `translator/contextual_suggestions` (万象 upstream schema already embeds a `grammar:` block + translator knobs; desktop docs also show `__include: octagram` patterns) |
| Runtime dependency | Desktop Linux often needs **`librime-plugin-octagram`（八股文）**. Weasel/Squirrel “direct config” assumes a build that already understands grammar. **Universe must verify** pinned `librime` xcframework **actually loads `.gram`** (module/plugins inventory) before productizing download — if octagram is missing, file on disk is a no-op or fail. |

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
| **G0** | **Engine capability gate** | Confirm pinned librime + plugins can open/read `.gram`; document in RimeBridge artifact matrix; fail closed with user copy if unsupported |
| **G1** | **Asset pin** | Freeze release URL + **SHA-256** of `wanxiang-lts-zh-hans.gram` (do not rely on mutable `LTS` alone); license/attribution for LMDG; size in UI |
| **G2** | **Optional catalog / download path** | Separate from base.zip (user-initiated); App Group place under Rime **shared or user** per librime search rules; disk-space check; progress UX (TD-009 adjacent) |
| **G3** | **Schema config** | Ensure `wanxiang` grammar block matches pinned stem; optional `rime_ice.custom.yaml` (or post-process) only if Product enables “雾凇也可用万象模型” |
| **G4** | **Memory / jetsam** | Device budget: Extension cold start + long composition with gram mapped; PERFORMANCE_BASELINE evidence; may restrict to Main-App deploy + shared mmap semantics as upstream claims |
| **G5** | **Deploy & verify** | After copy, full main-App deploy; smoke long sentence A/B with/without gram; uninstall removes only gram if unused by other schemes |
| **G6** | **Product UX** | Settings: optional add-on status; if gram missing, copy “整句增强未安装” not “方案损坏”; TD-010 honesty if feature listed |

### Explicit non-goals until Product opens a WI

- Bundling multi-hundred-MB `.gram` inside the App binary
- Claiming neural LLM / cloud rewriting
- Auto-enabling gram on every scheme without opt-in
- Treating missing gram as install failure of base 万象

- **Owner area:** RIME Platform, RimeBridge artifacts, Main App catalog/download, Test/Release performance.
- **Trigger to resolve:** Product reopens optional grammar slice after 万象 base path is stable; Architecture confirms librime/octagram support and memory budget.
- **Related:** PD-RIME-SCHEME-WANXIANG-001 non-claim on `.gram`; Assignment residual **R-07**; TD-009 (download UX); TD-001 (atomic install); `docs/RIME_SCHEME_MANAGEMENT.md`.

## Maintenance Rules

- Update an item when priority, mitigation, owner area or trigger changes.
- Remove an item only after implementation and verification are recorded in `CHANGELOG.md` and relevant architecture docs.
- New plans must link to the debt item they resolve; plans do not replace this register.
