# NATIVE-EXPERIENCE-001 — Step 4 Evidence Validation

> **Status:** Active
>
> **Entry date:** 2026-07-11 Asia/Shanghai
>
> **Current source of truth:** this active validation plan plus NE assignment records still open.
>
> **Related ADRs:** as cited by linked NE assignments
>
> **Note:** Status normalized from “In Progress” to the governance enum `Active`.

Entry Date: 2026-07-11

Protocol: `docs/plans/native-experience-001-investigation-protocol.md`

Input Record: `docs/plans/native-experience-001-step-3-evidence-collection.md`

Authorization: Product Lead accepted partial Step 3 closure on 2026-07-11 and
authorized Step 4 validation of already collected Measurements.

## Scope Boundary

This Step validates raw Measurement records and extracts Evidence only when
the frozen protocol requirements are satisfied. It does not fill collection
gaps, reinterpret interrupted artifacts as successful recordings, create
performance conclusions, or modify production code.

Entry into Step 4 does not mean Step 3 achieved complete coverage. Missing or
ineligible measurements remain explicit gaps.

## Validation Rules

Each candidate Measurement must pass all applicable checks:

1. Environment metadata is complete and matches a Step 2 environment.
2. The referenced artifact exists and its checksum can be verified.
3. Trace artifacts are readable and contain the claimed recording data.
4. The measurement group contains at least five comparable samples.
5. Debugger, thermal, background-load, runtime, schema, and host anomalies are
   absent or explicitly flagged.
6. Qualitative observations remain qualitative and cannot support quantitative
   latency or performance Evidence.

Failure of a validation check flags the Measurement or group; it does not
constitute a Universe Keyboard product failure.

## Initial Input Classification

| Input | Initial Step 4 disposition | Reason |
|---|---|---|
| NE1-M-044, NE1-M-046 through NE1-M-049 | Eligible for detailed validation | Five Simulator Time Profiler cold-activation samples are recorded; metadata, checksum, readability, comparability, and contamination checks remain required. |
| NE1-M-045, NE1-M-050 through NE1-M-053 | Eligible for detailed validation | Five Simulator System Trace cold-activation samples are recorded; metadata, checksum, readability, comparability, and contamination checks remain required. |
| NE1-M-043 | Exclude from baseline validation | Physical iPhone / iOS 27.0 warm pipeline sample does not match NE1-ENV-001. |
| NE1-M-036 through NE1-M-042 | Qualitative support only | These records may preserve observed behavior but cannot establish quantitative performance Evidence. |
| Interrupted and 40 KB partial trace attempts | Exclude | Recording completion and usable trace content were not established. |
| NE1-M-028 and NE1-M-029 | Validate only as standalone manual artifacts | Successful save was recorded, but scenario alignment, sample count, metadata, and trace content must be checked before any Evidence extraction. |

This table is an intake classification, not a validation result.

## Validation Run NE1-S4-V001 — Cold-Activation Trace Groups

Validation Date: 2026-07-11

Toolchain:

- macOS: 27.0 build `26A5378j`
- Xcode: 27.0 build `27A5218g`
- xctrace: 27.0 (`27A5218g`)
- Commands: `shasum -a 256 -c` and `xcrun xctrace export --toc`

Candidate groups:

- Time Profiler: NE1-M-044, NE1-M-046 through NE1-M-049
- System Trace: NE1-M-045, NE1-M-050 through NE1-M-053

### Artifact Integrity

All ten trace bundle manifests passed SHA-256 verification. The manifests
covered between 831 and 2,256 files per trace bundle. Recorded bundle sizes
ranged from approximately 71 MB to 118 MB for Time Profiler and from
approximately 786 MB to 3.0 GB for System Trace.

The bundle manifests cover the trace contents only. They do not include the
corresponding metadata text file or the manifest file itself. Trace integrity
is therefore verified against the recorded manifests, while original metadata
integrity cannot be independently established from those manifests.

### Trace Readability And Declared Content

`xctrace export --toc` completed successfully for all ten trace bundles:

- every Time Profiler trace contains the `time-profile`, `process-info`, and
  `thread-info` schemas;
- every System Trace contains `context-switch`, `syscall`, `thread-state`,
  `process-info`, and `time-profile` schemas;
- every trace records `Time limit reached` as its end reason;
- every trace includes a `Keyboard` process path under Simulator UDID
  `900FB396-39BF-4A84-9E75-FF813C155FA7` and the Universe Keyboard extension
  bundle.

This validates that the artifacts are readable recordings containing the
claimed instrument families and the target extension process. It does not
validate the cold-start precondition or measurement comparability.

### Environment And Cold-State Validation

All ten trace TOCs identify the recording target as:

- platform: `macOS`
- target: All Processes
- host OS: macOS 27.0 build `26A5378j`

Their process tables contain a mixture of Mac host processes, iOS 26.5
Simulator processes, and iOS 27.0 Simulator processes. The Universe Keyboard
process path is bound to the expected iOS 26.5 Simulator UDID, but the trace
target is broader than the NE1-ENV-001 Simulator-only identity stated in the
Step 3 metadata.

The Keyboard process identities also conflict with the repeated cold-start
claim:

| Sample | Time Profiler Keyboard PID | System Trace Keyboard PID |
|---|---:|---:|
| 001 | 85010 | 89572 |
| 002 | 89572 | 89572 |
| 003 | 89572 | 89572 |
| 004 | 89572 | 89572 |
| 005 | 89572 | 89572 |

PID `89572` persists across recordings from 20:42 through 22:13. This is
incompatible with five independently established extension-non-resident cold
starts. The trace artifacts therefore do not support the metadata assertion
that the Keyboard Extension was not resident before every sample.

The metadata files also do not record debugger state, thermal state, or a
bounded background-load assessment. Sample 001 explicitly records a temporary
visual presentation anomaly. These gaps prevent the required anomaly and
contamination checks from passing.

### Validation Decision

| Check | Time Profiler group | System Trace group |
|---|---|---|
| Five recorded samples | Pass | Pass |
| Trace manifest verification | Pass | Pass |
| xctrace readability | Pass | Pass |
| Claimed instrument data present | Pass | Pass |
| Expected Universe Keyboard process present | Pass | Pass |
| NE1-ENV-001-only target identity | Flagged | Flagged |
| Independent cold-start precondition | Not Pass | Not Pass |
| Debugger / thermal / background metadata | Not Pass | Not Pass |
| Metadata covered by original checksum | Not Pass | Not Pass |
| Eligible for quantitative Evidence extraction | No | No |

NE1-S4-V001 produces no validated Evidence record. The two groups are retained
as readable trace artifacts and tooling evidence, but they cannot support cold
activation timing, CPU, scheduling, startup, or first-input performance
conclusions.

## Deferred Tooling Revalidation

When a subsequent macOS 27 beta or Xcode 27 beta is installed, rerun the
minimal Simulator Time Profiler CLI smoke probe before attempting automated
batch collection. Record the exact host, Xcode, Simulator runtime, command,
completion state, artifact size, and trace readability.

The deferred retry does not block validation of currently eligible inputs and
does not reopen Step 3 unless Product Lead explicitly does so.

## Current Boundary

Step 4 has started and NE1-S4-V001 is complete. No Measurement has been
promoted to a validated Evidence record (`NE-E-{NNN}`). Remaining Step 3
inputs still require classification or validation before Step 4 can close.
Step 5 must not start until Step 4 records its complete validation results and
flagged anomalies.
