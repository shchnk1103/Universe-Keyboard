# ADR 0010: Debug-only Decision Trace & Evidence Provenance Boundary

## Status

Proposed

## Context

Typo Correction Benchmark Registry v1.0 is frozen at commit `49b000bcbb3a90d04f00dd803981a24a25b70e28`. `TYPO-BENCHMARK-004B` was accepted with implementation blockers, and `TYPO-BENCHMARK-004D` added a test-only structured Snapshot capability.

The 004D Quality Review found that the Snapshot can serialize decision and environment fields but currently receives `suppressionDecision`, `learningDecision`, build, schema, effective flags, deployment state and session state from test Fixtures. Those values describe what the Fixture claims; they do not prove what the existing decision path executed.

`TYPO-BENCHMARK-004D-A1` therefore stopped review and established one permitted architecture boundary: actual decisions may be observed through a Debug-only Decision Trace, without changing product behavior, Product Contracts, Registry semantics, candidate models, RIME ownership or Release artifacts.

This ADR freezes that observability and provenance boundary. It does not authorize `TYPO-BENCHMARK-004D-R2`, accept 004D Quality evidence, or authorize Task 7.

## Problem

An evidence record is trustworthy only when it distinguishes:

- the state a test arranged;
- the result the test expected;
- the decision the product path actually made;
- the environment in which that execution occurred;
- the Registry identity under which the evidence is interpreted.

The current test-only Snapshot mixes those categories in one caller-provided observation. A Fixture can declare `suppressedNormalTopMatchesCorrectedBest` or `topPromotion` even when no corresponding branch produced that result. Final candidate output alone cannot recover the missing cause reliably because multiple branches can produce the same visible list or position.

The architecture must make execution facts observable without moving evidence concerns into the production contract or adding privacy, persistence or hot-path risk.

## Decision

### Boundary

Debug-only Decision Trace is the only permitted provenance boundary.

The trace may observe existing decision points in non-shipping Debug or dedicated Evidence builds. It must be absent from shipping Release artifacts and must not participate in candidate generation, filtering, suppression, ranking, merge, selection or state transitions.

Test-only declaration is not sufficient for execution facts. Production/Release tracing is not permitted by this decision.

### Execution Facts

Execution facts must be emitted by the branch that made the decision:

- suppression provenance comes from the existing resolution path that compares the normal RIME top candidate with the corrected best candidate;
- learning provenance comes from the existing ranking/merge path that reads the learning snapshot and evaluates threshold, prefix, assessment and satisfaction guards;
- final candidate order, position, represented source and deduplication outcome come from the executed merge result;
- effective experimental and Partial Commit flags are observed at the decision invocation, not copied from requested settings;
- a selection count used by a learning decision is the count read by that execution, not an expected count declared by a test.

When suppression prevents ranking from executing, the trace must report that ranking was not evaluated because of the observed suppression result. It must not claim that the ranker independently produced a blocked decision.

Every trace event belongs to one bounded invocation and carries a correlation identity and deterministic sequence. The evidence assembler may translate correlated events into Snapshot fields, but it must not infer a decision from final output when the corresponding event is absent.

### Snapshot Consumption

The Snapshot must consume execution decisions from the Decision Trace. Its evidence builder must not accept caller-supplied `suppressionDecision` or `learningDecision` as execution facts.

Fixtures may provide controlled inputs, candidate/provider fixtures, learning records, requested settings and expected outcomes. Those values remain explicitly classified as Fixture Metadata or Expectations. They may be compared with execution facts, but may not populate or overwrite them.

If a required execution event is unavailable, the Snapshot reports the field as unavailable/not observed and the affected evidence remains `Blocked`. It must not substitute a Fixture value.

### Metadata Source Classification

The following classes are disjoint in the evidence schema:

| Classification | Fields / examples | Source and trust rule |
|---|---|---|
| Registry Identity | Registry version, Registry commit, Canonical Case ID | Version and commit are fixed by the accepted Registry. The harness selects a Canonical Case ID and validates that it exists. These fields identify interpretation scope; they are not execution facts. |
| Fixture Metadata / Expectations | Synthetic input, Fake Provider candidates, arranged learning records, requested flag state, expected decision, expected final position | Supplied by the test or evidence scenario. Must be labelled as declared/expected and cannot prove execution. |
| Execution Fact | Suppression result, learning/ranking result, guard result, selection count actually read, effective flags at invocation, final candidate order/position/source, deduplication result | Produced by the actual existing decision path and correlated through the Debug-only trace. Callers cannot set these fields. |
| Environment Metadata | Build commit/configuration/target, schema and artifact identity, deployment state, session state, device/OS/host, Full Access, capture time, run ID and environment-manifest digest | Obtained from build-generated values, existing runtime observation, or a separately verified environment manifest. Every value records its source. Unavailable values remain unavailable; Fixture strings cannot impersonate observed environment state. |

