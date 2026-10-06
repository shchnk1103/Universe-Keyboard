# Entry identity freeze — Wire-Version Reconciliation 001

- Work Item: `KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001`
- Capture date: 2026-09-30 Asia/Shanghai
- Baseline commit: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Assignment SHA-256 at capture: `d43baef8e0f06e34b623cf43222ee887b0c05ea6c3cc9931ee657cf57a68660d`
- Reviewed scope SHA-256 before status-only ACK writeback: `edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6`
- Establishment authorization SHA-256: `2870e8d75abf66142ea86d2dfc4ba719e24654e837bb12e0a7f1c176052f8afe`
- Assignment state: **Acknowledged / Not Ready** when captured.
- Worktree: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`, branch `codex/keyboard-wake-v3-compatibility-gate`.

## Method and interpretation

The coordinator computed SHA-256 directly from each named file and recorded `git status --short -- <path>`. For source/test paths, the baseline SHA-256 was computed from the named path at the pinned baseline commit. Source and test contents were not opened, printed, or semantically reviewed during this capture. This packet freezes identities; it does not establish that a candidate is integrated, accepted, built, tested, behaviorally correct, or safe to promote.

`??` means the file is untracked in this worktree; `M` means its current bytes differ from the pinned baseline; `clean` means current bytes match the baseline. The worktree is not clean. The seven paths declared by v3 manifest r2 match its recorded current SHA-256 values; those local candidate files remain uncommitted. The Runtime Record API Assignment and its ten-file manifest are frozen as historical predecessor records only; no source bytes from that archived older-base candidate are inferred from its manifest.

## Required document identities

| Required input path | SHA-256 | Worktree status |
|---|---|---|
| `docs/assignments/keyboard-wake-diagnostic-wire-version-reconciliation-001.md` | `d43baef8e0f06e34b623cf43222ee887b0c05ea6c3cc9931ee657cf57a68660d` | `??` |
| `docs/product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001-authorization.md` | `2870e8d75abf66142ea86d2dfc4ba719e24654e837bb12e0a7f1c176052f8afe` | `??` |
| `docs/plans/keyboard-wake-diagnostic-event-schema-proposal-001.md` | `e501a4075c24a79de560e7381ae361708c1a085250470e69840e23c930b53c06` | `??` |
| `docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md` | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` | `??` |
| `docs/product-decisions/ADR-0036-ACCEPT-authorization.md` | `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d` | `??` |
| `docs/plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md` | `ce5a729365deaf5775c96f91678586635e42dd5a851754e2b77aaf81ea2a7ae3` | `??` |
| `docs/assignments/keyboard-wake-diagnostic-v3-compatibility-gate-001.md` | `2f8e39530d867f263d80e8d9cc51891bdd4af286603f75336e436feee706cda7` | `??` |
| `docs/evidence/keyboard-wake-diagnostic-v3-compatibility-gate-001-source-test-manifest-2026-09-29-r2.json` | `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835` | `??` |
| `docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md` | `ef5a81d996f913fa69d61d0c3f70d591b1c25b155d1d9d3b5917f547578abd6e` | `??` |
| `docs/evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md` | `06cad80f247032cfc5711110daf2470deab7c29725e19492df1385da5c2b73e0` | `??` |
| `docs/assignments/keyboard-wake-diagnostic-runtime-record-api-001.md` | `a3e2d1c6bd5dd61d622cbd1505b1b012983be72c038d54941659bda103ee5d69` | `??` |
| `docs/evidence/keyboard-wake-diagnostic-runtime-record-api-001-source-test-manifest-2026-09-29.json` | `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` | `??` |
| `docs/assignments/keyboard-wake-lifecycle-diagnostics-001.md` | `54e075e651c7129d98eecc5fc9cac34f91e6bcc1d4dfb12b791a9829a83720c0` | `??` |
| `docs/ASSIGNMENT_POLICY.md` | `e90dd8f06371e9367652d4e7cc63dee31ee7b1ac855e7802d6d2e9b8e1e90680` | clean |
| `docs/VIRTUAL_ENGINEERING_TEAM.md` | `a684b2a00dae198f58b0983dccff30b9e3dc8f70cb80f5c1119301fe09dfa58d` | clean |
| `docs/AI_WORKFLOW.md` | `fd3ff24fc0d38ed134cace8ffd5479f76e6261b009d6f661d218e4e260b07413` | clean |
| `docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md` | `9e922b2b815714f2e647a4037be21871a3c163f52895640a16ed57dc26fa5f99` | clean |
| `docs/playbooks/keyboard-core.md` | `86b7a48d3040b719b3fc8f38bca5bcf6e4592037631c13da747d6efb996d5068` | clean |
| `docs/playbooks/keyboard-ui.md` | `e54a0ee6c25b07209181b239d360647d19cfd739e5f5d60ddcd4f2e34c8b13df` | clean |
| `docs/playbooks/main-app-ui.md` | `5cf0ec13c8763d98c3a4ea5c86f67f6a86396e8930a7e452e65982630cd08f29` | clean |
| `docs/playbooks/test-release.md` | `b7eb8cc76094f72699b6de77de6afa2608e6483a1c8da53dcf86a51ea6c35a58` | clean |

Paths are rooted at the repository worktree. The document identities above cover every Required Input listed in the Assignment, plus its current Assignment and establishment authorization.

## Relevant current source/test identities

The worktree SHA is the exact current byte identity; baseline SHA is the same path at commit `84b9c19227330b0fe6ff391be001ee398010fd6a`. `absent` means no file existed at that baseline. These are hash/status records only.

