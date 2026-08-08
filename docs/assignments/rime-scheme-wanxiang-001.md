# Assignment: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 + layout-bound scheme choice

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` — **catalog / layout / install path ready for formal close** (Product may stamp Completed when PR merged) |
| **Phase** | **Session close-out 2026-08-07** — V1 path Human-verified; polish debts deferred |
| **Parent PD** | [`PD-RIME-SCHEME-WANXIANG-001`](../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md) |
| **Non-claims** | Grammar `.gram` not bundled; no 双拼; no device Product Gate; toast (TD-009); capability UX (TD-010); Lua multi-scheme (TD-011); LMDG `.gram` (TD-012) research-only |
| **Next** | **(1)** Formal close / merge hygiene when Product ready. **(2)** Next engineering WI preferred: **TD-010** settings honesty (not TD-011/012). Do not expand scope in ad-hoc sessions. |
| **Residuals** | R-01 **accept**; R-02…R-07 **defer** — see table + roadmap |

### Session handoff (KOS 2.1 — for a cold new session)

New session bootstrap (also in `AGENTS.md` / `docs/kos/zero-context-startup.md`):

1. `AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → **`docs/ACTIVE_WORK.md`** → **this Assignment**.
2. Roadmap: phase 0 = this WI close; phase 1 = TD-010 → TD-009; phase 2 = TD-011 then TD-012 (research done, **no code yet**).
3. Human-verified this session: 万象 install/use, cold start, userdb isolation, uninstall, sync (`wanxiang.userdb.txt`), **layout nine-key while 26-key slot = 万象**, fog `rq` regression.
4. Code landed this arc (may be on `feat/wanxiang-catalog-001` or stacked commits): catalog+install, ADR 0026 layout-bound, layout UI single scheme picker, Extension bindings resolve, `sel-*` double-commit defense, fuzzy multi-schema deploy patch (effectiveness still fog-primary for Human).
5. **Do not** implement TD-010/011/012 unless the user opens that WI or marks urgent.

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

### Still out of scope

- Bundled LMDG `.gram`
- 双拼/辅助码 zip variants
- 万象九键 readiness productization
- Global download toast scheme name + real byte progress (**R-02** / **TD-009**)
- Per-scheme settings capability gates (**R-05** / **TD-010**)
- 万象 Lua 与雾凇高级输入对齐 / 多方案 Lua 兼容（**R-06** / **TD-011**）
- 万象语法模型 LMDG `.gram` 可选接入（**R-07** / **TD-012**）— research recorded; implement later

## Residuals (detail)

| ID | Description | Disposition |
|---|---|---|
| R-01 | Device install smoke for 万象 | **`accept` (2026-08-07)** — Human verified install/use/layout/sync isolation; formal Product close optional |
| R-02 | Toast always “雾凇拼音…”; download % stays 0 until extract/deploy | **Done 2026-08-08** — TD-009 scheme-named toast + real/indeterminate progress |
| R-03 | 万象下裸 `rq` 等雾凇触发不生效 | **Accept / deferred** — 万象上游用 `/rq`·`orq` 等（见 TD-011），非装失败；UX → R-05/R-06 |
| R-04 | 分段选词末段双插（长句） | **Mitigated** 2026-08-07 — `sel-*` strip; Human re-smoke optional |
| R-05 | 方案不支持的设置项仍可打开（模糊音在万象无效等） | **Done 2026-08-08** — TD-010 matrix + fuzzy/advanced gates |
| R-06 | 万象也有 Lua，但与雾凇模块/触发/产品开关不兼容 | **Partial 2026-08-08** — Product freeze **A** (native triggers + copy); usage guide landed; full deploy/diagnose (B–D) still deferred — [`TD-011`](../TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象) |
| R-07 | 万象「语法模型」`.gram`（LMDG）是什么、能否给雾凇等用、如何可选下载接入 | **Defer research complete** — [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration); phases G0–G6; **no code in this WI** |

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
- [ ] Product formal **Lifecycle → Completed** after merge/PR hygiene (optional stamp)

### Follow-on roadmap (not this WI)

| Phase | Work | Debt |
|---|---|---|
| 0 | Formal close this Assignment when branch merged | — |
| 1 | Settings honesty (unsupported → off + 提示) then download toast | TD-010 → TD-009 |
| 2a | Multi-scheme Lua matrix + deploy (if Product reopens Q4) | TD-011 |
| 2b | Optional LMDG `.gram` (engine gate first) | TD-012 |

## History

- 2026-08-07: Opened; freezes; ADR 0026 Accepted; layout-bound shipped.
- 2026-08-07: Catalog slice — base.zip / `wanxiang` pin + install path.
- 2026-08-07: Human reported download toast hardcodes 雾凇 + 0% progress while installing 万象; recorded as residual R-02 / TD-009 and **deferred** so WI stays on install correctness.
- 2026-08-07: Human smoke — scheme switch changes candidates; multi-segment last-segment double-insert mitigated (`sel-*` strip); 万象 `rq` not claimed (R-03); `wanxiang.userdb.txt` in sync is expected.
- 2026-08-07: Human — layout nine-key + 万象 26-key binding **verified**; fuzzy **only works on 雾凇** (not 万象). Product: later gate unsupported settings (closed + “暂不支持”) → residual **R-05** / **TD-010**; stay focused on 万象 path, not implement R-05 now.
- 2026-08-07: Research — 万象 upstream **has** Lua (shijian `/rq`·`orq`, V 计算器, …); Universe advanced-input path hard-codes `rime_ice` component names + deploy. Recorded **R-06** / **TD-011** (phases A–F); **no implementation**.
- 2026-08-07: Research — 万象「模型」= RIME-LMDG **grammar `.gram`** (not cloud LLM); optional heavy download; reusable by other pinyin schemes via `grammar.language`; needs librime/octagram + memory gates. Recorded **R-07** / **TD-012** (G0–G6); **no implementation**.
- 2026-08-07 **EOD close-out:** Product agreed roadmap (phase 0 close → phase 1 TD-010/009 → phase 2 TD-011/012). Assignment handoff block written for zero-context resume; R-01 accept; formal Completed stamp deferred to merge.
