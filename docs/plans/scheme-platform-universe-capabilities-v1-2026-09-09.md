# Scheme Platform — `universe-capabilities/v1` (Human Finalized)

**Status:** **Human Finalized** (`2026-09-09 Asia/Shanghai`) — declarative package capability manifest format.  
**Nature:** Universe convention (app/package-declared capabilities), **not** a RIME built-in schema field. **Docs only** — not Swift; not ADR Accept; not Product Gate / TF; not push.  
**Carrier:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) (P0/P1 seams consume; Discovery UI later).  
**Discovery UX consumer:** [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md) (Section A “package capability manifest”).  
**P0 seams:** [`scheme-platform-p0-interfaces-2026-09-09.md`](scheme-platform-p0-interfaces-2026-09-09.md) §2 Layout / §3 ResourceOwnership / §4 SharedDefault / §5 Manifest.

---

## 1. Placement

| Rule | Decision |
|---|---|
| **Filename** | `universe-capabilities.yaml` |
| **Location** | Scheme **package root** (alongside schemas / plan-owned files) |
| **Install** | Installed into the scheme’s **shared** directory with the package (same shared root peers use) |
| **Authority class** | Package capability manifest (Universe convention) — sits below **user override**, above **catalog adapter** |

Catalog schemes may **generate equivalent** capability data via adapters (no on-disk file required for catalog-owned Ice/Wanxiang). Community / imported packages **ship the file** or obtain it through an **import wizard**.

---

## 2. Format identity

```yaml
format: universe-capabilities/v1
schema_id: rime_ice   # primary scheme identity this manifest describes
```

| Field | Required | Notes |
|---|---|---|
| `format` | **yes** | Must be exactly `universe-capabilities/v1` for this revision |
| `schema_id` | **yes** | Primary RIME schema id the package claims |

Unknown **layout** keys under `layouts:`: **ignore** for forward compatibility (e.g. future `twelveKey`). This v1 record grants that ignore rule specifically to layout keys; producers must not assume the same treatment for unknown fields elsewhere.

---

## 3. Full schema (`universe-capabilities/v1`)

```yaml
format: universe-capabilities/v1
schema_id: <string>                    # required

layouts:
  twentySixKey:                        # optional layout block
    supported: <bool>                  # required if block present
    schemaIDs: [<string>, ...]         # required if block present; schema ids usable on this layout
    primary: <string>                  # required when supported=true; omit when false
    dependencies: [<string>, ...]      # required if block present; installed/ready prerequisites
  nineKey:
    supported: <bool>
    schemaIDs: [<string>, ...]
    primary: <string>                  # required when supported=true; omit when false
    dependencies: [<string>, ...]
  # <futureLayoutKey>: ignored by v1 parsers (forward compat)

resources:
  lua:
    strategy: named-list | exact-hash | none   # required if lua block present
    paths: [<string>, ...]                     # optional; named-list paths and/or exact-hash path keys
    # exact-hash pin map may live in adapter / pin table; paths here name owned relatives
  opencc:
    admitted: <bool>                           # required if opencc block present
    namedFiles: [<string>, ...]                # optional; admitted named OpenCC files when admitted=true

sharedDefault:
  mode: private-preset | consume-prelude       # required if sharedDefault present
  presetFile: <string>                         # required when mode == private-preset
```

### 3.1 `layouts.*`

| Subfield | Meaning |
|---|---|
| `supported` | Product capability claim for that layout (`true`/`false`) |
| `schemaIDs` | Required list of schema ids the package exposes; must be non-empty when supported, empty when unsupported |
| `primary` | Required when supported; preferred id and a member of `schemaIDs`. Omit when unsupported |
| `dependencies` | Required list of other scheme ids that must be installed/ready for readiness; may be empty |

Absent layout block ⇒ treat as **unsupported** for that layout unless a higher-priority authority (user override) or lower-priority catalog adapter says otherwise (see §5).

### 3.2 `resources.lua.strategy`

| Value | Meaning |
|---|---|
| `named-list` | Ice reference — owned lua via explicit named paths (plan removable / named list) |
| `exact-hash` | Wanxiang reference — owned lua via exact content-hash match |
| `none` | No lua ownership claim via this manifest |

Optional `paths` lists relative owned files (named-list members and/or exact-hash path keys). For `exact-hash`, the pinned digest inventory remains in the ownership adapter / catalog pin data; this manifest declares the strategy and optional path keys, not hashes. Whole-directory wipe of `lua/` remains **forbidden** regardless of strategy.

### 3.3 `resources.opencc`

| Subfield | Meaning |
|---|---|
| `admitted` | Whether this package admits OpenCC files under ownership rules |
| `namedFiles` | Optional named OpenCC files when `admitted: true` |

`admitted: false` is valid (Wanxiang may keep this). Whole-directory wipe of `opencc/` remains **forbidden**.

### 3.4 `sharedDefault`

| `mode` | Meaning |
|---|---|
| `private-preset` | Ice-shaped end-state — private preset file + include/import rewrite; **never** overwrite Prelude `default.yaml` |
| `consume-prelude` | Transitional — skip/`consumePrelude`-shaped; **not** third-party end-state (Wanxiang P1 bridge; P2 migrates to `private-preset`) |

When `mode: private-preset`, **`presetFile` is required** (e.g. `rime_ice_preset.yaml`).

---

## 4. Validation (fail-closed)

| Rule | Decision |
|---|---|
| Any **validation failure** | **Void the entire manifest** — **no partial apply** |
| Partial / best-effort field salvage | **Forbidden** |
| Effect when voided | Fall through to next priority authority (§5) as if the file were absent |

