# Evidence: TYPO-CORRECTION-002 INT-003 stale-cancel Product Capture — 2026-09-23-001

## Identity

| Field | Value |
|---|---|
| **Assignment** | TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 |
| **Authorization** | AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001 (**Consumed** under Human continue-auth; evidence amend still covered) |
| **Run ID** | TC2-SIM-20260923-201910-INT003-STALE-CANCEL-PRODUCT-001 |
| **Capture install tip** | `80091f35cc5411b292eca78662f39e2b91694045` (origin/main at consume; includes markers_impl) |
| **Markers impl tip** | `c1869cf9dda9f1643495e8ebdcfb67acc788b843` (#152) |
| **Live main tip (historical)** | `68223f2482125557d328ff19650d16305bd14434` |
| **Docs consume commit** | `e8950a68050c769bcd037c62f1ae78842c2c264e` (AUTH/Assignment only; no production Swift) |
| **Prior evidence commit** | `33fc37e6010eeee8c67fd7616bdcc356d20a8722` (Bounded/Inconclusive — no journal yet) |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-stale-cancel-product-capture-001` |
| **Simulator** | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` **only** |
| **App Group** | `group.com.DoubleShy0N.Universe-Keyboard` |
| **Diagnostics root** | `…/AppGroup/E9CF1194-00E6-4E56-9B2B-2781B8103B42/Diagnostics` |
| **Host** | Messages / conversation `+1 (888) 555-1212` |
| **Executor** | Grok Bot iOS开发大师 under Human continue-auth (KOS) |
| **Human ask** | 「授权你按照KOS设定继续」 (2026-09-23 Asia/Shanghai) — consume + run Capture; continue-auth also covers this evidence amend |
| **consumed_at** | `2026-09-23T20:19:10+08:00` (docs Consumed **before** first Simulator arm/capture) |
| **Evidence amend** | `2026-09-23T21:10+08:00` Asia/Shanghai — Human-completed visible-key Capture + journal analysis folded in |

## Verdict for this Run

| Phase | Result |
|---|---|
| **AUTH consume (docs-first)** | **Pass** — AUTH + Assignment marked Consumed; PR opened before arm |
| **Install Debug tip with markers** | **Pass** — built/installed from tip `80091f35cc5411b292eca78662f39e2b91694045`; `typo_recall.*` strings present in `Keyboard.debug.dylib` |
| **Arm (App Group container prefs + HF)** | **Pass** — `logging_enabled=true`, category toggles true, `diagnostics_high_fidelity_expiration` refreshed (~30 min window, last refresh ~`2026-09-23T12:56:43Z` / `20:56 +08`) |
| **Keyboard Extension appearance** | **Pass (visual)** — Universe Keyboard QWERTY/拼音 visible in Messages before/during attempt (screenshots `screen1`/`screen2` @ ~20:23–20:26 +08); later Human Capture windows confirmed |
| **HF-JSONL / dynamic journal growth** | **Pass** — Extension JSONL minted after Human visible-key Capture (see Journal binding) |
| **Visible-key stimulus (smoke long + rapid &lt;180)** | **Pass (Human)** — Human completed smoke composition + rapid burst on designated Simulator (Mac `CGEvent` Device Hub clicks earlier in Run did **not** deliver product keys; not claimed) |
| **Same-process smoke→rapid** | **Pass** — all `touch.terminal` share one `processInstanceID` and one `appearanceID` |
| **Cadence &lt;180 ms (rapid consecutive + even-index)** | **Pass** — rapid consecutive gaps 15/15 &lt;180 ms; even-index starts within rapid 6/7 &lt;180 (one ~200.27 ms); odd-index 7/7 &lt;180 |
| **`typo_recall.*` journal codes** | **Pass (positive cancel/reschedule)** — `debounce_cancelled` 26 / `debounce_scheduled` 27; rapid window 8 cancel + 8 schedule. `fence_discarded` **0** this Run. `epoch_bumped` 2 at appearance only |
| **Human visual attestation** | **Pass (both)** — confirmed 2026-09-23 Asia/Shanghai via widget: (1) no contextual typo-correction candidates while typing; (2) post-pause lookup/refresh only against the final composition |

**Overall disposition:** **Bounded / Pass-with-conditions** for the INT-003 stale-cancel **observation package** (Capture ≠ Gate).

| Claim slice | Disposition |
|---|---|
| Same-process smoke→rapid | **Pass** |
| Rapid &lt;180 stimulus (consecutive; even-index mostly) | **Pass** |
| Positive debounce cancel/reschedule journal | **Pass** |
| Human visual both attestations | **Pass** |
| Product Gate / QA-001 Gate | **Not claimed** — still requires separate Gate AUTH |

**Conditions / residuals (honest KOS):**

1. **`fence_discarded` absent this Run** (count 0) — cancel path observed via debounce cancel/reschedule, not fence discard.
2. **`query_begin` / `query_outcome` volume high (574/574)** — journal alone does **not** prove “only post-pause lookup”; Human visual attests post-pause refresh against final composition, but dense query markers remain an **Architecture residual**.
3. **`epoch_bumped` only at appearance** (~13:02:23Z, epochs 1 then 2) — no invalidate-path epoch during typing this Run; post-bump caveat on invalidate-path `debounce_cancelled` is **N/A for the typing path this Run** (caveat remains binding for future correlators).
4. Still **not** Product Gate; parent **Active**; Capture ≠ Gate.

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
| Dynamic JSONL search | Ready; **minted** after Human visible-key Capture (see Journal binding) |
| Markers AUTH | Remains **Consumed** (not reopened) |

## Journal binding

| Field | Value |
|---|---|
| **Path (Simulator App Group)** | `/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/06C5BC3E-7599-4761-A1A2-71DAEA991474/data/Containers/Shared/AppGroup/E9CF1194-00E6-4E56-9B2B-2781B8103B42/Diagnostics/v1/g1/open/keyboard_extension-583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2-20260923T13-0.jsonl` |
| **Relative** | `v1/g1/open/keyboard_extension-583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2-20260923T13-0.jsonl` |
| **SHA-256** | `a9af14932b1a0b78595c26966a6dd16fe4ba2aa654a91ec760f86fa12bda64cc` (re-verified at evidence amend) |
| **Bytes / Lines** | 941967 / 1432 |
| **processInstanceID** | `583B3AB8-86FE-4480-BD1D-5EEF9F1BB1E2` (all events) |
| **appearanceID** | `320926C3-3992-473E-A75C-739BF054334B` (all events) |
| **schemaVersion** | 4 |
| **`touch.terminal` window (UTC)** | `2026-09-23T13:03:50Z` → `13:04:36Z` |
| **`touch.terminal` window (CST +8)** | `21:03:50` → `21:04:36` Asia/Shanghai |
| **`touch.terminal` count** | 78 |

## Cadence analysis

### Rapid slice (touches 62–77, n=16)

Consecutive inter-touch gaps (ms) — **15/15 &lt; 180**:

`[100.35, 99.91, 49.47, 83.9, 82.58, 68.16, 65.51, 83.63, 49.74, 101.84, 47.82, 84.0, 49.51, 67.28, 65.82]`

| Slice | Result |
|---|---|
| Even-index starts within rapid | **6/7 &lt; 180** (one gap ~200.27 ms) |
| Odd-index starts within rapid | **7/7 &lt; 180** |
| Smoke→rapid phase boundary gap touch[61]→[62] | ~**28567 ms** (phase pause; not rapid-bar failure) |

### Earlier short &lt;180 bursts (context only)

Also present: touches **4–9** and **48–51** (short &lt;180 bursts). Primary INT-003 rapid claim uses touches **62–77**.

## `typo_recall` journal counts (full journal)

| Code | Count |
|---|---|
| `typo_recall.debounce_scheduled` | 27 |
| `typo_recall.debounce_cancelled` | 26 |
| `typo_recall.epoch_bumped` | 2 (at appearance ~13:02:23Z; epochs 1 then 2) |
| `typo_recall.fence_discarded` | 0 |
| `typo_recall.query_begin` | 574 |
| `typo_recall.query_outcome` | 574 |

### During rapid window `13:04:35Z`–`13:04:37Z`

| Marker | Count |
|---|---|
| `touch.terminal` | 16 |
| `debounce_cancelled` | 8 |
| `debounce_scheduled` | 8 |
| `query_begin` | 16 |
| `query_outcome` | 16 |

Positive cancel/reschedule journal is present for the rapid stimulus. Dense `query_*` counts do **not** alone prove “lookup only after pause” (see Conditions / residuals + Human visual).

## Human visual status

Confirmed **2026-09-23 Asia/Shanghai** via widget (Human-completed Capture):

| Attestation | Status |
|---|---|
| Keyboard visible (Universe / 拼音) on designated Simulator | **Pass** (executor pre-stimulus + Human Capture) |
| No contextual typo-correction candidates while typing | **Pass (Human)** |
| Post-pause lookup/refresh only against the final composition | **Pass (Human)** |
| Human supervised visible-key smoke + rapid | **Pass (Human)** |

### Human screenshots (chat attachments — described; not copied into `docs/evidence/assets`)

| Capture | Composition / notes | Candidate bar observed |
|---|---|---|
| Smoke | `winmenjintianquhongyuanwan` | Ordinary RIME single-char candidates (我/为/无…), **not** contextual phrase |
| Rapid | same + `hhhhhhhhhh` | Same ordinary RIME candidates; **not** contextual phrase |

Screenshots remain chat attachments unless later copied under `docs/evidence/assets`. No Product Gate claim from screenshot description alone.

## Prior Run residual (historical)

Earlier in this same Run ID, before Human taps:

- Mac-side Device Hub `CGEvent` clicks did **not** deliver product key events (placeholder unchanged; no `touch.terminal`).
- First evidence commit recorded HF-JSONL absent / stimulus inconclusive.
- That residual is **superseded** for stimulus/journal by the Human-completed Capture + journal binding above. `CGEvent` clicks are still **not** claimed as successful visible-key product stimulus.

## Non-claims

- No INT-003 Product Gate / QA-001 Gate
- No parent Close; no Release / TestFlight
- No production Swift / ObjC / RIME changes under this AUTH
- No `RimeRuntimeProvenance` restore
- Capture alone does **not** self-declare Product Gate
- Do **not** reuse consumed Cadence-003 / Controlled-Capture-002 / Markers AUTHs as Live authority
- Mac `CGEvent` Device Hub clicks are **not** claimed as successful visible-key product stimulus
- Markers binary presence ≠ journal cancel proof (journal now supplies positive cancel/reschedule; still ≠ Gate)
- High `query_begin` volume ≠ proof of “only post-pause lookup” without Human visual
- `fence_discarded` absence this Run ≠ cancel failure (debounce cancel/reschedule observed)
- Squash-merge of consume PR still requires separate parent/Human ask

## Follow-ups (not under this AUTH)

1. Separate **Architecture** AUTH may address dense `query_*` residual / fence-absent correlator notes.
2. Separate **Quality** AUTH on this observation package if parent schedules it.
3. **Product Gate** still needs a **separate** Gate AUTH — do not treat this Capture disposition as Gate.
4. **Do not squash-merge** consume PR #157 until parent/Human asks.

## Checkout hygiene

Docs + evidence only on branch `docs/typo-correction-002-int003-stale-cancel-product-capture-consume-001`. Dirty home main not mutated. Vendor binaries copied locally into worktree for build (gitignored). Journal SHA re-verified on host at evidence amend; raw JSONL not committed.

## Outcome

AUTH **Consumed**. Run ID bound. Install + arm + Human visible-key smoke/rapid + HF-JSONL + cadence + positive `typo_recall` debounce cancel/reschedule + Human visual both attestations collected. Disposition: **Bounded / Pass-with-conditions** for INT-003 stale-cancel observation package. Parent Active. No Gate. No merge.
