# ADR 0026: Layout-Bound RIME Scheme Selection (Amends ADR 0018)

- **Status:** **Proposed draft** (`2026-08-07 Asia/Shanghai`) — **not Accepted**  
  Product requirement frozen under
  [`PD-RIME-SCHEME-WANXIANG-001`](../../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md)
  (layout-page scheme choice; 万象全拼 V1). Independent Architecture Accept +
  Quality path required before production code lands.
- **Date:** 2026-08-07
- **Decision owner:** 🏛️ Architecture & Knowledge Steward (pending formal review)
- **Product authority:** [`PD-RIME-SCHEME-WANXIANG-001`](../../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md)
  freeze addendum (2026-08-07); Assignment
  [`RIME-SCHEME-WANXIANG-001`](../../assignments/rime-scheme-wanxiang-001.md)
- **Amends:** [`ADR 0018`](0018-keyboard-layout-nine-key-and-t9-runtime.md)
  §2 base-vs-effective scheme, §4 enable/disable ordering (migration only),
  and the pure resolver contract realized today by `RimeRuntimeSelection`
- **Does not supersede:** ADR 0001 deploy ownership; ADR 0004 session model;
  ADR 0018 T9 input semantics (digit raw, no raw-digit host commit, Path stack
  ADR 0020–0023); dual-gate ADR 0025

## Context

### What ADR 0018 decided (still true unless amended below)

| Piece | ADR 0018 rule |
|---|---|
| Layout preference | `KeyboardLayoutStyle` `twentySixKey` \| `nineKey` in App Group |
| User-visible “current scheme” | Single `rime_active_schema` (base); **do not** store `t9` as the only user-facing row |
| Effective runtime | Pure resolver: if base is `rime_ice` **and** layout is nine-key **and** T9 readiness matched → effective schema `t9` + T9 semantics; else effective = base + 26-key |
| T9 readiness | Main-App versioned marker + fingerprint; Extension read-only |
| Deploy | Main App only |

Today’s code matches that table (`RimeRuntimeSelection`: `supportsNineKey = baseSchemaID == "rime_ice"` then force `t9`).

### Why amend

Product freezes (2026-08-07):

1. Users must pick **which RIME scheme a layout uses** on the **keyboard layout** settings surface (26 键 and 九宫格 each have a scheme slot).  
2. Nine-key must **not** be permanently hard-wired to “only when global base is fog-song.”  
3. First new downloadable scheme is **万象拼音（全拼）**; large packages acceptable in principle.  
4. Apple-like single-key mixed candidates remain **Won’t do**.

A single global base + automatic `rime_ice`→`t9` rewrite cannot express:

- 26 键 = 万象全拼, 九宫格 = 雾凇 `t9`  
- 26 键 = 雾凇, 九宫格 = （将来）其它九键能力方案  
- User overrides without changing a single global “当前方案” row in confusing ways  

## Decision (proposed)

### 1. Two Chinese layout slots (product surface)

Persist **layout preference** (which Chinese chrome is active) and **per-layout scheme binding**:

| Slot | Meaning |
|---|---|
| Active Chinese layout | `twentySixKey` or `nineKey` (unchanged key) |
| Scheme for 26-key | Installed schema ID capable of 26-key letter input (e.g. `luna_pinyin`, `rime_ice`, `wanxiang…`) |
| Scheme for nine-key | Installed schema ID **declared nine-key capable** (e.g. compatible `t9`) |

English / symbol / emoji surfaces remain **out of** these two Chinese scheme slots (ADR 0018 English path unchanged unless a later PD).

**User-facing copy:** layout page shows “此布局使用的输入方案”, not internal IDs.

### 2. Capability registry (catalog, not hard-coded forever)

Each catalog / built-in scheme entry must expose at least:

| Flag | Meaning |
|---|---|
| `supportsTwentySixKey` | May appear in 26-key scheme picker |
| `supportsNineKey` | May appear in nine-key scheme picker |
| `nineKeySchemaID` | Optional: schema ID to **select** when this binding is chosen for nine-key (e.g. binding product “雾凇九键” → select `t9`, while catalog row may still be labeled under fog-song family) |
| `usesT9InputSemantics` | When effective, Core enables T9 Path / digit policies (ADR 0020–0023) |

Rules:

- Picker **filters** by flag; never offer a 26-only scheme on nine-key.  
- If nine-key binding points at a missing/unready schema → **fail closed** to 26-key effective layout (keep typable).  
- Fog-song family: keep **install/deploy/readiness** for compatible `t9` artifacts as today (fingerprint contract).  
- 万象 V1 全拼: expect `supportsTwentySixKey=true`, `supportsNineKey=false` until a later PD/schema says otherwise.

### 3. Effective runtime resolution (replaces ADR 0018 §2 table)

**Inputs (proposed):**

- `activeLayout` ∈ {26, 9}  
- `schemeBinding26` — schema identity for 26-key slot  
- `schemeBinding9` — schema identity for nine-key slot (may be a logical “fog nine-key” that maps to `t9`)  
- Install + readiness predicates for the chosen binding  
- On-disk fingerprints where required (T9 compatibility)

**Outputs (unchanged shape where possible):**

- `effectiveSchemaID` — argument to `selectSchema`  
- `effectiveLayoutStyle` — chrome  
- `usesT9InputSemantics` — Core policy  

**Algorithm (normative intent):**

