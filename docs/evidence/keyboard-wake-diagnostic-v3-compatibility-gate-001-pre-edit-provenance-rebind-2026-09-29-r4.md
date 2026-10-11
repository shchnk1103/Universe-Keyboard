# V3 Compatibility Gate — Pre-Edit Provenance Rebind R4

## Scope and identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Current Assignment SHA-256: `18bbe05e953d71c0189b08985ecdb5194c8986ab26f1f758fe450a40e3c80a14`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Source base and candidate worktree `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Candidate branch: `codex/keyboard-wake-v3-compatibility-gate`
- Original source provenance SHA-256: `ab43646343ae77ec014f2d405869eeb2beaef9cd350077acd1a42a9bdf38a1d4` (captured against Assignment SHA `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`).
- Prior lifecycle rebind SHA-256: `d6b04fe2a3cc848c2b776680a1819ae01bd96ccaf8844d991290db506fd25ec9` (captured against Assignment SHA `d2d254dea05ec8fbadc8b7ff783b429e9097a5013877482b3440cfd79989f0f5`).

This record rebinds the existing provenance to the current Assignment after the coordinator added only review-history and next-review references for the incomplete Architecture R3 round and the planned R4 reviews. The accepted objective, product contract, source base, allowed source/test paths, predecessor input identities, validation matrix, and authority exclusions are unchanged. It supersedes the Assignment binding in the two older provenance records for pre-edit entry purposes; those historical snapshots are preserved unchanged.

## Current source/base status

The current worktree is `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`. The source/test `HEAD` is the exact required base. A fresh `git diff --name-only` was empty before source edits, and all 15 current-base source/test hashes in the [original provenance record](keyboard-wake-diagnostic-v3-compatibility-gate-001-pre-edit-provenance-2026-09-29.md) were recomputed and matched. No tracked implementation file has been changed.

## Historical input identity revalidation

| Input | Exact identity checked | Result |
|---|---|---|
| Runtime API | `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` | All 10 entries in the retained source/test manifest rehashed with zero mismatches; predecessor `HEAD` remains `9eb83158e49218c1e8f75dbe7dd9e0390db81409`. |
| KeyboardCore reader | `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` | Five-file aggregate recomputed in the retained `keyboard-wake-diagnostics` worktree; predecessor `HEAD` remains `9eb83158…`. |
| Main App consumer | `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a` | Two-file source/test aggregate recomputed in the retained `keyboard-wake-diagnostics` worktree; predecessor `HEAD` remains `9eb83158…`. |
| Extension instrumentation | `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d` | Exact five-file binary diff digest recomputed in the retained `keyboard-wake-diagnostics` worktree against `9eb83158…`. |

These are historical identities only. The Runtime API's writer-version mismatch still must be reconciled to production schema v5. The old Extension patch's production marker call sites must not be copied. The reader and Main App candidates must be integrated and validated against the current base. Both predecessor worktrees remain dirty, preserved, and read-only for this task.

## Entry applicability and limits

- The provenance applies to this Assignment because the R4 revision adds review/receipt history only; all allowed source/test identities and historical input digests are unchanged.
- Entry Criterion 2's exact-base and historical-input provenance is satisfied before source edits. The integrated source/test manifest remains an Exit deliverable.
- Exclusive writer/process ownership of the new worktree is **not claimed here** and must be checked immediately before editing.
- No code was edited; no tests, formatting, builds, Simulator operations, installation, network access, production marker emission, root-cause conclusion, Gate, Release, or parent closure occurred.
