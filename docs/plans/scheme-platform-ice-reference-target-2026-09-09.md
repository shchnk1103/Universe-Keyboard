# Scheme Platform — Ice-as-reference target (Human Approved)

**Status:** **Human Approved** target (`2026-09-09 Asia/Shanghai`).  
**Nature:** Product / Architecture north-star for third-party scheme delivery. **Docs only** in this slice — not implementation, not ADR Accept, not Product Gate / TestFlight.  
**Assignment carrier (Active):** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md)  
**Related Paused:** [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md) (shelved for Scheme Platform; A34-R1 still open — NOT Closed/Done)

---

## History

| When | What |
|---|---|
| `2026-09-09 Asia/Shanghai` | Human approved **Ice-as-reference Scheme Platform** as the north-star target. Authorized local docs (this file + Ready Assignment + ACTIVE_WORK / Wanxiang P4 status note). **No** push; **no** ADR Accept; **no** Swift in this authorization. |
| `2026-09-09 Asia/Shanghai` | Human Gate 0: Assignment **Active**; Wanxiang P4 **Paused** (shelved); branch `codex/scheme-platform-001` from `origin/main` @ `814abfd`; ask-before-first-push/PR; no ADR Accept / Product Gate / TF / Swift this slice. |
| `2026-09-09 Asia/Shanghai` | P0 interfaces + matrix landed ([interfaces](scheme-platform-p0-interfaces-2026-09-09.md), [matrix](../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md)); local commit only; no push; no ADR Accept. |
| `2026-09-09 Asia/Shanghai` | Human deferred Wanxiang nine-key productization to later Assignment (not yet drafted); Scheme Platform P1/P2 must not enable; Ice `t9` remains reference shape. |
| `2026-09-09 Asia/Shanghai` | Human approved **P1↔Discovery split**: P1 = LayoutCapability + ResourceCapability/ownership seams (adapter lookup; Ice-only nine-key; Wanxiang `supportsNineKey=false`; strategy APIs). Installed Capability Discovery / layout-picker = later Assignment (not yet drafted; separate Human Active). Wanxiang nine-key productization remains deferred (may ride Discovery later or stay further deferred). |
| `2026-09-09 Asia/Shanghai` | Human approved **Discovery layout-page A/B UX** for later Discovery Assignment (A Confirmed / B Filename try; never auto-bind; P1 = query seams only). See [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md). |
| `2026-09-09 Asia/Shanghai` | Human approved **uninstall layout-fallback** (warn → A-only among remaining installed / else 26-key + Luna/`luna_pinyin`; package capability manifest = Universe convention, not RIME built-in). See [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md). |
| `2026-09-09 Asia/Shanghai` | Human approved **SharedDefault end-state**: Ice-shaped **`privatePreset`** = reference mode for third-party schemes. **P1** extract Ice `privatePreset` only; Wanxiang may temporarily keep skip/`consumePrelude`. **P2** Wanxiang → `privatePreset` (`consumePrelude` not end-state). Luna may remain Prelude/builtin exception. Fidelity risk → product regression (not silent). |
| `2026-09-09 Asia/Shanghai` | Human approved **Lua/OpenCC Ownership**: unified ResourceOwnership/ResourceCapability; **long-term dual** `namedList` (Ice) + `exactHash` (Wanxiang) — **not** forced to one; no dangerous filename heuristics auto-remove; no whole-dir wipe; Settings confirmed honesty + optional user marking; OpenCC Wanxiang may `admitted=false`; P1 wire both unchanged; P2 Wanxiang platform path keeps `exactHash`. Contrast: SharedDefault → `privatePreset` in P2; Ownership stays dual. |
| `2026-09-09 Asia/Shanghai` | Human approved **Luna presence + readiness greying**: Luna always on **26-key Section A**; never on nine-key A; not a B filename suggestion; builtin exception; uninstall fallback already → 26+Luna. Confirmed-but-unready → greyed in A with reason (prefer grey over hide); click guides fix; no direct binding until ready; uninstall auto-rebind **ready** A only. See [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md). |
| `2026-09-09 Asia/Shanghai` | Human ADR/#101: **leave draft PR #101** until Scheme Platform progresses; **do not Accept ADR 0034 now**; **keep #101 and #102 separate**; cross-links / Accept prep (incl. A34-R8-style refresh) **later** after platform docs/impl. |

---

## 1. North star

All third-party schemes share **one Scheme Platform**.

- **雾凇 / Ice is the reference implementation.** Platform behavior is extracted from what Ice already does correctly (or from Ice hooks that must remain behavior-identical after extract).
- **Wanxiang and future schemes** plug in via **adapters** (manifest + optional strategy plugins).
- **Minimize** production branches of the form `if schemaID == …`. Scheme-specific divergence lives in declarative manifests / adapter plugins, not scattered installer conditionals.

This supersedes expanding Wanxiang-P4 / A34-R1 into a mega-refactor that “makes Wanxiang more like Ice” by forking more Ice-shaped code paths. Prefer: extract once → Ice regression → Wanxiang migrates onto the same platform.

