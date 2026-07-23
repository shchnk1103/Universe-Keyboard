# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-004 Authorization

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-004`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-22 Asia/Shanghai`  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-004`](../assignments/keyboard-layout-9key-pinyin-004.md)  
**Predecessor:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-003`](../assignments/keyboard-layout-9key-pinyin-003.md)  
**Implementation plan:** [`plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md`](../plans/keyboard-layout-9key-pinyin-004-complete-path-catalog-and-atomic-sync-plan.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner, through the explicit instruction to execute the 004 plan under KOS 2.0 with Grok 4.5 as Executor.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 🧠 Input Intelligence Maintainer.
- **Executor:** Grok 4.5, limited to the linked Assignment Scope and phase gates.
- **Architecture and Quality authority:** remain separate from Product and implementation conclusions.

## Product Problem

Human Product Gate for `003` failed: Path completeness still depends on sparse RIME comments / fixed candidate windows, so multi-digit foci such as `28` and `94` omit valid syllables; prefix vs complete-syllable selection is not product-clear; Path Bar remains truncated to five items; Delete / Partial Commit recovery can still drop the Path Bar. Automated pass for `003` is historical evidence only and does not accept the product.

## Bound Product Decisions

### 1. Local complete Path catalog is the Path authority

1. Path legality for the current focus comes from a versioned local syllable catalog generated from the in-repo `luna_pinyin.dict.yaml`.
2. RIME comments may only reorder Path display; they do not authorize or deny a Path.
3. Ordinary digit keys still send one digit to RIME. Core never enumerates letter combinations as RIME probes to build Path.

### 2. Complete syllable vs letter prefix

1. Path items are either `completeSyllable` or `letterPrefix`.
2. Selecting a complete syllable confirms that syllable, advances focus when remaining slots exist, and may use an apostrophe boundary (e.g. `qiu'53`).
3. Selecting a letter prefix locks only that prefix (e.g. `28` → `b` becomes raw `b8`), keeps the same focus, and refreshes Path / candidates / marked text without confirming a syllable.
4. Same display text de-duplicates with complete syllable winning over prefix (`a` is complete, not a redundant prefix).

### 3. Atomic composition presentation

1. Raw input, safe marked text, full Path set, provisional/selected Path, and candidates publish from one Core revision.
2. UIKit reads one snapshot per refresh; stale revision clicks and delayed results are discarded.
3. While a valid T9 composition remains, Path Bar must not disappear solely because comments are empty, candidates are sparse, Delete restored a suffix, or Partial Commit advanced focus.

### 4. Host-visible text safety

1. Internal digit identity never enters host marked text.
2. Unselected input may use the provisional first Path for display when it fully covers the current focus slots; otherwise slot-capped comment projection remains valid for progressive prediction such as `8 → t`, `86 → to`, `868 → tou`.
3. Explicit Path selection covers only its slot range; unresolved safe suffixes are preserved.

### 5. 26-key freeze

26-key behavior remains letter-direct RIME, with no T9 catalog load requirement, Path generation, or marked-text policy change.

## Non-goals

- Second Chinese candidate engine or replacing RIME ranking
- Changing keyboard chrome beyond Path Bar presentation needed for full Path access
- Schema / vendor / deployment changes
- Full unrelated test suites, push, PR, or Product Gate claims from automation alone

## Product Acceptance

Human Product Owner on iPhone 13 Pro (Notes) remains the Product Gate. Minimum sequences are listed in the Assignment and plan. Automated tests are necessary but not sufficient.

## Change Policy

This Decision supersedes `003` Path-source and Path-completeness strategy after Human Product Gate failure. `003` history is retained as failed-gate evidence, not rewritten as pass. Material catalog source / license changes require Product and Architecture revalidation.
