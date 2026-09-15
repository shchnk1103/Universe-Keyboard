# RELEASE-2026-0801-04 — Build 55 公测候选证据审查交接

> **Run ID:** `RELEASE-2026-0801-04-B55-PUBLIC-BETA-READINESS-20260913`
> **Status:** `Handoff updated — independent Quality/Release review and re-review Blocked; public external-testing exception accepted; Beta Review pending`
> **Evidence grade:** `Executor-recorded` for this repository review; linked physical claims retain their original grade
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Primary release record:** [`Release evidence and acceptance record`](release-2026-08-01-acceptance.md)
> **Independent review:** [`Build 55 Quality/Release review`](../reviews/release-2026-09-13-build55-quality-release-review.md) · [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md)

## Scope and authority

本交接审查当前 Build 55 证据是否足以推进公开测试候选。它只汇总已经存在的仓库记录和 Human
Device-attested 结果，不新增设备副作用，不读取或清理 App Group，不修改代码。原始交接阶段未执行
commit、push、上传、分发或发布；后续公开外部测试动作由独立的 Product Decision 例外记录，见下方执行更新。

本记录是 Executor 的证据交接；独立 Quality/Release Reviewer 已出具初审和针对 Archive/export 核对的 [`Blocked` 复核结论](../reviews/release-2026-09-13-build55-quality-release-re-review.md)。本记录不是 Product Gate 或 Release 授权。

## Post-handoff public-testing execution update

On `2026-09-13 Asia/Shanghai`, the Human Product Owner accepted the separate
[`Build 55 public external-testing exception`](../product-decisions/RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md)
and authorized the App Store Connect execution. The external group `Build 55 Public Beta` now contains Store export
`1.0 (55)`. Its status is `Waiting for Review`, with the platform displaying `Expires in 90 days`.
The Beta Review form was submitted with sign-in disabled and the bounded `What to Test` text; a public link was created
as `Open to Anyone` with no tester limit: <https://testflight.apple.com/join/t48JR3Q3>.
App Store Connect states that testers cannot join until the build is approved, so there are currently zero testers,
invites, installs, sessions and feedback. This update changes the channel decision only; the independent Quality/Release
conclusion remains **Blocked**, and no formal Release Gate or App Store release claim is made.

## Evidence matrix

| Area | Current result | Authority / evidence |
|---|---|---|
| Build 55 identity and target-App reinstall | Available for this run; installed-App boundary established | [`Fresh-install boundary`](release-2026-09-13-build55-fresh-install-boundary.md), `Executor-recorded` |
| Build 55 Store upload package | Artifact-level preflight passed; ASC reports the build complete, and external-group status is `Waiting for Review`; exact IPA SHA-256 and code-image/dSYM lineage remain recorded | [`Store upload package preflight`](release-2026-09-13-build55-store-upload-package.md) · [`Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md) · [`Public-testing exception`](../product-decisions/RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md) |
| J1 / J2 / initial J3 | Device-attested observed; guide, keyboard addition, Full Access affirmation and automatic Luna deployment recorded | [`Fresh-install boundary`](release-2026-09-13-build55-fresh-install-boundary.md) |
| Luna 26-key first input | Device-attested basic output observed | [`Fresh-install boundary`](release-2026-09-13-build55-fresh-install-boundary.md) |
| 雾凇 / `rime_ice` download and deployment | Scoped Device-attested gate passed | [`雾凇九宫格 gate`](release-2026-09-13-build55-rime-ice-nine-key-gate.md) |
| 雾凇 nine-key candidates and commit | Device-attested normal; keyboard remained selected | [`雾凇九宫格 gate`](release-2026-09-13-build55-rime-ice-nine-key-gate.md) |
| Sound / degradation prompt | Sound present; no degradation prompt | [`雾凇九宫格 gate`](release-2026-09-13-build55-rime-ice-nine-key-gate.md) |
| Haptics | Not a nine-key failure; absent in that arm and attributed by Human to the Full Access requirement | [`雾凇九宫格 gate`](release-2026-09-13-build55-rime-ice-nine-key-gate.md) · [`TD-004 matrix`](release-2026-09-13-build55-td004-full-access-matrix.md) |
| TD-003 performance baseline | Open; no controlled cold/warm, fixed-cadence, first-key, continuous or memory baseline | [`TECH_DEBT.md`](../TECH_DEBT.md) · [`TD-003 follow-up`](release-2026-09-13-build55-td003-cold-warm-diagnostic.md) |
| TD-003 Human functional observation | Device-attested Pass for two declared sequences with no abnormality reported; does not replace the invalid performance captures or close TD-003 | [`TD-003 Human observation`](release-2026-09-13-build55-td003-human-functional-observation.md) |
| TD-004 degradation / shared-capability matrix | Open; off/on basic behavior, haptic-switch propagation, same-session candidate learning and Full Access-on diagnostic readback are observed; the off arm produced no new visible diagnostic record and no degradation cue; the safe uninstalled-scheme induction did not leave the deployed state; restart persistence, Full Access-off learning, backup/restore, other shared settings, resource-not-ready recovery and clean-state App Group behavior remain untested | [`TECH_DEBT.md`](../TECH_DEBT.md) · [`TD-004 matrix`](release-2026-09-13-build55-td004-full-access-matrix.md) |
| TD-005 crash/Jetsam classification | Open; UUID-bearing Jetsam snapshots remain unclassified because no victim marker was found. Archive/dSYM `CFBundleVersion=1` versus exported Build `55` is now reconciled at code-image and export-provenance level, while the metadata difference remains explicit | [`TECH_DEBT.md`](../TECH_DEBT.md) · [`TD-005 query`](release-2026-09-13-build55-td005-system-crash-query.md) · [`TD-005 classification follow-up`](release-2026-09-13-build55-td005-classification-follow-up.md) · [`Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md) |
| Clean App Group / RIME / user dictionary state | `UNKNOWN`; contents were intentionally not read or reset | [`Fresh-install boundary`](release-2026-09-13-build55-fresh-install-boundary.md) |
| Release materials and Task11 | Open items remain, including screenshots and Task11/F-03 coordination; Build 55 What to Test was submitted with the Beta Review form | [`Release acceptance`](release-2026-08-01-acceptance.md) · [`Dashboard`](../ENGINEERING_DASHBOARD.md) · [`Public-testing exception`](../product-decisions/RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md) |

