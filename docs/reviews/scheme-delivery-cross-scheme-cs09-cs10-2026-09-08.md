# Cross-scheme CS-09 / CS-10 delta review

Date: 2026-09-08 Asia/Shanghai. Independent read-only review of `d5dd9f2`
and follow-up assertions through `78e4a66`, relative to `81e6652`. The
reviewer did not modify files or rerun the full test suite.

Verdict: **Pass with conditions**. This is a manager-contract local candidate;
it does not close the Assignment or any Product, Device, ADR, merge,
TestFlight, or Release gate.

- CS-09 covers Ice-only and Wanxiang-only settings: Luna is the first and only
  runtime-smoke request, staging/commit succeeds, the target receipt clears,
  selection becomes Luna, and no installation path runs.
- CS-10 covers both retained-peer directions: after active uninstall, selecting
  the retained scheme produces the second deployment request for that scheme,
  deployment settings succeed, and no installation path runs.
- The candidate correctly limits its claim to `SchemaManager` state and a
  controlled deployment service. It does not establish a production installer
  inventory, actual RIME runtime smoke/candidate input, or physical-device
  behavior.

## Conditions and residual disposition

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| CS09-10-01 | Assignment executor | Fix or provide evidence in a separately authorized slice | Real installer file-inventory and peer-byte retention proof is not rerun by CS-09/10. |
| CS09-10-02 | Product / Device gate | Device evidence | Actual RIME runtime smoke and candidate input remain unproven by the controlled deployment service. |

Executor validation is recorded separately in the
[CS-09 / CS-10 evidence](../evidence/scheme-delivery-cross-scheme-cs09-cs10-2026-09-08.md): strict formatting/lint, focused tests, and the full App + Keyboard
run. It is executor evidence, not reviewer-run verification.
