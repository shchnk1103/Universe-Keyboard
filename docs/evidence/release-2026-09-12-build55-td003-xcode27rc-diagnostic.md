# RELEASE-2026-0801-04 — Build 55 / Xcode 27 RC 真机诊断采集回执

> **Run ID:** `RELEASE-2026-0801-04-B55-XCODE27RC-20260912`
> **Status:** `Collected — valid physical diagnostic capture; TD-003/004/005 remain open`
> **Evidence grade:** `Executor-recorded` for machine collection and export; Human operation completion is recorded separately as `Device-attested`
> **Collected:** `2026-09-12 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Release ledger:** [`RELEASE-2026-0801`](release-2026-08-01-acceptance.md)
> **Related functional gate:** [`Build 55 physical Product Gate`](release-2026-09-12-build55-physical-product-gate.md)

## Scope、authority 与 non-claims

Human Product Owner 在当前会话授权：在只有 Xcode `27.0 RC` 可用的环境中，对精确 Build 55
重新尝试一次有界真机采集。本回执记录一次 all-processes Time Profiler、其导出表和只读设备版本查询。
它不重写 `2026-08-24` P4 的两次 `Device disconnected` 历史失败，也不把本次单轮随机输入升级为
正式性能基线、Quality Pass、Product Gate 全量通过或 Release 授权。

Human 完成了声明的随机合成输入；精确数字序列、候选、宿主文字和周边内容均未写入回执。此次运行未执行
全新安装、Full Access off/on 对照、Activity Monitor 内存快照、crash/Jetsam 原始报告采集或恢复/终止流程。

## Frozen candidate and runtime manifest

| Boundary | Recorded value |
|---|---|
| Source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Xcode Cloud | `Archive Pilot (No Distribution)` Build `55`; Build ID `8ca1634e-9139-405a-aa5c-75c3d6919908` |
| Version/build | `1.0 (55)` |
| App bundle | `com.DoubleShy0N.Universe-Keyboard` |
| Keyboard bundle | `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| Ad Hoc package | Existing Build 55 functional-gate record; package SHA-256 `de5b9b355f87af094b669f2548fb2811e8c1cf529dc551276dda8128b0ef8152` |
| App executable | UUID `6898B44F-EF4F-3B46-93C8-BCE83668270A`; Ad Hoc extracted SHA-256 `2a63c53a656ec5e5ccb8307f45c095b4bb26773cc45c94c1af0df53a9f3b1609`; `7,964,720` bytes |
| Keyboard executable | UUID `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25`; Ad Hoc extracted SHA-256 `3ae37666bcba90e3cceb92683a673da20ba06ae86a7c16c31f720754f6033bff`; `5,707,616` bytes |
| App dSYM | UUID matches; DWARF SHA-256 `e93313058a4983af7a8d5f5d75aff751a53899becceb3329a7a9eea9bd88d5d0` |
| Keyboard dSYM | UUID matches; DWARF SHA-256 `d82a1ca71fec466acf23fd7be12431fd794392e8b7b77211732cda034434ec0f` |
| Installed receipt | `devicectl` reported `Universe Keyboard` / bundle `com.DoubleShy0N.Universe-Keyboard` / version `1.0` / bundle version `55` |
| Installed byte readback | Not available. The receipt and exported UUIDs bind the candidate identity; device-installed executable bytes were not copied back |
| Measurement tool | Xcode/Instruments `27.0 (27A266a)`; template `Time Profiler`; all processes; deferred recording; Hangs threshold `>250 ms` |
| Device | Physical iPhone 13 Pro (`iPhone14,2`), iOS `27.0 (24A435)`; device UDID hash `sha256:713f2a42a07a609959252ee4ce3d3e5664f2ca0a6b6384a67f17ec7ace243e88` |
| Measurement host | macOS `27.0 (26A428)` on `DoubleShy0N’s MacBook Pro` |
| Host field | Otherwise-empty Reminders title field; no reminder was completed or saved |
| Schema/access | Human was instructed to use Universe Chinese nine-key with Full Access on inherited from the preceding Build 55 smoke; exact deployed schema digest and an off/on comparison were not collected |
| Thermal/debugger | Not recorded as a controlled variable; no Xcode Run/Debug attach was used |

The Time Profiler export emitted the App executable UUID and it matches the Build 55 Archive/Ad Hoc/dSYM UUID.
The Keyboard process was sampled, but this export did not emit its loaded-image UUID; the Extension UUID above is
therefore the Archive/Ad Hoc/dSYM identity, not a claim that this particular export independently re-emitted that UUID.

## Collection result

