# Evidence: TYPO-CORRECTION-002 INT-003 cadence re-Run — 2026-09-22-003

## Identity

| Field | Value |
|---|---|
| **Assignment** | TYPO-CORRECTION-002-INT003-CADENCE-003 |
| **Authorization** | AUTH-TYPO-CORRECTION-002-INT003-CADENCE-003 |
| **Run ID** | TC2-SIM-20260922-225841-INT003-CADENCE-003 |
| **Source tip** | 69f5bd1ad662be4d980787d9a496b0d85aa7428a |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-controlled-capture-001/Universe Keyboard` |
| **Simulator** | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| **App Group** | `group.com.DoubleShy0N.Universe-Keyboard` |
| **Diagnostics root** | `…/AppGroup/0469C0D3-0C89-4988-BD85-314F03EC34B3/Diagnostics` |
| **Executor** | Grok Bot iOS开发大师 |
| **Human input** | Main App diagnostics arm + HF confirm; dismiss/reopen keyboard; one-key smoke then rapid visible-key taps (no phrase / typeText / clipboard / candidate select) |

## Verdict for this Run

| Phase | Result |
|---|---|
| **Arm** | Pass — App Group **container** prefs `logging_enabled=true`, `log_category_disp=true`; `diagnostics_high_fidelity_expiration` = `2026-09-22 15:33:25 +0000` (~23:33 +08; still active during capture) |
| **HF refresh** | Pass — after Human Main App confirm + keyboard dismiss/reappear, Extension wrote `touch.terminal` (prior open segment `DAD8465B-…` had `presentation.appeared` only) |
| **One-key smoke** | **Pass** — `touch.terminal` on process `F9245C6C-B9D7-45D3-ADA7-4BD0E675B770` |
| **Conditional rapid trace** | **Ran same process** — smoke and rapid share one `processInstanceID` and one `appearanceID` (clears Capture-002 process-churn residual for this Run) |
| **&lt;180 ms cadence bar (rapid inter-key starts)** | **Met for this Run** — rapid-only inter-key start gaps `[158.984, 153.957, 136.267]` ms; **3/3 &lt; 180**. Smoke→rapid phase-boundary gap `3043.675` ms recorded separately and not treated as rapid-bar failure |

Overall: **bounded cadence evidence** — Capture-002 same-process + rapid &lt;180 ms residuals addressed for this Run. **Not** an INT-003 Product Gate, not parent Close, not Release.

This Run does **not** reuse Capture-002 / Architecture / Quality Authorizations.

## Arm binding

| Check | Result |
|---|---|
| Prefer App Group container prefs | Applied |
| `logging_enabled` | `true` |
| `log_category_disp` | `true` |
| High-fidelity expiration | `2026-09-22 15:33:25 +0000` (active at capture ~15:03Z / 23:03 +08) |
| Dynamic JSONL | `keyboard_extension-F9245C6C-…-20260922T15-0.jsonl` |

## Same-process binding

| Field | Value |
|---|---|
| **processInstanceID** | `F9245C6C-B9D7-45D3-ADA7-4BD0E675B770` |
| **appearanceID** | `A7A38761-D2B7-4252-9BF7-0D010177AA45` |
| **Journal** | `v1/g1/open/keyboard_extension-F9245C6C-B9D7-45D3-ADA7-4BD0E675B770-20260922T15-0.jsonl` |
| **Lines / bytes** | 33 / 17472 |
| **SHA-256** | `b90e9fdcfd3c4bd99e006a9fefa3f9062c48b8e01149ff5033da9151eafdc8ed` |
| **`touch.terminal` count** | 10 (5 keystroke pairs) |

Adjacent short-lived Extension segment `1CE11321-…` (appear / visibility only, no `touch.terminal`) recorded for hygiene; **not** used for cadence.

## Ordered `touch.terminal` (monotonic)

| # | seq | utc | mono_ns | gap from previous touch (ms) |
|---|---|---|---|---|
| 0 | 6 | 2026-09-22T15:03:36Z | 477497151168041 | — |
| 1 | 7 | 2026-09-22T15:03:36Z | 477497151402000 | 0.234 |
| 2 | 12 | 2026-09-22T15:03:39Z | 477500194843333 | 3043.441 |
| 3 | 13 | 2026-09-22T15:03:39Z | 477500252367291 | 57.524 |
| 4 | 16 | 2026-09-22T15:03:39Z | 477500353827208 | 101.460 |
| 5 | 18 | 2026-09-22T15:03:39Z | 477500417332625 | 63.505 |
| 6 | 21 | 2026-09-22T15:03:39Z | 477500507784083 | 90.451 |
| 7 | 23 | 2026-09-22T15:03:39Z | 477500576146083 | 68.362 |
| 8 | 27 | 2026-09-22T15:03:39Z | 477500644051500 | 67.905 |
| 9 | 29 | 2026-09-22T15:03:39Z | 477500717370375 | 73.319 |

## Inter-key start gaps (even indices 0,2,4,6,8 as pair starts)

Full even-index series: `[3043.675, 158.984, 153.957, 136.267]` ms

| Slice | Gaps (ms) | &lt;180 |
|---|---|---|
| Smoke→rapid phase boundary | `3043.675` | N/A (phase pause) |
| Rapid inter-key starts only | `158.984`, `153.957`, `136.267` | **3 / 3** |

Also present (content-free): `presentation.appeared`, `candidate.visibility_changed`, `rime.owner.published`, `ui.applied` — lifecycle ordering only.

## Other artifacts (hashes)

| Artifact | SHA-256 |
|---|---|
| `…F9245C6C-…jsonl` (smoke+rapid) | `b90e9fdcfd3c4bd99e006a9fefa3f9062c48b8e01149ff5033da9151eafdc8ed` |
| `…1CE11321-…jsonl` (appear-only neighbor) | `b7187508c77c171c23c4479c1a72f00649196cea388fcd70ddcba2ddee6ced31` |
| `main_app-B57F6BB5-…jsonl` | `ea7d6923c297ac3a8cde7088ba63f03d1ab983a51257e17d526b148a0ea6b63d` |
| `v1/control.json` (`currentGeneration`: 1) | `baaa646c583ad8bb4c3d983f0069460e8afc8cbe0b3eb9212397eadc4a71fea4` |

## Non-claims

- No formal INT-003 Product pass/fail / Parent Closure / Release Gate
- No global less-than-180-ms engineering claim beyond this bounded Run receipt
- No candidate selection / QA-001 / paired performance
- No production code change; no `RimeRuntimeProvenance` restoration
- Docs commit/push not authorized by this AUTH alone (ask before push)

## Checkout hygiene

Docs-only on tip `69f5bd1`. Home main and other dirty worktrees not modified for this capture.

## Recommended next

1. Independent **Architecture** review AUTH on this Cadence-003 evidence package (new AUTH; do not reuse Capture-002 Arch).
2. Independent **Quality** review AUTH (new AUTH; cadence residual explicitly re-measured).
3. Optional: docs-only PR for Cadence-003 package (ask before push).
