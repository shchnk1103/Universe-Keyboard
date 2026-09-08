# Cross-scheme CS-F1 / CS-F3 delta review

Date: 2026-09-08 Asia/Shanghai. Independent read-only review of `889b3a5`
relative to `bf7086f`. The reviewer did not modify files or rerun the full
test suite.

Verdict: **Pass with conditions**. This is a local engineering-candidate
review; it does not close the Assignment or any Product, Device, ADR, merge,
TestFlight, or Release gate.

- CS-F1 now reaches the controlled deployment service through the production
  `SchemaManager` control flow. It asserts the Ice deployment request and
  failed state, no Ice receipt fields, Wanxiang byte/receipt/selection
  retention, and temporary-archive cleanup.
- CS-F1 uses a test installer that supplies real directories and a T9 fixture.
  It proves manager flow, receipts, selection, deployment request, and
  temporary-file behavior; it does not prove a production installer resource
  tree.
- CS-F3 uses the production installer plus a test-only FileManager failure seam
  to prove target rollback and peer/unknown/user-file retention. Its selection
  tracker is a harness: production manager selection retention is not combined
  with the real-installer mid-move failure in one test.

## Conditions and residual disposition

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| CSF-PAIR-01 | Assignment executor | Fix in a separately authorized slice | Symmetric Wanxiang CS-F1/CS-F3 failure injection remains absent. |
| CSF-PAIR-02 | Assignment executor | Fix in a separately authorized slice | Combine production `SchemaManager` selection retention with a real-installer CS-F3 mid-move failure. |

Executor validation is recorded separately in the
[CS-F1 / CS-F3 evidence](../evidence/scheme-delivery-cross-scheme-csf1-csf3-2026-09-08.md): strict formatting/lint, two focused tests, and full App + Keyboard
tests. It is executor evidence, not reviewer-run verification.
