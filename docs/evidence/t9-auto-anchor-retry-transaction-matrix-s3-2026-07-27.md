# T9 S3：后续机会真实事务与两音节回退矩阵

**日期：** 2026-07-27
**设备：** iPhone 17 Pro Max Simulator / iOS 27
**测试目标：** `RimeBridgeTests`
**运行时：** 隔离的 pinned librime `1.16.1` T9 fixture
**测试串：** `mingtianzaoshangwomenyiqiqugongyuanpaobu`（40 个 T9 槽位）

## 目的与生产边界

前序只读影子观测发现，首次 S2 事务在第 18 槽被拒绝后，后续有 14 个
稳定的 `proposalReady` 位置。本矩阵在隔离的 XCTest RIME session 中
实际执行这些提议，以回答：

1. 后续最大公共前缀能否通过现有候选守恒门；
2. 若最大前缀失败，逐音节缩短是否存在安全边界；
3. 安全边界是否降低后续 `process_key` 耗时。

矩阵不调用 `KeyboardController`，不修改生产一次尝试 ledger，不编译进
Keyboard Extension，也不触碰 App Group 或正式用户词典。每次测试事务后
都恢复纯数字 raw，才能继续下一槽。

## 固化的自动化契约

新增 fixture-gated
`RimeT9AutoAnchorRetryMatrixTests.testRejectedCompositionLaterOpportunityTransactionMatrix`：

- 逐键构造真实 T9 composition；
- 在第 18 槽和后续所有真实提议点执行最大前缀事务；
- 最大前缀失败时，从少一个音节开始逐级回退到两个完整音节；
- 每次替换使用现行首选保持 + 60% 前五候选重合规则；
- 每次事务后断言恢复 raw、活动 composition、首选候选及前五候选集合；
- 三轮交替运行纯数字基线和第 18 槽两音节锚定，记录固定慢槽中位数；
- 机器输出只含槽位、数量、判定和耗时，不含数字串、拼音或候选文本。

## 候选守恒矩阵

| 维度 | 结果 |
|---|---:|
| 最大前缀机会 | 15 |
| 最大前缀接受 | 0 |
| 最大前缀重合 | 全部 `2 / 5` |
| 逐音节回退事务 | 89 |
| 回退接受 | 15 |
| 接受边界 | 全部且仅有两个完整音节 |
| 两音节候选重合 | 全部 `5 / 5` |
| 总测试事务 | 104 |
| raw / composition / 首选 / 前五集合恢复 | 104 / 104 |

最大提议位置与前序影子观测一致：

`18, 21, 23, 25, 27, 28, 30, 31, 33, 34, 35, 37, 38, 39, 40`

这推翻了“等到后续机会再重复最大前缀事务”的方向。问题不是机会不足，
而是最大公共前缀在该句上过深；三个及以上音节都会让前五候选重合降到
`2 / 5`。

## 三轮配对耗时

第 18 槽的两音节版本先通过 `5 / 5` 候选守恒，再保持锚定继续输入。
测试顺序交替，避免同一侧总是获得更热的 session/cache。

| source slot | 纯数字中位数 | 两音节锚定中位数 | 变化 |
|---:|---:|---:|---:|
| 22 | 52.2 ms | 36.4 ms | -15.8 ms |
| 24 | 62.4 ms | 45.3 ms | -17.1 ms |
| 26 | 73.3 ms | 59.0 ms | -14.3 ms |
| 32 | 86.1 ms | 72.8 ms | -13.3 ms |
| 36 | 97.1 ms | 80.9 ms | -16.2 ms |

三轮全部按键中，`≥50ms` 计数从纯数字的 `15` 降到两音节锚定的 `9`。

## 六条冻结语料的深度矩阵

同一真实 RIME 测试随后复用了前序 S3 六条语料，对每条合格提议从最大深度
逐级回退到两个完整音节：

| Case | 最大深度 | 最大重合 | 通过的锚定深度 |
|---|---:|---:|---|
| Known positive | 12 | `5 / 5` | 2–12 全部 |
| Different sentence | 11 | `2 / 5` | 仅 2 |
| Local-ranking shape | 4 | `3 / 5` | 2–4 全部 |
| High ambiguity | 10 | `5 / 5` | 2–10 全部 |
| Legal-but-poor path | 9 | `1 / 5` | 无 |
| Threshold boundary | — | — | 17 槽仍无提议 |

在五条达到 18 槽的语料中，固定两音节版本保留了四条原本可接受/可回退
语料，同时仍以候选守恒拒绝 `a × 18` 低质量路径。它不是绕过安全门，
而是减少一次性注入的拼写约束。

## 24 条评审语料

在六条冻结语料之外，矩阵又增加了 24 条声明类别的输入：

- 16 条常见陈述、请求和计划句型，长度 22–36 槽；
- 4 条重复高歧义形态；
- 2 条语言质量差但可映射到 T9 的形态；
- 2 条低于 18 槽的阈值边界。

每条只在首次真实 `proposal` 位置比较最大前缀和固定两音节，不扫描更多
候选、不改变候选顺序。结果：

| 类别 | Case | 有提议 | 最大前缀接受 | 两音节接受 |
|---|---:|---:|---:|---:|
| Natural | 16 | 16 | 7 | 8 |
| Repeated ambiguity | 4 | 4 | 1 | 1 |
| Poor shape | 2 | 1 | 0 | 0 |
| Threshold | 2 | 0 | 0 | 0 |
| **Total** | **24** | **21** | **8** | **9** |

两音节保留了全部 8 条最大前缀已接受的 case，并额外使一条自然句从
`2 / 5` 提升到 `4 / 5`。其余 12 条有提议语料仍被 60% 候选守恒拒绝，
其中多条两音节重合为 `0 / 5`。两条 poor case 均未通过；两条 threshold
case 均未产生提议。

这些分布已固化成 pinned-runtime 回归断言：

- proposals `21`;
- maximal accepted `8`;
- two-syllable accepted `9`;
- maximal-accepted but two-syllable-rejected `0`;
- poor two-syllable accepted `0`.

## 验证

| 验证 | 结果 |
|---|---|
| RIME vendor structural inventory | 11 / 11 verified |
| 严格 `build-for-testing` | passed，0 warning / 0 error |
| 真实 fixture 聚焦矩阵 | 1 passed / 0 failed / 0 skipped |
| 默认 RimeBridge suite | 31 passed / 0 failed / 10 fixture-gated skipped |
| `git diff --check` | passed |

默认 suite 中本矩阵在未提供隔离 fixture 时按设计跳过；真实结果来自显式
fixture 运行，不应把默认 skip 解释为覆盖。

## 结论与限制

1. 对该被冻结拒句，安全边界不是“最大公共前缀”，而是两个完整音节。
2. 两音节锚定保留 `5 / 5` 候选，同时稳定降低约 13–17ms 的固定慢槽耗时。
3. 一次两音节锚定仍未消除后半段歧义增长，不能单独满足最终流畅目标。
4. 六条冻结语料和 24 条评审语料都支持“两音节 cap”作为下一版候选；
   它没有回退任何已接受 case，也没有放行 poor/threshold case。
5. 这仍是合成语料和未个性化的隔离 user directory。真实 userdb 排序、
   更多句型及物理设备证据仍需 Product / Architecture / Quality 复核。
   adaptive backoff 会引入多次 RIME 替换，当前调用预算不允许。
