# TYPO-CORRECTION-002 Simulator Run Receipt — Manual Cadence Arm

> **Run ID:** `TC2-SIM-20260917-223508-INT003-01`
>
> **Status:** Recorded as supplemental human-paced evidence; formal INT-003
> cadence condition not met; no gate closed
>
> **Evidence grade:** `Executor-recorded`
>
> **Scope:** One manually operated Debug Simulator capture using the designated
> Device Hub simulator, the signed Debug build already deployed for the
> provenance/sidecar run, and the active `rime_ice` runtime. This receipt records
> the fastest cadence the operator could achieve in the Simulator; it is not a
> formal rapid-typing or stale-cancellation pass.

This receipt is execution evidence only. It is not Product acceptance, Quality
approval, a Release decision or Assignment closure.

## Authority and Identity

- Assignment: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
- Device evidence owner: [`TYPO-CORRECTION-002 Device Hub Validation Record`](typo-correction-002-device-hub-validation.md)
- Case registry: [`TYPO Benchmark Registry V2`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- Source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Implementation source was an uncommitted isolated worktree used for the
  signed Debug build; the main checkout was not modified by this capture.
- No rebuild, reinstall or schema change occurred between the preceding signed
  build and this capture.

## Run Header

| Field | Observed value | Provenance / boundary |
|---|---|---|
| Collection date | 2026-09-17, Asia/Shanghai | Executor session; operator input was manual |
| Configuration | `Debug`, signed Simulator package | Reused `TC2-SIM-20260917-221208-SIGNED-01` package |
| Simulator | `iPhone 17 Pro Max`, iOS `27.0` | XcodeBuildMCP |
| Simulator UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` | XcodeBuildMCP UI snapshots |
| Host application | Messages, `com.apple.MobileSMS` | XcodeBuildMCP launch and UI snapshot |
| Host conversation | `+1 (888) 555-1212` | Deterministic repository test conversation |
| Universe Keyboard active | Human operator confirmed | AX label is not treated as keyboard identity |
| Full Access | Human operator confirmed | Device precondition; not inferred from AX |
| Build main executable SHA-256 | `05cd7be30e3a7e26a3cf1de507ad22769252218500618c42eb0c7fc7663b4e6d` | Signed Debug derived product |
| Build extension executable SHA-256 | `426a0a659e9e8f8aab82f6749ec2d5efe7d389fb63a40579d212bd76c369ddb3` | Signed Debug derived product |

## RIME Provenance

| Field | Observed value |
|---|---|
| Active schema / scheme | `rime_ice` |
| Artifact identity | `rime-ice-20260630-675d23b0` |
| Artifact version | `2026.06.30` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Provenance receipt ID | `9B187679-035E-4E79-A27D-F0008E605561` |
| Provenance receipt SHA-256 | `640d0b40d64c6d58b7e77a1f7a77949c58836bb638aa7a89a92a28451de4713f` |
| librime | `1.16.1` |
| Runtime smoke | `true` |

The receipt was read from the shared App Group before input and copied to the
run artifact directory. No old Ice directory or FakeCandidateProvider was used.

## Observed Scenario

The operator entered the repository-declared synthetic composition
`wimenjintianquhongyuan` through the visible Universe Keyboard, as confirmed by
the operator. No candidate, Space, Return, Delete or Send action was performed.

The final UI snapshot (`seq=39`) reported the complete unchanged raw composition
`wimenjintianquhongyuan` in the Messages draft. The draft remained unsent.

## Content-Free Cadence Evidence

High-fidelity diagnostics were enabled before the capture. The diagnostic
segment records 22 `touch.terminal` key-highlight events without key labels,
typed text or candidate text.

| Measure | Observed value |
|---|---:|
| Key-highlight events | 22 |
| First event | `2026-09-17T14:35:42Z` |
| Last event | `2026-09-17T14:35:56Z` |
| Minimum adjacent interval | `372.168791 ms` |
| Maximum adjacent interval | `1122.247500 ms` |
| Intervals below 180 ms | `0 / 21` |

This is a bounded measurement of the operator's achievable Simulator cadence. It
does not satisfy the Assignment's `<180 ms` INT-003 stimulus contract.

## Direct Sidecar Observability

Within the capture window, the content-free diagnostic segment contains 70
`typo_correction.sidecar_query` events:

- input-length markers cover `8` through `22`;
- every event reports `route=real_rime_sidecar`;
- every event reports `schemaID=rime_ice`;
- every event binds the provenance receipt ID above;
- every event reports `outcome=returned` and `resultCount=3`;
- reported query latency is `1–3 ms`;
- sidecar query sequence range is `950–1243`.

Intermediate prefix lengths also have sidecar events in this manual-cadence arm.
Because the measured touch intervals never entered the required rapid window,
this observation cannot distinguish expected post-pause queries from stale-work
cancellation behavior under the formal INT-003 stimulus.

## Claim Outcomes

| Claim | Outcome | Evidence / boundary |
|---|---|---|
| Full raw composition survives manual entry without automatic mutation | `pass` for this bounded sub-claim | Final UI snapshot `seq=39`; draft remained unsent |
| Exact deployed runtime is provenance-bound | `pass` for this bounded sub-claim | `rime_ice` receipt, archive digest and receipt ID above |
| Direct sidecar query is observable and isolated from the live composition | `pass` for this bounded sub-claim | 70 content-free events; real sidecar route; live composition unchanged |
| Human-operated cadence arm is preserved | `pass` | 22 content-free touch timestamps and interval distribution retained |
| `TC2-CASE-INT-003` rapid-typing stale-work cancellation | `inconclusive; not a formal pass` | No measured interval was below 180 ms; intermediate prefix queries were observed |
| No contextual candidate appears while typing under the formal rapid stimulus | `not established` | This arm did not meet the formal stimulus; only the paused final state was captured |
| `TC2-CASE-QA-001` candidate selection | `not-run` | No candidate was selected and no message was sent |
| Paired candidate-refresh performance case | `not-run` | No paired baseline or controlled performance capture |

## Preserved Artifacts

Raw content-free artifacts are retained outside Git:

`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260917-223508-INT003-01/raw/`

| File | SHA-256 |
|---|---|
| `diagnostics-v1-g1-open.jsonl` | `f752fe87b181eb76bf205ab9a406616f33c2b0add3405c86d73716c5fd11ae81` |
| `rime-runtime-provenance.json` | `640d0b40d64c6d58b7e77a1f7a77949c58836bb638aa7a89a92a28451de4713f` |

The UI snapshot and screenshot were captured by XcodeBuildMCP at the final pause
point. The screenshot contains only the deterministic test conversation and the
synthetic composition; it was not sent or published.

## Non-claims and Next Method

- This receipt does not close `TC2-CASE-INT-003`, `TC2-CASE-QA-001` or the paired
  performance case.
- It does not establish a Product, Quality, TestFlight, Release, merge or
  publication decision.
- The operator should not be asked to repeat the same impossible manual cadence
  as if it were a product defect.
- A formal INT-003 attempt requires a new capture using either an authorized
  automation method that sends actual touch events to the visible keyboard keys
  (never `type_text` or host-text injection), or a separately authorized change
  to the Assignment's cadence contract. Any harness/build change requires a new
  Run ID and fresh identity capture.
