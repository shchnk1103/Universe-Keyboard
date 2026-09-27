# RIME-SYNC-001 — Bounded iOS V1 Architecture Review — 2026-09-23

## Review identity

| Field | Value |
|---|---|
| Verdict | `Blocked` — one P1 local conditional-write finding must be fixed and re-reviewed |
| Reviewer | Independent Architecture reviewer `Meitner`, GPT-6 Luna; agent `01a0ce57-979e-7f03-bf42-90fea1dd1bfe` |
| Review mode | Read-only; no files, tests, simulators, devices or external services changed/operated by reviewer |
| Base | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate | Exact uncommitted snapshot in `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard` at review time |
| Snapshot | 26 paths: 18 modified, 8 untracked; reviewer verified the inventory and aggregate before/after review stability |
| Package digest | `81483fdace5b887207af930e52478a50f9fe5477ddd9931fa9e38ea9846c9c44`; SHA-256 over the 26 `shasum -a 256 <path>` output lines in the manifest order below, including newline terminators |
| Independent cross-check | Coordinator recomputed the 26 per-file SHA-256 values; all matched the reviewer's manifest. Sorting those same lines by path before aggregation yields `8924e2eb1f0ce704ed78cb0d7508d64216676117d62b309d07bb2df9c85321c9` |

The review is bound to the manifest below. The review receipt and later status
mirrors are not members of the reviewed snapshot.

| Path | SHA-256 |
|---|---|
| `.github/workflows/swift6-quality.yml` | `cb4a41108ba0e9268b04b1aaca8bd06480da3e0dd8706221acbbce3ad6a0a6a8` |
| `Universe Keyboard/App/ContentView.swift` | `aa9abbe72bc40cc7561f82ce076b565f06b210ecdc7ffed570a1b9a9078fe33f` |
| `Universe Keyboard/App/Universe_KeyboardApp.swift` | `317497cc73acc83f136ab5477c633e53a3857c5fdb4cc46b688cefd94bcca8c6` |
| `Universe Keyboard/Models/RimeSyncViewModel.swift` | `d354cc0460bf2c9e4f81e86496b2d8506b9846428c2efbcb665a7fc977380a85` |
| `Universe Keyboard/Services/RimeAutomaticSyncScheduler.swift` | `01f3c3a188341b1b34ef980f077f00323b0c9dcb5787c870c4b118297a182d13` |
| `Universe Keyboard/Services/RimeSyncCrypto.swift` | `6813f5c3e03e0483d2aca744ea68116e497b4b23fa81b622aa7e3c48efa192ea` |
| `Universe Keyboard/Views/Settings/RimeSyncSettingsView.swift` | `beb774914813c717c71c576d33590f84b53c7b5b39357b97f314d7734e6eea0d` |
| `Universe Keyboard/Models/RimeSyncUITestFixture.swift` | `e7059609de523009c5519b79c6f23936a162e9073b1b57794c984ad2b6bc3480` |
| `UniverseKeyboardTests/RimeSyncTests.swift` | `63a3b25fdd7769e4613b9881c108740f0a7bd1adda43d20e71baf618b8cf7c1c` |
| `UniverseKeyboardUITests/RimeSyncSettingsUITests.swift` | `295f44b069756eb84423c05f56ac15e4451f5acefc35324d861656977cd2e4c7` |
| `docs/ACTIVE_WORK.md` | `48b6a19ac13017c2bc7e781cb67fe88fc2a7137659fd1d932079bf29bd188e95` |
| `docs/CI_CHANGE_CLASSIFICATION.md` | `cf33103e0a0c5c64bb48fed1c8b76453f1d570d2787873c4d20e9b87e1ab2ac7` |
| `docs/ENGINEERING_DASHBOARD.md` | `cc91f0b43b02f672c990d45c998e1b769a98d5fedee0d73934602098ca3b14fd` |
| `docs/RIME_SYNC.md` | `4d81533f52bcdcbd00b04e500c2d9537261f6996745f07fe9da76d0cf36db504` |
| `docs/TECH_DEBT.md` | `3a5c72d88da8d214cc35251564bf747a344d9cbb9018de40ab7c5cbab34e5f45` |
| `docs/assignments/rime-sync-001.md` | `baa6627bcf30957881863b9cf277efa5958e781467b711ba232fcaa4d39aa5e3` |
| `docs/assignments/rime-sync-diagnostics-v1-001.md` | `99513607ffb6786aba2b415cc100de788437e6a4f70fdcbecdd51fd02a515307` |
| `docs/plans/rime-sync-001-implementation-plan.md` | `a6e96a22e7f450a3347226f7fb1aedbb4a04b8779df8dbf64da8ab8b8e1f8732` |
| `docs/evidence/rime-background-sync-natural-device-success-2026-09-22.md` | `c9c862e49d5fd7457f600025615e8e2c1cd4c038f4fda4decd2632393c3cc408` |
| `docs/evidence/rime-background-sync-natural-device-success-2026-09-23.md` | `86f65b5d6d0c420319d6af34953f7e30924fdf6a872abfa36e4981fdef940520` |
| `docs/evidence/rime-sync-v1-closure-readiness-2026-09-23.md` | `3f81e9ed31603cdec54f1d622bca281d5c386248b829be3cfffe73c88c6b071f` |
| `docs/evidence/rime-sync-v1-quality-remediation-2026-09-23.md` | `f443271b9dc08745806d8e5d5e205da3d58464e706c302640100ba599de05811` |
| `docs/reviews/rime-sync-v1-quality-rereview-2026-09-23.md` | `517f1d997bb287385e34c39806a2c9fef4508e40cd78594f14c35efc1eb69f50` |
| `docs/reviews/rime-sync-v1-simulator-evidence-quality-review-2026-09-23.md` | `0b57653524e97ffb5d834f2fd0f9d01606b6ea2f0f09f14aa7545794d94fb3da` |
| `scripts/ci/tests/test_verify_final_gate.sh` | `d8708784f0d4d112217b7a26e69191315c83bdba01f65970cfedb5ab7b033200` |
| `scripts/ci/verify_final_gate.sh` | `eaaacf85e8869613bdb0870ef0b70148ca7dcd7d1dc168f04a530e0da3b0dd25` |

