# Assignment: INPUT-RELIABILITY-DELIVERY-002 — Input Reliability Batch 2 Delivery

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Current phase | Active: extract and locally validate Batch 2 on an isolated carrier |
| Material non-claims | Not an Architecture, Quality, or Product Gate. Not a product push, pull request, merge, TestFlight, or Release. R345 stays evidence-insufficient until this batch records a bounded conclusion. R174 stays off. The original INPUT-RELIABILITY-B-001 Assignment and worktree are not migrated. INPUT-RELIABILITY-DELIVERY-001 stays Closed on its own carrier. |
| Next handoff / decision | Human Product Lead decides whether this carrier may be pushed as a product pull request after local validation and independent review |
| Residuals | T9 delete and retype recovery, partial-commit failure protection, R174 enablement, and phases C and D stay out of this batch. |

---

## Authority

- Assignment Authority / Product Approver: Human Product Owner acting as Product Lead.
- Decision Source / Date: Human Product Lead authorization in the current Grok Build session, 2026-10-19 Asia/Shanghai. Task ID `INPUT-RELIABILITY-DELIVERY-002`.

## Task Workspace

This Assignment opts in to `ops/task-workspace.md` at Kit commit `9ca6dc015bf01084150538aac65cedc25b2a33a5` (sha256 `91d3da26728c210de3b605f28f65e0377f9ee90b2f0eaf65c8e12b7f8cb5f76a`).

The initial writer lane is `grok-build`. There is no predecessor writer, so the first `CHECKPOINT` establishes `W`. No `HANDOFF` or `ACCEPT` is created for that initialization. Writer authority is not inherited from INPUT-RELIABILITY-DELIVERY-001.

## Boundary

- Scope: candidate source identity; stable candidate identity across paging; candidate page consumption; native candidate selection bound to that identity; owner, session, and epoch validity; refusal of a stale candidate; the regression tests that cover those behaviors.
- Non-goals: T9 delete and exact retype recovery; partial-commit failure protection; enabling R174; R349; Build 94 deploy-crash investigation; phases C and D; production deploy lifecycle changes; migrating INPUT-RELIABILITY-B-001; editing the original Codex worktree, the Batch 1 worktree, the Claude recovery worktree, or the main checkout.
- Required Inputs: `origin/main` `bb430f914deaf7b19a61183f744b5dcf2fdb8eae`, which contains Batch 1; the read-only Codex worktree at HEAD `eedbee993f8d89cd283c1487356f27f66c5e044a` as the extraction source.
- Project baseline: isolated worktree `grok/input-reliability-delivery-002` from that `origin/main`.

## Assignment

- Domain Owner: Keyboard input runtime.
- Executor: Grok Build, lane `grok-build`.
- Environment Executor: Grok Build on this Mac, using the already booted iPhone 17 Pro simulator only when a simulator test is required.
- Human Dependency: Human Product Lead — product push, pull request, and merge.
- Architecture Reviewer: Not yet assigned. Independent review is outside this implementation authorization.
- Quality Reviewer: Not yet assigned. Independent review is outside this implementation authorization.
- Product Approver: Human Product Owner.

## Gates and Handoff

- Entry: Human named this Task ID, the initial executor, and the Batch 2 scope; `origin/main` was reconfirmed at `bb430f914deaf7b19a61183f744b5dcf2fdb8eae`.
- Exit: Batch 2 source and tests are committed on the carrier; the authorized local checks have a recorded result; no product pull request exists.
- Stop: a hard dependency on Batch 3 design; an unbounded wrong-selection risk that a Batch 2 constraint cannot close; loss of a unique writer; any need to modify the original Codex worktree.
- Handoff Target: Human Product Lead.
- Required Handoff Content: carrier HEAD, extracted paths, the R345 conclusion for this batch, checks run, and whether an independent review can start.
- Revalidation Trigger: `origin/main` moves under this branch; the pinned Task Workspace file changes; Human changes the batch boundary.

## History

- 2026-10-19 Asia/Shanghai: Human Product Lead authorized this new Assignment and named Grok Build as the initial executor. The original INPUT-RELIABILITY-B-001 Assignment and the Closed INPUT-RELIABILITY-DELIVERY-001 Assignment stay unchanged.
