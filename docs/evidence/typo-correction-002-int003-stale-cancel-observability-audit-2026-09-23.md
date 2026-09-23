# Evidence: INT-003 stale-cancel observability audit — 2026-09-23

## Identity

| Field | Value |
|---|---|
| **Kind** | Read-only tip audit (docs-only; no capture; no Swift change) |
| **Tip SHA** | `4a51228fc8e435d538e9a5f7342ae325502e1e66` (`origin/main` after #148) |
| **Branch / worktree** | `codex/typo-correction-002-int003-stale-cancel-preflight-docs` |
| **Parent** | [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md) (Active) |
| **Contracts / cases** | `TC2-CTR-INT-002` / `TC2-CASE-INT-003` |
| **Executor** | Grok Bot iOS开发大师 |
| **Recorded at** | 2026-09-23T09:30:00+08:00 |

## Verdict (bounded)

**Diagnostics journal v1 cannot prove stale contextual-recall cancel today.**

Cancel/debounce is implemented in the MainActor coordinator (180 ms `DispatchWorkItem` + fence discard). The journal schema has **no** recall/debounce/cancel/epoch event codes. Prior INT-003 receipts that lacked an explicit cancellation marker remain correct on this tip. This audit does **not** claim Product Gate, parent Close, or that cancel is broken.

## Files reviewed

### Implementation (tip)

| Path | Relevance |
|---|---|
| `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` | Debounce `0.18` s; `invalidate` bumps `recallEpoch` / cancels work items; fence + yielded-turn token discard |
| `Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift` | `scheduleContextualTypoCorrectionRefresh` → coordinator; sidecar install invalidates first |
| `Keyboard/Controllers/KeyboardViewController+Presentation.swift` | Candidate refresh path schedules contextual recall |
| `Keyboard/Controllers/KeyboardViewController+ModeActions.swift` | Page / input-mode changes invalidate recall |
| `Keyboard/Controllers/KeyboardViewController.swift` | Hosts `recallEpoch`, work-item slots, `diagnosticsJournal`, HF mode |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | Controlled journal `Code` / `Flag` enums (schema v3) |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift` | `begin` / `end` recall flags; no journal emit |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | Core preflight ledger `termination = .cancelled` (in-memory; not journal) |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionDecisionTrace.swift` | DEBUG-only in-memory trace; not shipping journal |
| `Packages/RimeBridge/Sources/RimeBridge/` | No `RimeRuntimeProvenance.swift`; no `typo_correction.sidecar_query` string on tip |

### Evidence / registry / reviews (skim)

| Path | Lesson used |
|---|---|
| `docs/TYPO_BENCHMARK_REGISTRY_V2.md` | `TC2-CASE-INT-003` → `TC2-CTR-INT-002` **Pending** |
| `docs/evidence/typo-correction-002-device-hub-validation.md` | INT-003 scenario: continuous &lt;180 ms then pause; no contextual while typing; stale cancelled; post-pause lookup only |
| `docs/evidence/typo-correction-002-sim-run-2026-09-19-int003-reval-02.md` | Cadence unmet; **no explicit cancellation marker** in journal; do not convert absence into cancel claim |
| `docs/evidence/typo-correction-002-int003-cadence-2026-09-22-003.md` | Same-process + rapid &lt;180 cleared for that Run via `touch.terminal` only |
| `docs/product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md` | Residuals accepted; **not** Product Gate; provenance gap retained |
| `docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-architecture-review.md` | Third-runtime / bundle-SHA / provenance conditions |
| `docs/reviews/typo-correction-002-int003-cadence-2026-09-22-003-quality-review.md` | Bounded cadence Pass-with-conditions; parent INT-003 open |

## How stale cancel is implemented (code fact)

1. **Schedule:** After candidate presentation refresh, `scheduleContextualTypoCorrectionRefresh()` → `scheduleAfterCompositionSettled()`.
2. **Debounce:** Prior `DispatchWorkItem` cancelled; new item queued with `DispatchQueue.main.asyncAfter(deadline: .now() + 0.18)`.
3. **Eligibility:** letters page + Chinese mode + composition length ≥ 8 (whitespace stripped).
4. **Hard invalidate:** `invalidateTypoCorrectionRecall()` bumps `recallEpoch` / composition revision, cancels work items, finishes active driver / ends sidecar recall (used on page/mode change, sidecar rebind, lifecycle clears).
5. **In-flight discard:** Query / yield / apply paths compare fence snapshots (`normalizedComposition`, page, mode, `recallEpoch`, operation ordinal). Mismatch → discard; RunLoop yields have **no** cancel handle — token match is the fence.
6. **Rapid &lt;180 typing:** Debounce never fires if every inter-key start stays under 180 ms; pending scheduled work is cancelled on each re-schedule. That is the primary “stale work cancelled while typing” path for INT-003 continuous stimulus.

## Journal event codes: present vs missing

### Present on tip (`DiagnosticEvent.Code`)

| Code | Useful for INT-003? |
|---|---|
| `journal.started` / `journal.resumed` / `journal.dropped` / `journal.unavailable` | Arm / health only |
| `presentation.appeared` / `presentation.frame` | Lifecycle |
| `touch.terminal` | **Yes** — inter-key start cadence (Cadence-003 method) |
| `input.action` | Coarse input lifecycle (not recall cancel) |
| `rime.owner.published` | Owner publish |
| `ui.applied` | UI apply (not recall cancel) |
| `candidate.visibility_changed` | **Partial** — bar visibility; does not name contextual vs normal |
| `candidate.touch_routed` / `candidate.gesture_terminal` / `candidate.selection_delivered` | Candidate touch path (out of INT-003 non-select scope) |
| scheme / runtime_route / rime_sync family | Unrelated to INT-003 cancel |

### Flags that look like “cancel” but are **not** recall cancel

| Flag / field | Meaning |
|---|---|
| `candidate_touch_cancelled` (`wasCandidateTouchCancelled`) | Candidate **pan** gesture cancelled — not typo recall |
| `RimeSyncTerminalResult.cancelled` / scheme delivery `cancelled` | Sync / delivery terminals — unrelated |

### Missing for INT-003 cancel proof

| Desired observation | On tip journal? |
|---|---|
| Debounce scheduled / rescheduled | **No** |
| Debounce work-item cancelled | **No** |
| `recallEpoch` bump / fence discard / `.discarded` drive event | **No** |
| Sidecar recall begin / end | **No** (in-memory `isTypoCorrectionRecallActive` only) |
| Contextual query start / outcome / stale discard | **No** journal code |
| `typo_correction.sidecar_query` (historical OSLog-style marker in older Runs) | **Not present in tip sources**; tied historically to provenance-era captures; tip also lacks `RimeRuntimeProvenance.swift` |

`TypoCorrectionRecallPreflightTermination.cancelled` and DEBUG `TypoCorrectionDecisionTrace` do **not** write Diagnostics journal lines.

## Can the journal prove cancel today?

| Question | Answer |
|---|---|
| Prove cadence stimulus (inter-key starts &lt;180 ms) | **Yes**, with HF + `touch.terminal` (Cadence-003 method) |
| Prove same-process smoke→rapid | **Yes**, via `processInstanceID` / `appearanceID` binding |
| Prove “no contextual candidate while typing” from journal alone | **No strong proof** — may see `candidate.visibility_changed` / `ui.applied`, but schema is content-free and does not tag contextual vs normal |
| Prove stale recall cancelled / only post-pause lookup ran | **No** — no cancel / query / epoch marker |
| Convert “no cancel event” into “cancel happened” | **Forbidden** (reval-02 lesson; still valid) |

**Net:** Journal can support **stimulus and process binding**. Human visual observation can support **no contextual while typing** and **post-pause single lookup appearance**. Together they can produce a **bounded Human+journal observation**, not a journal-only cancel proof, and **not** an automatic Product Gate.

## Recommended observation plan (next product capture; Proposed AUTH only)

Do **not** run under this audit. When Human marks a Product-capture AUTH **Live**:

1. **Arm (Cadence-003 lessons):** App Group **container** prefs `logging_enabled` + category; refresh high-fidelity window; dismiss/reopen keyboard; confirm Extension `touch.terminal` on a fresh dynamic JSONL.
2. **Same-process:** One-key smoke then long synthetic composition rapid taps on the **same** `processInstanceID` / `appearanceID`.
3. **Stimulus:** Continuous visible-key intervals with **even-index touch starts** &lt;180 ms for the rapid slice; then intentional pause ≥180 ms without further keys.
4. **Collect:** Full dynamic JSONL for that process; list codes present (`touch.terminal`, lifecycle, candidate visibility, `ui.applied`); record Human attestation for contextual absence during typing and single post-pause contextual appearance (if any).
5. **Stop / inconclusive rules if cancel unobservable:**
   - If rapid starts fail &lt;180 → **inconclusive** for INT-003 stimulus (do not claim cancel).
   - If process churn splits smoke/rapid → **inconclusive** for same-process binding.
   - If journal has no cancel/query marker (expected on this tip) → **do not** claim journal-proven cancel; at most Human+journal **bounded observation**; Product Gate remains a separate AUTH decision.
   - If HF / JSONL absent → stop; re-arm; new Run ID.
6. **Non-claims during capture:** No QA-001 Product Gate, no paired perf, no physical-as-substitute, no parent Close, no Swift changes, no `RimeRuntimeProvenance` restore under the capture AUTH alone.

## Options if cancel marker remains missing

| Option | What it is | What it is not |
|---|---|---|
| **A — Docs-only Product path** | Accept Human visual + cadence journal as bounded evidence; Product Gate AUTH decides pass/fail with explicit “cancel marker absent” condition | Not journal-proven cancel |
| **B — Implementation AUTH (future)** | Separate AUTH to add controlled journal fields (e.g. recall schedule / cancel / fence-discard / query begin-end) under ADR 0027 field review | **Out of scope for this preflight**; do not implement here |
| **C — Stop / reopen** | Keep INT-003 Pending until marker or Product accepts A | Not a silent pass |

This audit recommends documenting A vs B in the Proposed capture Assignment/AUTH and **not** implementing B without a dedicated implementation AUTH.

## Non-claims

- No Simulator / capture executed under this receipt.
- No Swift / ObjC / RIME edits; no `RimeRuntimeProvenance` restoration.
- No Product Gate, Quality Gate, Release, TestFlight, parent Close, push, PR, or merge.
- No claim that cancel logic is incorrect — only that it is **not journal-observable** on tip `4a51228`.
