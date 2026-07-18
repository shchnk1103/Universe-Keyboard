# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-001 Authorization

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001`  
**Lifecycle status:** Recorded  
**Date / timezone:** `2026-07-18 Asia/Shanghai`  
**Assignment:** [`docs/assignments/keyboard-layout-9key-pinyin-001.md`](../assignments/keyboard-layout-9key-pinyin-001.md)  
**Product plan (scope only, not authority):** [`docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`](../plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md)

## Authority

- **Product Approver / Decision maker:** 🧭 Product Lead (KOS 2.0 permanent role), exercising Product authority under the Human Product Owner’s explicit instruction to resolve the missing Product Decision / Assignment gate for this Work Item and to continue under Knowledge OS 2.0.
- **Assignment Authority exercised under:** Product Lead mechanics per `docs/ASSIGNMENT_POLICY.md` and `docs/kos/knowledge-os-2.0-specification.md`.
- **Named Executor:** Implementation agent **Grok** (bounded packages under Input Intelligence, RIME Platform, and Keyboard Experience).
- **Named Architecture / Quality Reviewer for gate review:** Codex (Architecture & Knowledge Steward + Quality, Performance & Release review handoff).
- **Domain Owner (task Assignment):** 🧠 Input Intelligence Maintainer.

This file is the stable, repository-verifiable Product Decision Source for `KEYBOARD-LAYOUT-9KEY-PINYIN-001`. Conversation history is not authority; this record is.

## Authorization wording

On `2026-07-18 Asia/Shanghai`, the Human Product Owner:

1. Required execution of [`docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md`](../plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md) under repository collaboration rules.
2. Required a Product Decision and complete Assignment check with **no fabricated authorization** and **no `UNKNOWN` fields** before implementation.
3. Subsequently instructed the active agent to **automatically switch to Product Lead** under KOS 2.0 design to unblock the missing governance artifacts and continue the authorized work package.

Under that instruction, Product Lead records this Decision and the linked Assignment so formal work may enter `Ready` without inventing owner-less authority.

## Product problem

Chinese nine-key chrome already exposes a **选拼音** control as a placeholder (`KEYBOARD-LAYOUT-9KEY-UI-001`, Closed). Users need a real “精准选拼音” path:

```text
[m] [n] [o]                    ← precise pinyin path bar
[吗] [你] [哦] [年] ... [展开]  ← existing Chinese candidate bar
[九宫格按键区域]
```

Without composition refinement, multi-key T9 digit sequences remain overly ambiguous relative to system 九宫格 expectations.

## Bound product decisions

### 1. Target behavior

1. In **中文 + letters page + effective nine-key runtime**, show a fixed-height **精准拼音路径栏** above the Chinese candidate bar.
2. Paths represent **full current nine-key sequences’ valid pinyin paths**, not only the last key’s letters.
3. Default compact bar shows at most **4** deduplicated paths in Rime ranking order.
4. **选拼音** opens a full path panel that loads more paths on demand.
5. Selecting a path **only narrows the current Rime composition** (via existing session `replaceInput` / equivalent). It **must never** commit letters or raw input to the host.
6. Chinese candidates remain owned by the existing `t9` schema, session, and ranking. **No second Chinese candidate engine.**

### 2. Path source and safety

1. Path text comes from **current Rime candidate comments**, not a parallel pinyin table that can drift from Rime configuration.
2. Invalid, empty, decorative, emoji, or composition-incompatible comments are discarded.
3. If comments are missing or unparseable: **safe degrade** to ordinary nine-key candidates; do not invent pinyin; do not commit raw input.
4. First version has **no user toggle**: enabled whenever Chinese nine-key runtime is usable.

### 3. Composition and mixed raw-input invariants

1. Precise selection is **composition refinement**, not candidate commit.
2. After refinement, Rime raw input may be pure digits, pure letters, or **letter/digit/separator mixed** forms (for example `ni4`).
3. While any valid T9 composition is active (`usesT9InputSemantics` and non-empty raw input consisting only of supported letters, digits, and pinyin separators):
   - Space/Return with candidates: commit highlighted/first candidate;
   - Space/Return without candidates: **keep composition**; never leak raw input to host;
   - language / auto-English switch: abandon composition; never leak raw input;
   - ordinary 26-key typo correction remains suppressed for T9 compositions.
4. Failed `replaceInput` must **roll back** to the previous composition, Chinese candidates, and host marked text.
5. raw input remains the sole recovery/delete source; never reverse-engineer composition from display preedit or path-bar text.

### 4. UI product constraints

1. Keyboard Extension uses UIKit; business state lives in KeyboardCore; UIKit only renders and forwards actions.
2. Nine-key preferred height grows by a fixed **34 pt** path-bar reservation; key geometry and four-row pad remain unchanged. Empty composition keeps the reserved height (no jump).
3. Visual style: plain text, transparent background, continuous hit targets; no candidate-pill chrome; optional 1px semantic separator above the Chinese candidate bar.
4. Compact paths need stable hit targets **≥ 44 pt** where layout allows (especially `m / n / o`).
5. Candidate expansion and pinyin-path expansion are **mutually exclusive**.
6. No main-App settings surface for V1 of this feature.

### 5. Non-goals (hard)

- librime / vendor upgrade
- Main-App RIME deployment boundary change; Extension-side deploy or schema mutation
- Changing 26-key QWERTY product behavior
- English nine-key / multi-tap letter pick / swipe-to-letter
- Live layout hot-switch while the keyboard remains visible
- Second Chinese candidate engine or offline pinyin graph parallel to Rime
- Full 颜表情 candidate content productization (remains a separate residual)
- User-facing feature toggle for V1

### 6. Architecture gate required before product UI

Before Keyboard Extension UI implementation (plan phases 5–6), Architecture must accept an **independent ADR** extending ADR 0018 that at least records:

- mixed raw-input forms are allowed under T9 composition refinement;
- precise path selection is composition refinement, not commit;
- Extension only mutates the current session;
- path provenance is candidate comments with fail-closed parsing.

### 7. Spike gate (hard stop)

Before product UI, Executor must produce transferable Spike evidence on the **pinned** librime / `t9` stack proving at least:

- digit input yields usable candidate comments for path extraction (for example `6` → `m/n/o` or documented actual comments);
- `replaceInput` letter refinement does not produce host `committedText` and leaves non-empty composition/candidates when expected;
- multi-key refine (for example `64` → `ni`) narrows candidates and subsequent digits may form mixed raw input;
- mixed-input Delete / Space / Return / language switch / recovery / paging invariants hold;
- raw input never leaks to host when candidates are empty.

**Stop Conditions that block UI and require Architecture return:**

- `set_input` / `replaceInput` rejects required mixed forms;
- candidate comments cannot stably express full pinyin paths;
- schema or vendor upgrade becomes mandatory for the product to work.

### 8. Lifecycle gates

| Gate | Authority | Condition |
|---|---|---|
| Assignment `Ready` | Product Lead | This Decision + complete Assignment with no `UNKNOWN` |
| `Active` phases 1–2 (ADR + Spike) | Product Lead (this Decision) | Entry Criteria of Assignment satisfied |
| `Active` phases 3–4 (KeyboardCore) | Product Lead after Spike package is archived and ADR is Accepted (or Architecture explicitly accepts Spike-backed draft ADR) | Spike PASS; no stop condition |
| `Active` phases 5–6 (UI) | Same as above | Phases 3–4 deliverables and tests green |
| Quality / Architecture review | Codex handoff | Independent conclusions |
| Product Gate / device acceptance | Product Lead + Human Dependency device capture | Physical-device matrix in plan §真机验收 |

### 9. Executor / reviewer / evidence

1. **Grok** executes the plan phases under the Assignment.
2. **Codex** performs Architecture and Quality gate review at Spike and implementation handoff points.
3. Do not commit, push, or open PRs unless the Human Product Owner separately authorizes publication.
4. Implementation must not invent Product, Architecture, or Quality acceptance.

## Stable references

| Reference | Path or identity |
|---|---|
| Decision ID | `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-001` |
| This record | `docs/product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md` |
| Assignment | `docs/assignments/keyboard-layout-9key-pinyin-001.md` |
| Active plan | `docs/plans/keyboard-layout-9key-pinyin-selection-implementation-plan.md` |
| Predecessor runtime | ADR 0018; Assignment `KEYBOARD-LAYOUT-9KEY-001` (`Closed`) |
| Predecessor chrome | Assignment `KEYBOARD-LAYOUT-9KEY-UI-001` (`Closed`; 选拼音 placeholder residual) |
| Domain chrome/runtime SoT | `docs/KEYBOARD_LAYOUT.md` |

## Change policy

Amendments require a new dated Product Decision revision or superseding Decision ID. Executors must not rewrite historical Product authorization text to match later implementation convenience.
