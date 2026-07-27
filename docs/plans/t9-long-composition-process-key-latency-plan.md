# Plan: T9 long-composition `process_key` latency

| Field | Value |
|---|---|
| Status | **Active — S4 capped-two-syllable preflight authorized; implementation, paired Simulator evidence and independent review pending** |
| Created | 2026-07-24 |
| Product lock | 2026-07-24 |
| Lane A ship | 2026-07-24 |
| Long-term work item | [`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md) |
| Product direction | [`PD-T9-AUTO-ANCHOR-001`](../product-decisions/T9-AUTO-ANCHOR-001-authorization.md) |
| Architecture boundary | [`ADR 0024`](../architecture/decisions/0024-t9-auto-anchor-shadow-observation-boundary.md) |
| Supersedes | force_gc-as-primary-fix track (closed) |
| Close record | [`../evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md`](../evidence/t9-continuous-digit-latency-force-gc-case-close-2026-07-24.md) |
| Current evidence | [`../evidence/t9-auto-anchor-retry-transaction-matrix-s3-2026-07-27.md`](../evidence/t9-auto-anchor-retry-transaction-matrix-s3-2026-07-27.md) |

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
| 1 | Must unlimited digit run stay smooth **without** any Path / partial commit? | **Superseded 2026-07-26 by `PD-T9-AUTO-ANCHOR-001`: Yes as the long-term destination.** Early Path selection remains the current mitigation/correction surface while safe automatic bounding is developed through S1–S6. |
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
| Exact cumulative Path confirmation | Collapses T9 ambiguity without host commit | Current UI needs a second tap after later input to advance an end-selected Path | **V7 measured effective: 0 / 190 slow keys; V8 interaction validated** |
| Advance a previously explicit end-Path when the next digit arrives | Recreates cumulative anchoring without a redundant second tap | Product/state transition change; must preserve explicit intent and ADR 0023 | **Promising, not authorized** |
| Mid-type soft banner after N digits | User-driven shorten | **UX noise / rhythm break** | **Out of default scope** (may revisit only if idle hint + engine work fail) |
| Partial-commit friendly docs / settings copy | Same graph-shortening habit | Must not break ADR Path rules | Secondary |

**When:** Always preferred first for perceived improvement under locked Q1/Q4.

### Lane B — T9-only schema/engine knobs — **allowed secondary**

| Idea | Effect | Risk |
|---|---|---|
| `t9.custom.yaml` completion / spelling-hint limits | May lower `api` cost | **Measured ineffective** for the frozen long-composition spikes |
| `enable_sentence: false` | Intended sentence suppression | **Not applicable to `script_translator`; measured ineffective** |
| `max_homophones: 1` | Bounds sentence-entry enrollment | **Measured ineffective**; system table lookup remains dominant |
| Review Lua translators still on T9 hot path (`date` / `calc` pattern-gated?) | Drop accidental work | **Measured not primary** for the frozen input |
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

## Long-term automatic-bounding roadmap

The product destination is smooth uninterrupted nine-key input without
requiring a Path tap per syllable. Explicit Path remains the correctness
reference and correction surface.

| Stage | Deliverable | Mutation | Exit / next gate |
|---|---|---|---|
| S1 — Shadow authority observation | Debug-only analyzer over the already-returned snapshot; content-free `T9SHADOW` reason/count metrics | None | **Implemented and sampled; broader-stage independent review remains pending and Release remains behavior-neutral** |
| S2 — Reversible bounded-preference prototype | Complete local proof rejected by catalog audit; explicit gate, one-attempt ledger, bounded first-page conservation and Delete/rejection rollback | Debug/explicit gate only | **Implemented. Two later P1 findings were closed and durably re-reviewed at `0173782`; this does not promote the whole stage, and Release remains off** |
| S3 — Broader engine/corpus shadow | Replay proposed anchors against unchanged inputs across a synthetic corpus; compare candidates, paths and timing | Private test/runtime evidence only | **Six-case, 24-case, later-opportunity and real-RIME transaction matrices complete. A capped two-syllable proposal is the leading next hypothesis; independent stage review and production policy remain pending** |
| S4 — Release-candidate reversible anchor | First preflight caps the existing single proposal at two complete syllables; default/user control remains deferred | **Validated at immutable checkpoint `22d34dd`: Debug/explicit gate only; Release mutation not authorized** | **Deterministic/corpus/personalization regression, 5/5 frozen startup pairs and independent Architecture/Quality Pass complete; Product Gate remains open** |
| S5 — Personalization shadow | Observe whether repeated user-confirmed Path history improves confidence; no duplicate phrase store by default | None until privacy decision | **First isolated matrix durably reviewed at `9c4f86f`: three independent complete-learning cases plus one partial negative; broader language review and retention/deletion/privacy amendment remain open** |
| S6 — Productization | Default/user control decision, Release-like physical-device performance, memory/jetsam, candidate-quality and Product Gate | Yes | Product/Architecture/Quality acceptance; plan completion/archive |

### S1 frozen acceptance matrix

| Case | Required result |
|---|---|
| Complete page, every compatible Path shares closed prefix | `proposalReady`; counts only |
| Same Path set in personalized/reordered ranking | Same prefix/slot metrics |
| Top candidate preferred but another Path diverges | No preference override |
| `hasMorePages == true` or page is not zero | Blocked as incomplete candidate set |
| Missing/invalid/incompatible comment | Blocked as incomplete Path evidence |
| Only one still-extendable syllable | No closed-prefix proposal |
| Missing/stale generation or provenance | Blocked |
| Release build | Observer not compiled/emitted |
| Any case | No RIME call, state mutation, raw/pinyin/candidate/host log or dictionary access |

## Recommended sequence

1. ~~Lock product answers to questions 1–4~~ **Done 2026-07-24.**  
2. ~~Implement **Lane A idle Path hint**~~ **Done 2026-07-24** (Path bar only; settings footer).  
3. ~~**Simulator baseline** with clean source+compiled diagnostic + fixed digit sequence (Lane D).~~ **Done 2026-07-26; physical-device baseline remains open.**
4. ~~Try **Lane B** T9-only hypotheses in isolated runtime copies.~~ **Done for Lua, completion, spelling hints, sentence flag and homophone limit; none reduced the deterministic spikes.**
5. ~~Measure bounded composition/segmentation against continuous ambiguity.~~ **Done 2026-07-26: exact cumulative Path and phrase commit both removed the frozen spikes; Path did so without host commit.**
6. ~~Authorize, implement and sample S1 read-only shadow observation.~~
   **Implementation, automated validation and five-run real-UI sampling
   complete 2026-07-27; broader-stage independent review remains pending.**
7. Decide whether next-digit input advances an already explicit end-Path; add
   KeyboardCore contract coverage before any implementation.
8. Solidify the frozen matrix as layered regression coverage: deterministic
   unit contracts, RimeBridge integration metrics and opt-in host XCUITest.
9. ~~Complete the S2 authority audit and obtain reversible-prototype
   authorization.~~ **Done 2026-07-27: complete local proof rejected; Product
   authorized the explicitly gated one-attempt/rollback prototype.**
10. ~~Implement and validate the first S2 prototype.~~ **Done 2026-07-27:
    focused 9/9, KeyboardCore 738/738, Debug/Release builds and first Reminders
    A/B complete; Release remains off.**
11. ~~Collect the first repeated S2 runtime stability slice.~~ **Done
    2026-07-27: five of five frozen-sentence B runs accepted at source slot 18
    with `5/5/5` candidate conservation. Remaining RIME medians at source
    slots 24/32/34 were `73.9/54.6/41.1ms`; paired startup and corpus coverage
    remain open.**
12. ~~Collect the first S3 safety corpus slice.~~ **Done 2026-07-27: six
    synthetic cases covered accepted, `2/5` and `1/5` rejection/restore,
    17-slot ineligibility, high ambiguity and Delete after a `3/5` boundary
    acceptance. Candidate conservation worked, but rejected sentences remained
    slow and Delete re-opened unresolved spelling ambiguity.**
13. ~~Observe later opportunities after the single S2 attempt rejects.~~
    **Done 2026-07-27: a read-only observer found identical
    `proposalReady` positions in three of three 40-slot real-UI runs. Five
    major slow keys immediately followed an opportunity. No second
    `replaceInput` was executed; transaction safety remains unproven.**
14. ~~Freeze an offline/test-only later-transaction matrix over those
    positions.~~ **Done 2026-07-27: all 15 maximal-prefix attempts failed at
    `2/5`; 89 backoffs found exactly one accepted boundary per position, always
    two syllables at `5/5`. All 104 transactions restored exactly. A three-run
    paired timing slice reduced `≥50ms` calls from 15 to 9, but later growth
    remained.**
15. ~~Extend maximal-prefix/backoff evaluation to the frozen S3 corpus.~~
    **Done 2026-07-27: two-syllable depth passed the known-positive,
    different-sentence, local-ranking and high-ambiguity cases, while the
    legal-but-poor path still failed and the 17-slot case remained ineligible.
    This is six-case evidence, not a representative corpus or production
    authorization.**
16. ~~Expand reviewed sentence-shape and length cases.~~ **Done 2026-07-27:
    24 cases produced 21 proposals; maximal prefixes accepted 8 and two
    syllables accepted 9. Two syllables preserved every maximal acceptance,
    added one natural case, and accepted no poor-input case.**
17. ~~Cover the first isolated personalized/reordered userdb behavior under the
    S5 privacy gate.~~ **Done 2026-07-27: the first reviewed matrix ran three
    independent complete-learning cases and one partial negative. Complete
    targets produced restart-stable `4 → 0 → 0`; two `3/5` cases stayed
    accepted and one `2/5` case stayed rejected. The partial negative moved
    `2 → 3` and removed the proposal.** Next expand language/shape coverage and
    decide retention/deletion/privacy before any production integration. Keep
    the current runtime policy unchanged until a new Product/Architecture
    decision.
18. Implement the Product-authorized S4 preflight as a pure two-syllable
    proposal-depth cap under the existing one-attempt Debug gate. Revalidate
    deterministic tests, the declared 24-case corpus, isolated S5 matrix,
    strict builds and the Assignment-frozen five-pair, 200-ms Simulator A/B
    before independent review. Explicit fixture classes require zero skips;
    default-suite fixture skips remain non-coverage.
19. Advance later S4–S6 work only through the gates above; update this plan Status →
    Completed / Abandoned and archive when the final Product Gate closes.

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
| 2026-07-26 | iOS 27 Simulator V0–V6 isolated matrix reproduced deterministic `rawLen` 24/32/34 `process_key` spikes. Lua, word completion, spelling hints, `enable_sentence` and `max_homophones: 1` did not reduce them. Symbolicated multi-thread ETTrace identified `ScriptTranslation::MakeSentence → Dictionary::Lookup → Table::Query` as the dominant first-party path. No production configuration was changed; physical-device/Release/Product Gate evidence remains open. |
| 2026-07-26 | V7 controlled matrix separated ambiguity from raw length. Continuous T9 reproduced 15/190 slow keys; cumulative exact Path retained the full composition but reduced this to 0/190, and phrase commit/reset also produced 0/190. The smallest proven mitigation is explicit Path anchoring, not forced host commit. Automatic anchoring remains unauthorized because it could invent user intent. |
| 2026-07-26 | V8 real-UI XCUITest passed the full Reminders sequence and exposed the current interaction rule: an end-selected Path must be tapped again after later input exists before focus advances. This distinguishes the proven engine mechanism from current one-tap UX. A next-digit transition may safely advance a path the user already selected, but remains a product decision. Regression coverage should be layered; ordinary unit tests must not hard-code simulator wall-clock thresholds. |
| 2026-07-26 | Human Product Owner selected automatic safe bounded ambiguity as the final direction, authorized a durable staged plan and S1 implementation. ADR 0024 freezes S1 as Debug-only, read-only and content-free. Current-focus catalog completeness and current-page candidate comments are explicitly not treated as complete whole-sentence authority. User-dictionary ranking is preference evidence only. |
| 2026-07-27 | V9 drove the frozen 38-key sequence through Reminders and the visible nine-key surface for five no-Path/no-candidate rounds. Raw lengths 24 / 32 / 34 reproduced at 5 / 5 and remained RIME-dominated while warm UI max stayed 2.1 ms. All 190 observations produced zero `proposalReady`; the final round was 38 / 38 `candidateSetIncomplete`. S1 runtime sampling is complete, but ADR 0024 remains Proposed and independent Architecture/Quality review is still required. |
| 2026-07-27 | S2 audit enumerated the local 417-syllable segmentation graph for the frozen 38-slot input: `3,486,320,640` legal paths, four viable first syllables and no forced target boundary. Complete local proof and foreground full-candidate scans were rejected. Human Product Owner authorized an explicitly gated reversible prototype: one automatic apply attempt, bounded first-page candidate conservation, rejection/Delete rollback, no candidate-window scan, no persistence and no Release-default enablement. |
| 2026-07-27 | S2 first implementation/A-B: an all-sampled-compatible proposal never fired because real pages had one compatible and eight rejected Path comments. The bounded preference was narrowed to require the first candidate's compatible catalog path while retaining every sampled candidate text for post-replacement conservation. At source length 18 the transaction was accepted with `5/5/5` candidate conservation and `13/5` anchored/unresolved slots. The representative RIME spikes changed from about `110/71/65ms` to `77/54/41ms`. This is one Debug Simulator pair; S3 multi-run and independent review remain open. |
| 2026-07-27 | S2 B stability extension: five of five valid Reminders/software-keyboard runs accepted the same source-slot-18 proposal with `5/5/5` candidate conservation and no rejection/restore-failure outcome. Source-slot 24/32/34 RIME medians were `73.9/54.6/41.1ms`; key 24 and 32 still exceeded 50ms in four of five runs. This closes only the first-sentence B repeatability slice, not frozen paired A/B, corpus quality, independent review, physical-device or Release gates. |
| 2026-07-27 | S3 first corpus slice: six synthetic cases produced accepted (`5/5`, `3/5`), rejected/restored (`2/5`, `1/5`) and 17-slot not-eligible outcomes. Rejection protected correctness but left 71–127ms RIME calls on the different-sentence long case. Delete after a `3/5` accepted short case exposed no digits but re-resolved the remaining ambiguous `42` tail from provisional `ha` to `ga`. Unit coverage now freezes the `3/5` versus `2/5` boundary and prevents personalized candidate order from overriding compatible `jin/lin` Path disagreement. |
| 2026-07-27 | Product Owner accepted a read-only later-opportunity observer after the first S2 rejection. Three Reminders/software-keyboard runs of the 40-slot rejected sentence produced identical `proposalReady` positions (`21,23,25,27,28,30,31,33,34,35,37,38,39,40`). The major slow keys at `22,24,26,32,36` immediately followed ready positions. This establishes a stable retry signal, not second-transaction safety; the ADR one-attempt budget remains unchanged. |
| 2026-07-27 | A pinned-librime test-only transaction matrix executed all 15 maximal opportunities and 89 shorter-prefix backoffs. Every maximal proposal failed at `2/5`; exactly the two-syllable backoff passed at each position with `5/5`, and all 104 transactions restored raw and candidates. Three paired timing rounds reduced `≥50ms` calls from 15 to 9 and lowered the five fixed slow-slot medians by 13–17ms. This redirects S3 from retry timing to anchor-depth selection; one sentence does not authorize a production cap or repeated attempt. |
| 2026-07-27 | The same depth matrix covered the frozen six-case S3 corpus. Two syllables passed the known-positive, different-sentence, local-ranking and high-ambiguity cases; `a × 18` still failed conservation and the 17-slot threshold remained ineligible. A capped two-syllable proposal is now the leading test hypothesis, but broader reviewed language/personalization coverage and explicit architecture authorization remain required. |
| 2026-07-27 | A declared 24-case extension covered 16 natural sentence shapes, four repeated-ambiguity inputs, two poor shapes and two threshold cases. Of 21 proposals, maximal prefixes accepted 8 and two syllables accepted 9. The cap preserved every maximal acceptance, added one natural case, rejected all poor cases and left thresholds inactive. Pinned-runtime distribution assertions now protect these counts; real userdb personalization and production authorization remain open. |
| 2026-07-27 | Product-authorized S5 isolated personalization matrix used a generated temporary RIME user directory. One complete synthetic candidate selection moved rank 4 to rank 0 and remained rank 0 after reopening; the long-composition two-syllable transaction stayed accepted at `3/5` before and after learning. Calibration showed partial long-candidate selection can train a continuation rather than the visible segment. Fixture class passed 2/2, default RimeBridge passed 31 with 11 gated skips, and the generated directory was removed. Broader personalized corpus, retention/deletion/privacy and production authorization remain open. |
| 2026-07-27 | The authorized first reviewed S5 extension used a fresh generated directory for each of three complete-learning cases and one partial negative. Complete cases all produced restart-stable `4 → 0 → 0`; two `3/5` cases remained accepted and one `2/5` case remained rejected. The partial negative required a continuation, moved `2 → 3`, and removed the later proposal. Fixture class passed 5/5, default RimeBridge passed 31 with 14 gated skips, and all generated directories were removed. |
| 2026-07-27 | Independent Architecture and Quality both returned `Pass with findings`. Remediation now fails closed unless the canonical user root is a strict `/private/tmp` descendant, reduces complete learning to exactly one selection, freezes the negative to one partial plus one continuation, revalidates the Assignment to S5 and completes ADR 0024's required sections. Post-remediation fixture class passed 6/6, default RimeBridge passed 32 with 14 gated skips, and an intentional non-temporary-root run failed before creating data. Checkpoint `9c4f86f` and its documentation record `878532f` later closed the immutable-snapshot finding; remaining S5 P2 limitations stay open. |
| 2026-07-27 | A later independent branch review found two S2 P1 defects: Partial Commit could retain the old accepted rollback ledger, and duplicate candidate text could shrink the declared five-slot overlap denominator. Checkpoint `0173782` clears old ledger payload while preserving the one-attempt tombstone and counts conservation as a multiset over the original bounded slots. Focused tests passed 12/12, KeyboardCore 745/745 and strict Debug/Release builds passed; the explicit retry fixture passed 6/6, while the default RimeBridge suite recorded 32 passed / 0 failed / 14 fixture-gated skips, with those skips remaining non-coverage. Architecture and Quality bound durable `Pass` verdicts for the two P1 closures with no P0–P3 findings. Documentation checkpoint `b2a5ab1` records the closure without promoting broader stages or changing Assignment `Active`, ADR `Proposed` or Product/Release Gate authority. |
| 2026-07-27 | Product Owner authorized the recommended S4 preflight: cap the existing Debug-only, single automatic proposal at the first two complete syllables while preserving the one-attempt ledger, first-candidate identity, original-window multiset conservation and rollback contracts. The authorization includes deterministic, 24-case, isolated-personalization, strict-build and frozen startup-paired Simulator evidence. It excludes a second transaction/backoff loop, threshold reduction, production personalization, user controls and Release-default enablement. |
| 2026-07-27 | S4 implementation checkpoint `22d34dd` caps only a fully eligible S2 proposal, keeps automatic boundaries out of user Path ownership and adds explicit Path-supersession coverage. Focused tests passed 15/15, KeyboardCore 748/748, the explicit real-RIME class passed 7/7 with zero skips, and strict Debug/Release plus vendor verification passed. Five frozen startup pairs were valid; all B arms accepted one seven-slot anchor with 5/5/5 conservation, and all paired p95/worst deltas improved. Architecture and Quality independently returned Pass with no P0–P3 findings. This closes the Debug S4 preflight evidence only; physical-device, Release-default and Product Gate remain open. |
