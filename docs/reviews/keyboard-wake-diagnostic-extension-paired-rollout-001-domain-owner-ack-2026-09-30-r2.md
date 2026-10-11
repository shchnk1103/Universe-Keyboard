# Domain Owner ACK: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001 R2

## Disposition

**ACKNOWLEDGED.** The Keyboard Experience Maintainer accepts the exact revised Assignment scope and Entry/Exit sequence.

## Exact identities

| Object | SHA-256 |
|---|---|
| Paired rollout Assignment | f7e8304df7a9d8e56a6fa1387b9815410cccc21f52a0c87929f05b66be0ba6cb |
| Assignment-establishment authorization | bf471514b0711597d0576657297be5a06ff999904031b68cefcce09c6fddd767 |
| Baseline commit | 84b9c19227330b0fe6ff391be001ee398010fd6a |

## Domain disposition

- Entry now checks source/proposal provenance, current Extension ownership, and whether the planned boundaries are observable before edits.
- Integrated source/test manifest, paired Main App and Extension binary identity, and behavior evidence remain Exit evidence.
- The scope remains limited to Extension-observed lifecycle callbacks, RIME resume call boundaries, and existing UITextDocumentProxy calls.
- Do not infer missing callbacks, internal RIME state, host insertion, or display success; no new behavior or state was added.
- The compatibility candidate remains production v3 with test-only v4 fixtures. Production v4 still requires a separate promotion authorization and exact-candidate review.

No domain blocker remains for the documentation sequencing clarification. The Assignment remains Assigned / Not Ready pending other exact-candidate ACKs, separate implementation authorization, and a fresh exclusive Simulator reservation.

This was a read-only ACK. No source was edited; no tests, builds, vendor fetch, Simulator operation, installation, v4 production emission, or manual reproduction was performed.

Receipt provenance: the Coordinator recorded the Domain Owner's exact-candidate response from agent /root/paired_domain_owner_r2. The reviewer did not write this receipt.
