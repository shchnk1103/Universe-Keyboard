# TD-012-OCTAGRAM-VENDOR-G1 — Quality Review Conclusion

| Field | Value |
|---|---|
| **Date / timezone** | `2026-08-10 Asia/Shanghai` |
| **Reviewer role** | 🧪 Quality, Performance & Release Maintainer — **independent re-verification** |
| **Repository tip** | `da09bb66560e6593d8cd71a36bcd50f85b6b810b` (`main` = `origin/main`; contains #63 `84250c5` + #64 handoff) |
| **Object** | Assignment [`td-012-octagram-vendor-g1.md`](td-012-octagram-vendor-g1.md) · Handoff [`td-012-octagram-vendor-g1-review-handoff.md`](td-012-octagram-vendor-g1-review-handoff.md) |
| **Executor evidence (not sole basis)** | [`docs/evidence/td-012-g1-octagram-vendor-build-2026-08-10.md`](../evidence/td-012-g1-octagram-vendor-build-2026-08-10.md) |
| **Manifest pin** | `rime-vendor-ios-1.16.1-lua.1-octagram.1` / SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` |
| **Destination used** | `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5` |
| **Strict flags** | `CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES` |

## Verdict

**Conditional Accept**

G1 **module capability** claims are independently re-verified on current `main`: immutable vendor pin, slices/symbols, published SHA-256, no `.gram`, PR #63 CI green, RimeBridgeTests (incl. octagram ×3), App+Keyboard tests, Debug/Release builds — all **Pass**.

This does **not** accept model quality, Jetsam budget, schema/UX, download, App Store, or Product Gate. Residuals remain visible with M-03 dispositions below.

> **G1 proves module capability only; no model quality claim.**

### Scope non-claims

| Claim | Quality position |
|---|---|
| Concrete `grammar` component registrable without `.gram` | **Accepted for G1** (simulator re-run) |
| Any `*.gram` improves ranking / is productized | **Not claimed** — **out of scope** |
| Extension memory / Jetsam under model load | **Not measured** — **required before model G2**, not blocking G1 |
| Legal opinion on header residual | **Out of scope** (engineering notice retained) |
| Device-attested behavior | **Not claimed** (no physical device) |

---

## Independent re-verification table（M-04）

| # | Check | Result | Evidence grade | Receipt |
|---|---|---|---|---|
| 1 | `bash scripts/ensure_rime_vendor.sh verify` | **Pass** | **Quality-reverified** | Structural inventory of **12** frameworks; exit 0 |
| 2a | `lipo -info` device `ios-arm64` | **Pass** | **Quality-reverified** | Non-fat `arm64` |
| 2b | `lipo -info` simulator fat | **Pass** | **Quality-reverified** | Fat: `x86_64 arm64` |
| 2c | `nm -gU` `rime_require_module_octagram` | **Pass** | **Quality-reverified** | Present as `__Z28rime_require_module_octagramv` on device + both sim archs |
| 3 | Download release + SHA-256 vs manifest | **Pass** | **Quality-reverified** | `d17aab9a…31399dd9` **SHA_MATCH=YES** |
| 4a | No `.gram` in downloaded zip | **Pass** | **Quality-reverified** | **0** `.gram` entries |
| 4b | No git-tracked `*.gram` | **Pass** | **Quality-reverified** | `git ls-files '*.gram'` empty |
| 4c | No product `.gram` runtime path in G1 | **Pass** | **Quality-reverified** | Tests/disclaimers only; empty shared/user dirs |
| 5 | PR #63 CI green + merged tip | **Pass** | **Quality-reverified** | MERGED `84250c5`; `build-and-test` + GitGuardian SUCCESS; ancestor of `main` |
| 6a | `RimeBridgeTests` (incl. octagram) | **Pass** | **Quality-reverified** | 57 executed, 20 skipped, **0 failures**; octagram ×3 pass |
| 6b | `Universe Keyboard` scheme `test` | **Pass** | **Quality-reverified** | App **147**/0 + Keyboard **6**/0 |
| 6c | Debug build | **Pass** | **Quality-reverified** | BUILD SUCCEEDED |
| 6d | Release build | **Pass** | **Quality-reverified** | BUILD SUCCEEDED |
| 7 | Dual force-load Jetsam risk | Qualitative only | **Quality-reverified** (inspection) | Measure **before model G2**; not blocking G1 |

No row is graded **Device-attested**. Full native rebuild of the octagram recipe was not re-executed; artifact identity is covered by published-zip SHA + local vendor verify + link/runtime tests.

---

## Handoff Quality questions

1. Re-run verify / tests / builds: **all Pass** (table 1, 6a–6d).  
2. Slices + symbol: **Pass** (row 2).  
3. Published SHA matches manifest from downloaded bytes: **Pass** (row 3).  
4. PR #63 CI green; merge on `main`: **Pass** (row 5).  
5. No `.gram` in zip / repo / product path: **Pass** (row 4).  
6. Dual force-load: octagram ~104 KiB + explicit glog force-load; relative to existing RIME+Lua mass, G1 plugin is minor. **No RSS/Jetsam measurement.** Measurement **required before model G2**. **Not a G1 reject.**

---

## Capability proof (re-verified)

| Assertion | Result |
|---|---|
| `octagramModuleCompiledIn` | true |
| traits `core+dict+gears+lua+octagram` | match |
| empty dirs, no `.gram` → setup + initialize | success |
| `octagramModuleRegistered` | true |
| `grammarComponentRegistered` | true |
| Lua still registered | true |

**Interpretation:** registry exposes concrete `grammar` **component** and octagram **module**. Not proof that any model file loads, ranks better, or is extension-memory-safe.

---

## Residuals（M-03）

| Residual ID | Description | Owner | Disposition | Pointer |
|---|---|---|---|---|
| `Q-G1-01` | Stale GPLv3 file-header residual | Product / RIME Platform | `accept` | provenance audit; notice |
| `Q-G1-02` | Plugin DT 15.0 vs app 26.4 | Architecture / RIME Platform | `accept` | artifact contract |
| `Q-G1-03` | Keyboard force-load glog with octagram | RIME Platform | `accept` | `project.pbxproj` |
| `Q-G1-04` | Jetsam/size under force-load + future model unmeasured | Quality / TD-012 G4 | `tech_debt:TD-012` | parent TD-012 |
| `Q-G1-05` | Model pin/deploy/schema/UX/ranking | Product / TD-012 G2+ | `tech_debt:TD-012` | Assignment non-goals |

No residual uses disposition `fix` as a G1 blocker.

---

## Finding counts

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 (Q-G1-04 deferred to G2, not G1 defect) |
| P3 | 3 accepted hygiene residuals |

---

## Next

- Architecture Conditional Accept is filed separately; both required for Assignment `Reviewed` / `Closed`.  
- Product must not authorize `.gram` productization without a new PD.  
- Before model G2: measured extension memory / Jetsam plan (Q-G1-04).

`SUMMARY_DECISION=Conditional Accept`
