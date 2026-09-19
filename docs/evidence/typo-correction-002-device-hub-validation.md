# TYPO-CORRECTION-002 Device Hub Validation Record

> **Status:** Active evidence record — designated simulator remains the formal environment target; contextual acceptance scenarios pending. A separately authorized physical-device supplemental arm is limited to `TC2-CASE-INT-003`.
>
> **Authority:** [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md), [`TYPO_CORRECTION.md`](../TYPO_CORRECTION.md), [ADR 0015](../architecture/decisions/0015-contextual-multi-error-typo-correction.md)
>
> **Formal gate device:** Designated Device Hub iPhone 17 Pro Max simulator on iOS 27 only.

## Authority Correction

On 2026-07-15 Asia/Shanghai, the Product Owner clarified that the Device Hub iOS 27 iPhone 17 Pro Max target is a **simulator**. Product Contract V2.2, the Assignment and the Registry now record that environment explicitly. The earlier physical-device interpretation is superseded and is not an active blocker.

## Current Availability Observation

A read-only simulator discovery on 2026-07-15 found the designated iOS 27 iPhone 17 Pro Max booted with UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`. Its App Group container is readable, but it contains only three user-level custom YAML files and no complete shared/compiled `rime_ice` runtime fixture. This proves target availability, not real-RIME fixture readiness.

The designated simulator's fresh `UniverseKeyboardUITests` baseline completed with 8 passed, 1 designed skip and 0 failures. It did not run `TC2-CASE-INT-002`, `TC2-CASE-INT-003`, `TC2-CASE-QA-001` or the paired performance case, so those Gates remain pending.

## Scope Amendment — 2026-09-17

The Human Product Owner authorized a physical-device supplemental evidence arm
for `TC2-CASE-INT-003` in the current Codex task on 2026-09-17 Asia/Shanghai.
This arm exists to capture a human-achievable rapid-cadence observation that the
Simulator operator could not provide. It does not replace the designated
Simulator, does not alter the `TC2-CASE-QA-001` environment boundary and cannot
close a Product, Quality, performance, TestFlight, Release or merge gate.

The physical receipt must independently bind the device model, UDID, OS build,
signed app and extension identity, active schema, exact RIME provenance receipt,
Full Access state, host application and a new Run ID. Any rebuild, reinstall,
device change, schema change or restarted capture invalidates reuse of an older
Run ID.

The supplemental physical receipt
[`TC2-PHYS-20260917-232938-INT003-02`](typo-correction-002-physical-run-2026-09-17-int003-02.md)
records a signed-build installation and 11 provenance-bound
`real_rime_sidecar` observations on the physical iPhone 13 Pro. It does not
close `TC2-CASE-INT-003`: the export has no sub-second cadence or cancellation
outcome. Its provenance screen independently records the displayed archive
version and SHA-256, while the raw physical receipt manifest remains
unexported. The designated simulator and all other gates remain unchanged.

## Formal QA-001 Attempt — 2026-09-18

The designated Simulator was freshly captured under
[`TC2-SIM-20260917-235838-QA001-02`](typo-correction-002-sim-run-2026-09-18-qa-001-02.md).
The preceding `QA001-01` interaction is excluded because it used the system
Simplified Pinyin keyboard after an AX-label misread. The new capture used
manual key taps on Universe Keyboard, retained the unchanged raw composition,
and produced 70 provenance-bound direct sidecar observations. The intended
candidate `我们今天去公园` was not visible in the final eight-cell candidate
range, so no candidate was selected and `TC2-CASE-QA-001` remains
inconclusive. Delete, Space, Return, paging, Partial Commit, switch-away and
paired performance evidence were not run. No Product, Quality, TestFlight,
Release or merge gate is closed.

## Paired Performance Diagnostic — 2026-09-18

The designated Simulator also recorded
[`TC2-PERF-20260918-184840-RIMEICE-01`](typo-correction-002-sim-run-2026-09-18-perf-rimeice-01.md).
The same `rime_ice` receipt and signed Debug payload were used for sidecar-off
and sidecar-on arms. The treatment arm produced 70 directly observable
`real_rime_sidecar` events, all bound to the exact receipt, with the live RIME
session valid before and after each query and the final raw composition
unchanged.

Both arms were manually paced and had no adjacent interval below 180 ms. The
record therefore preserves useful provenance and sidecar isolation evidence but
remains `inconclusive` for fixed-cadence performance, stale-work cancellation,
QA-001 candidate selection and all Product / Quality / Release decisions.

## Required Fresh Run Preconditions

1. For the formal environment arm, Device Hub exposes the designated booted iPhone 17 Pro Max simulator running iOS 27. The authorized physical arm has its own device-identity precondition and receipt.
2. Build commit, Debug/Release configuration, app/extension build identity, schema ID, RIME deployment identity, Full Access state and host application are captured before input begins.
3. A new run identifier is created after every rebuild, reinstall, device change, schema change or restarted capture. Do not reuse this blocked record as a passing run.

## Required Scenarios

| Case | Input and action | Required observation |
|---|---|---|
| `TC2-CASE-INT-002` | Begin a composition, wait for contextual lookup, then continue typing. | The visible raw composition continues from the original text; no sidecar lookup mutates preedit, candidate paging or marked text. |
| `TC2-CASE-INT-003` | Type a long synthetic composition continuously with intervals below 180 ms, then pause. The authorized physical arm may provide supplemental cadence/cancellation evidence. | No contextual candidate appears while typing; stale work is cancelled; only the final unchanged composition receives a post-pause lookup. The physical arm does not replace the designated Simulator for other cases or gates. |
| `TC2-CASE-QA-001` | Execute curated multi-error phrase corpus and explicit candidate selection. | Intended phrase is visible within the documented candidate range; explicit selection commits it; normal input, Delete, Space, Return, paging, Partial Commit and switch-away remain correct. |
| `TC2-PERF::TC2-CASE-QA-001::CANDIDATE_REFRESH` | Repeat the same corpus under controlled cadence. | Record per-key and post-pause latency distributions, maximum main-thread block, memory growth and any stalls; do not infer a pass without paired baseline evidence. |

## Stop Conditions

- For the formal environment arm, the target is not the designated simulator, is not booted, uses a non-iOS-27 runtime, or lacks required keyboard permissions. A physical supplemental arm must instead satisfy its separately recorded device-identity and permission preconditions.
- Runtime fixture/schema/build identity cannot be captured.
- Any query changes the live composition, marked text or RIME session state.
