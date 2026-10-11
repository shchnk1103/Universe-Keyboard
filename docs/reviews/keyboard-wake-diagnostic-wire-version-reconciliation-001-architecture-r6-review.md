# Architecture R6 Review — Wire-Version Reconciliation 001

- Work item: \`KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001\`
- Lane: Architecture & Knowledge Steward
- Reviewer runtime: \`/root/wire_arch_v6_r6\` (GPT-6 Luna)
- Packet: Architecture R6 packet (`keyboard-wake-diagnostic-wire-version-reconciliation-001-architecture-r6-packet.md`)
- Packet SHA-256: \`b5042e18752e6d920c9cf0be09d7f601416e66f827d91b137adaa9dc9953e778\`
- Assignment reviewed-scope SHA-256: \`edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6\`
- Assignment current full-file SHA-256: \`6e94b19c21157a6b444158728d5cc294debb20b710b8498348eed3ef7bfb7585\`
- Baseline: \`84b9c19227330b0fe6ff391be001ee398010fd6a\`
- Proposal: [wire-version reconciliation proposal](../plans/keyboard-wake-diagnostic-wire-version-reconciliation-001-proposal.md)
- Proposal SHA-256: \`3962a2f9bac051737319666775cd560c2730d776e89a141ae1ee8bcdfc71a9ed\`
- Entry identity packet SHA-256: \`3a0a27291fe653daf02191622fa1392522d17b648bd5cdf74e5f13155000179b\`
- Verdict: **Pass with conditions**

## Identity and scope

The reviewer confirmed the packet, proposal, Entry identity and transition records, and the packet-listed Proposal 0.4, ADR 0036 and acceptance record, M-06 brief, v3 manifest r2, paired-rollout Assignment and receipt, and both domain consultations against their frozen SHA-256 identities. The expected Assignment change from \`d43baef8…\` to \`6e94b19c…\` is documented as status/history-only and does not constitute scope drift.

The reviewer inspected the versioning and source-selection semantics in \`DiagnosticEvent.swift\`, \`DiagnosticEventWireValidator.swift\`, \`DiagnosticsJournal.swift\`, and \`DiagnosticsLogSource.swift\`. No files were changed; no tests, builds, or Simulator actions were performed.

## Review findings

1. **Static writer rule — Pass.** ADR 0036 requires every newly persisted event from one writer build to use its declared schema version. The current v5 \`typo_recall\` family therefore cannot remain v5 while only markers are written as v4. The proposal describes this constraint accurately.
2. **Alternatives and accepted contract — Pass.** Extending v5 is a viable alternative but changes Proposal 0.4's accepted versioning rule and needs a same-build reader/fallback gate. A forward v6 preserves the current v5 contract and requires a paired reader candidate. The proposal does not infer deployment history from the local, unmerged candidate.
3. **v6 contract — Pass.** The proposal assigns v6 to every new event in a v6 writer build, leaves retained v3/v4/v5 history unchanged, and requires per-record v3/v4/v5/v6 validation. The v6 allowlist must support v6 \`typo_recall\`, v6 markers, retained v5 \`typo_recall\`, and historical v4 markers; it does not claim the current candidate already does so.
4. **Reader/fallback matrix — Pass with implementation conditions.** The matrix covers marker and typo-recall shapes, malformed and unknown records, future versions, mixed and rejected-only history, incomplete propagation, and legacy fallback suppression. It correctly limits compatibility claims for arbitrary older readers.
5. **Paired rollout and non-claims — Pass.** Producer remains off; future Main App and Extension identities, separate authorization, source ownership, exclusive Simulator reservation, and the human Maps action remain later gates. The parent stays Active and root cause unresolved.
6. **Decision handoff — Pass with conditions.** The records are sufficient to prepare an ADR 0036 addendum only after exact-candidate Architecture and Quality review and Human Product disposition. This review does not select a version or authorize implementation.

## Residuals

| ID | Owner | Disposition |
|---|---|---|
| \`ENTRY-ID-DRIFT-01\` | Paired-rollout Executor / Product Lead | Accepted narrowly under the existing Entry record; exclude the one-character historical hash transcription error from current identity proof. It does not block this review. |
| Duplicate JSON object member detection | Future KeyboardCore / Input Intelligence implementation owner | Preserve as an implementation residual. Proposal 0.4 requires rejection or an explicit parser limitation; do not claim detection without evidence. |
| v6 reader and fallback coverage | Future KeyboardCore and App & Data Operations implementation owners | Add v6-only and mixed v5/v6 source-selection tests with legacy text present, plus unknown raw key, malformed payload, and rejected-only history coverage in a future implementation Assignment. |
| Arbitrary older-reader behavior | Future paired-rollout owner | Keep outside the compatibility promise; require a same-build Main App and Extension gate. |

## Non-claims

This is an Architecture review only. It does not adopt a wire version, amend ADR 0036, modify the paired-rollout Assignment, authorize implementation or marker emission, or establish a Quality/Product Gate, Release, runtime diagnosis, root cause, or parent closure. v6 remains a recommendation pending Human Product disposition.
