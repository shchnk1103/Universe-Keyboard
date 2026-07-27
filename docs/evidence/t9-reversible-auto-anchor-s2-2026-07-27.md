# T9 reversible auto-anchor S2 evidence — 2026-07-27

## Scope

- Assignment: `T9-AUTO-ANCHOR-001`
- Device: iPhone 17 Pro Max Simulator
- Runtime: iOS 27.0
- Host: Reminders
- Configuration: Debug, software keyboard
- Synthetic pinyin:
  `jintiandetianqihenbucuowomenchuquwanba`

This record is diagnostic prototype evidence. It is not physical-device,
Release-like, Product Gate or production-budget evidence.

## Implementation boundary

- Controller capability defaults off.
- Keyboard Extension enables it only under `#if DEBUG`.
- At most one automatic apply `replaceInput` per composition.
- First visible candidate must provide a source-compatible, catalog-legal
  closed prefix.
- Lower incompatible candidates cannot authorize spelling; all bounded
  candidate texts remain in the post-replacement conservation check.
- Acceptance requires no commit, exact replacement raw identity, unchanged
  first candidate and at least 60% bounded candidate overlap.
- Rejection and Delete restore the pure-digit ledger. Restore failure resets
  the session and clears composition.
- No candidate-window scan, second RIME session, persistence, dictionary
  access, content-bearing logs or 26-key behavior change.

## Automated validation

| Layer | Result |
|---|---:|
| S2 focused Fake RIME tests | 9 passed |
| KeyboardCore full suite | 738 passed |
| iOS 27 Debug Simulator build | Passed, zero diagnostics |
| iOS 27 Release Simulator build | Passed, zero diagnostics |

The focused tests cover proposal legality, compatible-first authority,
candidate conservation, accepted continuation, drift rejection/restore,
one-attempt behavior, Delete rollback, disabled gate and failed-restore
fail-closed.

## Simulator A/B

### A — strict all-sampled-compatible proposal

The first implementation required every sampled candidate comment to map to
the same T9 source identity. Real output repeatedly contained:

- first page: 9 candidates;
- compatible paths: 1;
- rejected paths: 8.

No automatic proposal fired. Representative slow RIME calls remained:

| Source key position | RIME |
|---:|---:|
| 24 | 110.1 ms |
| 32 | 71.3 ms |
| 34 | 64.9 ms |

### B — compatible-first bounded preference

The revised policy lets only the first candidate authorize spelling and uses
lower candidates only when they are compatible; candidate conservation still
includes all bounded candidate texts.

At source length 18:

```text
T9AUTO status=accepted baseline=5 result=5 overlap=5 anchorSlots=13 unresolvedSlots=5
```

Representative slow RIME calls in the same 38-key sequence:

| Source key position | RIME |
|---:|---:|
| 24 | 77.2 ms |
| 32 | 54.4 ms |
| 34 | 41.1 ms |

The automatic transaction itself completed within the key-18 segment:
`total=7.3ms`, `rime=3.5ms`. The visible composition and candidate bar remained
usable through all 38 keys.

Computer-control tap-call timing was also lower in B (`max 136ms`, last 12
mostly `37–95ms`) than the prior UI run, but that measurement includes Mac UI
automation and event injection. It is not a product latency metric.

## B stability extension — five runs

The same software-keyboard sequence was repeated until five valid B runs were
available. Every run started with an empty composition and used only the
visible `ABC`–`WXYZ` letter-group keys. Invalid automation attempts made while
a system keyboard was visible were discarded before counting.

| Run | Auto-anchor | Baseline/result/overlap | Key 24 RIME | Key 32 RIME | Key 34 RIME |
|---:|---|---:|---:|---:|---:|
| 1 | Accepted at source slot 18 | `5 / 5 / 5` | 77.2 ms | 54.4 ms | 41.1 ms |
| 2 | Accepted at source slot 18 | `5 / 5 / 5` | 72.7 ms | 55.2 ms | 41.7 ms |
| 3 | Accepted at source slot 18 | `5 / 5 / 5` | 73.9 ms | 54.6 ms | 40.5 ms |
| 4 | Accepted at source slot 18 | `5 / 5 / 5` | 17.9 ms | 34.2 ms | 35.5 ms |
| 5 | Accepted at source slot 18 | `5 / 5 / 5` | 91.2 ms | 62.5 ms | 46.5 ms |
| **Median** | **5 / 5 accepted** | **all candidates conserved** | **73.9 ms** | **54.6 ms** | **41.1 ms** |

Across these runs:

- the accepted proposal remained `anchorSlots=13 unresolvedSlots=5`;
- no `rejected`, restore-failure or candidate-loss outcome appeared;
- key 24 and key 32 remained above 50 ms in four of five runs;
- key 34 stayed below 50 ms in all five runs, but remained a 35.5–46.5 ms
  RIME call;
- the hot segments remained RIME-dominated; Path-local and UI work stayed
  approximately sub-millisecond and around 2 ms respectively.

This establishes repeatability of the S2 transaction and candidate-conservation
gate for this one sentence. It also shows that S2 reduces but does not eliminate
the long-composition cliff. The runs were collected in one interactive session
with keyboard switching between samples; the fifth run required restarting
Reminders after iOS stopped exposing the extension in the short-tap keyboard
cycle. This is therefore a B stability slice, not a frozen-startup paired A/B.

For the fifth run only, the Simulator's enabled-keyboard list was temporarily
reduced to Universe Keyboard so the software keyboard could be selected. The
original five-entry list was restored and read back after the run.

## Reversibility observation

After B completed, one visible Delete:

- kept the Keyboard Extension alive;
- retained letter-only marked presentation;
- exposed no internal digit to Reminders.

The exact restore-before-delete call sequence is enforced by Fake RIME tests,
because the host UI does not expose the internal raw ledger.

## XCUITest limitation

The opt-in `T9LongCompositionS2UITests` harness compiles and can create/focus a
Reminders item. In the isolated UI-test invocation, switching to Universe
Keyboard triggered repeated iOS 27 invalid cross-`UIScreen` coordinate
conversion diagnostics and product-owned controls were not exposed before the
timeout. The extension rendered after the test process exited, after which the
manual software-keyboard A/B above was collected.

This is classified as an XCUITest/iOS 27 presentation limitation. It does not
count as a product pass or product failure.

## Conclusion and remaining gates

The S2 A/B and five-run B extension support the mechanism: a reversible prefix
anchor fired before the recurring ambiguity cliff with stable candidate
conservation and reduced the three representative RIME spikes. It did not
eliminate every slow call, and one Debug Simulator sentence is insufficient
for a product claim.

Next required evidence:

1. Frozen-startup paired S3 A/B with fixed cadence and per-run log extraction.
2. Expand the first six-case
   [`S3 corpus slice`](t9-reversible-auto-anchor-s3-corpus-2026-07-27.md)
   into a reviewed candidate-quality/rejection/rollback corpus.
3. Independent Architecture and Quality review.
4. Physical-device Release-like latency and interaction Product Gate.
5. Separate Product authorization before any Release-default enablement.
