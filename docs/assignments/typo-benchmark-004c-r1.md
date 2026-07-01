# Assignment: TYPO-BENCHMARK-004C-R1 — Physical Device Deployment & Environment Capture

> **Record type:** Task-specific Assignment Record
>
> **Policy version:** `1.0.0`
>
> **Lifecycle status:** Assigned / Not Ready

This record applies [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) to `TYPO-BENCHMARK-004C-R1`. It records the current Assignment Decision without creating or transferring permanent ownership.

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: `PM-SYNC-002` latest Product Lead Assignment Decision / 2026-07-01 Asia/Shanghai
- Product Approver: Product Lead

## Boundary

- Scope: On the designated physical device, prepare and verify the deployment environment for `TYPO-BENCHMARK-004C-R1`; capture the exact device, OS, build, deployed artifacts, active runtime schema, Full Access state, canonical clean state and Real RIME `nihoa-satisfied` / `nihoa-unsatisfied` environment facts; preserve a traceable evidence package for Quality review.
- Non-goals: Do not make a Quality conclusion or Product Gate decision; do not change Product Contracts, ADRs, Registry entries or production implementation; do not start Task 7; do not expand beyond physical-device deployment and environment capture.
- Required Inputs: Assignment Policy v1.0.0; Registry v1.0.0 at `49b000bcbb3a90d04f00dd803981a24a25b70e28`; ADR 0010 at `6bb6b1412240ca70e7c965592ccff429ce1a9929`; accepted governance commit `4188dccef2083e998185e242c6d5ab45af3ea9b4`; 004D implementation commit `3f948cfac8b2b303a03de6fefe24b3258adfcb02`; the accepted [`004C-R1 Environment Evidence Template v1.0.0`](../evidence/004c-r1-environment-evidence-template.md); designated unlocked physical device and required access from the Human Dependency; identified build, deployment artifacts and schema target; agreed canonical clean-state procedure; evidence archive location and policy.

## Assignment

- Domain Owner: RIME Platform Maintainer
- Executor: RIME Platform Maintainer
- Environment Executor: RIME Platform Maintainer
- Human Dependency: Universe Keyboard 人类项目负责人（当前用户）— provide the designated unlocked physical device and required access
- Architecture Reviewer: `Not Applicable — the Product Lead Assignment Decision states that Architecture Review is not required for this bounded environment-capture task.`
- Quality Reviewer: Quality, Performance & Release Maintainer

## Gates

- Entry Criteria:
  - The Assignment Record is complete and the RIME Platform Maintainer has acknowledged the Scope, dependencies and ability to proceed.
  - The Human Dependency has provided the designated unlocked physical device and required access.
  - The exact build, deployment artifacts and schema target are identified and frozen for the run.
  - The Environment Executor uses the accepted [`004C-R1 Environment Evidence Template v1.0.0`](../evidence/004c-r1-environment-evidence-template.md) as the only capture, provenance and archive contract.
  - Full Access can be set and its actual state can be observed.
  - The canonical clean-state procedure is agreed and executable on the designated device.
  - The evidence archive location and policy are identified before capture begins.
- Exit Criteria:
  - Device, OS, build, commit and deployed artifact identity are captured.
  - Deployment state and actual active runtime schema are verified and recorded.
  - Full Access state and canonical clean state are verified and recorded.
  - Real RIME `nihoa-satisfied` and `nihoa-unsatisfied` environment results are captured, including explicit blocked or failed results where applicable.
  - Evidence is preserved at the agreed archive location with sufficient provenance for independent Quality review.
  - The handoff reports completed evidence, unresolved blockers, skipped checks and residual risks without making a Quality or Product conclusion.
- Stop Conditions: The designated device, access or required environment becomes unavailable; build, deployment artifacts or schema target are not frozen; canonical clean state cannot be established; evidence provenance or archive location is unavailable; requested action exceeds Scope; an Assignment responsibility changes without Product Lead revalidation; Task 7 lacks explicit Product authorization.

## Handoff

- Handoff Target: Quality, Performance & Release Maintainer
- Required Handoff Content: Current status, environment state, captured evidence locations, unresolved risks, Stop Conditions and next required review.
- Revalidation Trigger: Any change to Scope, Domain Owner, Executor, Environment Executor, Human Dependency, reviewer, designated device, build, deployment artifacts, schema target, evidence archive policy or Product Decision requires Product Lead revalidation before work proceeds.

## Completeness Check

Status: **Complete with no `UNKNOWN` fields**. Completeness does not make the task `Ready`; every Entry Criterion must have current evidence before a separate lifecycle decision.
