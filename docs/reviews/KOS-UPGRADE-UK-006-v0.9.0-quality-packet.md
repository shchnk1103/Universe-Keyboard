# KOS-UPGRADE-UK-006 Quality review packet — Round 1

## Identity

| Field | Value |
|---|---|
| Work Item | `KOS-UPGRADE-UK-006` |
| Lane ID | `KOS-UPGRADE-UK-006/quality` |
| Review round | `1` |
| Project baseline | Universe Keyboard `main` `50cdccc8d07e70cb02987c9fe0a17be55291701d` |
| Upstream baseline | KOS Kit `v0.9.0` tag `4a386cdc07cc52a3da4d7cf77b429b874169becb`; commit `c98b2813240e22b2ac7fec44b2445321b03f73e0` |
| Assessment input | [`KOS-UPGRADE-UK-006-v0.9.0.md`](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0.md) |
| Source map | [`v0.9.0 source freeze`](../evidence/kos-upgrade-uk-006-v0.9.0-source-freeze-2026-09-25.md) |

## Question and positive acceptance criteria

Determine whether the source identity, release comparison, applicability
evidence and non-claims in the Upgrade Record are complete and accurate enough
for a separate Human Product disposition.

- `Q-01`: Independently query only the whitelisted GitHub `latest` Release
  endpoint and verify the exact tag, URL and publication time; then verify the
  annotated tag and peeled commit locally. Do not present a local branch tip as
  the release identity.
- `Q-02`: Verify the project baseline, current v0.8.0 pin, advisory mode,
  selective opt-ins and Active-Assignment migration boundary against the frozen
  project sources.
- `Q-03`: Verify the specific v0.9.0 M-02 and agent-orchestration changes at the
  release tag. Ensure the review neither understates the new requirements nor
  claims that the local project has already adopted them.
- `Q-04`: Independently verify that the three `kos.release-evidence` v1.0
  source digests match the UK-005 adopted candidate and are byte-identical at
  v0.9.0. Do not transfer UK-005 findings or claim a new implementation review.
- `Q-05`: Ensure the record preserves the limits on source evidence, validation,
  Product decision, device diagnosis and external actions.
- `Q-06`: Check internal Markdown links and whitespace in the frozen Upgrade
  Record and source map. Do not run code tests, builds or device operations.

## Frozen target set

Project target files:

- `docs/kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0.md`
- `docs/evidence/kos-upgrade-uk-006-v0.9.0-source-freeze-2026-09-25.md`
- `.kos/project.json`
- `docs/kos/UPGRADE_STATUS.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/kos/kos-2.1-operational-maturity.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md`
- `docs/assignments/kos-upgrade-uk-004-v0.8.0.md`
- `docs/product-decisions/KOS-UPGRADE-UK-004-adoption.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md`
- `docs/assignments/kos-upgrade-uk-005-release-evidence-v1.md`
- `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md`
- `docs/kos/release-evidence-profile.md`
- `scripts/ci/check_markdown_links.py` (read-only checker source only)

Upstream target files at the immutable v0.9.0 tag:

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

- No adoption decision, pin/profile/Assignment edit, migration, backfill, commit,
  push, PR, merge, tag, Release, source change or GitHub write.
- No code tests/builds, application-release evidence creation, Swift, device,
  simulator, CoreDevice, Device Hub or Accessibility operation.
- No unrelated KOS/Universe Keyboard history, assignments or KOS Kit files.
- If any quality claim requires an excluded input, report one path and reason,
  mark the claim uncovered and stop that dependent investigation.

## Tool, data and write boundary

- Read-only local file/search/Git object/hash tools, the repository's
  `scripts/ci/check_markdown_links.py` checker, and one exact GitHub read-only
  request only:
  `gh api repos/shchnk1103/kos-agent-kit/releases/latest --jq '[.tag_name, .html_url, .published_at] | @tsv'`.
  Do not call any other URL/API, inspect auth status, print credentials, or make
  a GitHub write. No code/test/build/device execution or edits to reviewed inputs.
- Read only the target set above. Do not inspect the Architecture packet or
  review receipt.
- Append only this lane's conclusion to
  `docs/reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-review.md`.

## Output, acceptance and budget

- Assess every `Q-01`–`Q-06` with exact evidence. Include findings with severity,
  owner, disposition and pointer.
- `Pass` requires full coverage and every positive condition met. `Pass with
  conditions` also requires full coverage and M-03 disposition for each
  residual. A fully covered unmet condition is `Fail`. Missing coverage or
  budget exhaustion is `Partial / incomplete`, never Pass.
- Maximum: 20 tool calls or 20 active minutes, whichever comes first. Record a
  checkpoint every 5 calls or 5 minutes, listing budget use and covered /
  uncovered conditions. Stop at the first limit; no automatic renewal.
- Only the Human Product Owner acting as Product Lead can authorize a precise
  target or budget expansion. Do not ask the sibling reviewer or coordinator
  to expand scope.
- A changed frozen target requires a new numbered round. Preserve this round's
  result and do not silently bind it to later bytes.
