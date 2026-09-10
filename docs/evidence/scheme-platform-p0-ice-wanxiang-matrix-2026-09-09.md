# Scheme Platform P0 — Ice vs Wanxiang matrix (2026-09-09)

**Status:** P0 evidence / planning matrix (docs only). **Not** device claim; **Not** ADR Accept.
**Assignment:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md)
**Interfaces:** [`../plans/scheme-platform-p0-interfaces-2026-09-09.md`](../plans/scheme-platform-p0-interfaces-2026-09-09.md)
**Target:** [`../plans/scheme-platform-ice-reference-target-2026-09-09.md`](../plans/scheme-platform-ice-reference-target-2026-09-09.md)
**Code freeze basis:** `origin/main` @ `814abfd` (Ice/Wanxiang production on `codex/scheme-platform-001` docs branch)

**Columns:**
- **Ice today** — reference production behavior
- **Wanxiang today** — production behavior / known gap
- **Platform target** — shared seam goal
- **P1 extract?** — pull Ice hook into platform with Ice unchanged
- **P2 migrate?** — Wanxiang onto platform/adapters

Sources: `SchemaManagerTypes` plans (`rime-ice-plan-2` / `wanxiang-plan-1`), `RimeIceSharedDefaultAdapter`, `WanxiangLuaOwnership`, `SchemaManager+Download` / `+Installation` / `+T9Layout`, `SchemaArchiveInstaller`, `RimeSchemeCapabilityMatrix`, `RimeRuntimeSelection`, cross-scheme matrix contract, Wanxiang P4 gap inventory.

---

## Matrix