---

## 2. Shared extract layer (platform)

The platform owns these capabilities for every third-party scheme. Ice is the reference that already (mostly) exercises them; Wanxiang gaps are called out in the P0 matrix (§5).

### 2.1 Lifecycle

Unified pipeline (fail-closed at every mutation boundary):

1. **download** (pinned source / digest / staged identity)  
2. **filter plan** (admit / skip / rewrite per plan)  
3. **stage-verify** (content + ownership checks before commit)  
4. **upgrade checkpoint** (prior generation when replacing)  
5. **install** (commit lease; write owned paths only)  
6. **deploy** (Main App deploy before claiming success)  
7. **receipt** (success only after deploy)  
8. **fail-closed restore** (no success receipt; restore selection + files / keep upgrade checkpoint per existing contracts)

### 2.2 Active vs inactive uninstall

| Mode | Required outcome |
|---|---|
| **Active** uninstall | Fallback **Luna-only** (await successful Luna deploy before stage→commit); peer schemes may remain installed but are **not** auto-selected |
| **Inactive** uninstall | Remove target-owned paths only; **preserve** peer / unknown / user / Prelude baselines; no Luna switch required |

Whole-directory wipe of `lua/` or `opencc/` remains **forbidden**.

### 2.3 Layout capability

26-key, 9-key, and future layouts are **declarative / plugin** capabilities on the scheme (or binding), **not** Ice-hardcoded `if schemaID == rime_ice` product logic. Ice’s current nine-key / binding behavior is the reference *shape*; the platform API must not bake Ice IDs into the only supported path.

**P1 (this Assignment):** extract declarative `LayoutCapability` + adapter lookup (preserve Ice-only nine-key answers; Wanxiang `supportsNineKey = false`); may add readiness **query** seams if needed. **Later Assignment (not yet drafted):** Installed Capability Discovery / layout-picker — dynamically enumerate installed schemes’ capabilities for layout UI (separate Human Active). **Decided UX for that later Assignment:** layout-page A/B + **uninstall layout-fallback** + **Luna presence** + **readiness greying** — [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md) (not P1 UI; uninstall hooks consume fallback contract; Luna always 26-key A / never nine-key A; confirmed-but-unready greyed with reason).

### 2.4 Resource ownership（Human Decided `2026-09-09`）

Unified **ResourceOwnership** / ResourceCapability API over **lua / opencc / dicts** (and similarly admitted owned sets):

- **Long-term dual strategies:** Ice **`namedList`** (reference) + Wanxiang **`exactHash`** — **not** forced to one (contrast SharedDefault, which consolidates to `privatePreset` in P2).
- Scheme supplies a **manifest** and/or **ownership strategy plugin** (`namedList` / `exactHash` / preserve-unknown, etc.).
- **No** dangerous filename heuristics auto-removing lua/opencc; **no** whole-directory wipe of `lua/` or `opencc/`.
- Settings: confirmed ownership/strategy honesty; optional user marking for third-party; heuristics only as confirm-gated hints if ever.
- OpenCC: Wanxiang may keep **`admitted=false`**; same API.
- **P1:** wire Ice+Wanxiang strategies, behavior unchanged; **P2:** Wanxiang uses platform path **keeping `exactHash`**.
- Cross-scheme coexistence follows preserve rules already Human-approved in the Ice↔Wanxiang matrix contract ([`scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md`](scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md)).

### 2.5 Shared-default policy（Human Decided `2026-09-09`）

- **Never overwrite** Prelude / official `default.yaml`.
- **End-state for third-party schemes:** Ice-shaped **`privatePreset`** is the **reference SharedDefault mode** (e.g. Ice `rime_ice_preset.yaml` + include/import rewrite).
- **P1:** extract Ice `privatePreset` only; Wanxiang may **temporarily** keep skip / `consumePrelude` as a **transitional** adapter.
- **P2:** Wanxiang **migrates to `privatePreset`** (same mode as Ice). **`consumePrelude` is not Wanxiang end-state.**
- **Luna** may remain a Prelude / builtin exception.
- **Fidelity risk:** Wanxiang preset migration needs **product regression** (separate from a silent change) — do not treat P2 preset cutover as behavior-free.

---

## 3. Scheme layer (per scheme)

Each third-party scheme contributes:

| Artifact | Role |
|---|---|
| **Manifest** | Identity, pin, plan/post IDs, layout capabilities, ownership map pointers, skip/admit rules |
| **Optional adapters** | Preset strategy; layout fallback; ownership strategy; post-process |

Ice’s adapters are the **reference**. Wanxiang’s existing **`exactHash`** Lua ownership, upgrade-rollback, and skip/`consumePrelude`-shaped SharedDefault are adapters (or become them) — not a second parallel platform. SharedDefault **end-state** for Wanxiang is still Ice-shaped **`privatePreset`** (P2), not permanent skip-only. Ownership **stays dual** (`namedList` + `exactHash`) even after P2 — unlike SharedDefault consolidation.

---

## 4. Phases

