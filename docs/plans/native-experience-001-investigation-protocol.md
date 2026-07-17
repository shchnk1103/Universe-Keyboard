<!--
  NATIVE-EXPERIENCE-001 — Native Interaction Baseline Investigation Protocol (Frozen)

  Status: Frozen
  Governance: KOS 2.0 — Method before Evidence before Knowledge before Implementation
  Frozen Date: 2026-07-08
  Current Version: v1.0
  Current Owner: To be assigned per ASSIGNMENT_POLICY.md

  This document defines the Investigation Protocol only.
  It does not authorize any code change, instrumentation, or optimization.
  Implementation Work Items are proposed as Future Work Recommendations only
  and require separate Assignment and Approval.
-->

# NATIVE-EXPERIENCE-001 — Native Interaction Baseline Investigation Protocol

> **Status:** Archived
>
> **Closure note:** Method frozen 2026-07-08; retained as investigation protocol history.
>
> **Current source of truth:** Active NE assignments and evidence under `docs/plans/` / `docs/evidence/` as applicable; product architecture remains in current domain sources.
>
> **Related ADRs:** none required by this hygiene pass
>
> **Guidance:** This plan is no longer current development guidance; do not treat Frozen method text as an open implementation backlog.

## 1. Objective

Establish the first authoritative Native Interaction Baseline for Universe Keyboard.

**The goal is complete understanding, not optimization.**

When this Investigation is complete, every user-perceivable delay between keyboard
invocation and the first successful typing interaction must have:

- measurable evidence;
- an identified root cause;
- a responsible owner;
- an approved classification (Optimizable / Requires Architecture / … / Unknown).

No remaining delay should be unexplained or attributed to unknown causes.

---

## 2. Scope

Investigate and document the complete interaction pipeline across the following dimensions.

### Keyboard Lifecycle

- Extension cold launch (process not resident)
- Extension warm launch (process resident, controller re-created)
- Keyboard presentation (viewDidLoad → viewDidAppear → first visible frame)
- View lifecycle (first appearance, return after disappearance, disappearance)
- Session restoration (ADR 0004 recovery path after runtime failure while visible)

### Input Readiness

- RIME initialization (`rime_setup` → `rime_initialize` → `rime_create_session` → `rime_select_schema`)
- OpenCC initialization (as part of RIME schema selection / runtime)
- Lua initialization (as part of `rime_initialize` for `rime_ice` schema)
- Candidate engine readiness (first `processKey` → first candidate page)
- First commit latency (first full composition → commit cycle)

### UI Responsiveness

- Keyboard presentation animation (alpha reveal after height confirmation)
- Candidate bar rendering (first candidate scroll view layout)
- Expanded candidate panel (first expand → visible cells)
- Keyboard page switching (letters ↔ numbers ↔ symbols)
- Chinese / English mode switching
- Symbol keyboard transition
- Shift state transition (off → singleUse → capsLock)

### Runtime Analysis

- Main-thread blocking during cold and warm launch
- Startup critical path (blocking dependency chain)
- Lazy-loading opportunities (deferred initialization candidates)
- Memory warm-up profile (cold start allocation vs steady-state)
- View construction cost (UIStackView row assembly)
- Auto Layout cost (first layout pass)
- Rendering pipeline (Core Animation commit)

### Memory

- Extension memory after cold start
- Memory after sustained typing
- Memory after candidate paging and expand/collapse cycles
- Memory after repeated host switching
- Growth trend (not leak assertion — evidence-based only)

### Jetsam

- Extension termination under normal conditions
- Extension termination under memory pressure
- Classification: ordinary lifecycle exit vs crash vs jetsam

### Measurement

Produce repeatable measurements using Instruments and production builds.
All measurements must be traceable to specific build, device, OS, host, schema, and Access state.

---

## 3. Non-Goals

This Investigation must **not** include any of the following:

- implementing optimizations;
- feature development;
- Typo Correction logic changes;
- Benchmark v1 changes;
- Task7 execution;
- Lua capability expansion;
- UI redesign or visual refresh;
- candidate ranking changes;
- AI-related functionality;
- adding new instrumentation, profiling hooks, or logging unless the Observability
  Assessment (Procedure Step 1) concludes existing observability is insufficient,
  and even then the action is a **recommendation**, not an implementation;
- any production behavior change;
- any code change that ships to users.

**Any implementation discovered during this Investigation must be proposed as a
separate Work Item under a different NATIVE-EXPERIENCE identifier.**

---

## Ownership

