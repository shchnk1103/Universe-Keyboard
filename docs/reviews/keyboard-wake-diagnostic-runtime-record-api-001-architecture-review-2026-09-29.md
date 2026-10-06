# Architecture Review: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001

> **S-03 — Superseded for current ADR status:** The review-time statement below that ADR 0036 remained Proposed is historical. Human Architecture Authority and Product Lead conditionally accepted ADR 0036 on 2026-09-29; see [acceptance decision](../product-decisions/ADR-0036-ACCEPT-authorization.md). This review remains bound to its listed pre-acceptance candidate hashes and does not authorize implementation.

## Disposition

**ACKNOWLEDGED — Pass with conditions** for the exact documentation candidates listed below. This is an independent Architecture Reviewer conclusion; it is not Human Architecture Authority acceptance of ADR 0036.

## Candidate identity

| Document | SHA-256 |
|---|---|
| ADR 0036 | `c27c7e0de34f28a504d467ca4bfd7443e6bab5dd79140931bc5d281b385bf9a0` |
| Runtime Record API Assignment | `412004c39cab3239fa3a174dab0a38106c26e52fadc47f478b198de771469a92` |
| Product Decision | `af287c90c9607223bcdebbdafe7da112f91cc56f71179d22e7c6fff06ecbaf74` |
| Extension Producer Reassigned record | `d375fb41db63d97696e4382a12d1b8ce89efec4c90b8a70725078d3d9b46818c` |

## Findings

- A v4 build labels every newly written event as v4, including events that reuse existing codes.
- Persisted v3 history remains v3 and is never rewritten in place.
- A v3 writer emits new events as v3 and rejects or omits v4-only codes/payloads.
- Mixed v3/v4 history is interpreted only by an explicitly version-aware v4 reader; a v3 reader cannot establish that v4 records are absent.
- The Product Decision, ADR 0036 and Runtime Assignment express the same version contract.
- The proposal preserves ADR 0027's `Diagnostics/v1` layout, journal ownership, retention, locks, privacy, capture gates and bounded asynchronous hot-path boundary.
- Extension call-site wiring is Reassigned to a future paired-build rollout Assignment. The successor has not been issued or authorized; no v4 emission is claimed.
- Dirty KeyboardCore writer/test files, exact identity checks and writer ownership revalidation remain explicit blockers before Ready.

## Conditions

1. ADR 0036 remains **Proposed**. Its Architecture review result does not equal formal ADR acceptance.
2. Runtime implementation requires Domain Owner and Executor exact-scope acknowledgments, formal ADR acceptance, separate implementation authorization, and a fresh source/test freeze with exclusive writer ownership.
3. The future paired-build rollout must bind one Main App + Keyboard Extension build and prove strict validation, incomplete/unsupported status and legacy-fallback suppression on that exact candidate.
4. The Reassigned Extension record's historical responsibility table is not a binding for its future successor.

## Non-claims

No source code, tests, build, Simulator, install, runtime event production, Product Gate, Quality Gate, Release decision or parent closure was performed or accepted by this review.
