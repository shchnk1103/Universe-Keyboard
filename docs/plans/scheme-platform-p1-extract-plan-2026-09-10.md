# Scheme Platform P1 — Extract plan + Ice regression checklist (P1-0)

**Status:** **Human Approved** order (`2026-09-10 Asia/Shanghai`). **P1-0 = this plan + Ice regression checklist (docs only).**
**Nature:** Execution plan for Ice-as-reference platform extract. **Not** Swift in P1-0; **not** ADR Accept; **not** Product Gate / TestFlight / Release.
**Assignment:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) (**Active**)
**Branch / PR:** `codex/scheme-platform-001` · draft PR #102 — **local commit only; ask before push**
**Base freeze:** `origin/main` @ `814abfd7c03002256978d7658c176b80002d2539`
**P0 inputs:** [`scheme-platform-p0-interfaces-2026-09-09.md`](scheme-platform-p0-interfaces-2026-09-09.md) · [`scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md`](../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md) · [`scheme-platform-ice-reference-target-2026-09-09.md`](scheme-platform-ice-reference-target-2026-09-09.md)
**KOS:** [`scheme-platform-execution-kos-2026-09-09.md`](scheme-platform-execution-kos-2026-09-09.md)

---

## 0. Authority

| Field | Value |
|---|---|
| Decision | Human Product Owner approved **P1-0 → P1-6** extract order (`2026-09-10 Asia/Shanghai`) |
| This slice (P1-0) | Docs only: this plan + Ice regression checklist; Assignment / ACTIVE_WORK / KOS pointers; **local commit**; **no push**; **no Swift** |
| Later slices (P1-1…P1-5) | Swift extract per slice; **ask Human before starting P1-1 Swift** (and before any push); each slice = local commit |
| P1-6 | P1 summary + Independent Quality (no open P0/P1 in scope); **no** silently closing conditionals |
| Non-claims | **No** ADR 0034 Accept; **no** Product Gate / TF / Release; **no** Wanxiang nine-key enablement; **no** Discovery UI; keep #101 ≠ #102 |

---

## 1. Human-approved slice order

| Slice | Content | Done when | Stop if |
|---|---|---|---|
| **P1-0** | This plan doc + Ice regression checklist | docs on branch (local commit) | — |
| **P1-1** | `SchemeAdapter` registry + Ice / Wanxiang / Luna adapters reflecting **today’s truth** | build + tests: lookup == today’s hardcodes | **product behavior change** |
| **P1-2** | `LayoutCapability`; `isNineKeyCapable` / 26 via adapter; Ice T9 unchanged; Wanxiang `supportsNineKey=false` | Ice T9 automation green | **enable Wanxiang nine-key** |
| **P1-3** | SharedDefault: Ice `privatePreset` into platform seam | Ice still `rime_ice_preset`; **no** Prelude overwrite | **Wanxiang preset migrate** (that is P2) |
| **P1-4** | `ResourceOwnership` `namedList` + `exactHash`; Ice/Wanxiang uninstall via strategies | coexistence / uninstall tests green | **whole-dir wipe** / **semantic change** |
| **P1-5** | Uninstall hook shape for Ice layout fallback (Ice behavior only; full A-only Discovery fallback later) | Ice uninstall layout **unchanged** | **implement Discovery UI fallback** |
| **P1-6** | P1 summary + Independent Quality (no open P0/P1 in scope) | IQ doc | **silently closing conditionals** |

Execute **strictly in order**. Do not start P1-(n+1) until P1-n Done-when is met (or Human rewrites the order).

---

## 2. Design invariants (carry from P0 / target)

1. Ice is the **reference**; P1 extracts Ice hooks with **Ice behavior unchanged**.
2. Minimize production `if schemaID == …`; divergence lives in registry + adapters.
3. Never overwrite Prelude / official `default.yaml`.
4. Never whole-directory wipe of `lua/` or `opencc/`.
5. Active uninstall → **Luna-only** (await successful Luna deploy before stage→commit).
6. Ownership stays **long-term dual**: Ice `namedList` + Wanxiang `exactHash` (not forced to one).
7. SharedDefault **end-state** for third-party = Ice-shaped `privatePreset`; **P1 = Ice only**; Wanxiang migrate = **P2**.
8. Wanxiang nine-key productization + Discovery layout-picker UI = **later Assignments** (not P1).

---

## 3. Slice guidance (docs; naming may refine in Swift)

### P1-0 — Plan + Ice regression checklist (this file)

- Land plan + checklist; update Assignment Current Phase / Progress / History; ACTIVE_WORK row; KOS one-liner.
- **Docs-only** gate: no `xcodebuild` required; report tip SHA; **no push**.

### P1-1 — SchemeAdapter registry (today’s truth)

