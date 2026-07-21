# KEYBOARD-LAYOUT-9KEY-PINYIN-002 — Architecture / Quality Review Handoff

Prepared by: Codex（Executor）  
Handoff target: Architecture & Knowledge Steward + Quality, Performance & Release Maintainer  
Date / timezone: `2026-07-19 Asia/Shanghai`  
Working tree: **dirty / uncommitted** — Product Decision forbids commit/push/PR without separate Human authorization.

> Assignment remains `Active — Phase 5`. This handoff requests independent conclusions; it does not self-approve Architecture, Quality, or Product Gate.

## Authority

- Product Decision: [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md)
- Assignment: [`keyboard-layout-9key-pinyin-002.md`](keyboard-layout-9key-pinyin-002.md)
- Architecture: [ADR 0021](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md), extending ADR 0020
- Domain source: [`KEYBOARD_LAYOUT.md`](../KEYBOARD_LAYOUT.md)
- Real-runtime evidence: [`keyboard-layout-9key-pinyin-002-spike-summary.md`](keyboard-layout-9key-pinyin-002-spike-summary.md)

## Implemented behavior

1. A single unresolved digit derives a complete ordered key-identity choice set in KeyboardCore; `6` displays `m / n / o` even when live RIME comments expose only `o`.
2. Multi-digit/mixed paths continue to come from compatible current RIME comments; no Cartesian expansion or second candidate engine was added.
3. A successful single-key `replaceInput` retains the issued sibling choices and selected path while live RIME raw/preedit/candidates update.
4. Direct taps and `cycleT9PinyinPath` use the same exact-success/rollback transaction. Cycle order is none → first → next → wrap.
5. **选拼音** now cycles compact choices and never presents the predecessor path panel. UIKit renders/forwards only; VoiceOver reports current value and selected state.
6. Before first selection all paths remain plain. The selected path uses the same inverse-color, 8 pt rounded highlight as the preferred candidate.
7. Successful explicit selection writes the exact path label to host marked text after live RIME apply; candidate comments cannot replace `m/n/o` with a longer spelling. Rollback restores the prior marked value.

## Review entry points

- `Packages/KeyboardCore/Sources/KeyboardCore/T9PinyinPath.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/KeyboardController+T9PinyinPath.swift`
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift`
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9PinyinSelectionSpikeTests.swift`
- `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift`
- `Keyboard/Views/T9PinyinPathBarView.swift`

## Architecture questions

1. Is the canonical single-digit mapping correctly limited to key identity, with RIME retaining exclusive Chinese candidate/ranking ownership?
2. Does retained choice provenance remain valid only for sibling refinement and clear/rebuild on every required lifecycle boundary?
3. Are direct/cycle selection, exact raw validation, no-commit acceptance, and rollback one coherent transaction?
4. Are Extension session-only, deployment, privacy, bounded hot-path, and Swift 6 boundaries unchanged?
5. Is leaving the old expanded-panel implementation unreachable an acceptable scoped compatibility choice, or must deletion be separately authorized?

## Quality evidence

| Check | Result |
|---|---|
| Real pinned librime Spike (`m/n/o`) | PASS; candidate counts `9/9/4`; no committed text |
| Focused `T9PinyinPathTests` | PASS; 27 tests, 0 failures |
| KeyboardCore full suite after acceptance fix | PASS; 621 tests, 0 failures |
| Debug generic iOS Simulator strict build | PASS |
| Release generic iOS Simulator strict build | PASS; existing Boost x86_64 slice linker warnings remain |
| RimeBridgeTests on iOS 27.0 simulator | PASS; 32 executed, 4 fixture-gated skips, 0 failures |
| Main `Universe Keyboard` simulator scheme tests after acceptance fix | PASS |
| `git diff --check` | PASS |

The default RimeBridgeTests run intentionally skipped the fixture-gated T9 Spike. The same new test was separately run with explicit isolated T9 fixture through the Spike runner and passed. Publication-grade Spike evidence remains pending because the current authorized implementation tree is dirty.

## Required independent checks

- Re-run focused/full tests from the current tree and inspect failures rather than relying on this summary.
- Verify new-input, Delete, final commit, page/language, visibility, fallback, and recovery invalidation.
- Verify failed selection restores RIME output, marked text, choices, and prior selected item.
- Confirm no host raw commit, deployment, network, persistence, or unbounded candidate scan was introduced.
- Record explicit Architecture and Quality conclusions before Product Gate.

