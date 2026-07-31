# T9-RESPONSIVE-PIPELINE-001 / R5-Preflight design

**Status:** `Active — Architecture design freeze for R5-Preflight`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Product:** R5-Preflight authorized 2026-07-31  
**Predecessor:** R4-Wire `be4c4ac`  
**ADR 0025:** remains **Proposed**

---

## 1. Boundary

### In scope

Prepare **controlled device preflight** for dual-gate thread-affine path:

| Mechanism | Release | DEBUG / preflight arm |
|---|---|---|
| Dual-gate default | **off** | off unless armed |
| App Group key `uk.t9resp.preflight.dualGate` | ignored | if `true`, arm dual-gate |
| Compile flag `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | never in project defaults | internal arm like auto-anchor B arms |
| Bootstrap | n/a | `ThreadAffineRimeEngineImplBootstrap` from pending runtime dirs |
| Logs | none for this feature | content-free `T9RESP` markers |

### Out of scope

- Formal R5 A/B Product conclusion;
- ADR Accept / Product Gate / Release default-on;
- Main App settings UI;
- Auto-anchor expansion.

---

## 2. Frozen decisions

### D1 — Arm resolution (fail closed)

```text
Release build → never arm dual-gate from UserDefaults
DEBUG or T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED:
  dualGate = UserDefaults(app group).bool(uk.t9resp.preflight.dualGate)
            OR compile flag ENABLED
  if dualGate && runtimeDirs known:
    install bootstrap + responsive=true + threadAffine=true
    rebuild
    log T9RESP path=thread-affine
  else if dualGate && no dirs:
    log T9RESP path=fallback-missing-runtime dualGate=requested
    keep ADR 0004 / existing deferred startup
  else:
    existing MainActor RimeEngineImpl path (unchanged)
```

### D2 — No dual live MainActor session when armed

When dual-gate arms successfully:

- Do **not** install `RimeEngineImpl` as `controller.rimeEngine` on MainActor.
- Session engine exists only via bootstrap on owner thread.
- `typoCorrectionCandidateQuery` uses non-session adapter (CandidateProvider-based)
  for this preflight arm (explicit residual: real sidecar typo not claimed).

### D3 — Content-free log grammar

Examples (allowed):

```text
T9RESP marker=PATH path=thread-affine fixture=T9RESP-R5P dualGate=on
T9RESP marker=PATH path=sync fixture=T9RESP-R5P dualGate=off
T9RESP marker=PUBLISH fixture=T9RESP-R5P epoch=1 rev=3
T9RESP marker=FALLBACK reason=missing-runtime dualGate=requested
```

Forbidden in these markers: raw keys, pinyin, candidate text, host document text.

### D4 — Operator prep (Human)

To arm on a DEBUG device/Simulator with App Group:

```bash
# Example only — suite name is the app group id
defaults write group.com.DoubleShy0N.Universe-Keyboard uk.t9resp.preflight.dualGate -bool true
```

Or build with `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED=1` injected like auto-anchor B arms.

Disarm: set key `false` / omit compile flag. Release archives ignore the key.

---

## 3. Evidence

- Unit tests: default off; arm resolution pure function; no Release arm.
- Code review: no project-level ENABLED flag in shared schemes by default.
- Optional device: Human exports content-free logs after arming.

---

## 4. Explicit non-claims

Subjective non-stutter, formal R5 Pass, ADR Accept, Product Gate, jetsam SLO.