## Passed within this review

- The required public-test nine-key path has current Build 55 Human Device-attested evidence for 雾凇 download, deployment,
  selection, candidate appearance, candidate commit, sound and absence of a degradation prompt.
- The earlier fresh-install J1/J2/J3 observations and Luna 26-key basic input are retained without claiming a clean shared container.
- With Full Access on, the main-App haptic switch was toggled off and on; the Extension correspondingly lost and regained vibration while sound and keyboard selection remained normal.
- With Full Access on, candidate learning was observed: after committing a non-leftmost candidate, the same synthetic sequence placed that candidate earlier on re-entry. Restart persistence and backup/restore were not tested.
- With Full Access on and 「记录诊断数据」 enabled, keyboard use produced a new main-App diagnostic record while the keyboard remained normal. Full Access-off persistence was not tested.
- With Full Access off, a new keyboard session remained usable but produced no new visible main-App diagnostic record and no degradation prompt.
- Keeping uninstalled 万象拼音 at「可下载」did not trigger RIME redeployment; the main App remained「已部署」, so resource-not-ready recovery was not reached.
- The evidence preserves the distinction between a scoped runtime pass and the overall Release Gate.

## Blocked or incomplete

- `TD-003` remains a release-relevant performance-evidence gap; the two retained Time Profiler runs are diagnostics, not a numeric
  or controlled cold/warm baseline. The separate Human observation passed functionally twice, while two later trace starts
  ended at about one second with `Device disconnected` and are excluded.
- `TD-004` remains open because the off arm demonstrates a shared-diagnostics gap without an Extension-visible recovery cue, and the safe resource-not-ready induction did not reach the target state; the matrix still does not cover all shared-capability and recovery boundaries.
- `TD-005` remains open because current Jetsam records are not classified or symbolicated to a causally identified victim.
  The Archive/export review confirmed the code-image lineage and explicit export-stage `buildNumber=55` provenance, while
  preserving that the Archive/dSYM metadata itself reports `CFBundleVersion=1`.
- The fresh-install clean shared-container boundary remains `UNKNOWN` because App Group/RIME/user-dictionary contents were not
  inspected or reset.

Under [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md), these gaps prevent this evidence set from being presented as a
quality-complete **Release Gate Pass**. A separate Product Decision now accepts a public external-testing exception;
the nine-key requirement itself is not the remaining technical blocker, and Beta Review approval is still pending.

## Skipped with reason

| Check | Reason |
|---|---|
| New xcodebuild / Swift checks | This handoff introduced documentation only; no code, project, test or workflow file changed |
| App Group inspection/reset | Explicitly outside the fresh-install evidence scope; would change the evidence boundary |
| Additional scheme download | Not needed; the authorized 雾凇 gate already passed |
| Product risk acceptance / Release action | Accepted and executed under the separate public external-testing exception; this handoff still does not convert the result into a Release Gate Pass |

