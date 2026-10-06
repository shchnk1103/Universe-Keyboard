# OWN-EXPORT-001 E0 补正交付（等待 root 核 Ready）

范围：仅私有 run-root 脚本、主机用例、synthetic 隔离与调用账本。不操作设备、不改生产源码、不覆盖原 E0 回执、不进入 E1。

## 新脚本 SHA-256

| 文件 | SHA-256 |
| --- | --- |
| owner_export_callback.py | `5fc756ed525ebb3c71b91a208615eb34249da535617461426399dc61d5cf52e8` |
| host_preflight.py | `146766c07c6b372b3a4edacb367f02cd0058ead0688a1d80cf6fa0bc537468eb` |
| decoder.py（未改，须 byte-identical） | `fc1817ab8843dab76acd9e8ae59277719c059742bb105eebecbc60a66f58775d` |
| lldb-format-suppress.lldb（未改） | `ca06f497c0f2e1d4591e57e59d9d21e1830cf5cda8d359e333cd36645acdf6c9` |
| e0-correction-preflight-results.json | `57c0738349ec0b4c5d05b90b478120ddd5662a8509f52cf8c7ff169efed238b5` |

原 `e0-receipt.json` / `e0-preflight-results.json` SHA 仍为冻结值：`{'e0-receipt.json': True, 'e0-preflight-results.json': True, 'identity-receipt.json': True, 'script-hashes.json': True, 'lldb-format-suppress.lldb': True, 'decoder.py': True}`。

## 预检

- host_preflight exit: `0`
- all_pass: `True`
- fake_api_pass: `True`
- decoder_pass: `True`
- formatter_pass: `True`
- live_isolated_pass: `True`
- fake 输出目录: `/private/tmp/ukey-host-activation-fix-owner-export-20261006/host-fake`

新增主机用例：`configure_old_but_fresh_hit`、`stop_over_120s_before_read`、`stop_over_120s_after_read`。旧 `stop_deadline`（以 configure 计时）已替换。

## 隔离

- 原 fake `callback.json` / `callback-stage.json` / `callback-private.json` 已 **move** 到 `/private/tmp/ukey-host-activation-fix-owner-export-20261006/synthetic-e0-leftover`，marker `not_runtime_receipt=true`。
- 预检前 live 产物存在: `{'callback.json': False, 'callback-stage.json': False, 'callback-private.json': False, 'owner-args.json': False, 'owner-buffer.bin': False}`
- 预检后 live 产物存在: `{'callback.json': False, 'callback-stage.json': False, 'callback-private.json': False, 'owner-args.json': False, 'owner-buffer.bin': False}`
- 预检遇 live 产物会 exit 4 并拒绝 unlink，不会删除真实证据。

## 预算

- 首工具 start UTC（`events.tool_started`，该事件无 tool_call_id）: `2026-10-06T03:39:24.973Z` name=`read_file`
- 首工具 completed UTC: `2026-10-06T03:39:25.029Z` tool_call_id=`call-3c22dc60-e646-4260-994d-9dedb7d570ea-88` duration_ms=`12`
- 交接包 read_file completed: 2026-10-06T03:39:25.033Z `call-3c22dc60-e646-4260-994d-9dedb7d570ea-87`（同批并行必读，晚 4ms）
- 未把 `e0-receipt.utc_start` 当作首工具时间，未重置时钟。
- permission_requested / permission_resolved / loop / phase 不计为调用次数。
- 完成名计数: `{'read_file': 33, 'grep': 7, 'run_terminal_command': 12, 'list_dir': 2, 'write': 2}`
- 完成 outcome: `{'success': 53, 'error': 3}`
- 本补正结束后累计调用（含本 recount shell）: `57` / 60
- 剩余调用: `3`
- 清理保留要求: 12；当前可留: `3`（不足）
- E1 调用上界: `24`（identity / boot / attach / formatter source / Human n·h / freeze / 1 ReadMemory / 回执 / stop；不含清理）
- E1+清理: `36`
- 是否足够进入 E1: false
- 自 first start 墙钟秒: `1136.661`；剩余墙钟秒: `2463.339`
- E1 已进入: false
- 停止原因: `remaining_calls=3 < e1_plus_cleanup=36; cleanup reserve 3 < 12; do not enter E1, do not auto-renew`

详细账本：`/private/tmp/ukey-host-activation-fix-owner-export-20261006/e0-call-ledger.json`

等待 Codex root 核 E1 Ready。预算不足，不得进入 E1、不得自续。
