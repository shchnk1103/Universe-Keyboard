# NATIVE-EXPERIENCE-001 — Step 1 Observability Assessment

Status: Closed

Closed Date: 2026-07-09

Protocol: `docs/plans/native-experience-001-investigation-protocol.md`

Source Scope: Step 1 only — Observability Assessment

## Closing Rule

This Step produces observation knowledge only.

No implementation work is created during Step 1. No new Work Item is created
during Step 1. Any future tooling, architecture, runtime, or UI implementation
decision must be made after the final Native Experience Report handoff and
accepted through a separate Assignment.

If Step 1 must be changed later, create a new Revision. Do not directly edit
this closed Step record.

## Source of Truth for Step 2

This document is the only Source of Truth for Step 2 — Environment Selection.

Step 2 must use the Findings, Evidence, Classification, and Confidence values
below as fixed inputs. Step 2 does not modify Step 1 conclusions.

## Evidence

### NE1-S1-E001 — `viewDidLoad` Performance Marker

Measurement: Source audit

Source: `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`

Observation: Existing code records `Logger.shared.performance("viewDidLoad complete")`.

Confidence: High

Reason: The call site exists in source and directly records the full
`viewDidLoad` duration.

### NE1-S1-E002 — RIME Engine Init Performance Marker

Measurement: Source audit

Source: `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl.swift`

Observation: Existing code records `Logger.shared.performance("Engine init complete")`
after setup, initialize, session creation, diagnostics, schema selection, and
schema verification.

Confidence: High

Reason: The call site exists in source and covers the aggregate initializer
duration.

### NE1-S1-E003 — RIME ObjC Stage Logs

Measurement: Source audit

Source: `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m`

Observation: Existing ObjC bridge emits `NSLog` stage markers for keyboard
setup, setup completion, initialize completion, session creation, session
destruction, restart, and recovery paths.

Confidence: High

Reason: The log points exist in source. They provide event boundaries, but not
explicit duration records.

### NE1-S1-E004 — No Existing Signpost Instrumentation

Measurement: Source audit

Source: Repository-wide search

Observation: No `os_signpost`, `OSSignpost`, or `signpost` usage exists in the
Swift source tree.

Confidence: High

Reason: Repository-wide search returned no matching call sites.

### NE1-S1-E005 — External Tool Coverage

Measurement: Tool capability assessment

Source: Frozen Investigation Protocol §8 Measurement Sources

Observation: Instruments Time Profiler, Allocations, Memory Graph, System Trace,
Xcode Debug Gauges, Xcode Organizer, Device Console, and existing
`Logger.shared.performance` are accepted measurement sources for the
Investigation.

Confidence: Medium

Reason: The protocol identifies these tools as accepted sources. Actual
Extension capture reliability still depends on later measurement execution.

## Findings

### NE1-S1-F001 — Current App-Level Markers Cover Coarse Startup Only

Evidence: NE1-S1-E001, NE1-S1-E002

Finding: Existing app-level performance markers cover total `viewDidLoad` time
and total RIME engine initialization time, but do not decompose `viewDidLoad`
into controller construction, runtime-directory resolution, RIME preparation,
layout construction, settings cache, observer registration, and haptic warmup.

Classification: Requires Tooling

Confidence: High

Conclusion: Current observability is insufficient for full-resolution startup
critical-path investigation. No implementation work or new Work Item is created
during Step 1.

### NE1-S1-F002 — RIME Subphase Duration Is Not Fully Resolved

Evidence: NE1-S1-E002, NE1-S1-E003

Finding: Existing RIME observability exposes aggregate engine init duration and
ObjC bridge stage events, but does not provide explicit per-subphase durations
for setup, initialize, create session, schema selection, and schema verification.

Classification: Requires Tooling

Confidence: High

Conclusion: Current observability is insufficient for full-resolution RIME
subphase investigation. No implementation work or new Work Item is created
during Step 1.

### NE1-S1-F003 — First-Key-to-Candidate Path Lacks Phase Boundaries

Evidence: NE1-S1-E004, NE1-S1-E005

Finding: Existing observability can profile CPU stacks externally, but it does
not provide explicit application-level boundaries for first key dispatch, RIME
processing, state mutation, `syncUI`, candidate snapshot application, and first
candidate render.

Classification: Requires Tooling

Confidence: Low

Conclusion: Current observability is insufficient for full-resolution
first-key-to-candidate investigation. The gap is classified as Requires Tooling.
No implementation work or new Work Item is created during Step 1.

### NE1-S1-F004 — Memory, Jetsam, and System Lifecycle Are Externally Observable

Evidence: NE1-S1-E005

Finding: Memory growth, allocations, system lifecycle events, crash reports,
and jetsam evidence are observable through accepted external tools without
requiring code changes.

Classification: Not Optimizable

Confidence: Medium

Conclusion: No Step 1 tooling gap is identified for memory, jetsam, and system
lifecycle evidence collection. Confidence remains Medium until actual trace
collection validates the toolchain on selected devices.

### NE1-S1-F005 — Overall Observability Is Partial, Not Blocking

Evidence: NE1-S1-E001, NE1-S1-E002, NE1-S1-E003, NE1-S1-E004, NE1-S1-E005

Finding: Existing observability is sufficient to begin Investigation, but not
sufficient for full-resolution answers across all Scope items.

Classification: Requires Tooling

Confidence: Medium

Conclusion: Step 1 does not trigger an investigation stop. Later steps may
collect available evidence with current tools and must preserve reduced
precision where tooling gaps remain.

## Step 1 Questions

| Question | Conclusion | Confidence | Evidence | Reason |
|---|---|---|---|---|
| Can Time Profiler capture full cold-start stack including pre-`viewDidLoad` frames? | Partially. External capture is expected, but early frames may be incomplete until verified during collection. | Medium | NE1-S1-E005 | Tool capability is accepted by protocol; actual capture reliability is environment-dependent. |
| Can System Trace capture XPC process launch messages? | Expected yes. | Medium | NE1-S1-E005 | Protocol accepts System Trace for system lifecycle. Actual capture is validated during Evidence Collection. |
| Does existing `Logger.shared.performance` cover key initialization phases? | Partially. It covers aggregate `viewDidLoad` and aggregate engine init only. | High | NE1-S1-E001, NE1-S1-E002 | Direct source audit confirms the marker scope. |
| Are there phases without sufficient observability? | Yes: `viewDidLoad` subphases, RIME subphases, and first-key-to-candidate boundaries. | High | NE1-S1-F001, NE1-S1-F002, NE1-S1-F003 | Missing boundaries are directly visible from source audit. |
| Can gaps be filled externally? | Partially. CPU stack sampling helps, but full-resolution phase attribution remains insufficient. | Medium | NE1-S1-E005 | External tools provide stack and system events, not application semantic boundaries. |

## Governance Self-Check

| Check | Result | Evidence |
|---|---|---|
| 1. 是否完成了本 Step 的全部 Exit Criteria？ | Yes, for Step 1 closure accepted by current governance decision. | Step 1 answers all Observability Assessment questions and identifies gaps. |
| 2. 是否产生了新的 Knowledge Asset？ | Yes. | This closed Step 1 Observability Assessment record. |
| 3. 是否越过了当前 Step 的 Scope？ | No. | No implementation, no instrumentation, and no new Work Item created. |
| 4. 是否可以正式 Close，并作为下一 Step 的唯一 Source of Truth？ | Yes. | Status is Closed; Step 2 source-of-truth rule is defined above. |

## Closing Decision

Step 1 — Observability Assessment is Closed.

Step 2 — Environment Selection may begin.
