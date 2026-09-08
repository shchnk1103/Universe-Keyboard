# Independent review: Cross-scheme CSF-PAIR-01 / CSF-PAIR-02

Date: 2026-09-08 Asia/Shanghai
Review type: independent read-only delta review
Reviewed candidate: `1efb886` relative to `8acabd9`
Verdict: **Pass with conditions**

## Review result

The candidate matches the matrix residuals:

- **CSF-PAIR-01:** when Ice is installed and selected, a failed Wanxiang
  deployment does not publish a Wanxiang receipt and retains Ice settings,
  selection, bytes, and temporary-archive cleanup.
- **CSF-PAIR-02:** both active-uninstall directions enter production
  `SchemaManager` control flow and use a real
  `SharedContainerSchemaArchiveInstaller`. The injected second staging move
  fails; target bytes, original selection, peer bytes, and original-scheme
  redeploy sequence are retained.

No P0 or P1 finding was identified.

## Adapter assessment

`DeploymentDirectoryOverrideSchemaArchiveInstaller` only supplies the
temporary-root directory pair for test deployment. It delegates staging,
rollback, commit, installation, and checkpoint operations to the real
installer. The failure and restoration therefore occur in the production
installer's `stageSchemaUninstall` / `rollbackSchemaUninstall` path; the
adapter does not bypass that behavior.

## Conditions and residuals

- **P2:** CSF-PAIR-01 remains a manager-layer deployment-failure proof. Its
  stub installer and transformed minimal archive do not prove real Wanxiang
  installation, full ownership inventory, or partial-install restoration.
- **P2:** CSF-PAIR-02 uses minimal target and peer fixtures. It does not cover
  complete pinned Ice/Wanxiang inventories, Lua exact-hash ownership,
  Prelude/OpenCC, or user files.
- **P3:** real RIME runtime/input, App Group, and physical-device behavior
  remain unproved.
- **P3:** F3 asserts settings, bytes, and deployment-request order; it is not
  evidence for every receipt or deployment-state field.

The automated symmetry and combined manager/real-installer gaps are closed
within these boundaries. This review does not accept ADR 0034, close Wanxiang
P4, pass a Product Gate, authorize PR undraft/merge, TestFlight, or App
Release.
