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
- **Risk:** `AUTH-KOS-UPGRADE-UK-001` 与 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001` 的 `consumption_state` 仍为 `unconsumed`，而对应 bounded action（钉住 Kit advisory / 建立 Assignment）已落在 `f580613`。Kit 把 consumption 当审计观察、不提供 replay 保护；正文也否定 bearer token。若不改，后续 agent 可能把未消费收据误读成可反复执行的许可。
- **Current mitigation:** AUTH exclusions 含 `required_mode` / `implement` / `merge` / `pr_83_merge`；独立 Architecture `A-P2-01` 与 Quality `Q-P2-01` 已记录该滞后。`AUTH-DIAGNOSTICS-VIEWER-LOAD-001` 已标 `consumed`（Assignment 已改绑 implement 收据）。`AUTH-KOS-UPGRADE-UK-001` 仍 `unconsumed`，因为 Assignment 仍引用它且 validator 要求 active 收据。
- **Current status:** 部分偿还。剩余是升级 Assignment 仍绑定的 AUTH 消费语义。
- **Recommended fix:** 在后续 Envelope 卫生中把这两条已完成 bounded action 的 AUTH 标为 `consumed`，或在收据上写明「Assignment Active ≠ AUTH unconsumed」的审计规则。不要把这次改正做成 `required` 切仓或扩大 include glob。
- **Owner area:** KOS 2.2 records（`docs/authorizations/`）与 Architecture & Knowledge Steward。
- **Trigger to resolve:** 下一次触及这些 AUTH 的 Envelope 卫生；切 `required` 之前必须先处理。
- **Related:** [`KOS-UPGRADE-UK-001`](assignments/kos-upgrade-uk-001.md)、[`A-P2-01`](reviews/KOS-UPGRADE-UK-001-architecture-review.md)、[`Q-P2-01`](reviews/KOS-UPGRADE-UK-001-quality-review.md)。

## Maintenance Rules

- Update an item when priority, mitigation, owner area or trigger changes.
- Remove an item only after implementation and verification are recorded in `CHANGELOG.md` and relevant architecture docs.
- New plans must link to the debt item they resolve; plans do not replace this register.
