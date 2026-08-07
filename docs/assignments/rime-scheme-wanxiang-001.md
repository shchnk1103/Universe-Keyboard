# Assignment: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 + layout-bound scheme choice

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Catalog entry + install path for 万象全拼; layout-bound already shipped |
| **Parent PD** | [`PD-RIME-SCHEME-WANXIANG-001`](../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md) |
| **Non-claims** | Grammar `.gram` not bundled; no 双拼 packs; no device Product Gate yet |
| **Next** | Merge PR; optional Human install smoke |
| **Residuals** | R-01 device smoke install 万象 — disposition `accept` for automated close if unit/catalog tests pass |

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
4. Layout-bound selection (prior commit).  

### Still out of scope

- Bundled LMDG `.gram`  
- 双拼/辅助码 zip variants  
- 万象九键 readiness productization  

## Gates

### Entry Criteria

- [x] Product freezes + Q1/Q2 asset pin  
- [x] ADR 0026 Accepted  
- [x] Executor named  

### Exit Criteria (catalog slice)

- [x] Catalog entry present with frozen asset/schema  
- [x] Unit test for catalog identity (`testWanxiangCatalogEntryIsDownloadableFullPinyin`)  
- [x] `default.custom.yaml` includes `wanxiang` when installed  
- [ ] Device install smoke (optional residual accept)  

## History

- 2026-08-07: Opened; freezes; ADR 0026 Accepted; layout-bound shipped.  
- 2026-08-07: Catalog slice — base.zip / `wanxiang` pin + install path.
