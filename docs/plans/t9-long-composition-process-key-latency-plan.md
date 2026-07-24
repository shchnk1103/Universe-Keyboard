# Plan: T9 long-composition `process_key` latency

| Field | Value |
|---|---|
| Status | **Active — Lane A idle hint shipped; baseline / Lane B pending** |
| Created | 2026-07-24 |
| Product lock | 2026-07-24 |
| Lane A ship | 2026-07-24 |
| Supersedes | force_gc-as-primary-fix track (closed) |
| Close record | [`../evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md`](../evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md) |

## Problem statement

On Chinese nine-key, continuous digit entry **without** Path or candidate selection produces frequent `SLOW KEY` as unconfirmed raw length grows. Device Debug instrumentation attributes SLOW keys almost entirely to librime **`process_key` (`api`)**, not UI, not local Path catalog, not `collectOutput`, and **not** residual force_gc after source+compiled clean.

## Goals

1. Reduce **rate and magnitude** of `api` spikes on long unconfirmed T9 digit runs.
2. Keep **26-key / `rime_ice`** behavior and shared `lua/force_gc.lua` unchanged unless a separate decision says otherwise.
3. Preserve Path completeness and ADR 0023 atomic presentation contracts.
4. Measure before/after with the same synthetic digit sequence and `T9SEG` / `SLOW RIME` reporting.
5. Prefer solutions that **do not interrupt mid-type rhythm**; educate only in empty/idle state when possible.

## Non-goals

- Inventing numeric SLOs without Release-like multi-run baselines.
- Off-main-thread librime rewrite as the first delivery (possible later architecture track).
- Weakening digit-host safety or Path authorization.
- Mid-composition banners / “after N digits” soft prompts that compete with Path/candidates while typing.

## Product decisions (locked 2026-07-24)

| # | Question | Decision |
|---|---|---|
| 1 | Must unlimited digit run stay smooth **without** any Path / partial commit? | **No.** Early Path selection and partial commit are **recommended usage**, not an edge-case workaround. Lane A is in scope as primary product path. |
| 2 | May T9-only translator quality trade off for speed? | **Allowed.** T9-only schema knobs (`t9.custom.yaml` etc.) may be explored if needed; still require nine-key Product Gate matrix before ship. **Do not** change shared ice force_gc / 26-key. |
| 3 | Acceptable worst-case per key? | **Minimize freezes** (multi-hundred-ms freezes are the pain). Prefer reducing spike rate/magnitude over polishing short-input averages. Formal numeric budgets still need baseline later. |
| 4 | Soft guidance placement? | **Lane A style, idle-only.** Prefer empty-state hint on Path bar and/or candidate bar when nine-key is active and user has **not** started composition. **Hide immediately** on first digit / first composition activity. **Reject** mid-type “after N unconfirmed digits” banners as default. |

### Idle empty-state Path hint — **shipped 2026-07-24**

Intent: teach Path / early confirm **without** disturbing input rhythm.

| Rule | Spec (locked + implemented) |
|---|---|
| When visible | Chinese nine-key letters surface reserved **and** no active T9 composition (raw + segment ledger empty) **and** Path chip count == 0 |
| Placement | **Path bar only** (primary); not candidate bar for v1 |
| Copy | 「点选拼音可加快输入」(`T9IdlePathHintPolicy.displayText`) |
| Hide trigger | Immediate when composition raw / ledger / Path chips become non-empty (first digit clears via policy) |
| Re-show | Every return to empty idle surface (no mid-type noise; low nag risk) |
| Non-goals for v1 | Hard cap on digit length; mid-type progressive warnings; blocking input until Path is used |
| Accessibility | `.staticText`, secondary label, non-interactive; id `t9PinyinPathIdleHint` |
| ADR 0023 | Hint is **not** a Path option; no catalog / soft-select / marked-text |

Code: `T9IdlePathHintPolicy`, `T9PinyinPathBarView.setPaths(..., idleHintText:)`, `KeyboardViewController.t9IdlePathHintText`, settings layout footer note.

## Candidate solution lanes

### Lane A — Product / interaction (shorten unconfirmed raw) — **primary**

