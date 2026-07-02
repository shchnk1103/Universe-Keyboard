# Environment Digest Tooling Architecture Work Package

> **Task:** `ENV-TOOLING-001`
>
> **Contract version:** `1.0.0`
>
> **Status:** Accepted
>
> **Architecture owner:** Architecture & Knowledge Steward
>
> **Domain owner:** RIME Platform Maintainer
>
> **Source of Truth:** This document is the only repository authority for ENV-TOOLING-001 digest roots, include/exclude rules, user-configuration boundary, manifest canonicalization, privacy boundary and engineering-tool runtime boundary.
>
> **Scope:** Architecture work package only. This document does not implement the capability, change evidence-field semantics, perform Environment Capture, make a Quality decision or authorize Benchmark/Task 7 execution.

## Authority And Dependency Boundary

This work package satisfies the Architecture-owned Required Inputs in the published [`ENV-TOOLING-001 Assignment`](assignments/env-tooling-001.md). It applies, but does not reproduce or modify:

- [`Assignment Policy v1.0.0`](ASSIGNMENT_POLICY.md);
- [`004C-R1 Environment Evidence Template v1.0.0`](evidence/004c-r1-environment-evidence-template.md);
- [`Environment Capture Procedure v1.0.0`](ENVIRONMENT_CAPTURE_PROCEDURE.md);
- [ADR 0003](architecture/decisions/0003-shared-container-ownership.md) for shared-container ownership;
- [ADR 0010](architecture/decisions/0010-debug-only-decision-trace-and-evidence-provenance-boundary.md) for evidence provenance separation;
- [`Shared Container And RIME Lifecycle`](architecture/shared-container-and-rime-lifecycle.md).

The accepted Template owns the five output fields and `verified_manifest` meaning. This work package only defines how the engineering capability constructs reproducible manifests for those fields. A fixture manifest remains fixture evidence. It becomes current Environment Evidence only when a later authorized capture binds the inputs to that capture's deployed environment and Run ID.

## Architecture Decision

ENV-TOOLING-001 is an explicitly invoked, read-only engineering capability. It operates on caller-supplied, already-existing directory roots or controlled fixtures. It does not discover an App Group container, deploy files, create a session, read preferences, infer an active schema or convert source-tree inputs into runtime evidence.

The implementation boundary is a non-shipping tool/library and its tests. The capability accepts five independent profile requests and returns a canonical manifest plus its SHA-256. It must not be linked to or invoked by the Main App or Keyboard Extension.

## Common Root Rules

- A supplied filesystem root must be an existing directory whose canonical location is provided by the authorized caller.
- Roots are read-only. The tool must not create lock files, temporary files, caches or output inside an input root.
- An input root is identified in a manifest by its logical token, never by an absolute host or App Group path.
- Files are regular files only. Directories are traversal structure and do not become manifest entries.
- Symbolic links, aliases, hard-link ambiguity, sockets, devices and other non-regular entries fail closed before target content is read.
- Every discovered path must match exactly one Include rule or one Exclude rule. An unclassified path fails closed; it is not silently ignored.
- The Executor must not add roots, include patterns, exclusion patterns or interpretation rules. A new path class requires Architecture review and a versioned amendment to this contract.
- Roots from different captures, installations, devices or environment identities must not be combined.

## Digest Root Contract

`<container>` below is a logical placeholder supplied by a later authorized environment capture. It is not serialized and must not be discovered by this capability.

