# Product Decision: KEYBOARD-LAYOUT-9KEY-PINYIN-003 Authorization

**Decision ID:** `PD-KEYBOARD-LAYOUT-9KEY-PINYIN-003`  
**Lifecycle status:** `Recorded`  
**Date / timezone:** `2026-07-22 Asia/Shanghai`  
**Assignment:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-003`](../assignments/keyboard-layout-9key-pinyin-003.md)  
**Predecessor:** [`KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../assignments/keyboard-layout-9key-pinyin-002.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner, through the explicit `2026-07-22 Asia/Shanghai` instruction to execute the remediation under KOS 2.0 with role separation and targeted testing.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 🧠 Input Intelligence Maintainer.
- **Executor:** Codex, limited to the linked Assignment Scope and phase gates.
- **Architecture and Quality authority:** remain separate from Product and implementation conclusions.

## Product Problem

The merged `002` implementation did not pass its physical-device Product Gate:

1. Long T9 input can block visibly when a Path Bar choice triggers repeated live-RIME discovery.
2. Candidate selection can publish a new remaining composition while Path Bar still displays choices from the preceding focus.
3. Internal digit identity can still appear transiently or persistently in host marked text through recovery, rollback or partial-state branches.

The `002` automated evidence is historical implementation evidence only. It is not acceptance evidence for these failed device behaviors.

## Bound Product Decisions

### 1. One user action, one coherent presentation revision

1. Marked text, Chinese candidates and Path Bar choices published for a T9 action must belong to the same composition revision.
2. Candidate selection immediately invalidates the preceding Path Bar revision. Stale choices must never remain visible while a newer remaining composition is active.
3. A delayed discovery result may publish only when its raw identity and revision still match the active composition.
4. UIKit renders Core-owned state and forwards actions. It does not repair, merge or infer Path Bar business state.

### 2. Path interaction has fixed foreground cost

1. A direct Path Bar tap must not execute a foreground loop whose bridge work scales with the number of candidate spellings or the existing 48-probe ceiling.
2. The first architecture Spike must preserve live-RIME authorization and compare a batched/read-only discovery transaction against the existing repeated `replaceInput -> candidateWindow -> restore` flow.
3. The synchronous foreground transaction must have a structurally fixed bridge-call bound independent of input length and spelling-enumeration count.
4. If live-RIME authorization cannot meet the reviewed device performance requirement without a static pronunciation source, second engine or unsafe session mutation, implementation stops and returns to Product Lead. This Decision does not pre-authorize those alternatives.

### 3. Host-visible T9 text is source-safe

1. Internal T9 digits remain raw identity only and must never enter host marked text, including mixed or separator-bearing forms.
2. A host-visible preedit value carries explicit provenance: projected T9 pinyin, explicit Path Bar spelling, confirmed Chinese plus safe remainder, or user-entered numeric text.
3. User-entered numeric text from the number page remains valid. Digit safety must distinguish explicit numeric input from internal T9 identity rather than stripping every digit globally.
4. Every host marked-text write uses the single validated boundary. Invalid internal-digit output fails closed to the last safe display or an empty composition.

### 4. Existing accepted behavior remains binding

1. `8 -> t`, `86 -> to`, `868 -> tou` remains the ordinary T9 display contract.
2. `tou -> to -> t -> empty` and anchored unresolved-tail Delete `qiule -> qiul` remain unchanged.
3. Path selection changes only the consumed spelling slots and preserves unresolved visible suffixes.
4. RIME continues to own Chinese candidates and ranking. The Extension remains session-only and performs no deployment, network or synchronous persistence work.

## Non-goals

- Replacing RIME candidate ranking or adding a second Chinese candidate engine
- Authorizing an offline pinyin graph before the Spike Stop Condition is reached and Product revalidates it
- Changing 26-key behavior, keyboard chrome, settings or RIME deployment
- Reworking unrelated number-suffix, typo-correction or continuation features
- Treating simulator/unit tests as physical-device performance or Product Gate evidence
- Running unrelated full test suites for this bounded implementation

## Product Acceptance

1. `deizhaoyishengwenyixia -> dei`: Path tap publishes coherent marked text, candidates and next paths without the existing multi-probe foreground stall.
2. `qingweifandaowozuili -> qing -> wei -> fan -> dao -> 请喂饭到`: the old `dao` focus disappears in the same action; remaining paths correspond to `wo`, then support `zui / li` progression.
3. Internal T9 digits never appear in the host during key input, path selection, candidate selection, Delete, checkpoint restore, rollback, fallback or session recovery.
4. Explicit number-page input still displays user-entered digits normally.
5. Targeted automated tests and current-build physical-device evidence are separate gates. Human Product Owner retains final Product Gate authority.

## Change Policy

This Decision supersedes only the failed performance/state-publication/safe-display implementation strategy of `002`. It does not rewrite `002` history. Material changes to multi-key choice source, RIME ownership, Delete semantics or App/Extension boundaries require Product and ADR revalidation.
