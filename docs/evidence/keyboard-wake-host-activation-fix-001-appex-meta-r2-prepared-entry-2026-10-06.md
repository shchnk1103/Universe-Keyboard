# AP-META-002 最小复核 Entry（Prepared，未执行）

## 范围与责任

root 为环境执行及 debugger-side 脚本 writer；Grok 生产 writer 不变，无源码授权。复用 AP-META-001 的冻结 source5、78文件配对 manifest、模块 UUID／SHA、内容无关元数据字段及严格身份验收，不降低验收。新运行根 /private/tmp/ukey-host-activation-fix-appex-meta-r2-20261006 仅执行授权后创建，不覆盖历史。

原目标仅 iPhone18Pro／iOS27.0，UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。安装debug模块UUID4B207746-89A7-321F-83C4-91477259BB26、SHA773c4eff9640b2623036e3f819301ead3914cb99b66c9c1496ece5986e762aab。执行前重新核对所有输入及实际安装字节；新实例 PID/start/path 现场发现，禁止复用95682或64039。

## 新鲜 Entry 与人工步骤

执行授权及本轮独占仍待 Human。关闭 Maps／主App、收键盘，两诊断保持关闭；旧appex若存活，仅明确批准后核实PID/start/path一次SIGTERM，不终止主App。主App搜索Tab空框叫出键盘：完全访问开、候选空、观测可见；不输入。新LLDB会话attach后核loadedUUID及元数据。安装、部署、数据变化或未知必要字段立即停止。

## 命令交付与门槛

长配置写入独立主机 Python 文件，AST及hash冻结后import；终端单次只发短 command source 或 script module.configure()，不再批量粘贴长Python行。command source配置文件不得包含continue或quit。初始化函数只读SB元数据、创建唯一精确出口断点、绑定PID/模块UUID/代码PC/断点及location/attachStopID，验证仅1location与hit0、配置callback并SetAsync(False)，最后写出配置成功回执。缺回执、任何错误或多断点即清理停止，绝不让Human点击。

root核配置成功后单独发CLI continue，不在Python上下文等待，也不预排process status命令。Human只点一次观测并停手；确认同PID运行且无callback后，再点一次取证。只读callback停点身份与同停点CLI元数据对照，最多8个caller函数名。仍禁止读取buffer/address/count/参数、ReadMemory、target expression或寄存器猜测。任意identity不匹配停止，不替换frame或重复点击。

## 收尾、预算与非目标

新30 actual tool calls／30分钟提案，不继承已消耗预算；最后8calls预留清理收件。停点≤120秒，单工具wait≤30秒，一runtime attempt／一命中；超过预算或错误停止采样。删除并核自身断点列表，再detach，单独quit并确认session退出、同PID非traced、诊断原值／存在性及Human视觉Exit，最后关闭App。禁止新大备份、删备份、生产修改、build/test/install/deploy/Maps/AppSwitcher/Git/Release、重复arm/freeze或自动延长。未更改持久环境时不做数据恢复；意外变化报告具体范围，不擅写。

Passed仅为本轮appex元数据身份链路，不关闭F4 owner或整体修复。执行授权需确认以上范围／预算和新独占；本Prepared不等于Ready。