Ownership records are governance facts. Roles are derived from
`docs/playbooks/`, `docs/READING_MAPS.md`, and
`docs/VIRTUAL_ENGINEERING_TEAM.md` — this section does not reintroduce
"Current Role" or "Act as."

### Primary Owner

To be assigned per `docs/ASSIGNMENT_POLICY.md`.

The Primary Owner is accountable for Investigation execution, Evidence
collection, and delivery of the Native Experience Report.

### Supporting Owners

To be assigned per `docs/ASSIGNMENT_POLICY.md`.

Supporting Owners contribute domain-specific expertise:

- **RIME Runtime:** RIME initialization, session, Lua, OpenCC measurement
- **Keyboard UI:** Layout construction, rendering, candidate bar, page switching measurement
- **KeyboardCore:** State machine, input pipeline measurement

### Quality Owner

To be assigned per `docs/ASSIGNMENT_POLICY.md`.

The Quality Owner verifies that the Evidence Chain is complete, traceable,
and free of contamination for every Finding.

### Approval Owner

To be assigned per `docs/ASSIGNMENT_POLICY.md`.

The Approval Owner authorizes the Investigation Protocol freeze, accepts
the final Native Experience Report, and signs off Exit Criteria.

---

## Dependencies

### Required Inputs

These documents must be available and current before Investigation begins:

- `docs/PERFORMANCE_BASELINE.md` — measurement rules and required metrics
- `docs/PROJECT_CONTEXT.md` — architecture overview and module boundaries
- `docs/UI_STYLE_GUIDE.md` — frozen keyboard geometry and rendering baseline
- `docs/architecture/shared-container-and-rime-lifecycle.md` — lifecycle contract
- `docs/architecture/input-pipeline-and-marked-text.md` — input pipeline contract
- `docs/architecture/decisions/0002-visibility-change-abandons-composition.md` — ADR 0002
- `docs/architecture/decisions/0004-rime-runtime-session-model.md` — ADR 0004

### Optional Inputs

- `docs/architecture/decisions/0003-shared-container-ownership.md` — if App Group XPC latency is suspected
- `docs/architecture/decisions/0007-full-access-and-privacy-boundary.md` — if Full Access OFF is selected as a matrix cell
- `docs/architecture/opencc-integration.md` — if OpenCC impact is measured

### Produces Knowledge For

- Native Experience optimization Work Items (NATIVE-EXPERIENCE-002, -003, -004, -005)
- Future Architecture Decision Records (ADR amendments or new ADRs)
- `PERFORMANCE_BASELINE.md` evolution (numeric baselines derived from collected evidence)
- Native Experience Regression Guard (NATIVE-EXPERIENCE-005)

---

## 4. Investigation Questions

The Investigation must answer every question below. None may be skipped or deferred.

### Primary Questions

**Q1.** What is the complete end-to-end latency from keyboard invocation to first
successful typing interaction, decomposed by phase?

**Q2.** What is the critical path of the keyboard cold-start sequence, and which
steps are blocking vs parallelizable?

**Q3.** What is the main-thread blocking profile during cold start, warm start,
and continuous typing?

**Q4.** What is the per-phase latency for: RIME initialization, Lua initialization,
OpenCC initialization, candidate engine readiness, and first commit?

**Q5.** What is the UI rendering cost for: keyboard first paint, candidate bar
first render, expanded panel first render, and page switching?

**Q6.** What is the memory profile of the Extension across its lifecycle states?

### Architecture vs Implementation Questions

**Q7.** Which observed delays are caused by the iOS Keyboard Extension lifecycle
model (XPC process launch, memory limits, system suspension policy), and which
are caused by Universe Keyboard's own implementation?

This question must produce a clear taxonomy:

| Category | Definition |
|---|---|
| Architecture Constraint | Inherent to iOS Keyboard Extension model; cannot be changed by us |
| Implementation Property | Caused by our code, our initialization order, our data flow |

**Q8.** Which observed delays have no meaningful optimization value?

This question must produce a clear classification per delay:

| Classification | Definition |
|---|---|
| Optimizable | Our code can be changed; risk is acceptable; benefit is measurable |
| Not Optimizable | Cost > benefit, or risk is unacceptable, or benefit is immeasurable |
| Requires Apple | Needs iOS API or system behavior change |
| Requires Architecture | Needs architecture-level refactor (e.g., RIME session lifecycle redesign) |
| Requires Runtime | Needs RIME/librime upstream change |
| Requires UI | Needs UI framework or rendering pipeline change |
| Requires Tooling | Needs new measurement/profiling infrastructure first |
| Unknown | Evidence is insufficient to classify |

---

## 5. Investigation Principles