## Stop-condition status

No implementation Stop Condition was observed. No vendor/schema/deployment change occurred. Automated evidence must not be treated as physical-device Product acceptance.

## Amendment A — Segmented Disambiguation Delta

- Native observation: [`keyboard-layout-9key-pinyin-002-native-segmented-observation.md`](keyboard-layout-9key-pinyin-002-native-segmented-observation.md)
- Real-runtime hard gate: [`keyboard-layout-9key-pinyin-002-segmented-spike-summary.md`](keyboard-layout-9key-pinyin-002-segmented-spike-summary.md) — PASS on librime `1.16.1`, `authorizedSuffixes=g|h`; fallback-only `n'i` rejected.
- Core state now records source digits, focused key group, confirmed values, tentative selection, issued replacements, and provenance. New-focus authorization uses a bounded live-comment probe followed by exact raw restoration.
- Local delta validation: focused path tests `34/34`; KeyboardCore `628/628`; Debug and Release generic iOS Simulator strict builds PASS. Existing Boost x86_64 slice notes remain unchanged.
- Independent review focus: synchronous bounded-probe latency in the Extension, complete rollback after partial probe failure, three-or-more groups, Delete across focus boundaries, and UIKit `选定` title/accessibility refresh.
- This amendment has not received a new independent Architecture or Quality conclusion; prior baseline conclusions do not automatically accept it.

## Amendment C — Long-input Choice Preservation Delta

- The first 16 ranked candidates are no longer treated as an exhaustive next-syllable catalog; confirm/advance reads a bounded window up to 48 candidates.
- When exact syllables do not fill the five-item compact limit, Core probes at most the current physical key group and publishes only branches with matching live segment comments. Exact raw retention and non-empty candidates alone remain insufficient.
- Every probe restores the prior ambiguous raw, and every newly published focus has no selected path regardless of choice count. No UIKit or RimeBridge production code changed.
- Local delta validation: focused path tests `41/41`; KeyboardCore `639/639`; RimeBridgeTests `28` passed + `4` fixture skips; main scheme `127/127`; Debug/Release strict generic-Simulator builds PASS.
- Refreshed independent review should inspect bounded synchronous latency, per-probe restoration, later-window ranking order, rejection of fallback-only branches, direct/cycle/Delete behavior, and the supplied long-input physical-device reproduction.

## Amendment D — Remaining Projection and Delete Delta

- `internalDigitIdentity(fromPreedit:)` recognizes digits separated only by spaces/apostrophes as internal raw. Partial Commit uses that suffix before falling back to comment letter-count peeling.
- T9 display fallback exposes only explicit ASCII letters; pure/mixed unresolved digits and digit-bearing comments cannot be written to host marked text. Partial Commit session-loss fallback retains the last safe remainder.
- Ordinary unconfirmed Delete exact-refines the visible pinyin minus its last letter and then reapplies that exact display. Partial checkpoints and explicit segmented selection bypass this path and keep their established rollback behavior.
- No UIKit/RimeBridge/schema/Vendor/deployment/persistence/logging change. Review the exact-refine failure restore, no-candidate output, session cleanup, and whether any other `updateInlinePreedit` path can publish T9 internal raw.
- Local delta evidence: focused T9/Partial/display matrix `90/90`; KeyboardCore `642/642`; RimeBridgeTests `28` passed + `4` fixture skips; main scheme `127/127`; Debug/Release strict generic-Simulator builds PASS.

## Amendment E/F/G review delta

- Confirmed segments now constrain both display and RIME session identity. Review `qiu'53` anchoring, exact raw comparison, usable-session guard, all-confirmed-prefix comment matching and whole-transition rollback.
- Complete-syllable discovery enumerates only a bounded probe set (maximum 6 digits / 48 probes), publishes only live-RIME-authorized comments, and restores anchored raw after each probe. It is not a second candidate engine.
- `T9PreeditResolver` caps ordinary comment display to one ASCII letter per explicit input slot. Review separator trimming, digit rejection and the explicit Path Bar display override.
- Final local evidence: T9 Path `46/46`, layout/runtime `14/14`, KeyboardCore `647/647`. Physical interaction and latency remain Product Gate, not Quality-owned evidence.
