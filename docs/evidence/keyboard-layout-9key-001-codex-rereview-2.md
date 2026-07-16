# KEYBOARD-LAYOUT-9KEY-001 — Codex Final Spike Gate Re-review

Reviewer: Codex (Architecture + Quality review)
Review date: 2026-07-16 Asia/Shanghai
Reviewed branch: `feature/keyboard-layout-9key-spike`
Reviewed HEAD: `0c357b4`
Reviewed handoff: [`keyboard-layout-9key-001-codex-handoff.md`](keyboard-layout-9key-001-codex-handoff.md)
Previous re-review: [`keyboard-layout-9key-001-codex-rereview.md`](keyboard-layout-9key-001-codex-rereview.md)
Assignment: [`../assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md)
Product Decision: [`../product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md`](../product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md)
ADR: [`../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md`](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md)

## Final Gate Decision

All blocking findings from the previous Codex re-review are closed.

- Product Decision Source: accepted.
- First Codex review restoration: accepted.
- Transferable raw Spike log archive: accepted.
- Hardened Spike technical result: accepted.
- ADR 0018 architecture contract: remains accepted.
- librime vendor upgrade: not required for V1 at this gate.
- Assignment lifecycle: authorized to transition `Ready -> Active` for implementation-plan steps 3–10.

Grok may update the Assignment lifecycle to `Active` in the next bounded implementation commit and proceed under the accepted plan, Assignment, Product Decision and ADR 0018.

This Gate acceptance does not mark product implementation complete and does not waive later automated, simulator, physical-device or Product acceptance requirements.

## Closure Verification

### P1 — Stable Product Decision Source: Closed

The repository now contains stable Product Decision `PD-KEYBOARD-LAYOUT-9KEY-001` at:

`docs/product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md`

It records:

- Human Product Owner as Product Approver;
- Grok as Executor;
- Codex as Architecture/Quality gate reviewer;
- authorization wording, date and timezone;
- the plan/Assignment/ADR boundaries;
- the additional conditions required before entering `Active`.

The Assignment points to this record as its Decision Source rather than treating the implementation plan or conversation alone as authority.

### P1 — First Codex review immutability: Closed

`docs/evidence/keyboard-layout-9key-001-codex-review.md` has been restored to the original Codex-authored review content. Executor-added “historical/superseded” text was removed.

Status progression is now recorded in separate review documents rather than by rewriting the first review.

### P1 — Transferable full raw log: Closed

The complete xcodebuild log is tracked as:

`docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz`

Verified from the Git object at reviewed HEAD:

- compressed `.gz` SHA-256: `724303a0b3d22783766bcd9e1b1bc76290dc81d79f1c5c5afe7e363ddca8e181`;
- decompressed raw-log SHA-256: `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651`;
- gzip integrity check: passed.

The decompressed log contains the expected selected XCTest pass, `TEST SUCCEEDED`, schema `t9`, raw input `64`, 9 candidates, first candidate comment `ni`, and deletion result `6`.

The known `essay` read-only warning is preserved in the full log and remains a productization investigation item; it does not invalidate the narrow Spike.

### P2 — Whole tracked worktree cleanliness rule: Closed prospectively

The current runner now:

- requires `git diff-index --quiet HEAD --` before the archival test;
- rejects tracked changes outside HEAD;
- rejects untracked source under package, script, app and test source roots;
- requires both the XCTest and runner to exist in the recorded commit;
- records a status digest for subsequent archival runs.

The hardened historical run remains associated with harness commit `337dd30ab443ad2d2af497648910946d6beb1a35`. That version enforced clean test/runner provenance but predated the whole-worktree check. The previous Codex re-review explicitly classified this as non-blocking and found no product-code contamination in the reviewed commit history.

Therefore no retroactive rerun is required solely for this runner improvement. Any future archival Spike run must use the new whole-worktree rule. Provenance text describing that rule must be read as the policy for archival runs going forward, not as a claim that the historical `337dd30` run executed code added later.

## Accepted Spike Facts

- Upstream schema SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`.
- Patched schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`.
- Compatibility patch removes `t9_processor`; required digit algebra remains.
- Runtime librime version reported by Bridge: `1.16.1`.
- Vendor structural verification succeeded and failure is fatal in the hardened runner.
- Effective schema selected by the Spike: `t9`.
- Input `64` produced non-empty preedit and 9 candidates.
- First candidate comment recorded by the hardened test: `ni`.
- BackSpace reduced raw input from `64` to `6`.
- Formal user App Group RIME data was not the Spike deployment destination.

## Implementation Authorization Boundary

The Executor is authorized to begin implementation-plan steps 3–10 only after recording the Assignment transition to `Active`.

Implementation must continue to obey:

- 26-key as the safe/default fallback;
- Chinese-only nine-key and English QWERTY;
- main App as the only deployment/readiness writer;
- versioned/fingerprinted T9 readiness;
- effective base-scheme/T9-scheme separation;
- ordered enable, disable and uninstall writes;
- no raw T9 digit commit to the host under Return, language switch or automatic-English transitions;
- no librime vendor replacement without a new stop-condition review;
- no expansion into V1 non-goals.

## Required Next Handoff

After product implementation, Grok must provide a new Codex review handoff containing at least:

1. Assignment lifecycle/history and final changed-file allowlist.
2. Effective-scheme, readiness and T9 preedit/input-semantics unit tests.
3. Main-App install/deploy/verify/failure/uninstall evidence.
4. RimeBridge session-recovery and no-raw-digit-commit evidence.
5. Debug and Release build results.
6. Light/dark, compact-width, Dynamic Type and accessibility evidence.
7. Physical-device acceptance or explicit Human Dependency status.
8. Investigation outcome for the `essay` read-only warning.
9. Documentation and CHANGELOG impact.
10. Unrun verification, known limits and residual risks.

Product implementation completion, Quality acceptance and Product Gate remain open until that later handoff is reviewed.
