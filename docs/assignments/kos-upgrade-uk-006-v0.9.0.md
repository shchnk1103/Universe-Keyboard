# Assignment: KOS-UPGRADE-UK-006 — Review KOS Agent Kit v0.9.0

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Reviewed |
| Current phase | Architecture Round 2 passed; Quality Round 2 partial findings were resolved by Quality Round 3 Pass. Product disposition and local prospective adoption are recorded separately under UK-006-ADOPTION; that docs-only application merged as PR #170 at 1c14ab66d628f1a291b5484da0255c40492a80be. This review Assignment remains Reviewed, not Closed. |
| Material non-claims | This review Assignment grants no required-mode change, Active-Assignment migration, backfill, Product/Release Gate or publication authorization; v0.9.0 adoption is a separate accepted Product Decision. |
| Next handoff / decision | No remaining review-lane action. The accepted Product Decision and local application are published under [UK-006-ADOPTION](kos-upgrade-uk-006-v0.9.0-adoption.md); future Kit upgrades, Product/Release gates or scope changes require their own authority. |
| Residuals | No open Architecture or Quality findings remain across the completed review lanes. Simulator/CoreDevice discovery remains a separate project-specific issue outside v0.9.0. |

---

> **Current supersession note:** The review-only boundary below describes UK-006's original review Assignment. The later Product disposition is [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md); local application is tracked separately and does not rewrite any frozen review packet or receipt.

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: current Codex session, `2026-09-25 Asia/Shanghai`; the Human Product Owner authorized the initial isolated adopter review and, after Round 1 Quality returned Partial / incomplete, authorized one new numbered remediation review with one Architecture and one Quality lane. This direction authorizes local review work and records only.
- Scope authority: Human Product Owner / Product Lead. Only this role may approve a precise scope or budget expansion.

## Boundary

- Scope: assess the latest KOS Kit Release `v0.9.0` against the Universe Keyboard `v0.8.0` advisory pin; review M-02 closeout and reviewer-scope/budget changes; compare bundled `kos.release-evidence` files with the already-adopted UK-005 candidate; resolve Round 1 Quality findings in a new numbered review by checking `docs/AI_WORKFLOW.md`, correcting the adoption and review-identity statements, independently querying the exact read-only GitHub latest Release endpoint once, and directly applying the repository Markdown-link checker to the frozen untracked inputs; then obtain independent Architecture Round 2 and Quality Round 2/3 conclusions.
- Non-goals: adopt or defer v0.9.0 on behalf of Product; change `.kos/project.json`, `UPGRADE_STATUS.md`, the release-evidence Profile, any Active Assignment or source code; enable `required`; migrate/backfill; implement simulator/device diagnosis; commit, push, create a PR, merge, tag or Release.
- Required inputs: Round 1 [source map](../evidence/kos-upgrade-uk-006-v0.9.0-source-freeze-2026-09-25.md), [assessment](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0.md) and [Architecture](../reviews/KOS-UPGRADE-UK-006-v0.9.0-architecture-packet.md)/[Quality](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-packet.md) packets/receipts; Round 2 [source map](../evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md), [assessment](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0-round-2.md), and the frozen [Architecture](../reviews/KOS-UPGRADE-UK-006-v0.9.0-architecture-r2-packet.md)/[Quality](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r2-packet.md) packets.

## Responsibilities

- Domain Owner / Executor: Architecture & Knowledge Steward / current Codex coordinator in the isolated worktree at the exact remote-main baseline.
- Environment Executor: Not Applicable — local documentation and immutable Git-object reads only; no product/device/account environment operation.
- Human Dependency: Human Product Owner — a later Product disposition is outside this review Assignment.
- Round 1 Architecture Reviewer: `/root/uk006_architecture_review`, read-only runtime, lane `KOS-UPGRADE-UK-006/architecture`.
- Round 1 Quality Reviewer: `/root/uk006_quality_review`, read-only runtime, lane `KOS-UPGRADE-UK-006/quality`.
- Round 2 Architecture Reviewer: `/root/uk006_r2_architecture_review`, fresh independent read-only runtime, same logical lane at review round `2`; packet SHA-256 `66946429bf205dea05a9ba3ceb0d93c13242f36f4bafb51e777ccb36e9e1fa97`.
- Round 2 Quality Reviewer: `/root/uk006_r2_quality_review`, fresh independent read-only runtime, same logical lane at review round `2`; packet SHA-256 `db3c2c89072f4902a2daae02267f7fba920d087df3d1af77e9415a490d8c33b8`.
- Round 3 Quality Reviewer: `/root/uk006_r2_quality_review`, continuing the same independent Quality runtime/lane at review round `3`; packet [`Quality Round 3`](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r3-packet.md), SHA-256 `15ee0213161f131561d2693d3488556405e084d856e3a896a6192bce2691a604`; receipt [`Quality Round 3`](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r3-review.md). The Round 2 assessment and source-map inputs remain unchanged.

Each reviewer may append only its own review receipt. It may not edit the
assessment, source map, packet, sibling receipt or any other project file.

## Gates and Handoff

