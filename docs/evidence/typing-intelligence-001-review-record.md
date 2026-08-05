# TYPING-INTELLIGENCE-001 Review Record

> **Review date:** 2026-07-11 Asia/Shanghai
>
> **Assignment:** [`TYPING-INTELLIGENCE-001`](../assignments/typing-intelligence-001.md)
>
> **Overall release conclusion:** BLOCKED

## Architecture Review

**Conclusion: PASS for ADR 0011 conformance.**

- Collection originates after final client commit and remains outside RIME integration and candidate generation.
- The event text is ephemeral and non-serializable. Persistence receives only bounded numeric deltas and source-category counts.
- Extension writes are coalesced on a utility queue; the measured callback path performs no synchronous App Group read, JSON encoding or persistence write.
- The App Group snapshot is versioned, bounded to 365 daily buckets and protected by a reset epoch.
- Main-App ownership is limited to settings, reading and clearing the shared aggregate.
- Existing keyboard visibility and RIME lifecycle callbacks were not extended or redefined.

No architecture revalidation trigger was observed. Any future raw-text field, network path, storage-engine change or lifecycle relocation requires a new decision.

## Quality Review

**Conclusion: PASS for automated implementation evidence; BLOCKED for release acceptance.**

Completed evidence:

- KeyboardCore full suite: 544 tests passed, 0 failed.
- Main Xcode test run: 79 tests passed, 0 failed, 0 skipped on the dedicated non-NE1 Simulator before the final documentation-only updates.
- Strict Debug iOS Simulator build: passed with complete concurrency checking and warnings treated as errors.
- Strict Release iOS Simulator build: passed with the same strict settings.
- Synthetic Release performance tests: 2 passed; limitations are recorded in the performance evidence.
- Source and built-product privacy manifests: all four files passed `plutil -lint`.
- Whitespace/error audit: `git diff --check` passed.
- Representative active-state Simulator UI and accessibility tree were inspected. No clipping or incoherent overlap was observed in that state.

Open release evidence:

- physical-device Full Access on/off behavior;
- queued-write behavior across Extension process death and restart;
- sustained English/Chinese typing latency and Extension memory comparison;
- host switching, crash/jetsam and failure-degradation behavior;
- dark appearance, larger Dynamic Type, reduced motion and complete VoiceOver traversal;
- final App Privacy declaration review against the submitted binary;
- reproducible NE1 hash/metadata comparison for files that were already untracked at the implementation baseline.

The current Xcode test host reports duplicate-loading warnings for package classes in the app debug dylib and test bundle. Tests pass; this remains test-host noise unless runtime evidence shows a product duplicate-symbol or state-ownership defect.

## Product And Program State

Product Review is not eligible while the Quality release blockers remain open. Program Manager synchronization must keep the Assignment `Active`; no `Completed`, `Accepted` or `Closed` state is authorized by this record.
