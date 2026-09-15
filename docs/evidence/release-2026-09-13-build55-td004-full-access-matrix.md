# RELEASE-2026-0801-04 — Build 55 / TD-004 Full Access off/on 真机矩阵回执

> **Run ID:** `RELEASE-2026-0801-04-B55-TD004-FA-MATRIX-20260913`
> **Status:** `Collected — Build 55 physical off/on matrix; degradation visibility and full capability fidelity remain open`
> **Evidence grade:** `Executor-recorded` for machine process observation; `Device-attested` for Human Full Access state and behavior report
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Product source:** [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)
> **Related debt:** [`TD-004`](../TECH_DEBT.md#td-004-implement-full-access-degradation-matrix)

## Scope、authority 与 non-claims

本轮依据 Human Product Owner 对“继续进入 TD-004”的授权，在同一台 iPhone 13 Pro、同一 Build 55、同一方案与宿主下，
完成一次 Full Access off/on 对照。off 与 on 分别从新的 Keyboard Extension session 开始；每臂执行 90 次只读进程快照，
Human 在观察窗口内完成固定的无真实内容输入与候选提交检查。

Full Access 开关状态、输入结果、候选提交、震动/声音和是否出现提示均是 `Device-attested`；进程快照只能证明进程出现，
不能独立证明系统权限状态或 App Group 共享数据已经被读取。本轮不保存固定输入、候选文字、宿主文字或其他用户内容，
也不把诊断日志、单次人类观察或进程存在升级为 Quality Pass、Product Gate、TD-004 完成或 Release 授权。

## Frozen candidate and environment

| Boundary | Recorded value |
|---|---|
| Source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Xcode Cloud | `Archive Pilot (No Distribution)` Build `55`; Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| Version/build | `1.0 (55)` |
| App / Keyboard bundle | `com.DoubleShy0N.Universe-Keyboard` / `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| App executable UUID | `6898B44F-EF4F-3B46-93C8-BCE83668270A` |
| Keyboard executable UUID | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` |
| Device | Physical iPhone 13 Pro (`iPhone14,2`), iOS `27.0 (24A435)` |
| Host | Reminders blank title field; no reminder was saved |
| Schema / treatment | Universe Chinese nine-key; same already-deployed scheme; fixed synthetic `64426` input; no real content |
| Access sequencing | off arm first, then on arm; Extension session reset before each arm; no uninstall or App Group reset |

## Machine collection

| Arm | Process snapshots | Product observations | Process identity | Machine result |
|---|---:|---|---|---|
| Full Access **off** | `90/90` successful | Product present in `74/90`; Extension first appeared at snapshot `16` | Keyboard PID `10937`; Main App PID `10940` appeared at snapshot `61` | No non-empty collector stderr |
| Full Access **on** | `90/90` successful | Product present in `64/90`; Extension first appeared at snapshot `26` | Keyboard PID `10951`; Main App absent from this window | No non-empty collector stderr |

The off reset command returned `No such process` for the previously observed PID `10210`; the immediate follow-up snapshot showed
no Keyboard process, so this is recorded as a termination race/absence observation, not a product failure. Before the on arm, both
the preflight and post-reset snapshots showed no Keyboard process, so no second termination was needed. No main App was terminated.

The archived process JSON is privacy-filtered to remove command arguments and device identifiers. The original temporary capture
directories remain unchanged as recovery copies.

## Human-attested behavior

| Capability / observation | Full Access off | Full Access on | Evidence boundary |
|---|---|---|---|
| Keyboard appears and stays selected | Yes | Yes | `Device-attested`; process snapshots support Extension presence |
| Basic input | Available | Available | `Device-attested`; no content retained |
| Candidate appears and can be committed | Yes | Yes | `Device-attested`; fixed synthetic input only |
| Key vibration | **Absent** | **Present** | `Device-attested`; qualitative observation |
| Key sound | Present | Present | `Device-attested`; qualitative observation |
| In-keyboard degradation prompt | None observed | None observed | `Device-attested`; no self-diagnosing cue observed |

## Matrix conclusion

| Claim | Outcome | Reason |
|---|---|---|
| Basic typing does not require Full Access in this Build 55 / iOS 27 run | `supported` | Basic input remained available with off |
| Chinese candidate path is impossible with Full Access off | `rejected by observation` | Candidates appeared and committed with off; product copy must not make this claim |
| Shared feedback differs by Full Access state | `supported for haptics in this run` | Vibration absent off and present on; sound remained present in both arms |
| Full Access off is fully self-diagnosing in the Extension UI | `not supported` | No degradation prompt appeared in the off arm |
| All shared capabilities are healthy in both states | `not established` | Haptic switch propagation and a same-session learning effect are observed with Full Access on, but broader shared settings, process-boundary persistence, diagnostics, resource-not-ready or App Group reset behavior remain open |
| TD-004 is closed | `no` | One qualitative off/on run does not close matrix fidelity or Extension-visible recovery |

This revalidates the existing product implication: do not state that Full Access is required merely to type Chinese. The observed
dependency is narrower and clear for haptics, while the absence of a degradation cue leaves the self-diagnosing setup claim open.
The `ONBOARDING_ACTIVATION.md` design matrix and copy are not rewritten by this observation.

## Follow-up — explicit shared feedback switch propagation

> **Run ID:** `RELEASE-2026-0801-04-B55-TD004-FA-FEEDBACK-20260913`
> **Evidence grade:** `Device-attested`
> **Scope:** Build 55 / same iPhone 13 Pro / same 雾凇 deployment / Full Access on; no scheme switch,
> uninstall, reset or private content.

Human changed the main-App **「按键震动」** setting off, returned to the keyboard and pressed a synthetic
letter key, then changed the setting on and repeated the same observation. Vibration was absent after the
off change and returned after the on change; key sound remained present throughout, and the keyboard stayed
selected. This explicitly verifies propagation of the haptic preference from the main App to the Extension
for the Full Access-on state. It does not prove propagation of every other shared setting, nor does it close
the Full Access-off shared-container or recovery boundaries.

| Follow-up capability | Result | Boundary |
|---|---|---|
| Main-App haptic switch off reaches the Extension | `pass` | No vibration observed after returning to the keyboard |
| Main-App haptic switch on reaches the Extension | `pass` | Vibration returned after returning to the keyboard |
| Key sound unaffected by haptic switch | `pass` | Sound remained present in both observations |
| Keyboard session remains usable | `pass` | Keyboard stayed selected |

The observation is additive to the off/on matrix above. It narrows the unverified set to other shared
settings, user-dictionary process-boundary persistence and backup/restore, diagnostics persistence,
resource-not-ready recovery, clean-state App Group behavior and Extension-visible degradation presentation.

## Follow-up — candidate learning observation

> **Run ID:** `RELEASE-2026-0801-04-B55-TD004-FA-LEARNING-20260913`
> **Evidence grade:** `Device-attested`
> **Scope:** Build 55 / same iPhone 13 Pro / 雾凇 scheme / Full Access on; the existing user dictionary
> was not reset, no uninstall was performed, and no candidate or input text was retained.

Human confirmed **「候选学习」** for 雾凇, entered the declared synthetic key-label sequence, observed
candidates, selected a candidate that was not the leftmost one and committed it. Re-entering the same
sequence caused the previously selected candidate to move earlier in the candidate order. This supports
a current-device candidate-learning effect with Full Access on.

| Follow-up capability | Result | Boundary |
|---|---|---|
| Candidates appear and commit under the learning path | `pass` | Human reported both behaviors |
| A selected candidate is learned within the observed repeat path | `pass` | The selected candidate moved earlier on re-entry |
| User-dictionary persistence across an Extension restart | `not established` | No restart boundary was exercised in this round |
| Full Access-off learning behavior | `not established` | This round remained Full Access on |
| User-dictionary backup / restore and clean-state behavior | `not established` | Existing data was preserved; no reset or restore was performed |

## Follow-up — diagnostics persistence

> **Run ID:** `RELEASE-2026-0801-04-B55-TD004-FA-DIAGNOSTICS-20260913`
> **Evidence grade:** `Device-attested`
> **Scope:** Build 55 / same iPhone 13 Pro / 雾凇 scheme / Full Access on; main-App diagnostic recording
> enabled; no export, clear, uninstall or private content capture.

Human enabled **「记录诊断数据」** in the main App, returned to a blank host input field, invoked the
keyboard and performed the declared synthetic key action. After returning to the main App, a new
diagnostic record was visible and the keyboard remained normal. This verifies the observed main-App
diagnostic readback path after a Keyboard Extension event with Full Access on.

| Follow-up capability | Result | Boundary |
|---|---|---|
| Extension activity produces a new main-App diagnostic record | `pass` | New record was visible after returning to the main App |
| Keyboard remains usable while recording | `pass` | Human reported normal keyboard behavior |
| Full Access-off diagnostic persistence | `not established` | This round remained Full Access on |
| Diagnostic export/clear and private-content filtering | `not established` | No export or content inspection was performed |

## Follow-up — diagnostics with Full Access off

> **Run ID:** `RELEASE-2026-0801-04-B55-TD004-FA-OFF-DIAGNOSTICS-20260913`
> **Evidence grade:** `Device-attested`
> **Scope:** Build 55 / same iPhone 13 Pro / 雾凇 scheme / Full Access off; a new Extension session
> was created by switching away from and back to Universe Keyboard; no reset, uninstall or private content.

Human disabled **「允许完全访问」**, created a new keyboard session, performed the declared synthetic
key action and returned to the main App diagnostics view. No new diagnostic record was visible. The
keyboard remained selected and usable, and no degradation prompt appeared. This is a bounded observation
that shared diagnostic readback was not available in this off arm; it does not prove that every internal
diagnostic write failed, because the observation is based on the user-visible record after one session.

| Follow-up capability | Result | Boundary |
|---|---|---|
| Basic keyboard selection and input with Full Access off | `pass` | Keyboard stayed selected and usable |
| New main-App diagnostic record after off-arm Extension activity | `not observed` | No new record appeared after returning to diagnostics |
| Extension-visible degradation prompt when shared diagnostics are unavailable | `not observed` | No prompt appeared |

This confirms the remaining product gap: the off state preserves basic input but does not visibly explain
that shared diagnostics are unavailable in this observation. Full Access should be restored before the next
test slice.

## Follow-up — uninstalled scheme did not enter resource-not-ready

> **Run ID:** `RELEASE-2026-0801-04-B55-TD004-RESOURCE-NOT-READY-INDUCTION-20260913`
> **Evidence grade:** `Device-attested`
> **Scope:** Build 55 / same iPhone 13 Pro / Full Access restored; the existing 雾凇 installation and
> App Group were preserved; no scheme download, uninstall or reset.

Human confirmed that **万象拼音** remained marked **「可下载」** and did not download it. Keeping the
scheme uninstalled did not trigger a new RIME deployment; the main App continued to display **「已部署」**.
The safe induction path therefore never reached a resource-not-ready state and did not exercise the
Extension's recovery behavior.

| Follow-up capability | Result | Boundary |
|---|---|---|
| Uninstalled downloadable scheme remains available as a precondition | `pass` | 万象拼音 displayed「可下载」 |
| Avoid download and preserve the verified 雾凇 installation | `pass` | No download, uninstall or reset occurred |
| Main-App resource-not-ready transition | `not reached` | RIME did not redeploy and remained「已部署」 |
| Extension behavior and recovery while resources are not ready | `not established` | No resource-not-ready Extension session was created |

## Raw / controlled artifact pointers and hashes

Controlled evidence archive root:
`evidence/release-2026-0801-04-build55/2026-09-13/raw/`

| Arm | Archive | Contents | Digest |
|---|---|---|---|
| Full Access off | `td004-full-access-off/` | `90` privacy-filtered process snapshots + preflight/app/reset observations | Snapshot aggregate `fe7e16a4099d22dbcd13885b8086afcd4eb6161980a146c890e9bdec3baadd80`; complete archive manifest `0bfdffdafeb9a130a4439bb17f59686827fa8bbdd61b3b8c23c442d18aba0b2b` |
| Full Access on | `td004-full-access-on/` | `90` privacy-filtered process snapshots + preflight/app/reset observations | Snapshot aggregate `dee074e9b857710e49447853bead281baf4fbc99f50d7dec0ea8d08bd6f96ba7`; complete archive manifest `316b0739828b7d5408f54e1d0c4354e6e1f5dad8d5d5a49ece675f6cdeb5d665` |

Each arm's archive is approximately `372K`; no raw input or candidate content is present. Build/archive identity is bound to the
existing Build 55 artifact and diagnostic receipts.

## Handoff and next action

TD-004 now has a current Build 55 / iOS 27 off/on qualitative matrix with process-session observations. The residual is explicit:
Full Access off preserves basic input and candidate commit in this environment, haptics are unavailable, sound remains available,
and the Extension shows no degradation cue. The explicit main-App haptic switch propagation round passed with Full Access on;
the candidate-learning effect was observed in a same-session Full Access-on repeat; Full Access-off diagnostics
readback was not observed and no degradation cue appeared; other shared settings, process-boundary learning
persistence/backup/restore, resource-not-ready recovery and clean-state App Group behavior remain unverified.
The non-destructive uninstalled-scheme induction attempt did not leave the deployed state.

## Human decision — preserve the verified scheme state

On `2026-09-13`, the Human Product Owner accepted the recommendation to preserve the current verified
雾凇 installation and not uninstall it merely to induce a resource-not-ready state. No App Group cleanup,
scheme download, release-risk acceptance or external distribution authorization is implied. The
resource-not-ready and recovery boundary therefore remains open and must stay explicit in the independent
Quality/Release conclusion.

The next legal step is a Quality/Product decision on whether this partial matrix is sufficient for a narrowly scoped tester constraint,
or whether to authorize a separate bounded clean-state/recovery round. No code, commit, push, merge or external distribution action
occurred during this writeback.
