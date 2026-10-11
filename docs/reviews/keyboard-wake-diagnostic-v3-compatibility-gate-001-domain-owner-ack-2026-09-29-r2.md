# Domain Owner ACK R2 — V3 Compatibility Gate

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Exact base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Proposal addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- Role: Keyboard Experience Maintainer
- Disposition: **ACK with conditions**

## Domain findings

- Current production diagnostics remain schema v5, including `typo_recall`; the Extension must not add a new production wake-marker call site for this candidate.
- Lifecycle instrumentation remains limited to actual Extension callbacks and existing RIME-resume call boundaries. The absence of `host_did_become_active` must not be filled by inference.
- Proxy boundaries remain `insertText`, `setMarkedText`, and `unmarkText`. A returned call does not prove host insertion or display.
- Any v4 wake-marker payload used for compatibility testing must stay in temporary or in-memory isolated fixtures, outside production App Group storage, `DiagnosticsJournalRuntime`, and real Extension ingress.
- Preserve current-main recall invalidation, sidecar wiring, and key-title changes. Do not overwrite them with the historical Extension patch.
- Cross-domain handoffs to Input Intelligence and App & Data Operations remain appropriate. RIME internal session/schema state must not be inferred in the Extension.

## Conditions and stop boundary

Architecture R2, Quality R2, and exact-candidate review remain separate gates; this ACK does not advance the lifecycle or authorize implementation by itself. Stop and re-escalate if work changes the current v5 writer, `typo_recall`, fallback contract, capture policy, or input/session behavior, or if it needs production marker emission.

## Evidence boundary

The reviewer read the exact Assignment, addenda, R1 review records, and relevant current source by read-only inspection. No files were modified; no code, tests, formatting, builds, Simulator operations, installation, network access, or root-cause conclusion occurred. The reviewer reported four batched read-only calls and twelve read-only shell subcommands. The reviewer did not write this receipt; the coordinator recorded it from the final response.
