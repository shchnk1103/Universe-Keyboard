# Quality Review R1 — V3 Compatibility Gate

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256 reviewed: `f19ee343da3347c04f89fa0cf99bbf96c9e82d4b94fc16fdd3d56260fff38245`
- Quality packet SHA-256: `85d838c732465bd5a41f946b759b7055b374fd55da178c065f7e45d6e114d4ba`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- CI workflow SHA-256: `cb4a41108ba0e9268b04b1aaca8bd06480da3e0dd8706221acbbce3ad6a0a6a8`
- Exact base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Disposition: **Pass with conditions**

This was a validation-plan review. It is not an implementation-candidate review, test result, Quality Gate, runtime diagnosis, or Product Gate.

## Plan disposition

The Assignment covers all six current CI heavy jobs: strict Swift format, KeyboardCore, RimeBridge, App + Keyboard, signed Keychain integration, and Release build. The signed test has the required signing flags and exact selector. Stage A is separated from Stage B; Stage B requires one fresh exclusive Simulator reservation and a single exact UDID for all Simulator-backed commands.

The required candidate coverage includes v3/v4/v5 records and mixed histories, current v5 `typo_recall`, unsupported/non-integer versions, unknown codes and raw keys, malformed and mismatched payloads, continuation-wide incomplete propagation, and Main App fallback suppression. The existing Main App and historical candidate results are inputs only; they do not prove this candidate's behavior. The pinned RIME manifest/digest must be checked, and no predecessor test result may be claimed for the new candidate.

## Conditions to retain

1. Freeze a new source/test manifest after integration and add explicit v3/v4/v5 plus mixed-history fixtures.
2. Prove fallback suppression in the integrated candidate, including incomplete/unsupported states; historical consumer tests are not candidate evidence.
3. Recheck that this managed worktree is cleanly isolated and has one writer before source edits; preserve its pre-existing untracked input documents.
4. Record exact Simulator model, runtime, UDID, and fresh exclusive window before Stage B. A visible or Shutdown device is not a reservation.
5. Open a new numbered Architecture and Quality review round for the exact integrated candidate and evidence.

No validation target or packet expansion was missing from the plan.

## Evidence boundary

The reviewer verified packet, Assignment, Product Authorization, CI workflow, and base identities by read-only inspection. No files were modified; no tests, builds, Simulator operations, installation, network access, root-cause finding, behavior conclusion, Gate, Release, or parent closure occurred.

The reviewer reported 19 read-only command calls and approximately 1 minute 43 seconds of active review time, within the frozen lane limits. The reviewer did not write this receipt; the coordinator recorded it from the final response.
