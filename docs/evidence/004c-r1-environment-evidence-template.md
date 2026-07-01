# 004C-R1 Environment Evidence Template

> **Version:** `1.0.0`
>
> **Status:** Accepted
>
> **Source of Truth:** This is the only repository authority for the `TYPO-BENCHMARK-004C-R1` environment evidence format, provenance, unavailable representation, blocking rules and archive contract.
>
> **Scope:** Environment capture only. This template does not make a Quality decision, run a Benchmark or authorize Task 7.

## Fixed Inputs

- Source commit: `3f948cfac8b2b303a03de6fefe24b3258adfcb02`
- Active schema: `rime_ice`
- Build identity: regenerate and reinstall for each capture run
- Registry version: `1.0.0`
- Registry commit: `49b000bcbb3a90d04f00dd803981a24a25b70e28`

## Environment Evidence Record

Every field below must be present. Required fields must contain a trusted value; optional fields may use the unavailable form defined later.

```yaml
template:
  name: "TYPO-BENCHMARK-004C-R1 Environment Evidence"
  version: "1.0.0"
  source_commit_required: "3f948cfac8b2b303a03de6fefe24b3258adfcb02"

capture:
  run_id: "<RFC-4122 UUID v4, lowercase canonical form>"
  timestamp:
    value: "<ISO-8601 UTC timestamp>"
    source: "system_observed"
  captured_by: "<maintainer identity>"
  evidence_location: "evidence/typo-benchmark/004c-r1/<UTC-date>/<run-id>/"
  status: "<captured|blocked>"
  blocked_reasons: []

source:
  commit:
    value: "3f948cfac8b2b303a03de6fefe24b3258adfcb02"
    source: "vcs_observed"
  working_tree:
    value: "<clean|dirty>"
    source: "vcs_observed"
  dirty_paths:
    value: []
    source: "vcs_observed"

build:
  regeneration_confirmed:
    value: "<true|false>"
    source: "build_observed"
  installation_confirmed:
    value: "<true|false>"
    source: "device_observed"
  xcode_version:
    value: "<version and build>"
    source: "build_observed"
  swift_version:
    value: "<version>"
    source: "build_observed"
  configuration:
    value: "<Debug|dedicated non-shipping Evidence>"
    source: "build_observed"
  archive_or_derived_data_identity:
    value: "<path or artifact ID>"
    source: "build_observed"
  build_timestamp:
    value: "<ISO-8601 UTC timestamp>"
    source: "build_observed"

device:
  model:
    value: "<model>"
    source: "system_observed"
  hardware_identifier:
    value: "<machine identifier>"
    source: "system_observed"
  device_identifier:
    value: "<redacted or hashed identifier>"
    source: "system_observed"
  os_version:
    value: "<exact version and build>"
    source: "system_observed"
  locale:
    value: "<locale|null>"
    source: "<system_observed|unavailable>"
  thermal_state:
    value: "<nominal|fair|serious|critical|null>"
    source: "<system_observed|unavailable>"
  debugger_attached:
    value: "<true|false|null>"
    source: "<system_observed|unavailable>"

signing:
  team_identifier:
    value: "<Team ID>"
    source: "codesign_observed"
  main_app_signing_identifier:
    value: "<application-identifier>"
    source: "codesign_observed"
  extension_signing_identifier:
    value: "<application-identifier>"
    source: "codesign_observed"
  main_app_entitlements_digest:
    value: "<SHA-256>"
    source: "codesign_observed"
  extension_entitlements_digest:
    value: "<SHA-256>"
    source: "codesign_observed"
  signature_validation:
    value: "<valid|invalid>"
    source: "codesign_observed"

application_identity:
  main_app:
    bundle_identifier:
      value: "<bundle ID>"
      source: "installed_bundle_observed"
    version:
      value: "<CFBundleShortVersionString>"
      source: "installed_bundle_observed"
    build_number:
      value: "<CFBundleVersion>"
      source: "installed_bundle_observed"
    executable_uuid:
      value: "<Mach-O UUID>"
      source: "installed_bundle_observed"
  keyboard_extension:
    bundle_identifier:
      value: "<bundle ID>"
      source: "installed_bundle_observed"
    version:
      value: "<CFBundleShortVersionString>"
      source: "installed_bundle_observed"
    build_number:
      value: "<CFBundleVersion>"
      source: "installed_bundle_observed"
    executable_uuid:
      value: "<Mach-O UUID>"
      source: "installed_bundle_observed"

access:
  keyboard_enabled:
    value: "<true|false>"
    source: "device_observed"
  full_access:
    value: "<enabled|disabled|unavailable>"
    source: "extension_runtime_observed"
  observation_method:
    value: "<method>"
    source: "capture_procedure"

app_group:
  identifier:
    value: "<App Group ID>"
    source: "entitlements_observed"
  main_app_access:
    value: "<available|unavailable>"
    source: "runtime_observed"
  extension_access:
    value: "<available|unavailable>"
    source: "runtime_observed"
  container_identity:
    value: "<redacted path or stable digest>"
    source: "runtime_observed"
  same_container_confirmed:
    value: "<true|false|unavailable>"
    source: "runtime_observed"

deployment:
  performed_by:
    value: "main_app"
    source: "runtime_observed"
  completed:
    value: "<true|false|unavailable>"
    source: "runtime_observed"
  deployment_timestamp:
    value: "<ISO-8601 UTC timestamp|null>"
    source: "<runtime_observed|unavailable>"
  pending_deployment:
    value: "<true|false|unavailable>"
    source: "runtime_observed"
  runtime_directories_available:
    value: "<true|false|unavailable>"
    source: "runtime_observed"
  deployment_evidence_location:
    value: "<path or URI|null>"
    source: "<capture_artifact|unavailable>"

schema:
  required_identifier: "rime_ice"
  active_identifier:
    value: "<schema ID>"
    source: "rime_runtime_observed"
  schema_version:
    value: "<version or commit>"
    source: "verified_manifest"
  active_schema_confirmed:
    value: "<true|false|unavailable>"
    source: "rime_runtime_observed"
  schema_digest:
    value: "<SHA-256>"
    source: "verified_manifest"

runtime:
  librime_version:
    value: "<version>"
    source: "runtime_observed"
  vendor_artifact_version:
    value: "<version>"
    source: "verified_manifest"
  vendor_manifest_digest:
    value: "<SHA-256>"
    source: "verified_manifest"
  shared_runtime_digest:
    value: "<SHA-256 manifest digest>"
    source: "verified_manifest"
  user_configuration_digest:
    value: "<SHA-256 manifest digest>"
    source: "verified_manifest"
  effective_configuration_digest:
    value: "<SHA-256>"
    source: "verified_manifest"
  lua_capability:
    value: "<available|unavailable|null>"
    source: "<runtime_observed|unavailable>"
  opencc_assets_digest:
    value: "<SHA-256 manifest digest|null>"
    source: "<verified_manifest|unavailable>"

canonical_clean_state:
  main_app_rebuilt:
    value: "<true|false>"
    source: "capture_procedure"
  app_reinstalled:
    value: "<true|false>"
    source: "device_observed"
  extension_reinstalled:
    value: "<true|false>"
    source: "device_observed"
  deployment_recreated:
    value: "<true|false>"
    source: "runtime_observed"
  extension_process_restarted:
    value: "<true|false>"
    source: "device_observed"
  unfinished_composition:
    value: "<absent|present|unavailable>"
    source: "extension_runtime_observed"
  typo_learning_state:
    value: "<empty|declared-scenario|unavailable>"
    source: "verified_manifest"
  rime_user_state:
    value: "<clean-fixture|preserved|unavailable>"
    source: "verified_manifest"
  experiment_flags:
    insertion:
      value: "<true|false|unavailable>"
      source: "extension_runtime_observed"
    transposition:
      value: "<true|false|unavailable>"
      source: "extension_runtime_observed"
    typo_partial_commit:
      value: "<true|false|unavailable>"
      source: "extension_runtime_observed"
  clean_state_manifest_digest:
    value: "<SHA-256>"
    source: "verified_manifest"

session:
  process_identity:
    value: "<redacted PID plus process-start timestamp>"
    source: "runtime_observed"
  invocation_id:
    value: "<trace invocation UUID|null>"
    source: "<debug_decision_trace|unavailable>"
  session_state:
    value: "<fresh|active|recovered|unavailable>"
    source: "runtime_observed"
  session_created_at:
    value: "<ISO-8601 UTC timestamp|null>"
    source: "<runtime_observed|unavailable>"
  active_schema_at_session:
    value: "<schema ID|null>"
    source: "<rime_runtime_observed|unavailable>"
  deployment_during_session:
    value: "<observed|not_observed|unavailable>"
    source: "runtime_observed"
  decision_trace_available:
    value: "<true|false>"
    source: "build_observed"

artifacts:
  environment_manifest:
    location: "<path or URI>"
    digest: "<SHA-256>"
  build_log:
    location: "<path or URI>"
    digest: "<SHA-256>"
  installation_evidence:
    location: "<path or URI>"
    digest: "<SHA-256>"
  signing_report:
    location: "<path or URI>"
    digest: "<SHA-256>"
  deployment_report:
    location: "<path or URI>"
    digest: "<SHA-256>"
  runtime_report:
    location: "<path or URI>"
    digest: "<SHA-256>"
  session_report:
    location: "<path or URI>"
    digest: "<SHA-256>"
```