Registry Identity does not prove behavior. Fixture Metadata does not prove execution. Execution Facts do not prove the environment. Environment Metadata does not prove a behavior decision. A valid evidence record binds all required classes with one run/invocation correlation without merging their trust meanings.

### Environment Binding

- Build identity comes from build-generated metadata, not a handwritten Fixture value.
- Effective flags are captured at the actual decision invocation. Requested or persisted settings remain separate Fixture/Environment inputs.
- Schema, artifact and deployment identity bind to the approved environment manifest and its digest. Existing runtime observation may strengthen that binding; a declared schema name alone is insufficient.
- Session metadata may use only already observable lifecycle/session state. This ADR does not authorize a RIME Bridge or session-model change to expose additional fields.
- Each Snapshot records the run ID, invocation ID or equivalent correlation, capture time, and source classification for required metadata.
- If existing boundaries cannot provide required schema, deployment or session facts, the evidence is `Blocked` and is handed to the owning architecture/environment task.

### Release Exclusion

Decision Trace code must be guarded by a dedicated non-shipping compile condition or an equivalently enforceable target boundary:

- shipping Release targets do not compile, link, register or emit Decision Trace events;
- stale settings cannot enable the trace in Release;
- the trace is not a production feature flag;
- Release evidence cannot claim Decision Trace provenance unless a future Architecture and Product decision explicitly changes this boundary.

A Release-like optimization configuration used by an internal Evidence target remains non-shipping and must be labelled accordingly; it is not evidence that the shipping Release binary emitted the trace.

### Privacy Boundary

- Trace collection is limited to controlled synthetic Benchmark input.
- Do not collect surrounding host text, arbitrary user text, user dictionary contents or unrelated RIME data.
- Decision events should carry structured reason codes, bounded counts and correlation identifiers rather than persisted raw input or candidate payloads.
- No trace data is uploaded, written to RIME user dictionaries or treated as telemetry.
- The trace is in-memory for the bounded evidence invocation. Export, when explicitly performed by the test/evidence harness, writes only the approved synthetic Snapshot artifact.

### Hot-path Boundary

When tracing is disabled, the Release path has no observer lookup, event allocation, logging or branch controlled by runtime settings.

When tracing is enabled in a non-shipping build:

- event count and payload size are bounded per invocation;
- collection is synchronous in-memory bookkeeping only and cannot block on another executor;
- no file, App Group, database, network, deployment or schema operation occurs in the key path;
- no JSON encoding, persistence, high-frequency log flushing or unbounded candidate copying occurs in the decision path;
- Snapshot encoding/export occurs after the observed decision path completes;
- instrumentation must not change timing-sensitive ordering or mutate inputs/outputs.

### No Product Or Runtime Contract Change

This decision does not authorize:

- Product Contract or Registry changes;
- production behavior changes;
- public Runtime API or Runtime contract changes;
- Candidate Model or KeyboardState evidence fields;
- merge, ranking, suppression or selection rule changes;
- RIME Bridge, RIME session or deployment changes;
- shipping diagnostics, telemetry or Release trace support.

The implementation may add only compile-isolated internal observation seams adjacent to existing decision points. Existing product return values and state transitions remain unchanged.

## Allowed Boundary For TYPO-BENCHMARK-004D-R2

If Product Lead authorizes 004D-R2 after accepting this ADR, Input Intelligence may modify only:

- compile-isolated internal Decision Trace types and an in-memory bounded collector;
- observation calls at the existing suppression and learning/ranking/merge decision points;
- the test-only Snapshot builder so execution fields are consumed from correlated trace events;
- test/evidence target build metadata generation and test coverage proving source classification, Release exclusion, no mutation and missing-event failure;
- directly required documentation references approved for 004D-R2.

004D-R2 may not change Candidate Model, KeyboardState, product method results, decision predicates, candidate order, RIME Bridge/session behavior, Registry content, Product Contracts or Release behavior. It may not begin until this ADR is accepted by Product Lead.

## Alternatives Considered

### Keep all provenance Test-only

Rejected. A test can arrange inputs and compare outputs but cannot reliably prove which internal branch caused an identical final result. Caller-supplied decision fields remain Fixture Metadata.

### Add Decision Trace to the shipping Runtime

Rejected. Production tracing creates unnecessary API, privacy, hot-path and Release-governance surface. Current evidence needs do not justify a production boundary change.

### Add decision fields to Candidate Model or KeyboardState

Rejected. Evidence provenance is not product state. Adding it would couple diagnostic identity to candidate behavior and create a Runtime contract change.

### Infer provenance from final candidate output

Rejected. Suppression, filtering, stable promotion, learned promotion and missing candidates can converge on indistinguishable final lists or positions.