| Check | Result | Grade / boundary |
|---|---|---|
| Trace retention | Start `2026-09-12T20:27:29.521+08:00`; end `2026-09-12T20:28:30.691+08:00`; duration `61.170705 s`; end reason `Time limit reached` | `Executor-recorded`; valid collection-level result |
| Main App process | `Universe Keyboard` PID `8570`; `774` Time Profiler sample rows; first/last relative samples `00:22.147.991` / `00:38.660.989` | `Executor-recorded` |
| Keyboard Extension process | `Keyboard` PID `8530`; `3,238` Time Profiler sample rows; first/last relative samples `00:41.237.992` / `00:59.291.991` | `Executor-recorded` |
| Potential hangs | Export contained `5` all-process rows, belonging to WeChat, Twitter, and Reminders; no `Universe Keyboard` or `Keyboard` row | `Executor-recorded`; no product-specific `>250 ms` row in this table, not proof of no smaller stall |
| Human input | Random synthetic input completed; no raw input or candidate content retained | `Device-attested` for action completion only |
| Crash/Jetsam | No raw OS crash/Jetsam report was acquired in this run | `not-run`; no “proved no crash” claim |

This is a process-sampling and collector-validity result. The sample-row counts are not a latency, CPU-budget,
memory or regression metric, and are not comparable to a fixed-cadence benchmark.

## Claim boundary

| Claim | Outcome | Evidence |
|---|---|---|
| Build 55 was installed on the named iPhone | `pass` for the reported receipt | `device-apps.json`, bundle version `55` |
| Xcode 27 RC can retain this physical-device Time Profiler arm | `pass` for this run | `toc.xml`, normal time-limit termination |
| Both product processes were sampled during the window | `pass` for process presence/sampling | `time-profile.xml`, PIDs and sample rows above |
| This run establishes the repository TD-003 numeric baseline | `inconclusive` | One random single run; no cold/warm pair, fixed cadence, memory or candidate/first-key coverage |
| TD-004 Full Access degradation matrix is closed | `not-run` | Full Access off/on matrix absent; this run used the on treatment only |
| TD-005 crash/Jetsam/symbolication handbook is closed | `inconclusive` | No OS report/classification window; Keyboard UUID was not emitted by this Time Profiler export |
| Fresh-install boundary is closed | `not-run` | Replacement install with retained app/container state; no uninstall or App Group reset |

## Raw artifact pointers and hashes

Raw trace data is now copied outside Git into the project's git-ignored controlled evidence archive at
`evidence/release-2026-0801-04-build55/2026-09-12/raw/`. The original `/private/tmp/uk-build55-td003-xcode27rc.jUoEYM`
directory remains unchanged as a recovery copy; the archive copy is the canonical local pointer for this receipt.

| Artifact | Pointer | SHA-256 / size |
|---|---|---|
| Raw Time Profiler trace | `evidence/release-2026-0801-04-build55/2026-09-12/raw/td003-time-profiler.trace` | `56M` trace bundle; deterministic file-manifest SHA-256 `f297d889346511931a62983be8e22e228d6e646d99a52b11aeee12e350c3c4ee` |
| Trace TOC | `evidence/release-2026-0801-04-build55/2026-09-12/raw/td003-time-profiler.toc.xml` | `8f2547fc680c80f173a7c2400b72ae56729269413556abc8c3984a922a533aae` |
| Time Profiler table | `evidence/release-2026-0801-04-build55/2026-09-12/raw/td003-time-profiler.time-profile.xml` | `cd65b84be3801ce98bd8bebc0cb3a0e1bb4e84c0b51f65d0409c0d624de458b0` |
| Potential-hangs table | `evidence/release-2026-0801-04-build55/2026-09-12/raw/td003-time-profiler.potential-hangs.xml` | `d58a17fe1f1b8bdae1cc3c267e2d8a3ad05944c66363b980741fb76107d14be3` |
| Process-info table | `evidence/release-2026-0801-04-build55/2026-09-12/raw/td003-time-profiler.process-info.xml` | `bce1bc5992e3735d85a9d660aee0ac4586b4236e30cf72658be9faed182dbb0c` |
| Device app receipt | `evidence/release-2026-0801-04-build55/2026-09-12/raw/build55-device-apps.json` | `20fb94d695078084ab62277dc98942712967f897c3eba9abd9eaafe643d4e674` |
| Dyld table export | `evidence/release-2026-0801-04-build55/2026-09-12/raw/td003-time-profiler.dyld-library-load.xml` | `c6482649b06f543695216f5f5e21696def50369444e0ffccf0764aa45a5ecc3c`; no rows emitted |

## Handoff and revalidation

The prior P4 environment failure is retained as historical evidence. This one successful Xcode 27 RC collection
removes only the claim that every retry in the current environment fails before retention; it does not close the
Assignment or accept any release risk.

The next legal step is a separate Product/Quality decision: either collect the remaining Release-like cold/warm,
multiple-run, candidate, first-key and memory evidence plus the documented crash/Jetsam query, or record a narrowly
scoped Human risk decision for the intended distribution channel. A public TestFlight/release action remains outside
this receipt.

Revalidation is required when source/build/archive, device/OS, schema/access treatment, host, Xcode/Instruments,
raw-artifact retention or measurement method changes. No code, install/uninstall, commit, push or external
distribution action was performed by this evidence writeback.
