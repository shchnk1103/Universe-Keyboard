# RELEASE-2026-0801-04 — Build 55 TD-005 systemCrashLogs 查询回执

> **Run ID:** `RELEASE-2026-0801-04-B55-TD005-SYSTEM-CRASH-20260913`
> **Status:** `Collected — bounded systemCrashLogs query; TD-005 remains open`
> **Evidence grade:** `Executor-recorded` for device query, report copy and identity filtering
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Related diagnostic run:** [`Build 55 / Xcode 27 RC diagnostic capture`](release-2026-09-12-build55-td003-xcode27rc-diagnostic.md)

## Scope and boundary

本回执记录在同一台 iPhone 13 Pro 上对 CoreDevice `systemCrashLogs` 的一次有界只读查询，目标是检查
Build 55 的 `Universe Keyboard` / `Keyboard` 是否有可绑定的 crash 或 Jetsam 原始报告。查询和报告复制
没有安装、卸载、启动、终止、清理 App Group/RIME/user dictionary 或要求 Human 输入。

系统报告可能包含设备标识、路径和其他敏感元数据；原始 bytes 只保存在 git-ignored 的受控 evidence 目录，
本回执只记录必要的身份、分类字段和摘要，不记录用户输入、宿主文字或候选内容。

## Frozen identity and query

| Boundary | Recorded value |
|---|---|
| Candidate source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60`; current worktree changes are documentation-only |
| Candidate | Xcode Cloud `Archive Pilot (No Distribution)` Build `55`; version `1.0 (55)` |
| App executable UUID | `6898B44F-EF4F-3B46-93C8-BCE83668270A` |
| Keyboard executable UUID | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` |
| Device | Physical iPhone 13 Pro (`iPhone14,2`), iOS `27.0 (24A435)`; UDID recorded only as a hash in the related receipt |
| Installed app preflight | `devicectl` reported `Universe Keyboard`, version `1.0`, bundle version `55` |
| Query surface | `systemCrashLogs`, searches `Universe`, `Jetsam` and `crash` |
| Observation time | `2026-09-13T12:35:12+08:00` (bounded query completed) |

The installed executable byte readback limitation from the related Build 55 receipt remains in force. The matching
UUIDs in the Jetsam process rows bind those rows to the candidate identity, but do not provide device-installed SHA-256
bytes.

## Query result

| Query | Result |
|---|---|
| `systemCrashLogs --search Universe` | One `Universe Keyboard` crash report, from Build `1`, not Build `55` |
| `systemCrashLogs --search Jetsam` | Four current `JetsamEvent` reports: one without a product process row; three with Build 55 App/Keyboard UUID rows but no victim marker |
| `systemCrashLogs --search crash` | Only historical sysdiagnose crash directories in the returned listing; no additional current product crash file |

## Classification

### Mismatched crash report

`Retired/Universe Keyboard-2026-09-11-191458.ips` is a real crash report, but it is not evidence for Build 55:

| Field | Observed value |
|---|---|
| Version / build | `1.0 (1)` |
| App UUID | `7e8336d3-adcd-3268-a212-724f57a14ac1` |
| Debug dynamic payload UUID | `9d3987ae-057b-3d0b-91fe-330116ab37dd` |
| Termination | `EXC_CRASH` / `SIGKILL`, namespace `RUNNINGBOARD` |
| Classification | `unrelated artifact; excluded from Build 55` |

### Jetsam reports

The reports are `bug_type=298` snapshots. They contain no `victim`, `jettisoned`, `killed` or process-level `reason`
field for the matching product rows. Per the crash/Jetsam handbook, process presence and memory-page values alone do
not prove that the process was terminated.

| Report time | Largest process | Build 55 product rows | Keyboard row | Classification |
|---|---|---|---|---|
| `2026-09-12 19:17:22 +0800` | `WeChat` | none | — | unrelated snapshot |
| `2026-09-12 20:28:57.16 +0800` | `com.apple.dt.instruments.dtsecur` | App and Keyboard UUIDs match | PID `8530`, `active,frontmost`, `rpages=1645`, `lifetimeMax=1645` | `unclassified`; no product victim evidence |
| `2026-09-12 22:26:07.06 +0800` | `WeChat` | App and Keyboard UUIDs match | PID `8915`, `suspended`, `rpages=2769`, `lifetimeMax=2776` | `unclassified`; no product victim evidence |
| `2026-09-13 09:51:46.25 +0800` | `WeChat` | App and Keyboard UUIDs match | PID `9442`, `suspended`, `rpages=2746`, `lifetimeMax=3000` | `unclassified`; no product victim evidence |

