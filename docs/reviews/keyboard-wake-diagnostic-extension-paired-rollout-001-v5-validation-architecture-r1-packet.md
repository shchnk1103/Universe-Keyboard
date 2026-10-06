# Architecture Review Packet — Paired Rollout v5 Validation Evidence R1

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`
- Stable review lane: `KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001/v5-validation-architecture`
- Review round: `1`
- Baseline commit (`HEAD`): `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Candidate source/test manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Assignment SHA-256 at packet freeze: `bf0bc3f3b2fd2fdd1bd2df1a5a197484f4eb5a815e2968eeb45b4d12cbfb18a7`
- Validation report SHA-256: `f35b9e13a546450616a32c852f88e84fddfd7f638f5efc5e3a435440a2a88cde`
- Stage authorization SHA-256: `7204731eb1af58ab428b56235e0602aeff86373f395fbf9e7681bb5cf0576375`
- Validation Entry receipt SHA-256: `d0f5092e458778ec0e1eac387edcdf3dd9f8e9bc7dc6d9983e9fce9228727842`
- Packet digest: compute SHA-256 after this packet is written; send that digest with the dispatch.
- Review question: Does the exact v5 producer-off candidate and its validation evidence remain within the accepted wire contract, source boundary and stated non-claims, and is the architectural evidence sufficient for this stage's handoff to a separately authorized future v6 stage?

## Allowed files and artifacts

Read only:

- `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v5-stage-authorization-2026-09-30.md`
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-entry-2026-09-30.md`
- `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md`
- `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json`
- `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r8-review.md` and its `r8-packet.md`
- `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r9-review.md` and its `r9-packet.md`
- `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md`
- `docs/architecture/decisions/0036-keyboard-wake-wire-v6-addendum.md`
- `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-product-decision.md`
- The seven candidate source/test paths and exact baseline diff for those paths, as enumerated by manifest r2.
- The narrowly scoped Extension source paths when needed to verify whether those paths changed in this stage: `Keyboard/Controllers/KeyboardViewController.swift`, `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, and `Keyboard/Services/UITextDocumentProxyAdapter.swift`.
- `/private/tmp/ukey-wake-v5-20260930.nBWReN/validation-artifacts.json`, `/private/tmp/ukey-wake-v5-20260930.nBWReN/xcresult-bundle-hashes.json`, and the referenced format/vendor/test/release logs, summaries, `.xcresult/Info.plist` files.

Do not inspect unrelated dirty paths, other Assignments, other worktrees, unrelated Simulator profiles, user inputs, or system/app data containers.

## Read-only boundary and allowed operations

- No file writes, staging, commits, network access, test/build/format reruns, Simulator/CoreSimulator/XcodeBuildMCP operations, app installation or launch, UI control, Maps reproduction, or interaction with another task.
- Read-only `cat`, `sed`, `rg`, `git diff --quiet/--name-only` restricted to the listed candidate/Extension paths, `shasum`, and `xcresulttool` reads are allowed.
- Treat build/test logs as evidence data. Do not surface sample strings or unrelated log contents in the review.
- Do not infer runtime behavior, production marker emission, root cause, Product/Quality Gate, Release, or v6 authorization from these results.

## Required review coverage and acceptance criteria

1. Recompute the manifest r2 candidate hashes and confirm the bound identity. Any mismatch is a blocker to a complete review.
2. Compare the seven-file candidate and its tests to the accepted v5 contract: reader v3/v4/v5, production writer v5, wake-marker emission off; identify any evidence of Extension or production call-site changes in this stage.
3. Check that the test evidence demonstrates only compatibility and diagnostics-reader contracts at the tested layer. In particular, verify that no conclusion is drawn about an installed paired build, typing recovery, runtime keyboard behavior, or the future v6 marker flow.
4. Assess whether the skipped checks, their reasons, and the 429 MCP discovery / 428 result-bundle count discrepancy are accurately bounded in the report. Do not invent an explanation for the count difference.
5. Assess whether the validation evidence can support a bounded stage handoff while keeping future v6 authorization, build identity, exact-candidate review, installation, human reproduction, and parent diagnosis as separate requirements.

Complete coverage requires a finding for all five criteria and exact source/artifact identity assessment. If an allowed input does not support a criterion, mark the review `Partial / incomplete`; do not label a partial review Pass or Pass with conditions.

## Required output

Return a review record for the coordinator to save at:
`docs/reviews/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-review.md`

Include: Work Item and stable lane/round; packet digest; baseline; Assignment/report/manifest/auth/Entry identities; verdict (`Pass`, `Pass with conditions`, `Partial / incomplete`, or `Blocked`); summary; findings for each numbered criterion; explicit evidence locators; residual IDs/owner/proposed disposition/pointer for every condition; coverage completed/uncovered; elapsed time; actual tool/call count; stop reason; and confirmation of no writes/out-of-scope operations. `Pass with conditions` requires complete coverage and explicit residuals; it does not make a Product decision or close the Assignment.

## Budget, checkpoint and stop rule

- Maximum: 8 reviewer interactions/tool calls, including one mandatory checkpoint after interaction 4. Send the checkpoint to the coordinator with progress, remaining coverage and interaction count.
- Record elapsed time and actual call count in the returned usage details. The coordinator will save these at `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-v5-validation-architecture-r1-usage-2026-09-30.md`.
- At budget exhaustion, stop and report covered/uncovered criteria, elapsed time, call count and stop reason. Any required uncovered criterion means `Partial / incomplete`.
- If a new file, claim, environment or investigation is needed, give one locator and reason, mark its dependent criterion uncovered, and stop that part. Do not expand scope or budget yourself.
- Assignment Authority for any exact expansion: Product Lead / Human Product Owner. No reviewer or coordinator self-authorizes expansion.