- Introduce thin registry / catalog façade: lookup by `schemaID` → adapter bundle.
- Register **Ice**, **Wanxiang**, **Luna** adapters that **mirror today’s hardcodes** (no new capability claims).
- Done when unit/lookup tests prove answers equal pre-extract hardcodes (nine-key / 26 / ownership / shared-default mode flags as applicable).
- Stop if any product-facing behavior drifts.

### P1-2 — LayoutCapability

- Declarative `LayoutCapability` on adapters; route `RimeRuntimeSelection.isNineKeyCapable` / `isTwentySixKeyCapable` (and binding setters that guard on them) through adapter lookup.
- Ice: `t9` / Ice readiness / binding9 behavior **unchanged**.
- Wanxiang: `supportsNineKey = false` (files in plan may remain; **no enablement**).
- Focused gate: `NineKeyEnableTransactionTests` + Ice T9 paths in `SchemaManagerTests` / related; coexistence layout assertions that Wanxiang is not nine-key capable.
- Stop if Wanxiang nine-key becomes product-true.

### P1-3 — SharedDefault → platform seam (Ice `privatePreset`)

- Extract / wrap `RimeIceSharedDefaultAdapter` behind SharedDefault seam; replace `schemaID == "rime_ice"` post-process call sites with adapter lookup.
- Ice still produces / uses `rime_ice_preset.yaml`; Prelude `default.yaml` never overwritten.
- Wanxiang remains transitional skip / `consumePrelude` — **do not** migrate Wanxiang preset in P1.
- Focused gate: Ice preset / skip-default tests in `SchemeResourcePreparationCoexistenceTests` (e.g. `testIcePlanSkipsDefaultYamlAndInstallsPrivatePreset`, `testIceUninstallRemovesPresetAndLeavesOfficialDefaultYaml`, pollution recovery).

### P1-4 — ResourceOwnership strategies

- Unify behind `ResourceOwnership` / ResourceCapability: Ice **`namedList`**, Wanxiang **`exactHash`**.
- Uninstall / checkpoint staging calls strategies; **no** dangerous filename-heuristic auto-remove; **no** whole-dir wipe.
- OpenCC: Wanxiang may keep `admitted=false`.
- Focused gate: Wanxiang exact-hash + Ice named-list coexistence / uninstall tests (`SchemeResourcePreparationCoexistenceTests`, CS-05/06/09/10 inventory preserve, CSF-3 staging).

### P1-5 — Uninstall hook shape (Ice layout fallback only)

- Shape `onUninstallPrepare` / UninstallHooks so Ice still calls today’s `prepareRimeIceUninstallWithLayoutFallback` semantics.
- **Do not** implement Discovery Section A-only picker UI or full A/B fallback productization here (later Assignment; contract already in [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md)).
- Optional: readiness **query** / rollback try-deploy **seams** only if required by Ice path — not Discovery UI.
- Done when Ice uninstall layout behavior is unchanged under automation.
- Stop if Discovery UI fallback is implemented in this Assignment.

### P1-6 — P1 summary + Independent Quality

- Write P1 summary (what extracted, what deferred to P2 / Discovery / Wanxiang nine-key).
- Independent Quality: **no open P0/P1 findings in scope**; do **not** silently close conditionals / residuals — write explicit disposition or leave open with owner.
- Still **no** ADR Accept; still **ask before push** if not yet pushed.

---

## 4. Ice regression checklist (P1-0 deliverable; gates for P1-1…P1-5)

Use as the **Ice behavior unchanged** bar. Check items that apply to the slice under test; P1-6 IQ re-runs the full applicable set on the freeze tip.

### 4.1 Always (every Swift slice P1-1…P1-5)

- [ ] **Docs-only? skip.** Else: `xcrun swift-format format --in-place --configuration .swift-format <touched>` then `xcrun swift-format lint --strict --configuration .swift-format <touched>` — lint failure = **stop** (AGENTS hard gate; aligns CI `Check Swift formatting`).
- [ ] Focused `xcodebuild` for touched targets (KeyboardCore and/or App / tests per AGENTS); do not claim green from format-only.
- [ ] No Prelude `default.yaml` overwrite; no whole-`lua/` / `opencc/` wipe.
- [ ] No Wanxiang nine-key enablement; no Discovery layout-picker UI.
- [ ] Local commit only unless Human authorized push; **ask before push**; no ADR Accept.

### 4.2 Capability / layout honesty (esp. P1-1, P1-2)

