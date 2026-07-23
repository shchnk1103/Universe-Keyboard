# ADR 0023: T9 Complete Local Path Catalog And Atomic Presentation

- **Status:** Accepted for implementation under `KEYBOARD-LAYOUT-9KEY-PINYIN-004` (device Product Gate pending)
- **Date:** 2026-07-22
- **Decision owners:** 🏛️ Architecture & Knowledge Steward
- **Product authority:** [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-004-authorization.md)
- **Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../../assignments/keyboard-layout-9key-pinyin-004.md)
- **Extends / supersedes path-source constraints in:** ADR 0020, ADR 0021, ADR 0022

## Context

ADR 0022 fixed foreground cost by using one read-only candidate window and banned static pronunciation sources for `003`. Human Product Gate still failed: Path completeness depends on whether RIME comments happen to expose a spelling in the foreground window. Sequences such as `28 → bu/cu/a/b/c` and `94 → xi/yi/zi` cannot be guaranteed from sparse comments alone. Prefix selection (`b` on `28`) is not a first-class product type.

Product Decision `004` therefore authorizes a compile-time local syllable catalog as Path legality authority while RIME remains the sole Chinese candidate engine.

## Decision Boundary

This ADR may introduce a versioned local syllable index generated from in-repo `luna_pinyin.dict.yaml`, redefine Path kinds, and keep the coherent composition-revision / host-preedit safety model from ADR 0022. It does not authorize a second Chinese ranking engine, Extension-side YAML parsing on the hot path, schema/vendor change, or 26-key behavior change.

## Decision

### 1. Compile-time local catalog

- Generator extracts unique lowercase ASCII syllable tokens from `Keyboard/Resources/luna_pinyin.dict.yaml`.
- Tokens are de-duplicated, sorted, mapped to T9 digit signatures, and emitted as Swift source.
- Provenance recorded in generated source: relative path, `luna_pinyin` version, SHA-256, syllable count, generator version.
- Baseline: **417** unique **legal** syllables after filtering non-pinyin placeholders such as `xx` (418 raw unique ASCII tokens). See [`t9-pinyin-syllable-catalog.md`](../t9-pinyin-syllable-catalog.md). Regenerating with a different count is a deliberate change requiring test/ADR review, not a silent drift.
- Runtime form: `[digitSignature: ordered syllables]`. Focus queries use 1…min(6, remainingDigitCount) signatures only. No whole-sentence cartesian product.

### 2. Path kinds and ranking

Each Path carries:

- stable ID
- `kind`: `completeSyllable` | `letterPrefix`
- `consumedSlotCount`
- `displayText`
- full `replacementRawInput` owned by Core
- composition revision and focus slot range

Ranking for the current focus:

1. Complete syllables that consume more input slots first
2. Same length: syllables appearing in current RIME comments (first-seen order) first
3. Remaining complete syllables in catalog order
4. Then current key-group letter prefixes
5. De-dupe by display text; complete syllable wins over same-named prefix

Example: focus `28` → `bu / cu / a / b / c`.

### 3. Selection semantics

- **Complete syllable:** replace focus slots, keep uninvolved suffix digits, optional apostrophe boundary (`qiu'53`), confirm syllable, advance focus when remaining slots exist, one `replaceInput` max.
- **Letter prefix:** e.g. `28` + `b` → `b8`, keep focus, lock prefix, recompute compatible complete paths + the prefix item, one `replaceInput` max. Does not confirm a syllable.
- Path logic must not call `candidateWindow` or per-spelling probes. Ordinary digit: Path RIME call count extra = 0 beyond the single `processKey`.

### 4. Atomic presentation (retained from ADR 0022)

KeyboardCore publishes one coherent composition revision for raw identity, safe host preedit, candidates, full Path array, provisional path, selected path, and segmented provenance. UIKit never synthesizes replacement raw or repairs revisions.

### 5. Host-visible preedit (retained and tightened)

All composition-projection marked-text writes reject ASCII digits. Provisional first Path may drive display when it fully covers the current focus slots; otherwise slot-capped comment projection remains valid for progressive prediction (`8/86/868`). Raw input is never a host fallback.

### 6. Path Bar UI

Fixed 34pt single-row horizontal collection shows **all** current-focus Paths (no `prefix(5)` truncation). Cell reuse, stable IDs, ≥44pt hit targets, VoiceOver kind/selected state. Candidate paging must not reset Path scroll within the same revision. Expanded Path panel discovery against candidate windows is retired as a Path-completeness mechanism.

## Supersession note

ADR 0022 §Decision Boundary statement that this work “does not authorize a static pronunciation source” is **superseded for Path legality only** by this ADR under PD-004. ADR 0022’s fixed foreground budget, atomic revision, rollback, and host-preedit provenance remain in force. ADR 0021’s “multi-digit Path must come only from live RIME comments” is superseded for authorization; comments remain ranking hints.

## License / source

`luna_pinyin.dict.yaml` is already shipped in this repository as RIME dictionary data. Upstream `rime-luna-pinyin` is LGPL-3.0. Provenance, filter policy, generator path (`scripts/…`), and attribution requirements are recorded in [`t9-pinyin-syllable-catalog.md`](../t9-pinyin-syllable-catalog.md). The generator records hash and version; it does not download network resources.

## Consequences

- Path completeness becomes independent of candidate-window sparsity.
- Catalog regeneration is a reviewable code change.
- Tests must pin catalog metadata and key signatures (`28`, `94`, single-key groups).
- Device Product Gate remains mandatory; automation cannot close 004.
