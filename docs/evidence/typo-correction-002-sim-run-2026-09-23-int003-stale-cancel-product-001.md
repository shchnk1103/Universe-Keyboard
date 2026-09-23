# Evidence: TYPO-CORRECTION-002 INT-003 stale-cancel Product Capture — 2026-09-23-001

## Identity

| Field | Value |
|---|---|
| **Assignment** | TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 |
| **Authorization** | AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 (**Consumed** under Human continue-auth) |
| **Run ID** | TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001 |
| **Capture install tip** | `80091f35cc5411b292eca78662f39e2b91694045` (origin/main at consume; includes markers_impl) |
| **Markers impl tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152) |
| **Live main tip (historical)** | `68223f2482125557d328ff19650d16305bd14434` |
| **Docs consume commit** | `e8950a68050c769bcd037c62f1ae78842c2c264e` (AUTH/Assignment only; no production Swift) |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-stale-cancel-product-capture-001` |
| **Simulator** | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` **only** |
| **App Group** | `group.com.DoubleShy0N.Universe-Keyboard` |
| **Diagnostics root** | `…/AppGroup/E9CF1194-00E6-4E56-9B2B-2781B8103B42/Diagnostics` |
| **Host** | Messages / conversation `+1 (888) 555-1212` |
| **Executor** | Grok Bot iOS开发大师 under Human continue-auth (KOS) |
| **Human ask** | 「授权你按照KOS设定继续」 (2026-09-23 Asia/Shanghai) — consume + run Capture |
| **consumed_at** | `2026-09-23T20:19:10+08:00` (docs Consumed **before** first Simulator arm/capture) |

## Verdict for this Run

| Phase | Result |
|---|---|
| **AUTH consume (docs-first)** | **Pass** — AUTH + Assignment marked Consumed; PR opened before arm |
| **Install Debug tip with markers** | **Pass** — built/installed from tip `80091f35cc5411b292eca78662f39e2b91694045`; `typo_recall.*` strings present in `Keyboard.debug.dylib` |
| **Arm (App Group container prefs + HF)** | **Pass** — `logging_enabled=true`, category toggles true, `diagnostics_high_fidelity_expiration` refreshed (~30 min window, last refresh ~`2026-09-23T12:56:43Z` / `20:56 +08`) |
| **Keyboard Extension appearance** | **Pass (visual)** — Universe Keyboard QWERTY/拼音 visible in Messages before/during attempt (screenshots `screen1`/`screen2` @ ~20:23–20:26 +08); composition field empty |
| **HF-JSONL / dynamic journal growth** | **Fail / absent** — `Diagnostics/v1/g1/open/` remained empty (no `keyboard_extension-<processInstanceID>-…jsonl` minted for this Run) |
| **Visible-key stimulus (smoke long + rapid &lt;180)** | **Not achieved** — Mac-side Device Hub `CGEvent` clicks did **not** deliver product key events (placeholder text unchanged; no `touch.terminal`). Prior INT-003 AX/coordinate harness was already **inconclusive** for product delivery; not reused as authority |
| **Same-process smoke→rapid** | **N/A / inconclusive** — no `processInstanceID` journal binding without JSONL |
| **Cadence &lt;180 ms (even-index starts)** | **N/A / inconclusive** — no `touch.terminal` series |
| **`typo_recall.*` journal codes** | **Absent this Run** (no extension JSONL). Binary contains codes: `debounce_scheduled`, `debounce_cancelled`, `epoch_bumped`, `fence_discarded`, `query_begin`, `query_outcome` — install/markers binding only |
| **Human visual attestation** | **Pending / absent** — required for Product-grade contextual-while-typing + post-pause lookup claims. Executor could not complete Human-supervised visible-key taps mid-run |

**Overall disposition:** **Bounded / Inconclusive for INT-003 Product stimulus** — arm + markers install + keyboard appearance ready; stimulus/journal/cadence/`typo_recall` observation **not** collected. **Not** Product Gate. Parent stays Active.