| Dimension | Ice today | Wanxiang today | Platform target | P1 extract? | P2 migrate? |
|---|---|---|---|---|---|
| **Lifecycle: download → filter → stage-verify → install → deploy → receipt** | Mature Main-App pipeline in `SchemaManager+Download`; plan filter via `shouldInstall`; deploy before success | Same pipeline entrypoints; Wanxiang pin/staged identity; upgrade path present | One `SchemeLifecycleCoordinator` over shared steps | **Yes** — façade / seam around Ice path | **Yes** — call same coordinator (drop parallel forks) |
| **Upgrade checkpoint** | Install/replace path; not the Wanxiang-shaped prior-generation helper as primary story | `createUpgradeCheckpoint` + restore/commit; fail-closed upgrade rollback (IQ Pass with conditions) | Shared `UpgradeCheckpointing` | **Partial** — introduce protocol; Ice may wrap existing path | **Yes** — Wanxiang checkpoint becomes strategy behind protocol |
| **Fail-closed restore** | Active-uninstall Luna fail keeps selection+files; staging rollback | Upgrade rollback + uninstall staging; double-failure checkpoint keep | Shared restore orchestration + matrix CS-F* | **Yes** — keep Ice semantics | **Yes** — keep Wanxiang semantics via same APIs |
| **Active uninstall → Luna-only** | Evidenced (automation + runtime-route) | Evidenced (CS-07/08 / runtime-route) | Shared uninstall mode `activeLunaOnly`; no peer auto-select | **Yes** — already mostly schema-agnostic `uninstallSchema` | **Low code** — verify no new schemaID forks |
| **Inactive uninstall preserves peer/unknown/Prelude** | Plan removable list; no whole lua/opencc wipe | Plan removable + exact-hash lua; preserve unknown/edited | Shared staging + ownership strategy | **Yes** (Ice strategy) | **Yes** (Wanxiang strategy registration) |
| **Skip / never overwrite Prelude `default.yaml`** | `skippedFiles: ["default.yaml"]` + private preset post-2 | `skippedFiles` includes `default.yaml`; no preset rewrite | SharedDefaultPolicy.neverInstallDefaultYAML | **Yes** | **Yes** — keep skip invariant |
| **Private preset / shared-default adapter** | `RimeIceSharedDefaultAdapter` → `rime_ice_preset.yaml` + include/import rewrite; Download `schemaID == rime_ice` hook | No private preset (skip/`consumePrelude` transitional) | `SharedDefaultAdapter`; **end-state** Ice-shaped `privatePreset` for third-party; Luna may remain Prelude/builtin exception | **Yes** — extract Ice `privatePreset` only; Wanxiang may keep skip/`consumePrelude` transitional | **Yes — required** — Wanxiang migrates to `privatePreset` (same as Ice); `consumePrelude` **not** end-state; needs product regression (not silent) |
| **Resource ownership: lua** | Explicit `removableFiles` lua paths (+ `lua/cold_word_drop` dir) = **`namedList`** | Exact-hash map `WanxiangLuaOwnership`; matched at uninstall/checkpoint via `matchingWanxiangLuaPaths` = **`exactHash`** | Unified **ResourceOwnership**/ResourceCapability; **long-term dual** `namedList` + `exactHash` (**not** forced to one); **no** dangerous filename heuristics auto-remove; **no** whole-dir wipe | **Yes** — wire Ice `namedList` (behavior unchanged) | **Yes** — Wanxiang uses platform path **keeping `exactHash`**; remove installer `wanxiang.schema.yaml` special-case |
| **Resource ownership: opencc** | Removable emoji/others Ice files; shared builtin OpenCC not wholesale owned | No opencc prefix in Wanxiang plan; may keep **`admitted=false`** | Same Ownership API over admitted opencc paths; Wanxiang may keep `admitted=false`; no directory wipe; no filename-heuristic auto-remove | **Yes** (Ice `namedList` paths) | **Keep `admitted=false` OK** unless product admits opencc later (same API) |
| **Resource ownership: dicts** | `cn_dicts/` `en_dicts/` removableDirectories | `dicts/` removableDirectory | Directory-owned under plan; never imply lua/opencc wipe | **Yes** | **Yes** |
| **Layout 26-key** | Capable; binding26; activate writes binding when 26-capable. Today helper: `isTwentySixKeyCapable` ≈ **not** `t9` (negation of nine-key hardcode) | Capable as full-pinyin product; in 26-key picker | Declarative `supports26Key` on adapter (**P1 seams**). **Discovery / layout-picker** (dynamic enumerate for UI) = later Assignment — not this extract | **Yes** — declarative seam; preserve current answers | **Yes** — adapter flags; Discovery UI still deferred |
| **Layout 9-key / T9** | Productized: readiness → binding9=`t9`; depends on Ice; uninstall layout fallback. Today helper: `isNineKeyCapable` **hardcoded** `== "t9"` | Plan admits `wanxiang_t9` / `wanxiang_t9i` files but `isNineKeyCapable` only `"t9"`; capability matrix does not productize Wanxiang nine-key | Declarative nine-key capability via adapter lookup (**P1 seams**); Ice-only answers preserved; Wanxiang `supportsNineKey=false`. **Discovery / layout-picker** + Wanxiang nine-key productization = later Assignment (not yet drafted; may ride Discovery or stay further deferred) | **Yes** — replace hardcode with adapter lookup; Ice-only answers unchanged; **do not** enable Wanxiang nine-key | **Human deferred** — file ownership (`wanxiang_t9*`) may remain in plan; **enablement / productization out of P2**; Discovery UI separate |
| **Capability honesty (fuzzy / advanced input)** | `RimeSchemeCapabilityMatrix`: fuzzy + advanced true for `rime_ice` | Both false for `wanxiang` (V1 honesty) | Keep matrix; drive from adapter/manifest flags | **Partial** — read from adapter | **Yes** — flags on Wanxiang adapter (values may stay false) |
| **`if schemaID == …` sprawl** | Download post-process; T9 normalize; uninstall layout; UI `rimeIce*` state; lua diagnostics guard | Installer Wanxiang lua match; post revision switch; named helpers | Adapters + manifest; P3 delete redundant forks | **Yes** — start reducing Ice forks via adapters | **Yes** — Wanxiang-named bridges → adapters |
| **Post-process revision binding** | `rime-ice-post-2` | `wanxiang-post-1` | `SchemePostProcessAdapter.revision` | **Yes** | **Yes** |
| **Cross-scheme coexistence (CS-01…10 / CS-F*)** | Peer in matrix | Peer in matrix | Platform must preserve Human-approved contract | **Regression gate** | **Regression gate** |
| **Pin / staged identity** | Ice dated pin / plan2-post2 | CNB `9bfcf60e…` / `17.5.9` / plan1-post1 | Unchanged unless Human extends | No pin change in P1 | No pin change in P2 unless authorized |

