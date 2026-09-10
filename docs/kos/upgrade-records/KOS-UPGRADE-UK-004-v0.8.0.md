# KOS Kit v0.8.0 Upgrade Record

- Owner: Human Product Owner; executor: current Codex runtime.
- From: adopted `v0.7.0` advisory, `f7f4dad6750b59dc827c1366fcd276447b2820b2`.
- Target: [v0.8.0 Release](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.8.0), annotated tag object `530d1b790d5effaa8cf9056d4e827c30ffa62fcf` → commit `2c9907565bf6b6fcd00e698cc539d9e2db573bc5`, locally revalidated at `2026-09-10T00:19:00+08:00`.
- Disposition: **Adopted** — Human Product Owner approved `Adopted` on `2026-09-10 Asia/Shanghai`; E-01, A-01/B-01, P-01 and D-01 are project policy only through explicit opt-in on future new records. Existing Active Assignments remain pinned.
- Reason: the document-only Architecture and Quality final-delta reviews both passed with no open findings; the Human Product decision accepted the bounded, advisory adoption.
- Risk: applying the optional fields to an existing record could invent historical authority or evidence; enabling `required`, H-02/W-01 or changing the opt-in boundary needs a new Assignment.
- Expiry / next reviewer: when the upstream release/source or adopted contract scope changes, when enabling `required`, or when a future opt-in reveals an ownership/validation conflict.

## Frozen upstream contract map

This source map freezes the content assessed below. The tag and commit are the
identity; blob IDs make the relevant source set independently reproducible from
the local Kit mirror. It does not assert that GitHub's hosted Release metadata
was fetched in this environment.

| Contract | Kit source at `2c990756` | Blob | Frozen meaning relevant to an adopter |
|---|---|---|---|
| E-01 | `ops/kos-2.1-operational-maturity.md` | `1190386` | An optional claim-bound observation with outcome, evidence, environment, coverage, comparison basis and freshness; unresolved comparable conflict is `inconclusive`. |
| A-01 | `ops/kos-2.1-operational-maturity.md` | `1190386` | A displayed authorization requires a resolvable Assignment → Authorization → accepted Decision chain that exactly covers action, target, scope and exclusions; failure is `UNKNOWN`. |
| B-01 | `ops/agent-execution.md` | `350ca26` | A concise Human-decision briefing states action, scope, immediate effect, applicable record/source and exclusions; it creates neither authority nor a Gate. |
| P-01 | `templates/docs/HANDOFF.md` | `dc610f3` | Candidate delivery records local/published/hosted heads and classifies CI coverage as `same-head`, `ahead`, `divergent` or `unknown`; only `same-head` covers the local candidate. |
| D-01 | `templates/docs/HANDOFF.md` | `dc610f3` | Final-documentation receipt binds final commit/tree, checker command/version, scope, baseline, time, exit/result and output; changed content requires a rerun. |
| Out of scope | `docs/design/kos-evolution-portable-ops-proposal.md` | `76ea329` | H-02 remains an optional H-01 observation extension and W-01 remains a future proposed-work header. Neither is considered here. |

Additional reviewed upstream inputs: `docs/assignments/KOS-PORTABLE-OPS-001.md`
(`63ee45b`), the portable-ops Architecture review (`587b224`) and Quality review
(`207bc71`). Their passed implementation verdicts describe the Kit's own
candidate, not Universe Keyboard adoption.

## Project applicability assessment

| Contract | Established project boundary | Applicability to a future Assignment | Required local adoption constraint | Assessment disposition |
|---|---|---|
| E-01 | Evidence grades already distinguish executor, independent Quality and human-device evidence. Privacy policy and the human-operated profile prohibit typed text, candidates, host text and other user content in logs/receipts. | **Conditionally applicable.** It can make a new, bounded evidence claim more comparable without changing current evidence ownership. | Adopt only for explicitly named new claims; retain the existing evidence grade; use content-free fields; record `inconclusive` rather than reconciling conflicts in a status summary. No legacy backfill. | Recommend **Adopt for new Assignments only**, pending independent review and Product decision. |
| A-01 / B-01 | Assignment Policy keeps Product authority separate and says `UNKNOWN` blocks Ready/Active; existing Current Status is a mirror, not authority. | **Conditionally applicable.** The project has Decisions and Authorization receipts, but many historical records do not expose a complete chain. | Require a newly created Assignment to reference a current accepted Decision and matching active Authorization before calling an action authorized. A briefing may explain a new Human decision but cannot replace the chain or turn this session into a reusable receipt. | Recommend **Adopt for new Assignments only**, pending independent review and Product decision. |
| P-01 | CI classification already says CI is not a merge/Release decision and distinguishes local versus hosted checks. | **Conditionally applicable.** It closes a real handoff ambiguity when a candidate is local-only, ahead of a published branch or built by hosted CI on another head. | Use it only in a publication/PR handoff that can observe all three heads. If sandbox/network access leaves any head unresolved, write `unknown` and “does not cover the local candidate.” | Recommend **Adopt for new publication handoffs only**, pending independent review and Product decision. |
| D-01 | Docs-only changes already require `git diff --check` and link/status validation; CI validates changed Markdown links and Profile JSON syntax. | **Conditionally applicable.** It makes the final checked tree and checker scope explicit without selecting a universal checker. | The adopting Assignment must name the actual checker, version, scope and output artifact. `git diff --check` alone is whitespace evidence, not a link/status receipt. Any final-documentation change invalidates the receipt. | Recommend **Adopt for new documentation handoffs only**, pending independent review and Product decision. |
| H-02 / W-01 | Existing human-operated evidence profile is an H-01-equivalent project contract; no proposed-work package is needed for this review. | **Not applicable to this Assignment.** | A later Product Assignment must separately assess its privacy/manifests or planning workflow. | **Out of scope; no adoption recommendation.** |

