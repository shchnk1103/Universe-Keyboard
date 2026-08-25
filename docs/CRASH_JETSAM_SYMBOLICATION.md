# Crash、Jetsam 与符号化操作手册

> **Status:** Active operational procedure
> **Owner:** 🧪 Quality, Performance & Release Maintainer
> **Applies to:** Main App 与 Keyboard Extension 的开发、TestFlight 和 App Store 构建

## Purpose

本手册解决三个不同问题：进程为什么消失、报告属于哪个构建、地址如何映射回源码。三者必须分别证明，
不能因为键盘回退到系统键盘就称为 crash，也不能因为没有 crash 弹窗就称为没有 Jetsam。

Apple 的当前诊断边界：crash report 含终止信息与线程回溯；Jetsam event report 描述内存压力下的系统进程
快照，不含 App 线程回溯；device console 只用于围绕精确时间补充线索。分发前必须保留精确 Archive 与 dSYM。

Authoritative references:

- [Diagnosing issues using crash reports and device logs](https://developer.apple.com/documentation/xcode/diagnosing-issues-using-crash-reports-and-device-logs)
- [Acquiring crash reports and diagnostic logs](https://developer.apple.com/documentation/xcode/acquiring-crash-reports-and-diagnostic-logs)
- [Adding identifiable symbol names to a crash report](https://developer.apple.com/documentation/xcode/adding-identifiable-symbol-names-to-a-crash-report)
- [Identifying high-memory use with jetsam event reports](https://developer.apple.com/documentation/xcode/identifying-high-memory-use-with-jetsam-event-reports)

## Before reproduction

Freeze one run manifest before the Human Device Operator types anything:

| Boundary | Required record |
|---|---|
| Source/build | commit, immutable tag, marketing version/build, workflow and Xcode/SDK |
| Installed payload | App and Keyboard executable UUID, SHA-256 and size |
| Symbols | App and Keyboard dSYM UUID plus DWARF SHA-256 |
| Runtime | device model/UDID, OS build, host app, Full Access, schema/layout and orientation |
| Time | local timezone, run start/end and the exact observed disappearance time |
| Privacy | synthetic input only; no typed text, surrounding text or candidates in the receipt |

Follow [`kos/universe-keyboard-human-operated-evidence-profile.md`](kos/universe-keyboard-human-operated-evidence-profile.md).
After the manifest is frozen, an unlisted build or install invalidates the run.

## Acquire the original report

Use the first available source and retain the original bytes:

1. **Connected physical device:** Xcode → Window → Devices and Simulators → select device → View Device Logs; export the
   relevant `Keyboard` or `Universe Keyboard` report. Jetsam/watchdog reports may instead need the device Analytics Data
   surface or direct transfer described by Apple.
2. **TestFlight/App Store:** Xcode Organizer → Crashes for reports available through App Store Connect. Apple documents
   automatic TestFlight crash-report delivery to the developer; a tester's optional written feedback, screenshots or other
   context is a separate sharing action. Watchdog, code-signature, thermal and Jetsam reports may still require direct device
   collection.
3. **Non-crash anomaly:** connect the device, select it in Console.app, reproduce once and record the exact time window.
   Console lines supplement but do not replace the OS report.

Keep `.ips`/`.crash` and Jetsam JSON unchanged. Work from a copy if Xcode needs a different filename extension for an old
crash-report workflow. Before sharing externally, inspect and redact personal identifiers; never edit the retained original.

## Classify termination before symbolication

| Observation | Required proof | Classification |
|---|---|---|
| Crash report names App/Keyboard and contains exception/termination plus binary images | complete OS report | `crash` |
| Jetsam report contains the Keyboard process in `processes` and marks it as victim/jettisoned | report header + matching process row | `jetsam` |
| Extension disappears, later relaunches, and no matching crash/Jetsam report exists in the bounded window | lifecycle sequence + bounded negative query | `ordinary lifecycle / unclassified`; never “proved no crash” |
| `EXC_RESOURCE` with `MEMORY` subtype | matching OS report | resource-limit report; analyze separately from a Jetsam JSON event |
| Report belongs to another version/build/UUID | report identity | unrelated artifact; exclude from this run |

For Jetsam, record `pageSize`, device/OS build, `largestProcess`, the Keyboard row's `name`, `uuid`, `reason`, `states`,
`rpages` and `lifetimeMax`. Memory bytes are `rpages × pageSize`. Being the largest process is a diagnostic clue, not proof
that the Keyboard was the victim. If the Keyboard row or victim evidence is absent, leave the result `unclassified`.

## Bind a report to the exact dSYM

Never select symbols by filename or version alone. Read the report's binary-image UUID and compare it to the retained dSYM:

```bash
xcrun dwarfdump --uuid "/path/to/Universe Keyboard.app.dSYM"
xcrun dwarfdump --uuid "/path/to/Keyboard.appex.dSYM"
```

Spotlight can locate already indexed candidates by UUID:

```bash
mdfind "com_apple_xcode_dsym_uuids == <UUID>"
```

The UUID must match the relevant App or Extension binary exactly, including architecture. Record the dSYM DWARF SHA-256 and
the owning Archive ledger. A version/build match without UUID equality is insufficient.

For frozen RC `testflight-v1.0-rc1-build7` / Build `1.0 (7)`, the current ledger records:

| Binary | UUID |
|---|---|
| App | `3AC2D57A-F20A-3B1F-A4C3-37DFA2F619D2` |
| Keyboard Extension | `08834E19-48AC-3A9C-AE0C-F53EBE94D720` |

These values expire when the candidate build changes. The canonical hashes remain in the
[`Build 7 artifact ledger`](evidence/release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md).

## Symbolicate

Use Xcode first because it can combine the matching App/Extension dSYMs and device-specific OS symbols:

1. Connect a device on the OS version recorded in the report so Xcode can acquire matching system symbols when available.
2. Open Devices and Simulators → Device Logs or the relevant Organizer crash.
3. Import/open the complete report with the matching `.xcarchive`/dSYMs available locally.
4. Confirm project frames show function names; preserve both original and symbolicated outputs.

For a specialized single-frame check only, `atos` may map an address when the architecture and binary load address/slide are
known:

```bash
xcrun atos -arch arm64 \
  -o "/path/to/Keyboard.appex.dSYM/Contents/Resources/DWARF/Keyboard" \
  -l <binary-load-address> <frame-address>
```

Do not use guessed load addresses or a single `atos` result as a substitute for full-report symbolication. Jetsam reports have
no thread backtraces, so they are classified and quantified rather than symbolicated like crashes.

## Evidence storage and receipt

Raw reports may contain device identifiers, paths and other sensitive metadata. Store them outside Git in the controlled run
directory; commit only a content-free receipt and hashes unless a reviewer explicitly approves a redacted fixture.

Required receipt fields:

```text
runId / buildTag / commit / versionBuild
deviceModel / deviceUDIDHash / osVersionBuild / host / access / schema
windowStart / windowEnd / observedTerminationTime
classification / processName / reportIncident / reportSHA256
binaryUUID / matchedDSYMUUID / dSYMDWARFSHA256
symbolicationStatus / firstProjectFrame
jetsamReason / pageSize / rpages / lifetimeMax (when applicable)
rawArtifactPointers / redactionStatus / owner / nextAction
```

Hash every original report before analysis. If no report matches, record the queried source, bounded time window and query
result; a bounded no-match is not proof that no producer/report exists.

## Release decision boundary

- An unexplained termination is a `Fail/Blocked` input to `RELEASE-2026-0801-04`, not a reason to guess-fix inside the
  evidence task.
- Retained Archive/dSYM plus a tested collection/classification path can satisfy TD-005; it does not close TD-003 performance
  or TD-004 Full Access.
- Upload and external distribution remain separately authorized actions. After upload, revalidate that App Store Connect
  received symbols and that Organizer reports map to the same build.
- Any source/build/UUID change invalidates the report mapping and requires a new ledger.
