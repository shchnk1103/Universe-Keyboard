# UK-005 P1-A — REP-Q-01 and hosted provenance closure receipt

> Status: `REP-Q-01 Closed`; `HOSTED-PROVENANCE Closed` for the candidate-bound
> hosted CI relation recorded below.
>
> This is an executor-recorded provenance receipt. It binds implementation identity,
> actual base/head and hosted CI evidence for the UK-005 P1-A handoff. It is not a
> Product Gate, Quality Gate, Release Pass, App Store Connect, TestFlight, device,
> merge or publication authorization.

## 1. Receipt identity and scope

| Field | Value |
|---|---|
| Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../assignments/kos-release-evidence-implementation-001-p1.md) |
| Parent Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](../assignments/kos-release-evidence-implementation-001.md) |
| Authorization | [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md) |
| Receipt type | Executor-recorded residual closure and hosted provenance receipt |
| Observed at | `2026-09-15T11:36:22+08:00` Asia/Shanghai |
| Execution worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005-provenance` |
| Candidate branch | `codex/kos-upgrade-uk-005-release-evidence` |
| Pull request | [#132](https://github.com/shchnk1103/Universe-Keyboard/pull/132), open; mergeable state currently `CONFLICTING` |
| Git action boundary | Commit/push/PR authorized and performed; merge, tag, Release and publication not performed |

The receipt closes the two UK-005 P1-A engineering residuals with separate identity
bindings:

1. `REP-Q-01` binds the existing Main-App source owner to its exact implementation
   candidate and also binds the UK-005 adapter package that consumes that source seam.
2. `HOSTED-PROVENANCE` binds the UK-005 package branch head to a successful hosted
   `Swift 6 Quality` run with `headSha` equal to that branch head.

The Main-App implementation and the UK-005 adapter are different candidates. Their
evidence is recorded together here only as an explicit dependency binding; no status
or review conclusion is transferred across Assignments.

## 2. Main-App source-owner identity bound by REP-Q-01

The UK-005 Profile names `SRC-MAIN-PROMOTION` and `SRC-MAIN-STORE` as the existing
Main-App authority. The source-owner implementation was independently finalized on
its own bounded candidate:

| Field | Value |
|---|---|
| Main-App source candidate | `ad39f443b7f77d96c28359bd652356a89bb173de` |
| Main-App actual base | `e7b2f602684553fc9b31cf32109839a3d6141e0d` |
| Main-App candidate tree | `f7ba5ae358538c8220a8e3d08cc1c2172eec8366` |
| Main-App hosted run | [34865917284](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34865917284) |
| Main-App hosted relation | `same-head`; hosted `headSha` = `ad39f443b7f77d96c28359bd652356a89bb173de` |
| Main-App merged reachability | Merged by PR #128 at `1a405143229eff151f61d1c7fc789bc4368802d7`; source blobs remain unchanged on the checked `origin/main` snapshot |

The relevant Main-App source blobs at the finalized candidate and merged revision are
identical:

| Source path | Blob SHA-1 |
|---|---|
| `Universe Keyboard/Services/ReleaseEvidenceStore.swift` | `a86e80bc3fe15cc32c5290c99ebcfab8b488254f` |
| `Universe Keyboard/Views/Diagnostics/ReleaseEvidenceView.swift` | `7f6aa34d1b538e4c17ecb038f4a34814e257871a` |
| `UniverseKeyboardTests/ReleaseEvidenceStoreTests.swift` | `b99219d3d3fc550262e407aa30e5bfd0ca7c4823` |

The source-owner run and its original receipt are preserved at the finalized Main-App
revision in [`release-evidence-promotion-001-rep-q-01-provenance-2026-09-15.md`](https://github.com/shchnk1103/Universe-Keyboard/blob/1a405143229eff151f61d1c7fc789bc4368802d7/docs/evidence/release-evidence-promotion-001-rep-q-01-provenance-2026-09-15.md).
That receipt closes the other Assignment's residual only; this section uses its exact
candidate facts as the named source-owner input for UK-005.

## 3. Exact UK-005 package identity

| Field | Value |
|---|---|
| Package base | `3139f8d3bdb6be6622504ea731988f42681896fb` |
| Candidate tree / branch head | `666a421de63590719516a8104f70a1a3c114dac1` |
| Package digest | `45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382` |
| Independent review package | Same `45af…` digest; Architecture and Quality/Performance/Release r4 reviews passed |
| Candidate delta beyond package | Commit `666a421` changes only the pinned-source-link references in the P0 Architecture closure review; none of the six package files changed, so the package digest is unchanged |

The six-file package and per-file hashes remain defined by the [P1 implementation
receipt](kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md).
The closure receipt, status mirrors and review-link correction are excluded from that
package digest.

## 4. UK-005 hosted CI provenance

The workflow was dispatched against the exact candidate branch with the exact package
base:

```text
gh workflow run swift6-quality.yml \
  --ref codex/kos-upgrade-uk-005-release-evidence \
  -f base_sha=3139f8d3bdb6be6622504ea731988f42681896fb