| Phase | Goal | Gate / stop |
|---|---|---|
| **P0** | Define platform interfaces + matrix 「**Ice already satisfies** / **Wanxiang gaps**」 | **Docs only.** No Swift. Exit = Human-readable matrix + interface sketch linked from Assignment |
| **P1** | Extract Ice hooks into platform; **Ice behavior unchanged** | Ice regression (automation + IQ as authorized). Stop if Ice UX/install/uninstall drifts without Human accept |
| **P2** | Migrate Wanxiang onto platform (lua / layout / default per reference) | Wanxiang regression + cross-scheme matrix still green. Prefer completing P2 before revisiting broad A34-R1 mega-claims |
| **P3** | Delete redundant forks; only then revisit A34-R1 / ADR Accept path | **No** ADR Accept in this Assignment without separate Human auth; Product Gate / TF still separate |

### Relationship to Wanxiang P4 / A34-R1

- Expanding Wanxiang-P4 into this platform extract is **superseded** by `SCHEME-DELIVERY-SCHEME-PLATFORM-001`.
- Pure A34-R1 **documentation / residual disposition** closure may continue only if Human explicitly chooses a **narrow** path that **excludes** platform extract (see Wanxiang P4 Current Status choice).
- Otherwise: recommend waiting until platform Assignment is **Active** and at least **P0** (preferably **P2**) before treating A34-R1 as closed via “Wanxiang became Ice-shaped.”

---

## 5. P0 matrix sketch (Ice satisfies / Wanxiang gaps)

Summary pointers from earlier coexistence / P4 / cross-scheme work (not a new device claim). Full P0 matrix is the first Active deliverable of the platform Assignment.

| Capability | Ice (reference) | Wanxiang (today) | Gap class |
|---|---|---|---|
| Skip / never overwrite Prelude `default.yaml` | P2+ private preset (`rime_ice_preset`); skip install of Prelude file | Plan skips `default.yaml`; no private preset rewrite **yet** | **Decided end-state** — third-party SharedDefault = Ice-shaped `privatePreset`; Wanxiang P1 transitional skip/`consumePrelude` → P2 migrate to `privatePreset` |
| Lifecycle download→…→receipt + fail-closed | Mature Ice install/uninstall/rollback paths | Upgrade-rollback + install paths present; not fully “one platform API” | **Platform extract** |
| Active uninstall → Luna-only | Evidenced | Evidenced (matrix / runtime-route) | **Shared** — keep; avoid schemaID forks |
| Inactive uninstall preserves peer/unknown/Prelude | Evidenced | Exact-hash Lua + plan removable | **Adapter shape** (Ice plan list vs Wanxiang exact-hash) |
| Layout 26 / 9-key capability | Ice/`t9` historically hardcoded in places | Nine-key readiness not Ice-parity productized | **Declarative layout** gap |
| Resource ownership API | **`namedList`** (Ice reference) | **`exactHash`** Lua ownership | **Decided** — unify behind API; **long-term dual** (not forced to one); P2 keeps `exactHash` |
| `if schemaID == …` sprawl | Present in places (layout, ownership) | Present (Wanxiang-named helpers) | **P1–P3 reduce** |

Earlier comparison / contract sources (do not re-litigate without new evidence):

- [`scheme-resource-ownership-and-coexistence-plan.md`](scheme-resource-ownership-and-coexistence-plan.md)  
- [`scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md`](scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md)  
- [`scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md`](../evidence/scheme-delivery-wanxiang-p4-closure-gaps-2026-09-09.md)  
- ADR 0034 Proposed + Architecture Accept Conditional Accept (A34-R1 still `fix`)

---

## 6. Non-goals (unless separately authorized)

- Rewrite Wanxiang **content** to be Ice (schemas, triggers, Lua product surface)
- **Wanxiang nine-key productization** — deferred to later Assignment (not yet drafted); may ride Discovery later or stay further deferred; P1/P2 must not enable
- **Installed Capability Discovery / layout-picker** (and similar Lua/OpenCC product-surface honesty) — later Assignment (not yet drafted); separate Human Active; not P1 seams
- ADR 0034 **Accept** (Human: **not now**; leave draft #101; Accept prep later after platform progress)
- Product Gate / TestFlight / App Release
- Big Swift extract **before** P0 matrix exists and Human Activates the platform Assignment
- Unilateral Pause of `SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001` (Human must choose parallel narrow A34-R1 vs pause-for-platform)
- peer-prefer B; Recovery persistence; whole-`lua/`/`opencc/` wipe; Ice `dofile` full close (A34-R2 / TD-011) as a silent hitchhiker

---

## 7. What Human must authorize next

1. **Active authorized** (`2026-09-09` Gate 0) on [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md). Proceed **P0** docs per KOS cadence; **ask before first push/PR**; no P1 Swift until separately authorized.  
2. Explicit choice on Wanxiang P4 (still Active): **(a)** Active platform and pause/narrow P4, or **(b)** continue narrow A34-R1 **without** platform extract.  
3. Separate auth for push/merge, ADR Accept, TF, Product Gate — never implied by this target approval.