| Source/test path | Worktree SHA-256 | Status | Baseline SHA-256 |
|---|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `346efd59225cdf71fc61917fcb26bc72f3b1cf84aea19d873b3f238e791b492b` | M | `b67dbb084c6e7a3201e6b64e411532845df3fde2c1bee6f54462b022a0f3a534` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `49077a7a6ade1b41724fda92314cb4a41071163dc9f6c5e2a8666ee38273dbc9` | M | `9c999e18645573da1519d0f84be0f83152e800a41b109783b5730788f7a4f005` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | `965667328c2db1cba4c4f99e21a82ee13ae3890ff18bf510b9967c5396273534` | ?? | absent |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` | `bc874c7f019645e18c04b8b2c3a9d21c8247afc75b44cc8951a857078d558a70` | M | `0d8efe45eb428d9ea05aa49bbf7dbebb83c7ab546fe11120c335a35a1447031c` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | `7da854233e4454ccd44c587acca5cf8b4d4b89b15c726277748fa172da1e7c53` | M | `8846bdaafa0490bbc310d00c23ff09db9569dcbc59b26ba0715c9c290e0591be` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `8760b930ff9f1045f8689f73c2dddb33bf199b86d7246cc6dd6e50feb2af1ba5` | M | `a712ec5b004af538346b63deac2ffad4980bb4d80c35a4c9c91fdaba8095820d` |
| `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` | `ad24cef7d5512b621a53724b3b1043b29a5b1863ef163aa8de0e25b6e2fa855c` | M | `aeb7e75c30614af255e0a224eaae422ac06527e75accccbb1db41510aff934af` |
| `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift` | `db5cd320abad9bae0a170e9514818308d1c669b7b65d12f2c47954681a101a42` | clean | `db5cd320abad9bae0a170e9514818308d1c669b7b65d12f2c47954681a101a42` |
| `Keyboard/Controllers/KeyboardViewController.swift` | `8591c5d9c7b93530bb2c5eb2a3eb000a3c53bc8133183eaa3b9a48b1be147aa8` | clean | `8591c5d9c7b93530bb2c5eb2a3eb000a3c53bc8133183eaa3b9a48b1be147aa8` |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `e931105a51915084e90ef39270ebd3c3378b0d3e01dfe633d51f54293ff48db8` | clean | `e931105a51915084e90ef39270ebd3c3378b0d3e01dfe633d51f54293ff48db8` |
| `Keyboard/Services/UITextDocumentProxyAdapter.swift` | `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5` | clean | `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5` |
| `KeyboardTests/ResponsiveRimeCanaryLifecycleTests.swift` | `b59051ed993d9bab95047375ec160bd24692364fbb72726c0d396b4416f93584` | clean | `b59051ed993d9bab95047375ec160bd24692364fbb72726c0d396b4416f93584` |
| `KeyboardTests/TypoCorrectionRecallRuntimeTests.swift` | `da8828fecac0c88c3ac1b4551b5dd1c39bebaa925bf1a7bc5dfc65f5a8748953` | clean | `da8828fecac0c88c3ac1b4551b5dd1c39bebaa925bf1a7bc5dfc65f5a8748953` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` | clean | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` | clean | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift` | `15a5a39a318b1b73e24735f6258110dcba714a3dee337afecff29ff2c7ebb339` | clean | `15a5a39a318b1b73e24735f6258110dcba714a3dee337afecff29ff2c7ebb339` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` | `67fd13af32f939613578feaef98e30675879f06bfcadd254723a7ac45b6cdd33` | clean | `67fd13af32f939613578feaef98e30675879f06bfcadd254723a7ac45b6cdd33` |

The historical Runtime Record API manifest references `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalV4WriterTests.swift`; that path is absent from this worktree. It belongs only to the frozen historical manifest and is not treated as a current test input or as integrated candidate evidence.

## Input-record discrepancy for review

The frozen paired-rollout pre-edit Entry receipt contains a one-character transcription error in its row for `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift`: it records `7da854233e4454ccd44c587acca5cf8b4d4b89b15b726277748fa172da1e7c53`. The actual worktree file and v3 manifest r2 both hash to `7da854233e4454ccd44c587acca5cf8b4d4b89b15c726277748fa172da1e7c53`. This packet uses the directly computed hash and the exact manifest value. The pre-edit receipt remains frozen unchanged; its erroneous cell must not be used as source identity proof. This is recorded for Architecture/Quality disposition as `ENTRY-ID-DRIFT-01`, owner: paired-rollout Assignment Executor / Product Lead; no correction was made under this Assignment.

## Scope-review prerequisites

| Record path | SHA-256 | Worktree status |
|---|---|---|
| `docs/evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-scope-ack-2026-09-30.md` | `afa6375bf802d18889c917cbcd200f80eb429929eb688b49f3273d7808595cf4` | `??` |
| `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r1-review.md` | `b2f1ee644ab0e48ec45693574f301907d5ace96f74195262aa3521d425245e48` | `??` |
| `docs/reviews/keyboard-wake-diagnostic-wire-version-reconciliation-001-quality-r1-review.md` | `1c0ab4ca1d50e80c048aceff2d6292f0ee189dcdf580b5938f73303f327f5889` | `??` |

These records bind the scope review and responsibility ACKs to the pre-status scope SHA above. They do not substitute for this packet's Entry identity review.

## Entry review and boundaries

This packet must receive independent Architecture and Quality review of the exact identity list before the Assignment can become `Ready`. Reviewers should verify the recorded hashes/statuses and completeness of the path set without reading source/test contents. Any identity drift or newly required input stops the dependent analysis and requires rebind.

No source or test was edited. No source/test semantics were evaluated. No protocol option, wire version, ADR change, implementation, test/build, Simulator action, installation, marker emission, root-cause result, Gate, Release, or parent closure is claimed.
