# ADR 0011: Local Typing Intelligence Data Boundary

## Status

Accepted; implementation pending

## Context

Universe Keyboard needs useful typing statistics in the main App while the actual commits occur inside a resource-constrained Keyboard Extension. The Extension and main App are separate processes, shared writes depend on Full Access, and keyboard text is highly sensitive.

The existing input pipeline has multiple finalization forms. Some final commits call `insertText`; others replace marked text and call `unmarkText`. Emoji currently has a UIKit-level direct insertion path. Observing RIME output, candidate selection or `TextInputClient.insertText` alone would therefore be incomplete or coupled to the wrong subsystem.

The feature also needs retention, deletion and future schema evolution without adding synchronous persistence to key handling or weakening the existing RIME, candidate and keyboard-lifecycle boundaries.

## Decision

### Collection Boundary

KeyboardCore owns a UI-independent final-commit observation contract. A committed-text event is emitted exactly once only after the controller has selected the final text that will leave composition.

The observation is attached to final commit exits, including both direct insertion and marked-text finalization. It is not attached to:

- RIME processing or output;
- candidate generation, merge or ranking;
- preedit/marked-text updates;
- unfinished composition;
- keyboard visibility callbacks;
- surrounding-text inspection.

Callers supply bounded source metadata only when required to distinguish approved aggregate paths. Source metadata must not contain candidate text, raw input or host identity.

UIKit direct commits such as Emoji must route through the same committed-text contract or an equivalent single final-commit API so the event cannot diverge from host insertion.

### Ephemeral Classification

The Extension classifies the committed string immediately into Product-approved aggregate counters using Swift extended grapheme clusters. The original string is not placed in the persistent event model and is discarded after classification.

Classification is deterministic, locale-independent where practical and covered by synthetic tests. Ambiguous graphemes fall into a bounded `other` aggregate instead of preserving content.

### Process And Ownership Model

- KeyboardCore defines commit observation and pure classification contracts.
- Keyboard Extension owns runtime aggregation and persistence scheduling.
- App & Data Operations owns the versioned shared-store implementation and main-App read/reset APIs.
- Main App reads aggregate snapshots and initiates explicit settings/reset operations.
- RIME directories and user dictionaries do not participate.

The main App is not a concurrent statistics writer during ordinary operation. Reset uses a monotonically increasing epoch. Extension work carrying an older epoch is discarded, preventing an asynchronous write from resurrecting cleared data.

### Storage Model

V1 uses a bounded, versioned App Group aggregate payload with an explicit storage protocol. The production backend may use App Group `UserDefaults` only if implementation evidence proves:

- payload size remains bounded;
- writes occur off the key path on one ordered utility executor;
- write coalescing limits cross-process/defaults traffic;
- decode failure recovers to a safe empty state;
- reset epoch prevents stale resurrection;
- schema migration is deterministic and tested.

SwiftData is not the V1 cross-process authority. Its model-container startup, migration and multi-process coordination would add complexity without providing value for a small bounded aggregate. SQLite may replace the backend in a future accepted ADR if query scale or concurrency requirements exceed the V1 protocol; callers must remain backend-independent.

### Hot-Path Contract

The final-commit path may perform only bounded in-memory classification and enqueue/merge work. It must not synchronously:

- read or write `UserDefaults`;
- encode/decode the full snapshot;
- open, migrate or checkpoint a database;
- scan, hash or copy files;
- wait for another executor;
- log committed content.

Persistence is coalesced and best-effort. Statistics may lose a bounded, documented unflushed delta when the Extension process is terminated. Typing correctness takes precedence over statistical durability.

### Lifecycle And Capability Contract

Statistics collection is not initialized by changing keyboard visibility or RIME session semantics. The writer is process-owned, lazily available and independently disposable. Process death loses in-memory state and a new process resumes from the last valid aggregate snapshot.

Without writable App Group access, collection enters an unavailable/paused state and avoids repeated persistence attempts. Basic typing continues. Capability observations must not be converted into an invented authoritative Full Access flag.

### Privacy And Network Contract

Only the fields accepted by `docs/TYPING_INTELLIGENCE.md` may be persisted. No keyboard-derived event or aggregate is uploaded, synchronized, shared with analytics/advertising SDKs or stored in RIME data.

Diagnostics may record bounded reason codes and store health, but never committed text, candidate text, category sequences or per-commit timestamps.

### Extensibility Contract

Storage and presentation consume versioned aggregate snapshots, not implementation-specific persistence objects. New dimensions require Product and privacy review. Schema versions are forward-detectable; unsupported future versions fail safely without destructive downgrade.

## Alternatives Considered

### Observe `TextInputClient.insertText`

Rejected because marked-text finalization can commit through `setMarkedText` plus `unmarkText`, producing undercounting and coupling statistics to a proxy implementation detail.

### Observe RIME Or Candidate Selection

Rejected because direct English, symbols, Emoji, Return and other commits do not all originate there. It would also violate the requirement to preserve RIME and candidate-generation boundaries.

### Persist Per-Commit Events

Rejected because an event log increases privacy risk, storage growth, reconstruction potential and write amplification without being necessary for approved insights.

### Shared SwiftData Store

Rejected for V1 because the feature does not need object graphs and the Extension/main-App multi-process lifecycle, migration and startup behavior would require additional evidence and operational complexity.

### Synchronous Durability On Every Commit

Rejected because keyboard latency and availability are more important than exact persistence of the final unflushed delta.

### Main-App-Only Statistics

Rejected because the main App does not observe Extension commits and cannot reconstruct them honestly.

## Consequences

- KeyboardCore gains a narrow commit-observation contract but no persistence dependency.
- Extension wiring gains bounded runtime-owned aggregation without changing visibility semantics.
- Main App receives only aggregates and cannot inspect typed content.
- V1 statistics are approximate across sudden process termination by an explicitly bounded unflushed delta.
- Full Access affects shared statistics availability but not basic typing.
- Any future content-level intelligence requires a new Product Decision and ADR.

## Risks

- Missing a final commit exit would undercount; exactly-once tests must enumerate every path.
- Duplicate observation around marked-text replacement would overcount.
- Unicode category classification contains ambiguous graphemes; `other` must remain content-free.
- `UserDefaults` payload or cross-process behavior may prove unsuitable during implementation evidence, requiring a backend change under this protocol.
- Extension termination can discard a bounded pending delta.
- Privacy copy, App Store declarations and implementation can drift unless release review compares all three.

## Follow-up Work

- Implement TYPING-INTELLIGENCE-001 work packages and verification matrix.
- Establish a pre-feature performance baseline before enabling production collection.
- Add valid privacy manifests based on the final API inventory.
- Add physical-device Full Access and process-death evidence.
- Reassess the backend before adding dimensions beyond bounded daily aggregates.

## Related Documents

- `docs/TYPING_INTELLIGENCE.md`
- `docs/assignments/typing-intelligence-001.md`
- `docs/plans/typing-intelligence-001-implementation-plan.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/architecture/decisions/0003-shared-container-ownership.md`
- `docs/architecture/decisions/0007-full-access-and-privacy-boundary.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/RELEASE_CHECKLIST.md`
