# Assignment: KEYBOARD-COMPACT-HEADER-001 — Compact Header & Candidate Bar

Policy version: 1.0.0
record_id: KEYBOARD-COMPACT-HEADER-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | V7–V10 local visual candidate; awaiting Human device comparison; UI-2 untouched |
| Writer / pending handoff | codex-compact-header / none; canonical W/P derived from carrier log |
| Next decision | Human reviews local visual diff and real-iPhone appearance; no new product publication authorized |

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

Targeted correction delivery: local product `e21d076cc6615b2601059df98a3a435bff41019d`; L1 18/0/0, L2 Keyboard49/0/0 + Extension40/0/0, Debug test build and strict Swift Pass. Evidence appended to existing verification. Stop for Human / Claude targeted re-review; no independent acceptance claim. W unchanged, P=none.

Final targeted delivery: product `5ca35456a86c7de9f0e99fce84ad11d7225bf60c`; N2 full surface-top panel/content with independently aligned action, N1 exact-prefix log reconciliation (three requested plus l1-final-r2). Focused12/0/0, strict format exit0, test compilation Pass. Human relayed Architecture/Quality Pass for prior candidate; this final diff awaits review. No activated Extension claim, no publication; W unchanged/P=none, stop.

Visual-polish delivery: local product `86df674649b590667c09db30194f10eb2c97baa6` on top of published PR216 head ddcd81c; same Writer/P=none. Human reports six prior iPhone interactions accepted; latest visuals not yet device-accepted. V1 measured/no height change; V2/V3/V5/V6 material/icon/corner cleanup; V4 original-path-preserving overlay with fixed34pt residual explicitly recorded. L1 20/0/0; Keyboard49/0/0 + Extension41/0/0; final Controller3/0/0, strict5/Debug compile Pass. Combined initial L2 run exit65 from exact floating-point size assertion remains failed; corrected directed run passes. Evidence: existing verification plus visual-polish-evidence.json. Stop; no Push, remote PR update, merge, release, task closure or UI-2 edits.

Continuous surface delivery: local product `a415f59945412969e18d7c1f3992b160e922bfbb` on top of visual86df674/CP005 bb74235. Phase A confirms UI-only feasibility; same two lists and original candidate/paging/selection identities. Partial reading anchor and bidirectional position sync, stable flow, shared surface and fixed local material, clipped reveal/interaction guard implemented. L1 27/0/0, L2 Keyboard49/0/0 + Extension41/0/0, Debug build-for-testing/strict Swift6 files Pass. One prior failed run retained (6 pixel-quantized proportion assertions; test tolerance fixed, product threshold unchanged). Human Xcode project rewrite remains unstaged/uncommitted by explicit instruction; source/config hashes and single non-Swift exclusion difference recorded. P0/P1 directed evidence, not live P2 approval. Stop; no Push/PR update/merge/release/close/handoff/UI-2 changes.

V7–V10 delivery: local product `a006e637cf22906ec45de817b156668af604f2a7`; Human reports prior five continuous-surface iPhone interactions accepted. Shared6pt leading and derived2pt first-row top eliminate measured+2/+1 text offset; shared secondaryLabel tint, single10pt tint-only ordinary blend,36pt circular expanded material inside unchanged56×46 hit area. Anchors/snapshot/paging/selection/animation/root/path/key contracts unchanged. L1 28/0/0, L2 Keyboard49/0/0 + Extension41/0/0, Debug testing build/strict16 Swift Pass. Initial old8pt assertion failures retained; current results are in-process, not new device acceptance. Evidence verification.md/v7-v10-evidence.json. Human project remains untouched/uncommitted. Same Writer/P=none; stop, no Push/PR update/merge/release/close/handoff/UI-2 edits.
