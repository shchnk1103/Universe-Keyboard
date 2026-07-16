# KEYBOARD-LAYOUT-9KEY-001 — Implementation Handoff

Prepared by: Grok (Executor)

Date: 2026-07-16 Asia/Shanghai

Branch: `feature/keyboard-layout-9key-spike`

## Gate status (read this first)

| Gate | Status |
|---|---|
| **Implementation / code-review gate** | **Approved** — `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-3.md` |
| **Product Gate / Assignment completion** | **Open** — interactive simulator/device evidence or explicit Product Lead waiver still required |

This handoff must **not** be read as final product acceptance.

Still required before Product Gate:

1. Interactive simulator or physical-device proof: switch 26/9-key, thumbnails, digit input, candidates, deletion, space/return, persistence, hide/show, recovery, fallback UX.
2. Light/dark compact screenshot evidence, **or** explicit Product Lead waiver.
3. Product Lead decision on remaining Human Dependency evidence.

Codex review documents (immutable; do not rewrite):

- `docs/evidence/keyboard-layout-9key-001-codex-implementation-review.md`
- `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview.md`
- `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-2.md`
- `docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-3.md` (**Code Review Approved**)

Gate authorization for Active implementation: `docs/evidence/keyboard-layout-9key-001-codex-rereview-2.md`

## Assignment lifecycle

| Field | Value |
|---|---|
| Assignment | `docs/assignments/keyboard-layout-9key-001.md` |
| Lifecycle | **`Active`** (implementation code-review closed; Product Gate open) |
| Product Decision | `PD-KEYBOARD-LAYOUT-9KEY-001` |
| ADR | `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md` |

---

## Codex re-review 3 — result

**Code Review Approved — no blocking implementation findings.**

Closed in re-review 2 and confirmed in re-review 3:

- Fail-closed publish on resume init/session failure, resume schema-selection failure, recovery session-recreation failure.
- Every realized/fail-closed publication updates `runtimeSelection` and fires `onRuntimeSelectionChanged`.
- Extension wires the callback at engine create; chrome + `usesT9InputSemantics` + grid reload move together.
- Controller synchronizes semantics after resume and in-place recovery.
- `RealizedSelectionLifecycleTests` cover the four required lifecycle cases plus controller rebuild path.
- Production enable orchestrator, T9 custom-YAML plan/sync, and handoff whitespace remain closed.

---

## Implementation closure map (summary)

### Realized selection / fail-closed (P1)

| Item | Detail |
|---|---|
| Reconcile | `RimeRuntimeSelection.reconciled(withActualSchemaID:)` + `.surface` |
| Engine | `RimeEngineImpl.applyRealizedSelection` / `publishFailClosedSelection` / `onRuntimeSelectionChanged` |
| Extension | Callback at create; apply after resume/settings; reload on layout change |
| Controller | `applyRealizedSelectionFromEngine()` after resume and rebuild recovery |
| Tests | `RealizedSelectionLifecycleTests` (5); reconcile unit tests |

### Enable transaction (P2)

| Item | Detail |
|---|---|
| Production | `NineKeyEnableOrchestrator` + `SchemaManager.enableNineKeyLayout()` |
| Tests | `NineKeyEnableTransactionTests` — order + prepare/deploy/smoke/fingerprint fail-closed |

### `t9.custom.yaml` (P2)

| Item | Detail |
|---|---|
| Production | `planSchemaCustomYamlFiles` → `syncCustomYamlFiles` (t9 only when ice installed; ice dict preference) |
| Tests | plan + filesystem write coverage in `RimeRuntimeSelectionBridgeTests` |

---

## Automated verification (Codex re-review 3)

| Suite | Result |
|---|---|
| `swift test --package-path Packages/KeyboardCore` | **594 / 0** |
| Full `Universe Keyboard` scheme | **UniverseKeyboardTests 115 + KeyboardTests 6 / 0** |
| Full `RimeBridgeTests` scheme | **31 / 0** (3 fixture-dependent skips) |
| Release simulator build, signing disabled | **BUILD SUCCEEDED** |
| Whitespace `git diff --check HEAD` / staged | **PASS** |

Prior focused T9 Spike fixture (when env injected): librime 1.16.1, `schema=t9`, raw `64`, 9 candidates, delete → `6`.

---

## Simulator / physical-device evidence (Product Gate — open)

| Item | Status |
|---|---|
| Interactive main-app enable UI (thumbnails, failure copy, persisted selection) | **Not captured** — Human Dependency |
| Extension E2E: cold start / hide-show / recovery / CN-EN / Space-Return-Delete | **Not executed** — Human Dependency |
| Physical device | **Not executed** — Human Product Owner |
| Light/dark compact screenshots | **Not produced** — or Product Lead waiver |

---

## Residual risks (honest)

1. Enable path briefly forces 26-key during deploy (fail-closed by design).
2. Rate-limited recovery early-return does not re-publish; last published selection remains source of truth.
3. Essay read-only warnings may still appear in deploy logs.
4. Pre-existing duplicate runtime-class warnings in main-App test host are unrelated baseline noise.

---

## Next steps (not Product Gate close)

1. Keep Assignment **`Active`** until Product Gate evidence or explicit waiver.
2. Human Product Owner / Product Lead: collect interactive simulator/device evidence or record a waiver.
3. Do **not** mark Assignment complete or claim Product Gate from automated green alone.
