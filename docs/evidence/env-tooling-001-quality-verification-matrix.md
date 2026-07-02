# ENV-TOOLING-001 Quality Verification Matrix

> **Task:** `ENV-TOOLING-001`
>
> **Matrix version:** `1.0.0`
>
> **Status:** Accepted — Quality Required Input Satisfied
>
> **Quality owner:** Quality, Performance & Release Maintainer
>
> **Decision date:** 2026-07-02 Asia/Shanghai
>
> **Source of Truth:** This document is the only repository authority for the pre-implementation Quality verification cases and evidence required by `ENV-TOOLING-001`.
>
> **Boundary:** This matrix satisfies the Assignment's Quality-owned Required Input. It does not authorize implementation, mark the Assignment `Ready`, accept a future implementation, perform Environment Capture, or authorize Benchmark or Task 7.

## Authoritative Inputs

- [`ENV-TOOLING-001 Assignment`](../assignments/env-tooling-001.md)
- [`Environment Digest Tooling Architecture Work Package v1.0.0`](../ENVIRONMENT_DIGEST_TOOLING.md), Accepted
- [`004C-R1 Environment Evidence Template v1.0.0`](004c-r1-environment-evidence-template.md), Accepted
- [`Environment Capture Procedure v1.0.0`](../ENVIRONMENT_CAPTURE_PROCEDURE.md), Accepted
- Assignment Policy v1.0.0

The Architecture Work Package owns roots, includes, exclusions, canonical bytes, failure categories, privacy and non-shipping boundaries. This matrix verifies those frozen contracts without redefining them.

## Quality Required Input Decision

| Assignment input | Quality owner | Result | Evidence |
|---|---|---|---|
| Required Input 12 — Quality verification matrix | Quality, Performance & Release Maintainer | **Satisfied** | This accepted matrix v1.0.0 |
| Entry Criterion — Quality has confirmed the verification matrix | Quality, Performance & Release Maintainer | **Satisfied** | Coverage and gates below |

This decision is limited to pre-implementation readiness. Program Manager must independently check every non-Quality Required Input and Entry Criterion. Product Lead alone decides whether the Assignment enters `Ready`.

## Result Vocabulary

| Result | Meaning |
|---|---|
| `Passed` | The implementation produced the required output and retained reproducible evidence for the exact case. |
| `Failed` | The implementation executed successfully but violated the frozen expected result. |
| `Blocked` | The verification could not execute or could not produce trustworthy evidence. It is not a pass. |
| `Not Applicable` | Permitted only where this matrix explicitly marks the case optional. |

An implementation Quality Review requires every mandatory case to be `Passed`. `Blocked`, skipped, missing or inferred results do not satisfy a mandatory case.

## Required Test Environments

### Controlled fixture environment

- Temporary fixture roots created outside product, App Group and source-tree directories.
- Fixture inventory committed or generated deterministically by tests.
- No physical device, live App Group, Runtime, Bridge, session or deployment dependency.
- Test teardown may remove its own temporary fixture/output only; it must not modify supplied roots.

### Shipping-boundary environment

- Production/Release build graph inspection proving the capability is not compiled or linked into the Main App, Keyboard Extension or RimeBridge shipping products.
- Source/target membership inspection proving invocation is explicit engineering tooling only.
- A fixture result cannot satisfy this boundary.

## Core Verification Matrix

### Schema profile

| ID | Verification | Fixture / action | Expected result | Required evidence |
|---|---|---|---|---|
| `Q-SCH-001` | Exact successful inventory | Root contains only `rime_ice.schema.yaml` | One complete schema manifest; logical root `Rime/shared`; lowercase SHA-256 | Canonical manifest bytes, digest and included inventory |
| `Q-SCH-002` | Missing required schema | Required file absent | `missingRequiredInput`; no accepted digest | Typed failure and no success artifact |
| `Q-SCH-003` | Wrong schema identity | Request uses a schema other than `rime_ice` | `wrongSchemaIdentity`; no file read beyond validation | Typed failure |
| `Q-SCH-004` | Unsupported sibling | Add an unclassified regular file | `unsupportedInput`; no partial manifest | Typed failure and inventory observation |
| `Q-SCH-005` | Source-tree substitution | Supply a source-tree or otherwise forbidden root | Fail closed; never label output deployed/runtime evidence | Typed failure and provenance envelope |

### Shared runtime profile

