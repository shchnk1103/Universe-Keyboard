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
| **Private preset / shared-default adapter** | `RimeIceSharedDefaultAdapter` → `rime_ice_preset.yaml` + include/import rewrite; Download `schemaID == rime_ice` hook | No private preset | `SharedDefaultAdapter`; Ice = privatePreset; Wanxiang = skipOnly (optional preset later) | **Yes** — extract Ice adapter behind protocol | **Optional** — only if product requires Ice-parity defaults; else skipOnly adapter |
| **Resource ownership: lua** | Explicit `removableFiles` lua paths (+ `lua/cold_word_drop` dir) | Exact-hash map `WanxiangLuaOwnership`; matched at uninstall/checkpoint via `matchingWanxiangLuaPaths` | `ResourceOwnershipStrategy` (planListed vs exactContentHash) | **Yes** — Ice planListed | **Yes** — exact-hash strategy; remove installer `wanxiang.schema.yaml` special-case |
| **Resource ownership: opencc** | Removable emoji/others Ice files; shared builtin OpenCC not wholesale owned | No opencc prefix in Wanxiang plan (base package focus) | Ownership API over admitted opencc paths; no directory wipe | **Yes** (Ice listed paths) | **Mostly N/A** unless Wanxiang admits opencc later |
| **Resource ownership: dicts** | `cn_dicts/` `en_dicts/` removableDirectories | `dicts/` removableDirectory | Directory-owned under plan; never imply lua/opencc wipe | **Yes** | **Yes** |
| **Layout 26-key** | Capable; binding26; activate writes binding when 26-capable | Capable as full-pinyin product; in 26-key picker | Declarative `supports26Key` on adapter | **Yes** | **Yes** |
| **Layout 9-key / T9** | Productized: readiness → binding9=`t9`; depends on Ice; uninstall layout fallback | Plan admits `wanxiang_t9` / `wanxiang_t9i` files but `isNineKeyCapable` only `"t9"`; capability matrix does not productize Wanxiang nine-key | Declarative nine-key capability; Ice shape is reference | **Yes** — Ice-only answers unchanged | **Gap** — product TBD; migrate file ownership already; **enablement** only with Human product auth |
| **Capability honesty (fuzzy / advanced input)** | `RimeSchemeCapabilityMatrix`: fuzzy + advanced true for `rime_ice` | Both false for `wanxiang` (V1 honesty) | Keep matrix; drive from adapter/manifest flags | **Partial** — read from adapter | **Yes** — flags on Wanxiang adapter (values may stay false) |
| **`if schemaID == …` sprawl** | Download post-process; T9 normalize; uninstall layout; UI `rimeIce*` state; lua diagnostics guard | Installer Wanxiang lua match; post revision switch; named helpers | Adapters + manifest; P3 delete redundant forks | **Yes** — start reducing Ice forks via adapters | **Yes** — Wanxiang-named bridges → adapters |
| **Post-process revision binding** | `rime-ice-post-2` | `wanxiang-post-1` | `SchemePostProcessAdapter.revision` | **Yes** | **Yes** |
| **Cross-scheme coexistence (CS-01…10 / CS-F*)** | Peer in matrix | Peer in matrix | Platform must preserve Human-approved contract | **Regression gate** | **Regression gate** |
| **Pin / staged identity** | Ice dated pin / plan2-post2 | CNB `9bfcf60e…` / `17.5.9` / plan1-post1 | Unchanged unless Human extends | No pin change in P1 | No pin change in P2 unless authorized |

---

## Top Wanxiang gaps for P2 (summary)

1. **Layout nine-key productization** — files exist in plan; runtime/capability still Ice/`t9`-only. Largest product gap; needs Human layout decision before enablement.  
2. **Ownership API unification** — exact-hash lua works but is a special-case in `SchemaArchiveInstaller`; must become `ResourceOwnershipStrategy` without changing pin hashes.  
3. **Shared-default** — skip policy OK; no private-preset. P2 default = `skipOnly` adapter; private preset only if product asks.  
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
