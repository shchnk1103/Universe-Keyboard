# Assignment: T9-RESPONSIVE-PIPELINE-001 / CANARY-001
# Default-off production-shaped responsive RIME canary

Policy version: 1.0.0

Lifecycle status: **Active — DEVICE-001 authorized; device execution awaits child Assignment dual review and immutable run freeze**

Date: 2026-08-03 Asia/Shanghai

## Authority

- Assignment Authority: **Product Lead**
- Decision Source / Date: Human Product Owner authorization in the active Codex task,
  `授权`, following the bounded P2-PERF-03 takeover recommendation, 2026-08-03
  Asia/Shanghai; followed by the explicit Product Lead instruction that the
  current Codex primary agent shall complete task-level responsibility
  assignment and delegate independent or parallel work to subagents where
  appropriate, 2026-08-03 Asia/Shanghai; followed by `请你按照你刚才的建议继续吧`,
  explicitly activating the bounded design/evidence-freeze phase, 2026-08-03
  Asia/Shanghai; followed by `激活 CANARY-001 implementation phase，并允许按冻结
  allowlist 修改代码。`, explicitly activating implementation under the frozen
  allowlist, 2026-08-03 Asia/Shanghai
  ; followed by `激活 CANARY-001 bounded build/test evidence phase`, explicitly
  authorizing the frozen local build/automated-test matrix and Simulator while
  retaining all physical-device, production, destructive-data and publication
  prohibitions, 2026-08-03 Asia/Shanghai; followed by `那你先修好这条证据链吧，
  争取一次就修好！`, explicitly authorizing a QEF-01 provenance-repair freeze
  and a bounded formal rerun while retaining the same prohibitions, 2026-08-04
  Asia/Shanghai. v7 and v8 were rejected during pre-run review and never
  executed; run001 terminally stopped on the sandbox-denied C02 preflight;
  `继续吧，不要过度发散` authorized one new bounded one-shot identity,
  CANARY001V9-20260804-002, without scope expansion; followed by `很好，继续吧，
  不要太发散，有些不必要的测试可以不用运行`, authorizing the narrow continuation
  after run003 while retaining the frozen matrix boundary, 2026-08-04 Asia/Shanghai
  ; followed by `我授权你，接下来就在我的iPhone 13 Pro上进行测试吧！`,
  explicitly activating the separately governed iPhone 13 Pro physical-device
  phase, 2026-08-04 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent Product Decision:
  [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md)
- Parent Assignment:
  [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)