These principles govern every step of the Investigation and may not be overridden.

**P1 — Method before Evidence.** The Investigation Procedure (§9) is frozen before
any data is collected. No ad-hoc measurement, no improvisation.

**P2 — Evidence before Conclusion.** Every Finding must be backed by an Evidence
record. Every Evidence record must be backed by a Measurement record. Experience
judgment is not a substitute for evidence.

**P3 — Complete Traceability.** Any Conclusion must be traceable backward through
Finding → Evidence → Measurement to the original raw data (Instruments trace file,
device log line, memory snapshot).

**P4 — Unknown is Valid.** When evidence is insufficient to classify a delay or
determine a root cause, the classification is `Unknown`. Guessing is not permitted.
A Finding classified as `Unknown` must state what additional evidence would be needed.

**P5 — No Implementation.** This Investigation does not change code, add
instrumentation, modify build configurations, or alter runtime behavior. If
observability gaps are found, they are documented as Findings and proposed as
separate Work Items.

**P6 — Long-Term Knowledge Asset.** Every deliverable produced by this Investigation
must be maintainable as a living document, not a one-time snapshot. The Native
Experience Report must define its own maintenance rules.

**P7 — Apple Keyboard is Reference, not Source of Truth.** Apple's system keyboard
may be used as a reference implementation to understand system behavior, but it is
not the definition of correctness. The target is user-perceived interaction quality.

**P8 — Environment before Number.** A single latency number is meaningless.
Every measurement must be contextualized by its Environment Matrix cell
(device, OS, host, schema, Access, thermal state, cold/warm).

---

## Assumptions

The following assumptions are accepted as true at Investigation start.
If any assumption is later discovered to be false, the affected Evidence,
Findings, and Conclusions must be re-evaluated. A material assumption
failure triggers a protocol amendment and may require re-collection.

**A1 — Measurement Tool Trustworthiness.** Instruments (Time Profiler,
Allocations, System Trace) and Console.app produce accurate, reproducible
measurements for iOS Keyboard Extension processes.

**A2 — Extension Lifecycle Stability.** The iOS Keyboard Extension lifecycle
(XPC launch, view lifecycle, process termination) behaves as documented
for the current iOS version and is not affected by a known system regression.

**A3 — Production Baseline Representativeness.** The current RIME
configuration (`rime_ice` with default Lua and OpenCC settings) represents
the production user experience. Measurements taken with this configuration
generalize to the target user population.

**A4 — Simulator-to-Device Correlation.** Simulator measurements are
directionally informative for cold/warm start behavior, even though
absolute latencies differ from physical devices.

**A5 — RIME Runtime Determinism.** Repeated RIME `initialize()` and
`create_session()` calls under identical conditions produce consistent
latency profiles (within measurement noise).

**A6 — Host App Neutrality.** The host application (Messages, Safari, Notes)
does not introduce significant additional latency to the Keyboard Extension
lifecycle beyond the iOS system baseline.

---

## Limitations

This Investigation has explicit boundaries. Findings should not be
extrapolated beyond them without new evidence.

**L1 — iOS Version Scope.** Measurements are valid only for the iOS version
under test. Future iOS beta or release behavior changes are out of scope.

**L2 — RIME Upstream Scope.** Measurements are valid only for the current
librime version and Lua module versions bundled with the project. Upstream
changes may invalidate Findings classified as `Requires Runtime`.

**L3 — Feature Flag Scope.** Measurements cover only the production
configuration (default feature flags). Experimental or disabled features
are not measured unless explicitly listed in the Environment Matrix.

**L4 — Device Sample Size.** Measurements are collected on a limited set of
devices (see Environment Matrix). Findings may not generalize to all
supported devices — especially older hardware with different memory or CPU
profiles.

**L5 — Thermal and Battery Variance.** Measurements are collected under
normal thermal and battery conditions. Thermal throttle, Low Power Mode,
or critically low battery may produce different results not captured here.

**L6 — User-Specific Variance.** Measurements are collected with synthetic
input on a clean device. Real-world factors (user dictionary size, accumulated
RIME user data, background app load) may introduce variance not captured here.

**L7 — No Implementation Authority.** This Investigation does not authorize
any code change, configuration change, or build configuration modification.
All implementation requires a separate Work Item.

---

## 6. Environment Matrix

Every measurement must be assigned to a cell in this matrix. Cells may be marked
as "not collected" with a documented reason.

### Matrix Dimensions