```

Hosted run: [34924569095](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34924569095)

| Field | Value |
|---|---|
| Workflow | `Swift 6 Quality` |
| Event | `workflow_dispatch` |
| Ref | `codex/kos-upgrade-uk-005-release-evidence` |
| Input `base_sha` | `3139f8d3bdb6be6622504ea731988f42681896fb` |
| API `headSha` | `666a421de63590719516a8104f70a1a3c114dac1` |
| Run conclusion | `success` |
| Coverage | `same-head` (`candidate_head == published_head == hosted_ci_head`) |

| Job | Job ID | Result |
|---|---:|---|
| `classify-change` | `104239779284` | `success` |
| `lightweight-checks` | `104239814848` | `success` |
| `build-and-test` | `104239848988` | `success` |
| `final-quality-gate` | `104242842901` | `success` |

The hosted full gate included pinned RIME preparation, strict Swift-format checking,
KeyboardCore tests, RimeBridge simulator tests, App/Keyboard contract tests, Debug
build and Release build. The GitHub runner emitted only the repository's existing
Node.js 20 action deprecation annotations; no job failed or was skipped.

## 5. Local pre-push verification

The local gate used the explicit installed simulator
`8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` (iPhone 17 Pro / iOS 26.0), because the local
Xcode 27 environment could not resolve the CI name-only destination against its latest
OS selection. This is an environment-specific destination spelling, not a change to
the CI contract.

| Check | Result |
|---|---|
| Release-evidence focused tests | `25` passed, `0` failed |
| CI classification tests | `12` passed, `0` failed |
| Python compile checks | passed |
| KeyboardCore | `1125` passed, `0` failed |
| RimeBridgeTests | `101` executed, `20` skipped by existing conditional fixtures, `0` failed |
| UniverseKeyboardTests | `357` executed, `9` skipped by existing conditional fixtures, `0` failed |
| KeyboardTests | `11` executed, `0` failed |
| Debug build | `BUILD SUCCEEDED` |
| Release build | `BUILD SUCCEEDED` |
| RIME vendor verification | 12-framework structural inventory passed; the temporary local Vendor symlink was removed before push |
| Lightweight/KOS checks | changed Markdown links, 12 CI tests, final gate matrix and KOS trigger-path checks passed; validator exit `0` with pre-existing repository warnings only |
| Swift format hard gate | Not applicable: no `.swift` file changed in the UK-005 package candidate |

The exact lightweight command used before push was:

```bash
KOS_AGENT_KIT_ROOT=/Users/doubleshy0n/Dev/kos-agent-kit \
KOS_AS_OF=2026-09-15T10:44:38+08:00 \
bash scripts/ci/run_lightweight_checks.sh \
  3139f8d3bdb6be6622504ea731988f42681896fb \
  666a421de63590719516a8104f70a1a3c114dac1
```

## 6. Closure and non-claims

- `REP-Q-01 = Closed`: the Main-App source owner now has a final implementation
  candidate, actual base/head, source blobs, merged reachability and a same-head hosted
  run; the UK-005 adapter package is separately bound to its exact candidate tree and
  digest.
- `HOSTED-PROVENANCE = Closed` for the UK-005 candidate-bound hosted CI relation:
  `666a421…` is the published branch head and the hosted run's exact `headSha`.
- The adapter's code-controlled `MAIN_APP_SOURCE_BINDING_STATE` remains fail-closed in
  this exact reviewed package. This receipt does not mutate the package, does not turn
  `inconclusive` into a pass, and does not manufacture a `current-proof` result.
- P-01/D-01 delivery and final-validation receipts are not produced by this receipt.
  Hosted CI success is not an App Store Connect/TestFlight upload, Beta Review result,
  external availability fact or Release Pass.
- No device validation, performance/memory profile, archive/export, signing, App Store
  Connect, TestFlight, Beta Review, external distribution, merge, tag or Release action
  was performed.
- PR #132 is open and currently conflicting with newer `main`; it is intentionally not
  auto-resolved because merging current `main` would change the exact reviewed package
  scope and digest. No merge conclusion is implied.
- `CHANGELOG.md` and ADR-0035 were not changed by this closure receipt. ADR-0035's
  separate Accepted / Conditional Accept status remains authoritative for its own
  Assignment; this receipt only closes UK-005 engineering provenance residuals.

The result is an engineering provenance closure, not a Product or Release decision.
