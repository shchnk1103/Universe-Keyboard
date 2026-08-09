# TD-012 G0: iOS octagram Artifact Capability Audit

**Date / timezone:** `2026-08-09 Asia/Shanghai`
**Evidence grade:** `Executor-recorded`
**Scope:** Read-only capability audit of the currently pinned iOS RIME vendor artifact.
**Product authorization:** Human Product Owner opened TD-012 G0 in-session on `2026-08-09 Asia/Shanghai`.
**Non-goals:** No model download, no vendor rebuild, no schema patch, no deployment, no Extension change, and no claim of runtime grammar success.

## Boundary

TD-012 may only offer the optional RIME-LMDG `*.gram` model if the pinned iOS
artifact actually includes the corresponding librime grammar implementation.
The presence of the core `Grammar` interface alone is insufficient: a static
iOS build must link and register the concrete module before a schema can load
the model.

## Evidence

| Check | Observed state |
|---|---|
| Pinned artifact | `rime-vendor-ios-1.16.1-lua.1` with SHA-256 `c299f36e…c840436c` |
| Structural receipt | `bash scripts/ensure_rime_vendor.sh verify` passed; exactly 11 reviewed XCFrameworks present |
| Inventory | Contains `librime`, `librime-lua`, Lua and core dependencies; no octagram XCFramework |
| `librime.a` archive members | `core_module.o`, `dict_module.o`, `gears_module.o`, `levers_module.o`, and supporting core objects; no octagram member |
| Exported symbols | Core `Grammar` type and `ContextualTranslation` appear, but `rime_require_module_octagram` does not |
| Runtime registration | Main App and Keyboard traits enumerate only `core + dict + gears + lua`; the only forced plug-in link is `rime_require_module_lua` |

## Conclusion

**G0 result: No-Go for the current vendor artifact.** The artifact can express
the grammar abstraction but does not contain the concrete octagram module or a
registration path. Downloading `wanxiang-lts-zh-hans.gram` now would create a
file that the product cannot truthfully represent as an enabled grammar model.

## Required Gate Before Reopening TD-012

1. Product and Architecture explicitly authorize a new iOS vendor-artifact
   feasibility/integration slice.
2. A reproducibly built, hash-pinned artifact includes the concrete octagram
   implementation and an intentional module-registration path.
3. A real iOS runtime smoke proves model loading, followed by memory/jetsam,
   disk-space, deployment and uninstall gates.

Until then, G1–G6 remain blocked. This audit is architecture evidence only; it
does not constitute a Release, quality, memory or Product acceptance result.
