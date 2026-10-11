# Assignment: RIME-SYNC-001 — Portable RIME Settings Sync

**Policy version:** `1.0.0`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Closed` — Human Product Owner decision `PD-RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25` |
| **Phase** | Bounded iOS V1 local-folder engineering was delivered, independently reviewed and published by [PR #182](https://github.com/shchnk1103/Universe-Keyboard/pull/182), merged as `8e4ea0f1777f1175141731797afeee5ebd964c96` on `2026-09-27`. The `2026-09-25` lifecycle path remains `Active → Completed → Reviewed → Closed`; this M-02 record synchronizes the later merge pointer without reopening the Assignment. |
| **Non-claims** | 10 skips remain unverified; 402 is not executed-test count and MCP cause remains unknown. Manual deletion is one Simulator Apple Files LocalStorage observation, not an XCTest pass and not evidence of Files UI refresh, physical device, cloud/provider propagation or cross-platform behavior. `TD-002`, `TD-008`, `TD-013`, `TD-017`, `TD-019` remain open/deferred as documented; CloudKit deferred. The engineering merge does not imply Product Gate, TestFlight or Release authorization/pass. |
| **Next** | No further work remains under this Closed engineering Assignment. The post-merge status sync is recorded in the linked M-02 receipt; retained debts and deferred providers stay separately tracked and require their own bounded authorization. |
| **Residuals** | [`Post-merge M-02 state sync`](../evidence/rime-sync-001-post-merge-state-sync-2026-09-27.md) · [`Product lifecycle close decision`](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md) · [`Close readiness ledger`](../evidence/rime-sync-v1-closure-readiness-2026-09-23.md) · [`Final Quality review`](../reviews/rime-sync-v1-parent-final-quality-sync-rereview-2026-09-25.md) · [`Final Architecture review`](../reviews/rime-sync-v1-parent-final-architecture-sync-rereview-2026-09-25.md) · [`Manual provider evidence`](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md) · [`TD-002`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access) · [`TD-008`](../TECH_DEBT.md#td-008-complete-portable-rime-data-compatibility) · [`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化) · [`TD-017`](../TECH_DEBT.md#td-017-investigate-background-sync-sandbox-extension-consume-failure) · [`TD-019`](../TECH_DEBT.md#td-019-live-webdav-provider-validation) |

## Product Lifecycle Close Decision — 2026-09-25

> **Superseded for current publication status:** PR #182 was merged on
> `2026-09-27` as `8e4ea0f1777f1175141731797afeee5ebd964c96`. This decision
> recorded the bounded engineering Close and did not itself authorize that
> later merge. See the [post-merge M-02 state sync](../evidence/rime-sync-001-post-merge-state-sync-2026-09-27.md).

The Human Product Owner accepted the bounded iOS V1 local-folder scope and
the explicitly listed open technical debts, then authorized recording the
parent lifecycle decision. Product Lead recorded [`PD-RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25`](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md)
as **Accepted / Closed**. The decision preserves the 401/391/10/0 test result,
the prior failed deletion XCTest, all evidence limitations, and the open debt
records; it does not imply Product Gate, publication, merge, TestFlight, or
Release.

**Current implementation note — `2026-09-24`:** P1/P2 deletion-boundary
remediation is implemented and five focused tests pass. The fresh Architecture
review is `Accept with conditions` on the exact 44-path snapshot
`2c09ee2f…75a4d2a`; the two code-level deletion findings are resolved. The
provider metadata/deletion evidence condition remains open, and
`ARCH-RIME-SYNC-001-P1-02` remains `tech_debt:TD-002`. See the
[Architecture receipt](../reviews/rime-sync-v1-final-architecture-rereview-2026-09-24.md)
and [remediation evidence](../evidence/rime-sync-v1-p2-deletion-boundary-remediation-2026-09-24.md).

**Local-folder first-sync supplement — `2026-09-24`:** A fresh iPhone 18 Pro Max
iOS 27.0 Simulator UI test used the production ViewModel, Keychain and
local-folder transport, selected a newly created Files-provider folder, and
completed the explicitly confirmed first manual sync. Read-only filename and
format-metadata checks found RIME standard outputs plus the encrypted V1
settings package. The result bundle and limitations are recorded in the
[first-sync receipt](../evidence/rime-sync-v1-local-folder-simulator-first-sync-2026-09-24.md).
This is new evidence after the 44-path Architecture and Quality receipts;
those reviews do not cover this snapshot. It does not exercise package deletion,
which remains an open provider-evidence condition.

**Manual local-provider deletion supplement — `2026-09-25`:** In the same
iPhone 18 Pro Max / iOS 27.0 Simulator, the App completed a confirmed manual
sync to a newly created folder, then its explicit delete-and-disconnect flow
returned to an unconfigured provider state. An immediate read-only listing of
that exact provider root showed `universe-rime-sync/` absent and the
`universe-ios-b7640898-217b-44b8-b4b1-6b4cf2128bc1/` standard RIME directory
still present. The evidence is manual and not an XCTest pass; no recovery-code
value or file content was recorded. The installed app was 1.0 (1), but its
binary digest/source binding was not frozen. Fresh independent Quality and
Architecture reviews of the exact 64-path candidate returned Quality `Pass
with conditions` and Architecture `Accept with conditions`. Quality resolved
`QR-PROVIDER-DELETE-01` as `fix` for this bounded observed-state check; the old
UI XCTest remains failed and binary provenance/capture-operation correlation
remain limited. See the [manual provider receipt](../evidence/rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md),
[Quality receipt](../reviews/rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md),
and [Architecture receipt](../reviews/rime-sync-v1-local-folder-provider-deletion-architecture-manual-review-2026-09-25.md).

**Full UI regression supplement — `2026-09-25`:** After correcting the
iOS 27 picker Cancel query to match its generic accessibility role, the full
`UniverseKeyboardUITests` run passed 29 of 36 tests, skipped 7 specialized or
opt-in cases, and had no failures. Both the picker-cancel regression and the
production-path first-sync case passed in the full sequence. See the
[executor-recorded receipt](../evidence/rime-sync-v1-local-folder-full-ui-regression-2026-09-25.md).
Fresh Quality and Architecture reviews of the updated exact candidate are
pending at this UI-only checkpoint; this was superseded by the final paired
68-path parent reviews and Product lifecycle decision below.

**Full App + Keyboard suite supplement — `2026-09-25`:** The current worktree
completed the `Universe Keyboard` Debug scheme on iPhone 18 Pro / iOS 27.0
Simulator: `.xcresult` 401 total, 391 passed, 10 skipped, 0 failed. Xcode's
native enumeration returned 401 unique IDs and exactly matched the result IDs.
XcodeBuildMCP separately reported 402 discovered; the underlying extra count
remains unknown. The Human Product Owner accepted this exact-run reporting
residual under the existing [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md).
See the [executor receipt](../evidence/rime-sync-v1-current-app-keyboard-full-suite-2026-09-25.md).
This is not the complete CI heavy-job matrix. At this evidence checkpoint the
parent still awaited provider deletion disposition and Product lifecycle
decision; both were subsequently recorded below.

**Current App + Keyboard review delta — `2026-09-25`:** After the exact-run
Product disposition and current-state synchronization, fresh independent
Quality is [`Pass with conditions`](../reviews/rime-sync-v1-current-app-keyboard-quality-delta-review-2026-09-25.md)
and Architecture is [`Accept with conditions`](../reviews/rime-sync-v1-current-app-keyboard-architecture-delta-review-2026-09-25.md)
on the 53-path manifest `eb3ab8b044421895c2b298520c39c485ebcf961f8c0c145127391f3cd05f2920`.
The stale count/status findings were resolved for this 53-path checkpoint.
At that point provider deletion and lifecycle remained open; later 64/68-path
reviews and the Product lifecycle decision below supersede this checkpoint.
`TD-002` remains open. Exact reviewer model/runtime identity was not
independently attestable.

---

**Decision source / date:** Human Product Owner authorization in the active cross-platform RIME sync objective, followed by explicit approval of RIME 标准同步主路径 / `2026-07-12 Asia/Shanghai`; manual RIME 用户词典安全恢复与设置入口调整、automatic-sync cooldown revalidated / `2026-07-13 Asia/Shanghai`; foreground cooldown consistency plus start/success/failure notifications, explicit user opt-in for automatic sync, independently selectable RIME standard / Universe settings scopes, migration of RIME notifications into the shared App notification settings contract, and independent notification-only controls for both sync parts, revalidated by the human Product Owner / `2026-07-15 Asia/Shanghai`

**Repository change types:** `Contract`, `Documentation`; later `Implementation`, `Evidence`, `State`

## Product Scope Disposition — V1 Closure

**Decision source / date:** Human Product Owner authorization in the active
RIME-SYNC-001 conversation / `2026-09-23 Asia/Shanghai`.

- The current parent closure is bounded to the delivered iOS V1 local-folder
  path: RIME standard sync and the encrypted Universe settings package through
  one user-selected local folder, Main-App-only orchestration, and their scoped
  UI, security and independent-review evidence.
- **Live WebDAV validation is explicitly deferred to `TD-019`** by the Human
  Product Owner on `2026-09-24 Asia/Shanghai`. The WebDAV implementation and UI
  remain in the app, but the current closure makes no live-server authentication,
  conditional-write, conflict or durable-deletion claim. Re-entry requires a
  separately bounded validation Assignment and explicit authorization for its
  test namespace and any remote mutations.
- **CloudKit/iCloud is explicitly deferred** as a later Apple-platform adapter.
  It is not an Exit Criterion or blocker for this bounded V1 closure. It may be
  re-entered only after the existing membership, container, entitlement and
  physical-device prerequisites are verified under a separately reviewed
  implementation/validation scope.
- **Full cross-platform compatibility is explicitly deferred to `TD-008`.**
  Representative iOS/macOS/Windows/Linux/Android fixture round-trips, full
  scheme portability and safe cross-device custom YAML/TXT import are outside
  this bounded V1 closure. Existing safety prohibitions remain: no live userdb
  copying, no automatic YAML import/overwrite and no full scheme-directory
  copying.
- This disposition narrows the current closure target; it does not mark the
  deferred work complete or close `TD-008`. UI-01 and security evidence remain
  required; UI-02's two accepted residuals are covered only by the separate
  [2026-09-24 Product Decision](../product-decisions/RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md).
  Independent Architecture, Quality and Product conclusions for parent close
  remain required.
- **`TD-002` is explicitly retained as `tech_debt:TD-002`** by Human Product
  Owner authorization on `2026-09-23 Asia/Shanghai`. The cross-process RIME /
  Keyboard Extension concurrency risk remains open; this disposition does not
  claim mitigation, technical resolution or risk-free acceptance.

## Parent Close Boundary — fulfilled `2026-09-25`

The two September natural-background successes close active engineering
observation of the automatic-sync sub-path. They do not by themselves change
the lifecycle of this broader portable-sync Assignment. Under the Assignment
Policy and KOS 2.1 M-03, the parent can leave `ACTIVE_WORK` only when all of the
following are recorded:

1. **Scope decision:** Product Lead has bounded this closure to the iOS V1
   local-folder path above; live WebDAV validation is tracked by `TD-019`,
   CloudKit is deferred and full cross-platform compatibility is tracked by
   `TD-008`. The two automatic-sync observations alone do not satisfy package,
   transport, conflict, UI, security or review criteria.
2. **Residual dispositions:** every residual has one allowed disposition
   (`fix`, `accept` or `tech_debt:<ID>`), including explicit treatment of the
   retained formal `Run 02 INVALID` result and old exact error `UNKNOWN`.
   Human Product Owner authorization on `2026-09-23 Asia/Shanghai` retains
   `TD-002`, `TD-013` and `TD-017` as open technical debts; the unrecoverable
   `UNKNOWN` detail is tracked under `TD-013`; Run 02 is accepted only as an
   invalid historical record, not as evidence that sync behavior passed; and
   both UI-02 residuals are accepted under the bounded [Product
   Decision](../product-decisions/RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md).
   `QR-CURRENT-01` is a bounded `accept` residual: Product accepted the
   exact-run discrepancy on `2026-09-24` after Xcode's 397-ID native
   enumeration matched all 397 `.xcresult` case identifiers. See the
   [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md)
   and [reconciliation evidence](../evidence/rime-sync-v1-xcodebuildmcp-count-reconciliation-2026-09-24.md).
   The internal reason for the extra MCP discovery count remains unknown; this
   disposition does not claim a tool fix or alter the 10 skipped cases.
   The UI-01 and SEC-01 rows are `fix` dispositions with scoped evidence;
   UI-02 has the separate bounded `accept` disposition above. Remaining
   limitations and all evidence pointers are enumerated in the readiness
   ledger.
3. **Independent review — complete:** the final synchronized 68-path candidate
   received Quality `Pass with conditions` and Architecture `Accept with
   conditions`. Their exact receipts are linked in the close decision below.
   Run 02 `HOLD` / `INVALID` remains historical and is not relabeled.
4. **Product lifecycle decision — complete:** on `2026-09-25 Asia/Shanghai`,
   the Human Product Owner accepted the bounded scope and open debts and
   authorized the Product Lead to record `Active -> Completed -> Reviewed ->
   Closed`. See [`PD-RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25`](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md).

All four close-boundary conditions are recorded as satisfied for this
Assignment's bounded scope. The lifecycle is `Closed`; future work in deferred
or open-debt areas is not reopened automatically.

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit role delegation
- **Assignment Revalidation Authority:** Product Lead
- **Product Contract:** [`docs/RIME_SYNC.md`](../RIME_SYNC.md)
- **Architecture Decision:** ADR 0012, [ADR 0013](../architecture/decisions/0013-rime-standard-sync-interoperability.md), ADR 0014 and [ADR 0019](../architecture/decisions/0019-app-notification-and-toast-settings.md)

## Acknowledgement And Activation

- **Executor acknowledgement:** `2026-07-11 Asia/Shanghai` — contract and architecture investigation accepted.
- **Architecture acknowledgement:** ADR 0012 accepted with implementation pending.
- **Product lifecycle decision:** `Assigned -> Acknowledged -> Ready -> Active` for Contract and Architecture work only.
- **Implementation authorization:** Human Product Owner explicitly opened code implementation on `2026-07-12 Asia/Shanghai`.
- **Current phase:** Historical activation detail; current phase is maintained in the Current Status block above.

## Assignment

- **Domain Owner:** App & Data Operations Maintainer
- **Executor:** App & Data Operations Maintainer, coordinating bounded RIME Platform and documentation work packages
- **Environment Executor:** Quality, Performance & Release Maintainer for build/simulator/network-fixture evidence; human owner for physical-device, provider-account and future CloudKit entitlement evidence
- **Human Dependency:** Human owner for explicit implementation authorization, physical-device interactions and future Apple Developer Program/container access; CloudKit is not an Entry Criterion for WebDAV/local-folder V1
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for Product Review, then Program Manager for owner-confirmed status synchronization

## Scope

1. Publish the portable sync Product Contract and ADR.
2. Define a versioned, transport-independent, encrypted sync package.
3. Add main-App-only sync orchestration and a polished native settings surface.
4. Implement WebDAV and local-folder adapters first.
5. Use librime standard `sync_dir` / `sync_user_data` for user-data snapshots and per-device YAML/TXT backup; after one confirmed initial sync, allow user-configurable, safety-gated automatic maintenance; retain encrypted managed settings as an auxiliary layer.
6. Apply managed settings through existing persistence and normal main-App deployment; require staging, validation and a recovery snapshot before any later cross-device YAML import.
7. Add deterministic offline merge and non-destructive conflict preservation.
8. Add privacy, credential, deletion, error, migration and recovery contracts.
9. Produce unit, integration, UI, interruption and security evidence for the bounded iOS V1. Full cross-platform fixture round-trips, scheme portability and staged custom-file import are deferred to `TD-008`.
10. CloudKit/iCloud is a deferred follow-up and is not part of the current V1 closure; re-entry requires its membership, container, entitlement and physical-device prerequisites.

## Non-goals

- No implementation code until the human owner explicitly opens implementation under `AGENTS.md`.
- No network or sync work in Keyboard Extension or KeyboardCore.
- No user dictionary, Typing Intelligence, diagnostics, logs, Typo learning or typed-content enters the encrypted Universe private package.
- No automatic RIME standard sync before the first confirmed manual sync, while the keyboard is active, or without the documented cooldown/background-task safety gate; no live database copy, cross-device YAML import or silent configuration overwrite.
- No live `*.userdb*` copying, automatic restore or silent overwrite.
- No Universe-hosted account/backend in this Assignment.
- No claim of real-time iOS background sync.
- No unrelated refactor or cleanup of the existing dirty worktree.

## Required Inputs

- `docs/RIME_SYNC.md`
- ADR 0003, 0005, 0007 and 0012
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/RIME_USER_DICTIONARY.md`
- `docs/UI_STYLE_GUIDE.md`
- `docs/PRIVACY_POLICY.md`
- `docs/TECH_DEBT.md`
- `docs/DEBUGGING.md`
- `docs/RELEASE_CHECKLIST.md`
- current Settings UI, RimeSettingsStore, deployment service and RimeBridge API surface
- official RIME user-sync contract and bundled `RimeApi.sync_user_data` header
- current Apple membership, capability and CloudKit requirements before CloudKit work

## Entry Criteria

### Contract And Architecture

- Product objective and role delegation are explicit.
- Assignment contains no `UNKNOWN` fields.
- repository and official documentation investigation is complete.

### Implementation

- Human owner explicitly authorizes code implementation.
- Privacy policy is updated for explicit encrypted synchronization.
- Sync package schema, encryption suite, credential storage and deletion semantics are accepted.
- Managed-field allowlist, package limits and deterministic conflict semantics are testable; file staging/rollback remains a prerequisite for the deferred file phase.
- Worktree scope is isolated from unrelated active changes.

### Standard RIME User-Data Sync

- The human owner explicitly approves standard RIME interoperability and the privacy boundary.
- The operation is manual, main-App-only and presents explicit confirmation that the keyboard is not in use.
- librime snapshot merge is used; live database copy, restore and overwrite remain prohibited.
- Automatic follow-up runs only after this first success, from the main App background task, with keyboard-activity, folder-access and cooldown checks plus truthful non-realtime copy.
- Physical-device, cross-process and cross-front-end evidence are recorded before Product acceptance.

### CloudKit Follow-up

- Active Apple Developer Program membership and admin permissions exist.
- iCloud container and entitlements are provisioned.
- Development and production environment verification is available on physical devices.

## Exit Criteria

- Portable package and transport contracts have executable compatibility tests.
- The local-folder path in the current iOS Simulator closure scope passes the
  selected interruption, retry, conflict, corruption and deletion checks; the
  exact Simulator filesystem/provider boundary must be recorded. Live WebDAV
  validation is deferred to `TD-019` and is not claimed by this closure.
- UI evidence covers light/dark and Dynamic Type in the scoped Simulator
  matrix, plus the Human-reported VoiceOver/enlarged-text observation on one
  iPhone 13 Pro. This does not establish full UI-02 VoiceOver conformance. The
  unrun narrow-device check and incomplete physical-evidence binding are
  explicitly accepted as bounded UI-02 residuals in the linked Product
  Decision, not counted as passes.
- Current Simulator UI evidence covers unconfigured-state navigation, local-folder automatic-sync controls, dark-mode Accessibility XXXL scrolling, WebDAV private-only scope/confirmation copy, bookmark-repair paused state, malformed recovery-code validation, success/conflict distinction, corrupted-package recovery, WebDAV authentication failure, valid mismatched-key replacement, local disconnect result, remote-delete fake-transport success and delete failure. The five new cases passed together on iPhone 18 Pro / iOS 27.0 Simulator in one run (5/5); see readiness ledger for xcresult paths and limits. Fresh independent Quality returned `Pass with conditions` for the current UI-01 aggregate, signed Keychain and full-suite evidence; see [current Quality receipt](../reviews/rime-sync-v1-current-quality-rereview-2026-09-23.md). Human-reported iPhone 13 Pro / iOS 27.0 VoiceOver and enlarged-text check remains device-attested only. The local Build 55 Archive has matching `1.0 (1)` metadata and a known source receipt, but is not linked to the installed device build; current CoreDevice/Device Hub inspection timed out. Exact source/executable provenance remains unavailable. The earlier full App + Keyboard run recorded 398 discovered, 387 passed / 10 skipped / 0 failed (397 executed); it remains historical evidence for that exact run. The current 2026-09-25 run is 401 total, 391 passed / 10 skipped / 0 failed, with native Xcode enumeration matching the 401 `.xcresult` IDs. Product accepted only this current run's 402/401 MCP reporting residual; see the [full-suite receipt](../evidence/rime-sync-v1-current-app-keyboard-full-suite-2026-09-25.md), [reconciliation evidence](../evidence/rime-sync-v1-xcodebuildmcp-count-reconciliation-2026-09-24.md) and [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md). The internal tool cause remains unknown and no future-run accuracy is implied. Current signed focused Keychain + RIME transport run passed 11/11; see same review receipt for conditions.
- Supplemental 2026-09-24 UI-02 observation: Human reports VoiceOver and enlarged-text layout normal on iPhone 13 Pro / iOS 27.0 after installing local Debug `1.0 (924)` from dirty worktree HEAD `4a51228`. Fresh independent Quality returned `Pass with conditions`, limited to this supplemental observation. Product accepted the unrun narrow-device check and incomplete physical-evidence binding as bounded residuals; neither is a pass. See the [evidence receipt](../evidence/rime-sync-v1-ui02-device-accessibility-2026-09-24.md), [Quality review](../reviews/rime-sync-v1-ui02-device-accessibility-quality-review-2026-09-24.md) and [Product Decision](../product-decisions/RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md).
- Imported managed settings deploy only from the main App and do not replace the keyboard's last usable deployment on failure.
- Keyboard hot path and offline typing remain unchanged.
- Bounded V1 package/transport fixtures pass on iOS; full cross-platform round-trips and safe custom-file import remain explicitly deferred to `TD-008` and are not claimed by this closure.
- Documentation, privacy, debugging, release and changelog impacts are complete.
- Architecture, Quality and Product reviews issue independent conclusions.
- Security tests cover ciphertext tampering/privacy, coordinator fail-closed behavior and local/WebDAV private-package deletion boundaries; the disconnect test verifies secret-store removal requests using a test double, while the separate signed Simulator lane tests OS Keychain behavior. Unsigned broad CI skips the Keychain integration only for the expected missing-entitlement result. These do not resolve [`TD-002`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access).

## Stop Conditions

- Any initial standard-sync path transfers user data without explicit confirmation or clear non-encryption disclosure; any automatic path runs without the documented initial-success, inactive-keyboard, cooldown and main-App-only boundary.
- Implementation would copy/replace a live RIME user database.
- A provider forces transport-specific state into the portable domain model.
- Recovery snapshot or non-destructive conflict preservation cannot be guaranteed.
- CloudKit work begins without verified membership/container/entitlement prerequisites.
- Required physical-device, provider, security or cross-platform evidence is unavailable.
- Scope overlaps unrelated dirty-worktree changes without a clean file boundary.

## Handoff

- **Required Handoff Content:** product contract, ADR, package schema, threat model, implementation diff, test matrix, cross-platform fixtures, provider evidence, privacy/deletion proof, skipped gates and residual risks.
- **Revalidation Trigger:** any change to synced data categories, default enablement, encryption, retention/deletion, transport priority, hosted backend, Extension network boundary, user-dictionary scope, CloudKit prerequisites, owners, reviewers or acceptance platforms.
