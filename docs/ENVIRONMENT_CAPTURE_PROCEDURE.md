# Universe Keyboard Environment Capture Procedure v1.0

> **Version:** `1.0.0`
>
> **Status:** Proposed
>
> **Source of Truth:** This document is the only repository authority for environment-capture preparation, execution sequencing, observation handling, handoff and correction procedure.
>
> **Scope:** Documentation governance and evidence operations only. This procedure does not define evidence fields, change product/runtime behavior, make a Quality decision or authorize benchmark execution.

## Purpose

Provide one repeatable procedure for collecting environment evidence without confusing tool output, operator expectation or fixture metadata with observed environment facts. A capture is complete only when its owning evidence template can be populated with traceable provenance and handed off without rewriting the run.

## Authority And Boundaries

This procedure coordinates, but does not duplicate, the following authorities:

- [`ASSIGNMENT_POLICY.md`](ASSIGNMENT_POLICY.md) owns Assignment authority, completeness, lifecycle and handoff fields.
- The applicable accepted evidence template owns required fields, allowed provenance values, unavailable representation, Run ID, naming, blocking and archive contracts. For `004C-R1`, use [`004C-R1 Environment Evidence Template v1.0`](evidence/004c-r1-environment-evidence-template.md).
- [ADR 0010](architecture/decisions/0010-debug-only-decision-trace-and-evidence-provenance-boundary.md) owns the boundary between execution facts, fixture expectations, environment metadata and debug-only decision traces.
- [`DOCUMENTATION_GOVERNANCE.md`](DOCUMENTATION_GOVERNANCE.md) owns documentation lifecycle and one-fact-one-owner rules.

When these sources conflict, stop before capture and return the conflict to the owner of the higher-level contract. This procedure must not reinterpret a required field, relax provenance or convert unavailable evidence into an observed fact.

## Roles

- **Product Approver:** authorizes the task and its Assignment; does not manufacture evidence.
- **Domain Owner:** owns environment-domain correctness and resolves domain blockers.
- **Executor / Environment Executor:** performs the approved procedure, records observations and preserves artifacts.
- **Human Dependency:** provides only the access or physical action named by the Assignment. Human recollection is not execution evidence.
- **Architecture Reviewer:** owns procedure and Source-of-Truth boundary questions, not Quality acceptance.
- **Quality Reviewer:** evaluates completeness and validity against the accepted template; does not add unpublished requirements.
- **Program Manager:** checks Assignment completeness and routes handoffs; does not assign work or make evidence conclusions.

The task-specific Assignment is authoritative for the actual names and any justified `Not Applicable` fields.

## Preconditions

Before generating a Run ID, the Executor must confirm:

1. the task Assignment has no `UNKNOWN` required field and is allowed to proceed;
2. the accepted evidence template and its fixed inputs are identified;
3. source, build target, artifact, device, schema target and evidence location are frozen as required by that template;
4. the designated device and Human Dependency access are available;
5. capture tools can preserve raw output without exposing credentials, raw user text, user dictionary content or unredacted device identifiers;
6. the archive destination and handoff target are known.

If a precondition fails, do not improvise a substitute. Record the task as not ready or blocked according to the owning Assignment and template.

## Capture Lifecycle

### 1. Prepare

- Start from the frozen inputs and record any working-tree or artifact mismatch before build or installation.
- Establish the template-required clean-state procedure without deleting or inspecting user data outside the approved scope.
- Verify that filenames, redaction and archive destinations satisfy the template before collecting payloads.

### 2. Start The Run

- Generate the Run ID exactly as required by the template.
- Bind every observation and artifact to that Run ID.
- A rebuild, reinstall, device change, schema change, clean-state reset or restarted capture begins a new run when the template says the environment identity changed.

### 3. Capture In Dependency Order

Capture evidence in the following order so downstream facts can be correlated to their prerequisites:

1. source and working-tree identity;
2. build, signing and build-artifact identity;
3. installation and installed-bundle identity;
4. device, access and App Group observations;
5. deployment and deployed runtime artifacts;
6. active runtime, schema and session observations;
7. clean-state facts and any task-authorized scenario availability;
8. artifact inventory, digests and final manifest.

The detailed fields and allowed `source` values come only from the evidence template. A value inferred from eligibility, expected configuration, source inspection or an earlier run is not an observation from the current run.

