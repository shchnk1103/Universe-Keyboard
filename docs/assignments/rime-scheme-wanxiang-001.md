# Assignment: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 + layout-bound scheme choice

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — catalog / layout / install path delivered; independent review/`Closed` handoff remains separate governance work |
| **Phase** | `2026-08-09` — V1 path + TD-009/010/011A delivered; TD-012 now continues only in dedicated G1 Assignment |
| **Parent PD** | [`PD-RIME-SCHEME-WANXIANG-001`](../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md) |
| **Non-claims** | Grammar `.gram` 不 bundled、不下载、不部署；无双拼；无 formal device Product Gate stamp；万象 product advanced **toggles** 不与 fog 1:1（freeze A copy only） |
| **Next** | TD-011 B–D remains optional debt; TD-012 G1 is now owned by [`TD-012-OCTAGRAM-VENDOR-G1`](td-012-octagram-vendor-g1.md); hand off this completed record for independent review/close when scheduled |
| **Residuals** | R-01/R-03/R-04 **accept**; R-02/R-05 **fix**; R-06 `tech_debt:TD-011`; R-07 `tech_debt:TD-012` |

### Session handoff (KOS 2.1 — for a cold new session)

New session bootstrap (also in `AGENTS.md` / `docs/kos/zero-context-startup.md`):

