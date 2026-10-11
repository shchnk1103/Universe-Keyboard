# Assignment: KOS-UPGRADE-UK-006-ADOPTION — Apply the prospective v0.9.0 decision locally

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Completed |
| Current phase | The accepted UK-006 Product Decision is applied to the local Kit pin, M-02 rule, new-lane reviewer contract and navigation/status mirrors; the docs-only application merged as PR #170 at commit 1c14ab66d628f1a291b5484da0255c40492a80be. |
| Material non-claims | No KOS 2.0/schema/validator change, required mode, migration, backfill, runtime/device action, new KOS Kit tag or Release, App Product/Quality/Release Gate, TestFlight or App Store release. |
| Next handoff / decision | None for this completed adoption Assignment; prospective rules apply to eligible future M-02 triggers and newly assigned independent review lanes. |
| Residuals | No known documentation or Profile syntax issue; the merge-trigger M-02 closeout is recorded in the linked post-merge state-sync receipt. |

---

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md), accepted in the current Codex session on 2026-09-25 Asia/Shanghai.

## Boundary

- Scope: apply the exact accepted v0.9.0 adoption to .kos/project.json, KOS upgrade status, M-02 state-sync guidance, independent reviewer-lane packet guidance, AI workflow routing, the repository entry summary, the Reading Map, Knowledge Index and the UK-006 review Assignment current-status mirror; create this bounded Assignment and Product Decision.
- Non-goals: alter the frozen UK-006 review assessment, source maps, packets or review receipts; change UK-005 release-evidence contract/Profile; migrate existing Assignments or reviewer lanes; enable required mode; implement the separate simulator/device diagnosis work; change code, CI or validation schemas; publish any Git state.
- Required Inputs: the accepted Product Decision; the UK-006 Round 2 assessment and source map; Architecture Round 2 and Quality Round 3 receipts; the local Assignment Policy, AI Workflow, M-02 rules, and Project Profile.
- Project baseline: isolated worktree at 50cdccc8d07e70cb02987c9fe0a17be55291701d.

## Assignment

- Domain Owner / Executor: Architecture & Knowledge Steward / current Codex executor in the isolated worktree.
- Environment Executor: Not Applicable — repository documentation and JSON text only; no device, application, account or release environment operation.
- Human Dependency: Not Applicable for this local application slice; any publication remains a separate Human Product Owner decision.
- Architecture Reviewer: Not Applicable — this applies the already accepted decision without changing KOS 2.0 core, record schema, validator or product architecture; the adopter-fit recommendation has its independent Architecture Round 2 receipt.
- Quality Reviewer: Not Applicable — this is a docs-only local application; mechanical documentation and JSON checks do not claim an independent review conclusion.
- Product Approver: Human Product Owner.

## Gates and Handoff

- Entry: accepted Product Decision; exact v0.9.0 immutable identity; isolated worktree at the stated baseline; completed Architecture Round 2 and Quality Round 3 adopter-fit reviews.
- Exit: the selected scope is reflected consistently in the canonical status, profile, operating rules and entry/navigation mirrors; existing frozen review records remain unchanged; local documentation checks are recorded.
- Stop: source/tag identity mismatch; conflict with KOS 2.0 or existing UK-005 authority; any need to enable required mode, migrate/backfill, change schema/validator, touch runtime/device scope or publish externally.
- Handoff Target: Human Product Owner.
- Required Handoff Content: local changed-file list, exact adopted boundaries, validation commands/results and publication non-claims.
- Revalidation Trigger: a changed Product Decision, Kit source identity, KOS 2.0/schema/validator boundary, UK-005 adopted bytes/Profile, or newly requested migration/publication scope.

## Validation

- git diff --check: passed for tracked changes.
- python3 -m json.tool .kos/project.json: passed; assertions confirmed
  v0.9.0 commit c98b2813240e22b2ac7fec44b2445321b03f73e0, advisory mode and
  supported schema 1.0.
- Directly called scripts/ci/check_markdown_links.py::missing_links() on
  28 modified or untracked Markdown files: zero missing local targets.
- Whitespace scan passed for the new Product Decision, new adoption Assignment
  and updated UK-006 review Assignment.
- Confirmed the UK-005 Profile and UK-005 adoption/review records are unchanged;
  Profile Git blob is 12b212fa8f2a0c8f805792c5922abeb84f7ccf97.
- The Round 2 assessment and source-map SHA-256 values remain
  eab2d1e27137d75120c06980be6356ccc092bbd7de20b89b8e4de10fc3e09af9 and
  49cba1b2881b33621e8690953cf2de60abb263cd35586bfc0f2cdaaf597d5eea.
- At the local-application stage, no code tests, builds, hosted CI, simulator/device operation or GitHub write was run; those were outside that local docs-only Assignment. The later PR #170 publication passed its pinned KOS validator, lightweight checks, final hosted quality gate and GitGuardian.

## M-02 merge-trigger closeout

- Work Item: KOS-UPGRADE-UK-006-ADOPTION.
- Exact event: lifecycle-changing tip PR merge that published the prospective v0.9.0 adoption.
- Authority record: [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md).
- Merged tip: PR [#170](https://github.com/shchnk1103/Universe-Keyboard/pull/170), source tip 36e5079a218cc909109078b8077e3bf1ef03bd98, merged at 2026-09-25T05:56:07Z as 1c14ab66d628f1a291b5484da0255c40492a80be.
- The single post-merge synchronization is documented in [the M-02 receipt](../evidence/kos-upgrade-uk-006-v0.9.0-post-merge-state-sync-2026-09-25.md). Its administrative publication and merge are part of this closeout transaction; it does not recursively trigger another M-02 for this identity.

## History

- 2026-09-25 Asia/Shanghai: Established from the Human Product Owner's prospective adoption decision and completed locally in the isolated worktree. No commit, push, PR, merge, tag or Release action was performed at that time.
- 2026-09-25 Asia/Shanghai: Docs-only adoption published via PR #170 and merged as 1c14ab66d628f1a291b5484da0255c40492a80be; post-merge M-02 is tracked above.
