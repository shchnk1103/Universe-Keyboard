# KOS-UPGRADE-UK-006 Quality review packet — Round 2

## Identity

| Field | Value |
|---|---|
| Work Item | `KOS-UPGRADE-UK-006` |
| Lane ID | `KOS-UPGRADE-UK-006/quality` |
| Review round | `2` |
| Project baseline | Universe Keyboard remote `main` `50cdccc8d07e70cb02987c9fe0a17be55291701d` plus the exact Round 2 assessment/source-freeze inputs named below |
| Upstream baseline | KOS Kit `v0.9.0`, annotated tag `4a386cdc07cc52a3da4d7cf77b429b874169becb`; peeled commit `c98b2813240e22b2ac7fec44b2445321b03f73e0` |
| Assessment input | [`KOS-UPGRADE-UK-006 Round 2 assessment`](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0-round-2.md) |
| Source map | [`Round 2 source freeze`](../evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md) |
| Packet digest | SHA-256 is supplied in the review dispatch; independently hash this exact packet and stop if it differs. |

## Review question and positive acceptance criteria

Determine whether the corrected source identity, project-adoption state,
applicability evidence, Round 1 finding dispositions, and static documentation
checks are complete and accurate enough for a separate Human Product decision.

- `Q2-01`: Independently query exactly once the read-only GitHub latest Release
  endpoint `GET https://api.github.com/repos/shchnk1103/kos-agent-kit/releases/latest`
  (or the exact equivalent `gh api repos/shchnk1103/kos-agent-kit/releases/latest
  --jq '[.tag_name, .html_url, .published_at] | @tsv'`). Verify the tag, release
  URL and publication time, then verify the local annotated tag and peeled
  commit. Do not retry any failure and do not treat the source map's earlier
  coordinator observation as this lane's independent query.
- `Q2-02`: Verify the project baseline, v0.8.0 pin, advisory mode, selective
  opt-ins and no-migration boundary against the frozen project sources. Verify
  from `AI_WORKFLOW.md`, `UPGRADE_STATUS.md`, UK-004 record and Product Decision
  that the upstream optional orchestration package was available but not
  adopted/instantiated; distinguish that package from local general delegation
  guidance.
- `Q2-03`: Verify the specific v0.9.0 M-02 and orchestration changes at the
  immutable tag. Check that the corrected assessment explicitly accounts for
  all mandatory packet identity, scope, boundary, acceptance, budget/checkpoint
  and stop/authority fields and does not claim project adoption in advance.
- `Q2-04`: Independently verify the contract/schema/evaluator SHA-256 values
  against the UK-005 adopted candidate and the v0.9.0 immutable tag. Do not
  transfer UK-005 findings or claim a new implementation review.
- `Q2-05`: Ensure the Round 2 assessment preserves Product/Release authority,
  source/validation limits, no migration/backfill/`required`, no external
  actions, the device-diagnostics non-claim and the unmodified Round 1 result.
- `Q2-06`: Directly check local links and whitespace in both frozen Round 2
  Markdown inputs. Import the repository checker at
  `scripts/ci/check_markdown_links.py` and call
  `missing_links(Path(<exact-input>), repository_root)` separately for the
  source map and assessment. Report both paths and the count actually checked;
  a `HEAD..HEAD` changed-file invocation that returns zero files is not coverage.
  Check trailing whitespace, blank-line whitespace and space-before-tab on the
  same exact files.
- `Q2-07`: Verify each Round 1 Quality finding has an explicit, evidence-backed
  disposition in the Round 2 assessment and packet; do not rewrite the Round 1
  receipt or upgrade its conclusion retroactively.

## Frozen target set

Project targets:

- `docs/kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0-round-2.md`
- `docs/evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md`
- `docs/AI_WORKFLOW.md`
- `.kos/project.json`
- `docs/kos/UPGRADE_STATUS.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md`
- `docs/assignments/kos-upgrade-uk-004-v0.8.0.md`
- `docs/product-decisions/KOS-UPGRADE-UK-004-adoption.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md`
- `docs/assignments/kos-upgrade-uk-005-release-evidence-v1.md`
- `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md`
- `docs/kos/release-evidence-profile.md`
- `scripts/ci/check_markdown_links.py` (read-only checker source)
- Round 1 assessment, source map and Quality receipt (prior finding disposition only).

Upstream targets at immutable KOS Kit `v0.9.0`:

- `CHANGELOG.md`
- `ops/kos-2.1-operational-maturity.md`
- `ops/agent-orchestration.md`
- `ops/release-evidence.md`
- `schemas/release-evidence-v1.schema.json`
- `scripts/validate_release_evidence.py`
- `templates/docs/ORCHESTRATION_PLAN.md`
- `docs/product-decisions/KOS-RELEASE-EVIDENCE-PORTABILITY-002-adoption.md`
- `docs/assignments/KOS-OPS-BOUNDARIES-001.md`

## Exclusions and stop behavior

- Do not inspect the Round 2 Architecture packet or receipt, or any sibling-lane
  output. Do not infer Architecture's result.
- No adoption/deferral decision, pin/profile/Assignment edit, migration,
  backfill, `required`, source change, code test/build, device, simulator,
  CoreDevice, Device Hub or Accessibility operation, GitHub write, other API or
  URL, auth/status inspection, secret output, commit, push, PR, merge, tag or
  Release.
- No unrelated KOS/Universe Keyboard history or files.
- The only external query permitted is the single exact latest Release read in
  `Q2-01`; if it fails, stop that claim and do not retry.
- If a claim requires an excluded input, report one path and reason, mark the
  claim uncovered and stop that dependent investigation.

## Tool, data and write boundary

- Read-only local file/search/Git object/hash tools; the exact `missing_links`
  checker-function calls specified in `Q2-06`; and the single exact external
  latest Release read in `Q2-01` only.
- Read upstream bytes using `git show <immutable-v0.9.0-object>:<path>`; do not
  read mutable KOS Kit worktree content.
- Read only the target set above.
- Append only this lane's conclusion to
  `docs/reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r2-review.md`.

## Output, acceptance and budget

- Assess every `Q2-01`–`Q2-07` with exact evidence; list findings with stable
  ID, severity, owner, disposition and pointer.
- `Pass` requires full coverage and every positive condition met. `Pass with
  conditions` also requires full coverage and a valid disposition for every
  residual. A fully covered unmet condition is `Fail`. Missing coverage or a
  budget limit is `Partial / incomplete`, never Pass.
- Maximum: 20 tool calls or 20 active minutes, whichever comes first. Record a
  checkpoint at start and every 5 calls or 5 minutes, including budget use and
  covered/uncovered criteria. Stop at the first limit; no automatic renewal.
- Only the Human Product Owner acting as Product Lead may authorize precise
  target or budget expansion. Do not request scope changes from the sibling
  reviewer or coordinator.
- A changed frozen input requires a new numbered review round. Preserve this
  round's conclusion; do not bind it to later bytes.
