# KEYBOARD-LAYOUT-9KEY-001 — Implementation Handoff

Prepared by: Grok (Executor)
Product Gate closed by: Product Lead (`PG-KEYBOARD-LAYOUT-9KEY-001`)

Date: 2026-07-16 Asia/Shanghai
Branch: `feature/keyboard-layout-9key-spike`

## Gate status (final)

| Gate | Status |
|---|---|
| **Implementation / code-review gate** | **Approved** — `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-3.md` |
| **Product Gate** | **PASS** — `docs/evidence/keyboard-layout-9key-001-product-gate-decision.md` |
| **Assignment lifecycle** | **`Closed`** — `docs/assignments/keyboard-layout-9key-001.md` |

Device evidence: `docs/evidence/keyboard-layout-9key-001/product-gate/20260716-device/`
(iPhone 13 Pro, iOS 27 beta 3, Full Access On, commit lineage `5a1c407`)

## Role clarification (KOS 2.0)

| Role | Who | Duty for this task |
|---|---|---|
| Product Lead | Virtual Product Lead (Assignment Policy) | Product Gate + Assignment close |
| Human Product Owner | Human | Human Dependency: operate device, capture screenshots |
| Executor | Grok | Implementation + automated evidence |
| Architecture / Quality | Codex | Code-review gate (immutable reviews) |

Human Product Owner is **not** Product Lead and does not issue Product Gate verdicts.

## Immutable Codex reviews

- `docs/evidence/keyboard-layout-9key-001-codex-implementation-review.md`
- `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview.md`
- `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-2.md`
- `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-3.md`

## Automated verification (Codex re-review 3)

| Suite | Result |
|---|---|
| KeyboardCore full | 594 / 0 |
| Universe Keyboard scheme | UniverseKeyboardTests 115 + KeyboardTests 6 / 0 |
| RimeBridgeTests full | 31 / 0 (3 fixture skips) |
| Release simulator build | BUILD SUCCEEDED |

## Device evidence (Product Gate)

See `product-gate/20260716-device/meta.md` for full index. Core input shots:

- `T2-64-candidates.PNG` — preedit `ni` + candidates
- `T3-commit-hanzi.PNG` — committed `你`
- `T7-return-no-raw.PNG` — host text `你好` (no raw digit dump)
- `T9-english-qwerty.PNG` — English QWERTY
- `L1-reopen.PNG` — nine-key after reopen

## Residual risks accepted by Product Lead

Documented in `PG-KEYBOARD-LAYOUT-9KEY-001` (T4 screenshot gap; full failure-path device matrix not photographed). Non-blocking for V1 close.