| Idea | Effect | Risk | Status |
|---|---|---|---|
| Idle empty-state Path hint (above) | Educates Path/partial without mid-type noise | Weak if users ignore; must not look like real Path | **Shipped 2026-07-24** |
| Encourage Path / 选拼音 as recommended usage | Cuts engine graph size | Behavior framing / docs / onboarding | Locked as product truth |
| Mid-type soft banner after N digits | User-driven shorten | **UX noise / rhythm break** | **Out of default scope** (may revisit only if idle hint + engine work fail) |
| Partial-commit friendly docs / settings copy | Same graph-shortening habit | Must not break ADR Path rules | Secondary |

**When:** Always preferred first for perceived improvement under locked Q1/Q4.

### Lane B — T9-only schema/engine knobs — **allowed secondary**

| Idea | Effect | Risk |
|---|---|---|
| `t9.custom.yaml` performance patch (completion/sentence/homophone limits) | May lower `api` cost | Candidate quality / ranking — Product Gate required |
| Review Lua translators still on T9 hot path (`date` / `calc` pattern-gated?) | Drop accidental work | Feature regressions |
| **Do not** disable shared force_gc for ice | Protects 26-key memory story | — |

**When:** After or alongside A if freezes remain; product allows quality tradeoffs with gate.

### Lane C — Architecture — **later**

| Idea | Effect | Risk |
|---|---|---|
| Dedicated serial queue for all librime calls | Main thread less frozen for UI chrome | Same wall wait for commit; complexity; must serialize all RIME |
| Coalesce digit events | Fewer processKey calls | Correctness / marked-text lag |

**When:** A/B insufficient; treat as separate high-cost track.

### Lane D — Measurement hardening (always do alongside A/B)

| Idea | Effect |
|---|---|
| Fixed synthetic digit script + rawLen buckets | Comparable before/after |
| Count SLOW rate, median/p95 total, median/p95 api | Objective |
| Confirm `runtime_clean=true` on diagnostic before each matrix | Avoid dirty-compile confounds |

## Recommended sequence

1. ~~Lock product answers to questions 1–4~~ **Done 2026-07-24.**  
2. ~~Implement **Lane A idle Path hint**~~ **Done 2026-07-24** (Path bar only; settings footer).  
3. **Baseline** with clean source+compiled diagnostic + fixed digit sequence (Lane D) when owner can run device matrix.  
4. If freezes remain unacceptable for users who ignore Path, try **Lane B** T9-only in smallest shippable steps + Product Gate matrix.  
5. Re-measure; only then consider Lane C.  
6. Update this plan Status → Completed / Abandoned with evidence links.

**Lane B hold:** Quality tradeoffs are allowed by product, but not shipped without device baseline + nine-key Product Gate. Prefer measuring after Lane A behavior change first.

## Preconditions already satisfied

- T9SEG + api/collect split in Debug.
- force_gc primary-cause track **closed** with device evidence.
- Deploy pipeline can keep T9 source hygiene without touching ice force_gc.

## Risks

- Schema “speed” patches can quietly change candidate sets — require Product Gate matrix for nine-key (Q2 allows, does not waive gate).
- Architecture moves without serializing *all* RIME entry points will race.
- Debug + Xcode attach inflates keyDown→insert gaps; report Debug vs Release-like separately.
- Idle hint that reappears too often becomes nag; once-per-session or “after Path success, never again” reduces risk.
- Putting hint text inside Path bar must not be confusable with a tappable Path syllable.

## Related code (orientation only)

- `HotPathSegmentTiming`, `RimeProcessKeyBridgeTiming`, `KeyboardViewController+InputActions`
- Bar prefetch idle: `KeyboardViewController+CandidatePaging`
- T9 schema hygiene: `T9SchemaCompatibility`, `T9DeploymentSupport`, diagnostics runner
- Path contracts: ADR 0023, `KEYBOARD_LAYOUT.md`
- Path UI: `T9PinyinPathBarView` / candidate empty states

## Discussion log

| Date | Note |
|---|---|
| 2026-07-24 | Draft opened after force_gc case close; owner invited to answer product questions before implementation. |
| 2026-07-24 | Product lock: (1) early Path/partial is recommended usage — unlimited unconfirmed need not be perfectly smooth; (2) T9-only quality tradeoffs allowed with gate; (3) prioritize killing freezes over short-input averages; (4) prefer Lane A **idle-only** Path/candidate hint, hide on first input — no default mid-type N-digit prompt. Implementation still gated on explicit go. |
| 2026-07-24 | Owner delegated implementation; shipped Lane A idle Path hint + settings footer + unit tests. Lane B deferred pending baseline/gate. |
