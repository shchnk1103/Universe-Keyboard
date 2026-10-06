# Keyboard Experience Domain Owner ACK — V3 Compatibility Gate R4 Rebind

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `18bbe05e953d71c0189b08985ecdb5194c8986ab26f1f758fe450a40e3c80a14`
- Exact base / worktree `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Role: Keyboard Experience Maintainer — Domain Owner
- Disposition: **ACK with conditions**

## Acknowledgment

The Domain Owner confirms that the Extension lifecycle and proxy-diagnostic scope preserves current-main behavior and schema-v5 events, including `typo_recall`. New keyboard-wake markers remain producer-off in production; v4 marker payloads are restricted to isolated temporary or in-memory fixtures. The Extension does not own RIME deployment, and KeyboardCore and Main App semantics remain with their named domain consultants.

The Assignment does not change normal input/session behavior, privacy boundaries, the existing v5 writer, or legacy-fallback semantics. Installation, manual Maps reproduction, publication, Gate, Release, and parent closure remain outside this Assignment.

## Evidence boundary

This ACK is bound to the exact Assignment scope identity above. It does not claim implementation, tests, Simulator behavior, a root cause, Ready, or Gate. Stage B still requires a fresh exclusive reservation for one exact Simulator model, runtime, and UDID.
