# Grok Handoff: TYPO-CORRECTION-002 controller/sidecar runtime integration

**Handoff status:** Ready for Grok to prepare a *new* implementation Assignment
and Authorization. This handoff does **not** authorize source changes, tests,
RIME actions, capture, commit, push, PR, merge or Release.

## 1. Current authoritative state

| Item | Exact value |
|---|---|
| Design Assignment | [`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-001`](../assignments/typo-correction-002-runtime-integration-design-001.md), `Reviewed` |
| Reviewed design | [`runtime integration design`](../plans/typo-correction-002-runtime-integration-design-2026-09-21.md) |
| Design SHA-256 | `b91e11cf327f9ad3e5974ff0e5b4a53fe755920356927efffed12cfe9c28a848` |
| Primary Architecture review | [`review`](../reviews/typo-correction-002-runtime-integration-design-architecture-review-2026-09-21.md) — `Conditional Accept` |
| Architecture re-review | [`re-review`](../reviews/typo-correction-002-runtime-integration-design-architecture-rereview-2026-09-21.md) — `Conditional Accept` |
| Re-review Authorization | [`AUTH … REREVIEW-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-DESIGN-ARCHITECTURE-REREVIEW-001.md), consumed |
| Parent | `TYPO-CORRECTION-002` remains Active; no Product/Quality/Release Gate is closed |

`Conditional Accept` here means the design is coherent enough to define a future
implementation package. It does **not** mean that runtime behavior is approved,
tested or ready to publish.

## 2. Preserve the exact pure-Core checkpoint

The reviewed preflight foundation is an **uncommitted**, isolated source snapshot:

| Field | Value |
|---|---|
| Worktree | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-runtime-preflight-implementation-001/Universe Keyboard` |
| HEAD | `4d1050f4b677494e06448cb40a83ef2da46d7b27` |
| Tree | `5f864a6f6f139810ed59c7e00ab6c33caad7e500` |
| Exact uncommitted diff SHA-256 | `8bb105c5381feb43fc41ec168fd239fd7c864cc0efa739cae3976beb685ebbab` |
| Changed paths only | `ContextualTypoCorrection.swift`, `TypoCorrectionRecallPreflight.swift`, `TypoCorrectionRecallPreflightTests.swift` under `Packages/KeyboardCore/` |

This snapshot contains only the pure-Core structural selector, operation-private
GroupID registry, budget separation and ledger contract. It is **not wired** to
the controller or production RIME sidecar. Do not reset, clean, overwrite or
silently absorb it into another dirty worktree. Before any future work, re-run:

```bash
git rev-parse HEAD HEAD^{tree}
git diff --name-only
git diff | shasum -a 256
```

Any mismatch invalidates this handoff's checkpoint identity and needs Product /
Architecture revalidation.

## 3. Non-negotiable runtime contract

Grok's future implementation must preserve all of the following:

1. `KeyboardViewController` owns one MainActor recall-operation lifecycle. It
   owns pending debounce work, operation token, `recallEpoch`, cancellation and
   candidate-bar refresh.
2. `recallEpoch` is authoritative on every route. Increment it **before** a
   composition mutation, page/mode change, visibility teardown, engine rebind /
   recovery or correction disable. Native/session epochs are optional
   route-local observations that may fail a fence but never replace it.
3. Use one `TypoCorrectionSidecarOwner`-style adapter over the already-installed
   query facade. Do not cast through to a raw engine, construct a second RIME
   session, use `Task.detached`, add a parallel query lane or invent a native
   epoch for default `RimeEngineImpl`.
4. One synchronous sidecar query occupies one scheduler turn. After it returns,
   schedule at most one later attempt with `RunLoop.main.perform(inModes:
   [.default])`; never synchronously loop into the next query from the return
   stack. This gives already-serviced invalidations an opportunity to run; it
   does not claim to interrupt an already-started call or input not yet on the
   run loop.
5. Fence before each query, after each return, before final Core apply and before
   candidate-bar refresh. A stale/cancelled/empty/budget-stop outcome is display
   no-op and must never start a later query.
6. Stage one and stage two produce in-memory material under one operation
   identity. They do not write `state.typoCorrection` while running. Exactly one
   conditional Core apply joins material, deduplicates across stages, performs
   normal-top suppression/ranking once, and writes the display state once.
7. The sidecar result is display-only. Do not call `TextInputClient`,
   `insertText`, `setMarkedText`, pasteboard, live RIME candidate selection or
   direct candidate-bar mutation. Existing user selection through Core remains
   the sole host-commit path.
8. Routine diagnostics remain content-free and non-blocking. Do not reuse the
   DEBUG decision trace; do not record composition, corrected input, candidate
   text, host context, clipboard, text hashes or durable GroupID maps.

## 4. What must be authorized before implementation

Do not infer this authority from the design or this handoff. Ask Product to
create a new bounded Assignment (suggested identity:
`TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001`) and matching
Authorization that explicitly names **Grok** as Executor and supplies:

- the exact starting checkpoint/worktree and whether the uncommitted pure-Core
  snapshot may be retained, committed, or transferred;
- the coverage-deficit predicate and production values for selected groups,
  query attempts, per-query limit and accepted display-result cap;
- the allowed production/test paths after a fresh source preflight;
- the exact adapter API boundary for default, MainActor-responsive and
  thread-affine paths;
- required focused/Core/RimeBridge/app tests and an independent Architecture
  review after implementation;
- explicit decision whether diagnostics/privacy receipt is in or out of scope.

If any of these is `UNKNOWN`, do not start source work.

## 5. Required future proof, kept separate

| Lane | Needed later | Not supplied by this handoff |
|---|---|---|
| Implementation | Swift formatting and CI-equivalent tests for actual changed paths | No source change or test result |
| Architecture | Independent implementation re-review proving adapter/fences/material apply | No implementation review |
| Real RIME | New provenance-bound Run ID and raw-artifact receipt | No RIME call/deployment |
| QA-001 / INT-003 | New separately authorized human interaction runs | No candidate/interaction conclusion |
| Paired performance | Dedicated paired plan and comparable run | No `180 ms` or latency claim |
| Diagnostics/privacy | Separate authorization and privacy review for any operation receipt | No telemetry change |

Do not use `FakeCandidateProvider` or an old Ice directory as real-RIME proof.

## 6. Grok startup sequence

1. Read `AGENTS.md`, `docs/KNOWLEDGE_INDEX.md`, `docs/ACTIVE_WORK.md`, this
   handoff and the two Architecture reviews.
2. Verify the pure-Core checkpoint identities above without changing it.
3. Obtain the new Product Assignment/Authorization described in section 4.
4. Only then inspect the exact production call entries and propose or implement
   the bounded adapter/coordinator/material changes inside the approved paths.
5. Stop after implementation evidence for independent Architecture/Quality
   review; do not commit, push, PR, merge or run device evidence unless later
   authority explicitly permits each action.

## 7. Explicit non-claims

No Swift/runtime behavior changed in this Codex handoff lane. No RIME query,
deployment, test, build, Simulator/device capture, QA-001, INT-003, performance
result, Product/Quality/Release Gate, commit, push, PR, merge, TestFlight,
Release or Assignment Close is claimed.