All three matching reports record `pageSize=16384`. The corresponding Keyboard resident/lifetime-max values are:

| Report time | Keyboard resident (`rpages × pageSize`) | Keyboard lifetime max (`lifetimeMax × pageSize`) |
|---|---:|---:|
| `2026-09-12 20:28:57.16 +0800` | `26,951,680` bytes | `26,951,680` bytes |
| `2026-09-12 22:26:07.06 +0800` | `45,367,296` bytes | `45,481,984` bytes |
| `2026-09-13 09:51:46.25 +0800` | `44,990,464` bytes | `49,152,000` bytes |

The `20:28:57.16` snapshot is approximately `26.469 s` after the related Time Profiler trace ended at
`20:28:30.691`. The temporal proximity is recorded for correlation only; it is not a causal termination claim.

## TD-005 outcome

| Claim | Outcome | Boundary |
|---|---|---|
| Current device `systemCrashLogs` acquisition path exercised | `pass` | Read-only listing, targeted copies and hashes completed |
| Build 55 UUID filtering exercised | `partial` | App and Keyboard UUIDs appear in three Jetsam snapshots; installed bytes were not readable |
| Build 55 crash classification closed | `not-run` | The only named crash report is Build 1 and is excluded |
| Build 55 Keyboard Jetsam classification closed | `not-run` | No report marks Keyboard as victim/jettisoned/killed; rows remain `unclassified` |
| TD-005 handbook closed | `not closed` | Acquisition path is exercised, but current termination classification and symbolication path remain incomplete |

## Raw artifact pointers and hashes

Raw artifacts are retained under the git-ignored controlled archive:
`evidence/release-2026-0801-04-build55/2026-09-13/raw/td005-system-crash-logs/`.
The original report copies remain on the device; the local copies below are unchanged after acquisition.

| Artifact | SHA-256 |
|---|---|
| `unrelated-universe-keyboard-2026-09-11-191458.ips` | `8637a8716967c50dd8df8229280a38c374ee7884a1030bca9471a6ed3e732184` |
| `jetsam-2026-09-12-191722.ips` | `c71b7ba218faecc7f7d0fdbb44dbbf9f97eba3d32ce2874961e4792086c2bca1` |
| `jetsam-2026-09-12-202857.ips` | `486d647bcc513edbbfba4a9b998cb5be94e4e92325b7e3f93353b31bf421aac7` |
| `jetsam-2026-09-12-222607.ips` | `c2e70724d1e4e067de9f8f24471d5d3416576574081066bfde93a2c95bb5e3b1` |
| `jetsam-2026-09-13-095146.ips` | `e9fd9ce2f0356fa14f457b3ef8559907a24f95d1d1c6d142dee7491c5da98929` |
| `device-apps.json` | `8ccd0043a979f1b0767ee4f946ae9d040dcd94fa8ea3be10f0ef870104af3a80` |
| `device-details.json` | `fa1c161911413b98dc64df19ef4b60007ef6281f057dfef2e601c8cf9b472be2` |
| `system-crash-logs-search-universe.json` | `18c5862147b3682a1408a30b1ea2db898f62b5ad6fc04d3f767d519b27ac3aae` |
| `system-crash-logs-search-jetsam.json` | `84c162dee9208dde4d031063b0d0f54880648ce8c79082f59c670a3b9b12ceea` |
| `system-crash-logs-search-crash.json` | `32821268cde20bb9f82fbc469e8a0d6f061a0196677e09e200bc24a70532b517` |

## Handoff

This receipt improves TD-005 evidence from “no query performed” to “current-device acquisition and UUID filtering
exercised”, while preserving `unclassified` where the report does not identify a victim. It does not close TD-003,
TD-004, TD-005 or the fresh-install boundary, and it does not authorize TestFlight, distribution or release.

The next legal step is a separate Human/Product decision: authorize a documented termination/recovery scenario with
the frozen Build 55 manifest, or keep TD-005 open and record the release risk separately. No code, install, uninstall,
commit, push or external distribution action was performed by this receipt.