### Declare Decision Provenance unavailable

Rejected. Existing decision points can emit bounded non-shipping observations without changing their behavior.

## Consequences

- Quality can distinguish executed decisions from arranged expectations.
- Snapshot schema and tests must preserve source classification instead of accepting a flat caller-declared observation.
- Some environment fields may remain blocked until a verified environment manifest or existing observation supplies them.
- Internal Debug/Evidence builds gain bounded observation code; shipping Release remains unchanged.
- 004D-R2 requires focused tests for event correlation, missing events, Release exclusion, privacy and no behavioral mutation.
- This ADR does not make 004D evidence accepted and does not satisfy Real RIME, physical-device, Release-baseline or Task 7 Entry Criteria.

## Risks

- Instrumentation could accidentally become part of Release or be enabled by stale settings.
- Observation code could perturb the key path or allocate unbounded payloads.
- An evidence assembler could silently fall back to Fixture values when trace events are missing.
- Environment declarations could be mislabeled as runtime observation.
- Raw synthetic candidates could expand into collection of live user data in a future change.
- Correlation errors could bind a decision event to the wrong Snapshot.

Mitigations are compile-time Release exclusion, bounded in-memory events, explicit source classification, fail-closed missing-event behavior, synthetic-only evidence, correlation tests and Quality review.

## Stop Conditions

Stop 004D-R2 and return to Architecture Review if implementation requires:

- a public Runtime API or Runtime contract change;
- Candidate Model, KeyboardState, merge, ranking or suppression predicate changes;
- RIME Bridge, deployment or session changes;
- persistence, network, App Group access, blocking work or unbounded collection in the key path;
- trace availability in a shipping Release target;
- environment facts that existing observation or an approved manifest cannot supply;
- collection outside controlled synthetic Benchmark input.

Return to Product Review if a proposed change would:

- alter Product Contract, Registry identity/semantics or Candidate Position behavior;
- enable an experimental behavior or Decision Trace in Release;
- introduce production telemetry, retention or user-data collection;
- change Task 7 authorization or evidence acceptance criteria;
- treat missing provenance as passed evidence.

Quality must stop review when an Execution Fact is caller-declared, inferred without a trace event, bound to unverifiable metadata, or substituted from Fixture Metadata.

## Cross-document Impact

This ADR is the owner of the Decision Trace and provenance boundary. Downstream documents require only minimal references:

| Consumer | Required reference after ADR acceptance | Must not duplicate or change |
|---|---|---|
| Typo Benchmark Registry | No Registry content change is required. Evidence using Registry IDs may cite this ADR for provenance. | IDs, Product Contract, Case taxonomy and coverage rules. |
| Quality / 004D review | Cite the Execution Fact, source classification, missing-event and Release-exclusion gates. | Do not copy implementation design or mark evidence passed solely because trace fields exist. |
| Performance | Cite the Hot-path Boundary when Decision Trace is used for phase attribution; measure enabled evidence builds separately. | Do not change frozen performance profiles or treat Debug/Evidence timing as shipping Release timing. |
| Engineering Dashboard | After Product acceptance, link ADR status and keep 004D/Task 7 blockers explicit. | Dashboard cannot accept the ADR, close Quality review or authorize work. |
| 004D-R2 | Treat accepted ADR 0010 as a hard prerequisite and implementation ceiling. | Do not widen scope into product behavior, RIME, Release or Registry changes. |

## Follow-up Work

- Product Lead reviews this ADR and either accepts it or returns it for revision.
- Only after acceptance may Product Lead authorize `TYPO-BENCHMARK-004D-R2`.
- 004D-R2 implements the bounded Debug-only trace and removes caller authority over execution fields.
- Quality re-reviews provenance, Release exclusion, privacy, hot-path safety and missing-event behavior.
- Environment work separately resolves schema, deployment, session and Real RIME evidence blockers.
- Task 7 remains unauthorized.

## Related Documents

- [`Typo Correction Benchmark v1.0 Registry`](../../TYPO_BENCHMARK_REGISTRY.md)
- [`ADR 0009: Typo Benchmark Registry Source of Truth`](0009-typo-benchmark-registry-source-of-truth.md)
- [`Typo Correction Benchmark`](../../TYPO_BENCHMARK.md)
- [`Performance Baseline`](../../PERFORMANCE_BASELINE.md)
- [`Engineering Dashboard`](../../ENGINEERING_DASHBOARD.md)
- [`Documentation Governance`](../../DOCUMENTATION_GOVERNANCE.md)
- [`Knowledge Dependencies`](../../KNOWLEDGE_DEPENDENCIES.md)
- [`Current 004D Snapshot capability`](../../../Packages/KeyboardCore/Tests/KeyboardCoreTests/BenchmarkEvidenceSnapshot.swift)
