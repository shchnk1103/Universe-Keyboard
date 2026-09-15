# RELEASE-2026-0801-04 — Build 55 / TD-003 冷暖切换诊断采集回执

> **Run ID:** `RELEASE-2026-0801-04-B55-TD003-COLD-WARM-20260913`
> **Status:** `Collected — partial diagnostic evidence; TD-003/004/005 and fresh-install remain open`
> **Evidence grade:** `Executor-recorded` for machine collection/export; Human operation completion is `Device-attested`
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Related receipts:** [`Build 55 / Xcode 27 RC diagnostic`](release-2026-09-12-build55-td003-xcode27rc-diagnostic.md) · [`Build 55 TD-005 query`](release-2026-09-13-build55-td005-system-crash-query.md)

## Scope、authority 与 non-claims

本轮是在当前已授权的最短安全路径下，对精确 Build 55 进行一次物理设备诊断采集。采集包含
150 秒 all-processes Time Profiler、导出表和 `devicectl` 只读进程快照。Human 完成了声明的合成输入与宿主切换动作；
本回执只记录动作完成，不保存固定数字序列、候选、宿主文字或其他真实输入内容。

本轮没有执行安装、卸载、进程终止、App Group 重置、Full Access off/on 对照、Activity Monitor 内存快照或分发动作。
因此本回执不宣称已建立 TD-003 的冷/暖启动、首键、候选、延迟、CPU 或内存数字基线，也不宣称 TD-004、TD-005、
全新安装边界、Quality Pass、Product Gate 或 Release 已通过。

## Frozen candidate and runtime manifest

| Boundary | Recorded value |
|---|---|
| Source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Xcode Cloud | `Archive Pilot (No Distribution)` Build `55`; Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| Version/build | `1.0 (55)` |
| App bundle | `com.DoubleShy0N.Universe-Keyboard` |
| Keyboard bundle | `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| App executable UUID | `6898B44F-EF4F-3B46-93C8-BCE83668270A` |
| Keyboard executable UUID | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` |
| Installed receipt | Same-device read-only preflight reported `Universe Keyboard`, version `1.0`, bundle version `55` |
| Device | Physical iPhone 13 Pro (`iPhone14,2`), iOS `27.0 (24A435)` |
| Measurement host/tool | macOS `27.0 (26A428)`; Xcode/Instruments `27.0 (27A266a)` |
| Measurement | `Time Profiler`; all processes; deferred recording; Hangs threshold `>250 ms`; requested limit `150 s` |
| Host field | Blank Reminders title field; no reminder was completed or saved |
| Treatment | Universe Chinese nine-key, Full Access on; synthetic input and a host switch were Human-attested |

Candidate identity and archive/dSYM mapping are inherited from the frozen Build 55 record; this run did not copy installed
executable bytes back from the device.

## Collection result

| Check | Result | Grade / boundary |
|---|---|---|
| Trace retention | Start `2026-09-13T12:44:56.315+08:00`; end `2026-09-13T12:47:27.555+08:00`; duration `151.239897 s`; normal `Time limit reached`; command exit `0` | `Executor-recorded`; collection valid |
| Product process snapshots | `48/48` read-only snapshots reported Main App PID `8570` and Keyboard PID `10210`; both were present in the first and last snapshot | `Executor-recorded`; process presence only |
| Main App Time Profiler rows | `0` rows in the exported time-profile table; `process-info.xml` still declares `Universe Keyboard (8570)` | Present but not sampled in this table; no Main App CPU claim |
| Keyboard Extension Time Profiler rows | `3,625` rows; first/last relative samples `00:57.164.796` / `02:22.022.797` | `Executor-recorded`; sample presence, not a performance budget |
| All-process Time Profiler rows | `194,064` `<row>` elements in the exported table | Collection volume only; not a latency/CPU metric |
| Potential hangs | `3` rows: two Reminders rows (`488.10 ms` microhang, `810.58 ms` hang) and one WeChat row (`945.74 ms` hang); no product row | No product-specific `>250 ms` row in this export; not proof of no smaller stall |
| Human operation | Declared synthetic sequence and host switch completed; no raw input retained | `Device-attested` for action completion only |

