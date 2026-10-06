# Quality Review Packet: v3 Compatibility Gate — Round 1

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane ID: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/quality`
- Review round: `1`
- Exact source baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `f19ee343da3347c04f89fa0cf99bbf96c9e82d4b94fc16fdd3d56260fff38245`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- CI workflow SHA-256: `cb4a41108ba0e9268b04b1aaca8bd06480da3e0dd8706221acbbce3ad6a0a6a8`
- Packet digest: compute SHA-256 over this file after freeze; pass the resulting digest in the dispatch and record it in the reviewer receipt.

## Claims and questions to decide

Review whether the revised Assignment provides a complete, current, and executable validation plan for the compatibility candidate, with attention to the schema-v5 source drift and CI jobs added after the historical candidate reviews.

1. Does the matrix cover the current changed source/test targets without reusing historical host or Simulator results as current candidate evidence?
2. Are the reader fixtures and consumer assertions sufficient for v3/v4/v5, mixed histories, strict rejection, query-wide completeness through continuation, and legacy fallback suppression?
3. Is the current `test_rime_sync_keychain` job fully represented with signed Simulator settings and its exact test selector?
4. Are strict formatting, KeyboardCore, RimeBridgeTests, App + Keyboard tests, Release build, `git diff --check`, and pinned RIME artifact identity all covered and correctly gated on one fresh exclusive Simulator destination where required?
5. Does the Assignment clearly distinguish source-stage work from Simulator validation and exclude install/manual/root-cause claims?

## Allowed review scope

- Read the frozen Assignment and Product Authorization.
- Read current `AGENTS.md`, `docs/CI_CHANGE_CLASSIFICATION.md`, `docs/ASSIGNMENT_POLICY.md`, `docs/AI_WORKFLOW.md`, `.github/workflows/swift6-quality.yml`, and only the current source/test files needed to map changed targets to validation.
- Read historical candidate evidence only to classify it as prerequisite/historical; do not reuse it as current candidate validation.
- Use local read-only file, hash, and Git inspection. No code or document writes, tests, builds, Simulator/UI operations, installs, network requests, or edits to any worktree are permitted.

## Exclusions

- No Architecture ruling on the persisted event protocol, no root-cause or product behavior review, and no Quality Gate on an implementation candidate.
- No Simulator availability/exclusivity assertion; the packet treats fresh exclusive reservation as a required precondition for Stage B.
- No installation, manual Maps reproduction, publication, Gate, Release, commit, push, PR, merge, or parent closure.
- Do not inspect unrelated implementation areas. If a required test target or boundary is missing from the frozen inputs, identify one locator and mark the dependent criterion uncovered.

## Acceptance and coverage criteria

A complete review must answer all five questions above and verify:

- all current CI heavy jobs are represented: `format-swift`, `test-keyboardcore`, `test-rimebridge`, `test-app-keyboard`, `test-rime-sync-keychain`, and `build-release`;
- the Keychain check carries `CODE_SIGNING_ALLOWED=YES`, `CODE_SIGN_IDENTITY=-`, `CODE_SIGNING_REQUIRED=NO`, Swift 6 strict-concurrency settings, and the workflow's exact `-only-testing` selector;
- Simulator-backed jobs share one revalidated, freshly reserved exact UDID and do not boot or substitute a device before that reservation;
- the Reader/Main App assertions exercise all accepted protocol and fallback criteria; preexisting results are explicitly historical;
- a full candidate review after implementation requires a new numbered round and exact source/test manifest plus results.

Report `Pass`, `Pass with conditions`, `Partial / incomplete`, or `Block` with one finding per uncovered criterion. `Pass with conditions` requires complete coverage and explicit residuals.

## Reviewer operating limits

- Maximum budget: **20 tool calls or 20 active minutes, whichever occurs first**.
- Checkpoint: after 10 calls or 10 active minutes, whichever occurs first; record elapsed time, calls used, coverage, and remaining work.
- Stop on packet/baseline mismatch, out-of-scope dependency, missing test target, or budget exhaustion. Budget does not renew automatically.
- Only the Human Product Owner acting as Product Lead may approve an exact scope or budget expansion; the reviewer and Coordinator may not approve their own expansion. Any approved change requires a revised frozen packet and a new numbered round before review resumes.
- Usage record: `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r1-usage-2026-09-29.md`.
- Receipt: `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r1-review.md`.
