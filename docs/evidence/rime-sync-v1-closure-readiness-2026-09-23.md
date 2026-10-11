# Evidence: RIME-SYNC-001 bounded iOS V1 closure readiness — 2026-09-23

## Status and scope

| Field | Value |
|---|---|
| Status | Historical close-readiness ledger for RIME-SYNC-001, updated through the 2026-09-25 close. The 2026-09-24 historical Architecture `Blocked` and Quality receipts remain bound to their original snapshots. The 66-path parent review pair's status-sync finding was fixed; the final synchronized 68-path candidate received Quality `Pass with conditions` and Architecture `Accept with conditions`. The Human Product Owner then accepted the bounded iOS V1 local-folder scope and retained debts; Product Lead recorded `Active → Completed → Reviewed → Closed` effective `2026-09-25 Asia/Shanghai`. Current broad suite: 401 total / 391 passed / 10 skipped / 0 failed; native 401 IDs match `.xcresult`; Product accepted only the exact 402/401 MCP reporting residual (cause unknown). Ten skips are not passes. See [Assignment close decision](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md). |
| Assignment | [`RIME-SYNC-001`](../assignments/rime-sync-001.md) |
| Evidence grade | `Executor-recorded` for local tests; source device observations remain `Device-attested` in their individual records |
| Scope decision | Human Product Owner bounds current closure to delivered iOS V1; CloudKit is deferred and cross-platform compatibility remains open as `TD-008` |
| Worktree | Isolated detached worktree; no commit, push, merge or release action |

The scope decision does not claim CloudKit or cross-platform work is complete,
does not waive remaining iOS V1 evidence, and does not alter the formal Run 02
`INVALID` record. The 2026-09-22 and 2026-09-23 natural-device records remain
supplemental observations with unknown exact build/source identity.

## Local verification