---

## Top Wanxiang gaps for P2 (summary)

1. **Layout nine-key productization** — **Human deferred** (`2026-09-09 Asia/Shanghai`) to a later Assignment (not yet drafted; may ride Discovery later or stay further deferred). Files may remain in plan; runtime/capability stays Ice/`t9`-only; P1/P2 must **not** enable Wanxiang nine-key; product capability stays false until that future Assignment.
1b. **Installed Capability Discovery / layout-picker** — **Human deferred** later Assignment (not yet drafted; separate Human Active). P1 of *this* Assignment only extracts declarative LayoutCapability / ResourceCapability seams + adapter lookup (today: `isNineKeyCapable == "t9"` hardcode vs `isTwentySixKeyCapable` = not `t9`). Dynamic enumeration for layout UI (and Lua/OpenCC product-surface honesty) is **not** P1.
2. **Ownership API unification** — **Human Decided (`2026-09-09`)**: unified ResourceOwnership/ResourceCapability; **long-term dual** `namedList` (Ice) + `exactHash` (Wanxiang) — **not** forced to one. P1 wire both (behavior unchanged); P2 Wanxiang platform path keeps `exactHash`. No dangerous filename heuristics auto-remove; no whole-dir wipe; Settings confirmed honesty + optional user marking; OpenCC Wanxiang may `admitted=false`. Contrast: SharedDefault → `privatePreset` in P2; Ownership stays dual. Exact-hash today is special-case in `SchemaArchiveInstaller` — become strategy without changing pin hashes.
3. **Shared-default** — **Human Decided (`2026-09-09`)**: third-party SharedDefault **end-state** = Ice-shaped **`privatePreset`**. P1 = extract Ice `privatePreset` only; Wanxiang may temporarily keep skip/`consumePrelude`. **P2 = Wanxiang migrates to `privatePreset`** (`consumePrelude` not end-state). Luna may remain Prelude/builtin exception. Fidelity risk → product regression (not silent).
4. **Lifecycle surface** — upgrade checkpoint is Wanxiang-strong; fold into shared `UpgradeCheckpointing` so Ice/Wanxiang stop diverging helper paths.
5. **Capability / settings honesty** — keep fuzzy/advanced false unless product expands; drive from adapter to avoid new schemaID switches.
6. **Residual A34-R1** — not a P2 code gap by itself; platform P2 progress informs later writeback (Paused Wanxiang P4; Pause ≠ Done).

---

## P0 exit checklist

- [x] Interface draft linked from Assignment
- [x] Ice-satisfies / Wanxiang-gaps matrix (this file)
- [ ] Human/Architecture informed (handoff; no Accept implied)
- [ ] Separate auth before P1 Swift

---

## History

- `2026-09-09 Asia/Shanghai`: P0 matrix authored on `codex/scheme-platform-001` (docs only; local commit; no push).
- `2026-09-09 Asia/Shanghai`: Human deferred Wanxiang nine-key productization to later Assignment; nine-key row / top-gaps note updated (**Human deferred**, not open TBD for this Assignment); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved P1↔Discovery split — 26-key vs nine-key hardcode note + Discovery deferred from P1 seams; local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human **Lua/OpenCC Ownership** decision — dual `namedList`/`exactHash` long-term; no filename-heuristic auto-remove; no whole-dir wipe; OpenCC Wanxiang may `admitted=false`; P1 wire both; P2 keep `exactHash` on platform; contrast SharedDefault → `privatePreset`. Local commit only; no push.