| Profile | Allowed root | Forbidden roots | Provenance boundary | Data ownership |
|---|---|---|---|---|
| Schema | `<container>/Rime/shared` with logical token `Rime/shared` | Source tree, app bundle, archive extraction directory, `Rime/user`, backup, temp or external download roots | Exact deployed regular file `rime_ice.schema.yaml`; fixture roots prove tooling only | Main App deployment owns bytes; tool is read-only; RIME Platform owns interpretation |
| Shared runtime | `<container>/Rime/shared` with logical token `Rime/shared` | Source tree, `Packages/RimeBridge/Vendor`, app bundle, archive extraction directory, `Rime/user`, backups, temp or download roots | Approved deployed artifact inventory under the supplied shared root | Main App deployment owns layout; tool is read-only; RIME Platform owns inventory correctness |
| User configuration | `<container>/Rime/user` with logical token `Rime/user` | Entire shared root, user-dictionary backups, App Group preferences database, source tree, temp and sync roots | Only the two exact approved `.custom.yaml` files; no wildcard discovery | Main App configuration/deployment owns files; tool is read-only |
| Effective configuration | `<container>/Rime/shared/build` with logical token `Rime/shared/build` | Undeployed shared source, `Rime/user`, source tree, app bundle, inferred/expected configuration and any live session memory | Exact deployment-produced compiled configuration file `rime_ice.schema.yaml` | RIME deployment owns output; tool is read-only; RIME Platform confirms deployment provenance |
| Canonical clean state | No filesystem root. Logical token `clean-state` over a caller-supplied structured fact set | Every filesystem directory, preferences database, session memory scan and evidence from another Run ID | Facts retain their Template-authorized provenance; the tool only canonicalizes them | The later Environment Executor owns observation; tool owns deterministic serialization only |

The fixed schema identity for this work package is `rime_ice`. Supplying another schema identifier fails closed and requires Assignment revalidation.

## Include Contract

### Schema Profile

Canonical inventory contains exactly one required regular file:

```text
rime_ice.schema.yaml
```

No referenced dictionary, Lua, OpenCC or build file is part of the Schema profile. Those belong to Shared Runtime or Effective Configuration.

### Shared Runtime Profile

The inventory is recursive but closed. A regular file is included only when its normalized relative path matches one of these rules:

```text
*.yaml
*.txt
build/**/*.yaml
build/**/*.bin
cn_dicts/**/*.yaml
en_dicts/**/*.yaml
lua/**/*.lua
opencc/**/*.json
opencc/**/*.ocd2
```

Rules use `/` as separator. `**/` matches zero or more complete directory components. Root `custom_phrase.txt` is included only as a frozen deployed distribution artifact; it is not permission to read a user-created phrase file from `Rime/user` or another root.

Every regular file under the Shared Runtime root must be included by this list or excluded by the Exclude Contract. Any other regular file is an unsupported input and fails closed.

### User Configuration Profile

Canonical inventory contains exactly two required regular files:

```text
default.custom.yaml
rime_ice.custom.yaml
```

No wildcard is allowed. `luna_pinyin.custom.yaml` is outside the fixed `rime_ice` profile. Other `.custom.yaml` files are unsupported rather than automatically included.

### Effective Configuration Profile

Canonical inventory contains exactly one required deployment output:

```text
rime_ice.schema.yaml
```

This path is relative to logical root `Rime/shared/build`. It represents the deployed/compiled effective schema configuration. The tool must not synthesize it by merging YAML, reading expected preferences or substituting `Rime/shared/rime_ice.schema.yaml`.

### Canonical Clean-state Profile

The canonical inventory contains exactly these typed facts, using the field names and values authorized by the accepted Environment Template:

```text
main_app_rebuilt
app_reinstalled
extension_reinstalled
deployment_recreated
extension_process_restarted
unfinished_composition
typo_learning_state
rime_user_state
experiment_flags.insertion
experiment_flags.transposition
experiment_flags.typo_partial_commit
schema_digest
shared_runtime_digest
user_configuration_digest
effective_configuration_digest
```

Each state fact must carry its source classification in the caller-supplied record. Each referenced digest must be a lowercase 64-character SHA-256 produced for the same environment identity. Run ID, timestamps and absolute evidence locations remain provenance-envelope metadata and are not hashed into the clean-state digest.

### Ordering, Paths, Symlinks And Missing Inputs

