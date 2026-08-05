# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-03
# Replicated, reverse-order canonical A/B decision matrix

Policy version: 1.0.0
Lifecycle status: **Reviewed — bounded evidence-only A/B; overall Partial**
Date: 2026-08-03 Asia/Shanghai

## Purpose

P2-PERF-02 produced a bounded iPhone 13 Pro observation: the explicit
thread-affine arm shortened the immediate accept path and reduced the Human
stall score from `2/4` to `0.5/4` in one fixed A→B pair. Architecture and
Quality both retained `Partial` because the pair was single-order/single-sample,
the content-free fixture cannot be replayed from logs, and B revisions `16` and
`33` have no explicit PAINT coalescing reason.

This Assignment defines the smallest next evidence slice before any request to
make the thread-affine path a production-facing experiment. The evidence scope
is now authorized; production-facing wiring remains out of scope.

## Authority and assignment

- Assignment Authority: **Product Lead**
- Decision Source / Date: Human Product Owner authorization in the active Codex task, 2026-08-03 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Domain Owner: Quality, Performance & Release Maintainer
- Executor: Current Codex task for build, install, content-free export parsing and evidence packaging
- Environment Executor: Current Codex task for named iPhone 13 Pro operations; Human Product Owner for manual input
- Human Dependency: Human Product Owner for manual input, integrity report and
  subjective score
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer
- Handoff Target: Product Lead, after independent Architecture/Quality review

The authorization is limited to the four-arm evidence matrix below. It does not
authorize production source changes, default-gate changes, ADR acceptance,
Product Gate or Release claims.

## Scope

If authorized, run two canonical pairs on the same iPhone 13 Pro:

| Pair | First arm | Second arm | Purpose |
|---|---|---|---|
| P2-PERF-03-AB | A: sync gate-off | B: explicit thread-affine diagnostic | Repeat the P2-PERF-02 order |
| P2-PERF-03-BA | B: explicit thread-affine diagnostic | A: sync gate-off | Detect order/practice effects |

### Frozen runs and tokens

| Arm | Run ID | Fresh token |
|---|---|---|
| A1 | `P2P03-AB-A1-20260803-001` | `S6A-4F6E59D5C301D8A7969C551CA12F6ABB` |
| B1 | `P2P03-AB-B1-20260803-001` | `S6A-04E2D1B82EE1853B687E3E34198C5232` |
| B2 | `P2P03-BA-B2-20260803-001` | `S6A-01EFFFC8FAC49CE6091A05196C14E9C7` |
| A2 | `P2P03-BA-A2-20260803-001` | `S6A-E576AA10440DFA38964EA535AD89A1B1` |

### Frozen source/toolchain/device envelope

Captured immediately before the four arm builds. The untracked fingerprints
exclude this Assignment file itself to avoid a self-referential hash; the file
name is frozen in the run header.

| Field | Value |
|---|---|
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Worktree dirty entry count | `96` |
| Tracked diff SHA-256 | `4f8e9c07f43d69168e778e65d06c73423b0da2cd4c50a4afb9354bff52460088` |
| Untracked-content SHA-256 (excluding this Assignment) | `78e733c2ee2c2d55190fd5ff6b02ca434dc6aa9a54dba67dff6327e3444224e7` |
| Untracked-name SHA-256 (excluding this Assignment) | `a99fb1fa65dd90552cfd250a6de94e78d63cf5e82fb03e6a35da0d8d6b2c108f` |
| Xcode / SDK / Swift | `27.0 (27A5228h)` / `27.0` / `6.4` |
| Device | iPhone 13 Pro / `iPhone14,2` / physical |
| Device UDID | `00008110-000A08440198801E` |
| CoreDevice ID | `DE65EBE1-463E-5EB4-9694-F6DCBFC04028` |
| OS | iOS `27.0 (24A5390f)` |
| Connection | wired, paired, connected, booted, Developer Mode enabled |

Each arm uses a fresh run token, the same declared canonical fixture ID
`T9-RESP-PERF-39-V1`, the same software-keyboard/manual nine-key protocol and
the same content-free App diagnostic export. The raw fixture is not copied into
logs or the repository.

The pre-run manifest must bind, without user content:

- source HEAD, tracked and untracked-content fingerprints, build configuration,
  injected conditions and App/Keyboard executable hashes;
- device model/UDID/CoreDevice, OS, Xcode/SDK/Swift and run time window;
- Full Access as observed or `unavailable`, and an opaque host/list identifier
  if the host can provide one;
- normalized tokenless geometry digest and per-arm tokenized digest;
- restore package identity, install sequence and one-key smoke result.

## Frozen arm contract

