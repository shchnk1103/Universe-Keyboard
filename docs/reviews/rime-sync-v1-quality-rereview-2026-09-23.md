# RIME-SYNC-001 Simulator Quality Re-review — 2026-09-23

## Review identity

| Field | Value |
|---|---|
| Verdict | `Pass with conditions` — bounded to the Simulator evidence in this review |
| Reviewer | Independent Quality reviewer, GPT-6 Luna (`Darwin`; agent `01a0ce4b-d558-7903-bb65-883390c9e56c`) |
| Base | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate | Exact uncommitted snapshot in `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` at review time |
| Snapshot evidence | Remediation record SHA-256 `f443271b9dc08745806d8e5d5e205da3d58464e706c302640100ba599de05811`; its manifest excludes itself |
| Simulator | iPhone 18 Pro / iOS 27.0, `405D994F-28CB-4F89-BB22-B64AD81C05A2` |
| Review mode | Independent, read-only; no files or devices changed by reviewer |

Reviewer independently enumerated 25 changed/added paths and verified the 24
non-self files in the remediation manifest: 24/24 SHA-256 values matched.
This review does not overwrite the historical Hegel review or the first fresh
Aquinas review.

## Original finding disposition

| Finding | Disposition | Basis and condition |
|---|---|---|
| Unsigned Keychain entitlement handling and CI lane | `Resolved with conditions` | Unsigned integration skips only for the read-only `errSecMissingEntitlement` result; other outcomes fail. Ad-hoc-signed Simulator Keychain CRUD passed 1/1 and the focused lane is included in the fail-closed CI gate. No hosted GitHub run exists, so hosted CI is not claimed green. |
| UI fixture could affect production preferences, secrets, or background scheduling | `Resolved` | Each UI launch uses a unique defaults suite and in-memory secret store. DEBUG fixture skips BGTask registration; ViewModel scheduling is disabled; foreground/background lifecycle paths avoid automatic sync, scheduler refresh, backup, and deployment. Corrected UI suite passed 8/8. This is fixture-isolation evidence, not production device acceptance. |
| XcodeBuildMCP discovery count differed from executed count | `Resolved as a bounded evidence discrepancy; cause UNKNOWN` | The authoritative xcresult is 395 total = 385 passed + 10 skipped + 0 failed. The two XCTest binaries expose 395 unique method names, matching the 395 normalized xcresult test IDs with empty differences in both directions. No missing test method explains the extra discovery tally. The source/raw output for `396 discovered` and why the tool over-counted were not present in the referenced result bundle/log; retain both facts and do not count 396 as executed. This unknown does not block this bounded verdict. |

## Evidence reviewed

- Repository entry instructions, Knowledge Index, Reading Maps, current
  Assignment and active-work ledger.
- Historical Hegel review, first fresh Aquinas review, remediation manifest,
  closure-readiness evidence, related source/test/CI changes, and the simulator
  result bundles and build logs cited by the remediation record.
- Full App + Keyboard XCTest: 395 total (385 passed, 10 skipped, 0 failed).
  The ten skips were accounted for as one RIME artifact, one expected unsigned
  Keychain entitlement, five scheme-coexistence fixtures, and three
  authorization-gated TD-012 device tests; skips are not passes.
- Corrected RIME settings UI suite: 8 passed, 0 skipped, 0 failed.
- Ad-hoc-signed Simulator Keychain integration: 1 passed, 0 skipped, 0 failed.
- Release Simulator build and source/test/CI hash manifest.

## Limits and remaining conditions

- `UI-02` remains Human-attested only: the Product Owner reported VoiceOver and
  enlarged-text checks on iPhone 13 Pro / iOS 27.0, but there is no screenshot
  or audio receipt and no source commit/executable digest for the installed
  app. This review does not independently validate that device observation.
- Simulator evidence does not prove physical-device Keychain behavior,
  production background-task delivery, provider-side deletion semantics,
  authentication/wrong-key recovery, or actual disconnect completion.
- The original discovery tally's raw source and one-count cause remain
  `UNKNOWN`; preserve that non-claim and capture the raw MCP output if another
  comparable run is performed.
- Hosted CI has not run. This verdict is not a merge-readiness claim, formal
  Architecture review, Product Gate, parent closure, TestFlight, or Release
  approval. `RIME-SYNC-001` remains `Active`.