| Dimension | Values |
|---|---|
| Device | Simulator (arm64, iOS 26.4+) / iPhone 13 Pro / iPhone 17 series |
| OS Version | Exact iOS build number |
| Cold/Warm | Cold (Extension process killed before test) / Warm (process resident) |
| Host App | Messages / Safari (address bar) / Notes (body) / Third-party app |
| Schema | rime_ice (default, no Lua advanced input) / rime_ice + Lua advanced input |
| Simplification | OpenCC enabled / OpenCC disabled |
| Full Access | ON / OFF |
| Thermal State | Normal / Elevated (document if different) |
| Debugger Attached | Yes / No |

### Prioritization

Not every combination must be measured. The Investigation must document:

- **Primary Baseline:** Simulator (cold + warm, Messages, rime_ice default, Full Access ON)
- **Device Validation:** iPhone 17 (cold + warm, Messages, same schema/config)
- **Regression Reference:** One older device (if available)
- **Stress Scenarios:** Memory pressure, repeated host switching, rapid page switching

Cells not collected must be listed with a documented reason (e.g., "Device unavailable",
"Configuration not yet supported", "Deferred to NATIVE-EXPERIENCE-00X").

---

## 7. Evidence Model

### Source of Truth Chain

```
Measurement (raw data)
  │
  │  Exact timestamp, Instruments trace file, device log line,
  │  memory snapshot, build identifier, environment cell
  │
  ▼
Evidence (extracted data point)
  │
  │  Reproducible value: duration in ms, memory in MB, stack trace,
  │  event sequence. Includes sample count (N) and distribution
  │  (median, P95, worst).
  │
  ▼
Finding (factual statement)
  │
  │  "Cold-start RIME session creation occupies X% of viewDidLoad
  │   wall time (median N=Y, P95=Z)."
  │  States what was observed, not why.
  │
  ▼
Conclusion (root cause + classification)
  │
  │  "Root cause: librime's initialize() loads Lua modules synchronously
  │   on the calling thread. Classification: Requires Runtime."
  │  Explains why and classifies the finding.
```

### Evidence Record Format

Every Evidence record must include:

```yaml
evidence_id: NE-E-{NNN}
measurement_ref: NE-M-{NNN}        # back-reference to raw measurement
environment_cell: {device}/{cold|warm}/{host}/{schema}/{access}
timestamp: {ISO 8601}
metric: {description}
value: {numeric value with unit}
sample_count: {N}
distribution: {median / P95 / worst}
tool: {Instruments template | Console | Allocations | Device Logs}
trace_file: {path or reference to preserved trace}
```

### Finding Record Format

Every Finding must include:

```yaml
finding_id: NE-F-{NNN}
evidence_refs: [NE-E-{NNN}, ...]
statement: {factual statement — what was observed}
phase: {cold-start | warm-start | first-key | continuous-typing | page-switch | memory | jetsam}
conclusion_id: NE-C-{NNN}
```

### Conclusion Record Format

Every Conclusion must include:

```yaml
conclusion_id: NE-C-{NNN}
finding_refs: [NE-F-{NNN}, ...]
root_cause: {explanation of why the observed behavior occurs}
classification: {Optimizable | Requires Architecture | Requires Runtime | Requires UI | Requires Tooling | Requires Apple | Not Optimizable | Unknown}
owner: {module or role responsible}
user_impact: {description of how this affects perceived interaction quality}
if_unknown: {what additional evidence would be needed for classification}
```

---

## 8. Measurement Sources

### Available Observability Tools (Current State)

| Tool | What It Observes | Granularity | Extension Compatibility |
|---|---|---|---|
| Instruments Time Profiler | Per-thread CPU stack sampling, function-level timing | Sampling interval (~1 ms) | Requires "Wait for executable" for cold start |
| Instruments Allocations | Memory allocation, retain/release, growth | Per-allocation | Full Extension support |
| Instruments Memory Graph | Object ownership graph, retain cycles | Snapshot | Full Extension support |
| Instruments System Trace | Context switches, syscalls, scheduling | Microsecond | Full Extension support |
| Xcode Debug Gauges | CPU, memory, disk, network trends | Seconds | Full Extension support |
| Xcode Organizer | Crash logs, jetsam reports, energy logs | Event | Post-hoc only |
| Device Console (Console.app) | `os_log` output, system messages | Per-message timestamp | Full Extension support |
| KeyboardCore `Logger.shared.performance` | Application-level performance markers | Log timestamp | Dependent on existing instrumentation density |

### Observability Assessment

**This assessment is Step 1 of the Investigation Procedure. It must be completed
before any data collection.**

The assessment must answer:

1. Can Instruments Time Profiler capture the full cold-start stack for the
   Keyboard Extension process, including frames before `viewDidLoad`?