Examples of validation failure (non-exhaustive):

- Missing / wrong `format`
- Missing `schema_id`
- `layouts.<known>.supported` present but not a bool, missing required layout fields, or inconsistent `supported` / `schemaIDs` / `primary` values
- `resources.lua.strategy` not in `named-list|exact-hash|none`
- `sharedDefault.mode: private-preset` without `presetFile`
- `sharedDefault.mode` not in `private-preset|consume-prelude`
- YAML parse error / non-object root

Unknown layout keys are **not** validation failures; v1 ignores them. No general ignore rule is finalized for unknown fields outside `layouts`.

---

## 5. Priority / authority order

Highest first:

1. **User override** (explicit user choice / prior confirmed binding / user marking)
2. **Package capability manifest** — this file (`universe-capabilities/v1`), if present **and** valid
3. **Catalog adapter declaration** (catalog schemes may generate equivalent without shipping the file)
4. **Default unsupported** (no claim)

Used by Discovery Section A eligibility, uninstall layout-fallback rebind candidate selection, and P1 capability **query** seams.

**Filename / `schema_id` string heuristics are not manifest fields** and are **not** an authority here — they live in App **Section B only** (try / unverified). See discovery-layout-ux.

---

## 6. Non-fields (explicit)

Do **not** put these in `universe-capabilities.yaml`:

- Filename / `schema_id` layout hints (Section B App UX only)
- User override bindings
- Catalog pin digests / staged identity (remain in catalog / plan)
- Whole-dir ownership claims for `lua/` or `opencc/`

---

## 7. Examples

### 7.1 Ice-like — `private-preset` + named-list + nine-key

Illustrative shape aligned with Ice reference (catalog may generate equivalent via adapter; community may ship this file):

```yaml
format: universe-capabilities/v1
schema_id: rime_ice

layouts:
  twentySixKey:
    supported: true
    schemaIDs: [rime_ice, melt_eng, radical_pinyin]
    primary: rime_ice
    dependencies: []
  nineKey:
    supported: true
    schemaIDs: [t9]
    primary: t9
    dependencies: [rime_ice]

resources:
  lua:
    strategy: named-list
    paths:
      - lua/date_translator.lua
      - lua/corrector.lua
      - lua/t9_preedit.lua
      # … additional Ice named lua paths / lua/cold_word_drop via plan
  opencc:
    admitted: true
    namedFiles:
      - opencc/emoji.json
      - opencc/emoji.txt
      - opencc/others.txt

sharedDefault:
  mode: private-preset
  presetFile: rime_ice_preset.yaml
```

### 7.2 Wanxiang transitional — `consume-prelude` + exact-hash + nine-key false

Illustrative **P1 transitional** shape (product nine-key remains false; P2 SharedDefault migrates to `private-preset`):

```yaml
format: universe-capabilities/v1
schema_id: wanxiang

layouts:
  twentySixKey:
    supported: true
    schemaIDs: [wanxiang]
    primary: wanxiang
    dependencies: []
  nineKey:
    supported: false
    schemaIDs: []
    dependencies: []
    # wanxiang_t9* may exist in plan ownership; product capability stays false until later Assignment

resources:
  lua:
    strategy: exact-hash
    paths:
      # path keys matched via WanxiangLuaOwnership / pin table (exact content hash)
      - lua/data/chaifen.txt
      - lua/wanxiang/bit.lua
      - lua/wanxiang/wanxiang.lua
  opencc:
    admitted: false

sharedDefault:
  mode: consume-prelude
  # no presetFile — required only for private-preset
```

Notes:

- `nineKey.supported: false` matches Human deferral of Wanxiang nine-key productization.
- `consume-prelude` is **not** Wanxiang end-state; P2 → `private-preset` (+ `presetFile`).
- `opencc.admitted: false` is valid under the same ResourceOwnership API.
- `lua.strategy: exact-hash` stays long-term (Ownership dual; contrast SharedDefault consolidation).

### 7.3 Minimal community package (26-key only, no lua/opencc claims)

```yaml
format: universe-capabilities/v1
schema_id: example_community

layouts:
  twentySixKey:
    supported: true
    schemaIDs: [example_community]
    primary: example_community
    dependencies: []

resources:
  lua:
    strategy: none
  opencc:
    admitted: false

sharedDefault:
  mode: private-preset
  presetFile: example_community_preset.yaml
```

---

## 8. Relationship to catalog adapters

| Source | How capabilities are supplied |
|---|---|
| **Catalog schemes** (Ice, Wanxiang, …) | May **generate equivalent** via registered adapters / plan (file optional) |
| **Community / import** | Ship `universe-capabilities.yaml` **or** produce it via **import wizard** |
| **Validation** | Same fail-closed rules whether file-backed or adapter-generated equivalent is materialised for query |

P1 extracts Ice/Wanxiang into seams; on-disk community file + wizard are Discovery / import surfaces (later Assignment may own wizard UX).

---

## 9. Non-goals (this record)

- Swift parser / P1 coding without separate auth
- Shipping the file inside Ice/Wanxiang catalog packages on day one (adapters may generate equivalent)
- Enabling Wanxiang nine-key productization
- Putting filename heuristics into the manifest
- Partial apply on validation failure
- ADR Accept / Product Gate / TF / push

---

## 10. History

- `2026-09-09 Asia/Shanghai`: Human finalized `universe-capabilities/v1` — file at package root installed into shared dir; fields for layouts / lua strategy / opencc / sharedDefault; validation failure voids entire manifest; priority user override > manifest > catalog adapter > default unsupported; filename heuristics App Section B only; catalog may generate via adapters; community ships file or import wizard. Local docs + commit only; no push.
