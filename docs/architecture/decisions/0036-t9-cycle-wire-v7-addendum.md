# ADR 0036 Addendum: T9 cycle and delete events use wire v7

## Status

Accepted for the T9-PINYIN-CYCLE-009 S1 implementation. This addendum does not decide the privacy classification, Release capture default, or performance acceptance.

## Decision

1. New `t9.cycle_result` and `t9.delete_path` records use schemaVersion 7 only. They do not extend the v5 or v6 contracts.
2. This build's Main App and Keyboard Extension write newly persisted records as v7. Readers still accept retained v3, v4, v5, and v6 neighbors under their own versions.
3. An unknown schema version is rejected and the page stays incomplete. It must not be presented as an empty log, and there is no legacy fallback.
4. A cycle snapshot's candidate band, preedit shape, and existing criteria come from the `replaceInput` result before rollback, not from the restored output. `preedit_shape` only classifies separator scalars and does not keep a substring.
5. The T9 admission chain assigns the sequence and time and enqueues inside one successful `os_unfair_lock_trylock`, or returns immediately. It must not call `DiagnosticsJournalRuntime.record`, `DiagnosticsJournalIngress.record`, `Mutex.withLock`, or the Debug ticket set.
6. Resource auditing is not enabled. Capture reuses the default-off `logging_enabled` switch. A build containing these events must not enter TestFlight before the Human privacy classification.
7. S1c: a background pump takes admission batches and writes typed v7 events; `utcTimestamp` is the background assembly time and the monotonic field is the admission time. The pump reads the advance-only close generation `logging_close_generation` before every take and drops the untaken tail and any unwritten Ingress batch when it is newer than the last seen value. The writer re-checks it immediately before the first `handle.write`. A close followed by a reopen never resurrects the old tail.
8. Commitment sentence (also shown in Settings): 「关闭开关后，键盘在察觉到关闭之后不再开始新的写入；察觉之前已经开始写盘的那一批会写完。不承诺具体毫秒数。」

## Related Documents

- [ADR 0036](0036-diagnostic-event-wire-v4-writer-compatibility.md)
- [ADR 0036 v6 addendum](0036-keyboard-wake-wire-v6-addendum.md)
- [ADR 0027](0027-enterprise-local-diagnostic-observability.md)