2. Can Instruments System Trace capture XPC process launch messages?
3. Does the existing `Logger.shared.performance` output cover the key
   initialization phases (RIME setup, initialize, session creation, schema
   selection, layout construction)?
4. Are there gaps where no existing observability covers a phase that the
   Scope (§2) requires?
5. If gaps exist, can they be filled with external-only tools (Instruments,
   Console), or would they require in-code changes?

### Gap Handling

If the Observability Assessment finds that existing tools are **sufficient**:
- Proceed to data collection using only external tools.
- No code changes.

If the Observability Assessment finds that existing tools are **insufficient**:
- Document each gap as a Finding (NE-F-XXX).
- Classify each gap as `Requires Tooling`.
- Propose a separate Work Item (e.g., NATIVE-EXPERIENCE-TOOLING-001) to build
  measurement infrastructure.
- Collect what is collectible with existing tools.
- Mark affected Scope items as "Insufficient Observability — deferred."

---

## 9. Investigation Procedure

This procedure is **frozen**. It may not be modified during the Investigation.
If a procedure change is necessary, the Investigation pauses and the change
must be approved as a protocol amendment.

### Step 1: Observability Assessment

**Input:** Measurement Sources (§8), existing codebase

**Actions:**
1. Audit existing `Logger.shared.performance` call sites in
   `KeyboardViewController+Bootstrap.swift`, `RimeEngineImpl.swift`,
   and `RimeSessionManager.m`.
2. Configure Instruments for Extension profiling.
3. Run one trial cold-start trace to confirm toolchain can capture
   Extension process frames.
4. Run one trial Console session to confirm Extension log output.

**Output:** Observability Assessment document answering all five questions
in §8. May be a subsection of the final Native Experience Report.

**Stop Condition:** If observability is insufficient for ≥ 50% of Scope items,
pause and recommend NATIVE-EXPERIENCE-TOOLING-001 before continuing.

### Step 2: Environment Selection

**Input:** Environment Matrix (§6)

**Actions:**
1. Select Primary Baseline cell.
2. Select Device Validation cell(s).
3. Select Regression Reference cell (if available).
4. Select Stress Scenario cells.
5. Document unavailable cells with reasons.

**Output:** Completed Environment Matrix with planned vs deferred cells.

### Step 3: Evidence Collection

**Input:** Completed Observability Assessment, selected Environment cells

**Actions:**
1. For each selected cell:
   - Cold-start trace (Instruments Time Profiler + System Trace)
   - Warm-start trace
   - First-key interaction trace
   - Continuous typing trace (English + Chinese)
   - Candidate paging / expand trace
   - Page switching trace
   - Memory profile (Allocations cold + steady-state + growth)
   - Console log capture (for Logger output correlation)
2. For Stress cells: add host-switching and memory-pressure scenarios.
3. Preserve all raw trace files with environment metadata.
4. Record sample count per measurement (minimum N=5 runs per cell).

**Output:** Raw Measurement records (NE-M-{NNN}) with preserved trace files.

### Step 4: Evidence Validation

**Input:** Raw Measurement records

**Actions:**
1. Verify each measurement has complete environment metadata.
2. Verify sample count meets minimum (N ≥ 5).
3. Verify trace files are readable and correspond to claimed measurements.
4. Discard or flag any measurement with anomalous system behavior
   (unexpected background activity, thermal throttle, debugger artifacts).
5. Extract Evidence records (NE-E-{NNN}) from validated Measurements.

**Output:** Validated Evidence records, flagged anomalies.

### Step 5: Finding Extraction

**Input:** Validated Evidence records

**Actions:**
1. For each Scope dimension, extract factual statements from Evidence
   records. Each statement must be:
   - Falsifiable (could be disproven by new evidence)
   - Scoped to a specific phase
   - Backed by at least one Evidence record
2. Create Finding records (NE-F-{NNN}).
3. Cross-reference Findings with Investigation Questions (§4).
4. Flag any Investigation Question that cannot be answered with
   current Findings — these become `Unknown` Conclusions.

**Output:** Finding records, mapped to Investigation Questions.

### Step 6: Root Cause Classification

**Input:** Finding records

**Actions:**
1. For each Finding, determine the root cause using:
   - Stack trace analysis from Time Profiler
   - Code path analysis from source (read-only)
   - System behavior analysis from Console / System Trace
2. Classify each Finding using the Classification Model (§10).
3. Assign owner for each classified Finding.
4. For Findings that cannot be classified due to insufficient evidence,
   classify as `Unknown` and document what additional evidence is needed.
5. Create Conclusion records (NE-C-{NNN}).

