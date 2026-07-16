# Assignment: KEYBOARD-LAYOUT-9KEY-001 — 26 键 / 9 键布局切换

**Policy version:** `1.0.0`

**Lifecycle status:** `Ready`

**Repository change types:** `Contract`, `Documentation`, `Evidence`; after ADR acceptance and hardened Spike archive: `Implementation`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Stable repository Product Decision [`PD-KEYBOARD-LAYOUT-9KEY-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md) (`docs/product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md`), recorded `2026-07-16 Asia/Shanghai`. That Decision captures the Human Product Owner authorization wording, named Executor (Grok), named gate reviewer (Codex), date/timezone and Active-entry gates. Supporting Architecture/Quality records (immutable first review, amendment re-review, handoff) are linked from the Decision; they are not substitutes for the Product Decision Source.
- **Product Approver:** Human Product Owner (repository Product authority for this work item), as named in `PD-KEYBOARD-LAYOUT-9KEY-001`. The virtual Product Lead role may only execute Assignment mechanics under that Product Decision; it is not a substitute Decision Source.
- **Product Plan (non-authority input):** [`docs/plans/keyboard-layout-9key-implementation-plan.md`](../plans/keyboard-layout-9key-implementation-plan.md) — defines scope and order; **not** itself a Product Lead authorization record.
- **Architecture Decision:** [ADR 0018](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md) — architecture content accepted by Codex re-review; product implementation enters `Active` only when Assignment evidence P1s are closed and Entry Criteria for Active are met.

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-16 Asia/Shanghai` — Assignment, ADR, T9 Spike, stop conditions and Codex amendment requirements accepted.
- **Architecture acknowledgement:** ADR 0018 revised for versioned readiness, ordered lifecycle writes and unconditional T9 raw-digit non-commit; status `Accepted; implementation pending` after Codex-required amendments.
- **Product lifecycle decision:**
  - Governance + Spike package only was authorized first under `PD-KEYBOARD-LAYOUT-9KEY-001`.
  - First Assignment `Active` claim was **invalid** under Codex review and remains superseded.
  - Codex amendment re-review (`docs/evidence/keyboard-layout-9key-001-codex-rereview.md`) accepted ADR architecture and Spike technical direction, and required three evidence/authorization P1 closures before `Active`.
  - **Current lifecycle status remains `Ready`.** Product implementation steps 3–10 must not start until those P1s are closed and the Assignment validly enters `Active`.
- **Current phase:** Close Codex re-review P1/P2 evidence and Decision Source gates. Product steps 3–10 remain gated.

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

- Decision Source is the stable Product Decision `PD-KEYBOARD-LAYOUT-9KEY-001` (not conversation-only text).
- ADR 0018 architecture content remains accepted.
- Transferable Spike archive includes the complete raw xcodebuild log (or compressed form) with hashes, and the first Codex review remains immutable.
- Hardened Spike evidence is bound to a Git commit that contains the Spike harness; archival runs require a clean tracked worktree.
- Codex re-review Exit Criteria for blocking P1s are satisfied or explicitly waived by Architecture/Quality.
- No Stop Condition is active.
- Assignment lifecycle is explicitly transitioned `Ready -> Active` for product steps 3–10 (do not imply Active while still `Ready`).

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

- **Lifecycle:** **`Ready`** (not Active). Product steps 3–10 not started.
- **Governance:** Stable Product Decision Source `PD-KEYBOARD-LAYOUT-9KEY-001` at `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md`. Product Approver is Human Product Owner.
- **ADR 0018:** Architecture content accepted by Codex re-review (`docs/evidence/keyboard-layout-9key-001-codex-rereview.md`).
- **First Codex review:** restored to immutable Codex-authored content at `docs/evidence/keyboard-layout-9key-001-codex-review.md` (Executor must not rewrite reviewer records).
- **Codex re-review:** `docs/evidence/keyboard-layout-9key-001-codex-rereview.md`.
- **Spike (hardened):** **PASSED** on harness commit `337dd30ab443ad2d2af497648910946d6beb1a35`.
  - Tracked archive: `docs/evidence/keyboard-layout-9key-001/`
  - Full raw log (transferable): `docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz`
  - Decompressed raw log SHA-256: `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`
  - Compressed log SHA-256: `724303a0b3d22783766bcd9e1b1bc76290dc81d79f1c5c5afe7e363ddca8e181`
  - Vendor verify log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`
  - Machine summary: `T9_SPIKE_RESULT passed=true librime=1.16.1 schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 candidateSample=你|密|米|迷|秘 firstCandidateComment=ni rawAfterDelete=6`
- **Product implementation:** **Not started.** Remains blocked until re-review Exit Criteria are satisfied and Assignment transitions to `Active`.
- **Physical-device gate:** Open; depends on Human Product Owner after implementation.