- Entry: Human authorization for Round 3; isolated Universe Keyboard worktree remains based at `50cdccc8d07e70cb02987c9fe0a17be55291701d`; Round 2 assessment/source map remain frozen; Quality packet explicitly identifies the immutable KOS Kit repository path and the single permitted latest-Release request; packet digest is independently checked before dispatch.
- Exit: one independent Architecture conclusion and a complete Quality conclusion, including numbered continuation rounds that resolve any partial findings, all bound to exact packet, assessment and source-map digests; all findings have explicit disposition; the frozen Markdown inputs are directly checked for local links and whitespace; results and non-claims are handed to the Human Product Owner. Adoption is not an Exit requirement and is not authorized here.
- Stop: any need to change the KOS 2.0 core/schema/validator/`required`; missing or inconsistent source identity; an out-of-scope dependency; reviewer independence failure; or a frozen input change. A stopped lane reports one locator, marks the dependent claim uncovered and waits for explicit scope/budget authority.
- Handoff Target: Human Product Owner for a separate Product decision.
- Handoff Content: exact local and upstream baselines, latest Release check, applicability matrix, exact UK-005 source comparison, reviewer receipts, documentation validation results, recommendation and non-claims.
- Revalidation Trigger: a changed KOS Kit tag/source, changed frozen project input, review packet change, scope/budget expansion, or new Human Product direction.

## History

- `2026-09-25 Asia/Shanghai`: Established in the isolated review worktree from the exact remote `main` baseline. KOS Kit latest Release API returned `v0.9.0`; no project adoption or publication action was performed.
- `2026-09-25 Asia/Shanghai`: Independent Architecture Round 1 passed all six criteria with no findings (`P0/P1/P2/P3 = 0/0/0/0`, 13/20 calls); see the [Architecture receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-architecture-review.md). Independent Quality Round 1 returned Partial / incomplete (`0/0/4/0`, 18/20 calls); see the [Quality receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-review.md). The four P2 findings remain open; no frozen review input was changed and no new round was authorized. A coordinator-side local Markdown link/whitespace scan of all seven untracked review files passed, but does not upgrade the Quality receipt's Q-06 result. The Assignment is Blocked pending a separate Product Lead decision on whether and how to continue Quality review.
- `2026-09-25 Asia/Shanghai`: Human Product Owner authorized one new numbered remediation review after the Round 1 Partial / incomplete result. Round 2 preserves every Round 1 receipt and finding, corrects only the review assessment/source map, and will run one fresh independent Architecture and one fresh independent Quality review. Each reviewer is capped at 20 tool calls or 20 active minutes. No v0.9.0 adoption or publication is included.
- `2026-09-25 Asia/Shanghai`: Round 2 sources and packets are frozen. Assessment SHA-256 `eab2d1e27137d75120c06980be6356ccc092bbd7de20b89b8e4de10fc3e09af9`; source-map SHA-256 `49cba1b2881b33621e8690953cf2de60abb263cd35586bfc0f2cdaaf597d5eea`. Architecture and Quality packet SHA-256 values are bound above and supplied with their separate dispatches. The reviewed Round 1 inputs remain unchanged.
- `2026-09-25 Asia/Shanghai`: Architecture Round 2 passed all seven criteria with no findings (`P0/P1/P2/P3 = 0/0/0/0`; 19 operations including receipt write). Quality Round 2 returned `Partial / incomplete` (`0/0/3/0`; 20/20 calls); receipt: [Quality Round 2](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r2-review.md). The exact direct link/whitespace checks passed on both frozen Markdown inputs, but the single external GET was inaccessible and upstream v0.9.0 objects were not found from that lane's checkout. A coordinator-only read-only check later confirmed that `/private/tmp/kos-agent-kit-kos-ops-publish-001` resolves `v0.9.0` to `c98b2813240e22b2ac7fec44b2445321b03f73e0`; this does not upgrade the independent Quality result because that local path was not in its frozen packet. No Round 2 input or receipt was rewritten. Assignment is Blocked pending Product Lead decision on a narrowly scoped new Quality review; no v0.9.0 adoption or publication.
- `2026-09-25 Asia/Shanghai`: Human Product Owner authorized one Quality-only Round 3. It preserves the Round 2 assessment/source map and Architecture receipt; only the Quality packet/receipt advance. One read-only `gh api` request is permitted for the exact latest Release endpoint; immutable upstream reads must use the named local KOS Kit repository path. No adoption or publication is included.
- `2026-09-25 Asia/Shanghai`: Quality Round 3 packet was frozen at SHA-256 `15ee0213161f131561d2693d3488556405e084d856e3a896a6192bce2691a604`; its bound Round 2 assessment/source map hashes are unchanged. The single approved `gh api` query must be executed once with the required network permission up front; no retry or alternate endpoint is allowed.
- `2026-09-25 Asia/Shanghai`: Quality Round 3 passed all five criteria (`P0/P1/P2/P3 = 0/0/0/0`, 10 calls including receipt write). The single exact Release API read succeeded; the reviewer verified immutable v0.9.0 objects through the explicitly frozen local Git repository path; all three Round 2 Quality findings were resolved. See the [Quality Round 3 receipt](../reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r3-review.md). A final scan of all fifteen UK-006 Markdown files found no broken local links or whitespace errors. Round 1 and Round 2 receipts remain unchanged. This Assignment is `Reviewed`, not `Closed`; Human Product Owner disposition remains separate.
- 2026-09-25 Asia/Shanghai: Human Product Owner recorded prospective v0.9.0 adoption in [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md). The local policy/profile application is a separate [UK-006-ADOPTION Assignment](kos-upgrade-uk-006-v0.9.0-adoption.md). The review packets, assessment and receipts remain unchanged; this review Assignment remains Reviewed, not Closed, because no owning Gate was closed.
