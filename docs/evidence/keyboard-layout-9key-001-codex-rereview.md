# KEYBOARD-LAYOUT-9KEY-001 — Codex Amendment Re-review

Reviewer: Codex (Architecture + Quality review)
Review date: 2026-07-16 Asia/Shanghai
Reviewed branch: `feature/keyboard-layout-9key-spike`
Reviewed HEAD: `d8d04e0`
Reviewed handoff: [`keyboard-layout-9key-001-codex-handoff.md`](keyboard-layout-9key-001-codex-handoff.md)
First review: [`keyboard-layout-9key-001-codex-review.md`](keyboard-layout-9key-001-codex-review.md)
Assignment: [`../assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md)
ADR: [`../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md`](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md)

## Re-review Decision

The architecture and technical Spike amendments are substantially correct:

- ADR 0018 architecture content is accepted by this re-review.
- The hardened T9 Spike technical conclusion is accepted.
- No librime vendor upgrade is required at this gate.
- Assignment remains `Ready`.
- Evidence archival remains unaccepted until the P1 findings below are resolved.
- Product implementation steps 3–10 must not start until those P1 findings are resolved and the Assignment validly enters `Active`.

## Blocking Findings

### [P1] Assignment Decision Source still lacks a stable identifier

Location: `docs/assignments/keyboard-layout-9key-001.md:12-15`

The revised Decision Source describes an “active Grok task session” but provides no task ID, URL, stable title or independent Product Decision record. A repository-only reviewer still cannot locate and verify the authorization.

Required correction:

1. Add a stable Grok/Product task identifier or link; or
2. add a repository Product Decision/handoff record containing the Human Product Owner's authorization wording, date, timezone and named Executor/reviewer; and
3. point the Assignment Decision Source at that stable record before moving from `Ready` to `Active`.

### [P1] Executor modified a Codex-authored historical review

Location: `docs/evidence/keyboard-layout-9key-001-codex-review.md:1-7`

The “Historical record / Superseded” banner was added by Grok after the first Codex review. An Executor must not rewrite a reviewer-authored evidence record, even to add lifecycle context.

Required correction:

1. Restore the first Codex review document to the exact Codex-authored content.
2. Keep that review immutable as the first-review record.
3. Use this separate re-review document and the current handoff to record status progression.
4. Do not label or alter a reviewer conclusion from an Executor-owned commit.

### [P1] Full raw xcodebuild log is not in the transferable evidence archive

Locations:

- `docs/assignments/keyboard-layout-9key-001.md:107`
- `docs/plans/keyboard-layout-9key-implementation-plan.md:277`
- `docs/evidence/keyboard-layout-9key-001/archive-hashes.md`

The Assignment and plan require raw logs. The branch currently tracks only a curated xcodebuild excerpt plus the SHA-256 of a full log stored under the local gitignored evidence directory.

A digest can verify a file after it is obtained, but cannot reconstruct or let another reviewer inspect a missing file. The current archive therefore still depends on this machine.

Required correction:

1. Add the complete xcodebuild log to the transferable archive, preferably compressed, for example:
   `docs/evidence/keyboard-layout-9key-001/xcodebuild-t9-spike.log.gz`.
2. Record SHA-256 for both the compressed artifact and the decompressed raw log.
3. Keep the existing concise excerpt for quick review.
4. Verify a fresh clone can locate and inspect the full archived log without the local gitignored directory.

## Non-blocking Finding

### [P2] Harness commit check does not cover all tested tracked source

Location: `scripts/run_t9_compatibility_spike.sh:130-145`

The runner checks only the XCTest and runner for uncommitted modifications. Changes to RimeBridge, `RimeDeploymentService`, project configuration or other linked source could still influence the run while provenance records only HEAD as the harness commit.

No such product-code contamination was found in this reviewed commit history, so the current technical result remains credible.

Required correction before the next archival run:

1. Require the complete tracked worktree to be clean; or
2. archive a full tracked diff/status and bind its digest to provenance.

Ignored evidence output directories may remain outside this cleanliness check.

## Confirmed Resolutions From The First Review

- The Assignment lifecycle was corrected from the invalid early `Active` claim to `Ready`.
- ADR 0018 no longer permits implementation under `Proposed` status.
- ADR 0018 defines versioned/fingerprinted T9 readiness.
- Enable order is `install → deploy → verify → readiness → nineKey`.
- Disable/uninstall order starts by persisting `twentySixKey`, then invalidates readiness, then removes resources.
- Switching away from rime-ice preserves valid readiness when T9 resources remain intact.
- Interruption recovery is defined at every lifecycle boundary.
- T9 Return, language switch and automatic-English transitions unconditionally forbid raw-digit host commits.
- No-candidate Space/Return behavior is explicitly defined.
- Spike assertions independently require non-empty preedit and non-empty candidates.
- First candidate comment is recorded (`ni` in the hardened run).
- Vendor verification failure now fails the Spike.
- Harness commit `337dd30ab443ad2d2af497648910946d6beb1a35` contains the XCTest and runner.
- Local full-log and vendor-log hashes match the tracked provenance values.
- Current branch diff passes `git diff --check`.

## Accepted ADR Boundary

ADR 0018 is ratified by this re-review as the architecture contract for implementation, including:

- base scheme versus effective T9 scheme separation;
- versioned readiness and resource fingerprinting;
- main-App deployment ownership;
- ordered lifecycle writes and interruption recovery;
- safe 26-key fallback;
- no raw T9 digit commit to the host;
- no mandatory librime upgrade for V1.

This architecture acceptance does not override the unresolved Assignment/evidence gates above.

## Re-review Exit Criteria

Grok may request the next Codex review after providing:

1. A stable, repository-verifiable Product Decision Source.
2. The first Codex review restored without Executor-added text.
3. The complete raw xcodebuild log in a transferable archive with hashes.
4. A whole-tracked-worktree cleanliness rule in the Spike runner, or equivalent recorded diff provenance.
5. A clean working tree and `git diff --check` result.

Until the three P1 items are closed, keep Assignment status `Ready` and do not start product implementation steps 3–10.