## Field Requirements

### Required

- Capture Run ID, timestamp, capturer and evidence location.
- Source commit and working-tree state.
- Fresh build and installation confirmation, toolchain and build identity.
- Device model, hardware identity and exact OS version/build.
- Main App and Extension signing, bundle, version, build and executable UUID identity.
- Keyboard-enabled and Full Access state.
- App Group identity, access from both processes and same-container result.
- Deployment completion, pending state and runtime-directory availability.
- Active schema identity and confirmation; it must be `rime_ice`.
- librime, vendor artifact, schema, runtime and effective-configuration identity/digests.
- Canonical Clean State fields and digest.
- Session state and active-schema observation.
- Environment manifest and required artifact locations/digests.

### Optional

- Locale, thermal state and debugger attachment.
- Lua capability and OpenCC asset digest when outside the capture claim.
- Exact session-creation timestamp and trace invocation ID when existing observation cannot provide them.
- Auxiliary screenshots or videos.

Optional fields cannot be fabricated. Use the unavailable form when they cannot be observed.

## Unavailable Representation

Do not use an empty string, `unknown`, `N/A` or a Fixture placeholder.

```yaml
field:
  value: null
  source: "unavailable"
  unavailable:
    reason: "<specific reason>"
    owner: "<role responsible for the missing fact>"
    retry_condition: "<condition that permits recollection>"
```

