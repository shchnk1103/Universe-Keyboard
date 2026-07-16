# Post-Commit Continuation V1.3 Physical-Device Acceptance Record

> **Evidence status:** Completed package; independent Quality/Architecture review pending
>
> **Collection date:** `2026-07-16 Asia/Shanghai`
>
> **Assignment:** [`POST-COMMIT-CONTINUATION-001`](../assignments/post-commit-continuation-001.md)
>
> **Build under test:** `eaa72d5207deacab1dc0b94024c67af96448ad19` (`Release`, merged PR #13)

## Environment

| Field | Recorded value |
|---|---|
| Device | Physical iPhone 13 Pro (`iPhone14,2`), 256-GB capacity; free-space state was not captured |
| Device UDID | `00008110-000A08440198801E` |
| OS | iOS 27.0 beta 3, build `24A5380h` |
| Connection | Wired, paired, Developer Mode enabled |
| Host | Messages, ordinary draft text field; no message was sent |
| Schema | `rime_ice`; installed/current state was confirmed by the human owner before the run |
| Access | Full Access on; system keyboard registration and the enabled permission were rechecked in Settings |
| Build | Normally signed physical-device Release build from commit `eaa72d5` |
| Toolchain | Xcode 27.0 (`27A5218g`), `xctrace` 27.0 |
| Thermal | `Fair` throughout both 30-second steady-state Activity Monitor runs; no thermal state was induced |
| Debugger | No LLDB debugger attached; Instruments recorded all processes |

The signed Release build used strict Swift 6 checking with warnings treated as
errors. The build succeeded. Xcode 27 beta also emitted two toolchain caveats:
App Intents metadata extraction was skipped because the target has no App
Intents dependency, and `dsymutil` reported a missing temporary PCM search
path. Neither warning identified a Swift source warning or a runtime failure,
but both remain part of this snapshot rather than being reported as a clean
zero-warning build.

## Frozen Method

The paired steady-state sequence used the same device, OS, host field, Release
artifact, `rime_ice` deployment, Full Access state and controlled Device Hub
tap cadence. Each state ran three repetitions in Activity Monitor and three in
Time Profiler:

1. start with an empty draft and Chinese mode;
2. tap `c h i l e` at a fixed 180-ms cadence;
3. select the first composition candidate, `吃了`;
4. wait 1.2 seconds for the candidate bar;
5. clear the two committed characters before the next repetition.

With the setting enabled, every repetition exposed the V1.3 resource sequence
`吗 / 饭 / 什么 / 东西` (the leading item shares the candidate bar's expand
area in the compact view). With the setting disabled, `吃了` still committed
normally and the post-commit candidate bar stayed empty.

Cold-start runs began with a non-Universe keyboard selected and the previous
Keyboard Extension process explicitly terminated. Activity Monitor recording
started before the human owner selected Universe Keyboard. Each newly created
process then completed one real `chile -> 吃了` interaction. Absolute
trace-start-to-selection time is excluded because it includes human response
time; cold-start comparison begins at the first `sysmon-process` row for the
new Keyboard process.

## Results Snapshot

### Repeated Final Commit And Candidate Refresh

| Metric | Enabled | Disabled | Comparison |
|---|---:|---:|---:|
| Activity Monitor CPU time over the 30-second trace | 751.4 ms | 719.3 ms | +32.1 ms / +4.5% |
| Activity Monitor mean CPU | 3.29% | 2.68% | +0.61 percentage points |
| Time Profiler 1-ms Keyboard samples | 792 | 787 | +5 / +0.6% |
| Time Profiler main-thread samples | 665 | 638 | +27 / +4.2% |
| Physical-footprint median | 23.67 MiB | 24.36 MiB | -0.69 MiB |
| Physical-footprint peak | 23.80 MiB | 24.56 MiB | -0.77 MiB |
| Potential hangs at or above 250 ms | 0 | 0 | no difference |

The CPU differences agree across Activity Monitor and Time Profiler and remain
small relative to the fixed interaction workload. The enabled path did not
increase the observed physical footprint. These results support a bounded
"no unexplained regression observed" conclusion for this build and device;
they do not establish a product-wide latency or memory budget.

### Cold Process Start

| Metric, relative to first Keyboard process sample | Enabled | Disabled | Comparison |
|---|---:|---:|---:|
| CPU-time increase in the first 5 seconds | 3.17 ms | 3.52 ms | -0.35 ms |
| First-5-second physical-footprint median | 10.53 MiB | 10.55 MiB | -0.02 MiB |
| Post-5-second physical-footprint median | 15.77 MiB | 15.67 MiB | +0.09 MiB |
| Observed physical-footprint peak | 15.95 MiB | 15.84 MiB | +0.11 MiB |
| First real RIME commit | succeeded | succeeded | no functional difference |
| Post-commit continuation | V1.3 sequence visible | empty by contract | expected difference |

The enabled and disabled cold processes used different PIDs (`13312` and
`13305`) created after explicit termination. The approximately 0.1-MiB
post-start difference is within the observed sampling variation and does not
show sustained growth in this bounded run.

## Raw Evidence And Integrity

The raw Instruments bundles are preserved locally under the ignored directory:

`evidence/post-commit-continuation-v1.3/2026-07-16/raw/`

The aggregate below is the SHA-256 of the sorted per-file SHA-256 manifest for
each trace bundle. Invalid pilot captures are intentionally excluded.

| Bundle | Aggregate SHA-256 |
|---|---|
| `enabled-activity.trace` | `25f548a73a7ff7c203e138d707f05e6d5cad45742cb6cfa51ee1bf07c169ea02` |
| `disabled-activity.trace` | `18d374d8d714da02342919854df1ebfdbf4809335747ced6e7562d3440079728` |
| `enabled-time.trace` | `fcfbb785646ad454c7191b1bed0995c0c329043dd2bc34615aed570e2a5e6cc4` |
| `disabled-time.trace` | `3a47e56d7146ce44ecde27ebb66a902e28edc8b1a05e2881dac01b01511ec7fb` |
| `enabled-cold-start.trace` | `fe634c396b4ca09a33b94e685aca872ea1a439cb0bf68922e2068b2a99dd35ef` |
| `disabled-cold-start.trace` | `13bd464fb9c95e17ae16de856c518ab17d33cab2af08250c9a20c08f5cbd0d25` |

The failed attached-PID attempt, the native-keyboard pilot and the first
enabled cold-start window that expired before Keyboard process creation are
not evidence and are not included in this archive.

## Acceptance And Non-Claims

- The human owner separately accepted the physical-device candidate behavior
  on this iPhone 13 Pro before the instrumented run.
- The instrumented run reconfirmed enabled/disabled behavior, cold-process
  recovery and repeated final commits without a visible hang, crash, fallback
  to another keyboard or duplicate insertion.
- The Messages draft was cleared after testing and no message was sent.
- The app setting was restored to its original enabled state.
- This record does not prove App Store/TestFlight compatibility, population
  language quality, exact per-refresh wall-clock latency, absence of jetsam,
  sustained leak freedom, Full Access-off behavior or performance on another
  device/OS/schema/build.
- Exact per-refresh Release timing was not logged because successful detailed
  key/candidate timings are Debug-only. The paired CPU samples, memory series,
  repeated visible result and zero 250-ms hang rows support the narrower
  regression conclusion without converting Debug diagnostics into product
  evidence.

## Review And Revalidation

PR #13 merged commit `eaa72d5`; its Swift 6 Quality and GitGuardian checks
passed, but GitHub reports no submitted reviews and no review decision. This
evidence package therefore advances the Assignment to `Completed`, not
`Reviewed` or `Closed`. An independent Quality/Architecture review of this
record and the merged implementation is required before closure.

Revalidate this snapshot after any change to the continuation resource or
provider, setting default, KeyboardCore commit/candidate semantics, candidate
presentation, RIME boundary, build configuration, device/OS, active schema,
Full Access state, Xcode/Instruments method or thermal comparability.
