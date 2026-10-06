# App & Data Operations Consultation — V3 Compatibility Gate

## Identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Proposal addendum SHA-256: `102707357458ff2c0e965ae3bf7b00d82c61ef218450eacd5101e437004a5024`
- ADR 0036 addendum SHA-256: `1d78cffb211800187d8f72a22789c8a789ca72ab98f9c68a12ddc969bae8f8ce`
- Exact base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Role: App & Data Operations Maintainer — narrow consultation, not co-owner
- Disposition: **ACK with conditions**

## Findings

- Query-wide completeness is aggregated by `beginPage` and retained by continuation. Main App consumes and preserves that aggregate; it does not own rediscovery of rejected records on later pages.
- Only a known-complete empty v1 result may use the existing `rime_diag_log` fallback.
- Incomplete, unsupported, partial, unavailable, and rejected-only v1 results retain v1 ownership and suppress legacy fallback.
- This clarifies safe handling of incomplete results without changing the existing Product fallback contract.
- Main App responsibility remains query aggregation consumption, source selection, bounded status presentation, and fallback suppression. Production markers, Extension ingress, KeyboardCore per-record parsing, and RIME are outside this role's ownership.

## Conditions and evidence boundary

Implementation must keep using the completeness result from `DiagnosticsJournalReader`; v4 marker fixtures must remain isolated from production storage/runtime/Extension ingress. The consultant reported no locator requiring a new fallback-contract decision.

This was read-only document and current-source review. No files were modified; no code, tests, builds, Simulator operations, installation, or runtime diagnosis occurred. The coordinator recorded this receipt from the consultant's final response; the consultant did not write it.
