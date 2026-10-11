# Product Decision: RIME-SYNC-001 QR-CURRENT-01 MCP Discovery Count Residual

## Decision

**Accepted — bounded reporting residual for the exact runs listed below.**

The Human Product Owner accepts the one-count difference between XcodeBuildMCP's
`398 discovered` summary and the `397` test cases in the authoritative
`.xcresult` as an external discovery/preflight reporting residual for the
current Quality-reviewed Simulator run and its 2026-09-24 confirmation run.
For the two original exact test-products bundles, Xcode's native enumeration
produced 397 unique test identifiers, and each identifier set matches its
`.xcresult` case set exactly. On `2026-09-25`, the Human Product Owner separately
accepted the same bounded reporting residual for the new 402/401 run after the
native 401-ID set exactly matched that run's `.xcresult` IDs.

This is a Product acceptance of the reporting mismatch—not a claim that the
internal XcodeBuildMCP cause is known or repaired, and not a claim that a
missing or additional test exists.

## Evidence and authority

- Reconciliation receipt: [XcodeBuildMCP count reconciliation](../evidence/rime-sync-v1-xcodebuildmcp-count-reconciliation-2026-09-24.md).
- Additional exact-run receipt: [2026-09-25 full App + Keyboard suite](../evidence/rime-sync-v1-current-app-keyboard-full-suite-2026-09-25.md).
- Original current-snapshot Quality review remains unchanged:
  [Quality re-review](../reviews/rime-sync-v1-current-quality-rereview-2026-09-23.md).
- Parent Assignment: [RIME-SYNC-001](../assignments/rime-sync-001.md).
- Decision source: Human Product Owner instruction in the active task on
  `2026-09-24 Asia/Shanghai`: accept the discrepancy as an MCP discovery-count
  anomaly and use the exact identifier-set match as its disposition basis.
- Additional decision source: Human Product Owner instruction in the active
  task on `2026-09-25 Asia/Shanghai`: accept the new exact-run 402/401
  discrepancy on the same bounded basis.

## Scope and limits

- The original acceptance applies only to the cited 2026-09-23 Quality-reviewed
  and 2026-09-24 confirmation runs on iPhone 18 Pro / iOS 27.0 Simulator.
- The additional acceptance applies only to the 2026-09-25 iPhone 18 Pro / iOS
  27.0 Simulator run: 401 `.xcresult` cases, 391 passed, 10 skipped, 0 failed;
  native Xcode enumeration returned the same 401 unique IDs. The ten skipped
  tests are not passes.
- Together, these are two bounded acceptance instances of the same reporting
  residual, not a blanket acceptance of future MCP counts or any test result.
- No test-coverage claim is added; the identifier comparisons establish only
  that Xcode's enumerated sets and those two runs' result sets are identical.
- The underlying reason XcodeBuildMCP reported one extra discovered count
  remains unknown. Reopen this residual if a future run's Xcode enumeration
  and `.xcresult` case sets differ, or if a tool change materially changes the
  discovery behavior.

## Lifecycle and non-claims

This decision records `QR-CURRENT-01` as a bounded `accept` residual for the
listed exact runs in parent-close accounting. It does not itself close
RIME-SYNC-001 or authorize its lifecycle transition, independent final-package
reviews, merge, TestFlight or Release. Other close criteria and residuals
remain governed by the parent Assignment.
