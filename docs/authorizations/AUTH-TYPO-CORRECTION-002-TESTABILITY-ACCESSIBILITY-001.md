# Authorization: AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001

## Bounded keyboard UI testability/accessibility implementation

### Current status

- Status: `consumed` — bounded implementation authorization fully used.
- Target assignment: `TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001` (`Closed`).
- Parent assignment: `TYPO-CORRECTION-002`.
- Intended executor: Grok (external AI), completed in the isolated child worktree.
- Source baseline: `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- Publication boundary: none. Commit, push, PR, merge and Assignment closure were handled by separate authorizations.

### KOS record

```yaml
record_id: AUTH-TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001
record_type: authorization
title: Authorize bounded keyboard UI testability/accessibility implementation
status: consumed
decision_source: direct Human Product Owner instruction in the current task
decision_date: 2026-09-19
parent_assignment: TYPO-CORRECTION-002
child_assignment: TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001
authorization_action: implement_bounded_keyboard_testability_accessibility_contract
source_baseline: 9eb83158e49218c1e8f75dbe7dd9e0390db81409
executor: Grok
consumption: consumed; bounded child implementation complete
```

### Authorized action

The Human Product Owner authorizes Grok to use a new clean isolated worktree based exactly on `9eb83158e49218c1e8f75dbe7dd9e0390db81409` to inspect and, only when justified, minimally implement a Keyboard UI testability/accessibility contract.

The contract is intended to let an authorized UI automation harness discover and activate the same visible keyboard key controls that a human uses. The minimum bounded surface is the alphabetic keys required for the INT-003 interaction, plus existing Delete, Space, Return, and keyboard-switch controls where applicable. The implementation must preserve the normal UIKit action path, hit geometry, RIME/session boundary, privacy boundary, and visual contract.

The current source already has partial key accessibility semantics, including `.keyboardKey` traits and key identifiers. The current Simulator UI tree did not expose independent Universe Keyboard key targets. Grok must verify the root cause before editing; it must not duplicate semantics blindly, remove routing safeguards without proof, or treat the Apple-style appearance or an AX language label as proof that the keyboard is not Universe Keyboard.

### Scope and artifact bindings

- Worktree: a new clean isolated checkout, not `main` and not the dirty parent sidecar worktree.
- Baseline: exact commit `9eb83158e49218c1e8f75dbe7dd9e0390db81409`.
- Primary source boundary: `Keyboard/` keyboard UI/controller files only, if a change is justified.
- Test boundary: focused `KeyboardTests` accessibility/testability contract tests only, if needed.
- Required parent references:
  - `docs/assignments/typo-correction-002.md`
  - `docs/authorizations/AUTH-TYPO-CORRECTION-002-PARENT-REVALIDATION-001.md`
  - `docs/assignments/typo-correction-002-testability-accessibility-001.md`
- Required evidence: exact source/worktree identity, changed-file manifest, focused test/format results, and bounded Simulator accessibility/touch proof where available.

### Explicit exclusions

This authorization does not permit:

- a general end-user AI keyboard-control feature or public automation API;
- LLM/model/cloud/network/App Intent/Shortcut/Siri integration;
- direct host text-field injection, pasteboard insertion, marked-text mutation, arbitrary text replacement, or host-context access;
- reading, persisting, or logging raw user composition, candidate text, host text, credentials, or sensitive input;
- changes to RIME schema, vendor/archive, deployment, App Group, sidecar, session lifecycle, candidate search/ranking, search budget, debounce, or cancellation;
- `FakeCandidateProvider`, the old Ice directory, synthetic candidates, or fake runtime fixtures;
- visual redesign or use of AX appearance/labels to invalidate the human keyboard identity;
- edits to `main`, the dirty parent sidecar worktree, the F-01 remediation worktree, or unrelated files;
- Product, Architecture, Quality, Performance, TestFlight, Release, mergeability, or parent-closure decisions;
- commit, push, pull request, merge, tag, branch cleanup, or any remote mutation.

### Required evidence

Grok must return a handoff containing:

1. exact worktree path, branch, baseline, and final local identity;
2. the inspected hierarchy and the identified discoverability boundary;
3. a bounded changed-file list, or an explicit no-change result;
4. the accessibility/testability contract and its privacy/action-path rationale;
5. Swift formatting and focused/affected test results, or precise environment-limited non-claims;
6. fresh Simulator AX/touch evidence showing independent visible-key discovery/actionability when available;
7. proof that the harness route uses ordinary visible key actions and not host-text injection or private simulator APIs;
8. residual UNKNOWNs and questions for independent Architecture/Quality review.

### Stop conditions

Grok must stop and hand back without broadening scope if:

- the only working route is direct text injection, pasteboard mutation, private simulator API, or host-context access;
- independent discoverability requires weakening privacy, input isolation, or normal hit routing;
- the issue is an iOS keyboard-extension accessibility limitation that cannot be safely corrected in this slice;
- the proposed fix touches RIME, schema/vendor/archive, sidecar, search, ranking, debounce, or cancellation;
- the exact baseline, clean worktree, executor, or required environment cannot be proven;
- the request becomes a general AI control feature or a publication/gate action.

### Human instruction and authority boundary

This authorization is issued by the Human Product Owner acting as Product Lead, based on the direct instruction in the current task on 2026-09-19 (Asia/Shanghai). It authorizes only the narrow UI testability/accessibility implementation described above. It is intended to make the keyboard-control surface available to an authorized test harness that presses visible controls; it does not authorize an AI to set the host field, mutate arbitrary composition, read user content, select arbitrary candidates, or become an end-user feature.

The child assignment is now `Closed` only for the bounded implementation recorded by the child reviews and merged PR #140. No work in the dirty parent worktree or on `main` was covered by this implementation authorization.

### Consumption and revalidation

- Issuer: Human Product Owner / Product Lead.
- Issued: 2026-09-19.
- Consumed by: Grok implementation in child worktree; publication and merge were separately authorized.
- Revalidation is required if the baseline, worktree, executor, environment, keyboard hierarchy, accessibility contract, privacy boundary, test target, or evidence artifact changes.
- Any later source change, new publication, new merge, Product Gate, or parent-assignment closure requires a separate authorization.

### History

- 2026-09-19: created as a separate bounded authorization for the child keyboard UI testability/accessibility assignment. No source change or publication action has been authorized here.
- 2026-09-19: consumed by the reviewed implementation; the child was published in PR #140 and closed only after the dedicated child Close Authorization. Parent remains Active.
