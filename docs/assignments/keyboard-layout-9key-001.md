# Assignment: KEYBOARD-LAYOUT-9KEY-001 — 26 键 / 9 键布局切换

**Policy version:** `1.0.0`

**Lifecycle status:** `Ready`

**Repository change types:** `Contract`, `Documentation`, `Evidence`; after ADR acceptance and hardened Spike archive: `Implementation`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:**
  1. Human Product Owner instruction in the active Grok task session on `2026-07-16 Asia/Shanghai`: create a new branch; execute [`docs/plans/keyboard-layout-9key-implementation-plan.md`](../plans/keyboard-layout-9key-implementation-plan.md) strictly; complete Assignment and ADR first, then the T9 Spike; do not skip stop conditions; hand all Section 13 evidence to Codex review.
  2. Codex Architecture/Quality review conclusions on `2026-07-16 Asia/Shanghai`, relayed by the same Human Product Owner: Spike technical direction is conditionally accepted (pinned librime `1.16.1` + remove `t9_processor`); Assignment must not remain `Active` until Decision Source is verifiable; ADR 0018 must be revised (versioned readiness, ordered enable/disable, unconditional no-raw-digit commit) and enter `Accepted; implementation pending` before product code; Spike assertions/provenance must be hardened and re-archived on a committed snapshot. Review body is recorded in the owner-relayed Codex review message and the amended handoff at [`docs/evidence/keyboard-layout-9key-001-codex-handoff.md`](../evidence/keyboard-layout-9key-001-codex-handoff.md).
