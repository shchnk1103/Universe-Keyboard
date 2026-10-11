# TYPO-CORRECTION-002 Simulator QA-001 Run Receipt — Manual Candidate Observation

> **Run ID:** `TC2-SIM-20260917-235838-QA001-02`
>
> **Status:** Recorded as an inconclusive formal QA-001 attempt; the intended
> candidate was not observed and no gate is closed
>
> **Evidence grade:** `Executor-recorded`
>
> **Scope:** Formal `TC2-CASE-QA-001` attempt on the designated Device Hub
> iOS 27 iPhone 17 Pro Max Simulator. This receipt is not Product acceptance,
> Quality approval, a performance result, a Release decision or an Assignment
> closure.

## Authority and Identity

- Assignment: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
- Device evidence owner: [`TYPO-CORRECTION-002 Device Hub Validation Record`](typo-correction-002-device-hub-validation.md)
- Case registry: [`TYPO Benchmark Registry V2`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- Source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Collection window: 2026-09-18, Asia/Shanghai; the Run ID was allocated at
  2026-09-17 23:58:38 before the local date changed.
- Implementation source was the uncommitted isolated worktree; the `main`
  checkout was not modified by this capture.

## Run Header

| Field | Observed value | Provenance / boundary |
|---|---|---|
| Configuration | `Debug`, signed Simulator package | XcodeBuildMCP build/run |
| Build run | `TC2-SIM-20260917-234800-QA001-01` | Same package remained installed; no rebuild, reinstall or schema change before this capture |
| Simulator | iPhone 17 Pro Max, iOS `27.0` | XcodeBuildMCP |
| Simulator UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` | XcodeBuildMCP session defaults and runtime snapshot |
| Host application | Messages, `com.apple.MobileSMS` | XcodeBuildMCP launch and runtime snapshot |
| Host conversation | `+1 (888) 555-1212` | Deterministic repository test conversation |
| Universe Keyboard active | Human operator confirmed before input; keyboard-extension diagnostics emitted during input | The Apple-style appearance and AX label were not used as sole identity evidence |
| Full Access | Human operator confirmed | Not inferred from AX |
| High-fidelity diagnostics | Enabled before capture | Keyboard-extension diagnostics export |
| Main executable SHA-256 | `ea76b87fee7d6a23d3a76de64507767da052a05932914d318e30c61d8b6e1b0a` | Signed Debug derived product |
| Keyboard executable SHA-256 | `ebbb920f68b38b45034aa2748c969a050f97ab11149852106e824d3b709d0249` | Signed Debug derived product |
| App Group | `group.com.DoubleShy0N.Universe-Keyboard` | Shared receipt and diagnostics paths |

## Invalidated Preceding Capture

The earlier `TC2-SIM-20260917-234800-QA001-01` interaction is explicitly
excluded from this receipt. Its automated taps were sent while the system
Simplified Pinyin keyboard was current; the AX value `下一个键盘=Universe
Keyboard` had been misread as the current keyboard identity. Its candidate and
draft observations are not QA-001 evidence. Because the capture method was
restarted, this receipt uses a new Run ID as required by the Assignment.

For `QA001-02`, the operator manually switched to Universe Keyboard and then
manually tapped every key. The runtime snapshot after the switch reported
`下一个键盘=English (Australia)`, and the keyboard-extension diagnostics below
confirm that the extension, not the system keyboard, produced the observed
input-path events.

## RIME Provenance

The receipt was read from the designated Simulator App Group before input and
copied to the raw artifact directory for this Run.

| Field | Observed value |
|---|---|
| Active schema | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Provenance receipt ID | `BC045C1B-6E03-4A4D-AA2E-2D31E3CA0ACE` |
| Provenance receipt SHA-256 | `6c9c9fc0e60237385784a10a492eb8c8ae17cfb8f582c5854e894e19935c55d9` |
| librime | `1.16.1` |
| Runtime smoke | `true` |
| Lua runtime smoke | `true` |
| Installed content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |

No FakeCandidateProvider, old Ice directory or synthetic RIME fixture was used
for this capture.

## Observed Scenario

The operator manually tapped the repository-declared composition
`wimenjintianquhongyuan` through the visible Universe Keyboard and paused. The
final runtime snapshot (`seq=85`) reported the same raw composition in the
Messages draft. No candidate, Space, Return, Delete or Send action was
performed.

The final screenshot shows the candidate bar with eight visible candidates,
but the intended candidate **“我们今天去公园” was not visible**. Since the
target was not observed, no candidate was selected and the draft remained
unsent.

## Content-Free Diagnostic Segment

The raw diagnostic segment spans `2026-09-17T16:00:51Z` through
`2026-09-17T16:01:05Z` (`2026-09-18 00:00:51–00:01:05` Asia/Shanghai).
Diagnostics contain route, schema, receipt, sequence, result-count and latency
markers only; they do not contain the raw input or candidate strings.

| Event / measure | Observed value | Boundary |
|---|---:|---|
| `touch.terminal` records | 44 | 22 manually tapped keys, represented by terminal highlight lifecycle records |
| First key-start marker | `2026-09-17T16:00:53Z` | Monotonic timestamp in raw log |
| Last key-start marker | `2026-09-17T16:01:04Z` | Monotonic timestamp in raw log |
| Minimum adjacent key-start interval | `262.944 ms` | This is not an INT-003 rapid-cadence run |
| Maximum adjacent key-start interval | `1441.980 ms` | Manual operator cadence |
| Intervals below 180 ms | `0 / 21` | Not evidence for the INT-003 stimulus |
| `typo_correction.sidecar_query` | 70 | Direct sidecar observations |
| Sidecar input-length markers | `8–22` | Content-free lengths only |
| Sidecar route | `real_rime_sidecar` on all 70 | Direct production sidecar route |
| Sidecar schema | `rime_ice` on all 70 | Same active schema |
| Sidecar outcome | `returned` on all 70 | `resultCount=3`, `limit=3` |
| Sidecar latency | `1–7 ms` | Diagnostic marker range |
| Sidecar receipt binding | Same receipt ID on all 70 | `BC045C1B-6E03-4A4D-AA2E-2D31E3CA0ACE` |
| Final candidate visibility | `candidate_count=8`, `visible_candidate_cell_count=8` | Final revision 22; screenshot supplies the visible-label observation |
| `candidate.selection_delivered` | `0` | No candidate selection |
| Send/commit action | `0` observed | No message sent |

One startup `typo_correction.query_route` marker reported `route=unavailable`
before the direct sidecar calls. It is not used as a failure claim: the later
70 bounded events are the direct route evidence for this capture.

## Claim Outcomes

| Claim | Outcome | Evidence / boundary |
|---|---|---|
| Formal designated Simulator identity | `pass` for this run header | iPhone 17 Pro Max / iOS 27 / exact UDID |
| Exact deployed RIME runtime is provenance-bound | `pass` for this bounded sub-claim | `rime_ice` receipt, archive digest, receipt ID and runtime-smoke fields |
| Universe Keyboard produced the observed input-path events | `pass` for this bounded sub-claim | Human switch confirmation plus 44 keyboard-extension touch records and 70 sidecar events |
| Raw composition survives manual entry without automatic mutation | `pass` for this bounded sub-claim | Final runtime snapshot `seq=85` reported the unchanged synthetic composition; draft remained unsent |
| Direct real-RIME sidecar query is observable | `pass` for this bounded sub-claim | 70 content-free events; all real route, returned and receipt-bound |
| Intended candidate “我们今天去公园” is visible in the documented range | `not established` | Final screenshot did not show the target; diagnostics intentionally omit candidate text |
| Explicit candidate selection commits the intended phrase | `not-run` | Target was not observed; no candidate was selected |
| Normal interaction regression: Delete, Space, Return, paging, Partial Commit and switch-away | `not-run` | This attempt stopped at the paused candidate observation |
| `TC2-CASE-QA-001` | `inconclusive; no pass` | Candidate recovery and explicit selection were not established |
| `TC2-CASE-INT-003` rapid stale-work cancellation | `not-run` | Manual cadence had 0 intervals below 180 ms; this run was for QA-001 |
| Paired candidate-refresh performance case | `not-run` | No paired baseline or controlled performance capture |

## Preserved Artifacts

Raw artifacts are retained outside Git:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260917-235838-QA001-02/raw/`

| File | SHA-256 | Note |
|---|---|---|
| `pre/rime-runtime-provenance.json` | `6c9c9fc0e60237385784a10a492eb8c8ae17cfb8f582c5854e894e19935c55d9` | Simulator App Group receipt copied before input |
| `post/diagnostics-g1.jsonl` | `6c4b7747fab45805ed2ff4e39c6e8019fed24b8253bd9819c6f5cd19b6b70c5b` | Content-free keyboard-extension diagnostics |
| `post/qa001-02-screenshot.jpg` | `03f6523bceb4da1a99de306a7539061268a15e73f66537cdc1129e732332ad99` | Final paused UI, 368×800 JPEG |

## Non-claims and Next Method

- This receipt does not close `TC2-CASE-QA-001`, `TC2-CASE-INT-003` or the
  paired performance case.
- It does not establish a Product, Quality, TestFlight, Release, merge or
  Assignment decision.
- The direct sidecar seam and deployment provenance are now independently
  observable on the designated Simulator, but the semantic candidate-recovery
  claim remains open because the target candidate was absent from the final
  visible range.
- The next useful action is a read-only implementation/evidence review of why
  the real-RIME sidecar returned results while the target candidate was not
  presented. Do not repeat the same manual input blindly or infer a pass from
  the sidecar result count alone.
