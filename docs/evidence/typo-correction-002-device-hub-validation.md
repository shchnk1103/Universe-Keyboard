# TYPO-CORRECTION-002 Device Hub Validation Record

> **Status:** Active evidence record — designated simulator available; contextual acceptance scenarios pending.
>
> **Authority:** [`TYPO-CORRECTION-002`](../assignments/typo-correction-002.md), [`TYPO_CORRECTION.md`](../TYPO_CORRECTION.md), [ADR 0015](../architecture/decisions/0015-contextual-multi-error-typo-correction.md)
>
> **Allowed device:** Designated Device Hub iPhone 17 Pro Max simulator on iOS 27 only.

## Authority Correction

On 2026-07-15 Asia/Shanghai, the Product Owner clarified that the Device Hub iOS 27 iPhone 17 Pro Max target is a **simulator**. Product Contract V2.2, the Assignment and the Registry now record that environment explicitly. The earlier physical-device interpretation is superseded and is not an active blocker.

## Current Availability Observation

A read-only simulator discovery on 2026-07-15 found the designated iOS 27 iPhone 17 Pro Max booted with UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`. Its App Group container is readable, but it contains only three user-level custom YAML files and no complete shared/compiled `rime_ice` runtime fixture. This proves target availability, not real-RIME fixture readiness.

The designated simulator's fresh `UniverseKeyboardUITests` baseline completed with 8 passed, 1 designed skip and 0 failures. It did not run `TC2-CASE-INT-002`, `TC2-CASE-INT-003`, `TC2-CASE-QA-001` or the paired performance case, so those Gates remain pending.

## Required Fresh Run Preconditions

1. Device Hub exposes the designated booted iPhone 17 Pro Max simulator running iOS 27.
2. Build commit, Debug/Release configuration, app/extension build identity, schema ID, RIME deployment identity, Full Access state and host application are captured before input begins.
3. A new run identifier is created after every rebuild, reinstall, device change, schema change or restarted capture. Do not reuse this blocked record as a passing run.

## Required Scenarios

| Case | Input and action | Required observation |
|---|---|---|
| `TC2-CASE-INT-002` | Begin a composition, wait for contextual lookup, then continue typing. | The visible raw composition continues from the original text; no sidecar lookup mutates preedit, candidate paging or marked text. |
| `TC2-CASE-INT-003` | Type a long synthetic composition continuously with intervals below 180 ms, then pause. | No contextual candidate appears while typing; stale work is cancelled; only the final unchanged composition receives a post-pause lookup. |
| `TC2-CASE-QA-001` | Execute curated multi-error phrase corpus and explicit candidate selection. | Intended phrase is visible within the documented candidate range; explicit selection commits it; normal input, Delete, Space, Return, paging, Partial Commit and switch-away remain correct. |
| `TC2-PERF::TC2-CASE-QA-001::CANDIDATE_REFRESH` | Repeat the same corpus under controlled cadence. | Record per-key and post-pause latency distributions, maximum main-thread block, memory growth and any stalls; do not infer a pass without paired baseline evidence. |

## Stop Conditions

- The target is not the designated simulator, is not booted, uses a non-iOS-27 runtime, or lacks required keyboard permissions.
- Runtime fixture/schema/build identity cannot be captured.
- Any query changes the live composition, marked text or RIME session state.
