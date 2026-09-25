# Assignment: KOS-DEVICE-DISCOVERY-DIAGNOSTICS-001 — 设备发现诊断流程发布准备

Policy version: 1.0.0
Repository Change Type: Documentation — Environment procedure v1.1.0 amendment

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Reviewed — Architecture **Pass** and Human Product Owner publication acceptance recorded |
| Current phase | Environment Capture Procedure 1.1.0 was published by PR #171, merged as `2c3b0e242aa9a2465ffecc419a0266b894732f11`; its single post-merge M-02 synchronization is recorded below |
| Non-claims | No current CoreDevice/CoreSimulator/device health or device operation is claimed; this documentation publication does not make a Quality, Product Gate, TestFlight or Release conclusion |
| Next handoff / decision | None for this documentation publication. Any live host/device diagnosis or stateful simulator/device operation requires its own bounded Assignment and authority |
| Residuals | No publication-documentation residual is known. The underlying host-versus-Codex discovery symptom was not reproduced or resolved by this docs-only scope |

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner's explicit authorization in the current conversation, `2026-09-25 Asia/Shanghai`, first for the bounded documentation slice and then to accept the reviewed amendment for publication.
- **Product Approver:** Human Product Owner

## Objective

Prepare a reviewed procedure amendment for publication that keeps Simulator, connected-device, Device Hub, Accessibility Inspector and XCTest/XCUITest observations within their own diagnostic boundaries. The procedure helps an operator distinguish a host command result from a failure in a Codex-mediated or Xcode UI operation.

The local proposal and navigation are drafted, independently reviewed, and accepted for publication. The accepted text becomes the repository's current procedure when the publication is merged to the default branch.

## Scope

1. Amend the environment-capture procedure with the accepted diagnostic sequence and raise its version to 1.1.0.
2. Describe separate evidence for Xcode tool selection, CoreDevice/devicectl, CoreSimulator/simctl, Device Hub, Accessibility Inspector and XCTest/XCUITest.
3. Record exact operation, execution channel, duration, exit/status and bounded redacted output when a discovery or UI operation fails or times out.
4. Route relevant debugging, environment-evidence and knowledge-index readers to the accepted procedure section.
5. Record the Human Product Owner's publication acceptance and the independent Architecture result without presenting the user's reported host checks as current evidence.

## Non-goals

- Do not run xcrun, devicectl, simctl, Device Hub, Accessibility Inspector, XcodeBuildMCP, XCTest or XCUITest operations.
- Do not boot, shut down, install to, launch on, inspect, or otherwise change a simulator or physical device.
- Do not infer current device availability, CoreDevice/CoreSimulator health, or a root cause from the user's reported snapshot.
- Do not hardcode a simulator name or UDID as a reusable current target; rediscover the target for each future authorized task.
- Do not change Xcode selection, simulator services, automation routing, source code, tests, CI, KOS 2.0, the KOS Kit pin or Profile.
- Do not merge or release. Commit, push and PR remain distinct actions and require their own explicit action authorization.

## Required Inputs

