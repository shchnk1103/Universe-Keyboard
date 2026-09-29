# Assignment: ARCHIVE-POINTER-RIME-SYNC-PUBLISH-PREFLIGHT-001 — Append the archive-relocation pointer for the RIME-SYNC publication preflight raw artifacts

Policy version: 1.0.0

**Repository Change Type:** `Documentation`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Completed |
| **Phase** | Append-only notes written. Docs-only PR opened from `docs/archive-pointer-rime-sync-publish-preflight-001`. Merge is not authorized. |
| **Non-claims** | This does not rewrite historical evidence or review content or any recorded SHA-256. It does not newly verify the host-local archive: those facts are as recorded by the 2026-09-29 host cleanup session. It is not Quality, Product Gate, merge, TestFlight or Release. |
| **Next** | The Human Product Owner reviews the PR and decides whether to merge. If merged, record the M-02 closeout under this Assignment. |
| **Residuals** | None |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: explicit instruction from the Human Product Owner, delegated to this executor session, on `2026-09-29 Asia/Shanghai`. The instruction covered:
  - the append-only archive pointer in the three `origin/main` documents that cite `/private/tmp/rime-sync-publish-preflight.mfN43t`;
  - branch `docs/archive-pointer-rime-sync-publish-preflight-001` from `origin/main`;
  - commit, push and opening a PR.

  It did not authorize a merge.
- Product Approver: Human Product Owner acting as Product Lead
- Record weight: this is the lightest compliant record under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) for a formal task that changes repository state. It does not opt into the optional A-01/B-01, P-01 or D-01 contracts. No separate Product Decision or Authorization record was created, and none is claimed.

## Boundary

- Scope:
  - Append one dated, append-only archive-relocation note to each of these three documents:
    - [`rime-sync-v1-publication-preflight-2026-09-25.md`](../evidence/rime-sync-v1-publication-preflight-2026-09-25.md), which holds the full facts;
    - [`rime-sync-v1-publication-quality-review-2026-09-26.md`](../reviews/rime-sync-v1-publication-quality-review-2026-09-26.md), which gets a short pointer;
    - [`rime-sync-v1-publication-review-packet-2026-09-26.md`](../reviews/rime-sync-v1-publication-review-packet-2026-09-26.md), which gets a short pointer.
  - Record this Assignment.
- Non-goals:
  - Editing the historical sections or recorded SHA-256 values.
  - Changing the four worktree-only documents that cite the path. They are not on `main`.
  - Changing `ACTIVE_WORK`, the Dashboard, the Closed `RIME-SYNC-001` Assignment, `.kos/project.json`, Swift, CI or scripts.
  - Operating on the host archive.
  - Merging, TestFlight or Release.
- Required Inputs:
  - `origin/main` at `84b9c19227330b0fe6ff391be001ee398010fd6a`.
  - The archive facts provided by the Human Product Owner from the 2026-09-29 host cleanup session: path, host, file name, size, SHA-256, sidecar files, retained and excluded counts, 17-path presence and the three SHA matches.

## Assignment

- Domain Owner: 🏛️ Architecture & Knowledge Steward. This follows the policy's *Documentation-only Governance Publication* profile.
- Executor: the current Grok executor session. It works in a fresh clone on a separate machine, not in the user's Mac checkout.
- Environment Executor: `Not Applicable`. This covers repository documentation only. The archive and deletion were done earlier by a separate host session and are not part of this Assignment.
- Human Dependency: Human Product Owner — PR review and the merge decision.
- Architecture Reviewer: 🏛️ Architecture & Knowledge Steward, per the profile. No review has been performed, and the executor does not self-attest one.
- Quality Reviewer: `Not Applicable`. Per the profile, link and governance validation are publication checks.

## Gates

- Entry Criteria: explicit Human instruction; fresh `origin/main` baseline; `git grep` confirms exactly three `origin/main` documents cite the path. All three were met on `2026-09-29`.
- Exit Criteria:
  - Append-only notes present in the three documents.
  - `git diff --check` passes.
  - `scripts/ci/run_lightweight_checks.sh` passes, or any step it could not run is reported.
  - The PR is open and not merged.
- Stop Conditions:
  - A change would alter historical content or recorded SHA values.
  - The citing-document set differs from the three expected documents.
  - The scope expands to host operations, other documents or a merge.

## Handoff

- Handoff Target: Human Product Owner.
- Required Handoff Content: PR URL, head SHA, file list, check results, and a statement that the archive facts are recorded but were not re-verified here.
- Revalidation Trigger: `origin/main` changes the three documents before merge; the archive is moved or re-verified; the Human revises the facts.

## History

- `2026-09-29 Asia/Shanghai`: The Human instructed the append-only pointer update. The executor branched from `origin/main` `84b9c19` and appended the three notes. The docs-only PR was opened without a merge. Lifecycle moved to `Completed`, which is not Quality or Product acceptance.
