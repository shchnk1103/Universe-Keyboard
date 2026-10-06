# Input Intelligence Consultation — V3 Compatibility Gate R4 Rebind

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `18bbe05e953d71c0189b08985ecdb5194c8986ab26f1f758fe450a40e3c80a14`
- Exact base / worktree `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Role: Input Intelligence Maintainer — required domain consultant
- Disposition: **ACK**

## Acknowledgment

The KeyboardCore event and typed-payload contract is bounded. Records are interpreted and validated by their own schema version (v3/v4/v5), mixed retained history is supported without rewriting records, and the production writer remains schema v5, including `typo_recall`. New wake-marker production emission remains disabled; v4 marker fixtures must use isolated temporary or in-memory storage.

Writer ingress remains bounded and asynchronous; keyboard input must not wait on encoding or persistence. The reader keeps strict raw-key validation and query-wide incomplete status through continuation. Only a known-complete empty v1 result can enable the legacy fallback; incomplete, unsupported, partial, unavailable, or rejected-only results suppress it. Duplicate JSON-member detection remains an explicit limitation unless separately implemented and tested.

## Evidence boundary

This consultation is bound to the exact Assignment scope identity above. No implementation, test/build, Simulator, root-cause, Ready, Gate, or Release conclusion is made.