- Inventory entries are ordered by normalized relative-path UTF-8 bytes in ascending unsigned byte order.
- Clean-state facts are ordered by field-name UTF-8 bytes using the same rule.
- Relative paths use `/`, contain no leading slash, trailing slash, empty component, `.` or `..`, and must already be Unicode NFC.
- Backslash, NUL, tab, CR and LF are forbidden in a path.
- Case is preserved. Case-folding is prohibited. Two paths that collide after platform normalization fail closed.
- Symbolic links and all non-regular file types fail the profile; their targets are never followed.
- Every exact required file/fact must exist. Missing, unreadable, changing or unsupported input fails the entire profile; partial manifests are prohibited.
- An empty Shared Runtime inventory fails closed.

## Exclude Contract

Exclusions are closed and apply before content is opened. A listed path is omitted and recorded in an exclusion report using normalized relative path plus reason code; no content, size, timestamp or digest is collected. Any unlisted non-included path is `unsupportedInput`, not an Executor-created exclusion.

| Path/content class | Matching rule | Classification | Reason |
|---|---|---|---|
| RIME user database | `**/*.userdb`, `**/*.userdb/**`, `**/*.userdb.*` | Privacy + Runtime | User learning content and mutable database state |
| Sync data | `sync`, `sync/**`, `**/sync`, `**/sync/**` | Privacy + Runtime + Non-deterministic | May contain user learning or cross-device state |
| Logs | `logs`, `logs/**`, `**/*.log` | Privacy + Runtime + Non-deterministic | Runtime diagnostics may contain input-derived data |
| Cache directories | `.cache`, `.cache/**`, `cache`, `cache/**` | Runtime + Non-deterministic | Rebuildable mutable state; does not include approved `Rime/shared/build` deployment output |
| Temporary files | `tmp`, `tmp/**`, `temp`, `temp/**`, `**/*.tmp`, `**/*.temp`, `**/*.partial`, `**/*.download`, `**/*.swp`, `**/*~` | Runtime + Non-deterministic | Incomplete or process-local writes |
| Locks and process state | `**/*.lock`, `**/*.pid`, `**/*.socket` | Runtime + Non-deterministic | Transient coordination state |
| Backups | `**/*.bak`, `**/*.backup`, `user_dictionary_backups`, `user_dictionary_backups/**` | Privacy + Runtime + Non-deterministic | Historical/user-owned data outside current configuration |
| Runtime user metadata | `user.yaml`, `**/user.yaml` | Privacy + Runtime + Non-deterministic | Installation/sync identity and mutable user state |
| Crash reports | `crash`, `crash/**`, `crashes`, `crashes/**`, `**/*.crash`, `**/*.ips` | Privacy + Runtime + Non-deterministic | May contain process or input-adjacent diagnostics |
| Telemetry | `telemetry`, `telemetry/**`, `analytics`, `analytics/**` | Privacy + Runtime + Non-deterministic | Not environment configuration |
| Generated diagnostics | `diagnostics`, `diagnostics/**`, `reports`, `reports/**`, `**/*.trace`, `**/*.memgraph` | Privacy + Runtime + Non-deterministic | Capture output must not become digest input |
| Credentials | `credentials`, `credentials/**`, `secrets`, `secrets/**`, `**/*.key`, `**/*.pem`, `**/*.p12`, `**/*.mobileprovision` | Privacy | Secret material is never permitted input |
| User/host text | Any path explicitly classified by its owner as user input, surrounding text, host text, clipboard content or user-authored phrase data | Privacy | Real user content is prohibited even if its extension otherwise matches |
| Filesystem metadata | Timestamps, permissions, owner/group, inode, ACL, extended attributes and absolute paths | Non-deterministic + Privacy | Not file content and may identify a device or host |

An approved deployed dictionary or distribution `custom_phrase.txt` is a Deployed Artifact, not real user content. If its provenance cannot be established as part of the frozen deployment inventory, the Shared Runtime profile fails before opening it.

## User Configuration Boundary

| Classification | Included in User Configuration digest | Examples and rule |
|---|---|---|
| Configuration | Yes, exact allowlist only | `default.custom.yaml`, `rime_ice.custom.yaml`; Main App-authored declarative settings for the fixed schema |
| Runtime State | No | `user.yaml`, logs, locks, caches, session/process files and runtime timestamps |
| User Learning | Never | `*.userdb*`, sync data, learning backups, learned candidate state and user dictionary contents |
| Deployed Artifact | No; owned by Schema/Shared/Effective profiles | `Rime/shared` schema, dictionary, Lua, OpenCC and `build` outputs |