For an enum-shaped field, use `unavailable` and add `unavailable_reason` at the same level.

## Provenance Contract

Allowed source values:

- `vcs_observed`
- `build_observed`
- `system_observed`
- `codesign_observed`
- `installed_bundle_observed`
- `device_observed`
- `entitlements_observed`
- `runtime_observed`
- `extension_runtime_observed`
- `rime_runtime_observed`
- `verified_manifest`
- `debug_decision_trace`
- `capture_procedure`
- `capture_artifact`
- `unavailable`

Prohibited sources include `fixture_declared`, `expected`, `assumed`, user recollection and unclassified handwritten strings. Environment facts must bind to one Run ID. Evidence from different runs, commits, builds or devices must not be merged.

All digests use SHA-256. The manifest must record the digest algorithm explicitly.

## Blocked Rules

Set `capture.status` to `blocked` and record one or more `blocked_reasons` when:

- Source commit differs from the frozen commit.
- The build includes unrecorded working-tree changes.
- The App and Extension were not rebuilt and reinstalled for the run.
- Installed bundles cannot be linked to the captured build identity.
- Signing is invalid or Main App and Extension Team IDs conflict.
- Main App or Extension identity cannot be confirmed.
- Full Access cannot be observed from the Extension runtime boundary.
- Main App and Extension cannot be shown to access the same App Group container.
- Main-App deployment is incomplete or unavailable.
- The active schema is not `rime_ice` or cannot be observed.
- A required artifact, schema, runtime or configuration digest is missing.
- Canonical Clean State cannot be established.
- Session state cannot be correlated to the current installation, deployment and schema.
- Any required environment fact is unavailable.
- The environment manifest digest is missing or fails verification.
- Artifacts from different Run IDs, commits, builds or devices are combined.
- A Fixture or expectation is used as an execution or environment fact.

