# KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001 — 2026-09-27 simulator evidence

## Status

Evidence-bound diagnosis only. One working baseline, one App Switcher failure report and one keyboard-switch recovery were captured on the Product-selected iPhone 18 Pro / iOS 27.0 Simulator. Root cause remains unresolved; no fix, Quality Gate, Product Gate, physical-device or Release claim is made.

## Identity and capture conditions

- **Simulator:** iPhone 18 Pro, UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`, Booted; runtime reports iOS 27.0. The runtime build number was not bound to this UDID.
- **Source:** worktree HEAD `9eb83158e49218c1e8f75dbe7dd9e0390db81409` plus a five-file diagnostic patch. Its SHA-256 `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d` is over the byte stream from `git diff --binary 9eb83158e49218c1e8f75dbe7dd9e0390db81409 --` followed by these exact paths, piped directly to `shasum -a 256`: `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift`, `Keyboard/Controllers/KeyboardViewController+CandidateDataSource.swift`, `Keyboard/Controllers/KeyboardViewController+InputActions.swift`, `Keyboard/Controllers/KeyboardViewController+KeyPressFeedback.swift`, and `Keyboard/Controllers/KeyboardViewController.swift`. Human used Xcode from the diagnostic worktree. No Xcode result bundle or DerivedData receipt was retained to independently bind the installed binary to that source identity.
- **Installed app:** `com.DoubleShy0N.Universe-Keyboard` 1.0 (1), Main App executable SHA-256 `00697b3629226c389373b510222521da8b1fffe00df2f6ea2d1c3d9a170db4a8`, Keyboard Extension executable SHA-256 `68b74453173cd7a9bd80994f82a6f2e7f3ac7b40693b5327fa56f879b484b09e`.
- Both installed bundles pass `codesign --verify --deep --strict` and are ad-hoc signed. `codesign` entitlement readback returned an empty dictionary for both bundles, while the App Group directory and Extension journal are present and writable. This discrepancy is unresolved; it does not invalidate the observed journal, but exact signed-entitlement provenance remains open.
- **RIME state:** `rime_deployed=true`, `rime_deploying=false`, `rime_needs_deploy=false`; built-in Luna resources and receipts are present. Resource and overlay receipt manifest SHA-256 values match at `437f63f7e30b48bcacdb1fcacc69a51e1dfabd013a47a3795da24e26c02358b7`; overlay generation is `luna-official-2026-08-31-v3`.
- **Diagnostics:** user enabled recording and Debug high-fidelity sampling. The control record timestamp is 2026-09-27 10:44:51 UTC; the configured high-fidelity expiry is 11:24:53 UTC. `logging_enabled=true`; `log_category_perf` and `log_category_engine` are absent and default to enabled in this build. Captured Extension events report `high_fidelity_enabled=true`. No typed input, candidate text, host text, coordinates or personal data were read or emitted in this report.

## Symptom and reproduction

On Maps, the Human Product Owner reports that opening the iOS App Switcher and returning while Universe Keyboard is active leaves key feedback and sound available, but the candidate bar does not visibly change and Maps receives no new text. The keyboard did not recover by itself and the Human did not change keyboards before the failure snapshot.

The Human then switched to the System Keyboard and verified text entry in Maps. Switching back to Universe Keyboard restored Pinyin composition, first-candidate selection and Maps text insertion. These input outcomes are human-observed; the journal intentionally contains no text values.

## Observed timeline

All journal times are UTC on 2026-09-27; Asia/Shanghai is UTC+8.

| Time (UTC) | Evidence | Observation |
|---|---|---|
| 10:57:39 | Baseline segment, journal `processInstanceID` `B4682BBE-35EC-4218-9FB7-1F954F3B5FF8`, appearance `B661B587` | `presentation.appeared`; high-fidelity diagnostics active. |
| 10:57:44–10:57:48 | Same journal writer identity, action sequences 1–5 | Touch, paired `input.action`, RIME owner publication, UI application and candidate visibility events; user confirmed the candidate bar worked before App Switcher. |
| 11:00:07–11:00:11 | Same journal writer, action sequences 6–10 (local sequence range not separately retained) | Paired `input.action` records, `rime.owner.published`, `ui.applied` and candidate-visibility events were recorded. The Human simultaneously reports no visible candidate change and no new Maps text. These internal events do not prove rendered pixels or host-text insertion. |
| 11:00:17 | Same journal writer, appearance `B661B587`, local sequence 113 | Last event in the captured failure window: `candidate.visibility_changed`, `candidate_count=4`, `visible_candidate_cell_count=4`, `candidate_bar_visible=true`, revision 21. No later touch/action event was appended to this segment during the capture window. |
| 11:10:13 | New journal `processInstanceID` `48EFCF0F-65A3-446D-B8E0-0ADD5993E8E6`, appearance `268AC085` | New `presentation.appeared`; the session began at epoch 0 and advanced to epoch 1 on input. This is a new journal writer/presentation association, not proof of an OS process termination or restart. |
| 11:10:15–11:10:23 | New journal writer, action sequences 1–6 (local sequence 6–50) | Touch/action, RIME owner publication, UI application and candidate-visibility events resumed. Human confirms System Keyboard text entry worked, then Universe Keyboard composition, candidate selection and Maps insertion worked. |

## Evidence identities

- Baseline segment: `Diagnostics/v1/g1/sealed/keyboard_extension-B4682BBE-35EC-4218-9FB7-1F954F3B5FF8-20260927T10-0.jsonl`; 47 records; SHA-256 `7dc9aa1d271bb30a49504e4555df9f63868e863a9bf871b299996b0e78f19829`.
- Reported-failure segment: `Diagnostics/v1/g1/open/keyboard_extension-B4682BBE-35EC-4218-9FB7-1F954F3B5FF8-20260927T11-0.jsonl`; 66 records at capture; SHA-256 `76062649d9fd9fc26ce9a6f71538232fc1f62fd81958b0a8a949604b284edb8e`.
- Recovery segment: `Diagnostics/v1/g1/open/keyboard_extension-48EFCF0F-65A3-446D-B8E0-0ADD5993E8E6-20260927T11-0.jsonl`; 50 records at capture; SHA-256 `a48143b5557c4535c8b5aa8a684e15a00d5145f17ea5b511c2a001058d736959`.
- The two `open` segment hashes are capture-time snapshots, not immutable archived artifacts; no Run ID or copied raw-log archive was created. They identify the bytes read for this report only.
- A failure-state screenshot was viewed read-only but not retained because the Maps screen contained host text. No UI interaction, keyboard reset, simulator reset or app relaunch was performed by the executor.

## Boundary evidence and root-cause status

- Main-App RIME deployment flags and Luna receipts were present, and the baseline and recovery journal writers recorded RIME owner/candidate events. This does not establish Main-App deployment closure or rule out session, authorization, connection or stale-runtime conditions.
- During the Human-reported failure, the original process still emitted `input.action`, RIME-owner publication, UI-application and candidate-count/visibility events. This argues against a total absence of key-action handling or a completely dead RIME session. These structured events do **not** prove that candidate content visibly changed or that `UITextDocumentProxy` inserted text.
- Recovery followed a switch to the System Keyboard and back. The next Universe Keyboard presentation had a new journal `processInstanceID` and appearance identity, with a newly initialized session epoch. This associates a new writer/presentation with recovery; it does not prove OS process death/restart, whether the App Switcher caused suspension, whether a resume callback was skipped/failed, or whether a stale host text connection or UI rendering state caused the visible failure.
- ADR 0027 events have no explicit App Switcher, host-active/resign-active, presentation-disappearance or resume-result marker. The exact failure onset and the transition between the old and new process are consequently not directly represented in the journal.

**Root cause status:** one human-observed user-visible failure followed by a successful keyboard-switch recovery; the responsible internal step remains unknown. Possible areas include Extension lifecycle activation, RIME session/owner state, UI application/rendering and host text-proxy synchronization. No fix is authorized by this Assignment.

## Next owner and required follow-up

Hand off to **Keyboard Experience Maintainer** for source-level review of Extension visibility/suspend/resume activation, session ownership and host text-proxy synchronization. Architecture and Quality reviewers must independently assess the exact evidence identities above. If that review proves a KeyboardCore or RimeBridge boundary, create a separate Assignment or obtain explicit Product reassignment before crossing that ownership boundary.

Residual evidence gaps: exact Xcode build-to-source receipt, installed signed App Group entitlement provenance, actual candidate pixels and host-text-proxy result at the failure boundary, and explicit App Switcher suspend/resume markers. Host App version is known, but a separate readback of keyboard enablement/Full Access and a writer-health/drop preflight were not retained. No automated tests were run; no code was changed in this diagnostic turn.
