# Assignment: KEYBOARD-LAYOUT-9KEY-PINYIN-003 — Path Bar 原子快照与安全预编辑

**Policy version:** `1.0.0`  
**Lifecycle status:** `Active — Automated Quality Pass; Human Product Gate failed; superseded by KEYBOARD-LAYOUT-9KEY-PINYIN-004 (not rewritten as pass)`  
**Repository change types:** `Contract`, `State`, `Implementation`, `Evidence`, `Documentation`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-003`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-003-authorization.md), `2026-07-22 Asia/Shanghai`
- **Product Approver:** Human Product Owner under KOS 2.0

## Boundary

### Scope

1. Establish privacy-safe, action-correlated diagnostics for Path Bar bridge work and presentation revisions.
2. Replace click-time spelling-scaled live-RIME probing with a fixed-foreground-cost discovery/refinement contract proven by a RimeBridge Spike.
3. Make marked text, candidates and Path Bar state publish from one coherent T9 composition revision.
4. Introduce one validated host-visible preedit boundary that distinguishes internal T9 identity from explicit user numeric input.
5. Add targeted KeyboardCore, RimeBridge and Keyboard UI/contract coverage for the reported sequences and adjacent rollback/Delete behavior.
6. Produce a physical-device handoff for iPhone 13 Pro; do not claim the Product Gate from automated evidence.

### Non-goals

- Product changes outside [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-003`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-003-authorization.md)
- 26-key, keyboard chrome, settings, deployment, vendor, schema or unrelated feature refactors
- Static pronunciation sources, second candidate engines or arbitrary background librime calls without a new Product/Architecture decision
- Full unrelated test-suite execution
- External publication, push, PR, release or risk acceptance

### Required Inputs

- `AGENTS.md`, `KNOWLEDGE_INDEX.md`, applicable Reading Maps and playbooks
- Product Decision `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-003`
- ADR 0004, ADR 0021 and proposed [`ADR 0022`](../architecture/decisions/0022-t9-atomic-presentation-and-bounded-path-discovery.md)
- Current `101b889` merged `002` implementation and the user-provided synthetic reproductions
- `PERFORMANCE_BASELINE.md`, input-pipeline and Partial Commit contracts

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor:** Codex — bounded implementation and documentation
- **Environment Executor:** Codex — targeted local/Simulator commands and non-private diagnostics only
- **Human Dependency:** Human Product Owner — iPhone 13 Pro interaction/performance Product Gate
- **Architecture Reviewer:** Codex acting under 🏛️ Architecture & Knowledge Steward rules; decision evidence must remain separate from implementation claims
- **Quality Reviewer:** dedicated Quality subagent acting under 🧪 Quality, Performance & Release rules; automated conclusions do not close Product Gate
- **Supporting domains:** 🔧 RIME Platform Maintainer and ⌨️ Keyboard Experience Maintainer within their respective file/state boundaries

## Gates

### Entry Criteria

- Assignment contains no `UNKNOWN`.
- Product behavior, non-goals and human gate are recorded.
- Worktree baseline and predecessor status are known.

### Phase Gates

| Phase | Required exit evidence |
|---|---|
| 1 — Diagnosis | Call-count/timeline evidence locates the foreground probe and stale revision boundaries |
| 2 — Architecture Spike | Fixed foreground bridge bound, session safety and rollback strategy reviewed |
| 3 — Core/RIME implementation | Focused state, call-count and digit-safety tests pass |
| 4 — UI contract | UIKit renders one revision and discards stale results; targeted contract tests pass |
| 5 — Quality handoff | Targeted matrix, skipped checks and residual risks recorded |
| Product Gate | Human iPhone 13 Pro replay and performance judgment recorded |

### Exit Criteria

- No foreground loop scales with the 48-spelling probe budget during a Path Bar tap.
- Candidate, marked-text and Path Bar snapshots cannot cross revisions.
- Internal T9 digits cannot reach the marked-text client through any audited path.
- Explicit user numeric input remains functional.
- Targeted tests pass and the exact commands/results are recorded.
- Architecture and Quality conclusions are recorded independently.
- Human Product Gate evidence is recorded before `Closed`.

### Stop Conditions

Stop and return to Product Lead/Architecture when:

- meeting the performance requirement appears to require a static pinyin graph, second engine, schema/vendor change or unbounded scan;
- session work would move to arbitrary background threads or violate ADR 0004;
- a fix changes accepted Delete, Partial Commit, choice-source or candidate-ranking semantics;
- a required responsibility becomes `UNKNOWN` or current repository authority conflicts;
- physical-device evidence is unavailable when attempting Product Gate closure.

## Handoff

- **Current phase:** Human Product Gate failed; Product Lead authorized `KEYBOARD-LAYOUT-9KEY-PINYIN-004` as the superseding implementation track. 003 automated evidence remains historical only.
- **Handoff target:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](keyboard-layout-9key-pinyin-004.md) / ADR 0023 / Grok 4.5 Executor; do not claim 003 Product Gate pass
- **Required handoff content:** scope, revision model, bridge-call evidence, changed files, targeted commands/results, skipped checks, privacy boundary, residual risk and device matrix
- **Revalidation Trigger:** choice-source change; session/concurrency boundary change; new static data; schema/vendor change; Delete or Partial Commit semantic change; scope expansion

## Completeness Check

- Required fields present: yes
- Any `UNKNOWN`: none
- Exactly one Domain Owner: yes
- Human and environment dependencies explicit: yes
- Product, Architecture, implementation and Quality authority separated: yes
