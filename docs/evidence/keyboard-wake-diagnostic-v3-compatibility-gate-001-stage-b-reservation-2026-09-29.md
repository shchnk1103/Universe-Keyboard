# Stage B Simulator Reservation — V3 Compatibility Gate 001

- Work item: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Stage: B — CI-equivalent Simulator validation
- Reservation recorded: 2026-09-29 14:25:01 UTC / 2026-09-29 22:25:01 Asia/Shanghai
- Candidate branch: `codex/keyboard-wake-v3-compatibility-gate`
- Exact base / `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Source/test manifest SHA-256: `32d8a402f9a683348b6ef3395156112491d10aeead74ad61fb89e41d0d7edb7c`
- Assignment SHA-256 before lifecycle writeback: `5e9e32f025a8fbaf5493879441523e349a066d380ab4f43bec1f08df55bce52c`
- Assignment SHA-256 after reservation writeback: `e5317a92b2cae0f51dd3b61244c52068d0e12c03ae8723a3474558ed8a829ded`

## Reserved destination

- Model: **iPhone 17**
- Runtime: **iOS 26.0**
- UDID: **`D3C353BE-3AA6-499B-8F87-349073D65BE4`**
- State at reservation: **Booted**
- Inventory source: XcodeBuildMCP `list_sims`, observed at 2026-09-29 14:25:01 UTC.
- Authorization: The Human Product Owner supplied this exact destination and authorized proceeding in response to the request for a fresh exclusive window covering Stage B. The reservation applies only to the validation matrix in this Assignment and ends when its final command and result-bundle collection finish.
- Isolation check: The XcodeBuildMCP profiles inspected before the run referenced other simulator UDIDs; none referenced this reserved UDID. No other agent in this task was active.
- XcodeBuildMCP profile: `v3-compat-stage-b-2026-09-29`, configured with `persist: false` so the current project-level defaults are not overwritten.
- Planned raw-log and result-bundle directory: `/private/tmp/universe-keyboard-v3-compat-stage-b-20260929-1425`.

## Permitted window

Run only the Assignment's KeyboardCore host suite and Simulator-backed `RimeBridgeTests`, App/Keyboard, signed Keychain integration, and Release build commands. Every Simulator-backed command must name this same UDID. Do not boot, shut down, erase, or use another Simulator. Stop if this exact destination changes or another task needs it.

At the time this receipt was written, no Stage B test or build had started. The full command output, exit code, and result-bundle path for each run will be recorded in the Stage B validation evidence. The reservation does not authorize manual Maps reproduction, production marker emission, app installation outside the test harness, root-cause diagnosis, a Product/Quality Gate, Release, commit, push, PR, merge, or parent Assignment closure.