**Output:** Conclusion records with classification and ownership.

### Step 7: Optimization Priority Matrix

**Input:** Conclusion records

**Actions:**
1. For each Conclusion classified as `Optimizable`:
   - Estimate user impact (qualitative: Low / Medium / High)
   - Estimate implementation cost (qualitative: Low / Medium / High)
   - Assign priority (P1 / P2 / P3 / P4)
2. For each Conclusion classified as `Requires Architecture` / `Requires Runtime` /
   `Requires UI` / `Requires Tooling` / `Requires Apple`:
   - Note the dependency and estimated lead time
   - Assign priority based on user impact
3. For each `Unknown`: note evidence gap and proposed resolution path.
4. Sort matrix by priority.

**Output:** Optimization Priority Matrix.

### Step 8: Native Experience Report

**Input:** All prior outputs

**Actions:**
1. Compile the Native Experience Report with all required sections.
2. Include:
   - Interaction Timeline (Mermaid sequence diagram)
   - Startup Timeline (phased breakdown with per-phase latencies)
   - Lifecycle Diagram (Mermaid state diagram)
   - Initialization Dependency Graph (Mermaid flow or graph)
   - Critical Path Analysis
   - Main-Thread Analysis
   - Bottleneck Inventory (consolidated from Findings)
   - Environment Matrix (completed)
   - Evidence Index (all NE-E records)
   - Optimization Priority Matrix
   - Future Work Recommendations
3. Define maintenance rules for the Report (update triggers, owner, review cycle).

**Output:** Native Experience Report (`docs/native-experience-report.md`).

### Step 9: Exit Verification

**Input:** Native Experience Report, Exit Criteria (§12)

**Actions:**
1. Verify every Exit Criterion is satisfied.
2. Verify every Investigation Question is answered or classified as `Unknown`
   with documented evidence gap.
3. Verify every Stop Condition (§13) that was triggered is documented.
4. Verify Handoff Targets (§14) are identified and ready.

**Output:** Exit Verification checklist (appended to Native Experience Report).

---

## 10. Classification Model

Every Finding must be assigned exactly one classification in its Conclusion.

| Classification | Definition | Example |
|---|---|---|
| **Optimizable** | Our code can be changed. Risk is acceptable. Benefit is measurable. | Reorder initialization to defer non-critical work past first paint. |
| **Requires Architecture** | Requires a design-level change to module boundaries, lifecycle contracts, or data flow. Needs an ADR. | Move RIME session creation off the main thread (requires ADR 0004 amendment). |
| **Requires Runtime** | Requires a change in RIME/librime upstream. We cannot fix it in our codebase. | librime's `initialize()` is synchronous-only. |
| **Requires UI** | Requires a change in the UI framework, rendering pipeline, or view hierarchy strategy. | Candidate bar uses UICollectionView; switching to a custom renderer would change the cost profile. |
| **Requires Tooling** | Requires new measurement or profiling infrastructure before the delay can be properly characterized. | No existing signpost covers the XPC launch-to-viewDidLoad gap. |
| **Requires Apple** | Requires an iOS API change or system behavior change. We cannot fix it. | Keyboard Extension XPC cold-launch floor is controlled by iOS. |
| **Not Optimizable** | Cost of optimization exceeds benefit, risk is unacceptable, or benefit cannot be measured. | A 2ms delay in the warm path with no user-perceivable impact. |
| **Unknown** | Evidence is insufficient to classify. Must state what additional evidence is needed. | Cannot determine whether delay is in RIME or in our wrapper without code-level instrumentation. |

---

## 11. Deliverables

All deliverables are **Knowledge Assets** designed for long-term maintenance.
None are one-time snapshots.

### D1: Native Experience Report

**Location:** `docs/native-experience-report.md`

**Owner:** Architecture & Knowledge Steward

**Version:** v1.0

**Update Trigger:**
- Major startup architecture change (new ADR affecting lifecycle or session model)
- RIME lifecycle change (upstream librime version bump, Lua/OpenCC integration change)
- iOS Keyboard Extension lifecycle change (new iOS major version)
- Significant performance regression requiring baseline update
- Completion of a NATIVE-EXPERIENCE implementation Work Item that alters measured latencies

