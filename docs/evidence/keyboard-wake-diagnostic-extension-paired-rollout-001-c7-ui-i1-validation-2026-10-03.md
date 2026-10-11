# I1 精确候选单次安装交付

## Scope / Decision

Human明确授权具体I1与安装窗口独占。原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2/iPhone18Pro/iOS27.0 Booted，原worktree/branch/HEAD保持。**I1限定安装/机器保护核验完成，新候选43d85d…已安装；未启动、未输入或进行新runtime验证。**

## Verification

安装前origin全部inventory与I0 fresh before一致、backup本体与原库存一致，原source571/Vendor630及H1payload78无hash变化、签名有效，MainApp/appex缺席。MCP当前profile属其他任务，未改共享defaults；沿已冻结结构化simctl精确UDID argv，install仅尝试一次且exit0，无build/retry。

安装后新发现App/data路径已更新、AppGroup路径不变。全部78payload SHA等于H1 standalone；App/appex bundle id/build1/version1.0配对一致，六MachO SHA/UUID一致，App/appex strict双签名有效。这里不以版本号1代替精确字节身份。

主App应用数据与Group53files/2internal链接无内容/原metadata差异；Group完整inventory完全相等，主数据系统根与系统metadata行也完全相等。主数据唯一inventory差异为4个SplashBoard snapshot路径改名（8条旧/新路径），文件SHA multiset相等；不声称整树路径完全不变。容器权威绑定来自live simctl；MCMMetadataUUID与物理目录名不相等的初步假设检查不作Gate条件，原check与分类留痕，不把它推为数据缺陷。

两diagnostic键仍ABSENT/off，deployed=true、needs=false、isDeploying原ABSENT。没有启用诊断或部署。完整可访问after-state保全在private `/private/tmp/ukey-wake-ui-i1-20261003/after-preservation`，源两次读回稳定、容器稳定、进程缺席；副本字节/结构/mode/owner/原xattrs吻合，新增provenance865/9/9单列。raw用户数据和全inventory留private，repo仅有限状态/读取流程和收据。

## Remaining / nonclaims

当前正常输入、完全访问、探针按钮可见性/显示用时以及观测→冻结→导出未在新候选上验证。原T29非阻塞未验证只在T接受、30raw skip原记录保留。I1不授予U/LLDB/Maps/RIME部署/实际恢复/Release。父子Assignment仍Active、根因未确认。旧备份与I0 fresh backup均保留，未删除/覆盖。

下一步建议仅U0：新候选正常输入健康及未arm按钮可见性计时，先保持两诊断关闭、禁止点观测；U1实际arm/export/LLDB及M另阶段。U0 Prepared尚未授权，必须确认对应人工窗口独占。无需CHANGELOG或长期架构变更，未改源码或Git。
