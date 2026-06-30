# ADR 0009: Typo Benchmark Registry Source of Truth

## Status

Accepted

## Context

Typo Correction Benchmark v1.0 Contracts, Cases and Performance Evidence references are consumed by multiple evidence tasks. Keeping their definitions only in task threads would make identity, version and historical evidence mapping depend on unavailable conversation context. Copying the complete Registry into the benchmark, performance, Partial Commit and archived-plan documents would create competing owners.

The Product Lead, Input Intelligence and Quality reviewers have frozen the Registry semantics. This decision governs only repository publication, ownership, versioning and dependency direction; it does not alter those semantics or declare evidence passed.

## Decision

Publish one independent, versioned Registry at [`docs/TYPO_BENCHMARK_REGISTRY.md`](../../TYPO_BENCHMARK_REGISTRY.md).

The Registry is the sole authority for:

- `TC-CTR-*`, `TC-CASE-*` and `TC-PERF::*` identity;
- Primary and secondary reference relationships;
- lifecycle, alias, deprecation and supersession rules;
- Registry version and Task alignment.

Domain documents retain their existing responsibilities and link to the Registry instead of copying it. `TYPO_BENCHMARK.md` explains behavior, `PERFORMANCE_BASELINE.md` owns measurement procedure, and `architecture/partial-commit.md` owns Partial Commit architecture. Archived plans and historical evidence may map to Canonical IDs but never become current authority.

## Alternatives Considered

### Keep the Registry inside `TYPO_BENCHMARK.md`

Rejected because that document already combines behavior explanation, benchmark examples and historical validation context. Adding governance and performance identity would further mix responsibilities.

### Split Contract, Case and Performance Registries into separate files

Rejected for v1.0 because the three namespaces share one version and require atomic relationship validation. Separate owners or versions would make cross-layer drift more likely.

### Keep task-thread deliverables as the authority

Rejected because thread history is not a repository Source of Truth and cannot provide long-term knowledge continuity.

## Consequences

- New evidence has one stable Canonical reference system.
- Navigation and domain documents require small links to the Registry.
- Registry changes require explicit version and lifecycle review.
- Product behavior, implementation and evidence status remain outside this ADR.
- A larger Registry is accepted in exchange for atomic versioning; future physical splitting requires a superseding ADR or a compatible structural amendment that preserves one logical authority.

## Risks

- Authors may duplicate full Registry rows in downstream documents instead of linking.
- Historical aliases may be mistaken for current evidence identifiers.
- Publishing IDs may be misread as evidence acceptance.
- Manual references can drift without structural ID and link checks.

These risks are controlled by the Registry change procedure, Canonical-only new evidence, explicit evidence-status boundaries and documentation health checks.

## Follow-up Work

- Use the Registry in the approved observability and Real RIME environment-freeze tasks.
- Add Registry-aware structural validation when implementation scope is separately approved.
- Do not start Task 7 until all non-document Entry Criteria are accepted.

## Related Documents

- [`Typo Correction Benchmark v1.0 Registry`](../../TYPO_BENCHMARK_REGISTRY.md)
- [`Typo Correction Benchmark`](../../TYPO_BENCHMARK.md)
- [`Performance Baseline`](../../PERFORMANCE_BASELINE.md)
- [`Partial Commit Architecture`](../partial-commit.md)
- [`Documentation Governance`](../../DOCUMENTATION_GOVERNANCE.md)
- [`Knowledge Dependencies`](../../KNOWLEDGE_DEPENDENCIES.md)