## Required future owner mapping

This map is a pre-adoption constraint, not an implementation or policy change.
It prevents a future opt-in from creating a second source of truth.

| Contract | Project owner source after a future opt-in | Explicit opt-in boundary | Prohibited shortcut |
|---|---|---|---|
| E-01 | The individual `docs/evidence/<work-item>.md` owned by the named Assignment; `DOCUMENTATION_GOVERNANCE.md` remains the grade policy and `PRIVACY_POLICY.md` remains the content boundary. | A newly created Assignment names the claim and evidence owner, then adds the observation to its own evidence record. | Do not add an outcome to `UPGRADE_STATUS`, Active Work, a review or an unrelated status mirror. |
| A-01 / B-01 | The bounded `docs/assignments/<work-item>.md`, matching `docs/authorizations/` receipt and accepted `docs/product-decisions/` source; `ASSIGNMENT_POLICY.md` remains the reusable rule. | A newly created Assignment declares that it adopts A-01/B-01 and supplies a current matching Decision and Authorization before an action is described as authorized. | Do not infer the chain from chat text, a Current Status row, a validator result or a briefing. |
| P-01 | The work item's handoff packet, with CI facts sourced from the relevant PR/hosted run and the candidate source from Git. `CI_CHANGE_CLASSIFICATION.md` remains the CI policy. | A publication/PR Assignment explicitly requests P-01 and records all three heads for that handoff. | Do not use a generic CI summary or an uncommitted worktree HEAD as same-head coverage. |
| D-01 | The work item's final documentation-validation evidence or handoff; `DOCUMENTATION_GOVERNANCE.md` remains documentation policy and the selected checker owns its output. | A documentation-changing Assignment names its checker command, version, scope and output artifact before claiming a D-01 receipt. | Do not call whitespace-only `git diff --check` a completed link/status validation receipt. |

## Boundary verdict and review request

The frozen assessment finds no conflict with KOS 2.0, the project Assignment
Policy, the advisory envelope mode, CI authority boundaries or the keyboard's
content privacy boundary **provided that** all four recommended contracts stay
opt-in and apply only to newly created records/handoffs. It does not demonstrate
that the project templates, checker or current records already implement them.

No matrix row is an adoption decision. `required`, core/schema/validator changes,
Active Assignment migration, H-02 and W-01 remain excluded. The independent
Architecture reviewer must test source-of-truth/authority compatibility; the
independent Quality reviewer must test evidence, freshness, candidate identity
and final-documentation validation claims. Their verdicts bind this exact source
map and assessment, not a later edited tree.

## Historical compatibility review result

- [Architecture review](../../reviews/KOS-UPGRADE-UK-004-v0.8.0-architecture-review.md):
  `Pass`, `P0/P1/P2/P3 = 0/0/0/1`. Its accepted P3 preserves the non-claim for
  unsigned local tag / hosted Release metadata not re-fetched.
- [Quality review](../../reviews/KOS-UPGRADE-UK-004-v0.8.0-quality-review.md):
  `Pass with conditions`, `0/0/0/2`. Its accepted P3s preserve that upstream
  tests do not implement project adoption and hosted metadata was not re-fetched.

These historical conclusions do not themselves adopt any contract.

## Current document-only review handoff

The current independent conclusions live only in the two review records:
[Architecture](../../reviews/KOS-UPGRADE-UK-004-v0.8.0-architecture-review.md)
and [Quality](../../reviews/KOS-UPGRADE-UK-004-v0.8.0-quality-review.md). Their
scope is limited to this governance packet's source ownership, status mirrors,
navigation, review binding, document-validation claims and Human-decision
boundary. They do not evaluate implementation, CI/device sufficiency, upstream
test/release provenance or whether v0.8.0 should be adopted.

The final document-only delta reviews passed before the separate Human Product
decision. Their conclusions remain document-handoff evidence only; adoption
authority comes only from the Product Owner's explicit `Adopted` decision.

## Adoption boundary

The adopted policy is advisory: E-01, A-01/B-01, P-01 and D-01 are available
only to new records that explicitly opt in and follow the owner mapping above.
This does not enable `required`, migrate an Active Assignment, instantiate H-02
or W-01, or authorize publication actions.
