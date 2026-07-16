# KEYBOARD-LAYOUT-9KEY-001 — Codex Spike Gate Review

Reviewer: Codex (Architecture + Quality review)
Review date: 2026-07-16 Asia/Shanghai
Reviewed branch: `feature/keyboard-layout-9key-spike`
Reviewed handoff: [`keyboard-layout-9key-001-codex-handoff.md`](keyboard-layout-9key-001-codex-handoff.md)
Assignment: [`../assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md)
ADR: [`../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md`](../architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md)

## Review Decision

The narrow Spike result is technically credible:

- repository-pinned librime reports version `1.16.1`;
- patched `t9.schema.yaml` differs from the captured upstream file only by removing `t9_processor`;
- the isolated runtime selected schema `t9`;
- input `64` produced raw input `64` and 9 candidates;
- BackSpace reduced raw input to `6`;
- the selected XCTest and xcodebuild invocation passed.

Therefore a librime vendor upgrade is **not currently required** to continue this feature.

However, the package is **not approved for product implementation yet**:

- Assignment: revision required; current `Active` state is not accepted.
- ADR 0018: revision required; remains `Proposed` and is not accepted.
- Spike technical direction: accepted.
- Spike evidence package: hardening required before archival.
- Product implementation: may continue only after the P1 findings below are resolved and ADR 0018 becomes `Accepted; implementation pending` or `Accepted`.

## Findings

### [P1] Product authorization source is not verifiable

Location: `docs/assignments/keyboard-layout-9key-001.md:12-13`

The Assignment says the Decision Source is a Human Product Owner instruction but links only to the implementation plan. The plan records scope; it is not a Product Lead authorization record. `Product Approver` also names only a generic role, not an identity or authoritative Product task/thread.

Required correction:

1. Cite the current human Product Owner task/handoff that authorized Grok as Executor and Codex as reviewer.
2. Identify the Product Approver or authoritative Product thread according to `docs/ASSIGNMENT_POLICY.md`.
3. Record the lifecycle transition from that verifiable source.
4. Until corrected, do not claim the Assignment is complete or `Active`.

The human owner's current Codex conversation can serve as the underlying authorization fact, but the Assignment must record it precisely enough to audit.

### [P1] A Proposed ADR cannot authorize formal implementation

Location: `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md:5`

ADR 0018 is explicitly `Proposed`, while the same sentence permits product implementation under its provisional boundary. `docs/DOCUMENTATION_GOVERNANCE.md` defines `Proposed` as under review and not binding.

This feature changes durable contracts across App Group state, RIME selection, main-App deployment and Keyboard Extension runtime behavior. Formal product implementation must not depend on a non-binding provisional contract.

Required correction:

1. Resolve the remaining P1 architecture findings in this review.
2. Change the ADR status to `Accepted; implementation pending` once Architecture review accepts the amended decision.
3. Only then proceed with product implementation steps 3–10.

### [P1] T9 readiness lacks version identity and deterministic recovery order

Location: `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md:41-66`

A single `rime_t9_ready` Boolean cannot prove which compatible schema or installed resource version was verified. A stale `true` can survive an App update, partial resource loss or a compatibility-schema change.

The phrase “in the same user-visible transaction where practical” also does not define a recoverable order for filesystem and App Group changes, which cannot be assumed to be one atomic transaction.

The ADR additionally conflates resource capability with current scheme selection: switching from rime-ice to an unsupported base scheme should fall the layout back to 26-key, but should not invalidate otherwise intact T9 resources. Otherwise switching back to rime-ice causes an unnecessary redeploy.

Required correction:

1. Define a versioned or fingerprinted readiness marker tied to the installed compatible T9 artifact set.
2. Define enable order: install → deploy → runtime verify → persist readiness marker → persist `nineKey` last.
3. Define disable/uninstall order: persist `twentySixKey` first → invalidate readiness → remove T9 resources.
4. Define recovery after interruption at every boundary.
5. On base-scheme switch away from rime-ice, fall back the layout but preserve readiness when verified resources remain intact.

### [P1] No-candidate paths can still commit raw digit strings

Location: `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md:72-78`

The ADR permits visible preedit to fall back to raw digits, then prohibits Space/Return/English switch from committing raw digits only “when candidates or readable preedit exist.” That leaves an abnormal no-candidate path where a sequence such as `64426` may still reach the host document.

Required correction:

1. State an unconditional invariant: while T9 composition is active, Return, language switch and automatic-English transitions must never commit `rawInput` digits.
2. Explicitly define the no-candidate behavior for each transition: keep composition, clear composition, or reject the commit.
3. Add unit and integration tests for the no-candidate path rather than relying only on normal candidate production.

### [P2] Spike assertions are weaker than the recorded conclusion

Location: `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift:50-62`

The test currently passes when any of raw input, preedit or candidates is non-empty. Raw input `64` alone is therefore sufficient to pass even if digit algebra produces no candidates.

The current run's full log independently records `candidateCount=9`, so this does not invalidate the observed Spike result. It does make the reusable test susceptible to a future false positive.

Required correction:

1. Assert `afterDigits.candidates` is non-empty.
2. Assert composition/preedit is non-empty separately.
3. Record candidate comments and add an explicit observation of whether the planned readable-preedit source is available.
4. Keep candidate ranking outside the success condition.

### [P2] Evidence provenance does not identify the tested source snapshot

Location: `docs/evidence/keyboard-layout-9key-001/provenance.md:5`

The recorded commit `eaa72d5207deacab1dc0b94024c67af96448ad19` does not contain either:

- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift`
- `scripts/run_t9_compatibility_spike.sh`

The run therefore came from an uncommitted/staged working tree rather than the recorded Git snapshot. The full xcodebuild log currently exists only in the local gitignored evidence directory; the tracked package contains an excerpt.

Required correction:

1. Correct the assertions and runner first.
2. Create a boundary-clean source commit containing the Spike test and runner.
3. Rerun the Spike from that commit.
4. Record the actual tested commit.
5. Record SHA-256 for the full xcodebuild log and vendor verification log.
6. Preserve sufficient immutable evidence for another reviewer to verify the run without relying on this machine's gitignored directory.

### [P2] Vendor verification failure is swallowed

Location: `scripts/run_t9_compatibility_spike.sh:155-158`

The runner invokes `ensure_rime_vendor.sh verify` but appends `|| true`. A failed vendor check would therefore be ignored while the result still claims use of the pinned vendor.

Required correction:

1. Make vendor verification failure fail the Spike, or explicitly downgrade the conclusion and stop before testing.
2. Distinguish the manifest's expected archive SHA-256 from an actually verified local artifact checksum.
3. Include the vendor verification outcome and log hash in provenance.

### [P3] Staged diff does not pass `git diff --cached --check`

Locations:

- `docs/evidence/keyboard-layout-9key-001-codex-handoff.md:3-7`
- `docs/plans/keyboard-layout-9key-implementation-plan.md:297`

The handoff contains trailing whitespace and the plan contains an extra blank line at EOF. Clean these before publication.

## Evidence Confirmed In This Review

- Upstream schema SHA-256: `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6`.
- Patched schema SHA-256: `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b`.
- Schema diff removes only the `t9_processor` line.
- Local full xcodebuild log SHA-256: `6444f04db309fbeff2e7b1fed0c76e86f61668f0b88d185ac935790545fe8e0a`.
- Local vendor verification log SHA-256: `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4`.
- Vendor structural inventory check reported success for 11 framework artifacts in this run.
- Full log records `schema=t9`, `rawAfter64=64`, `candidateCount=9`, `rawAfterDelete=6` and `TEST SUCCEEDED`.
- The runtime used isolated shared/user directories under the local evidence root.
- No KeyboardCore, Keyboard Extension or main-App product implementation was included in the reviewed package.

## Residual Risks For Product Implementation

The Spike does not yet prove:

- fresh main-App installation from the actual packaged resource path;
- a versioned readiness transaction or interruption recovery;
- candidate comments are always sufficient for readable T9 preedit;
- Space, Return and language transitions never commit raw digits;
- effective-scheme consistency during Objective-C session recovery;
- multi-syllable behavior such as `64426` in the product path;
- compact-width, dark-mode, accessibility or physical-device behavior;
- whether the `essay` read-only warning is acceptable in the final main-App deployment path.

These are not reasons to upgrade librime now, but they remain mandatory implementation and acceptance work.

## Re-review Entry Criteria

Grok should request Codex re-review after providing:

1. A verifiable Assignment Decision Source and corrected lifecycle state.
2. Amended ADR 0018 resolving readiness identity/order and no-raw-digit semantics.
3. Stronger Spike assertions and non-swallowed vendor verification.
4. A rerun bound to a commit containing the tested runner and XCTest.
5. Updated provenance and durable raw-evidence hashes.
6. A clean `git diff --cached --check` result.

Until these conditions are satisfied, do not begin product implementation steps 3–10.