The presence of `translator/enable_user_dict` in `rime_ice.custom.yaml` is configuration and is permitted. The learned records controlled by that setting remain User Learning and are prohibited. The tool hashes approved configuration file bytes without parsing, exporting or traversing referenced user data.

App Group `UserDefaults` is not a root and must not be read. The deployed `.custom.yaml` bytes are the only accepted input to this profile.

## Canonical Manifest Contract

### File Digest

- Each included regular file is read as raw bytes without text decoding or newline conversion.
- `contentDigest` is lowercase hexadecimal SHA-256 of those exact bytes.
- A pre-read and post-read identity check must detect size or filesystem-identity changes. Detected mutation fails closed; it must not emit a successful manifest.

### Manifest Data Model

Every filesystem profile produces this logical body:

```json
{
  "algorithm": "sha256",
  "entries": [
    {
      "contentDigest": "<lowercase SHA-256>",
      "path": "<normalized relative path>",
      "size": 0,
      "type": "file"
    }
  ],
  "manifestVersion": "1.0.0",
  "profile": "<schema|shared-runtime|user-configuration|effective-configuration>",
  "root": "<logical root token>"
}
```

The clean-state body replaces `entries` with a `facts` array. Each fact contains `name`, typed `value`, and `source`; digest-reference facts additionally contain the lowercase digest value. No raw input content is permitted.

### Deterministic Serialization

- Encoding is UTF-8 without BOM.
- Serialization is compact JSON with no insignificant whitespace.
- Object keys are emitted in ascending UTF-8 byte order.
- Arrays use the canonical ordering defined by this contract; implementations must not rely on map iteration order.
- Strings use JSON escaping for quotation mark, reverse solidus and control characters; `/` is not escaped.
- Only JSON strings, booleans, non-negative base-10 integers and `null` are permitted. Floating-point values are prohibited.
- The serialized document ends with exactly one LF (`0x0A`); CRLF is prohibited.
- `manifestDigest` is lowercase hexadecimal SHA-256 over the complete serialized manifest bytes including that final LF.

### Metadata Policy

Included in the hashed body:

- manifest version;
- profile identifier;
- logical root token;
- normalized relative path or clean-state fact name;
- raw-byte file size;
- file content digest;
- clean-state typed value and its source classification.

Excluded from the hashed body and retained only in a provenance envelope:

- Run ID and capture timestamp;
- tool invocation timestamp;
- absolute input/output paths;
- device identifier;
- tool executable location;
- filesystem timestamps, permissions, ownership, inode, ACL and extended attributes.

The envelope must record tool version, implementation commit, manifest digest, profile, authorized caller, source classification and later capture correlation. Excluding envelope metadata keeps identical approved inputs reproducible while preserving traceability.

Permissions are validation-only: an unreadable required file fails closed. Permission bits are never serialized. Timestamp differences alone do not change a digest, and timestamps must not be used to select files.

## Privacy Boundary

The capability may read only raw bytes of files admitted by the five Include contracts. It may emit only normalized logical paths, sizes, content digests, approved clean-state facts and provenance-envelope metadata.

It must never read, traverse, parse, export or hash:

- RIME user dictionary or learning database contents;
- sync or backup learning data;
- real user input;
- surrounding text;
- host-application text;
- clipboard content;
- credentials or signing secrets;
- logs, crash reports, telemetry or generated diagnostics.

Controlled synthetic fixture bytes and approved deployed dictionaries are not real user content. Fixture output must be labelled fixture evidence and cannot be promoted into a physical-device or current-runtime claim.

Architecture privacy confirmation: **Accepted**. The closed roots, exact/pattern allowlists, pre-read exclusions, no-follow symlink policy, no App Group preference access and fail-closed unknown-path rule prevent the capability from requiring real user content.

## Runtime And Shipping Boundary

