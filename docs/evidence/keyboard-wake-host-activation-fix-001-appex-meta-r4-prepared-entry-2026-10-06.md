# AP-META-004 点击前检查修正后的最小 Entry（Prepared）

继承AP-META-003及AP-META-002冻结的生产source5、78payload、原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2／iPhone18Pro／iOS27.0、debug模块UUID/SHA和metadata-only验收；不继承旧PID／旧样本或已消耗预算。root负责环境及私有debugger脚本，Grok生产writer不变。

新运行根/private/tmp/ukey-host-activation-fix-appex-meta-r4-20261006，只新授权后创建。沿用已验证的callback单参数注册＋CLI明确函数名读回，long配置文件化、短command source；唯一location/hit0、SetAsync(False)及配置回执齐才continue。新增冻结私有检查脚本/private/tmp/ukey-appex-meta-preclick-preflight-20261006/preclick_checkpoint.py（hash见completion）；不执行生产修改。

点击前（pre-arm及pre-freeze）各自必须在native continue已返回prompt后，用短script preclick_checkpoint.capture_debugger_state(ROOT,phase)保存新的process state/PID/hit0，无frame／内存／参数。主机一次ps保存returncode/stdout/stderr，以record_and_evaluate先落盘fresh/config/new snapshot/callback存在性，分别判定PID/start/path、LLDB running、hit0及配置，禁止要求ps stat包含Ss。任何STOP/错误/缺原值或callback存在立即清理，不点击、不修后续跑。两阶段使用不同文件，预检查不得用旧阶段快照替代。

授权依赖：新鲜本轮独占、上轮后无安装部署、关闭Maps／主App、两诊断关闭。旧appex存活仅Human明确授权后重核PID/start/path一次正常SIGTERM，不终止主App／强杀。Human主App搜索空框叫新键盘，完全访问开、候选空、观测可见；root检查PASS后只一次观测，按钮变取证停手；pre-freeze检查PASS后只一次取证停手。禁止字符输入、候选提交、Maps／AppSwitcher或重复点击。

新预算提案36actualcalls／30分钟，最后8calls留清理收件（相比30calls增加6，只覆盖两阶段各一metadata capture及分别记录判定，不增加runtime attempt）；一次runtime attempt／一命中，停点≤120秒、单工具wait≤30秒。逐call账本：2Entry＋1旧进程授权＋2SIGTERM＋1fresh人工＋2新PID＋2attach＋2configure＋2continue＋4pre-arm capture/hostrecord＋1arm人工＋4pre-freeze capture/hostrecord＋1freeze人工＋4停点读回/delete/list/detach/quit＋2机器Exit＋1视觉Exit＋2归档＋2final读回＝35calls，余1，若需额外calls则停止，不暗续。

命中后只验证callback与同停点CLI的PID/thread/StopID/frame0/codePC/moduleUUID/mangled/bp_loc/最多8caller，无buffer/address/count/argument/ReadMemory/target expression。误命中、身份不匹配、配置/检查错误即停止；不替换frame或重arm。清理delete/list空、detach、单独quit及同PID非traced、session debugserver退出、诊断原值／存在性/Human视觉Exit，再关App。

无build/test/install/deploy/生产源码/Git/Release、新大备份或删除备份。所有历史残项原样保留，检查PASS不证明Maps/owner/通知或父任务完成。Prepared非Ready，36calls/30分钟、新执行窗口及必要SIGTERM均需Human明确授权。