- [ ] `isNineKeyCapable("t9")` / Ice nine-key path remains true when today’s rules say so; Wanxiang / `wanxiang` remains **false**.
- [ ] `isTwentySixKeyCapable` answers match today’s hardcodes for Ice / Wanxiang / Luna.
- [ ] Registry lookup for Ice / Wanxiang / Luna == today’s hardcoded answers (P1-1 Done-when).
- [ ] `NineKeyEnableTransactionTests` green (Ice T9 enable / failure leave-26 / lease / readiness).
- [ ] Binding9 writes still reject non-capable IDs; Ice uninstall / leave-Ice layout fallback behavior unchanged (P1-2 / P1-5).

### 4.3 SharedDefault / preset (esp. P1-3)

- [ ] Ice install still skips Prelude `default.yaml` and installs / rewrites toward `rime_ice_preset`.
- [ ] Ice uninstall removes Ice preset ownership without deleting official `default.yaml`.
- [ ] Known Ice `default.yaml` pollution recovery path still fail-closed / restores per existing contract.
- [ ] Wanxiang still skips `default.yaml` (no P1 preset migration).

### 4.4 Ownership / coexistence / uninstall (esp. P1-4, P1-5)

- [ ] Ice uninstall stages **namedList** Ice lua/opencc paths only; does not stage Wanxiang exact-hash paths.
- [ ] Wanxiang uninstall / checkpoint uses **exactHash** match; unknown / modified / symlink paths preserved per today’s tests.
- [ ] CS-01…CS-10 / CS-F* focused set still green where touched (peer retain; active uninstall → Luna-only; staging fail-closed).
- [ ] Active uninstall awaits Luna deploy before commit; Luna deploy / staging failure restores selection + files.
- [ ] Ice `prepareRimeIceUninstallWithLayoutFallback` product outcome unchanged (P1-5).

### 4.5 Suggested focused test anchors (non-exhaustive)

| Area | Anchors (names may move; intent fixed) |
|---|---|
| Ice preset / Prelude | `SchemeResourcePreparationCoexistenceTests` — `testIcePlanSkipsDefaultYamlAndInstallsPrivatePreset`, `testIceUninstallRemovesPresetAndLeavesOfficialDefaultYaml`, pollution recovery |
| Wanxiang ownership | `testWanxiangExactHashLuaMatchIsStagedOnUninstall`, modified/unknown/symlink negatives; `testIceUninstallDoesNotStageWanxiangExactHashLuaPaths` |
| Coexistence | CS-01…CS-06, CS-09/10 inventory; CSF-1/2/3 manager + preparation tests in `SchemaManagerTests` / coexistence |
| Active uninstall | `testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles`, Luna/staging failure restores; CS-07/08 |
| Nine-key / T9 | `NineKeyEnableTransactionTests` full class; `SchemaManagerTests` nine-key capability assertions (e.g. Wanxiang not capable) |

---

## 5. Regression gates (summary)

| Gate | When | Rule |
|---|---|---|
| Docs-only | P1-0 (and pure docs fixes) | No Swift → skip format/xcodebuild; state so in handoff |
| Format + lint | Any Swift touch | `swift-format` format then `lint --strict`; fail = stop |
| Focused tests | Each P1-1…P1-5 | Run anchors for the slice + any shared Ice checklist rows marked; expand if blast radius unclear |
| IQ | P1-6 | Independent Quality; **no open P0/P1 in scope**; no silent conditional close |
| Push | Any | **Ask Human**; draft #102; leave #101 alone; **no** ADR Accept |

---

## 6. Explicit non-goals (P1)

- Wanxiang **content** rewrite to Ice; Wanxiang **nine-key productization** / enablement
- Wanxiang SharedDefault migrate to `privatePreset` (**P2**)
- Installed Capability Discovery / layout-picker UI; full A/B Discovery fallback productization (P1-5 = Ice hook shape only)
- ADR 0034 **Accept**; Product Gate / TestFlight / App Release
- Whole-dir `lua/` / `opencc/` wipe; dangerous filename-heuristic auto-remove
- Ice `dofile` full close (A34-R2 / TD-011); `RTRD-01`/`RTRD-02`; Recovery persistence; peer-prefer B
- Closed / Done for Paused Wanxiang P4 / A34-R1 without separate writeback auth
- Push / undraft / merge without Human ask; expanding PR #101 into platform work

---

## 7. KOS one-liner (P1 extract)

**P1-0→P1-6 in order; local commit per slice; ask before push; no ADR Accept; Ice behavior unchanged — stop on product drift / Wanxiang nine-key enable / Discovery UI / whole-dir wipe / silent conditional close.**

---

## 8. History

| When | What |
|---|---|
| `2026-09-10 Asia/Shanghai` | Human approved P1-0→P1-6 order; P1-0 lands this plan + Ice regression checklist; Assignment / ACTIVE_WORK / KOS updated; **local commit only**; **no push**; **no Swift**. |
