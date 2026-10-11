# Architecture Review Packet: v3 Compatibility Gate — Round 1

## Frozen identity

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stable lane ID: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001/architecture`
- Review round: `1`
- Exact source baseline: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256: `f19ee343da3347c04f89fa0cf99bbf96c9e82d4b94fc16fdd3d56260fff38245`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Current `DiagnosticEvent.swift` SHA-256: `b67dbb084c6e7a3201e6b64e411532845df3fde2c1bee6f54462b022a0f3a534`
- Current `DiagnosticsLogSource.swift` SHA-256: `0d8efe45eb428d9ea05aa49bbf7dbebb83c7ab546fe11120c335a35a1447031c`
- Proposal 0.4 SHA-256: `e501a4075c24a79de560e7381ae361708c1a085250470e69840e23c930b53c06`
- ADR 0036 SHA-256: `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c`
- ADR acceptance SHA-256: `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d`
- Historical API manifest SHA-256: `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`
- Historical Reader candidate: `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7`
- Historical Main App consumer candidate: `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a`
- Historical Extension patch digest: `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d`
- Packet digest: compute SHA-256 over this file after freeze; pass the resulting digest in the dispatch and record it in the reviewer receipt.

## Claims and questions to decide

Review the exact Assignment and read-only current-source inputs. Decide whether the proposed compatibility contract can preserve schema-v5 behavior while adding explicit v3/v4/v5 reader compatibility, and define the new-marker boundary for this candidate.

1. State precisely what “v3 compatibility gate” means when current `DiagnosticEvent` is globally schema v5 and the current producer/reader path already handles schema-v5 `typo_recall` events.
2. Define how each record is validated by its own version across v3, v4, and v5, including mixed history. Confirm how unsupported/malformed records become query-level incomplete and suppress legacy fallback through continuation.
3. Define whether new lifecycle, RIME-resume, and text-proxy markers are producer-off in this compatibility candidate with isolated test-only fixtures, or whether another explicitly isolated scheme is required. Existing schema-v5 production behavior must remain intact.
4. Determine whether Proposal 0.4 / ADR 0036 needs an addendum or supersession. Distinguish Architecture authority from any further Product decision required.
5. Confirm single primary Domain Owner and cross-domain handoffs among Keyboard Experience, Input Intelligence, and App & Data Operations.

## Allowed review scope

- Read the frozen Assignment, Product Authorization, Proposal 0.4, ADR 0036 and acceptance evidence.
- Read current-base sources necessary to understand the contract: `DiagnosticEvent.swift`, `DiagnosticsJournal.swift`, `DiagnosticsJournalRuntime.swift`, `DiagnosticsJournalReader.swift` and its validator files, `DiagnosticsLogSource.swift`, `KeyboardViewController.swift`, `KeyboardViewController+Bootstrap.swift`, and `UITextDocumentProxyAdapter.swift`.
- Read the historical source/test manifest and prior API, Reader, Main App consumer, and Extension review records solely to understand what must be revalidated; do not treat their old candidate conclusions as review of this baseline.
- Read current `AGENTS.md`, `docs/ASSIGNMENT_POLICY.md`, `docs/AI_WORKFLOW.md`, `docs/VIRTUAL_ENGINEERING_TEAM.md`, and `.github/workflows/swift6-quality.yml` for the applicable process and ownership boundaries.
- The reviewer may use local read-only file, hash, and Git inspection. No code or document writes, tests, builds, Simulator/UI operations, installs, network requests, or edits to any worktree are permitted.

## Exclusions

- No root-cause investigation, behavior design, performance conclusion, new capture policy, journal retention change, App Group mutation, RIME deployment/session change, or runtime observation.
- No approval of implementation, production marker emission, Simulator validation, installation, manual reproduction, Product/Quality Gate, Release, commit, push, PR, merge, or parent closure.
- Do not inspect unrelated files or expand into another current feature. If a named claim cannot be decided from the allowed inputs, report the smallest locator and mark that claim uncovered.

## Acceptance and coverage criteria

A complete review must answer all five questions above and verify:

- Current v5 event codes/payloads, especially `typo_recall`, remain valid and are not relabeled or dropped by the compatibility change.
- v3/v4/v5 records are version-validated individually; mixed histories are not reinterpreted as one writer version.
- incomplete/unsupported status survives page continuation and prevents stale legacy fallback; only the owning Main App semantics are assigned to App & Data Operations.
- no new producer event becomes active before the Architecture boundary and Product authorization requirements are explicit.
- Proposal/ADR consequences and any required decision owner are identified without implying Product acceptance.

Report `Pass`, `Pass with conditions`, `Partial / incomplete`, or `Block` with one finding per uncovered criterion. `Pass with conditions` requires full criterion coverage and explicit residuals.

## Reviewer operating limits

- Maximum budget: **20 tool calls or 20 active minutes, whichever occurs first**.
- Checkpoint: after 10 calls or 10 active minutes, whichever occurs first; record elapsed time, calls used, coverage, and remaining work.
- Stop on packet/baseline mismatch, out-of-scope dependency, product decision requirement, or budget exhaustion. Budget does not renew automatically.
- Only the Human Product Owner acting as Product Lead may approve an exact scope or budget expansion; the reviewer and Coordinator may not approve their own expansion. Any approved change requires a revised frozen packet and a new numbered round before review resumes.
- Usage record: `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r1-usage-2026-09-29.md`.
- Receipt: `docs/reviews/keyboard-wake-diagnostic-v3-compatibility-gate-001-architecture-r1-review.md`.
