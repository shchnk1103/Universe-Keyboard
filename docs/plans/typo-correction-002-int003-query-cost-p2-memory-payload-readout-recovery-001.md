# 仅产物解析脚本修正与剩余readout — Proposed

2026-10-09T13:05:35.442324+08:00

## 故障归属

本轮target-only编译一次exit0/32.830秒，74文件/2实际MachO/arm64Simulator/UUID/exportReady/Compilerflags及Appcodesign verify已留存。Coordinator检查脚本将str传给plistlib.loads导致TypeError；不是Swift编译或产品签名失败。执行AUTH因首失败规则耗尽，未重跑/修源。保留原失败脚本和artifact-readout，不将当前Partial改成过去成功。

## 下一Human授权的最小切片

独立Assignment/AUTH，仅修本地证据脚本XML输入为UTF8 bytes（plistlib.loads(xml.encode("utf-8"))），先用已保存app-signature-entitlements.stdout演练实际XML类型/字段，不生成报告拼接脚本。新输出root `/private/tmp/universe-keyboard-int003-p2-memory-payload-readout-recovery-001`；不在原buildroot覆盖原失败报告，不重新编译/格式化/签名写入/安装/测试/Simulator/LLDB/Profiler。

冻结已有成功buildargv/env/源22及buildlog/2binary/74filemanifest/原readout身份；只用manifest驱动读取已有产品路径，先hash与size验证，无手拼其他Evidence路径、无遍历缓存/新目录。已有真实Compilerdriver/ObjCresponse/Appcodesign验证及2MachO UUID/符号结果按未变字节复用，不重复原生工具以填缺口。模拟器不需要确认或使用。

只补剩余：actualembeddedKeyboard Info.plist，codesign --verify --strict及--display --entitlements :-（最多这2次native命令、任一失败即停）；解析App已留存XML与Extension新XML。Simulator __entitlements的字节可按现有otool-load保存的section offset/size从准确2binary读取，先校验section名称/segment/文件长度/offset/size及payloadhash，再plistlib.loads(bytes)；不猜otool十六进制word字节序，不运行额外otool或compiler。机器脚本和真实样本解析预检同次授权内先完成，失败只保留事实，不自动重试。

一轮readout/最多300秒，2codesignnativecalls，零buildattempt；记录总toolcalls/解析失败/UTC及原产物hash复核。成功新admission记录把本次artifact结果关联原build，不声称本次重建或新增CI通过。默认Debug/Release旧证据仍按原范围，不随main重试。

## 所需出口

74filebyteidentity、实际App及embeddedExtensioncodeflags/UUID/Symbol/noTESTING、签名及AppGroup完整、记录源/工具链/产品/command关联，则本次build/readout可收敛。缺必要证据Partial，不用装机或新输入替代metadata；读到真实源/签名/产物差异不修、回Human。父Active，仍无Capture/Gate/发布/Release/ADR Accept/父Close。未来设备与测量外暖机授权保持独立。此方案尚未创建/释放/消费执行AUTH。
