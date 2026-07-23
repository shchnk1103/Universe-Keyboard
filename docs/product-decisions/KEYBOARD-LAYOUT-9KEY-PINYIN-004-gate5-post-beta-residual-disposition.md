# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-004 Gate 5 — Post-β Residual Disposition

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004-GATE5-POST-BETA-RESIDUAL`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-23 Asia/Shanghai`  
**Parent:** [`PD-…-004`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md)  
**Prior:** [`PD-…-GATE5-PATH`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-path-decision.md) · [`PD-…-GATE5-PHASE1-BETA`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-phase1-beta-authorization.md)  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../assignments/keyboard-layout-9key-pinyin-004.md)  
**Independent review:** [`…-post-beta-human-residual-independent-review.md`](../assignments/keyboard-layout-9key-pinyin-004-gate5-post-beta-human-residual-independent-review.md)  
**Evidence freeze:** remediation [`§27`](../assignments/keyboard-layout-9key-pinyin-004-gate5-remediation-evidence.md)

## Authority

- **Product Approver / Decision maker:** Product Lead acting under Human Product Owner’s standing KOS 2.0 authorization for this Assignment track (in-session instruction to auto-select next Product role after independent Accept).  
- **Does not replace:** Human Product Owner may override; full frozen Human Product Gate for entire 004 exit criteria remains a separate act.

## Inputs accepted

| Input | Disposition |
|---|---|
| Phase 1 β-limited independent review | Accept (prior) |
| Post-β independent Architecture **Accept with findings** + Quality **Pass-with-findings** | **Accept** |
| Human H5-A / H5-B / H5-C device Pass | **Accept as residual matrix** |
| Directed automation freeze 68/1 skip/0 fail + hash match | **Accept** |

## Bound Product Decisions

### 1. Residual Pass language (narrow)

1. Product **accepts** Gate 5 **post-β residual** as **Human residual Pass (H5)** for:  
   - ghost typo Delete / Core digit ledger SoT (long + short);  
   - Path select remaining host projection;  
   - standalone `da→dao` Path bar sync.  
2. This **does not** rewrite or erase earlier frozen Human Gate history for step-5 A/B/C from first attempts.  
3. This **does not** equal **004 Assignment Closed** or **full Human Product Gate Pass** against full exit criteria (including historical B device unchanged-raw invent-slot).

### 2. Residual debt (parked, visible)

| Debt | Product stance |
|---|---|
| Full B / residual-B Path cursor | **Closed** — [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md) Accepted; **Human residual-B device Pass** `2026-07-23` |
| Provisional-only mixed-raw C continue (`XCTSkip`) | **Parked residual** — not greenwashed as fixed |
| Handoff wording “unique full-cover” vs short resync first full-cover | **Closed** — dual policy documented (short unconfirmed = **first** full-cover; confirmed+remaining = **unique** full-cover). Evidence remediation §31. |
| Same-conversation independent review optics | **Accept with note** — third-party re-review optional if Product Owner requires |

### 3. Authorization to land repository checkpoint

| Action | Authorized? |
|---|---|
| **Local git commit(s)** of in-scope 004 / Gate5 worktree on current feature branch | **Yes** — Executor may create clean, reviewable commit(s) |
| **Push** feature branch to `origin` | **Yes** — allowed after local commit so recovery checkpoint exists on remote (PR optional next) |
| **Open / merge PR** | **Not auto-merged**; Executor may open PR if tooling available; **merge** remains Human Product Owner |
| Claim full 004 Human Product Gate Pass | **No** |
| Rewrite α Phase 0.5/0.6 history as positive coverage | **No** |

### 4. Assignment lifecycle

1. Assignment remains **`Active`** until Product Lead/Human later closes after PR merge or explicit close.  
2. Handoff target after landing commit: **Human Product Owner** for PR review/merge and optional full Gate re-statement.  
3. Executor must not self-close Assignment to `Closed` solely because residual H5 passed.

## Implementation gates (for authorized commit)

1. Prefer one coherent commit or a small stack with clear boundaries (docs vs code OK if single atomic feature commit is clearer).  
2. Do not include secrets, `.bak`, or unrelated dirty files.  
3. Cite verification: directed matrix already re-run independently; no need to re-run full suite unless code changes after this PD.  
4. CHANGELOG entry if not already accurate for user-visible T9 Path residual fixes.

## Explicit non-claims (as of this PD’s freeze)

- Not full 004 Product Gate Pass  
- Not production App Store ship decision  

**Superseding note (same day, later PD):** residual-B Path-ledger cursor is **Closed** with Human device Pass and PR #28 merge — see [`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL`](KEYBOARD-LAYOUT-9KEY-PINYIN-004-gate5-residual-b-path-ledger-peel.md). Do not treat “Not full B coverage” as current open residual-B debt.

## Human Product Owner — when we need you

| When | Need |
|---|---|
| **After residual-B land** | Optional: provisional-only C SKIP decision / formal 004 `Closed` |
| **Full Gate close** | Separate decision if/when remaining exit matrix is product-closed |
