# T2 恢复后正常基线健康 Entry（机器前置通过，人工验证待完成）

Human 本轮授权补归档已完成T2交付并继续后续验证，确认原模拟器独占，并确认恢复后没有打开、重新安装或部署App。Product Authority/Approver为Human；root沿既定Coordinator/Executor及Environment Executor，Human负责以下正常输入观察，既定Quality后续结果验收。本切片为既定T2恢复可行性中的运行健康补证，不自动消耗Keychain/新候选/Maps/LLDB权限。

原路径、分支和HEAD已恢复；571 source/630 Vendor匹配。旧[T2交付](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-restore-validation-2026-10-03.md)归档完成。原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2为iPhone18Pro/iOS27.0 Booted。原容器路径相同，App/appex进程不存在；[新鲜读回](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-health-artifacts/preflight.json)两次稳定，main827/group52+2links/app78精确旧C7及双签名通过，两诊断原缺键/默认关闭，deployed=true/needs=false/deploying=false。未覆盖历史T2receipt。

接下来由Human打开原Universe Keyboard主App，先确认两项诊断仍关闭；只看完全访问已开启（不切换）；进入搜索Tab，用Universe Keyboard输入一次自选无敏感内容的短拼音，再点一个候选确认上屏。不要求内容上报，仅报告开关/候选/提交状态。不要重新部署、安装、点观测、切App复现Maps或开启诊断。出现部署要求、键盘异常或开关不符立即停下；不猜修、不重部署。

Exit为Human正常候选/提交及完全访问确认，再保存机器可有限核验的状态；尚未取得Human结果，不预填通过。当前只证明旧C7恢复基线，不是新UI候选运行证明。T1仍Partial/Hold，30skip未验证和Keychain未执行保留；不得为计数差额重跑。下一步未执行Keychain需明确新鲜保护Entry及既定授权范围核查。

沿用ios-debugger-agent技能的原设备发现；未修改共享MCP默认项。沙箱simctl连接失败后采用主机精确UDID只读读回，无服务重启。无源码/测试执行/Git发布/Release/CHANGELOG或架构合同变化。
