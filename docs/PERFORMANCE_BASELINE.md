# Performance Baseline

> Typo Correction Benchmark v1.0 Performance Evidence references and frozen measurement profiles are registered in [`TYPO_BENCHMARK_REGISTRY.md`](TYPO_BENCHMARK_REGISTRY.md). This document remains the authority for repository-wide measurement procedure and collected-evidence requirements.

## Purpose

This document defines how to collect repeatable Extension performance evidence. It intentionally contains no invented acceptance numbers. Initial values and future budgets must come from recorded simulator and physical-device measurements.

## Baseline Record

Create one record per build/environment:

| Field | Required value |
|---|---|
| Commit/build | exact commit and Debug/Release configuration |
| Device | model and storage state |
| OS | exact iOS version |
| Host | host app and input-field type |
| Schema | schema ID/version; Lua and simplification state |
| Access | Full Access on/off |
| Method | Instruments template, signpost/log points and sample count |
| Thermal/power | thermal state and whether attached to debugger |

Use synthetic input only. Do not record surrounding host text or private user content.

## Measurement Rules

- Measure Release-like behavior for product conclusions; Debug measurements are diagnostic only.
- Perform cold and warm runs separately.
- Record multiple runs and report median, worst observed value and sample count; do not report one favorable run.
- Compare the same device, OS, host, schema and access state before/after a change.
- Preserve Instruments traces or exported evidence with the release record when practical.
- A future numeric budget requires reviewed real-device evidence and a separate decision/update.

## Required Metrics

### Extension Cold Start

Measure from Extension process/presentation start to installed, visible, interactive keyboard UI. Separately record controller construction, runtime-directory resolution, RIME session creation and first stable layout. Test after terminating the Extension process, not only after hiding it.

### First Key Latency

Measure touch-down/action entry to committed state/UI feedback for:

- English direct key;
- first Chinese composition key;
- first key after returning from another host;
- first key after a fresh RIME session.

Correlate UI feedback, `KeyboardController.handle`, RIME processing and `syncUI` rather than using a single aggregate log only.

### Continuous Typing Latency

Use a fixed synthetic sequence at controlled cadence. Record per-key distribution, worst stalls, dropped visual/audio feedback and main-thread blocking. Run English direct input and Chinese RIME composition separately.

### Candidate Refresh Latency

Measure RIME output availability to candidate snapshot application for:

- first candidate page;
- near-edge prefetch;
- expanded candidate panel;
- candidate selection followed by remaining composition;
- typo-correction merge enabled only in an explicitly identified experimental run.

### Memory Usage

Record Extension memory after cold start, after sustained typing, after candidate paging, after repeated expand/collapse, and after repeated host switching. Inspect candidate caches, audio players, RIME sessions and retained controllers. Report resident memory and growth trend; do not infer a leak from one snapshot.

### Jetsam Observation

Collect device logs for Extension termination under normal and memory-pressure scenarios. Record whether termination is an ordinary lifecycle exit, crash or jetsam; preserve the report and exact build. Absence of a visible crash is not proof that jetsam did not occur.

### RIME Session Creation

Measure setup/initialize/session creation/schema selection separately for cold process start and active-session recovery. Confirm no deployment or filesystem preparation appears inside this interval.

### Lua Smoke Impact

Compare the same deployed `rime_ice` runtime with the release-relevant advanced-input configuration. Measure deployment smoke separately from Extension typing. For input, compare representative ordinary pinyin and documented Lua triggers; record session creation, key latency and candidate refresh impact.

### OpenCC Impact

Using the same schema and input set, compare simplification enabled/disabled after valid deployment. Record candidate refresh and commit latency plus memory changes. Verify correctness separately; faster output is not acceptable if conversion is wrong.

## Tooling And Evidence

Preferred evidence:

- existing `Logger.shared.performance` intervals for coarse correlation;
- Instruments Time Profiler for CPU/main-thread stacks;
- Allocations and Memory Graph for growth/ownership;
- Organizer/device logs for crash and jetsam evidence;
- XCTest performance tests only for deterministic pure or integration boundaries, not as a substitute for Extension device measurements.

Instrumentation added later must avoid synchronous persistence or verbose payloads in the key hot path.

## Baseline Status

No numeric baseline or budget is accepted yet. The following remain to be collected on the current primary physical device, current development iOS version and one available Simulator:

- [ ] cold start;
- [ ] first key;
- [ ] continuous English and Chinese typing;
- [ ] candidate refresh/paging;
- [ ] memory growth;
- [ ] jetsam observation;
- [ ] RIME session creation/recovery;
- [ ] Lua smoke impact;
- [ ] OpenCC impact.

## Related Documents

- `docs/TYPO_BENCHMARK_REGISTRY.md`
- `docs/architecture/decisions/0004-rime-runtime-session-model.md`
- `docs/RELEASE_CHECKLIST.md`
- `docs/DEBUGGING.md`
- `docs/TECH_DEBT.md`
