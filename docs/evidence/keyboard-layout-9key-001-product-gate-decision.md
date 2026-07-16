# KEYBOARD-LAYOUT-9KEY-001 — Product Gate Decision

**Decision type:** Product Gate / Assignment acceptance
**Decision ID:** `PG-KEYBOARD-LAYOUT-9KEY-001`
**Date / timezone:** `2026-07-16 Asia/Shanghai`
**Role:** 🧭 Product Lead (virtual engineering team; KOS 2.0 Assignment Policy)
**Assignment:** [`docs/assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md)
**Product Decision Source:** [`PD-KEYBOARD-LAYOUT-9KEY-001`](../product-decisions/KEYBOARD-LAYOUT-9KEY-001-authorization.md)

## Authority

Per `docs/ASSIGNMENT_POLICY.md`:

- **Product Lead** retains Product Gate and acceptance authority.
- **Human Product Owner** is a **Human Dependency** for physical-device operation and capture of interactive evidence — not the Product Lead role.
- This decision is issued by Product Lead after independent Architecture/Quality code-review conclusions and review of the human-supplied device evidence package.

Conversation history is not authority. This file is the repository Product Gate record for KEYBOARD-LAYOUT-9KEY-001.

## Inputs reviewed

| Input | Path / identity | Conclusion used |
|---|---|---|
| Product Decision | `PD-KEYBOARD-LAYOUT-9KEY-001` | Scope authorization for plan execution |
| ADR 0018 | `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md` | Binding layout / T9 / fail-closed contract |
| Architecture + Quality code review | `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-3.md` | **Code Review Approved** — no blocking implementation findings |
| Implementation handoff | `docs/evidence/keyboard-layout-9key-001-implementation-handoff.md` | Automated verification + residual risks |
| Device evidence package | `docs/evidence/keyboard-layout-9key-001/product-gate/20260716-device/` | Interactive / physical-device proof |
| Device package index | `…/20260716-device/meta.md` | Screenshot index + operator notes |
| Implementation commit | `5a1c407` | Code under review + device build lineage |

## Product Gate verdict

### **PASS — accepted**

Product Lead **accepts** KEYBOARD-LAYOUT-9KEY-001 for product completion of V1 scope under ADR 0018.

### What is accepted

1. **Main App layout UX:** 26-key / 9-key cards, character-free thumbnails, light/dark, selection persistence to settings subtitle, enable state “九键已启用”.
2. **Extension nine-key chrome:** Chinese letter page shows 1–9 + letter legends when layout is nine-key and T9 ready.
3. **T9 input semantics (device-proven):**
   - digit path yields non-empty candidates and readable preedit (`ni` for `64`);
   - candidate selection commits Hanzi (e.g. `你`);
   - host field does not retain raw digit dumps such as `64` / `64426` on the return/commit path observed;
   - English remains 26-key QWERTY under nine-key layout preference;
   - hide/show reopen retains nine-key chrome.
4. **Code-review gate already closed** by Codex; Product Gate does not re-open architecture findings closed in re-review 3.
5. **Automated evidence** previously green under Codex (KeyboardCore 594, main-app + RimeBridge schemes, Release build).

### Explicit non-blocking residuals (accepted with risk)

| Residual | Product Lead disposition |
|---|---|
| No dedicated T4 “BackSpace reduces one digit” screenshot | **Accepted residual** — Spike + code path already prove delete; operator reported no defect. Not a Product Gate blocker. |
| Full failure-matrix device shots (uninstall ice mid-nine-key, network deploy fail UX) | **Accepted residual for V1** — fail-closed contract is code-reviewed and unit-tested; not required for this Gate when core happy path is device-proven. |
| Candidate ranking not fixed | **Out of scope** per plan. |
| Pre-existing main-app test duplicate-class warnings | **Baseline noise** — not attributed to this feature. |

### Not claimed

- App Store release readiness of the whole product.
- English nine-key / multi-tap / swipe letter selection.
- Live cross-process layout hot-switch while keyboard stays visible.
- Librime vendor upgrade.

## Assignment lifecycle decision

| From | To | Effective |
|---|---|---|
| `Active` | `Completed` | Executor outputs + evidence delivered |
| `Completed` | `Reviewed` | Codex code-review + Product Gate conclusions both recorded |
| `Reviewed` | **`Closed`** | Product Gate **PASS**; handoff complete |

## Human Dependency closure

| Dependency | Status |
|---|---|
| Human Product Owner — physical-device operation, host acceptance capture | **Satisfied** via `product-gate/20260716-device/` (iPhone 13 Pro, iOS 27 beta 3, Full Access On) |
| Final Product Gate decision | **Satisfied by this Product Lead decision** — Human Dependency does not equal Product Lead |

## Required follow-ups (non-gating)

1. Keep Codex review artifacts immutable.
2. Optional: CHANGELOG / domain doc polish if not already covered by implementation commits.
3. Any English nine-key or librime upgrade requires a **new** Product Decision + Assignment.

## Signature (role)

**Product Lead** — Product Gate **PASS** for KEYBOARD-LAYOUT-9KEY-001 on `2026-07-16 Asia/Shanghai`.
Assignment may be marked **`Closed`**.