## Package / binary identity (installed)

| Artifact | SHA-256 |
|---|---|
| Main executable `Universe Keyboard` | `7ba0b89870465447be2811ff9449564daa5f97e11fadf998df697d626bd5e104` |
| Keyboard executable `Keyboard.appex/Keyboard` | `e70273d13634c05fcc65dd17a1cf0284ab0541e25b80a103d8cdc4586a4d1bf4` |
| Keyboard debug dylib | `5b3e93ce1c52ee89bb8e931a64f384504f079e900e3b360e013f4545c2f36a69` |

## Arm binding

| Check | Result |
|---|---|
| Prefer App Group **container** prefs | Applied (path under `E9CF1194-00E6-4E56-9B2B-2781B8103B42`) |
| `logging_enabled` | `true` |
| `log_category_disp` (and gen/engine/config/deploy/perf) | `true` |
| High-fidelity window | Refreshed on container prefs before/during arm attempts |
| Dynamic JSONL search | Ready (`keyboard_extension-<uuid>-<hour>-<part>.jsonl`); **no file appeared** this Run |
| Markers AUTH | Remains **Consumed** (not reopened) |

## Cadence / same-process / typo_recall summary

| Item | Status |
|---|---|
| Even-index `touch.terminal` start gaps &lt;180 ms | **Not observed** (no journal) |
| Same-process smoke→rapid | **Not observed** |
| HF-JSONL health | **Absent** |
| `typo_recall.debounce_scheduled` | Absent (journal) / Present (binary) |
| `typo_recall.debounce_cancelled` | Absent (journal) / Present (binary) |
| `typo_recall.epoch_bumped` | Absent (journal) / Present (binary) |
| `typo_recall.fence_discarded` | Absent (journal) / Present (binary) |
| `typo_recall.query_begin` / `query_outcome` | Absent (journal) / Present (binary) |
| Post-bump epoch caveat | N/A this Run (no invalidate-path events). Remains binding for future correlators |

## Human visual status

| Attestation | Status |
|---|---|
| Keyboard visible (Universe / 拼音) on designated Simulator | **Observed by executor screenshots** (pre-stimulus) |
| No contextual candidate while rapid typing | **Pending** — no valid stimulus |
| Post-pause single lookup only | **Pending** — no valid stimulus |
| Human supervised visible-key smoke + rapid | **Need Human visual now** |

## Non-claims

- No INT-003 Product Gate / QA-001 Gate
- No parent Close; no Release / TestFlight
- No production Swift / ObjC / RIME changes under this AUTH
- No `RimeRuntimeProvenance` restore
- Capture alone does **not** self-declare Product Gate
- Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 / Markers AUTHs as Live authority
- Mac `CGEvent` Device Hub clicks are **not** claimed as successful visible-key product stimulus
- Markers binary presence ≠ journal cancel proof

## Blockers / Human action now

1. **Need Human visible-key taps** on designated Simulator (`06C5BC3E-7599-4761-A1A2-71DAEA991474`) while HF arm remains live:
   - Confirm Main App diagnostics / HF if needed; dismiss/reopen keyboard until Extension JSONL appears
   - Smoke: long synthetic composition then pause
   - Rapid: continuous inter-key **starts** &lt;180 ms, then pause ≥180 ms
   - Same process for smoke→rapid
   - Attest contextual-while-typing absence + post-pause lookup
2. After Human taps: executor (or follow-up) collects JSONL, fills cadence/`typo_recall` tables, may amend this evidence on the same consume PR branch
3. **Do not squash-merge** consume PR until parent/Human asks

## Checkout hygiene

Docs + evidence only on branch `docs/typo-correction-002-int003-stale-cancel-product-capture-consume-001`. Dirty home main not mutated. Vendor binaries copied locally into worktree for build (gitignored).

## Outcome

AUTH **Consumed**. Run ID minted. Install + arm + keyboard appearance achieved. Stimulus/journal **inconclusive** pending Human visual. Parent Active. No Gate.