```text
if activeLayout == nineKey:
  candidate = resolveNineKeyBinding(schemeBinding9)
  if candidate.installed && candidate.ready && candidate.supportsNineKey:
    effectiveSchemaID = candidate.nineKeySchemaID   // e.g. t9
    effectiveLayoutStyle = nineKey
    usesT9InputSemantics = candidate.usesT9InputSemantics
  else:
    // fail closed
    effectiveSchemaID = resolve26(schemeBinding26) or luna_pinyin
    effectiveLayoutStyle = twentySixKey
    usesT9InputSemantics = false
else:
  effectiveSchemaID = resolve26(schemeBinding26) or luna_pinyin
  effectiveLayoutStyle = twentySixKey
  usesT9InputSemantics = false
```

`reconciled(withActualSchemaID:)` remains: if engine did not select the requested schema, fail closed chrome/semantics (same spirit as today).

### 4. Migration from ADR 0018 single-base model

When per-layout bindings are **absent** (first launch after upgrade):

| Legacy state | Migration default |
|---|---|
| `rime_active_schema=S`, layout 26 | `schemeBinding26=S`, `schemeBinding9=fogNineKeyIfReady` (logical t9) |
| `rime_active_schema=rime_ice`, layout 9, T9 ready | keep layout 9; `schemeBinding9=t9 path`; `schemeBinding26=rime_ice` |
| `rime_active_schema≠rime_ice`, layout stale 9 | force effective 26; fix preference on next main-App reconcile (unchanged safety) |
| No schema | `luna_pinyin` / built-in defaults |

**Optional:** keep `rime_active_schema` as a **legacy alias** of “last selected 26-key scheme” or “last scheme detail page set-current” for one release, then document deprecation. Exact alias rules are an implementation detail for Architecture Accept.

### 5. Settings UI ownership

| Surface | Owns |
|---|---|
| Scheme list / detail (existing) | Install, uninstall, license, deploy, “可用于哪些布局” status |
| **Keyboard layout page** | Active Chinese layout + **scheme picker per layout** |
| Main Settings advanced input | Still global preference × **active effective scheme** capability (no change to ADR direction) |

Switching layout in the keyboard chrome (if any) must re-read bindings and may `selectSchema` only through existing session lifecycle (no Extension deploy).

### 6. What stays from ADR 0018 (non-negotiable)

- Main App owns deploy/readiness writes; Extension never full-deploys.  
- Compatible `t9` patch (no unsupported `t9_processor`) for fog nine-key.  
- T9 digit raw / preedit / no raw-digit host commit / Path policies when `usesT9InputSemantics`.  
- Enable nine-key **resources** still requires install → deploy → smoke → readiness **before** a nine-key binding can be **ready** (order may bind layout preference earlier only if fail-closed resolver prevents effective nine-key without readiness).

### 7. 万象拼音 interaction

- V1: catalog entry **全拼**, 26-key picker only.  
- Selecting 万象 on 26-key must not clear nine-key fog binding.  
- Selecting nine-key layout must select the **nine-key slot scheme** (typically `t9`), not silently force 万象.  
- Cross-schema userdb sharing remains forbidden (existing user-dictionary boundary).

### 8. Implementation sketch (non-binding order)

1. Extend App Group keys for `schemeBinding26` / `schemeBinding9` (names TBD).  
2. Extend catalog metadata with capability flags.  
3. Rewrite `RimeRuntimeSelection` pure resolve to layout-bound inputs; keep pure + unit-tested.  
4. Layout settings UI pickers.  
5. Migration on main-App launch.  
6. 万象 catalog/install slice (full pinyin).  
7. Expand tests: matrix layout × binding × readiness × actual schema reconcile.

## Alternatives considered

| Alternative | Why not (proposed) |
|---|---|
| Keep ADR 0018 only; 万象 as second global base | Cannot express 26=万象 & 9=t9; Product rejected |
| Store `t9` as global `rime_active_schema` when on nine-key | Conflates layout and scheme management (ADR 0018 rejection still holds for **global** row) |
| UI-only layout without per-layout schema ID | Breaks multi-scheme |
| Allow any schema on nine-key without capability flags | Wrong algebra / empty or toxic candidates |

## Consequences

### Positive

- Matches Product: layout page owns scheme choice.  
- 万象 and future schemes plug into catalog + picker without rewriting T9 Path stack.  
- Fail closed preserves typability.

### Costs / risks

- Migration bugs if bindings corrupt → must fail closed to 26-key.  
- More settings complexity; copy must stay plain-language.  
- `RimeRuntimeSelection` and all call sites (Extension bootstrap, diagnostics, force_gc tools) need coordinated update.  
- Architecture Accept required before coding.

### Explicit non-claims

- This draft does **not** authorize production code.  
- Does **not** ship 万象 assets.  
- Does **not** define 万象 double-pinyin.  
- Does **not** revive mixed first-key candidates.

## Acceptance checklist (for later Architecture Accept)

- [ ] Product reconfirm migration defaults  
- [ ] Pure resolver tests for all matrix cells in §3–§4  
- [ ] Catalog capability flags design reviewed  
- [ ] No Extension deploy regression  
- [ ] Docs: KEYBOARD_LAYOUT, RIME_SCHEME_MANAGEMENT, PROJECT_CONTEXT cross-links  
- [ ] Assignment RIME-SCHEME-WANXIANG-001 Entry can clear Architecture UNKNOWN  

## History

- 2026-08-07: Draft opened from Product freezes (全拼 V1, size, layout-bound picker).