**Contents:**
- Interaction Timeline (Mermaid sequence diagram: user taps host field → keyboard visible → first key → first candidate → first commit)
- Startup Timeline (phased breakdown: system phases + our phases, per-phase latency)
- Lifecycle Diagram (Mermaid state diagram: process states, view lifecycle, session states)
- Initialization Dependency Graph (Mermaid graph: blocking vs parallel dependencies)
- Critical Path Analysis (longest blocking chain, annotated with per-node latency)
- Main-Thread Analysis (CPU profile during cold start, warm start, typing)
- Bottleneck Inventory (all Findings, organized by phase and severity)
- Investigation Questions answered (Q1-Q8, with Finding cross-references)
- Observability Assessment summary
- Maintenance rules (update triggers, owner, review cycle)

### D2: Optimization Priority Matrix

**Location:** Appended to Native Experience Report, or as standalone
`docs/native-experience-priority-matrix.md`

**Owner:** Product Lead

**Version:** v1.0

**Update Trigger:** New Findings classified as Optimizable (P1/P2); completed implementation Work Item changing any priority row.

**Contents:**

| Finding ID | Delay Description | Magnitude | Classification | Owner | User Impact | Impl Cost | Priority |
|---|---|---|---|---|---|---|---|
| NE-F-XXX | … | X ms | Optimizable | KeyboardCore | Medium | Low | P1 |

### D3: Environment Matrix

**Location:** Appended to Native Experience Report

**Owner:** Primary Owner of NATIVE-EXPERIENCE-001

**Version:** v1.0

**Update Trigger:** New device added to test matrix; new iOS version tested.

**Contents:** Completed matrix with all measured cells, deferred cells, and reasons.

### D4: Evidence Index

**Location:** Appended to Native Experience Report, or as

**Owner:** Quality Owner of NATIVE-EXPERIENCE-001

**Version:** v1.0

**Update Trigger:** New Evidence records collected; trace file locations changed.
`docs/native-experience-evidence-index.md`

**Contents:** All NE-E records with back-references to NE-M records and trace
file locations.

### D5: Bottleneck Catalog

**Location:** Section within Native Experience Report

**Owner:** Primary Owner of NATIVE-EXPERIENCE-001

**Version:** v1.0

**Update Trigger:** New Finding classified; existing Finding reclassified after new evidence.

**Contents:** All bottleneck Findings with their Evidence chain, root cause,
classification, and owner.

### D6: Future Work Recommendations

**Location:** Section within Native Experience Report

**Owner:** Primary Owner of NATIVE-EXPERIENCE-001

**Version:** v1.0

**Update Trigger:** New follow-up Work Item proposed; existing recommendation scope changed.

**Contents:**
- Proposed follow-up Work Items (NATIVE-EXPERIENCE-002, -003, -004, -005,
  -TOOLING-001, etc.)
- For each: one-paragraph rationale, suggested scope, suggested priority
- Explicit statement: "These are recommendations only. Each requires separate
  Assignment and Approval."

---

## 12. Exit Criteria

This Investigation is complete only when **all** of the following are true:

- [ ] Every user-perceivable delay defined in Scope (§2) has been measured.
- [ ] Every measured delay has an Evidence record (NE-E-XXX) with traceable Measurement (NE-M-XXX).
- [ ] Every Evidence record has been validated (sample count ≥ 5, environment metadata complete).
- [ ] Every validated delay has a Finding (NE-F-XXX).
- [ ] Every Finding has a Conclusion (NE-C-XXX) with root cause and classification.
- [ ] No unexplained startup latency remains — every phase is either measured or classified as `Unknown` with documented evidence gap.
- [ ] The complete Interaction Timeline has been documented.
- [ ] The complete Startup Timeline has been documented with per-phase decomposition.
- [ ] Every Investigation Question (§4) has been answered or classified as `Unknown` with documented evidence gap.
- [ ] Q7 (Architecture vs Implementation) has been answered with a clear taxonomy.
- [ ] Q8 (Optimization Value) has been answered with a per-delay classification.
- [ ] The Optimization Priority Matrix is complete and sorted.
- [ ] Future Work Recommendations are documented.
- [ ] The Native Experience Report is published with maintenance rules.
- [ ] All raw trace files are preserved and referenced in the Evidence Index.
- [ ] Every Finding can be traced backward to exactly one Measurement record through its Evidence chain.
- [ ] Every Conclusion has been classified using the Classification Model (§10) — no Conclusion remains unclassified.

---

## 13. Stop Conditions

The Investigation must pause or escalate when any of the following occur:

**SC1 — Observability Blocked.** The Observability Assessment (§9 Step 1) concludes
that existing tools are insufficient for ≥ 50% of Scope items. Pause and recommend
a separate Tooling Work Item.

**SC2 — Environment Unavailable.** A required device (e.g., Primary Baseline physical
device) is not accessible. Document the gap and either select an alternative or pause.

