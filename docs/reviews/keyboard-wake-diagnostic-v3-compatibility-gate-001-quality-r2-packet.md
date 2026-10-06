# Quality Review Packet: V3 Compatibility Gate — Round 2

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane ID: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/quality`
- Review round: `2`
- Exact source baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Proposal addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- Quality R1 receipt SHA-256: `0c3500edb3e1172b74fb19d52622e655bc487db94cf5c88b3ee2a890e4a40461`
- CI workflow SHA-256: `cb4a41108ba0e9268b04b1aaca8bd06480da3e0dd8706221acbbce3ad6a0a6a8`
- Packet digest: compute SHA-256 over this file after freeze; include the resulting digest in the dispatch and reviewer receipt.

## Claims and questions to decide

Review whether the producer-off boundary and test-fixture isolation remain compatible with the complete, executable candidate validation plan.

1. Does the integrated test plan still cover the Runtime API, reader, Main App consumer, and compatible Extension surfaces without relying on a production wake-marker call site?
2. Are isolated v4 marker fixtures and v3/v4/v5 mixed-history tests specified so they cannot write to the real App Group or call production Extension ingress?
3. Does the matrix prove strict per-record validation, retained v5 `typo_recall`, query-wide incomplete continuation, and Main App legacy-fallback suppression in the integrated candidate?
4. Does the plan retain all six current heavy CI jobs, including the exact signed Keychain test, and require the pinned RIME digest check?
5. Are Stage A and Stage B still separated, with a fresh exclusive exact-UDID reservation required for all Simulator-backed validation?

## Allowed review scope

- Read the exact Assignment, Product Authorization, Proposal 0.4 addendum, ADR 0036 addendum, Quality R1 receipt, current CI workflow, and only the current source/test paths needed to answer the questions above.
- Treat all predecessor test/evidence digests as historical inputs, not candidate evidence.
- Use local read-only file and hash inspection. No source or document writes, tests, builds, Simulator/UI operations, installs, network requests, or edits to any worktree.

## Exclusions

- No Architecture decision on the persisted protocol, no product behavior or root-cause review, and no Quality Gate on an implementation candidate.
- No Simulator availability/exclusivity assertion; fresh exclusive reservation remains an execution-time prerequisite.
- No installation, manual Maps reproduction, publication, Gate, Release, commit, push, PR, merge, or parent closure.
- Do not inspect unrelated implementation areas. If any required test target or boundary is missing, identify the narrow locator and mark the affected claim uncovered.

## Acceptance and coverage criteria

A complete review must:

- answer all five questions above;
- verify current schema-v5 production behavior remains protected and new marker production remains off;
- confirm test fixtures use isolated storage and candidate-specific test results are required;
- verify the six-job matrix, exact signed Keychain selector/settings, pinned RIME identity, and one-UDID reservation requirement remain complete;
- state whether the producer-off boundary removes or introduces any required validation target;
- report `Pass`, `Pass with conditions`, `Partial / incomplete`, or `Block`, with explicit residuals for a conditional result.

## Reviewer operating limits

- Maximum budget: **12 tool calls or 12 active minutes, whichever occurs first**.
- Checkpoint: after 6 calls or 6 active minutes, whichever occurs first; record elapsed time, calls, coverage, and remaining work.
- Stop on identity mismatch, missing target, out-of-scope dependency, or budget exhaustion. Budget does not renew automatically.
- Only the Human Product Owner acting as Product Lead may approve an exact scope or budget expansion. Any approved change requires a revised frozen packet and a new numbered round before review resumes.
- Usage record: `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r2-usage-2026-09-29.md`.
- Receipt: `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-quality-r2-review.md`.
