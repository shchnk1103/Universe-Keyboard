# TYPING-INTELLIGENCE-001 Synthetic Performance Evidence

> **Evidence date:** 2026-07-11 Asia/Shanghai
>
> **Assignment:** [`TYPING-INTELLIGENCE-001`](../assignments/typing-intelligence-001.md)
>
> **Evidence status:** Automated synthetic evidence accepted; physical-device comparison remains open

## Environment

- Implementation baseline commit: `cd31785d00dc234021f44e89b432576b01fe0825`
- Host: Apple silicon, macOS 27.0 build `26A5378j`
- Toolchain: Xcode 27.0 build `27A5218g`, Apple Swift 6.4
- Configuration: Swift Package Manager Release build
- Command: `swift test --package-path Packages/KeyboardCore -c release --filter TypingIntelligencePerformanceTests`

The working tree contained the active Typing Intelligence implementation and unrelated pre-existing files listed in the implementation plan. This record does not assign benchmark results to the baseline commit alone.

## Workloads And Results

| Workload | Measured body | Mean wall time | Samples | Result |
|---|---|---:|---:|---|
| Grapheme classification | Classify a 360-grapheme synthetic mixed-content string 500 times | 0.060 s | 10 | Passed |
| Commit callback and aggregation | Perform 1,000 English direct-key commits, classify each event and enqueue its content-free delta into the in-memory writer | 0.004 s | 10 | Passed |

The second workload excludes persistence flushing from the measured body. One explicit test-only flush runs after measurement so the queued aggregate path is exercised without introducing storage work into the key-path measurement.

## Interpretation

- The benchmark confirms that the committed-text callback performs classification and in-memory aggregation without synchronous App Group reads, JSON encoding or persistence writes.
- The 1,000-commit mean corresponds to approximately 0.004 ms per synthetic commit in this host process. This is arithmetic derived from the measured workload, not a device latency budget.
- Classification throughput is bounded by the test input and aggregate categories; it does not preserve or serialize the synthetic text.
- No numeric product budget or regression threshold is accepted by this evidence.

## Limitations And Open Evidence

- This is a macOS package microbenchmark, not an iOS Keyboard Extension measurement.
- It does not measure touch handling, UI feedback, RIME, process scheduling, App Group filesystem latency, memory pressure, jetsam or host-App switching.
- It is not a disabled-versus-enabled comparison against the primary physical device.
- Physical-device continuous typing, memory, process-death and Full Access evidence remains required by `docs/PERFORMANCE_BASELINE.md` and the Assignment.
- The classification sample's relative standard deviation was 4.903%. The callback workload's relative standard deviation was 18.676%, so its mean is directional evidence only.

## Conclusion

**PASS for the automated synthetic gate.** The design has a non-persisting measured key-path body and no observed functional failure under the bounded workload. **OPEN for release performance acceptance** until the required physical-device comparison is recorded.