## Release decision boundary

The separate public external-testing exception is the Product decision for channel scope; the overall Quality/Release Gate
remains open. The repository can support a scoped claim that Build 55's 雾凇 nine-key path was exercised successfully on
the designated iPhone, but it cannot yet claim complete performance, Full Access degradation/recovery, crash/Jetsam or
clean fresh-install evidence.

### Human decision on further TD-004 induction

On `2026-09-13`, the Human Product Owner accepted the recommendation to preserve the verified 雾凇
installation rather than uninstall it to force a resource-not-ready state. This preserves the current
candidate and does not close TD-004 or replace the required Quality/Release conclusion. The later public external-testing
exception separately authorizes the App Store Connect channel action; resource-not-ready recovery remains an explicit open item.

## TD-005 read-only classification follow-up

The executor completed the authorized read-only TD-005 follow-up on `2026-09-13`. The existing report hashes were
reconfirmed; the three Jetsam rows containing the frozen App/Keyboard UUIDs still have no victim/jettisoned/killed
or process-level reason marker and remain `unclassified`. The App/Keyboard executable UUIDs also match across the
retained Archive, Store/Ad Hoc exports and dSYMs, but the Archive and dSYM metadata report `CFBundleVersion=1`
while the exported packages and export summaries report Build `55`. The subsequent Archive ↔ export reconciliation
confirmed the code-image lineage and export-stage Build 55 provenance, while retaining the metadata difference
explicitly. See the [`TD-005 classification follow-up receipt`](release-2026-09-13-build55-td005-classification-follow-up.md)
and the [`Archive ↔ export reconciliation receipt`](release-2026-09-13-build55-archive-export-reconciliation.md).

The follow-up itself was artifact-only: no new device action, installation, termination induction or Git action occurred
in that slice. The later App Store Connect external-testing action is recorded in the post-handoff update above. The overall
Quality/Release conclusion remains **Blocked**.

## Archive ↔ export reconciliation

The authorized Release/Artifact owner read-only check confirmed that the frozen project and retained Archive are
`1.0 (1)`, while both Store and Ad Hoc export records explicitly carry `buildNumber=55` and produce `1.0 (55)`.
App/Keyboard executable UUIDs, dSYM UUIDs and the non-identity resource manifest match across the retained artifacts;
the export logs also show the Archive product tree entering the distribution pipeline. The relationship is therefore
**conditionally reconciled at code-image and export-provenance level**, but the Archive/dSYM `CFBundleVersion=1`
metadata difference remains recorded and is not silently rewritten to `55`. See the [`Archive ↔ export reconciliation receipt`](release-2026-09-13-build55-archive-export-reconciliation.md).

This narrows the artifact-identity question; it does not classify the three Jetsam rows or close TD-005. Independent
Quality/Release re-review completed on `2026-09-13` and returned **Blocked**; see the section below.

## Independent Quality/Release review

The independent read-only review and the subsequent re-review completed on `2026-09-13` and returned **`Blocked`**.
The re-review accepts the scoped Build 55 雾凇 nine-key, Luna 26-key, Full Access on/off observations, the bounded
diagnostic observations listed above and the conditional Archive/export candidate relationship, but it does not close
TD-003, TD-004, TD-005 or the clean App Group boundary. It also does not treat the uploaded `1.0 (55)`
`Complete / Ready to Submit` state as external-group, Beta Review or Release completion. See the prior
[`Quality/Release review`](../reviews/release-2026-09-13-build55-quality-release-review.md) and the new
[`Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md) for the conclusion
matrices, accepted claims and required Product Lead decision. The re-review does not require a true `CFBundleVersion=55`
Archive/dSYM for the bounded candidate relationship; that artifact remains necessary only if Release/Artifact policy
requires an exact Archive identity claim.

## Owner handoffs

1. 🧪 Quality / Performance / Release: independent review and re-review have returned **Blocked**; preserve the conditional Archive/export relationship and do not promote the scoped claims to an overall Release Pass.
2. 🧭 Product Lead: decide whether to authorize another evidence slice for TD-003/TD-004/TD-005 and the clean shared-container
   boundary; any skipped-gate risk must be explicitly scoped, owned and recorded.
3. 📋 Program / Release coordination: monitor Beta Review approval, preserve the public-link/Build-55 status, and track the
   remaining screenshot and Task11/F-03 material without presenting the channel exception as a Release Gate Pass.

This handoff itself authorizes no Git or formal Release Gate action. The separate public external-testing exception records
the completed Build 55 group assignment, Beta Review submission and public-link creation; testers remain unable to join
until Apple approves the build.