- Architecture boundary:
  [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed**; ordinary production behavior remains governed by
  [`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)

The initial authorization covered responsibility assignment, this Assignment
Record and independent read-only design review. The implementation activation
authorized changes only inside the frozen allowlist. The subsequent bounded
build/test activation authorized the frozen local build/automated-test matrix
and Simulator test installation only; physical-device work, ordinary gate
changes, production rollout, ADR 0025 acceptance and Product Gate remain closed.

## Current phase and repository change type

- Current Phase: **DEVICE-001 assigned; internal control-entry and device-run freeze under review**
- Current Repository Change Type: **`Runtime` + `Tests` + bounded `Contract` /
  `Documentation`**
- Evidence execution: **v6 retained as diagnostic evidence; v7 and v8 rejected
  pre-run and never executed; run001 reviews reported Architecture and Quality
  P0/P1 = 0 and approval was recorded. C02V9 then exited 1 before
  manifest compilation because the managed sandbox denied Swift/Clang module
  cache output. The one-shot chain correctly made that failure terminal; no
  retry or later command ran. Those artifacts are preserved under
  `evidence/CANARY-001-v9-run001-terminal`. Run002 uses a fresh runID/token and
  a clean one-shot root; its matrix and scope are otherwise unchanged. Run002
  resolved the sandbox problem and C02 executed 906 XCTest tests with zero
  failures, but Swift 6.4 emitted only a separate zero-test
  `-swift-testing.xml` rather than the requested XCTest xunit file. The runner
  therefore returned 96 for missing frozen evidence and stopped the chain;
  C03V9-P05V9 were not run**.
  Run002 is preserved under `evidence/CANARY-001-v9-run002-terminal`.
  Run003 removed the unsupported XCTest xunit requirement. C02 passed at 906/0;
  C03 then passed its 9 selected tests, but the evidence capture rejected the
  valid `Selected tests passed` aggregate because it accepted only `All tests`.
  The chain stopped and is preserved under
  `evidence/CANARY-001-v9-run003-terminal`. Run004 accepts exactly XCTest's
  `All tests` or `Selected tests` aggregate, still requiring a non-empty pass
  with zero failures/unexpected results; no product code or test scope was added.
  Simulator test installation remains allowed; logs beyond command/test output,
  physical-device actions and production-shaped manual input remain closed.

## Product objective

Determine whether the responsive thread-affine direction can exist in a
production-shaped internal canary while preserving a mechanically enforceable
safe fallback to the current ADR 0004 path.

The canary question is deliberately narrower than shipping:

> Can one real RIME session owner, behind a default-off enable gate and an
> independent explicit kill-switch, preserve ordered input, lifecycle safety,
> privacy and auditable presentation while remaining safely removable?

P2-PERF-03 supplies enough bounded direction evidence to ask this question. It
does not answer it and does not provide a performance SLO.

## Boundary

### Scope proposed for later Assignment Decision

Once all responsibilities are explicitly assigned, acknowledged and the Entry
Criteria are satisfied, this Assignment may authorize these staged outputs:

1. Freeze the production-shaped canary design before implementation:
   default-off enablement, independent kill-switch, one-owner session
   exclusivity, lifecycle transition, bounded mailbox, fail-closed behavior and
   content-free evidence contract.
2. Implement the smallest internal-only canary path that exercises the real
   RIME owner and the actual Extension lifecycle without changing ordinary
   Release defaults or adding a user-facing setting.
3. Validate gate-off equivalence, owner isolation, FIFO/no-drop behavior,
   epoch/revision rejection, kill-switch transitions, presentation terminal
   receipts, privacy and restore through automated and target-level evidence.
4. Prepare a separately activatable physical-device evidence phase. That phase
   remains closed until Product Lead explicitly authorizes it and its named
   Environment Executor and Human Dependency acknowledge readiness.
5. Produce independent Architecture and Quality reviews, then return the
   bounded result and residual risks to Product Lead.

The smallest safe implementation is determined by the Architecture design
freeze. A `processKey`-only production-shaped wire is not acceptable if any
other reachable session API can concurrently access the same live RIME session.
The design must either route every reachable session API through the same owner
or make an unrouted action explicitly unavailable/fail-closed while the canary
owns the session.

### Non-goals

- No Release default-on, user-facing toggle, staged rollout, analytics cohort or
  external user experiment.
- No Product Gate, R6, shipping decision, App Store claim or ADR 0025 acceptance.
- No auto-anchor expansion, Lua/schema behavior change, candidate policy change
  or new product SLO.
- No dropped, merged or reordered accepted session action.
- No parallel MainActor/owner-thread escape hatch into the same live RIME
  session and no `@unchecked Sendable` isolation bypass.
- No raw input, pinyin, candidate text, committed text, host text, screenshot or
  UI hierarchy in diagnostics or retained evidence.
- No physical-device install, device input, App Group wipe, userdb reset, host-data
  deletion or other destructive/environment action under the current
  pre-`Ready` state.

## Assignment

- Domain Owner: **🔧 RIME Platform Maintainer** — single primary task-level
  owner for live RIME session ownership, Swift 6 isolation and the RimeBridge
  boundary; this Assignment does not transfer permanent ownership
- Executor: **Current Codex primary agent `/root`, acting as the task-level RIME
  Platform Executor** — accountable for the in-scope handoff and allowed to
  delegate bounded implementation/evidence subtasks without transferring
  Executor responsibility
- Environment Executor: **Current Codex primary agent `/root`** — limited to
  explicitly activated, non-destructive repository, build, Simulator,
  Simulator install and content-free log operations; physical-device actions
  remain closed until the separate activation below
- Human Dependency: **Human Product Owner / Product Lead** — only for a future
  separately activated physical-device phase: authorize that phase, make the
  named device/Full Access state available and perform the frozen manual input;
  no current device action is requested
- Architecture Reviewer: **Independent Architecture & Knowledge Steward
  subagent `/root/canary_arch_review`** — must not implement or perform Quality
  acceptance
- Quality Reviewer: **Independent Quality, Performance & Release Maintainer
  subagent `/root/canary_quality_review`** — must not implement, redesign the
  Architecture contract or review evidence it produced itself

### Assignment completeness disposition

The required responsibility fields are explicitly assigned by the Product Lead
instruction above. The participants required for the current Contract/read-only
phase have acknowledged Scope, Non-goals, independence and Stop Conditions.
The Architecture and Quality design freezes then passed independent cross-review
with no P0/P1. The design phase is therefore `I-Ready`, while the Assignment
was `Acknowledged` until Product Lead explicitly activated implementation. The
Assignment is now `Active`. Frozen-allowlist implementation and the run004
automated/Simulator evidence layer are complete; the separate physical-device
layer remains pre-`Ready` until Product Lead activation and Human Dependency
acknowledgement.

### Acknowledgement record

- Product Lead / Assignment authority: the Human Product Owner explicitly
  directed the current Codex primary agent to complete the task-level
  responsibility configuration and use independent subagents where appropriate.
- Domain Owner / Executor: `/root` acknowledges the RIME Platform boundary,
  Scope, Non-goals, delegation responsibility and Stop Conditions.
- Environment Executor: `/root` acknowledges only the non-destructive
  repository/Simulator boundary; no physical-device operation is acknowledged
  or active.
- Architecture Reviewer: `/root/canary_arch_review` independently acknowledged
  the Assignment after read-only review and confirmed that its review is not
  implementation, ADR 0025 acceptance, `Ready` or Product Gate.
- Quality Reviewer: `/root/canary_quality_review` independently acknowledged the
  Assignment after read-only review and confirmed that it will not implement,
  execute the environment or review evidence it produced itself.
- Human Dependency: stage-specific acknowledgement is deferred by design. It is
  required only if Product Lead separately activates the physical-device phase;
  that activation must identify the device/Full Access state and reconfirm the
  Human action before the phase can become `Ready`.

## Required inputs

- [`P2-PERF-03 Assignment`](t9-responsive-pipeline-001-p2-perf-03-replicated-ab-proposal.md)
- [`P2-PERF-03 evidence`](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md)
- [`P2-PERF-03 summary JSON`](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-summary-2026-08-03.json)
- [`P2-PERF-03 Architecture review`](t9-responsive-pipeline-001-p2-perf-03-architecture-review.md)
- [`P2-PERF-03 Quality review`](t9-responsive-pipeline-001-p2-perf-03-quality-review.md)
- [`CANARY-001 Architecture design freeze`](t9-responsive-pipeline-001-canary-001-architecture-design-freeze.md)
- [`CANARY-001 Quality evidence freeze`](t9-responsive-pipeline-001-canary-001-quality-evidence-freeze.md)
- [`CANARY-001 live-session API inventory`](t9-responsive-pipeline-001-canary-001-live-session-api-inventory.md)
- [`CANARY-001 Architecture review`](t9-responsive-pipeline-001-canary-001-architecture-review.md)
- [`CANARY-001 Quality review`](t9-responsive-pipeline-001-canary-001-quality-review.md)
- [`ADR 0025 Proposed`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
- [`ADR 0004`](../architecture/decisions/0004-rime-runtime-session-model.md)
- [`Shared container and RIME lifecycle`](../architecture/shared-container-and-rime-lifecycle.md)
- [`Input pipeline and marked text`](../architecture/input-pipeline-and-marked-text.md)
- [`Swift 6 ownership`](../architecture/swift6-migration.md)
- [`Performance baseline`](../PERFORMANCE_BASELINE.md)
- [`Environment capture procedure`](../ENVIRONMENT_CAPTURE_PROCEDURE.md)
- [`Privacy policy`](../PRIVACY_POLICY.md)
- [`Release checklist`](../RELEASE_CHECKLIST.md)
- [`RimeBridge playbook`](../playbooks/rime-bridge.md)
- [`Keyboard UI playbook`](../playbooks/keyboard-ui.md)
- [`Test / Release playbook`](../playbooks/test-release.md)

## Design and evidence freeze outputs

Detailed Architecture facts are owned by the linked Architecture design freeze;
evidence fields and classifications are owned by the linked Quality evidence
freeze; current source discovery is owned by the static API inventory. This
Assignment owns only Product scope, responsibility, lifecycle and Gate criteria.

The Product disposition for the previously ambiguous accepted-action boundary
is:

- explicit kill while the presentation remains active fences new acceptance and
  drains all already accepted FIFO work;
- an Accepted ADR 0002 visibility change may abandon unfinished composition and
  accepted work only with per-revision `abandonedVisibility` terminal receipts;
- timeout enters `FencedUnavailable` and never proves owner destruction or
  baseline takeover.

This disposition did not itself authorize implementation. The later explicit
implementation activation governs the frozen allowlist and does not change ADR
0002, ADR 0004 or ADR 0025.

## Entry Criteria

The Assignment may not enter `Ready` until all conditions hold:

1. Every participant required for the phase being activated acknowledges Scope,
   Non-goals, dependencies, independence and Stop Conditions. The physical-device
   phase additionally requires the deferred Human Dependency acknowledgement.
2. The linked Architecture and Quality freezes are cross-reviewed and have no
   unresolved P0/P1 or conflict with Accepted ADR 0002/0004.
3. Changed-file allowlists and clean restoration boundaries are frozen for the
   implementation phase; ambient worktree changes remain preserved.
4. Default-off baseline behavior and the ordinary restore artifact can be
   identified before implementation validation.
5. The Quality contract's marker/validator/privacy/geometry/restore schemas are
   versioned and fail closed on missing run-header, terminal receipt or privacy
   field; implementation-only source hashes may remain explicitly pending until
   the later evidence-capture gate.
6. Quality freezes the actual commands, destinations, comparability rules and
   capacity-observation rules before evidence collection without deriving an
   SLO from P2-PERF-03.
7. Any target, Simulator or device phase has its own discoverable environment,
   destination and permission boundary. A physical-device phase additionally
   requires a new explicit Product Lead activation recorded in this Assignment.

## Acceptance matrix

| Gate | Required proof | Current run004 classification | Blocking result |
|---|---|---|---|
| Assignment | All responsibilities assigned; current-phase acknowledgement and reviewer independence recorded | Pass for automated/Simulator; device Human Dependency not activated | Stay pre-`Ready` / `Blocked` |
| Default-off | Ordinary Release contains no compiled/reachable canary capability; internal artifact absent/invalid/pre-start-kill configuration uses ADR 0004-equivalent path | Pass: ordinary Release built; restored binaries match; internal condition absent | Any ordinary-Release reachability, implicit enablement or baseline drift |
| Kill-switch | Pre-start kill creates no canary owner; active kill fences and drains before positive destruction and baseline recovery; visibility uses its distinct ADR 0002 terminal | Partial: automated contracts pass; device runtime NotRun | Concurrent owner, silent transition or stranded accepted input |
| RIME ownership | All reachable session APIs use one owner or are explicitly fail-closed while canary owns the session | Partial: static/automated pass; external real-RIME fixture NotObserved | MainActor/background parallel session access |
| Ordering | Accepted revisions are FIFO, epoch-bound and no-drop/no-merge/no-reorder; refusal is pre-accept and reasoned | Partial: automated contracts pass; production-shaped manual runtime NotRun | Missing or reordered ACCEPT/PUBLISH |
| Presentation | Every PUBLISH has a terminal presentation receipt with auditable coalescing/failure reason | Partial: automated terminal contracts pass; manual keyboard PAINT NotRun | Unexplained PAINT gap |
| Lifecycle | Reset/recover/Delete/selection/Path/page/visibility/process teardown cannot publish stale state or duplicate host effects | Partial: automated lifecycle passes; device/host layer NotRun | Stale/duplicate/unsafe recovery |
| Capacity | Mailbox is bounded; control priority and sustained-input memory trend are observed without inventing an SLO | Partial: bounded behavior covered; sustained device load/memory trend NotRun | Unbounded growth, starvation or unexplained termination |
| Privacy | Versioned scanner passes the retained evidence scope; raw attachment and token subset conclusions remain separate | Pass for frozen 33-item publishable scope; device scope NotRun | Raw user content or scope overclaim |
| Provenance | Pre-run header, hashes, time window, Full Access, host, geometry, fixture and validator/schema versions are complete or explicitly block the run | Pass for run004 automated identity; device-only fields explicitly NotObserved | Inherited, post-hoc or missing comparability field |
| Restore | Explicit canary teardown returns to the identified ordinary package and bounded smoke; incomplete restore blocks closure | Partial: ordinary install/binary identity passes; Main App launch smoke NotRun | Unknown package/gate state |
| Independent review | Architecture and Quality publish separate verdicts and residual ledgers | Pass: Architecture 0/0/1/0; Quality 0/0/3/0 | Missing independence or unresolved P0/P1 |

No fixed test count, latency budget or device list is frozen here. The Quality
Reviewer must define comparable commands, destinations and any quantitative
decision rule before evidence collection; this Assignment must not invent them
from the P2-PERF-03 sample.

## Exit Criteria

The future canary task may reach `Completed` only when:

1. The authorized design and implementation scope is delivered without changing
   ordinary defaults or introducing a user-facing setting.
2. All acceptance-matrix rows are classified with current, reproducible evidence;
   `Partial`, `Blocked` and `NotRun` remain visible and are not averaged away.
3. Gate-off equivalence, kill-switch transitions, owner exclusivity, lifecycle,
   presentation receipts, privacy, capacity and restore have explicit results.
4. Any physical-device evidence was separately activated and binds its own
   immutable run header; otherwise the device layer remains `NotRun`.
5. Independent Architecture and Quality reviews publish P0/P1/P2/P3 residuals
   and a handoff recommendation.
6. Product Lead receives the bounded result and chooses stop/retain, remediate,
   authorize a stronger evidence phase, or open a separate ADR/Product Gate
   decision. The Executor does not make that choice.

Completion of this Assignment is not ADR 0025 acceptance, Product Gate, Release
approval or permission to change the default gate.

## Stop Conditions

Stop and return to the named authority when:

- any required Assignment responsibility becomes unavailable, contradictory or
  unacknowledged;
- implementation is requested before assignee acknowledgement and Architecture
  design review;
- the design conflicts with Accepted ADR 0004 or requires treating ADR 0025 as
  already Accepted;
- ordinary Release contains a compiled or runtime-reachable canary capability
  while ADR 0025 remains Proposed;
- safe exclusivity cannot be shown for kill-switch fallback or any reachable
  session API;
- any live-session entry point is neither routed through the single owner nor
  explicitly fail-closed;
- an accepted revision lacks FIFO completion or an explicitly authorized,
  auditable terminal disposition after kill/fence;
- gate-off comparison cannot bind the same build/configuration/provenance
  envelope required by the frozen comparison contract;
- an implementation uses `@unchecked Sendable`, parallel live-session access,
  dropped/merged/reordered accepted input or an unbounded mailbox;
- the default gate, ordinary Release behavior or a user-facing setting would
  change;
- evidence requires raw user content, unversioned privacy interpretation,
  post-hoc run identity or an unexplained PAINT gap;
- a target/device/environment action lacks an explicitly assigned Environment
  Executor, Human Dependency, destination, restore artifact or fresh Product
  activation;
- a P0/P1 Architecture or Quality finding remains unresolved;
- progress requires a new product SLO, risk acceptance, ADR acceptance, Product
  Gate or Release decision.

## Handoff

- Current Handoff Target: **DEVICE-001 independent Architecture/Quality review,
  then Environment Executor and Human Dependency**
- Required Current Handoff Content: this Assignment Record, frozen allowlist,
  implementation diff, source-only test additions, independent static
  Architecture/Quality verdicts, explicit NotRun list and unchanged Product/ADR
  boundaries
- Later Handoff Sequence: assigned Domain Owner/Executor -> independent
  Architecture Reviewer -> independent Quality Reviewer -> Product Lead
- Required Later Handoff Content: exact changed-file allowlist, design record,
  commands and destinations, source/build/artifact hashes, marker/schema/privacy
  versions, evidence matrix, failed/skipped rows, residual ledger, restore proof
  and documentation-impact disposition
- Revalidation Trigger: Product scope or assignee change; ADR 0004/0025 status;
  owner/session/lifecycle design; gate or kill-switch semantics; marker,
  validator or privacy schema; RIME artifact/schema; target/device/OS/toolchain;
  Full Access/host; evidence-retention policy; Product Gate or Release decision

## Current state and next decision

- Frozen-allowlist implementation and source-only focused tests are complete.
  Independent Architecture and Quality implementation reviews both report
  `P0/P1/P2/P3 = 0/0/0/0` for the final static diff.
- The mechanically gated run004 matrix completed: C02-C11 and P01-P05 all
  exited zero. Test groups report C02 906/0, C03 9/0, C04 18/0, C08 139/0,
  C09 1/0 and C10 34 pass / 20 classified skip / 0 fail. P01 has
  `unknownSkipped=0`; P02 restored the ordinary Simulator package with matching
  App/Extension executable hashes and no internal condition; P03-P05 passed.
- The internal compilation condition remains absent from ordinary project build
  settings. Default gates, Product Decision, ADR 0025 (`Proposed`), production
  rollout and Product Gate remain unchanged.
- Independent post-run Architecture review reports bounded Pass / overall
  Partial with `P0/P1/P2/P3 = 0/0/1/0`; Quality reports automated-layer Pass /
  overall Partial with `0/0/3/0`. Remaining P2s are the 20 explicitly
  `NotObserved` fixture/provenance skips, lack of Main App launch smoke, and the
  still-unexecuted physical-device/manual-runtime layer.
- Lifecycle remains `Active` pending Product Lead disposition. QEF-01 is closed
  for the frozen automated/Simulator claim boundary only. Physical-device
  evidence requires a new immutable device run header and separate activation;
  production rollout and Product Gate remain closed.
- The earlier host execution-quota block is historical and was not bypassed;
  execution resumed only after the environment became available. No physical
  device, App Group/userdb cleanup, commit or push occurred.

## Activated build/test evidence paths

- Immutable command manifests:
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-2026-08-03.txt`
  (v1, retained failed preflight) and
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v2-2026-08-03.txt`
  (superseded before retry after source drift), and
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v3-2026-08-04.txt`
  (retained historical manifest), through
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v6-2026-08-04.txt`
  (completed final manifest; SHA-256
  `10447f04d76fa57dbc37e37019aa58b52755ac1217614d07375226b1e2f3f5a8`)
  and
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v7-2026-08-04.txt`
  (QEF-01 provenance-repair pre-run freeze; SHA-256
  `3880a49af4c3a02cbcab04d17197998d1faeca18f4de4c1141ed3bb853cc0507`;
  rejected pre-run and never executed), and
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v8-2026-08-04.txt`
  (rejected pre-run and never executed; SHA-256
  `04b9a040238a7418473923b3fe562b3ee07d61f1a136646ba4247e6049f36283`;
  run-header binding SHA-256
  `09133e2e26efaeaed31a8c72a5beb00cef775cedc3d4a9eaef498884b460af03`), and
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-command-manifest-v9-2026-08-04.txt`
  (run004 mechanically gated QEF-01 refreeze; earlier SHA
  `d04eea23e67b34439fc350985ec499d84d53fab4ae8e9b7bb1a24243ea805009`
  was rejected pre-run and never executed; run001 SHA
  `95ae940bb051497ad8d3ca8ca5864ed9cf2d843c76e598f8596a0156fe1fb9e1`
  stopped terminally at C02 and is archived; run002 SHA
  `3413e323a9656231c0fabcf8ae873cbbaa730cdb0baff2d61b035a1ad92fce98`
  is also archived after the xunit capture failure; run003 SHA-256
  `7e609158de46b2592fcd548ca8ee273bdcaa190f0da02416ff8b4383fa1b0bac`
  is archived after the filtered aggregate capture failure; current run004 SHA-256
  `5f39593c5641266f38e810ab316d6533bd3bb852e15934a4a78b2c07318c8ae2`;
  run-header binding SHA-256
  `b11e318a8f9f55df2bde38dd28ea449d87dda38be7a92b5f9fc448a1d062d72d`;
  independent pre-run Architecture and Quality reviews both approved with
  P0/P1 = 0)
- Canonical v9 machine-readable result record (created only after P03V9 passes):
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-result-v9-2026-08-04.json`
- Historical/narrative result ledger:
  `docs/evidence/t9-responsive-pipeline-canary-001-build-test-2026-08-03.md`
- Simulator destination: booted iPhone 17 Pro Max, iOS 27.0,
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- DerivedData/scratch/result bundles: explicit CANARY-001 paths under
  `/private/tmp`; no App Group or userdb cleanup is permitted.
- Restore proof installs the ordinary package and compares installed executable
  hashes, but intentionally does not launch the Main App, so it cannot trigger
  foreground sync, backup or pending RIME deployment.