- User-provided recommendation describing host checks, tool-layer distinctions, explicit simulator UDID use, timeout attribution and fallback.
- [Environment Capture Procedure](../ENVIRONMENT_CAPTURE_PROCEDURE.md), including its current tool-observation and publication rules.
- [Debugging Guide](../DEBUGGING.md), [Reading Maps](../READING_MAPS.md), [Knowledge Index](../KNOWLEDGE_INDEX.md), [Assignment Policy](../ASSIGNMENT_POLICY.md) and [Documentation Governance](../DOCUMENTATION_GOVERNANCE.md).
- Apple documentation for the documented tool roles:
  - [Xcode command-line tool reference](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference)
  - [Devices and Simulator](https://developer.apple.com/documentation/xcode/devices-and-simulator)
  - [Run your app on a simulated or physical device](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices)
- Baseline: isolated worktree at `codex/device-discovery-ops-001`, based on repository `main` commit `7c77312fe1bcc001e722cd632146722b031239fe`.
- The user's reported Xcode 27.0 / `devicectl` / `simctl` results are conversational context only; this Assignment does not rerun or independently attest them. The reported iPhone 17 UDID is intentionally omitted from reusable guidance because it is a volatile target.

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward — reusable diagnostic procedure and Source-of-Truth boundary.
- **Executor:** Current Codex primary session — authorized only for the documentation scope above.
- **Environment Executor:** Not Applicable — this slice is local documentation and static document checks only.
- **Human Dependency:** Not Applicable for drafting. Any future device operation requires a new Assignment naming the target and authorized operations.
- **Architecture Reviewer:** `/root/device_discovery_architecture_review` — fresh independent reviewer runtime; [review receipt](../reviews/kos-device-discovery-diagnostics-001-architecture-review.md), verdict **Pass**.
- **Quality Reviewer:** Not Applicable — this draft makes no product, device, test or Quality conclusion.
- **Product Approver:** Human Product Owner — accepted this amendment for publication on `2026-09-25 Asia/Shanghai`.

## Gates

### Entry Criteria

- Explicit user authorization for this bounded documentation slice.
- An isolated worktree based on the identified repository baseline.
- The accepted procedure and repository navigation sources inspected before editing.

### Exit Criteria

- The procedure separates command-line discovery from Device Hub, Accessibility and XCTest/XCUITest outcomes.
- The procedure requires exact operation/channel/status/duration evidence for failures and prohibits cross-layer health conclusions.
- All repository routes point to the accepted procedure and review record.
- Whitespace and changed-document internal-link checks pass.
- The final handoff links the independent Architecture result, records the merged publication pointer, and confirms that no device operation or current environment-health claim was made.

### Stop Conditions

- A requested claim would need fresh host/device evidence or an unapproved device operation.
- A change would alter accepted evidence fields, privacy rules, stop conditions or other procedure responsibilities beyond the reviewed diagnostic rules.
- A link or source conflict cannot be resolved without changing an accepted contract.
- Commit, push, PR, merge or release is requested without its separate explicit action authorization.

### Handoff

The procedure amendment was published by PR #171. The post-merge M-02 synchronization is recorded in the receipt below. No device operation, current environment finding or Release claim is part of this documentation Assignment. Any material change to the reviewed diagnostic rules requires a fresh bounded review.

### Lifecycle

The documentation amendment remains `Reviewed` after independent Architecture **Pass** and Human Product Owner publication acceptance. PR #171 is merged. The M-02 closeout records that publication state and does not change the Assignment lifecycle to `Closed` or authorize runtime/device validation.

### Revalidation Triggers

- Xcode or the relevant command-line tool behavior changes.
- The repository's accepted environment-capture procedure, evidence provenance or privacy contract changes.
- A future task requires current device evidence or stateful simulator/device operations.

## Accepted Diagnostic Boundary

The accepted procedure:

- treats `xcode-select`, `xcodebuild -version` and `xcrun --find` as tool-selection/resolution observations only;
- treats `xcrun devicectl list devices` as a CoreDevice/devicectl observation and `xcrun simctl list devices` as a separate CoreSimulator/simctl observation;
- does not treat Device Hub or Accessibility availability/timeouts as a CoreDevice health check;
- records the provider/execution channel so a host Terminal result is not silently generalized to a Codex-mediated tool operation;
- uses simctl for authorized simulator discovery and lifecycle operations, with every target-specific operation bound to a freshly discovered explicit UDID;
- attributes a timeout only to the exact operation that timed out, including its elapsed duration; it requires independent CLI observations before making a layer-specific availability claim;
- avoids repeated retries of a failing Device Hub/Accessibility operation and permits a fallback only when the current Assignment authorizes it.

## M-02 merge-trigger closeout

- Work Item: `KOS-DEVICE-DISCOVERY-DIAGNOSTICS-001`.
- Exact event: the lifecycle-changing merge that published Environment Capture Procedure 1.1.0.
- Authority record: this Assignment, including the Human Product Owner's recorded acceptance for publication; the prospective M-02 scope is defined by [PD-KOS-UPGRADE-UK-006](../product-decisions/KOS-UPGRADE-UK-006-v0.9.0-adoption.md).
- Merged tip: PR [#171](https://github.com/shchnk1103/Universe-Keyboard/pull/171), source tip `05f435460c55e3a528ee8011cb2b4e6f09e350ce`, based on `7c77312fe1bcc001e722cd632146722b031239fe`.
- Merge pointer: `2c3b0e242aa9a2465ffecc419a0266b894732f11`, merged at `2026-09-25T05:35:17Z` (`2026-09-25T13:35:17+08:00`).
- This trigger occurred on the effective date of the prospective UK-006 M-02 rule. The one post-merge synchronization is recorded in the [M-02 receipt](../evidence/kos-device-discovery-diagnostics-001-post-merge-state-sync-2026-09-25.md). The receipt's publication and administrative merge complete this same transaction; it does not recursively trigger another M-02 for this identity.

## History

- `2026-09-25 Asia/Shanghai` — Initial executor draft handoff, before independent review: Human had authorized this local documentation slice; the proposed procedure and navigation were drafted. No device command or UI operation, Architecture review, Product publication acceptance, commit, push or PR had yet occurred.
- `2026-09-25 Asia/Shanghai` — Fresh independent Architecture review recorded **Pass** with no P0–P3 findings. Receipt binds the five-file pre-status-sync package to manifest SHA-256 `9985853266a3a6fb6536c4aa5d82dd300e637961fd3cf20871b590de63ff17fc`. This entry synchronizes status only; it does not change the reviewed proposal text. No device operation, Product publication acceptance, commit, push or PR occurred.
- `2026-09-25 Asia/Shanghai` — Human Product Owner accepted the amendment for publication. Procedure version and route status were synchronized in the local candidate; the hosted repository remains unchanged. Commit, push, PR, merge and Release have not occurred.
- `2026-09-25 Asia/Shanghai` — Human authorized completion of the pre-archive work. The single M-02 closeout now records PR #171 and its merge pointer; its own publication and administrative merge complete this same trigger transaction. No device operation or runtime diagnosis was performed.
