# KOS Upgrade Record: KOS-UPGRADE-UK-002-v0.6.0

- Upstream repository: `shchnk1103/kos-agent-kit`
- From version: `v0.5.0` (advisory; pinned `e11cbfb`)
- To version: `v0.6.0`
- Release class: minor
- Checked at: `2026-09-02T18:53:00+08:00`
- Upgrade owner: Human Product Owner

## Impact assessment

- Affected contracts: `v0.6.0` adds only the optional AI orchestration package
  (`ops/agent-orchestration.md`), an adopting-project template
  (`templates/docs/ORCHESTRATION_PLAN.md`) and its design/review/evidence
  records. No frozen `core/` change; no schema or validator change; no effect on
  this project's advisory Envelope behavior or the KOS 2.2 `required` boundary.
- Adoption would only matter for workflows that will use multi-agent /
  multi-provider capability routing with the `C0–C2/H` + `E0–E3` contract. No
  current active workflow in this project needs it; the RIME background-sync
  thread does not.
- Concurrent-checkout note: the RIME thread is Active on this repository
  (`codex/rime-background-sync-crash-fix`) and is the shared writer of the
  governance/upgrade files this record touches. Per the orchestration
  package's Active-Assignment migration rule 8, adopting here now would mutate
  files under an overlapping active writer; defer until the thread freezes a
  checkpoint and merges.

## Decision

- Disposition: Deferred
- Decision source and date: Human Product Owner in-session `2026-09-02
  Asia/Shanghai`.
- Rationale: no current workflow needs the optional orchestration contract;
  adopting it now would mean editing shared governance/upgrade files while the
  RIME background-sync thread is Active in the same repository. `v0.6.0` does
  not change any obligation Universe Keyboard already has under `v0.5.0`
  advisory.
- Deferred-until: re-review when (a) the RIME thread reaches a frozen
  checkpoint / merges, and (b) any workflow will actually use multi-agent or
  multi-provider orchestration. At that point adopt for new Assignments under
  the adopted default; existing Active Assignments remain pinned and are never
  retroactively migrated.

## Evidence

- Release notes: https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.6.0
- Kit-side review closure: `KOS-AGENT-ORCH-001` (Architecture/Quality Pass;
  merged via PR #4 at `3849b26`; published at `a16c932`, tag `v0.6.0`).
- Residual: none new. Universe Keyboard keeps its `v0.5.0` advisory pin until a
  later upgrade review.
