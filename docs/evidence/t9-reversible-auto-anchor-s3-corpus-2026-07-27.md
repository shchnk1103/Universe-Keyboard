# T9 reversible auto-anchor S3 corpus slice — 2026-07-27

## Scope

- Assignment: `T9-AUTO-ANCHOR-001`
- Device: iPhone 17 Pro Max Simulator
- Runtime: iOS 27.0
- Host: Reminders
- Configuration: Debug, software keyboard
- Input: synthetic pinyin only, through visible `ABC`–`WXYZ` keys

This is a first diagnostic corpus slice. It is not a representative language
quality benchmark, physical-device evidence, Release-like evidence or Product
Gate.

Each new case started in a newly launched Reminders item with an empty
composition. The Simulator temporarily exposed only Universe Keyboard so the
same software keyboard could be selected deterministically. Its original
five-entry keyboard list was restored and read back after collection.

## Matrix

| Case | Synthetic input | Slots | Result | Conservation | Anchor / unresolved | Observation |
|---|---|---:|---|---:|---:|---|
| Known positive | `jintiandetianqihenbucuowomenchuquwanba` | 38 | Accepted | `5 / 5` | `13 / 5` | Five-run stability sample remained accepted |
| Different sentence | `mingtianzaoshangwomenyiqiqugongyuanpaobu` | 40 | Rejected and restored | `2 / 5` | `11 / 7` | Candidate gate prevented a potentially disruptive replacement |
| Local-ranking shape | `jintiantianqihenhao` | 19 | Accepted | `3 / 5` | `13 / 5` | Exactly met the 60% gate; visible first candidate remained “今天天气很好” |
| High ambiguity | `shishishishishishishishishishishishi` | 36 | Accepted | `5 / 5` | `12 / 6` | Spelling remained repeated `shi`; base candidates were low quality |
| Legal-but-poor path | `aaaaaaaaaaaaaaaaaa` | 18 | Rejected and restored | `1 / 5` | `13 / 5` | Catalog legality alone did not bypass candidate conservation |
| Threshold boundary | `jintiandetianqihe` | 17 | Not eligible | — | — | No `T9AUTO`; the minimum-source threshold prevented mutation |

## Findings

### Candidate conservation is active safety, not a passive metric

The different-sentence case generated a legal proposal at source slot 18, but
only two of the five bounded baseline candidates survived. S2 restored the
pure-digit ledger and did not retry. The `a × 18` case similarly restored at
one of five overlap. These are real negative outcomes proving the transaction
does not accept every catalog-legal prefix.

The local-ranking case accepted with exactly three of five candidates. That is
the current 60% boundary, not surplus evidence. A focused unit contract now
asserts that three of five may accept while two of five must reject.

### Candidate conservation is relative, not absolute language quality

Repeated `shi` accepted with full overlap, but the resulting candidate texts
were inherently poor because the source itself is extremely ambiguous.
Conservation proves that automatic replacement did not damage the bounded
candidate set. It does not prove that the original candidate set was natural.

### Delete preserved safety but re-opened unresolved ambiguity

After the three-of-five accepted `jintiantianqihenhao` case, one visible Delete:

- kept the Keyboard Extension alive;
- exposed no digit to Reminders;
- restored the pure-digit ledger before one normal deletion, as enforced by
  the deterministic Fake RIME contract;
- displayed the remaining final `42` slots as `ga` rather than pinning the
  previous provisional `ha`.

The final spelling change is not a digit-ledger failure: `42` remains ambiguous
between legal T9 spellings after deleting the final `o` slot. It is nevertheless
a user-visible stability risk. Future corpus gates must record provisional
spelling stability separately from candidate conservation.

### Rejected sentences remain slow

The rejected 40-slot different-sentence case continued on pure digits and
recorded RIME-dominated calls including approximately:

- source key 22: `126.7 ms`;
- source key 24: `71.8 ms`;
- source key 26: `81.4 ms`;
- source key 32: `91.3 ms`;
- source key 36: `102.3 ms`.

Failing closed protects correctness but does not solve latency for that
sentence. A production strategy therefore cannot rely only on one attempt at
source slot 18.

## Regression coverage

`T9ReversibleAutoAnchorTests` now explicitly protects:

- compatible `jin / lin` Path divergence remains rejected in either candidate
  order, so local ranking cannot manufacture spelling authority;
- the five-candidate 60% boundary rounds up to three candidates;
- the existing accepted continuation, rejection restore, one-attempt,
  Delete rollback and restore-failure fail-closed contracts remain intact.

Validation:

| Layer | Result |
|---|---:|
| Focused `T9ReversibleAutoAnchorTests` | 9 passed |
| Complete KeyboardCore suite | 738 passed |

## Next gates

1. Expand to a reviewed synthetic corpus with declared expected spelling
   families and candidate-quality expectations.
2. Separate accepted, rejected, not-eligible and Delete-after-accept buckets.
3. Add a policy for a later safe attempt after an early candidate-conservation
   rejection; do not retry every key.
4. Decide whether provisional spelling changes after Delete require an
   explicit path-stability constraint or are normal unresolved-T9 behavior.
5. Run frozen paired performance sampling and independent
   Architecture/Quality review before any Release-default discussion.