| ID | Verification | Fixture / action | Expected result | Required evidence |
|---|---|---|---|---|
| `Q-SHR-001` | Closed include set | Populate representative root/nested approved YAML, TXT, build BIN/YAML, dictionary YAML, Lua, OpenCC JSON/OCD2 files | Every approved file included exactly once in canonical order | Manifest, inventory and digest |
| `Q-SHR-002` | Zero-component `**/` match | Use approved files directly under an approved directory boundary | Pattern treats `**/` as zero or more complete components | Included inventory |
| `Q-SHR-003` | Empty inventory | Existing root contains no included regular file | Fail closed; no accepted digest | Typed failure |
| `Q-SHR-004` | Unknown regular file | Add an unclassified extension/path | `unsupportedInput`; no silent ignore | Typed failure |
| `Q-SHR-005` | Approved exclusions | Add representative log, cache, temp, lock, backup and generated diagnostic paths | Excluded before content read; each path appears in exclusion report with reason | Exclusion report; no content digest for excluded paths |
| `Q-SHR-006` | Privacy exclusions | Add representative `*.userdb*`, sync, user.yaml, credential and user-text-classified paths | Excluded before content read; no size/content/timestamp/digest emitted | Exclusion report and privacy assertion |
| `Q-SHR-007` | Distribution `custom_phrase.txt` provenance | Provide approved deployed distribution artifact and separately an unproven equivalent | Approved artifact included; unproven artifact fails before read | Provenance envelope and typed result |

### User configuration profile

| ID | Verification | Fixture / action | Expected result | Required evidence |
|---|---|---|---|---|
| `Q-USR-001` | Exact allowlist success | Root contains `default.custom.yaml` and `rime_ice.custom.yaml` only | Exactly two entries; logical root `Rime/user` | Manifest, inventory and digest |
| `Q-USR-002` | Missing either file | Remove each required file in separate case | `missingRequiredInput`; no partial digest | Typed failures |
| `Q-USR-003` | Other custom YAML | Add `luna_pinyin.custom.yaml` or another `.custom.yaml` | `unsupportedInput`; wildcard discovery prohibited | Typed failure |
| `Q-USR-004` | User learning exclusion | Add userdb, sync and backup learning structures | Tool does not read/hash/export learning content | Exclusion report plus read-boundary test |
| `Q-USR-005` | Preferences prohibited | Attempt to supply an App Group preferences database/root | Fail closed; preferences are not an allowed root | Typed failure |
| `Q-USR-006` | Configuration content remains opaque | Include `translator/enable_user_dict` inside approved YAML | Hash raw approved file bytes only; do not traverse referenced learning state | Manifest and no-learning-access assertion |

### Effective configuration profile

| ID | Verification | Fixture / action | Expected result | Required evidence |
|---|---|---|---|---|
| `Q-EFF-001` | Exact deployed build output | Root contains only `rime_ice.schema.yaml` under logical `Rime/shared/build` | One complete effective manifest and digest | Manifest and provenance envelope |
| `Q-EFF-002` | Undeployed schema substitution | Supply `Rime/shared/rime_ice.schema.yaml` or source YAML | Fail closed; no synthesized effective digest | Typed failure |
| `Q-EFF-003` | Missing compiled output | Required build output absent | `missingRequiredInput` | Typed failure |
| `Q-EFF-004` | Extra unclassified build output | Add unsupported file | `unsupportedInput`; no partial digest | Typed failure |

### Canonical clean-state profile

| ID | Verification | Fixture / action | Expected result | Required evidence |
|---|---|---|---|---|
| `Q-CLN-001` | Complete typed fact set | Supply every frozen state fact and four same-environment digest references | Complete clean-state manifest ordered by field-name bytes | Manifest bytes, digest and source classifications |
| `Q-CLN-002` | Missing fact | Omit each required fact class | `invalidCleanStateFact`; no accepted digest | Typed failure |
| `Q-CLN-003` | Invalid digest reference | Use uppercase, malformed or non-64-character digest | `invalidCleanStateFact` | Typed failure |
| `Q-CLN-004` | Mixed environment | Supply facts/digests from different identities or Run IDs | `mixedEnvironmentIdentity` | Typed failure |
| `Q-CLN-005` | Filesystem root prohibited | Attempt to provide a directory to clean-state profile | Fail closed; structured facts only | Typed failure |
| `Q-CLN-006` | Provenance retained | Supply allowed source classifications and an unavailable required fact | Sources serialized; unavailable required fact cannot become success | Manifest/failure evidence |

