# TYPO-CORRECTION-002 Simulator Run Receipt — INT-003 Revalidation

> **Run ID:** `TC2-SIM-20260919-120020-INT003-REVAL-02`
>
> **Status:** Recorded as provenance-bound direct-sidecar evidence; the formal
> INT-003 rapid-cadence condition was not met; QA-001 was not run; no gate is
> closed
>
> **Evidence grade:** `Executor-recorded`
>
> **Scope:** One manually operated Debug Simulator capture on the designated
> Device Hub simulator with the real `rime_ice` runtime. This receipt separates
> deployment/sidecar observability from the stale-work cancellation claim. It is
> not Product acceptance, Quality approval, a performance result, a Release
> decision, a merge decision or Assignment closure.

## Authority and identity

- Parent Assignment: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
- Bounded Authorization: [`AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001.md)
- Case registry: [`TYPO Benchmark Registry V2`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- Source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Execution worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Execution branch: `codex/typo-correction-002-provenance-sidecar`
- Configuration: `Debug`, signed Simulator package
- Main executable SHA-256: `4e55969afce3ae497bab5c7af20a6889ce1420b7770c8be40e1877515e8883be`
- Keyboard extension executable SHA-256: `ea37b30d98aefea11387333e787aafe7f71fcab0fca0dafa5acccc5ced374801`

The Authorization initially named `TC2-SIM-20260919-115054-INT003-REVAL-01`.
Manual deployment/schema selection occurred before this actual capture, so this
capture received the fresh `REVAL-02` Run ID. No rebuild, reinstall or schema
change occurred during this capture. The main checkout was not modified by the
capture.

## Run header

| Field | Observed value | Provenance / boundary |
|---|---|---|
| Collection window | `2026-09-19T04:07:41Z`–`2026-09-19T04:07:55Z` | `2026-09-19`, Asia/Shanghai; content-free diagnostic timestamps |
| Simulator | `iPhone 17 Pro Max`, iOS `27.0` | XcodeBuildMCP session |
| Simulator UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` | XcodeBuildMCP session and App Group path |
| Host application | Messages, `com.apple.MobileSMS` | UI snapshot |
| Host conversation | `+1 (888) 555-1212` | UI snapshot |
| Universe Keyboard active | Human operator confirmed | Apple-style appearance and AX keyboard label are not treated as sole identity evidence |
| Full Access | Human operator confirmed | Not inferred from AX |
| High-fidelity diagnostics | Enabled before capture | Main-App diagnostics setting |
| Final draft | `winmenjintianquhongyuan` | Final UI snapshot; draft remained unsent |

## RIME provenance

The receipt below was read from the designated Simulator App Group after the
runtime was deployed and copied to the Run artifact directory. No
`FakeCandidateProvider`, old Ice directory or synthetic RIME fixture was used.

| Field | Observed value |
|---|---|
| Active schema / scheme | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Source variant | `nju` / downloaded |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Provenance receipt ID | `078F7EA2-F9CA-4033-B7DD-48BE636BEB38` |
| Provenance receipt file SHA-256 | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |
| librime | `1.16.1` |
| Runtime smoke | `true` |
| Lua runtime smoke | `true` |

## Observed scenario

The operator reported entering the target sequence, accidentally entering `w`
twice, then deleting one `w`, and pausing without sending. The final UI snapshot
is the authoritative observed draft for this receipt and reported
`winmenjintianquhongyuan` (23 characters), not the registry target
`wimenjintianquhongyuan` (22 characters). This discrepancy is retained rather
than silently normalized; the content-free diagnostics cannot identify which
key produced the extra character.

No candidate-selection, Space, Return, or Send action was observed after the
pause. Because the final raw composition did not equal the QA-001 input, this
interaction is not a QA-001 candidate-selection attempt.

## Content-free cadence evidence

The raw diagnostic segment contains 50 `touch.terminal` records: 25 key-start
markers and 25 terminal markers. It does not contain key labels, raw input or
candidate text.

| Measure | Observed value |
|---|---:|
| Key-start markers | 25 |
| Adjacent key-start intervals | 24 |
| Minimum adjacent interval | `225.657417 ms` |
| Median adjacent interval | `472.1476665 ms` |
| Maximum adjacent interval | `1595.088083 ms` |
| Intervals below `180 ms` | `0 / 24` |

The observed cadence therefore did not satisfy the Assignment's `<180 ms`
INT-003 stimulus. The journal schema emitted no explicit cancellation event in
this segment, so the absence of such an event is not converted into a
cancellation claim.

## Direct sidecar observability

The capture segment contains 72 direct `typo_correction.sidecar_query` events,
from `2026-09-19T04:07:46Z` through `2026-09-19T04:07:55Z`.

- Every event reports `route=real_rime_sidecar`.
- Every event reports `schemaID=rime_ice` and `outcome=returned`.
- Every event reports `resultCount=3` with `limit=3`.
- Every event binds receipt ID `078F7EA2-F9CA-4033-B7DD-48BE636BEB38`.
- Every event preserves live session ID `4408136472` before and after, with
  `liveSessionValid=true` before and after.
- Sidecar session ID `4701819672` remains stable before and after.
- Reported query latency is `1–7 ms` (median `2 ms`).
- Input-length markers cover `8–23`; counts are 4 each for lengths 8–20, 5
  for 21, 8 for 22 and 7 for 23.
- Sidecar diagnostic sequence numbers range from `54` through `365`.

These observations establish the direct, real-RIME sidecar seam and its
provenance binding. They do not establish that stale contextual work was
cancelled, because the required rapid stimulus was not present and the journal
does not expose a cancellation marker.

## Claim outcomes

| Claim | Outcome | Evidence / boundary |
|---|---|---|
| Exact deployed runtime is provenance-bound | `pass` for this bounded sub-claim | Fresh `rime_ice` receipt, archive/content digests and runtime-smoke fields |
| Direct real-RIME sidecar query is observable | `pass` for this bounded sub-claim | 72 content-free events; all real route, returned and receipt-bound |
| Live RIME composition/session remains valid across sidecar queries | `pass` for this bounded sub-claim | Stable live session ID and valid-before/after markers on all 72 events |
| Exact registry composition survived this capture | `not established` | Final observed draft was `winmenjintianquhongyuan`, not the 22-character target |
| `TC2-CASE-INT-003` rapid stale-work cancellation | `inconclusive; not a formal pass` | 0/24 adjacent intervals below 180 ms; no explicit cancellation marker |
| QA-001 target candidate visibility/selection | `not-run` | Final raw composition did not match the QA-001 input; no selection or send |
| Paired candidate-refresh performance | `not-run` | No paired baseline/treatment capture in this Run |

## Preserved artifacts

Raw content-free artifacts are retained outside Git:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260919-120020-INT003-REVAL-02/raw/`

| File | SHA-256 |
|---|---|
| `diagnostics-v1-g1-open.jsonl` | `1a8ea6ed1728d4152153e8ed87feec05e40bad2ea94ca545c9bc1aaa36d50cae` |
| `rime-runtime-provenance.json` | `b6c9a74a747b35997cc4dc67c651443b7dfd610f50fd290f9076760de7865c54` |

An earlier pre-input screenshot was moved to the Run's `excluded/` directory
because it showed the pre-capture system keyboard and is not used as evidence
for this receipt.

## Non-claims and next method

- This receipt does not close `TC2-CASE-INT-003`, `TC2-CASE-QA-001` or the
  paired performance case.
- It does not establish a Product, Quality, TestFlight, Release, merge or
  Assignment decision.
- The provenance and direct sidecar-observability portion is now reproducibly
  recorded for this Run.
- A formal INT-003 pass still requires a fresh Run using an authorized method
  that sends actual touch events to the visible keyboard keys and records a
  `<180 ms` stimulus boundary; `type_text` or host-text injection must not be
  used. Any restarted capture receives another fresh Run ID.
