# OpenCC Integration

## Purpose

This document is the Source of Truth for the current OpenCC integration boundary. It records where conversion participates in the product and which repository sources verify that behavior. It is not an OpenCC tutorial, asset inventory or troubleshooting runbook.

## Current Integration

OpenCC participates inside the deployed RIME schema pipeline through the RIME `simplifier` filter and its configured OpenCC resources. Conversion is applied by RIME while producing candidate/output behavior; it is not a post-commit rewrite performed by the main App, Keyboard Extension UI or KeyboardCore.

Current implementation evidence:

- `Packages/KeyboardCore/Sources/KeyboardCore/RimeBaseSchemaTemplates.swift` defines the managed schema template entry.
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+CustomYaml.swift` reads the simplification preference when preparing configuration.
- `Packages/RimeBridge/Sources/RimeBridge/RimeConfigManager+DeploymentResources.swift` prepares deployment resources.
- `Universe Keyboard/Views/Settings/RimeSettingsStore.swift` owns the main-App setting and deployment request flow.

## Responsibility Boundary

- The main App owns the user setting, configuration preparation, resource preparation and full deployment.
- `RimeBridge` owns the configuration/deployment boundary and the real RIME session that consumes deployed filters and resources.
- The Keyboard Extension only creates a session from prepared runtime directories and consumes RIME output. It does not repair OpenCC files or deploy configuration while typing.
- KeyboardCore does not perform an application-layer simplified/traditional conversion after commit.

The shared-container and deployment ownership rules remain authoritative in [Shared Container And RIME Lifecycle](shared-container-and-rime-lifecycle.md) and ADR [0001](decisions/0001-main-app-owns-rime-deployment.md) / [0003](decisions/0003-shared-container-ownership.md).

## Operational Sources

- Configuration/resource/session failure diagnosis: [DEBUGGING](../DEBUGGING.md#simplifiedtraditional-conversion-wrong).
- Performance measurement: [PERFORMANCE_BASELINE](../PERFORMANCE_BASELINE.md#opencc-impact).
- Release evidence: [RELEASE_CHECKLIST](../RELEASE_CHECKLIST.md#rime-lua-and-opencc).
- Binary and packaged artifact changes: [RIME Artifacts](rime-artifacts.md).

## ADR Trigger

Create or supersede an ADR before changing the integration strategy, including moving conversion outside the RIME filter pipeline, changing cross-target ownership, introducing a second conversion authority, or changing persistent resource/deployment ownership. Routine fixes that restore this documented contract require ADR review but not automatically a new ADR.

## Out Of Scope

This document does not own OpenCC internals, exhaustive resource manifests, user-facing copy, debugging steps, performance results, release results or historical migration notes. Those remain in the linked operational, artifact, UI and history sources.