## Canonicalization And Digest Matrix

| ID | Verification | Expected result |
|---|---|---|
| `Q-CAN-001` | Run identical profile twice against identical bytes | Byte-identical manifest and identical digest |
| `Q-CAN-002` | Create same files in different creation/enumeration order | Identical canonical order, bytes and digest |
| `Q-CAN-003` | Change one included file byte | Changed content digest and manifest digest |
| `Q-CAN-004` | Change an included file size | Changed size and manifest digest |
| `Q-CAN-005` | Change only timestamp/permission/owner metadata while retaining readability | Manifest bytes and digest unchanged |
| `Q-CAN-006` | Change absolute fixture-root location | Logical paths, manifest bytes and digest unchanged |
| `Q-CAN-007` | Inspect JSON bytes | Compact UTF-8, no BOM, sorted object keys, canonical arrays, exactly one final LF, no CRLF |
| `Q-CAN-008` | Inspect digests | Lowercase 64-character SHA-256; file digest covers raw bytes; manifest digest includes final LF |
| `Q-CAN-009` | Exercise JSON escaping | Quote, reverse solidus and controls escaped; `/` not escaped; decoded values round-trip |
| `Q-CAN-010` | Supply prohibited value/path encoding | Float, NUL, tab, CR/LF, backslash or non-NFC/invalid relative path fails closed |
| `Q-CAN-011` | Case-distinct paths | Case preserved; no case folding |
| `Q-CAN-012` | Platform-normalization collision | `pathNormalizationCollision`; no accepted digest |

Required evidence for every canonicalization case: exact command/test name, fixture identity, result and retained canonical bytes where success is expected.

## Filesystem Safety And Atomic Failure Matrix

| ID | Verification | Expected result |
|---|---|---|
| `Q-FS-001` | Symlink file or directory | `symlinkInput`; target never followed/read |
| `Q-FS-002` | Alias or non-regular entry | `nonRegularInput` or closed typed equivalent; no target/content read |
| `Q-FS-003` | Hard-link ambiguity | Fail closed before accepted manifest |
| `Q-FS-004` | Missing root | `missingRoot` |
| `Q-FS-005` | Unreadable required file | `unreadableInput`; permission bits not serialized |
| `Q-FS-006` | File mutation during read | `inputChangedDuringRead`; no accepted digest |
| `Q-FS-007` | Mixed roots/environment identity | `mixedEnvironmentIdentity` |
| `Q-FS-008` | Root mutation check | Input tree bytes and inventory unchanged after invocation |
| `Q-FS-009` | Output-location check | No cache, lock, temp or output created inside any supplied root |
| `Q-FS-010` | Partial-failure check | Any single invalid input fails the entire profile; no partial accepted manifest |

## Manifest And Provenance Matrix

| ID | Verification | Expected result |
|---|---|---|
| `Q-PRV-001` | Successful filesystem profile envelope | Records tool version, implementation commit, profile, authorized caller, source classification and manifest digest |
| `Q-PRV-002` | Fixture execution | Explicitly labelled fixture evidence; cannot claim device/runtime provenance |
| `Q-PRV-003` | Absolute-path privacy | Manifest and envelope contain logical root tokens only; no absolute input/output path in hashed body |
| `Q-PRV-004` | Excluded metadata | Run ID, timestamps and device identity absent from hashed body |
| `Q-PRV-005` | Same-capture correlation contract | Tool exposes required envelope fields but does not invent a Run ID or environment identity |
| `Q-PRV-006` | Missing/unsupported input | No success digest, inferred value or partial manifest emitted |
| `Q-PRV-007` | Source/deployed separation | Source-tree fixture cannot be relabelled as deployed-runtime evidence |

## Privacy Matrix

| ID | Verification | Expected result |
|---|---|---|
| `Q-PRI-001` | Sentinel user-learning content in excluded userdb/sync/backup paths | Sentinel never appears in output and excluded content is not opened/read |
| `Q-PRI-002` | Sentinel user/host/surrounding/clipboard text in prohibited path class | Invocation fails/excludes before read according to frozen classification; sentinel absent |
| `Q-PRI-003` | Credential file | Excluded before read; no size, digest or content emitted |
| `Q-PRI-004` | Logs/crash/telemetry/diagnostics | Excluded before read; reason recorded without content metadata |
| `Q-PRI-005` | Manifest inspection | Contains paths, sizes and digests only for included files; never raw file bytes |
| `Q-PRI-006` | Failure inspection | Error includes typed category and normalized non-sensitive path only; no absolute path or content |

