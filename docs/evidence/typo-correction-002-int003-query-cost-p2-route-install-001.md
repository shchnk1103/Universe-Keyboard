# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001

## 结论

Executor安装身份核对 **Pass**：只在iPhone18 Pro iOS27.0 / UDID405D994F-28CB-4F89-BB22-B64AD81C05A2安装一次新包，native exit0；已安装78files的路径/大小/SHA256与已核验payload manifest完全一致，source25/HEAD前后匹配。0launch/0input/0取证按钮/0LLDB。

Human“确认仍独占，继续吧”授权本轮安装，[Assignment](../assignments/typo-correction-002-int003-query-cost-p2-route-install-001.md) / [独立AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-INSTALL-001.md)已先释放并消费，本轮耗尽；未复用build AUTH。父TYPO-CORRECTION-002 Active。

## 身份与环境

- source HEAD：`72dd21710f2a86c9f951d489f645bae89b053b58`；candidate25 SHA256 `d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`。
- [新包manifest](./typo-correction-002-int003-query-cost-p2-route-payload-001-payload-manifest.json) SHA256 `8bded308bca12cac26d3a1f572287464d1642aea957b338b6d176ebeaa6aa442`。
- [耐久installed identity](./typo-correction-002-int003-query-cost-p2-route-install-001-installed-identity.json) SHA256 `fa3e202ecb98cea227c6fbfc3a0e20ecc00799fea46b3f1fc13314120c218ed8`；App实际bundle路径 `/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/405D994F-28CB-4F89-BB22-B64AD81C05A2/data/Containers/Bundle/Application/89DBF2C8-CE4A-4811-9046-79B27B1D2CB1/Universe Keyboard.app`。
- read-only device discovery仅记录目标405D，Booted/available。未操作其他设备。
- full Appbundle inventory exact match，无额外/缺失文件；包括6MachO的静态UUID和签名权限按字节绑定，未读取loaded UUID或宣称Extension进程已运行。没有访问App Group/用户data内容。

## 精确命令与回执

```json
[
  {
    "stage": "device",
    "argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl",
      "list",
      "devices",
      "--json"
    ],
    "attempt": 1,
    "exit_code": 0,
    "start_utc": "2026-10-10T15:46:19.656099+00:00",
    "elapsed_seconds": 0.612
  },
  {
    "stage": "install",
    "argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl",
      "install",
      "405D994F-28CB-4F89-BB22-B64AD81C05A2",
      "/private/tmp/uk-routepkg1/DD/Build/Products/Debug-iphonesimulator/Universe Keyboard.app"
    ],
    "attempt": 1,
    "exit_code": 0,
    "start_utc": "2026-10-10T15:46:20.268685+00:00",
    "elapsed_seconds": 11.691
  },
  {
    "stage": "app-container",
    "argv": [
      "/Applications/Xcode.app/Contents/Developer/usr/bin/simctl",
      "get_app_container",
      "405D994F-28CB-4F89-BB22-B64AD81C05A2",
      "com.DoubleShy0N.Universe-Keyboard",
      "app"
    ],
    "attempt": 1,
    "exit_code": 0,
    "start_utc": "2026-10-10T15:46:31.963369+00:00",
    "elapsed_seconds": 0.417
  }
]
```

root `/private/tmp/uk-routeinstall1`保存binding/exclusive confirmation、candidate/payload manifest、receipts及filtered device/install/container stdout/stderr、installed identity/archive-manifest。三个native各一次：ready0.612s、install11.691s、container0.417s；无重试/重build。安装正常系统替换可能停止旧进程，本轮不推断UI/进程延续。

## 非声明与交接

本轮无Swift或工程修改，无新test/build/主App启动/输入/取证按钮/部署重试重置/偏好写入/LLDB/Git发布。保留原52测试及finding closure，未称为实际arm成功、真实runtime route、Full Access/RIME ready或正式P2成本证据。无需产品CHANGELOG更新。

下一仅运行前置只读确认：Human在本405D打开App，核对FullAccess、Luna当前/已部署、两诊断关闭，以及搜索输入宿主和四按钮初始状态；先另绑定前置检查权限，不输入、不arm。之后actualarm/正式采集再独立AUTH，不能拿本install授权继续点按钮。技术无blocker，P2真实运行证据未完成，父Active，无Gate/Close/ADR Accept/TestFlight/Release。