| Claim | Outcome | Evidence |
|---|---|---|
| Current-snapshot full App + Keyboard XCTest targets | `pass` — `Executor-recorded` | iPhone 18 Pro Simulator / iOS 27.0; XcodeBuildMCP reported 398 discovered, while 387 passed + 10 skipped + 0 failed equals 397 executed. For both this 2026-09-23 Quality-reviewed run and the 2026-09-24 confirmation, native Xcode enumeration returned 397 unique enabled IDs and matched the `.xcresult` case IDs with zero differences. Product accepted this exact-run MCP discovery-count residual; its internal cause remains `UNKNOWN` and no future-run accuracy is implied. The 10 skipped tests are not passes. See [count reconciliation](rime-sync-v1-xcodebuildmcp-count-reconciliation-2026-09-24.md) and [Product residual decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md). Quality-reviewed result `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-32-10-266Z_pid5815_cb08a974.xcresult`; log `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-23T15-32-10-266Z_pid5815_b0dff4c5.log`. |
| Current-snapshot RIME transport and signed Keychain integration (`P2`, `SEC-01`) | `pass` — `Executor-recorded` | Ad-hoc-signed Debug Simulator run, iPhone 18 Pro / iOS 27.0; all 10 `RimeSyncTransportTests` and `testRimeSyncSecretStorePersistsUpdatesAndDeletesAUniqueKeychainItem` passed, 11/11, 0 skipped. This exercises production Security.framework add/read/update/delete with a unique dummy item and the stable diagnostic-code mappings. Result `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-31-31-357Z_pid5815_3e99c755.xcresult`; log `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-23T15-31-31-357Z_pid5815_6cd098bc.log`. No physical-device Keychain or hosted-CI claim. |
| `ARCH-RIME-SYNC-001-P2-01` stable diagnostic-code mapping | `Accept` — exact-snapshot Architecture review; Quality conditions recorded below | `RimeSyncDiagnosticErrorCode` is a finite raw-value enum. Folder stage and known sync errors map to fixed identifiers; arbitrary NSError domain/code/message and associated transport text are excluded; unknown errors map to `unknown`. The focused RIME suite passed as part of the signed 11-test run above. Fresh GPT-6 Luna Architecture review `Hypatia` (`01a0ceeb-6769-78f0-9d6d-332f76a1dd0d`) accepted this finding for the bound source/test/contract hashes; see [P2 Architecture receipt](../reviews/rime-sync-v1-architecture-p2-rereview-2026-09-23.md). |
| Full App + Keyboard XCTest targets | `pass` (unsigned broad suite; focused signed Keychain lane) | `Universe Keyboard` scheme on iPhone 18 Pro Simulator / iOS 27.0: authoritative `.xcresult` total 395 = 385 passed + 10 skipped + 0 failed; bundle `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T12-15-53-587Z_pid5815_d1efb7f2.xcresult`. XcodeBuildMCP discovery reported 396. A method-name set comparison between both test binaries and all 395 executed IDs found zero differences; no missing method explains the extra tool tally, whose cause remains unknown. Skips are listed in the remediation record; none count as passes. |
| OS Keychain integration (`SEC-01`) | `pass` — signed Simulator integration; current independent review is `Pass with conditions` | The latest ad-hoc-signed run is bound to the present source snapshot and is recorded above: production `RimeSyncSecretStore` exercised add/read/update/delete with a unique dummy account (1/1). The current Quality receipt reviews this result. The earlier corrected-candidate signed bundle `...12-35-41-482Z_pid5815_f55e4935.xcresult` and unsigned expected-entitlement skip `...11-29-09-590Z_pid5815_749ca766.xcresult` are historical. No physical-device Keychain or hosted-CI behavior is claimed. |
| Authenticated encryption and transport regression/security-focused tests | `pass` | Covered in the signed full App + Keyboard XCTest run above, including modified ciphertext rejected before any coordinator publish, local-folder/WebDAV private-package deletion boundaries, and disconnect-model requests to remove both secret accounts and sync configuration. |
| Independent Quality review of this Simulator evidence | `Pass with conditions` — bounded Simulator scope | Original [Hegel review](../reviews/rime-sync-v1-simulator-evidence-quality-review-2026-09-23.md) and first fresh `Blocked` review remain historical. The distinct second fresh review verified the corrected fixture lifecycle and method-name inventory; the cause/raw source of the 396 discovery tally remains `UNKNOWN` and is explicitly non-authoritative. See [fresh Quality re-review](../reviews/rime-sync-v1-quality-rereview-2026-09-23.md) and [remediation evidence](rime-sync-v1-quality-remediation-2026-09-23.md). |
| Fresh Quality re-review for P1-remediated candidate | `Pass with conditions` (`Quality-reverified`; historical exact 29-file manifest) | This earlier receipt remains bound to its own candidate: 396 executed = 386 passed + 10 skipped; XcodeBuildMCP reported 397 discovered, cause `UNKNOWN`. It is not reused as the current combined-snapshot conclusion. See [P1 Quality receipt](../reviews/rime-sync-v1-quality-p1-rereview-2026-09-23.md). |
| Original independent Architecture review | `Blocked; superseded for ARCH-RIME-SYNC-001-P1-01` | This is the historical finding that triggered remediation; it is not the current Architecture verdict. The P1 is resolved for its bound snapshot by the fresh [Architecture re-review](../reviews/rime-sync-v1-architecture-rereview-2026-09-23.md); the P2 is separately accepted for its exact files by the [P2 Architecture re-review](../reviews/rime-sync-v1-architecture-p2-rereview-2026-09-23.md). The original receipt remains historical. Original receipt: [Architecture review](../reviews/rime-sync-v1-architecture-review-2026-09-23.md). |
| P1 remediation and fresh Architecture re-review | `pass` for bound snapshot | Only confirmed Cocoa `fileReadNoSuchFile` is treated as object absence; all other read failures propagate before any package write. The regression case verifies an existing unreadable settings path with nil ETag fails without writing `format.json`; existing absent-object/first-publish and stale-ETag coverage remains. Historical focused tests: 2 passed; the final current-snapshot App + Keyboard run is recorded above. Fresh independent Architecture verdict: `Accept`; see [P1 re-review](../reviews/rime-sync-v1-architecture-rereview-2026-09-23.md). |
| Added ciphertext/privacy and delete-boundary checks | `pass` | Private-value canary absent from ciphertext; modified authenticated ciphertext rejected as `.corruptedPackage`; local-folder deletion preserves installation data and user-dictionary snapshot; WebDAV deletion targets only the private package root |
| RIME settings UI smoke/accessibility-tree checks | `pass` | Corrected-candidate iPhone 18 Pro Simulator / iOS 27.0; all 8 `RimeSyncSettingsUITests` passed. Bundle `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T12-31-19-792Z_pid5815_919bbc64.xcresult`. Each launch receives a unique defaults suite and an in-memory secret store, and bypasses production lifecycle background effects. Destructive confirmation alerts were cancelled; no sync, account, folder or remote data was changed. |
| UI-01 five-case recovery and management matrix | `pass` — `Executor-recorded` | All five selected `RimeSyncSettingsUITests` passed in one run on iPhone 18 Pro Simulator / iOS 27.0 (build `24A434`, simulator UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`): WebDAV authentication error, valid recovery-code import followed by fake `.corruptedPackage` sync error, local disconnect completion, fake-transport remote-delete completion, and delete failure preserving configuration. Result: 5 passed / 0 failed / 0 skipped. Bundle `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-07-57-797Z_pid5815_f1640d5d.xcresult`; build log `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-23T15-07-57-797Z_pid5815_35981f79.log`. Exact UI test source SHA-256: `00678a1de9180c082d300649d478ee3cb21848941d9c9555dbc25f3831ffeeeb`. Tests use DEBUG-only fixtures, isolated defaults, dummy secrets and fake transport; this is UI/state-transition evidence, not real WebDAV, cryptographic wrong-key reproduction or provider-side deletion. |
| Fresh independent Quality review of current full-suite, UI-01 aggregate, P2 mapping and SEC-01 signed lane | `Pass with conditions` (`Quality-reverified`) | Fresh GPT-6 Luna reviewer `Helmholtz` (`01a0ceeb-67f3-7c42-bca9-3cd7a529375a`) checked the current UI fixture/tests, diagnostic tests, readiness ledger and the three xcresult summaries. Counts and non-claims were consistent; see [current Quality re-review receipt](../reviews/rime-sync-v1-current-quality-rereview-2026-09-23.md). Conditions: unresolved 398/397 tally, fake transport does not prove provider deletion, signed Simulator is not physical-device/hosted CI evidence, and UI-02 source provenance was unknown at that review's date; Product later accepted the provenance gap as a residual on 2026-09-24. |
| Independent Quality re-review of corrected UI-01 recovery path | `Pass with conditions` — `Quality-reverified`, bounded to the changed method/source | Fresh GPT-6 Luna reviewer `Euler` (agent `01a0cec7-4a05-7a83-ba3c-3176b7d9e707`) independently verified the exact source/document hashes, fake `fetchSettings()` error path, visible wrong-key copy/state and the single-method result bundle `...14-56-21-411Z_pid5815_5dd4cf4e.xcresult` (1/1). Review manifest: test `00678a1de9180c082d300649d478ee3cb21848941d9c9555dbc25f3831ffeeeb`; fixture `41550bf022f2d5b039b3b67a8afbf92cf62b1b9fc7b5c74b54d91834de251e99`; ViewModel `d354cc0460bf2c9e4f81e86496b2d8506b9846428c2efbcb665a7fc977380a85`; settings view `beb774914813c717c71c576d33590f84b53c7b5b39357b97f314d7734e6eea0d`; Assignment `3232f41e361cbbb6862d9e8f32db43bcd884e66172ec21c0ea0e93d6f4925f5f`; readiness evidence at review time `8fdb1015e288b3b46701504a1630fabab3ec99323cf2f7eb21470cea9fd8e525`; UI style guide `03a1fbee1b6470b489fc7223f4d41a46f194a1c9036850398b64e87f08f6e56e`; RIME contract `4d81533f52bcdcbd00b04e500c2d9537261f6996745f07fe9da76d0cf36db504`. The reviewer did not inspect the subsequent five-case aggregate bundle; that run is separately `Executor-recorded`. The condition/non-claim remains that a fake `.corruptedPackage` response does not prove an actual cryptographic key mismatch, live WebDAV behavior or provider deletion. |
| Physical UI-02 owner observation | `Human-attested; superseded for current status by 2026-09-24 receipt` | Historical 2026-09-23 observation: Human Product Owner reports checking VoiceOver and enlarged accessibility text on iPhone 13 Pro / iOS 27.0; both appeared correct. The owner reports no taps on “立即同步”, disconnect, or delete. Installed app metadata then available did not identify source commit or executable digest. The 2026-09-24 receipt and fresh Quality review now define the supplemental evidence boundary; see the Product residual decision for current disposition. |
| Strict Swift formatting for all changed Swift files | `pass` | `xcrun swift-format lint --strict --configuration .swift-format` passed for all nine changed Swift files, including `Universe_KeyboardApp.swift`, `RimeAutomaticSyncScheduler.swift` and the corrected UI test visibility predicate; `git diff --check` passed. |
| Final independent Architecture review of bounded iOS V1 package — `2026-09-24` | `Blocked` — historical exact candidate; superseded for the P1 on later snapshots | Fresh review found `ARCH-RIME-SYNC-001-FINAL-P1-01`; the fail-closed remediation and its later Architecture disposition are recorded in the linked historical receipts. This 38-path verdict is not the current parent Architecture conclusion. See [historical final Architecture receipt](../reviews/rime-sync-v1-final-architecture-review-2026-09-24.md) and [remediation re-review](../reviews/rime-sync-v1-final-architecture-rereview-2026-09-24.md). |
| Final independent Quality review of bounded iOS V1 package — `2026-09-24` | `Pass with conditions` — historical exact candidate | This review covers its recorded 387-pass / 10-skip run, exact 397-ID match, signed Keychain/transport 11/11, UI-01 5/5 and supplemental UI-02 boundaries. It is not the current 2026-09-25 parent Quality conclusion. See [historical final Quality receipt](../reviews/rime-sync-v1-final-quality-review-2026-09-24.md). |
| Parent review delta — exact 66-path candidate, `2026-09-25` | Quality `Pass with conditions`; Architecture `Accept with conditions`; `fix` completed in the next synchronized candidate | Both reviewers matched manifest `08d16753aa41c9b64dc718fea0e55c1eaf95d0930fa1d8d77fc69b97d10bfad2` and identified stale pending/close-gate wording here. This dated row preserves the original finding and disposition; see [parent Quality](../reviews/rime-sync-v1-parent-final-quality-review-2026-09-25.md) and [parent Architecture](../reviews/rime-sync-v1-parent-final-architecture-review-2026-09-25.md). The reconciled current state and paired 68-path conclusion are recorded below. |
| Final synchronized parent review — exact 68-path candidate, `2026-09-25` | Quality `Pass with conditions`; Architecture `Accept with conditions` | Both reviewers matched `ae5f2da4efebe9de3c4da67b6db02b951dc906a8f4e73723535eb4ea265748ca`, confirmed the ledger/state correction, explicit residual dispositions and bounded evidence claims, and confirmed no further Simulator run is needed for the single observed provider state. These are engineering reviews only; Product lifecycle authority remains separate. See [final Quality](../reviews/rime-sync-v1-parent-final-quality-sync-rereview-2026-09-25.md) and [final Architecture](../reviews/rime-sync-v1-parent-final-architecture-sync-rereview-2026-09-25.md). |

### Historical notes from 2026-09-23 (superseded by the current status and ledger below)

The following narrative records the evidence state at the time it was written;
it is not the current UI-02 status. The UI-02 evidence receipt's initial
"disposition and review remain open" status is also its capture-time state;
the later Product Decision and Quality review links above supersede that
status without altering the reviewed evidence bytes. Simulator results are not physical-device
revalidation. The separate owner observation above reports VoiceOver and
enlarged-text checks on an iPhone 13 Pro, but that historical observation was
not yet an independent Quality conclusion and was not pinned to a source commit
or installed executable digest. The later 2026-09-24 receipt and review
supersede this status. The UI-01 matrix now exercises
authentication and wrong-key error presentation, fake-transport deletion
success/failure, and local disconnect completion. It does not exercise
provider-driven remote deletion. Transport tests do not establish provider-side remote
deletion semantics beyond the request boundary; disconnect verifies the
ViewModel's secret-store removal requests, not the OS Keychain implementation;
the separate signed Simulator integration test does exercise the production
Keychain implementation, but not on physical hardware. The normal unsigned
full-suite now skips the Keychain integration only when the OS reports missing
entitlement; the separate ad-hoc-signed lane executes that path. The corrected
`.xcresult` is authoritative at 395 executed tests; the 396 discovery tally is
not an executed-test count. The binary method-name inventory exactly matches
the result IDs, while the one-count MCP reporting anomaly remains unexplained.
The UI suite also caught an offscreen/hittability assertion bug: it now scrolls
until the status title is hittable, not merely present in the accessibility
tree. The corrected complete suite passes all eight tests. An earlier fixture
attempt used the App Group defaults suite although sync preferences are in
standard defaults; that fixture defect was also corrected.

## Residuals and non-claims

- CloudKit/iCloud is deferred outside this iOS V1 closure by the Product scope
  decision; there is no CloudKit completion claim.

The following is the close-time residual ledger. `Pending` rows are deliberately
not M-03 dispositions and continue to block closure.

| Residual ID | Owner | Disposition / status | Evidence pointer and boundary |
|---|---|---|---|
| `TD-002` | Main App / RIME Platform | `tech_debt:TD-002` — Product Owner authorized retention on `2026-09-23`; risk open | [`TD-002`](../TECH_DEBT.md#td-002-validate-rimeuser-concurrent-access). Natural background success and process-gate skip do not prove cross-process exclusion. |
| `TD-008` | Main App data operations / RIME Platform | `tech_debt:TD-008` — Product Owner explicitly deferred full portability on `2026-09-23` | [`TD-008`](../TECH_DEBT.md#td-008-complete-portable-rime-data-compatibility). Cross-platform fixtures, scheme portability and staged custom YAML/TXT import remain out of scope. |
| `QR-CURRENT-01` — XcodeBuildMCP discovered/executed tally | Quality / CI integration | `accept` — Product accepted the exact-run reporting residual on 2026-09-24; not a tool fix | Current Quality review reports 398 discovered versus 397 authoritative `.xcresult` tests (387 passed + 10 skipped). Xcode native enumeration produced 397 unique IDs, with a zero symmetric difference against the `.xcresult` cases. The ten skips remain skips. Internal MCP cause and future-run accuracy remain unknown. See [reconciliation evidence](rime-sync-v1-xcodebuildmcp-count-reconciliation-2026-09-24.md), [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md), and the historical [current Quality review](../reviews/rime-sync-v1-current-quality-rereview-2026-09-23.md). |
| `TD-013` | Diagnostics owner / Quality | `tech_debt:TD-013` — Product Owner authorized retention on `2026-09-23`; debt remains open | [`TD-013`](../TECH_DEBT.md#td-013-diagnostics-v1-p1-查询生命周期与迁移硬化). This retains the legacy diagnostics/query gaps; it does not imply repair or acceptance as harmless. |
| `TD-017` | Main App RIME sync / RIME Platform | `tech_debt:TD-017` — Product Owner authorized retention on `2026-09-23`; debt remains open | [`TD-017`](../TECH_DEBT.md#td-017-investigate-background-sync-sandbox-extension-consume-failure). Keep the sandbox-extension attribution unknown; successful later syncs do not prove the warning harmless. |
| Historical exact error `UNKNOWN` | Main App diagnostics / Quality | `tech_debt:TD-013` — retained as unrecoverable historical diagnostic detail | Existing TD-013 evidence says the original private App Group preferences were not exported, so the exact error cannot be reconstructed. Do not infer a cause or fabricate a code. |
| Formal Run 02 `INVALID` | RIME-SYNC-001 Product / Quality | `accept` — accepted only as an invalid historical record, not as acceptance of sync behavior | [`Run 02`](rime-background-sync-natural-device-run-2026-09-01-r2.md) remains `INVALID`; retain the historical Architecture/Quality `HOLD`, do not relabel it as pass. |
| Simulator UI recovery and management results (`UI-01`) | Main App / Quality | `fix` — five-case matrix and current independent Quality review complete | All five additional `UniverseKeyboardUITests/RimeSyncSettingsUITests` cases passed together on iPhone 18 Pro / iOS 27.0 Simulator: WebDAV authentication error, valid recovery-code import followed by fake `.corruptedPackage` sync error, local disconnect completion, fake-transport remote-delete completion, and delete-authentication failure preserving configuration. Result 5/5, 0 failed, 0 skipped; xcresult `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T15-07-57-797Z_pid5815_f1640d5d.xcresult`. Fresh current-snapshot Quality is `Pass with conditions`; see [current Quality receipt](../reviews/rime-sync-v1-current-quality-rereview-2026-09-23.md). All use DEBUG-only isolated defaults, dummy secrets and fake transport; no real WebDAV challenge, cryptographic wrong-key condition or provider-side deletion is claimed. Earlier eight UI checks remain bounded to their separate run. |
| Local Files provider deletion observation | Main App / Quality / Architecture | `fix` for `QR-PROVIDER-DELETE-01`, bounded to observed Simulator LocalStorage state; fresh Quality `Pass with conditions` and Architecture `Accept with conditions` on the exact 64-path candidate | A new test-created `Universe-Rime-Sync-9F47C2A1` folder completed manual sync, then the production App's delete-and-disconnect UI returned to unconfigured. An immediately subsequent read-only listing of the exact provider root showed `universe-rime-sync/` absent and `universe-ios-b7640898-217b-44b8-b4b1-6b4cf2128bc1/` retained. The reviews judge this sufficient for the bounded observed-state check, while action/capture correlation remains time-adjacent and executor-recorded: no independently timed click, operation ID, structured event, or saved screenshot; installed executable/source provenance is `UNKNOWN`. The manual operation has no `.xcresult` or Files UI refresh assertion. The earlier UI XCTest remains `1 failed / 0 passed`; it is not relabeled. `TD-002` remains open. See [manual receipt](rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md), fresh [Quality](../reviews/rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md) and [Architecture](../reviews/rime-sync-v1-local-folder-provider-deletion-architecture-manual-review-2026-09-25.md), [original attempt](rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md), [state reinspection](rime-sync-v1-local-folder-provider-state-reinspection-2026-09-25.md), and historical [Quality](../reviews/rime-sync-v1-local-folder-provider-deletion-quality-delta-review-2026-09-25.md) / [Architecture](../reviews/rime-sync-v1-local-folder-provider-deletion-architecture-delta-review-2026-09-25.md) receipts. No device/cloud provider behavior is claimed. |
| VoiceOver spoken output and narrow-device/source provenance (`UI-02`) | Human owner / Quality | `accept` — Product accepted both residuals for bounded iOS V1 on 2026-09-24; no formal UI-02 pass | Human-reported iPhone 13 Pro / iOS 27.0 observation on local Debug `1.0 (924)` from dirty worktree HEAD `4a51228`: VoiceOver and enlarged accessibility text showed no issue; no sync/disconnect/delete action was taken. Fresh Quality `Pass with conditions` is limited to this supplemental observation. Product accepts (1) no narrow-device check against a defined target and (2) no frozen full-source manifest/on-device executable readback. Neither is a passing result; exact reproducibility and broader accessibility conformance remain unclaimed. See [Product Decision](../product-decisions/RIME-SYNC-001-UI02-RESIDUAL-ACCEPTANCE-2026-09-24.md). |
| OS Keychain integration (`SEC-01`) | Main App / Quality | `fix` — signed Simulator integration and current independent Quality review complete | Production `RimeSyncSecretStore` Security.framework add/read/update/delete passed with a unique dummy account in the ad-hoc-signed iPhone 18 Pro Simulator host (1/1 in the 11-test signed run above). Fresh Quality reviewed this result. A focused signed CI lane exists but no hosted workflow was run; no physical-device Keychain behavior is claimed. |
| Stable diagnostic error-code mapping (`ARCH-RIME-SYNC-001-P2-01`) | Architecture & Knowledge Steward / Main App diagnostics | `fix` — implementation/tests pass; Architecture `Accept`; included in current Quality `Pass with conditions` | A finite `RimeSyncDiagnosticErrorCode` enum replaces raw NSError domain/code output and drops associated error text. Unknown errors map to `unknown`; known preflight stage remains distinguishable. Contract and tests updated; see [P2 Architecture receipt](../reviews/rime-sync-v1-architecture-p2-rereview-2026-09-23.md) and [current Quality receipt](../reviews/rime-sync-v1-current-quality-rereview-2026-09-23.md). |

The Product Owner authorized the `TD-013`, `TD-017`, `UNKNOWN` and Run 02
dispositions in the active RIME-SYNC-001 conversation on `2026-09-23
Asia/Shanghai`, then accepted the two UI-02 residuals and the exact-run
`QR-CURRENT-01` reporting residual for bounded iOS V1 on `2026-09-24
Asia/Shanghai`. UI-01 and SEC-01 have current scoped Quality review, but that
does not establish provider-side deletion, hosted CI, or physical-device
Keychain behavior.
**Supplemental provider observation — `2026-09-25`:** A separate manual
production-App Simulator flow in a newly isolated Files local-storage folder
showed the private package root absent and the standard RIME directory present
immediately after delete-and-disconnect. Fresh Quality `Pass with conditions`
and Architecture `Accept with conditions` resolved `QR-PROVIDER-DELETE-01` as
`fix` for that single observed provider state. The enclosing UI XCTest remains
`1 failed / 0 passed` at the later Files UI query; the manual observation is
not a test pass and has no `.xcresult`, operation ID, independently timed click,
or installed executable/source binding. See the [manual receipt](rime-sync-v1-local-folder-provider-deletion-manual-2026-09-25.md)
and its [Quality](../reviews/rime-sync-v1-local-folder-provider-deletion-quality-manual-review-2026-09-25.md)
and [Architecture](../reviews/rime-sync-v1-local-folder-provider-deletion-architecture-manual-review-2026-09-25.md)
reviews. Historical automated-attempt details remain in the [attempt receipt](rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md).
- The local conditional-write P1 is resolved for the exact snapshot in the
  [Architecture re-review](../reviews/rime-sync-v1-architecture-rereview-2026-09-23.md).
  The P2 diagnostic-code mapping is implemented and covered by tests; fresh
  Architecture accepted it for the exact bound files. This does not change any
  accepted ADR or expand V1 scope.
- Independent Quality reviewer `Hegel` issued the historical `Blocked`
  conclusion; first fresh re-review also returned `Blocked`. A distinct second
  fresh Quality re-review returned `Pass with conditions` for the prior
  bounded Simulator candidate. A newer candidate-specific Quality re-review
  returned `Pass with conditions`; neither older Quality receipt covers the
  later P1/P2 and UI changes as a combined snapshot.
  Independent Architecture accepted both the P1 remediation and the bounded P2
  mapping on their respective exact snapshots. This is not Product Gate, merge,
  TestFlight or Release approval.

## Next gate at this historical checkpoint (superseded)

This section preserves the readiness state recorded before the bounded V1
Assignment was closed on `2026-09-25`. Its “next gate” is historical, not a
current action item. Later publication preflight and review state is recorded
in the dated evidence and review receipts linked from the Assignment.

The latest complete App + Keyboard Simulator suite is 401 total, 391 passed,
10 skipped and 0 failed. Xcode native enumeration matches all 401 `.xcresult`
IDs; Product's `QR-CURRENT-01` acceptance is restricted to the exact 402/401
MCP reporting discrepancy, whose cause remains unknown. Ten skips are not
passes. See the [current run receipt](rime-sync-v1-current-app-keyboard-full-suite-2026-09-25.md)
and [Product Decision](../product-decisions/RIME-SYNC-001-QR-CURRENT-01-PRODUCT-RESIDUAL-2026-09-24.md).
The full UI regression is separately 29 passed / 7 skipped / 0 failed; UI-01
and signed Keychain/transport 11/11 remain scoped evidence. UI-02's accepted
residuals do not constitute a formal pass. The 2026-09-25 parent review delta
on the 66-path candidate returned Quality `Pass with conditions` and
Architecture `Accept with conditions`, and identified stale status narration
in this ledger. That finding was corrected; the final synchronized 68-path
candidate then received paired Quality `Pass with conditions` and Architecture
`Accept with conditions`. See the exact receipts in the review table above.
The bounded local-folder engineering package received the Product lifecycle
decision `Accepted / Closed` on `2026-09-25 Asia/Shanghai`. See [Assignment
close decision](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md).
This closes only the stated engineering Assignment scope; it does not close
technical debts or grant merge, TestFlight or Release authority.