- **Product Approver:** Human Product Owner (repository Product authority for this work item). The virtual Product Lead role may only execute Assignment mechanics under that owner confirmation; it is not a substitute Decision Source.
- **Product Plan (non-authority input):** [`docs/plans/keyboard-layout-9key-implementation-plan.md`](../plans/keyboard-layout-9key-implementation-plan.md) — defines scope and order; **not** itself a Product Lead authorization record.
- **Architecture Decision:** [ADR 0018](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md) — must be `Accepted; implementation pending` before product implementation enters `Active`.

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-16 Asia/Shanghai` — Assignment, ADR, T9 Spike, stop conditions and Codex amendment requirements accepted.
- **Architecture acknowledgement:** ADR 0018 revised for versioned readiness, ordered lifecycle writes and unconditional T9 raw-digit non-commit; status `Accepted; implementation pending` after Codex-required amendments.
- **Product lifecycle decision:**
  - Governance + Spike package only was authorized first.
  - First Assignment `Active` claim was **invalid** under Codex review (unverifiable Decision Source / Proposed ADR authorizing implementation) and is superseded by this revision.
  - Current status after amendments + hardened Spike re-archive: **`Ready`**.
  - Product implementation may move `Ready -> Active` only when ADR 0018 is `Accepted; implementation pending`, hardened Spike evidence is bound to a committed snapshot, and no required field is `UNKNOWN`.
- **Current phase:** Codex amendment package (Assignment, ADR, Spike assertion/provenance hardening). Product steps 3–10 remain gated.

## Assignment

- **Domain Owner:** RIME Platform Maintainer (primary — T9 schema, effective schema selection, deployment ownership and fixed-librime compatibility)
- **Executor:** Grok, coordinating bounded packages under RIME Platform, Input Intelligence, Keyboard Experience and App & Data Operations
- **Environment Executor:** Grok for isolated Simulator/runtime Spike, unit/integration builds and local evidence capture; Human Product Owner for physical-device keyboard-extension acceptance
- **Human Dependency:** Human Product Owner for physical-device operation, host-app acceptance and final Product Gate
- **Architecture Reviewer:** Architecture & Knowledge Steward via Codex review handoff
- **Quality Reviewer:** Quality, Performance & Release Maintainer via Codex review handoff
- **Product Approver:** Human Product Owner
- **Handoff Target:** Codex for Architecture/Quality re-review of the amendment package; then Executor may start product implementation under ADR 0018; Product Gate remains with Human Product Owner

## Boundary

### Scope

1. Maintain this Assignment with no `UNKNOWN` required fields and a verifiable Decision Source.
2. Publish and keep ADR 0018 as the binding boundary for base scheme vs effective scheme, versioned T9 readiness, App Group keys, client compatibility layer, ordered enable/disable/uninstall writes, deployment ownership and failure fallback.
3. Publish keyboard-layout domain documentation and route it from `KNOWLEDGE_INDEX.md` / `READING_MAPS.md`.
4. Run and re-archive the mandatory T9 compatibility Spike against the pinned librime build in an isolated temporary deploy directory:
   - place upstream `t9.schema.yaml`;
   - remove unsupported `t9_processor` for the experiment only;
   - select `t9`;
   - input representative digit sequences such as `64`;
   - assert non-empty candidates **and** non-empty composition/preedit, BackSpace reduces one raw digit, record first-candidate comment, then clean the session;
   - bind evidence to the commit that contains the Spike harness; vendor verify failure fails the Spike.
5. Only after ADR 0018 is `Accepted; implementation pending` and hardened Spike evidence is archived, implement the plan's runtime, install/deploy lifecycle, KeyboardCore/RIME Bridge T9 semantics, Extension nine-key layout, main-App settings UI, tests, builds and documentation updates.
6. Produce and update the Section 13 handoff package for Codex review.

### Non-goals

- English nine-key / multi-tap input.
- Nine-key swipe letter selection.
- Independent nine-key scheme for 朙月拼音.
- Cross-process live layout hot-switch while the keyboard is already visible.
- Replacing the pinned RIME binary or changing main-App vs Extension deployment ownership without a new Product/Architecture decision.
- Persisting raw user digits, dictionary content or composition text into new storage locations.
- Claiming product completion from UI mockups or by swallowing T9 runtime failures.
- Expanding into unrelated refactors.
- Treating a `Proposed` ADR as authorization for product implementation.

### Required Inputs

- Human Product Owner task authorization and Codex review conclusions (Decision Source above)
- `docs/plans/keyboard-layout-9key-implementation-plan.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/VIRTUAL_ENGINEERING_TEAM.md`
- ADR 0001, 0003, 0004, 0006, 0008 and this task's ADR 0018
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
- `docs/architecture/rime-artifacts.md`
- `docs/RIME_SCHEME_MANAGEMENT.md`
- `docs/UI_STYLE_GUIDE.md`
- `docs/PROJECT_CONTEXT.md`
- `docs/RELEASE_CHECKLIST.md`
- `config/rime-vendor-manifest.env` and the pinned Vendor librime artifact
- Upstream rime-ice `t9.schema.yaml` provenance

## Gates

### Entry Criteria

#### Ready (governance / Spike amendment package)

- Human Product Owner authorized Grok execution and Codex review (Decision Source item 1).
- Assignment contains no `UNKNOWN` fields and Decision Source is not only the plan file.
- Work runs on an isolated feature branch.
- T9 Spike uses an isolated temporary deployment directory and does not overwrite the user's formal App Group RIME data.

#### Active (product implementation)

- ADR 0018 status is `Accepted; implementation pending`.
- Hardened Spike evidence is bound to a Git commit that contains the Spike test and runner.
- Codex amendment requirements for Assignment/ADR/Spike assertions are recorded as satisfied or explicitly waived by Architecture/Quality.
- No Stop Condition is active.

### Exit Criteria

- T9 Spike result is recorded with raw logs, vendor-verify log and provenance bound to the harness commit; on failure, implementation expansion has stopped.
- On subsequent implementation: shared layout settings, versioned readiness marker, effective-schema resolver, ordered install/deploy/verify/uninstall lifecycle, T9 input semantics (including unconditional no-raw-digit commit), Extension layout, settings UI, automated tests and builds are complete.
- Failure paths retain 26-key usability and never leave the keyboard unusable.
- Section 13 handoff content is complete or explicitly marked unavailable with reason.
- Architecture, Quality and Product reviews issue independent conclusions before closure.

### Stop Conditions

Stop, mark `Blocked`, and hand evidence to Product Lead / Codex when any of the following is true:

1. Any required Assignment field is `UNKNOWN`, Decision Source is missing, or Decision Source is only a non-authoritative plan document.
2. The pinned librime cannot pass the T9 Spike after the documented compatibility patch (remove unsupported `t9_processor`).
3. Implementation would require replacing the fixed RIME binary or changing main-App/Extension deployment ownership.
4. Implementation would persist raw user digits, dictionary content or composition text into a new durable location.
5. Failure cannot safely fall back to 26-key input.
6. Required physical-device operator or physical-device evidence cannot be obtained for acceptance that depends on it.
7. The plan conflicts with an accepted ADR, product contract or unexpected dirty worktree changes outside this Assignment.
8. Product implementation is requested while ADR 0018 is still `Proposed` or otherwise non-binding.

## Handoff

- **Handoff Target:** Codex (Architecture + Quality re-review of amendments), then Executor for product implementation under accepted ADR, then Human Product Owner for Product Gate
- **Required Handoff Content:**
  - Assignment and ADR paths
  - Actual changed-file allowlist
  - T9 upstream version, source and checksums
  - Spike result, harness commit, full log SHA-256, vendor-verify log SHA-256, fixture/schema SHA-256
  - Unit/integration test and Debug/Release build logs when implementation proceeds
  - Light/dark and compact-width screenshots when UI proceeds
  - Physical-device acceptance facts or explicit unavailability
  - Unrun verification items and reasons
  - Known limits, fallback proof and residual risks
- **Revalidation Trigger:** Spike failure, librime/vendor change, deployment-boundary change, product decision change for English nine-key or live hot-switch, Decision Source dispute, or conflict with ADR 0001/0004/0006/0018

## Current Evidence Status

- **Governance:** Assignment Decision Source revised to cite Human Product Owner task instruction + Codex review conclusions; Product Approver is Human Product Owner; lifecycle corrected from invalid early `Active` to `Ready` pending product Active gate.
- **ADR 0018:** Revised for versioned readiness marker, ordered enable/disable/uninstall, preserve readiness on base-scheme switch when T9 files remain intact, and unconditional no-raw-digit commit during T9 composition. Status: `Accepted; implementation pending`.
- **Spike (initial, superseded):** technical direction passed on `2026-07-16` but assertions/provenance were insufficient for archival (OR condition; unbound commit; vendor verify `|| true`).
- **Spike (hardened, current):** **PASSED** on harness commit `337dd30ab443ad2d2af497648910946d6beb1a35`.
  - Tracked archive: `docs/evidence/keyboard-layout-9key-001/`
  - Handoff: `docs/evidence/keyboard-layout-9key-001-codex-handoff.md`
  - Local full run (gitignored): `evidence/keyboard-layout-9key-spike/20260716-195542/`
  - Machine summary: `T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6`
  - Full log SHA-256: `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`
  - Vendor verify log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`
  - Upstream schema SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`
  - Patched schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`
- **Product implementation:** **Not started.** May enter `Active` only after Codex re-accepts this amendment package (or Human Product Owner explicitly directs continuation under accepted ADR 0018).
- **Physical-device gate:** Open; depends on Human Product Owner after implementation.