1. `AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → **`docs/ACTIVE_WORK.md`** → **this Assignment**.
2. Roadmap progress: phase 0 path ready; phase 1 **TD-010 → TD-009 done**; phase 2a **TD-011 freeze A (copy) landed** (PR #54); phase 2b **TD-012 G0 No-Go**.
3. Human-verified earlier: 万象 install/use, cold start, userdb isolation, uninstall, sync (`wanxiang.userdb.txt`), **layout nine-key while 26-key slot = 万象**, fog `rq` regression.
4. Code on `main` this arc: catalog+install, ADR 0026, layout UI, Extension bindings, `sel-*`, fuzzy multi-schema deploy, TD-009 toast, TD-010 gates + prefs preserve, TD-011 `RimeSchemeNativeUsageGuide`.
5. **Do not** unify fog `rq` ↔ 万象 `/rq`. TD-012 G0 已由 Product 开启并得出当前 artifact No-Go；不得进行 G1–G6，除非新的 Artifact + Architecture/Product Gate 明确授权。

---

**Task ID:** `RIME-SCHEME-WANXIANG-001`
**Date / timezone:** `2026-08-07 Asia/Shanghai`
**Repository Change Type:** `Implementation`
**Product Decision source:** PD above

## Authority

- Assignment Authority: Product Lead (session “按 KOS 2.1 自行完成”)
- Domain Owner: 🔧 RIME Platform + Main App settings
- Executor: Current agent
- Environment Executor: Not Applicable for catalog unit slice
- Human Dependency: Optional device download smoke
- Architecture Reviewer: ADR 0026 already Accepted
- Quality Reviewer: Residual `accept` for dual formal review of catalog text; implementation tests Executor-recorded

## Boundary

### Done / in this slice

1. Catalog: `wanxiang` downloadable via GitHub `rime-wanxiang-base.zip`.
2. Install/uninstall plan; `default.custom.yaml` includes `wanxiang` when installed.
3. 26-key layout picker lists installed 万象; nine-key remains fog `t9` only in V1.
4. Layout-bound selection (ADR 0026) + layout settings UI shows **one** scheme section per 主键盘.
5. Extension resolve passes scheme bindings so nine-key works when 26-key slot is 万象.
6. Human smoke path above (handoff §3).
7. Research-only debts: TD-009…012 linked from residuals (no implementation required for this slice exit).

### Still out of scope (or follow-on)

- Bundled LMDG `.gram` / optional download (**R-07** / **TD-012**) — **G0 No-Go**；新的 Artifact + Architecture/Product Gate 前不得继续
- 双拼/辅助码 zip variants
- 万象九键 readiness productization
- 万象 advanced-input **product toggles** / multi-schema deploy diagnose (**R-06** remaining **TD-011 B–D**) — freeze A copy only
- ~~Global download toast~~ → **Done** TD-009
- ~~Per-scheme settings gates~~ → **Done** TD-010

## Residuals (detail)

| ID | Description | Disposition |
|---|---|---|
| R-01 | Device install smoke for 万象 | **`accept` (2026-08-07)** — Human verified install/use/layout/sync isolation; formal Product close optional |
| R-02 | Toast always “雾凇拼音…”; download % stays 0 until extract/deploy | **Done 2026-08-08** — TD-009 scheme-named toast + real/indeterminate progress |
| R-03 | 万象下裸 `rq` 等雾凇触发不生效 | **Accept / deferred** — 万象上游用 `/rq`·`orq` 等（见 TD-011），非装失败；UX → R-05/R-06 |
| R-04 | 分段选词末段双插（长句） | **`accept`** — `sel-*` mitigation delivered; Product accepts this residual for this completed Assignment. A future re-smoke must be a separate task. |
| R-05 | 方案不支持的设置项仍可打开（模糊音在万象无效等） | **Done 2026-08-08** — TD-010 matrix + fuzzy/advanced gates |
| R-06 | 万象也有 Lua，但与雾凇模块/触发/产品开关不兼容 | **`tech_debt:TD-011`** — Product freeze A (native triggers + copy) delivered; B–D remain deferred in [TD-011](../TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象). |
| R-07 | 万象「语法模型」`.gram`（LMDG）是什么、能否给雾凇等用、如何可选下载接入 | **`tech_debt:TD-012`** — G1 is separately assigned; G2–G6 remain prohibited until their own gates. |

## Gates

### Entry Criteria

- [x] Product freezes + Q1/Q2 asset pin
- [x] ADR 0026 Accepted
- [x] Executor named

### Exit Criteria (catalog + layout path slice)

- [x] Catalog entry present with frozen asset/schema
- [x] Unit test for catalog identity (`testWanxiangCatalogEntryIsDownloadableFullPinyin`)
- [x] `default.custom.yaml` includes `wanxiang` when installed
- [x] Device / Human install smoke — residual R-01 **accept** (2026-08-07)
- [x] Product formal **Lifecycle → Completed** — `2026-08-09`; residuals disposed or handed off to TD-011/TD-012

### Follow-on roadmap (not this WI)

| Phase | Work | Debt | Status |
|---|---|---|---|
| 0 | Formal close this Assignment | — | Optional Product stamp |
| 1 | Settings honesty then download toast | TD-010 → TD-009 | **Done** 2026-08-08 |
| 2a | Multi-scheme Lua — freeze A native copy | TD-011 A | **Done** PR #54; B–D open |
| 2b | Optional LMDG `.gram` (engine gate first) | TD-012 | **G0 No-Go**；等待新的 Artifact + Architecture/Product Gate |

## History

- 2026-08-08: TD-009/010 repaid; TD-011 freeze A usage guide PR #54 on `main`; EOD backlog → TD-012 default, 011 B–D optional.
- 2026-08-07: Opened; freezes; ADR 0026 Accepted; layout-bound shipped.
- 2026-08-07: Catalog slice — base.zip / `wanxiang` pin + install path.
- 2026-08-07: Human reported download toast hardcodes 雾凇 + 0% progress while installing 万象; recorded as residual R-02 / TD-009 and **deferred** so WI stays on install correctness.
- 2026-08-07: Human smoke — scheme switch changes candidates; multi-segment last-segment double-insert mitigated (`sel-*` strip); 万象 `rq` not claimed (R-03); `wanxiang.userdb.txt` in sync is expected.
- 2026-08-07: Human — layout nine-key + 万象 26-key binding **verified**; fuzzy **only works on 雾凇** (not 万象). Product: later gate unsupported settings (closed + “暂不支持”) → residual **R-05** / **TD-010**; stay focused on 万象 path, not implement R-05 now.
- 2026-08-07: Research — 万象 upstream **has** Lua (shijian `/rq`·`orq`, V 计算器, …); Universe advanced-input path hard-codes `rime_ice` component names + deploy. Recorded **R-06** / **TD-011** (phases A–F); **no implementation**.
- 2026-08-07: Research — 万象「模型」= RIME-LMDG **grammar `.gram`** (not cloud LLM); optional heavy download; reusable by other pinyin schemes via `grammar.language`; needs librime/octagram + memory gates. Recorded **R-07** / **TD-012** (G0–G6); **no implementation**.
- 2026-08-09: Human Product Owner 正式开启 TD-012 G0 的只读 artifact capability audit。当前固定 iOS artifact 通过 11-framework inventory 校验，但无 octagram archive/member/强制模块注册，runtime 仅配置 `core + dict + gears + lua`；G0 判定 No-Go，未下载模型、未改代码、未改变部署边界。详见 [artifact audit](../evidence/td-012-g0-octagram-artifact-audit-2026-08-09.md)。
- 2026-08-07 **EOD close-out:** Product agreed roadmap (phase 0 close → phase 1 TD-010/009 → phase 2 TD-011/012). Assignment handoff block written for zero-context resume; R-01 accept; formal Completed stamp deferred to merge.
- 2026-08-09: Product marked this Assignment `Completed`, accepted R-04 for this scope, and moved R-06/R-07 to TD-011/TD-012. `TD-012-OCTAGRAM-VENDOR-G1` replaces this record in Active Work. This Assignment may not claim `Reviewed` or `Closed` until its independent governance handoff occurs.
