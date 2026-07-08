# Knowledge OS 2.0

> **Version:** `2.0.0`
>
> **Status:** Knowledge OS 2.0 canonical specification and Zero-Context Startup Layer accepted
>
> **Source of Truth:** this directory
>
> **Assignments:** [`KOS-GOV-001`](../assignments/kos-gov-001.md), [`KOS-BOOT-001`](../assignments/kos-boot-001.md)

This directory is the canonical repository-backed specification for Knowledge OS 2.0.

Knowledge OS 2.0 is a governance specification. It defines how repository knowledge is organized, assigned, changed, reviewed and migrated. It is not product runtime behavior, implementation code, Benchmark evidence or repository migration output.

## Canonical Documents

- [`Knowledge OS 2.0 Specification`](knowledge-os-2.0-specification.md) — frozen principles, authority model, lifecycle model, state and phase model, task level specification, repository change policy, migration specification and repository structure specification.
- [`Zero-Context Startup Layer`](zero-context-startup.md) — startup workflow, reading order, discovery rules, repository-truth discovery, validation and prompt compression guidance for new AI sessions.
- [`Migration Readiness Assessment`](migration-readiness.md) — readiness assessment for future migration work. It does not execute migration.

## Authority Boundary

The published [`KOS-GOV-001 Assignment`](../assignments/kos-gov-001.md) remains the execution authority for the canonical Knowledge OS 2.0 specification publication. The published [`KOS-BOOT-001 Assignment`](../assignments/kos-boot-001.md) is the execution authority for the Zero-Context Startup Layer.

If this directory conflicts with the applicable Assignment, return to Product Lead for revalidation. Do not resolve the conflict by redesigning Knowledge OS.

## Non-goals

This directory does not authorize:

- repository migration;
- implementation work;
- production code changes;
- test changes;
- Runtime, RIME, Benchmark, Registry or ADR changes;
- Knowledge OS 3.0;
- new roles, lifecycle concepts, object models or governance principles.