**SC3 — Classification Impasse.** A Finding cannot be classified even as `Unknown`
because the question itself is ill-posed. Escalate to Product Lead for scope
clarification.

**SC4 — Scope Drift.** The Investigation begins to slide into implementation
discussions, code changes, or optimization proposals. Stop and re-scope to
Investigation only.

**SC5 — Evidence Contamination.** A measurement is discovered to have been taken
in a contaminated environment (e.g., debugger attached when Release behavior was
intended, unexpected system load, wrong schema configuration). Flag the
measurement, document the contamination, and re-collect.

**SC6 — Unsafe Assumption.** A Finding relies on an assumption that cannot be
verified with available tools. If the assumption is material to a Conclusion,
classify as `Unknown` rather than proceeding.

---

## 14. Handoff Targets

This Work Item produces **Knowledge only**, not Code Changes.
The following are the expected downstream recipients.

### H1: Implementation Work Items

Based on the Optimization Priority Matrix, the following types of Work Item
may be created:

| Target Work Item | Trigger Classification | Suggested Scope |
|---|---|---|
| NATIVE-EXPERIENCE-002 | Optimizable (P1/P2) — Startup Pipeline | Reduce cold-start latency through initialization reordering, lazy loading, deferred work |
| NATIVE-EXPERIENCE-003 | Optimizable / Requires UI — Rendering & Animation | Reduce UI thread blocking during keyboard presentation, first paint, page transitions |
| NATIVE-EXPERIENCE-004 | Optimizable — Lifecycle & Memory | Reduce warm-start overhead, optimize session reuse, reduce memory growth |
| NATIVE-EXPERIENCE-005 | All classifications — Continuous Guard | Establish CI regression guard for Native Experience metrics |
| NATIVE-EXPERIENCE-TOOLING-001 | Requires Tooling | Build measurement infrastructure (signpost hooks, profiling build config, CI integration) |

**Each of these requires:**
- Separate Assignment per `ASSIGNMENT_POLICY.md`
- Separate Approval
- Explicit scope, non-goals, and exit criteria

### H2: Architecture Decision Records

Findings classified as `Requires Architecture` must be handed off to the
Architecture & Knowledge Steward for ADR consideration:

- ADR 0004 (Session Model) — if main-thread RIME session creation is identified
  as a significant bottleneck
- ADR 0002 (Visibility Cleanup) — if warm-start session recreation is identified
  as wasteful
- New ADR — if the Investigation reveals an architectural constraint not covered
  by existing ADRs

### H3: RIME Upstream

Findings classified as `Requires Runtime` must be documented with sufficient
detail for the RIME community or librime maintainers:

- Specific librime API call and its observed cost
- Reproducible measurement data
- Suggested improvement (if identifiable)

### H4: Product Lead

The complete Native Experience Report and Optimization Priority Matrix must be
handed off to Product Lead for:

- Prioritization of follow-up Work Items
- Decision on which P3/P4 items to defer
- Decision on whether `Requires Apple` items warrant a Radar or Feedback Assistant submission

---

### Governance Rule

**No output of NATIVE-EXPERIENCE-001 may directly modify production code.**

All implementation — including instrumentation, profiling hooks, startup
reordering, lifecycle changes, UI optimization, and build configuration
changes — must be received through a separate, independently assigned
Work Item.

NATIVE-EXPERIENCE-001 produces Knowledge only. Implementation is always
decoupled and gated by `docs/ASSIGNMENT_POLICY.md`.

---

## Appendix A: Document Maintenance

**Owner:** To be assigned (Executor of NATIVE-EXPERIENCE-001)

**Initial Freeze Date:** 2026-07-08

**Current Version:** v1.0

**Current Owner:** To be assigned per `docs/ASSIGNMENT_POLICY.md`

**Next Review Trigger:** Investigation completion (Exit Criteria met). Thereafter,
per Native Experience Report maintenance rules. No amendment between Freeze
and Exit unless a Stop Condition (§13) triggers a protocol change.

**Review Cycle:** At Investigation completion; then per Native Experience Report
maintenance rules.

**Amendment Process:** Any change to this Protocol after Freeze requires:
1. Document the proposed change with rationale
2. Obtain Product Lead or Architecture & Knowledge Steward approval
3. Update this document with amendment date and summary

**Related Documents:**
- `docs/PERFORMANCE_BASELINE.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
- `docs/architecture/decisions/0002-visibility-change-abandons-composition.md`
- `docs/architecture/decisions/0004-rime-runtime-session-model.md`
- `docs/PROJECT_CONTEXT.md`
- `docs/ASSIGNMENT_POLICY.md`
