# TYPO-CORRECTION-002 Physical Device Run Receipt — Provenance Gate Not Established

> **Run ID:** `TC2-PHYS-20260917-151101-INT003-01`
>
> **Status:** Recorded as inconclusive supplemental evidence; no gate closed
>
> **Evidence grade:** `Executor-recorded`
>
> **Scope:** Authorized physical-device supplemental arm for
> `TC2-CASE-INT-003` only. This receipt does not replace the designated iOS 27
> iPhone 17 Pro Max simulator and cannot close QA-001, paired performance,
> Product, Quality, TestFlight, Release or merge gates.

This receipt records the operator's manual physical-device capture and the
content-free diagnostic export. It does not treat keyboard activity or
candidate refresh as proof that the exact deployed RIME runtime was consumed.

## Authority and Identity

- Assignment: [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md)
- Device evidence owner: [`TYPO-CORRECTION-002 Device Hub Validation Record`](typo-correction-002-device-hub-validation.md)
- Case registry: [`TYPO Benchmark Registry V2`](../TYPO_BENCHMARK_REGISTRY_V2.md)
- Source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- Collection date: 2026-09-17, Asia/Shanghai
- Implementation source was the uncommitted isolated worktree; the main
  checkout was not modified by this capture.

## Run Header

| Field | Observed value | Provenance / boundary |
|---|---|---|
| Device | iPhone 13 Pro (`iPhone14,2`) | `xcrun devicectl device info details` |
| Device UDID | `00008110-000A08440198801E` | `xcrun xctrace list devices` / `devicectl` |
| OS | iOS `27.0`, build `24A437` | `devicectl` |
| Device reality | Physical, wired, paired, Developer Mode enabled | `devicectl` |
| Host application | Messages | Operator capture context |
| Universe Keyboard active | Human operator confirmed | AX label not treated as keyboard identity |
| Full Access | Human operator confirmed | Not inferred from AX |
| High-fidelity diagnostics | `true` in exported diagnostic segment | Exported display artifact |
| Signed build run | `TC2-PHYS-20260917-150556-SIGN-02` | Signed Debug build / automatic provisioning |
| Main executable SHA-256 | `f41a235d4dca9d154c6ce3f7f1d52161d434b5b8720e111af6d130e2e6aeb30b` | Derived physical product |
| Keyboard executable SHA-256 | `a8a8bc776428bcc3a86fdc7f221de0dac2095d838bfdc9ecc4eb5de79eeeacb1` | Derived physical product |
| Team identifier | `C33N6HTS9N` | Signed main app and extension |
| App Group entitlement | `group.com.DoubleShy0N.Universe-Keyboard` | Signed main app and extension |

## RIME Provenance Boundary

The physical build was signed and installed successfully, but this run does
not contain an independently readable physical-device
`rime-runtime-provenance.json`. The `devicectl` App Group copy attempt was
rejected because the tool does not allow copying the App Group's top-level
`Diagnostics/v1` path; that is a tool-observation limitation, not evidence
that the App Group is absent.

The simulator receipt must not be reused for this physical device. The active
physical-device schema, exact artifact identity, archive digest, runtime
receipt ID and runtime smoke result therefore remain `UNKNOWN` for this run.

## Observed Scenario

The operator manually entered the repository-declared synthetic composition
`wimenjintianquhongyuan` through the visible Universe Keyboard and paused. No
candidate selection or send action was performed. The export contains no
`candidate.selection_delivered`, `candidate.touch_routed`,
`candidate.gesture_terminal` or `input.action` event.

## Content-Free Diagnostic Counts

The raw display export is formatted text rather than the underlying JSONL
journal. It is still sufficient to establish the following bounded
observations:

| Event / marker | Count | Meaning / boundary |
|---|---:|---|
| `touch.terminal` | 44 | Visible key lifecycle activity; no key labels or input text |
| `rime.owner.published` | 22 | Owner/UI publication activity; not provenance proof |
| `ui.applied` | 22 | Candidate/UI application activity |
| `candidate.visibility_changed` | 28 | Candidate-bar visibility/count changes |
| `typo_correction.query_route` | 1 | Route event exists, but formatter omitted its payload fields |
| `typo_correction.sidecar_query` | 0 | No valid direct sidecar evidence was exported |

The absence of a valid `sidecar_query` event means this run cannot establish
that a direct query used a provenance-bound real RIME sidecar. It does not by
itself distinguish missing physical runtime directories from a missing or
invalid physical provenance receipt; the route payload is not recoverable from
this formatted export.

## Claim Outcomes

| Claim | Outcome | Evidence / boundary |
|---|---|---|
| Physical signed build installed and launched | `pass` for this bounded sub-claim | `devicectl` install and process launch succeeded |
| Universe Keyboard was manually active with Full Access | `pass` for operator precondition | Human confirmation |
| Keyboard received visible input lifecycle activity | `pass` for this bounded sub-claim | 44 content-free touch events |
| Raw composition survived without an observed automatic rewrite | `not independently promoted` | Operator paused after entry; no content-bearing raw journal/snapshot is retained in this artifact |
| Exact physical RIME runtime is provenance-bound | `not established` | No physical receipt identity/digest was captured |
| Direct real-RIME sidecar query is observable | `not established` | `sidecar_query=0`; route details omitted by display formatter |
| `TC2-CASE-INT-003` rapid-typing stale-work cancellation | `inconclusive` | Physical manual cadence was not timestamped with sub-second precision in this export; provenance gate is also open |
| `TC2-CASE-QA-001` candidate selection | `not-run` | No candidate was selected and no message was sent |
| Paired candidate-refresh performance case | `not-run` | No paired performance capture |

## Preserved Artifacts

Raw content-free artifacts are retained outside Git:

`/private/tmp/typo-correction-002-phys-runs/TC2-PHYS-20260917-151101-INT003-01/raw/`

| File | SHA-256 |
|---|---|
| `post/diagnostics-export.txt` | `3e8325d5f87c9a9bd1dda8c6549ef4808209eb519ce4da96561a2334e73114e4` |
| `post/paste-error.log` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `pre/app-group-copy-error.log` | `b82f1e0ed0d5d3b3e4d63e1f0059afedf39e3cec19c429f65226541883e6df64` |

The `paste-error.log` digest above is the SHA-256 of the empty file. The
App-Group copy error is retained as evidence of the `devicectl` observation
boundary, not as an App Group failure.

## Next Required Action

Before another physical capture, open the signed Universe Keyboard main app on
the same device and inspect `RIME 方案设置` → `雾凇拼音` → `方案信息` and the
deployment section. Confirm or capture the physical-device deployment result.
If a deployment or schema mutation is required, create a new Run ID before
pressing the deploy action. A new capture must then independently bind the
physical `rime_ice` provenance receipt and show at least one valid
`typo_correction.sidecar_query` event.

No Product, Quality, TestFlight, Release, merge or Assignment conclusion is
made by this receipt.
