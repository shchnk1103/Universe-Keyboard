# Assignment: KEYBOARD-COMPACT-HEADER-001 — Compact Header & Candidate Bar

Policy version: 1.0.0
record_id: KEYBOARD-COMPACT-HEADER-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | UI-1 local candidate; UI-2 deferred pending real Extension evidence |
| Writer / pending handoff | codex-compact-header / none; canonical W/P derived from carrier log |
| Next decision | Human assigns independent review or a new bounded runtime step; no product publication |

## Authority and responsibilities

Human Product Lead, current Codex chat, 2026-10-20 Asia/Shanghai, explicitly authorized this task and named current Codex lane initial Writer. [AUTH](../authorizations/AUTH-KEYBOARD-COMPACT-HEADER-001.md) records that instruction, not an agent-issued grant.

- Domain Owner / Executor / initial Writer: current Codex lane `codex-compact-header`, bounded Keyboard UIKit presentation; permanent ownership unchanged.
- Environment Executor: same Codex lane on this Mac; task-owned Simulator and build outputs only.
- Product Approver / Human Dependency: Human Product Lead; subsequent acceptance, reviewer assignment, external product publication and scope changes.
- Architecture / Quality Review: subsequent independent review, not assigned or claimed by this implementation; Human owns assigning reviewers before that stage.

## Task Workspace opt-in

Uses `ops/task-workspace.md` at Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5`, sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`, under UK-007. No F-01/L-01 adoption or historical migration.
Carrier: `codex/keyboard-compact-header-001`. Human named initial Writer; first CHECKPOINT establishes W without fabricated HANDOFF/ACCEPT. Only initialization docs may be pushed. Product and descendant checkpoints remain local; a future handoff requires separately authorized safe synchronization.

## Baseline and scope

Actual remote main verified 2026-10-20: `096183ca118cc40ffc16854d1a5336a42cfcbd89`, including merged PRs #213/#214/#215. Independent managed worktree `compact-header-001`, branch above. Shared dirty main and all historical worktrees/backups are protected.

UI-1: local semantic UIKit design tokens; 46pt total compact bar/cell (48pt fallback only for observed clipping/touch/layout issues); unchanged candidate fonts and expanded-cell height; 56pt full-trailing action zone, 22pt medium symbols, bounded hits, clipped viewport, stable material/reduce-transparency fallback; unchanged dual-mode and recovery semantics.
UI-2, after UI-1 preliminary validation: existing snapshot paths drive 0/34pt T9 row; coordinate root height/bottom anchoring without shrinking keys. No second input state machine. Retain UI-1 and revert only task-owned UI-2 edits if host/coordinate verification fails.

Protected: RIME session, recovery/Partial Commit state machines, candidateOrigin/authority/native select, owner/session/epoch/revision, R174 default-off. No product push/PR/merge/TestFlight, historical task/worktree/device modifications or cleanup.

## Stage plan and evidence

1. Authority commit, initial BRIEF/CHECKPOINT, docs-only carrier push, verify W/P/H/S before source edits.
2. UI-1 source and directly related behavioral UIKit tests; initial format/build/tests before UI-2.
3. UI-2 bounded presentation implementation only if feasible; task-owned real Extension measurement for idle/input/delete/retype/select/layout switch/wake; keys target 0–2pt screen-center variation. If unavailable or unstable, do not claim UI-2 completion.
4. Final strict format, actual UIKit/Keyboard target tests, necessary Core regression, Debug build-for-testing and Release build. Distinguish hostless UIKit, real Extension, visual, physical-device and skipped coverage.
5. Update only affected UI docs/CHANGELOG/evidence, local product commit, local CHECKPOINT, report and stop.

Entry: exact merged baseline, isolated clean worktree, valid Human authorization, unique Writer from initialized remote carrier.
Stop: Writer conflict/rejection, required Core reliability changes, unexplained input regression/touch conflict/host layout behavior. UI-2 instability stops UI-2 only, retaining verified UI-1. No independent Gate or mergeability claim from self-checks.
Revalidation: baseline/scope/contract/ownership changes, AUTH revoked, second Writer, evidence identity changes.

## Local delivery disposition

UI-1 delivered locally with [verification](../evidence/keyboard-compact-header-001/verification.md) and source hashes. UI-2 prototype withdrawn under authorized fallback because real Extension activation/coordinate evidence was not established; fixed 34pt reservation remains. No host-stability failure inferred. W=codex-compact-header, P=none. No reviewer assigned, HANDOFF, Gate, Closeout or product publication. Stop for Human after final local checkpoint.

## Targeted correction stage

Human authorization in the current chat supersedes CP-002's stop only for A1/A3 and explicitly allowed cleanup/testing/records; see the appended AUTH. Claude Architecture/Quality Partial are Human-relayed results, not newly performed reviews. Same W/P, carrier, worktree and protected boundaries. The stage is L1 directed reproduction and corrections, then L2 affected targets/Debug test build, local candidate/checkpoint and stop. Independent re-review remains Human-owned.
