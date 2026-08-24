# Evidence: RELEASE-2026-0801-08 pending kaomoji Core (2026-08-23)

**Assignment:** [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md)  
**ADR:** [`0030`](../architecture/decisions/0030-pending-kaomoji-palette.md) Accepted  
**PD:** [`PD-RELEASE-2026-0801-08-KAOMOJI-CATALOG`](../product-decisions/RELEASE-2026-0801-08-kaomoji-catalog.md)

## What landed

- Parallel Core state `pendingKaomoji` next to `pendingPunctuation`.
- Action `.pressKaomoji` from nine-key and Chinese symbols-page `^_^`.
- Candidate kind `.kaomojiCandidate`; compact includes pending; `^_^` always first; no same-key cycle.
- Mutual exclusion with ADR 0029 punctuation pending (accept, do not delete already-accepted host text).
- `KeyboardEffect` widened to `UInt16` so `.pendingKaomojiChanged` can use bit 8.

## Verification

| Check | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore --filter 'PendingKaomojiTests\|T9PendingPunctuationTests\|CandidateKindTests'` | 61/0 |
| `swift test --package-path Packages/KeyboardCore` | 1054/0 |
| `xcrun swift-format lint --strict` on changed Swift | pass |
| App/Keyboard Debug build (`iPhone 17 Pro, OS=26.0`) | BUILD SUCCEEDED |
| KeyboardTests / RimeBridgeTests / App tests | not run in this slice |
| VoiceOver / physical device | not run |

Independent Architecture review: [`Pass`](../assignments/release-2026-08-01-08-architecture-review.md) `2026-08-23`. Human-reported device smoke: [`evidence`](release-2026-08-01-08-human-device-smoke-2026-08-23.md).

## Non-claims

- Not 08 Exit Criteria.
- Not independent Architecture review.
- Not Product Gate for accessibility or visual certification.
- Catalog glyphs remain Human-correctable near-duplicates.

## Handoff to task 05

First-party string literals in KeyboardCore. Do not describe this as an Apple kaomoji dump or a third-party kaomoji project in App Store copy.
