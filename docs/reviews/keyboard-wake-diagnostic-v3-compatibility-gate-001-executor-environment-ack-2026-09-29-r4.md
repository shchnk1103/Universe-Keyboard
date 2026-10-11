# Executor and Environment Executor ACK — V3 Compatibility Gate R4 Rebind

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `18bbe05e953d71c0189b08985ecdb5194c8986ab26f1f758fe450a40e3c80a14`
- Exact base / worktree `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Roles: Executor and Environment Executor — current Codex task
- Disposition: **ACK with conditions**

## Acknowledgment

The Executor accepts the bounded local candidate scope: revalidate and integrate the reviewed inputs against the exact base; preserve current schema-v5 production behavior; keep production keyboard-wake marker emission disabled; use v4 marker data only in isolated fixtures; and preserve the dirty primary checkout and both predecessor worktrees.

The Environment Executor may perform host-side checks after the Stage A Entry Criteria are met. Immediately before the first source edit, the Executor will recheck exact base, source/test baseline, and absence of another writer or process owning this worktree. Simulator-backed validation remains prohibited until a fresh exclusive reservation records one exact device model, iOS runtime, and UDID; all Stage B Simulator commands must use that same UDID.

## Evidence boundary

This ACK does not claim source integration, tests/builds, Simulator validation, installation, runtime diagnosis, Ready, Gate, Release, or parent closure. Installation, manual Maps reproduction, commit, push, PR, merge, TestFlight, and Release remain excluded.
