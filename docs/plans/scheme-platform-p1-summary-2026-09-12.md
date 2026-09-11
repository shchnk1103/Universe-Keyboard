# Scheme Platform P1 — Extract summary (P1-6)

**Status:** P1 extract complete on freeze tip （docs summary this file）. **Not** ADR Accept; **not** Product Gate / TestFlight / Release; **not** Assignment Close.
**Assignment:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) (**Active** — keep Platform Active; P1 Done + IQ recorded; next = P2 awaiting auth)
**Branch / PR:** `codex/scheme-platform-001` · draft PR [#102](https://github.com/shchnk1103/Universe-Keyboard/pull/102)
**IQ freeze tip:** `3cfa355` (`3cfa35515656cf7ac31a3dae3fd64960ecfc37f4`) — P1-5 UninstallHooks; confirm HEAD after fetch
**Independent Quality:** [`scheme-delivery-scheme-platform-001-p1-quality-review.md`](../reviews/scheme-delivery-scheme-platform-001-p1-quality-review.md)
**Plan / checklist:** [`scheme-platform-p1-extract-plan-2026-09-10.md`](scheme-platform-p1-extract-plan-2026-09-10.md)
**KOS:** [`scheme-platform-execution-kos-2026-09-09.md`](scheme-platform-execution-kos-2026-09-09.md)
**Date:** `2026-09-12 Asia/Shanghai`

---

## 1. What P1 extracted (Ice-as-reference; Ice behavior unchanged)

| Slice | SHA (feat tip) | What landed |
|---|---|---|
| **P1-0** | `70e66d4` | Extract plan + Ice regression checklist（docs only） |
| **P1-1** | `7a50165` | **`SchemeAdapter` registry** + Ice / Wanxiang / Luna adapters mirroring today’s hardcodes; KeyboardCore equality tests; thin `postProcessingRevision` bridge |
| **P1-2** | `5bba4d2` | **`LayoutCapability`** (`supportsTwentySixKey` / `supportsNineKey` / `nineKeySchemaIDs`); route `isNineKeyCapable` / `isTwentySixKeyCapable` (+ binding9 / ADR 0018 family path) via registry; Ice T9 unchanged; Wanxiang `supportsNineKey=false` |
| **P1-3** | `22c6b79` | **SharedDefault** Ice **`privatePreset`** seam (`SchemeSharedDefaultApplying` + registry applicator → `RimeIceSharedDefaultAdapter`); Download post-process via registry; Wanxiang remains transitional `consumePrelude` no-op |
| **P1-4** | `5c42546` | **`ResourceOwnership` dual strategies** — Ice **`namedList`** + Wanxiang **`exactHash`**; uninstall/checkpoint staging via strategies; Wanxiang OpenCC `admitted=false`; **no** whole-dir wipe / filename-heuristic auto-remove |
| **P1-5** | `3cfa355` | **`UninstallHooks` / `onUninstallPrepare`** — Ice layout fallback via registry (`prepareUninstallLayoutFallback` → 26-key + invalidate T9 readiness = today’s `prepareRimeIceUninstallWithLayoutFallback`); **no** Discovery A/B UI |
| **P1-6** | *(this docs tip)* | This summary + Independent Quality |

**Invariant carried:** minimize production `if schemaID == …`; divergence lives in registry + adapters; never overwrite Prelude `default.yaml`; never whole-dir wipe `lua/` / `opencc/`; active uninstall → Luna-only; ownership stays long-term dual.

---

## 2. Explicitly deferred (not silently closed)

| Item | Owner / next | Notes |
|---|---|---|
| **P2** Wanxiang SharedDefault → **`privatePreset`** migrate | Human auth → P2 | `consumePrelude` is transitional, **not** Wanxiang end-state; fidelity risk → product regression |
| **Discovery A/B layout-picker UI** | Later Assignment (not drafted) | Section A Confirmed / Section B Filename try; uninstall A-only rebind contract already documented — **not** productized in P1-5 |
| **Wanxiang nine-key productization** | Later Assignment | P1/P2 must **not** enable; `supportsNineKey` stays false |
| **ADR 0034 Accept** | Human + Architecture later | Leave draft **#101**; keep **#101 ≠ #102**; **no Accept now** |
| **A34-R1 writeback** | Paused Wanxiang P4 Assignment | Still **`open`**; Pause ≠ Closed/Done; revisit after platform progress |
| A34-R2 / TD-011 / RTRD-* / Recovery persistence / peer-prefer B | Parallel debt | Out of P1 scope |

---

## 3. Tip trail (key SHAs + merges)

| Tip | Role |
|---|---|
| `814abfd` | Base freeze `origin/main` / Gate 0 branch start |
| `70e66d4` | P1-0 plan + Ice regression checklist |
| `7a50165` | P1-1 SchemeAdapter registry |
| `5bba4d2` | P1-2 LayoutCapability（hosted CI fully green on tip） |
| `22c6b79` | P1-3 SharedDefault Ice `privatePreset` |
| `d8e8299` | merge `origin/main` into scheme-platform-001（post–P1-3; hosted CI fully green） |
| `5c42546` | P1-4 ResourceOwnership dual |
| `82bdd60` | merge `origin/main` into scheme-platform-001（post–P1-4; hosted CI fully green） |
| `3cfa355` | **P1-5 UninstallHooks** — **IQ freeze tip** |
| *(P1-6 docs tip)* | This summary + IQ + Assignment / ACTIVE_WORK / KOS sync |

Hosted CI snapshots used by IQ: see Independent Quality review（prior slice tips green; freeze-tip `build-and-test` disposition recorded explicitly — not silently closed）.

---

## 4. Non-claims

- **Not** ADR 0034 Accept / undraft-or-merge #101
- **Not** Product Gate / TestFlight / App Release
- **Not** Assignment Exit / Closed（Exit Criteria need P2/P3; prefer keep **Active** with P1 Done + IQ）
- **Not** Wanxiang nine-key enablement; **not** Discovery UI productization
- **Not** A34-R1 Closed/Done
- Push of this P1-6 docs tip: **ask Human**（local commit only unless authorized）

---

## 5. Next

1. Human: authorize push of P1-6 docs tip to draft #102（optional; ask wording in handoff）.
2. Human: authorize **P2** start when ready（Wanxiang → platform SharedDefault `privatePreset`; ownership stays dual `exactHash`）.
3. Leave #101 alone; no ADR Accept; no Product Gate / TF.
