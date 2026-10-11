# Architecture Review Packet: V3 Compatibility Gate — Round 2

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane ID: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/architecture`
- Review round: `2`
- Exact source baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Proposal addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- Architecture R1 receipt SHA-256: `7bf40f54d12dcae70f883716b0564372ded88ad86043b81924840a4246bd6fe8`
- Quality R1 receipt SHA-256: `0c3500edb3e1172b74fb19d52622e655bc487db94cf5c88b3ee2a890e4a40461`
- Packet digest: compute SHA-256 over this file after freeze; include the resulting digest in the dispatch and reviewer receipt.

## Claims and questions to decide

Review whether the exact Assignment and addenda faithfully resolve Architecture R1 without broadening the accepted Product Authorization.

1. Do the Assignment and addenda accurately record that production stays on schema v5, including `typo_recall`, and that current events are not relabeled or downgraded?
2. Is the new-marker boundary precise: producer-off in the production Extension; v4 marker payloads allowed only in isolated temporary/in-memory fixtures that do not use App Group, production `DiagnosticsJournalRuntime`, or real Extension ingress?
3. Does the reader contract explicitly validate v3, v4, and v5 records individually, permit valid mixed retained history, preserve bounded incomplete status through continuation, and suppress legacy fallback except for a known-complete empty v1 result?
4. Do the addenda preserve the historical Proposal 0.4 / ADR 0036 bodies and defer future production marker-version, production mixed-writer, fallback-contract, and duplicate-key parser decisions to a separate Product/Architecture decision?
5. Does the Assignment scope remain within the existing human authorization and preserve the single Keyboard Experience Domain Owner plus Input Intelligence and App & Data Operations handoffs?

## Allowed review scope

- Read the exact Assignment, Product Authorization, Proposal 0.4 addendum, ADR 0036 addendum, Proposal 0.4, ADR 0036, and the R1 receipts named above.
- Read current-base `DiagnosticEvent.swift`, `DiagnosticsJournal.swift`, `DiagnosticsJournalRuntime.swift`, `DiagnosticsJournalReader.swift` and validator files, `DiagnosticsLogSource.swift`, `KeyboardViewController.swift`, `KeyboardViewController+Bootstrap.swift`, and `UITextDocumentProxyAdapter.swift` only as needed to validate the recorded current-v5 boundary.
- Use local read-only file and hash inspection. No source or document writes, tests, builds, Simulator/UI operations, installs, network requests, or edits to any worktree.

## Exclusions

- No fresh root-cause investigation, runtime observation, producer implementation, behavior design, performance claim, or review of a source/test candidate.
- No approval of app installation, production marker emission, manual reproduction, Product/Quality Gate, Release, commit, push, PR, merge, or parent closure.
- Do not inspect unrelated files. If a required claim is not supported by this frozen input set, identify its narrow locator and mark it uncovered.

## Acceptance and coverage criteria

A complete review must:

- answer all five questions above;
- identify any mismatch between the R1 decision and this exact revision;
- state whether any remaining change would exceed the existing Product Authorization;
- preserve the R1 distinction between a contract review and later exact-candidate review;
- report `Pass`, `Pass with conditions`, `Partial / incomplete`, or `Block`, with explicit residuals for a conditional result.

## Reviewer operating limits

- Maximum budget: **12 tool calls or 12 active minutes, whichever occurs first**.
- Checkpoint: after 6 calls or 6 active minutes, whichever occurs first; record elapsed time, calls, coverage, and remaining work.
- Stop on identity mismatch, out-of-scope dependency, new Product decision requirement, or budget exhaustion. Budget does not renew automatically.
- Only the Human Product Owner acting as Product Lead may approve an exact scope or budget expansion. Any approved change requires a revised frozen packet and a new numbered round before review resumes.
- Usage record: `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r2-usage-2026-09-29.md`.
- Receipt: `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r2-review.md`.
