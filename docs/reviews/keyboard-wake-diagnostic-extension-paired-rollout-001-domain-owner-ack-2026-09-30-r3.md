# Domain Owner ACK: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001 R3

## Disposition

**ACKNOWLEDGED** by the Keyboard Experience Maintainer for the exact current Assignment identity below.

## Exact identity

| Object | SHA-256 |
|---|---|
| Paired rollout Assignment | `3d91b7d599ab34a995a2bb8cc0ccf4a1d4874f0fdf64e6b4c80717cd5a1c7a6d` |
| v6 Product Decision | `3a8228c0ad7e85e1798e8fb65f4be52c844875cca3866f9e7e2c088be134a52c` |
| ADR 0036 Addendum 002 | `4b6141cee61d7d0fb6e90b8898de2a427f342c74501cd7f489d21832879c11dc` |

## Domain disposition

The owner accepts responsibility for Extension lifecycle wiring, observable RIME-resume call boundaries, and existing `UITextDocumentProxy` calls. The work must not infer unobservable state, change typing behavior, or collect input content. KeyboardCore and Main App version-reading work remain under their assigned responsibilities and require their own exact authorization and frozen scope.

The prior R2 ACK bound writer-v3/test-fixture-v4 behavior and does not cover the current writer-v5 producer-off stage plus separately authorized future v6 promotion. This R3 ACK applies only to the current Assignment scope and does not make it Ready or authorize implementation, testing, builds, Simulator work, installation, reproduction, or publication.

## Provenance

The Coordinator recorded the exact current-scope response from `/root/paired_domain_rebind_luna`. The agent reported read-only inspection; no source, test, build, or Simulator action occurred. Agent interaction count was not recorded.