Blocked means environment evidence is incomplete. It does not mean a Benchmark Case failed.

## Run ID Generation Rule

- Generate one cryptographically random RFC 4122 UUID version 4 at the start of capture.
- Serialize it in lowercase canonical form: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`.
- Reuse the same Run ID for every artifact produced by that single build/install/environment capture.
- Never reuse a Run ID after a rebuild, reinstall, device change, schema change, clean-state reset or restarted capture.
- A retry after a blocked run receives a new Run ID; the earlier blocked record remains immutable.

## Evidence Location And Naming

The canonical logical location is:

```text
evidence/typo-benchmark/004c-r1/<YYYY-MM-DD-UTC>/<run-id>/
```

Required names:

```text
004c-r1_<run-id>_environment.yaml
004c-r1_<run-id>_environment.sha256
004c-r1_<run-id>_build.log
004c-r1_<run-id>_signing.txt
004c-r1_<run-id>_install.txt
004c-r1_<run-id>_deployment.json
004c-r1_<run-id>_runtime.json
004c-r1_<run-id>_session.json
004c-r1_<run-id>_manifest.sha256
```

Large or sensitive artifacts may live in approved external evidence storage. The environment record must retain their immutable URI, SHA-256 digest and access owner at the canonical logical location. File names must not contain a device UDID, username, absolute App Group path or other sensitive local identity.

## Archive Policy

- A capture directory is immutable after handoff. Corrections require a new Run ID.
- Preserve captured and blocked runs; do not overwrite or silently delete failed attempts.
- The SHA-256 manifest covers every archived artifact and is generated after capture completes.
- Store the environment record and checksum manifest in repository-managed evidence when permitted. Store large or sensitive payloads externally and retain immutable references and digests.
- Retain the archive through 004C-R1 Quality review, Product acceptance and every downstream evidence decision that cites the Run ID.
- Deletion or relocation requires the evidence owner to preserve a replacement immutable reference and update every active citation.
- Archive access must follow least privilege and must not expose raw user text, user dictionary content, unredacted device identifiers or credentials.

## RIME Platform Handoff Requirements

The RIME Platform Maintainer must submit:

- Active schema observation proving `rime_ice`.
- Exact librime and vendor artifact versions.
- Vendor manifest, schema, shared runtime, user configuration and effective configuration digests.
- Main-App deployment completion state and timestamp.
- Observation of whether deployment occurred during the Extension session.
- Shared/user runtime-directory availability.
- App/Extension shared-container consistency.
- Schema selection correlated with the current session.
- Session state: fresh, active or recovered.
- Lua and OpenCC resource state when included in the environment claim.
- Canonical Clean State and the treatment of RIME user state.
- Source, Run ID, timestamp, evidence location and SHA-256 for every submitted fact.

This handoff reports environment facts only. It does not make a Quality conclusion or authorize Benchmark execution or Task 7.