The collector preflight had no matching product process, while the first process snapshot already contained both product PIDs.
The snapshots do not carry a process-launch timestamp, and this run did not terminate/relaunch either process under machine control;
the cold/warm boundary is therefore not independently measurable from this run.

The export also emitted the known host dylib-overlap warnings for Spotlight and `LocalAuthenticationUIService`; collection and
all exports completed successfully. No product-specific hang, crash, Jetsam, memory snapshot, candidate/first-key timing or
diagnostic-log export was produced by this run.

## Claim boundary

| Claim | Outcome | Evidence |
|---|---|---|
| Build 55 identity was the intended candidate | `pass` for the existing device receipt and frozen archive mapping | Build 55 receipt and `process-info.xml`/snapshot executable paths |
| Xcode 27 RC can retain a 150-second physical-device diagnostic arm | `pass` for this run | `toc.xml`, normal time-limit termination, exit `0` |
| Both product processes remained observable during the capture | `pass` for process presence | `48` successful process snapshots; stable PIDs `8570` / `10210` |
| Keyboard Extension was sampled | `pass` for sample presence | `3,625` Keyboard rows in `time-profile.xml` |
| TD-003 cold/warm numeric baseline is established | `inconclusive` | No controlled terminate/relaunch, no launch boundary, no fixed latency/cpu/memory/candidate metrics, one run |
| TD-004 Full Access degradation matrix is closed | `not-run` | Full Access on only; no off/on comparison |
| TD-005 crash/Jetsam/symbolication is closed | `not-closed` | Separate systemCrashLogs query remains unclassified; this run did not induce or classify termination |
| Fresh-install boundary is closed | `not-run` | No uninstall, App Group reset or clean-install treatment |
| Product/Quality release decision | `pending` | This is diagnostic evidence only |

## Raw artifact pointers and hashes

Raw artifacts were copied without overwrite from `/private/tmp/uk-build55-td003-cold-warm.jIyKq2` into the project's
git-ignored controlled evidence archive. The archive contains the raw Trace bundle, five XML exports, `48` JSON process
snapshots and their `48` stderr sidecars. No raw input is present in the archive.

Archive root: `evidence/release-2026-0801-04-build55/2026-09-13/raw/td003-cold-warm/`

| Artifact | SHA-256 / size |
|---|---|
| Raw Time Profiler trace bundle | `79M`; deterministic file-manifest SHA-256 `8ab5bbc076dc22557916228582997b038f682febdf05fcc166b9c732c8622fcf` |
| `toc.xml` | `8fc7fd11a8cfe6832c5a68b5d6036a94cf09ee51686d40e95051f57b5782bc0e` |
| `time-profile.xml` | `118M`; `f872e32370bb604a73901e951171bc706adb42022c817628a7a2773a55721450` |
| `potential-hangs.xml` | `c1143fcabc18fd89154661add527f671dee28768a44575300bd557966d7ab6c9` |
| `process-info.xml` | `790f8e9825b45b44579bb39d4b64c0245267d779413a18b2f39b45e8d2846850` |
| `dyld-library-load.xml` | `c6482649b06f543695216f5f5e21696def50369444e0ffccf0764aa45a5ecc3c` |
| `processes-*.json` aggregate | `48` snapshots; aggregate SHA-256 `c072c3ca850c645c2a37be5ce7c10cb4b0c30edc9e620f668771bc71392aad5b` |
| Complete archive manifest | `f9efe7b3ee2e092de0e7bdc6a924dae0d380405a19570c0093ab5ed6fc9b1fc1` |

## Handoff and next action

This run removes the question of whether Xcode 27 RC can retain a longer physical diagnostic window and confirms that the
product processes were observable during that window. It does not repay TD-003, TD-004 or TD-005, and does not close the
fresh-install boundary. The existing Build 55 functional Product Gate remains separate from these residual gates.

The next legal step is a Product/Quality decision: accept this as partial diagnostic evidence and assign a new bounded evidence
round for the remaining Release-like cold/warm, Full Access, memory and termination/fresh-install boundaries, or record a
narrowly scoped Human risk decision for the intended distribution channel. No code, commit, push, merge or external distribution
action occurred during this writeback.
