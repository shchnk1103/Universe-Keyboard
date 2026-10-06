# F2-before 恢复交付 — 2026-10-04

执行方案：`docs/plans/keyboard-wake-host-activation-fix-001-f2-before-restore-plan-2026-10-04.md`。仅恢复原 UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2` 的 F2-before 安装包、主 App 数据和 App Group。恢复后只做机器读回；未启动 App、未重新部署、未试打、未改五文件源码。

完整回执：[`restore-receipt.json`](restore-receipt.json)、[`restore-verification.json`](restore-verification.json)、[`install-receipt.json`](install-receipt.json)。私有工作目录 `/private/tmp/ukey-host-activation-fix-f2-restore-20261004/`。

## 命令与结果

暂存（不改 before 备份）：

```bash
/usr/bin/ditto --rsrc --extattr --acl \
  /private/tmp/ukey-host-activation-fix-f2-backup-20261004/installed-app \
  /private/tmp/ukey-host-activation-fix-f2-restore-20261004/Universe\ Keyboard.app
```

签名核验（暂存包与安装后 live）`codesign --verify --deep --strict` 四次，exit 0。

安装（未 uninstall / erase）：

```bash
xcrun simctl install 405D994F-28CB-4F89-BB22-B64AD81C05A2 \
  /private/tmp/ukey-host-activation-fix-f2-restore-20261004/Universe\ Keyboard.app
```

exit 0；stdout/stderr 空。随后 `ditto --rsrc --extattr --acl` 恢复 51 个应用文件（主数据 3 + Group 48）。命令摘要见 [`restore-commands.json`](restore-commands.json)。

## 核验结果

| 项 | 结果 |
|---|---|
| 独占 UDID / Booted iPhone 18 Pro iOS 27.0 | 通过 |
| 目标 App/appex 进程 | 安装前、安装后、恢复后均为空；未 SIGTERM |
| before 备份身份 | 与 `backup-inventories.json` 全等；文件数/字节与 receipt 一致（copy 相对 live-before 多 883 条 provenance） |
| after 保全 | `/private/tmp/ukey-host-activation-fix-f2-after-preservation-20261004` mode 0700；payload 与安装前 live 一致 |
| 安装后 payload | 78 文件 / 91,344,780 bytes，与 before 文件哈希一致 |
| 恢复动作 | 107：main 3 文件 + 46 移除；group 8 目录 + 48 文件 + 2 内部 symlink |
| 两次读回 | 稳定 |
| 选中偏好 | logging ABSENT；high-fidelity ABSENT；`rime_deployed` true；`rime_needs_deploy` false；`rime_is_deploying` ABSENT |
| 结构计数 | main 827/42/0/1,101,984；group 51/15/2/37,749,287；app 78/9/0/91,344,780 |
| 双签名 | 通过 |

容器 UUID：App `37ACBFEE…` → `9F532453…`；Data `B43FA7F3…` → `FB2E1C3F…`；Group 仍为 `05FFE2DA…`（before 原为 `53661EB9…`）。系统 `.com.apple.mobile_container_manager.metadata.plist`、根身份与 SplashBoard 快照保持安装后 live，未写入旧 UUID metadata。

provenance 例外（payload 仍对齐）：rewritten 54、missing_on_live 8、added 7。不声称全部 xattr 精确相等。

## 未做 / 不声称

未启动 App、未 RIME 再部署、未试打、未改 Keychain / 系统键盘 / Maps。机器恢复不等于输入健康。F3/F4/Release 另授权。五文件哈希仍为 F1 冻结值。全部历史备份与 F2 xcresult 保留。模拟器独占未释放。