Tests that claim “not read” must use an observable fixture mechanism, such as unreadable/sentinel inputs or a controlled filesystem reader seam. Output string absence alone is insufficient.

## Runtime And Shipping Exclusion Matrix

| ID | Verification | Expected result |
|---|---|---|
| `Q-SHP-001` | Target membership | Capability belongs only to an explicit engineering tool/library and tests |
| `Q-SHP-002` | Main App Release graph | No capability object, symbol, resource, registration or invocation |
| `Q-SHP-003` | Keyboard Extension Release graph | No capability object, symbol, resource, registration or invocation |
| `Q-SHP-004` | RimeBridge shipping graph | No capability dependency or invocation |
| `Q-SHP-005` | Hot-path source inspection | No hashing, scan, observer lookup or logging added to key handling/session lifecycle |
| `Q-SHP-006` | Runtime settings inspection | No feature flag, App Group preference or stale setting can enable capability |
| `Q-SHP-007` | Network/persistence inspection | No upload, telemetry, database, App Group or input-root mutation |

Required evidence includes target configuration, changed-file review, Release build result and symbol/dependency inspection. A Debug fixture test cannot replace Release exclusion evidence.

## Required Failure Categories

Implementation tests must exercise and preserve these exact architecture-owned categories:

- `missingRoot`
- `missingRequiredInput`
- `unreadableInput`
- `unsupportedInput`
- `forbiddenInput`
- `nonRegularInput`
- `symlinkInput`
- `pathNormalizationCollision`
- `inputChangedDuringRead`
- `invalidCleanStateFact`
- `mixedEnvironmentIdentity`
- `wrongSchemaIdentity`

An implementation may use structured associated values for non-sensitive context, but it must not merge distinct categories or expose prohibited content/absolute paths.

## Implementation Handoff Evidence

Before implementation Quality Review, Executor must provide:

- Assignment ID and Policy version.
- Frozen implementation baseline and final implementation commit.
- Exact changed-file list.
- Tool target/product identity and invocation command.
- Five profile manifests produced from controlled fixtures.
- Exclusion reports for applicable filesystem profiles.
- Provenance-envelope examples.
- Focused test command and complete result.
- Relevant full test/build commands and results.
- Release build and shipping-boundary inspection.
- `git diff --check`.
- Input-root before/after mutation evidence.
- Privacy/read-boundary evidence.
- All failed, blocked, skipped and unexecuted cases.
- Architecture Review result.
- Residual risks and unsupported conditions.
- 004C-R1 usage handoff that preserves the separate Assignment/Revalidation boundary.

Do not publish hardcoded test counts as durable truth. Retain exact counts only in the dated implementation evidence record.

## Quality Acceptance Gate For Future Implementation

Quality may recommend acceptance only when:

1. every mandatory matrix case is Passed;
2. all five profiles are complete and fail atomically;
3. canonical bytes and digests are reproducible;
4. included and excluded inventories are auditable;
5. privacy tests prove prohibited inputs are not read;
6. no source/runtime provenance substitution exists;
7. Release and shipping targets exclude the capability;
8. no input-root mutation or hot-path work exists;
9. focused and relevant full verification pass;
10. every skipped or unavailable check is explicit and non-mandatory;
11. implementation remains within the accepted Architecture Work Package;
12. no Assignment Stop Condition is triggered.

Fixture success validates the capability only. It does not satisfy 004C-R1 Environment Evidence and does not authorize Benchmark or Task 7.

## Quality Stop Conditions

Stop implementation review and return to the named authority if verification requires or discovers:

- a new root, profile, include pattern, exclusion or digest meaning;
- Runtime, Bridge, session, deployment, Main App or Extension integration;
- physical-device-only capability validation;
- user database, real-text, preferences or prohibited file access;
- source-tree output presented as deployed-runtime evidence;
- input mutation, in-root output or network/persistence;
- a shipping target dependency;
- a changed Template, Procedure, Registry, ADR, Product Contract or Assignment Gate;
- a missing mandatory case that cannot be tested within the frozen contract.

## Readiness Handoff

Quality Required Input result: **Satisfied**.

Program Manager may use this matrix as evidence that Required Input 12 and the Quality-owned matrix Entry Criterion are complete. This handoff does not satisfy implementation baseline, Executor Acknowledgement, isolated worktree or any other non-Quality Required Input, and it does not grant `Ready` or implementation authorization.
