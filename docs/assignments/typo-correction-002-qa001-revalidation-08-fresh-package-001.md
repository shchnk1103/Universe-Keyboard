# Assignment: TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001 — Fresh-package QA-001 candidate observation

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001",
  "record_type": "assignment",
  "title": "Fresh-package QA-001 candidate observation after PR #144 merge tip e1b28ae",
  "lifecycle": "active",
  "current_phase": "observation complete; evidence written; awaiting Product residual / commit auth",
  "authorization_action": "observe_qa001_target_candidate_on_fresh_package",
  "updated_at": "2026-09-22T18:45:00+08:00",
  "revalidation_triggers": [
    "install_source_tip_changed",
    "hosted_CI_binding_changed",
    "simulator_or_host_identity_changed",
    "same_package_or_same_run_reuse_detected",
    "scope_expansion_toward_INT003_performance_or_gates",
    "AUTH_revoked_or_executor_changed"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-PARENT-REVALIDATION-002"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok (iOS开发大师) under Human Product Owner handoff",
    "environment_executor": "Grok (iOS开发大师) — designated Device Hub Simulator build/install/capture only",
    "human_dependency": "Human Product Owner — eye observation whether 「我们今天去公园」 is visible and selectable; Human attestation required",
    "architecture_reviewer": "Not Applicable for this observation slice — separate Architecture AUTH required if a later review is authorized",
    "quality_reviewer": "Not Applicable for this observation slice — separate Quality AUTH required if a later review is authorized",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Observation complete. Human attested target visible + selectable (position 2). Evidence: [`reval-08 receipt`](../evidence/typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md). Residual: tip `e1b28ae` lacks on-disk provenance writer; App Group Ice prefs bind env. |
| **Next** | Docs commit authorized; push / Assignment Close / Architecture/Quality still need new AUTH. |
| **Non-claims** | No INT-003, paired performance, 180 ms, TestFlight, Release, Product/Quality/Release Gate, parent Close, Swift edit, commit/push/PR. |

## Authority and inputs

- **Parent:** [`TYPO-CORRECTION-002`](typo-correction-002.md) — Lifecycle **Active** (this child does not close it).
- **Related parent-revalidation lane:** [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](typo-correction-002-parent-revalidation-002.md).
- **Prior inconclusive (forbidden reuse):** [`QA-001 revalidation 07`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md) — Run `TC2-SIM-20260920-224421-QA001-REVAL-07`, package source `3f9f2652b03279a99537639f4382b48bb58548ca`. Same package + same phrase must not be retried.
- **Merge tip (install source):** `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` (PR #144 squash merge onto `main`).
- **Hosted CI binding A:** Swift 6 Quality push run [`35715351145`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35715351145) on headSha `e1b28ae…` — observed `success` including `final-quality-gate` at draft time. Pre-squash run `35706026531` (`589deab4…`) is **not** the install-tip binding.
- **Matching AUTH:** [`AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001.md) — **live/consumed** `2026-09-22T18:40:00+08:00`.

## Scope

After the matching Authorization is explicitly set **live** and consumed for execution, Executor may only:

1. Check out / build from tip `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` (or an isolated worktree at that exact commit).
2. Perform a **fresh** Simulator install (not the reval-07 package).
3. Mint a **new** Run ID of the form `TC2-SIM-YYYYMMDD-HHMMSS-QA001-REVAL-08`.
4. Record the **new** installed package hash / identity and RIME provenance for this Run.
5. Use the designated Simulator and Messages host below; enter `wimenjintianquhongyuan` via the **real keyboard** (no FakeCandidateProvider, no old Ice directory, no `typeText`, no clipboard, no host text injection).
6. Ask Human Product Owner to observe whether 「我们今天去公园」 is visible and selectable.
7. Write Executor evidence. If the target is not seen, record **`inconclusive`** — do **not** rewrite as a general product failure.

### Designated environment

| Item | Value |
|---|---|
| Simulator | iPhone 17 Pro Max / iOS 27 |
| UDID | `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Messages · `+1 (888) 555-1212` (do not Send) |
| Phrase | `wimenjintianquhongyuan` |
| Target candidate | 「我们今天去公园」 |

## Non-goals and stop conditions

- Do not reuse reval-07 package `3f9f2652…` or Run `TC2-SIM-20260920-224421-QA001-REVAL-07`.
- Do not run INT-003, paired performance, or claim 180 ms.
- Do not edit Swift, tests, Vendor, schema, or project files under this Assignment.
- Do not commit, push, open/modify PRs, merge, TestFlight, Release, or close parent/child Assignments.
- Do not open Product / Quality / Release Gate conclusions from this observation alone.
- Stop if install tip drifts from `e1b28ae…`, CI binding A is revoked, required Human attestation is unavailable, or a forbidden input path would be required.

## Entry Criteria

- No required Assignment field is `UNKNOWN`.
- CI binding **A** is recorded: push run `35715351145` on `e1b28ae…` is `success` (including `final-quality-gate`).
- Matching AUTH exists and is later set **live** by Human before execution.
- Fresh build/install from `e1b28ae…` into the designated Simulator is feasible.

## Exit Criteria

- New Run ID and new package hash/provenance are recorded.
- Environment binding (Simulator UDID, host, tip, CI run) is in the evidence receipt.
- Human visibility attestation is recorded (seen+selectable / not seen → inconclusive).
- Explicit non-claims listed above remain intact.

## Handoff

- Evidence target: `docs/evidence/typo-correction-002-sim-run-*-qa001-reval-08*.md` (path finalized at execution).
- Later Architecture/Quality reviews require **new** Authorizations; not implied by this Assignment.
