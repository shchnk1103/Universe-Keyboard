# U0 人工正常路径交付 — 2026-10-03

固定原 iPhone 18 Pro / iOS 27.0，UDID 405D994F-28CB-4F89-BB22-B64AD81C05A2，Human 已授权 U0 并确认本轮独占。固定 I1 已安装候选 43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50。

## 结果及来源

- Human step1：完全访问开启，空候选栏“观测”初始可见。精确秒数 NOT MEASURED，不推为历史延迟普遍修复。
- Human step2：单次合成输入后候选正常，“观测”在有候选时保持隐藏；正常提交后空栏按钮出现。输入框更新由正常提交回报支持，没有读取输入内容。
- root 收尾只读：live simctl 精确 UDID/bundle 查询，已安装全部 78 文件 SHA 与 H1 完全一致。logging_enabled 与 diagnostics_high_fidelity_expiration 均 ABSENT，与 I1 原存在性/值一致，两诊断关闭。
- 首次 readback 对 App Group 使用不支持的 selector，exit117；改用 groups 查询后成功。这是 reader 参数错误，不作为环境或偏好异常。

证据：[step1](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-artifacts/step1-human.json)、[step2](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-artifacts/step2-human.json)、[machine readback](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-artifacts/post-human-readback.json)、[reader](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u0-artifacts/readback.py)。raw 保留在 /private/tmp/ukey-wake-ui-u0-20261003。

## 结论与边界

U0 按本轮冻结正常路径完成。未点击观测、arm、freeze、export、LLDB、Maps、重装或部署；没有新构建/测试。人工回报与机器身份分别归档，正常输入后不主张完整 data/Group 字节仍等于 I0。原备份全部保留。

U1 正常观测→冻结→有界导出仍待阶段 Entry/授权；Maps 与根因仍未验证，父子 Assignment 保持 Active。T 的 29 未验证残项接受仅限 T，30 raw skip 原记录不改，不计通过。无通用 Quality/Product/Release 结论；不需 CHANGELOG 或架构合同修改。
