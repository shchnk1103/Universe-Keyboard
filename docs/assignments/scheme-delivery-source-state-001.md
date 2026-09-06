# Assignment: SCHEME-DELIVERY-SOURCE-STATE-001

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current Phase | Pinned Rime Ice artifact verification and scheme-scoped failure repair |
| Material non-claims | No TestFlight/App Release, no device acceptance, no disabled integrity check |
| Next handoff / decision | Independent review and local/hosted checks, then Human device and merge decisions |
| Residuals | Device retest pending |

## Authority and scope

Human Product Owner / Assignment Authority approved the proposed source-pin, probe-classification and per-scheme failure fixes in the current conversation: “你的建议比较合理，继续吧” (2026-09-06 Asia/Shanghai).

Scope: repair mutable Rime Ice download artifact binding, distinguish unreachable sources from changed artifacts, record bounded per-source failures, bind error display/retry to stable scheme ID; regression tests and documentation. Main-App deployment ownership, archive/digest/staged checks, cancellation and commit lease remain intact. No unrelated product changes, automatic TestFlight, merge or device actions.

Governance baseline: KOS v0.7.0 advisory, Kit f7f4dad6750b59dc827c1366fcd276447b2820b2. Existing tasks remain pinned. This bounded Markdown Assignment is not added to advisory Envelope include; no invented historical authority fields.

## Responsibilities

- Domain Owner / Executor: Main App UI / current Codex executor.
- Environment Executor: current Codex executor, isolated clone and dedicated Simulator.
- UI worker: Ohm subagent, separate clone, per-scheme failure state only.
- Architecture Reviewer: independent read-only review subagent after implementation.
- Quality Reviewer: independent read-only review subagent after implementation.
- Human Dependency / Product Approver: Human Product Owner, physical-device download/switch-page retest and final merge acceptance.

## Gates

Inputs: user logs; current catalog/probe/UI; ADR 0001/0003/0006/0032; scheme management and diagnostic contracts; official dated artifacts.
Entry: explicit repair authorization, isolated baseline 4c9f424, proven HEAD length drift and unscoped UI failure.
Exit: exact source/digest/staged binding evidence; negative/fallback/cancel/UI regression tests; local strict CI-equivalent gates; independent review; human retest handoff.
Stop: unverified artifact origin, staged mismatch, unsafe fallback, source contract expansion, scope conflict or failed cleanup. Do not waive these to make tests green.
Handoff Target: Human Product Owner. Revalidate on artifact/pin, processing plan, schema identity, environment, evidence or scope change.
