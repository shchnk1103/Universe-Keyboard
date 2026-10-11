# AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-RIME-VENDOR-MATERIALIZATION-002

- 状态：consumed
- 建立时间：2026-09-20 Asia/Shanghai
- 消费时间：2026-09-20 Asia/Shanghai
- Assignment：`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`
- Worktree：`/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001`
- Branch：`codex/typo-correction-002-recall-publication-staging-001`
- Bound HEAD：`162b09fd58ba60538a944026b1902efa405c75aa`
- 前置 staging evidence：`docs/evidence/typo-correction-002-recall-remediation-publication-staging-2026-09-20-001.md`

## 目的

仅在新的 clean staging worktree 中物化并验证固定的 RIME vendor build dependency，使后续质量门拥有可复算的依赖 provenance。旧 worktree 的 vendor materialization receipt 不自动延伸到本 worktree。

## 固定输入

- Version：`rime-vendor-ios-1.16.1-lua.1-octagram.1`
- Archive SHA-256：`d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- Expected vendor tree SHA-256：`d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd`
- Materialization script：`bash scripts/ensure_rime_vendor.sh`

## 允许动作

- 在上述 worktree 内执行 `bash scripts/ensure_rime_vendor.sh fetch` 与 `verify`；
- 下载/验证固定 archive，并只写入 ignored `Packages/RimeBridge/Vendor` 及其 receipt；
- 记录 archive/tree/framework inventory hash 和命令结果；
- 写入 vendor materialization evidence，消费本 Authorization。

## 明确禁止

- 不修改 checked-in source、manifest、schema、RIME bridge、Xcode project 或 Swift tests；
- 不复制 vendor 到其他 worktree，不改变 vendor pin；
- 不部署、不安装、不产生设备/Simulator behavior Run；
- 不 commit、push、PR、merge、TestFlight、Release；
- 不把 vendor verify/fetch 解释为 RIME runtime、候选、INT-003、QA-001、性能或 Product/Quality/Release Gate 结论。

## 退出条件

- 12 个 manifest framework 均通过结构与 receipt 校验；
- archive SHA、receipt version/SHA 和 vendor tree SHA 被 evidence 绑定；
- 若 fetch/verify 失败，保留失败边界，不进入 Xcode 质量门。

## Consumption receipt

- Evidence：`docs/evidence/typo-correction-002-recall-remediation-rime-vendor-materialization-2026-09-20-002.md`
- Result：固定 archive SHA、receipt、12/12 inventory 和 vendor tree identity 均通过；vendor prerequisite 已满足。
- Non-claims：未修改 checked-in source/manifest，未产生产品 Run，未 commit/push/PR/merge。
