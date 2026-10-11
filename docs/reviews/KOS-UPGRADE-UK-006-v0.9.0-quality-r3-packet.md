# KOS-UPGRADE-UK-006 Quality review packet — Round 3

## Identity

| Field | Value |
|---|---|
| Work Item | `KOS-UPGRADE-UK-006` |
| Lane ID | `KOS-UPGRADE-UK-006/quality` |
| Review round | `3` |
| Project baseline | Universe Keyboard remote `main` `50cdccc8d07e70cb02987c9fe0a17be55291701d` plus the exact Round 2 assessment/source-map inputs named below |
| Upstream baseline | KOS Kit `v0.9.0`, annotated tag `4a386cdc07cc52a3da4d7cf77b429b874169becb`; peeled commit `c98b2813240e22b2ac7fec44b2445321b03f73e0` |
| Assessment input | [`KOS-UPGRADE-UK-006 Round 2 assessment`](../kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0-round-2.md), unchanged SHA-256 `eab2d1e27137d75120c06980be6356ccc092bbd7de20b89b8e4de10fc3e09af9` |
| Source map | [`Round 2 source freeze`](../evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md), unchanged SHA-256 `49cba1b2881b33621e8690953cf2de60abb263cd35586bfc0f2cdaaf597d5eea` |
| Round 2 Quality receipt | [`Quality Round 2`](KOS-UPGRADE-UK-006-v0.9.0-quality-r2-review.md), SHA-256 `f0693556f832c0732f043e089a3350cd2db4947b44872c294a5df77ccee59855` |
| Packet digest | SHA-256 is supplied in the review dispatch; independently hash this exact packet and stop if it differs. |

## Question and positive acceptance criteria

Resolve only the three open Round 2 Quality findings against the unchanged
assessment/source map and exact upstream release identity. This is a Quality
continuation in the same logical lane; preserve every Round 2 finding and do
not rewrite its receipt.

- `Q3-01`: Use one read-only GitHub latest Release request. Run exactly once,
  from a host/network-enabled execution mode (request sandbox escalation
  before execution if required):
  `gh api repos/shchnk1103/kos-agent-kit/releases/latest --jq '[.tag_name, .html_url, .published_at] | @tsv'`.
  Do not first run it in a restricted mode and then retry. Do not use another
  URL/API, do not retry after any execution failure, and do not treat the source
  map's earlier observation as independent evidence. Record exact output or
  exact error and elapsed time.
- `Q3-02`: Verify the immutable local KOS Kit tag and source objects in the
  explicitly supplied repository:
  `/private/tmp/kos-agent-kit-kos-ops-publish-001`.
  Run read-only commands with `git -C` against that path, including
  `git -C /private/tmp/kos-agent-kit-kos-ops-publish-001 rev-parse v0.9.0^{tag}`
  and `git -C /private/tmp/kos-agent-kit-kos-ops-publish-001 rev-parse v0.9.0^{commit}`.
  They must return the annotated tag object
  `4a386cdc07cc52a3da4d7cf77b429b874169becb` and peeled commit
  `c98b2813240e22b2ac7fec44b2445321b03f73e0`. Read every upstream target with
  `git -C /private/tmp/kos-agent-kit-kos-ops-publish-001 show v0.9.0:<path>`;
  do not read the mutable KOS Kit working-tree files. Verify the assessment's
  M-02 and orchestration summary against those immutable bytes.
- `Q3-03`: Independently verify that the `ops/release-evidence.md`,
  `schemas/release-evidence-v1.schema.json`, and
  `scripts/validate_release_evidence.py` blobs at `v0.9.0` have the UK-005
  adopted SHA-256 values recorded in the Round 2 source map. Where available,
  verify byte identity against candidate commit `8e55551` using immutable Git
  objects from the same explicit repository path. Do not infer byte identity
  from the source map alone.
- `Q3-04`: Determine whether Round 2 findings
  `Q-UK006-R2-Q01-01`, `Q-UK006-R2-Q03-01`, and `Q-UK006-R2-Q04-01` are resolved
  by this lane's independent evidence. Any criterion still uncovered remains
  `Partial / incomplete`; no automatic renewal or further review round.
- `Q3-05`: Verify unchanged Round 2 assessment/source-map hashes and confirm
  that Round 2's Q2-02/Q2-05/Q2-06/Q2-07 results remain bound to those exact
  bytes. Do not read or infer the sibling Architecture result.

## Frozen target set

Project targets:

- `docs/kos/upgrade-records/KOS-UPGRADE-UK-006-v0.9.0-round-2.md`
- `docs/evidence/kos-upgrade-uk-006-v0.9.0-round-2-source-freeze-2026-09-25.md`
- `docs/reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r2-packet.md`
- `docs/reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r2-review.md`
- `.kos/project.json`
- `docs/AI_WORKFLOW.md`
- `docs/kos/UPGRADE_STATUS.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-004-v0.8.0.md`
- `docs/product-decisions/KOS-UPGRADE-UK-004-adoption.md`
- UK-005 record, Assignment, Product Decision and release-evidence Profile named by the Round 2 source map.
- `scripts/ci/check_markdown_links.py` (read-only source, only if needed to verify the prior direct-check result).

Upstream targets, read only from the explicit local Git object repository above:

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

- Do not read any Architecture packet, receipt or reviewer output, including
  Architecture Round 2. Do not infer its result.
- No adoption/deferral decision, pin/Profile/Assignment edit, migration,
  backfill, `required`, source or code change, tests/builds, device/simulator,
  CoreDevice/Device Hub/Accessibility operation, other external URL/API,
  GitHub write, auth/status inspection, secret output, commit, push, PR, merge,
  tag or Release.
- No unrelated KOS/Universe Keyboard files. Do not use the KOS Kit mutable
  working tree as source.
- The only external query permitted is the exact `gh api` invocation in
  `Q3-01`, performed with its required network permission up front. If the one
  request fails, record the exact error and stop that claim. No retry or
  alternate request.
- If the explicit local Git object path does not contain a required object,
  report that object and command, mark the dependent criteria uncovered, and
  stop. Do not fetch or use another repository/path.

## Tool, data and write boundary

- Read-only local file/search/hash/Git object operations; the one exact Release
  request; no tests, builds or device operations.
- Read only the target set above. Do not inspect the sibling Architecture lane.
- Append only this lane's conclusion to
  `docs/reviews/KOS-UPGRADE-UK-006-v0.9.0-quality-r3-review.md`.

## Output, acceptance and budget

- Assess every `Q3-01`–`Q3-05` with exact evidence. Include stable finding IDs,
  severity, owner, disposition and pointer; explicitly disposition each open
  Round 2 Quality finding.
- `Pass` requires full coverage and every positive condition met. `Pass with
  conditions` also requires full coverage and a valid disposition for every
  residual. A fully covered unmet condition is `Fail`. Missing coverage or
  budget exhaustion is `Partial / incomplete`, never Pass.
- Maximum: 20 tool calls or 20 active minutes, whichever comes first. Record a
  checkpoint at start and every 5 calls or 5 minutes, with budget use and
  covered/uncovered criteria. Stop at the first limit; no automatic renewal.
- Only the Human Product Owner acting as Product Lead may authorize a precise
  target or budget expansion. Do not request expansion from the coordinator or
  another reviewer.
- Changed assessment/source-map bytes require a new Architecture and Quality
  review round. Preserve this round's conclusion and never rebind it to later
  bytes.