The capability is **Explicit Engineering Tooling Only**:

- no invocation from Main App, Keyboard Extension, RIME Bridge, session lifecycle, deployment flow or key handling;
- no code linked into shipping App or Extension products;
- no production feature flag or persisted setting can enable it;
- no read, scan, allocation, logging or observer lookup is added to the keyboard hot path;
- no file mutation, deployment, session creation, schema selection or runtime repair;
- no network upload or telemetry;
- outputs are local engineering artifacts only.

Controlled fixture verification is sufficient for capability implementation. A physical device is required only by a later separately authorized Environment Capture, not by ENV-TOOLING-001 implementation.

## Failure Contract

Each profile is atomic: success returns one complete canonical manifest and digest; failure returns no accepted digest. Required failure categories are:

- `missingRoot`;
- `missingRequiredInput`;
- `unreadableInput`;
- `unsupportedInput`;
- `forbiddenInput`;
- `nonRegularInput`;
- `symlinkInput`;
- `pathNormalizationCollision`;
- `inputChangedDuringRead`;
- `invalidCleanStateFact`;
- `mixedEnvironmentIdentity`;
- `wrongSchemaIdentity`.

Failures may report normalized non-sensitive paths and reason codes. They must not include file content, absolute paths or inferred success values.

## Stop Condition Review

The Assignment Stop Conditions are internally consistent with this work package.

Result: **Accepted**.

Implementation must stop and return to the named authority if it requires Runtime, Bridge, Session, deployment or product changes; live App Group discovery; physical-device-only capability validation; user database or real-text access; source-tree substitution; new digest semantics; governance changes; a new include/exclude class; a sixth profile; or any input that cannot be represented within the contracts above.

No current Architecture Stop Condition is triggered by this work package.

## Architecture Review Result

| Review | Result | Basis |
|---|---|---|
| Boundary Review | Accepted | Five closed profiles; no implementation or capture authorization |
| Privacy Review | Accepted | Exact roots/allowlists, prohibited user-learning/text classes and fail-closed traversal |
| Ownership Review | Accepted | Main App/RIME retain data ownership; RIME Platform owns domain interpretation; tool is read-only |
| Runtime Review | Accepted | Explicit non-shipping tooling; no Main App, Extension, Bridge, session or hot-path integration |
| Deployment Review | Accepted | Reads caller-supplied deployed/exported roots only; cannot deploy, repair or infer deployment |
| Provenance Review | Accepted | Fixture, deployed bytes, manifest and capture identity remain distinct; tool cannot promote provenance |

Final Architecture Review Result: **Accepted**.

The following Architecture Required Inputs are **Satisfied** by contract version `1.0.0`:

- Architecture Work Package;
- Allowed Roots;
- Include Contract;
- Exclude Contract;
- User Configuration Boundary;
- Manifest Canonicalization Contract;
- Architecture Privacy Confirmation.

This conclusion does not make the Assignment `Ready`: Quality Verification Matrix, implementation baseline, isolated worktree and all other Assignment Entry Criteria remain owned by their respective authorities.

## Quality Verification Matrix Handoff

Quality may now define verification cases directly against the frozen roots, inventories, exclusions, canonical bytes, failure categories, privacy rules and Release exclusion in this document. Quality must not reinterpret an unsupported path as an optional exclusion or treat fixture digest output as current Environment Evidence.

Recommendation: proceed to **Quality Verification Matrix Review**. Do not begin capability implementation until Quality completes that input and the Assignment reaches `Ready` through its authorized lifecycle.

## 004C-R1 Handoff Boundary

After capability implementation and acceptance, a separately authorized new 004C-R1 capture must:

1. create a new Environment Capture Run ID;
2. bind exported/supplied roots to that run's deployed environment;
3. invoke the accepted tool explicitly outside Runtime;
4. archive the five manifests, their actual SHA-256 values and provenance envelopes;
5. populate the accepted Template without modifying prior blocked runs.

ENV-TOOLING-001 does not execute these steps and does not authorize 004C-R1, Benchmark or Task 7.
