# Input Intelligence Consultation — V3 Compatibility Gate

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Proposal addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- Exact base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Role: Input Intelligence Maintainer — narrow consultation, not co-owner
- Disposition: **ACK with conditions**

## Findings

- The Assignment keeps Keyboard Experience as the single Domain Owner and limits this consultation to KeyboardCore event/version validation, writer/reader semantics, and completeness.
- Records are validated against their own schema version; valid mixed v3/v4/v5 history is supported.
- Unknown schema, code, raw key, malformed payload, code/payload mismatch, and version-incompatible fields must remain represented as bounded incomplete/unsupported status rather than being silently discarded.
- Query-wide incompleteness must survive continuation; only known-complete empty v1 permits legacy fallback.
- Production remains schema v5, including `typo_recall`; no production wake-marker call site is added. v4 marker payloads are confined to isolated temporary/in-memory fixtures outside production App Group storage, `DiagnosticsJournalRuntime`, and real Extension ingress.
- Any future production marker version, mixed writer, fallback contract change, or duplicate-member detection requires a separate Product/Architecture decision.

## Conditions and evidence boundary

The current base still has reader gaps: its decoder accepts only v4/v5, and the reader can discard decoding failures with `compactMap`. These are candidate implementation requirements, not evidence of a completed fix. A future candidate must bind new source/test identities and prove the complete rejection, continuation, and fallback matrix.

The consultant reported no blocker to the Assignment boundary. No files were modified; no tests, builds, Simulator operations, installation, network access, Gate, Release, root-cause conclusion, or parent closure occurred. The coordinator recorded this receipt from the consultant's final response; the consultant did not write it.