| Arm | Compile conditions | Required path | Gate meaning |
|---|---|---|---|
| A | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` | `sync`, dual gate `0/0` | measurement only |
| B | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | `thread-affine`, dual gate `1/1`, `READY` | explicit diagnostic only |

Neither arm may define any auto-anchor `*_ENABLED` condition. Project defaults
remain false. No user setting or Release default is changed.

## Human protocol

For each arm, the Human uses the software keyboard and manually taps the visible
Chinese nine-key letter groups in the declared fixture. The Human must not use
the numeric page, Path, candidate, space, commit, Delete, paste or coordinate
automation. The report contains only content-free fields:

- `missingKeys`, `duplicateKeys`, `candidateDisappeared`, `keyboardExited`;
- `protocolAdherence` (`manual`, `no-prohibited-actions`, `not-observed`);
- raw subjective `stallScore` on the locked scale `0 = completely smooth`,
  `4 = severe stalls` (half-point values allowed);
- a short note with no host text, pinyin, candidate or screenshot.

Do not clear App diagnostics between arms; isolate runs by fresh tokens.

## Evidence matrix

Each run must be checked independently before comparison:

| Layer | Required observation | Failure meaning |
|---|---|---|
| Input integrity | T9SEG action/event `1..39`, ordered, no commit; Human four integrity fields all `no` | stop pair; do not average |
| A path | `sync`, dual gate `0/0`, 39 T9SEG | A invalid if absent |
| B owner | `PATH`, `READY`, ACCEPT `1..39`, PUBLISH `1..39`, epoch-bound and ordered | B invalid if absent |
| Presentation | VISIBLE/PAINT lag; every missing PAINT revision has explicit content-free `coalesced`/reason | keep UI layer Partial if reason absent |
| Geometry | prepared/execution valid; normalized digest equal across arms | keep geometry Partial if absent |
| Privacy | allow-list pass; no raw input/host/candidate text | stop and discard export |
| Restore | ordinary package installed after final arm; one-key smoke passes | pair remains incomplete |

Comparison is directional only. Report per-run medians/maxima and the order
effect; do not invent a product SLO. A repeated B improvement supports a new
production-wiring discussion but does not itself accept ADR 0025, Product Gate,
Release default-on or real-device shipping readiness.

## Non-goals and stop conditions

- No production source, Lua/schema behavior, RIME bridge contract, user setting,
  default gate or UI semantics change.
- No input drop, merge, reorder, auto-anchor expansion, `@unchecked Sendable`,
  coordinate automation, device wipe, App Group wipe or Reminders deletion.
- Stop on wrong device/flags/path, privacy leakage, lost/duplicate input,
  candidate disappearance, keyboard exit, unprovable session/geometry, or missing
  restore identity.
- Real-librime, Extension jetsam/memory, iOS 26 Release, App Store and Product
  Gate claims remain out of scope.

## Exit and handoff

1. Two order-controlled pairs have fresh run IDs/tokens and content-free,
   manifest-bound evidence.
2. Architecture and Quality independently classify the evidence and residuals.
3. The final record states whether order reversal changed the direction, without
   treating one Human score as a universal SLO.
4. The ordinary package is restored and verified.
5. The handoff stops at a Product Lead decision: authorize a separately scoped
   production-shaped canary/wiring review, or retain the diagnostic path only.

## Execution state

- Assignment execution is complete under the Product Lead authorization above; no
  production source or default-gate change was made.
- A1/B1/B2/A2 each have a valid, fresh token-bound export. An initial A1 attempt
  without a prepared token is recorded as `invalid-run-token` and is excluded;
  the subsequent A1 rerun is the valid arm.
- A1/A2 sync and B1/B2 thread-affine runtime evidence are each validator-complete:
  39/39 action/event, stable valid session, matching prepared/execution geometry,
  and no commit. B1/B2 additionally have 39/39 ACCEPT/PUBLISH and READY.
- The ordinary package was restored after A2 (install sequence `3800`) and the
  Human confirmed the keyboard-switch smoke. Token envelopes were cleaned per arm
  and the matrix registry was finalized.
- Existing regression was re-run without source changes: `T9ResponsiveEvidenceValidatorTests`
  **28/0** and KeyboardCore full **901/0**; JSON/document whitespace checks passed.
- Evidence: [`P2-PERF-03 replicated A/B evidence`](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md)
  and [content-free summary JSON](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-summary-2026-08-03.json).
- Independent Architecture review: [`Pass with conditions`](t9-responsive-pipeline-001-p2-perf-03-architecture-review.md),
  residual P0/P1/P2/P3 `0/0/4/2`.
- Independent Quality review: [`bounded condition pass; overall Partial`](t9-responsive-pipeline-001-p2-perf-03-quality-review.md),
  residual P0/P1/P2/P3 `0/0/4/3`.
- The handoff is complete at Product Lead decision. The result must not be called
  a Product Gate, ADR acceptance, production-wiring approval, or Release claim.
