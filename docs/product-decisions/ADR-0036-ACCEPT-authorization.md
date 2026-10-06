# Product Decision: ADR-0036-ACCEPT — 有条件接受 ADR 0036

**Decision ID:** `PD-ADR-0036-ACCEPT`
**Lifecycle status:** `Recorded — Human Architecture Authority + Product Lead accepted conditionally`
**Date / timezone:** `2026-09-29 Asia/Shanghai`
**Architecture target:** [ADR 0036](../architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md)
**Parent / Assignment:** [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](../assignments/keyboard-wake-lifecycle-diagnostics-001.md) · [Runtime Record API Assignment](../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md)

## Authority and reviewed identity

- **Decision makers:** Human Architecture Authority and Human Product Owner / Product Lead in the current Codex task.
- **Decision source:** In-session instruction on 2026-09-29 Asia/Shanghai: “有条件接受 ADR 0036（Architecture + Product）”.
- **Accepted ADR review candidate:** SHA-256 `c27c7e0de34f28a504d467ca4bfd7443e6bab5dd79140931bc5d281b385bf9a0`.
- **Accepted ADR final status-writeback file:** SHA-256 `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c`.
- **Architecture basis:** Independent review `ACKNOWLEDGED — Pass with conditions`, SHA-256 `89d6d99c2e1e9e12953cd687992445658ba21bc87c2dfd8a36b147937414725f`.
- **Quality basis:** Independent scope review `ACKNOWLEDGED`, SHA-256 `dc4e8590f3bfc0d7a6fae923b667b52ee5f20cb033c267b841468beb4937aa51`.
- **Domain Owner basis:** Exact-scope acknowledgment, SHA-256 `3238d3c2b08678cf1895e2a6866ab9141fdeafada54940c29b37c2a45f377468`.
- **Reviewed Runtime Assignment scope:** SHA-256 `412004c39cab3239fa3a174dab0a38106c26e52fadc47f478b198de771469a92`.
- **Product scope decision:** Original reviewed candidate SHA-256 `af287c90c9607223bcdebbdafe7da112f91cc56f71179d22e7c6fff06ecbaf74`.

The accepted contract is the ADR 0036 content reviewed at the identity above. The status and authorization writeback records this decision without changing the reviewed wire-version semantics.

## Bound decision

Human Architecture Authority and Human Product Owner / Product Lead **accept ADR 0036 conditionally** as the binding architecture contract for the v4-capable persisted event writer:

1. A v3 writer labels every newly written event as v3. A v4 writer labels every newly written event from that build as v4, including existing event codes.
2. Retained v3 history remains v3 and is never rewritten in place. A v4-only code or payload is never downgraded or encoded as v3.
3. Mixed v3/v4 history is interpreted only by a version-aware v4 reader that validates each record against its own version; a v3 reader cannot establish that v4 records are absent.
4. `Diagnostics/v1` layout, journal ownership, retention, locks, privacy, capture gates and bounded asynchronous hot-path behavior remain unchanged.
5. Extension v4 event emission stays disabled until a separate, explicitly authorized paired-build rollout proves the Main App and Keyboard Extension build identity together and validates strict version/code/payload/raw-key handling, controlled incomplete/unsupported status and legacy-fallback suppression.

## Conditional residuals

| Residual | Owner | Disposition | Required evidence / pointer |
|---|---|---|---|
| `ADR36-C1` — Runtime writer implementation still requires separate Product authorization, fresh source/test identities and exclusive writer ownership before `Ready` or implementation. | Product Lead and Runtime Record API Assignment | `fix` | [Runtime Record API Assignment](../assignments/keyboard-wake-diagnostic-runtime-record-api-001.md) Entry Criteria |
| `ADR36-C2` — Extension event emission and paired-build compatibility remain deferred; a future successor Assignment must bind its own roles and one exact Main App + Extension build. | Product Lead and future paired-build rollout Assignment | `fix` | [Extension producer Assignment](../assignments/keyboard-wake-diagnostic-extension-producer-001.md) and ADR 0036 § Follow-up Work |

These conditions preserve separate authorization and evidence gates; they do not weaken the accepted wire-version contract.

## Explicit non-authorization

This decision does **not** authorize source-code changes, implementation, tests, builds, Simulator or device operations, installation, v4 event emission, paired-build rollout, Product/Quality Gate, Release, commit, push, PR, merge or closure of the parent lifecycle Assignment. It does not establish a root cause or behavioral fix.

## Executor follow-through

| Action | Authorized? |
|---|---|
| Change ADR 0036 status to **Accepted (Conditional)** and record this decision | **Yes** |
| Synchronize Assignment and active-status mirrors under KOS M-02 | **Yes** |
| Begin Runtime Record API implementation or treat this ADR acceptance as its separate implementation authorization | **No** |
| Enable Extension v4 production or claim paired-build readiness | **No** |

## Pointers

- Acceptance evidence: [`../evidence/adr-0036-accept-2026-09-29.md`](../evidence/adr-0036-accept-2026-09-29.md)
- Prior v4 writer scope decision: [`KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001`](KEYBOARD-WAKE-DIAGNOSTIC-V4-WRITER-001-authorization.md)
- Architecture review: [`Runtime Record API Architecture review`](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-architecture-review-2026-09-29.md)
- Quality review: [`Runtime Record API Quality review`](../reviews/keyboard-wake-diagnostic-runtime-record-api-001-quality-review-2026-09-29.md)