## Overall

**Architecture verdict: Blocked.** The bounded iOS V1 ownership and data-layer
boundaries substantially align with ADR 0012/0013/0014/0019: Main App owns
sync orchestration; Keyboard Extension remains offline and outside the sync
hot path; standard RIME sync uses librime's `sync_user_data` snapshot path;
the private settings package is separately encrypted. However, the local
folder conditional-write implementation does not fail closed on every read
error, so the stale-write protection contract is not fully upheld.

This is an Architecture finding against the current implementation path, even
though the affected `RimeSyncTransport.swift` file is unchanged in this
candidate. Fix the finding and obtain a fresh Architecture re-review before
claiming Architecture Pass. No source fix is authorized by this review request.

| Priority | Count | Disposition |
|---|---:|---|
| P0 | 0 | — |
| P1 | 2 | One implementation blocker for Architecture Pass; one retained cross-process risk that remains a parent-close/Product condition |
| P2 | 1 | Non-blocking contract consistency follow-up |

## Findings

### ARCH-RIME-SYNC-001-P1-01 — Local conditional write fails open on read error

**Status: Open; blocks Architecture Pass.**

[`RimeSyncTransport.swift`](../../Universe%20Keyboard/Services/RimeSyncTransport.swift#L183)
uses `try? Data(contentsOf:)` to obtain current local settings bytes, then maps
the result to an ETag and compares it to the caller's ETag. If reading an
existing object fails, `try?` collapses that failure to `nil`. When the caller
also supplies `nil`, the comparison passes and the write proceeds, even though
the implementation has not established that the object is absent. This can
bypass the stale-write protection required by
[`RIME_SYNC.md`](../RIME_SYNC.md#L82).

**Required remediation:** distinguish confirmed absence from read failure;
only a confirmed not-found state may produce `nil`. Propagate all other read
errors and fail closed. Add regression coverage for an existing but unreadable
object and the absent-object creation path. Re-review the changed source and
tests on a new exact snapshot.

### ARCH-RIME-SYNC-001-P1-02 — TD-002 process-boundary risk remains open

**Status: Retained `tech_debt:TD-002`; does not block this review's design
assessment by itself, but remains a parent close/Product acceptance condition.**

[`RimeSyncProcessGate`](../../Universe%20Keyboard/Services/RimeSyncModels.swift#L4)
provides mutual exclusion only inside the Main App process. It cannot prove
exclusion against a separate Keyboard Extension process. The activity
heartbeat is a conservative signal, not a cross-process lock. The Product
Owner explicitly retained this risk as `TD-002`; no technical mitigation or
risk-free claim is made. Preserve the Assignment's required device,
cross-process and cross-front-end evidence boundary.

### ARCH-RIME-SYNC-001-P2-01 — Diagnostic error values are not stable

**Status: Non-blocking follow-up.**

[`diagnosticErrorCode(for:)`](../../Universe%20Keyboard/Services/RimeSyncTransport.swift#L79)
returns arbitrary `NSError` domain/code strings. The contract requires stable
error codes in diagnostics ([`RIME_SYNC.md`](../RIME_SYNC.md#L117)). Consider
mapping implementation errors to a bounded reviewed enum before logging.

### Parent-close evidence conditions — UI/security provenance

These are not architecture-design blockers and do not expand V1 to CloudKit
or full cross-platform portability, but they remain open close-time work:
authentication/wrong-key recovery, actual disconnect and provider deletion
results, and the provenance-limited physical UI-02 observation. The current
readiness ledger continues to mark these as pending; they must not be silently
treated as accepted residuals.

## Boundary and non-claims

- Quality's `Pass with conditions` applies only to the stated Simulator
  evidence. It is not this Architecture conclusion, hosted CI, physical-device
  Keychain, production background scheduling, Product acceptance, merge,
  TestFlight or Release evidence.
- The 2026-09-22/23 natural-device success records remain supplemental,
  source/build-unpinned observations. They do not establish reliable system
  scheduling or resolve TD-002.
- CloudKit is deferred. Full cross-platform compatibility remains in TD-008.
  TD-013, TD-017 and historical exact error `UNKNOWN` remain open/unknown as
  recorded. Run 02 remains `INVALID`; its historical `HOLD` conclusions are
  unchanged.
- The remaining UI/security evidence and Product lifecycle decision still
  prevent parent closure. The Assignment remains `Active`.
- No code, test, hosted workflow, simulator, device, commit, push, PR, merge or
  Release operation was performed by this Architecture reviewer.

## Review process

The repository has no dedicated Architecture playbook. The reviewer followed
the repository entry instructions, Assignment Policy and Architecture &
Knowledge Steward role. The review was independent and read-only. The review
candidate stayed at base commit
`4a51228fc8e435d538e9a5f7342ae325502e1e66`; all 26 manifest entries were
stable before and after review.
