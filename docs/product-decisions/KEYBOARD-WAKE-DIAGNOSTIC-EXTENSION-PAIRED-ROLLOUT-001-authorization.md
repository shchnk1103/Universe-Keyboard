# Product Authorization — KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001

## Current Status

| Field | Value |
|---|---|
| Status | **Authorized for Assignment establishment only** |
| Current phase | The Human Product Owner authorized creating the paired-build rollout Assignment, accepted the Entry/Exit clarification, and later authorized a separate exact-scope implementation authorization. All six required responsibilities acknowledged or reviewed pre-status Assignment SHA-256 f7e8304df7a9d8e56a6fa1387b9815410cccc21f52a0c87929f05b66be0ba6cb. The Assignment remains **Acknowledged / Not Ready**: its pre-edit Entry found a writer-version conflict with the reviewed schema-v5 candidate. See the [implementation authorization](KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-implementation-authorization.md), [Entry receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-001-pre-edit-entry-2026-09-30.md), and [reconciliation brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md). This record remains authority for Assignment establishment only. |
| Material non-claims | This authorization does not authorize Extension code changes, tests, builds, Simulator operations, installation, v4 event emission, manual reproduction, publication, a Gate, root-cause conclusion, behavior fix, or parent closure. |
| Next handoff | Product/Architecture must reconcile the persisted-wire contract before the Assignment can become Ready / Active. Source ownership and a fresh exclusive Simulator window remain Entry conditions after that disposition. |

## Decision

- **Decision source / date:** Human Product Owner replied “授权” in the current Codex task on 2026-09-29 Asia/Shanghai, after the Executor proposed creating this independent Assignment and explicitly bounded the current authorization to Assignment establishment only.
- **Authorized output:** Create and maintain [`KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001`](../assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md), assign the named KOS responsibilities, and synchronize its predecessor and parent status mirrors.
- **Not authorized:** Execute the future implementation scope or perform any runtime, build, Simulator, installation, publication, or external action. A separate, exact-scope implementation authorization is an Entry Criterion for `Ready` / `Active` work.
- **KOS 2.2:** Not opted in; the project pin remains advisory.

## M-06 decision packet

### Objective

Close the remaining observation gap in the App Switcher keyboard-wake investigation by recording content-free Extension lifecycle, RIME-resume boundary, and text-proxy call markers, then collecting evidence from one verified Main App + Keyboard Extension build. This is intended to distinguish which observed boundary stops progressing; it does not presume the root cause.

### Scope and effects

This authorization currently permits documentation only. The separately assigned future implementation scope is bounded to existing Keyboard Extension lifecycle and proxy boundaries, typed v4 submission through the already reviewed API, and a paired build whose Main App and Keyboard Extension demonstrably contain compatible v4 writer/reader behavior. If later authorized and completed, the Extension will persist additional fixed-enum, content-free diagnostic events under the existing user-enabled diagnostic/high-fidelity gates. The events must not change input behavior or synchronously block the key/proxy path.

### Non-goals

No behavior fix, KeyboardCore input/session change, RimeBridge change, event-schema expansion, Main App reader/fallback change, RIME deployment, raw text or candidate capture, synchronous persistence, standalone diagnostic-app installation, unpaired v4 producer enablement, root-cause claim, parent closure, commit, push, PR, merge, TestFlight, or Release is authorized here.

### Completion evidence

Assignment-establishment completion is the bounded Assignment and this authorization record, synchronized predecessor/parent/Active Work status, and a passing changed-Markdown link check with its baseline/candidate pair recorded in the [validation receipt](../evidence/keyboard-wake-diagnostic-extension-paired-rollout-assignment-markdown-links-2026-09-29.log). The future implementation Assignment requires exact paired-build identities, CI-equivalent validation, independent Architecture and Quality review, and a Human Product Owner Maps App Switcher reproduction report before its evidence can be considered complete. None of that future evidence exists by this authorization.