### 4. Classify Every Observation

For each required fact, use exactly one of these outcomes:

- **Observed:** the accepted provenance source produced the fact during the current run.
- **Unavailable:** the fact could not be obtained through an accepted source; use the template's unavailable representation and name the reason, owner and retry condition.
- **Contradicted:** an accepted observation conflicts with a frozen input or another same-run observation; preserve both artifacts and block the run.

Never replace an unavailable or contradicted fact with operator recollection, fixture expectation, a build-time value where installed/runtime provenance is required, or output from another run.

## Tool Observation And False-negative Rule

Command success means only that the command produced the recorded output. Command failure, an empty listing or an inaccessible domain does not by itself prove that the corresponding device resource is absent.

In particular, `devicectl` access to an `appGroupDataContainer` can produce a false negative. Its failure or empty result must be recorded as a tool-observation limitation, not as proof that:

- the App Group container does not exist;
- the Main App or Extension cannot access it;
- deployment did not occur; or
- a runtime directory is absent.

An absence claim requires a template-authorized observation that can actually enumerate or inspect the relevant boundary in the current run. Otherwise record the field as unavailable and preserve the command, arguments, exit status, timestamp and redacted output as supporting evidence. Matching entitlements or a reachable container also cannot, by themselves, prove that both running processes accessed the same container.

Tool limitations are environment blockers or retry conditions; they are not Product failures and must not trigger a runtime change from this procedure.

## Artifact Integrity And Archive

- Preserve raw capture artifacts before preparing summaries.
- The environment record references artifacts; it does not replace them.
- Populate each template-required digest with the actual SHA-256 value. A phrase such as `recorded in manifest` is not a digest.
- Generate the final checksum manifest only after the archived artifact set is complete, using the naming and coverage rules in the template.
- Treat a handed-off run as immutable. Corrections use a new Run ID when required by the template; never silently rewrite a blocked run.
- A Git commit is one valid repository preservation mechanism, but it is not automatically the only permitted archive backend. The accepted template governs repository or external immutable storage requirements.

## Stop Conditions

Stop capture and preserve the current run when:

- an Assignment responsibility, frozen input or evidence authority is missing or changes;
- required provenance cannot be obtained and the template requires the fact;
- artifacts from different runs, builds, devices or environments would need to be combined;
- a tool limitation is being treated as an observed absence;
- satisfying a request would require changing Product Contract, runtime, RIME Bridge, session, candidate behavior, Registry, ADR, template or privacy boundary;
- evidence would expose prohibited user or device data;
- Task 7 or another execution gate lacks explicit Product authorization.

The Executor records the template-defined blocked state and hands the evidence to the named reviewer. The Executor does not redesign the contract during capture.

## Handoff And Correction

The handoff must provide:

- Run ID and lifecycle status;
- frozen source/build/device/environment identity;
- canonical evidence location;
- environment record and checksum manifest;
- observed, unavailable and contradicted facts with provenance;
- tool limitations, blocked reasons and retry conditions;
- confirmation that no artifacts from another run were merged.

Quality reviews the package against the accepted template. If Quality requests a field or artifact not required by that template, route the interpretation question to Architecture before changing the procedure. If the package failed an existing template requirement, the Environment Executor may correct the capture process directly; immutable-run rules still apply.

## Change And Publication Lifecycle

- `Proposed` revisions are review artifacts and are not binding until Product publication acceptance.
- Accepted editorial clarifications may retain the patch version only when they do not change responsibilities, provenance, stop conditions or required evidence.
- Any change to responsibility boundaries, accepted provenance meaning, privacy, archive semantics or stop conditions requires Product and Architecture review before publication.
- Evidence-template field changes belong in the template, not this procedure.
- Runtime observability or production-boundary changes follow the applicable ADR and separate implementation task.

## Related Documents

- [Assignment Policy](ASSIGNMENT_POLICY.md)
- [004C-R1 Environment Evidence Template](evidence/004c-r1-environment-evidence-template.md)
- [ADR 0010 — Debug-only Decision Trace & Evidence Provenance Boundary](architecture/decisions/0010-debug-only-decision-trace-and-evidence-provenance-boundary.md)
- [Documentation Governance](DOCUMENTATION_GOVERNANCE.md)
- [Knowledge Dependencies](KNOWLEDGE_DEPENDENCIES.md)
