import Foundation

/// 管理 RIME 配置文件的部署和数据目录。
///
/// 小文件以字符串字面量写入，大文件（官方词典）从 bundle 复制。
struct RimeConfigManager {

    private static let appGroupID = "group.com.DoubleShy0N.Universe-Keyboard"

    // MARK: - Public

    static func prepareDirectories() -> (sharedDir: String, userDir: String)? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            diag("App Group 容器不可用")
            return nil
        }

        let rimeRoot = containerURL.appendingPathComponent("Rime")
        let sharedDir = rimeRoot.appendingPathComponent("shared")
        let userDir = rimeRoot.appendingPathComponent("user")

        for dir in [sharedDir, userDir] {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        // 列出 bundle 中所有可用的 yaml 文件
        let bundleYamls = Bundle.main.urls(forResourcesWithExtension: "yaml", subdirectory: nil) ?? []
        let bundleRimes = Bundle.main.urls(forResourcesWithExtension: "yaml", subdirectory: "Resources") ?? []
        diag("Bundle yaml (root): \(bundleYamls.map { $0.lastPathComponent }.joined(separator: ", "))")
        diag("Bundle yaml (Resources/): \(bundleRimes.map { $0.lastPathComponent }.joined(separator: ", "))")

        // 1. 写入小文件（字符串字面量）
        writeIfChanged(name: "default.yaml", content: defaultYaml, to: sharedDir)
        writeIfChanged(name: "installation.yaml", content: installationYaml, to: sharedDir)
        writeIfChanged(name: "luna_pinyin.schema.yaml", content: lunaPinyinSchema, to: sharedDir)

        // 2. 复制官方词典
        copyFromBundleIfNeeded(name: "luna_pinyin.dict.yaml", to: sharedDir)

        // 3. 复制预编译二进制到 prebuilt_data_dir (shared/build/)
        //    macOS librime 1.16.1 编译产出，跨平台兼容
        let buildDir = sharedDir.appendingPathComponent("build")
        try? FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
        for name in ["luna_pinyin.table.bin", "luna_pinyin.prism.bin", "luna_pinyin.reverse.bin"] {
            copyFromBundleIfNeeded(name: name, to: buildDir)
        }

        // 列出已部署文件
        let sharedFiles = (try? FileManager.default.contentsOfDirectory(at: sharedDir, includingPropertiesForKeys: nil)) ?? []
        diag("SharedDir: \(sharedFiles.map { "\($0.lastPathComponent)(\((try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)/1024K)" }.joined(separator: ", "))")

        return (sharedDir.path, userDir.path)
    }

    // MARK: - Diagnostics

    private static func diag(_ msg: String) {
        print("[RimeConfig] \(msg)")
        let defaults = UserDefaults(suiteName: appGroupID)
        let line = "[RimeConfig] \(msg)"
        var existing = defaults?.string(forKey: "rime_diag_log") ?? ""
        existing = line + "\n" + existing
        defaults?.set(existing, forKey: "rime_diag_log")
        defaults?.synchronize()
    }

    // MARK: - Private helpers

    private static func writeIfChanged(name: String, content: String, to dir: URL) {
        let url = dir.appendingPathComponent(name)
        if (try? String(contentsOf: url, encoding: .utf8)) == content { return }
        try? content.write(to: url, atomically: true, encoding: .utf8)
        print("[RimeConfigManager] 已写入 \(name)")
    }

    private static func copyFromBundleIfNeeded(name: String, to dir: URL) {
        let dest = dir.appendingPathComponent(name)

        // 尝试多个可能的 bundle 路径
        let resourceName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        let sourceURL = Bundle.main.url(forResource: resourceName, withExtension: ext)
                     ?? Bundle.main.url(forResource: resourceName, withExtension: ext, subdirectory: "Resources")

        guard let source = sourceURL else {
            diag("Bundle 中未找到 \(name)，使用内嵌词库")
            writeIfChanged(name: name, content: fallbackDict, to: dir)
            return
        }

        let sourceSize = (try? source.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        let destSize = (try? dest.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0

        // 始终用 bundle 中的版本替换（bundle 中的官方词典 > 内嵌回退）
        if sourceSize != destSize {
            try? FileManager.default.removeItem(at: dest)
            try? FileManager.default.copyItem(at: source, to: dest)
            diag("已从 bundle 复制 \(name) (\(sourceSize/1024) KB)")
        } else {
            diag("\(name) 已是最新 (\(sourceSize/1024) KB)")
        }
    }

    // MARK: - YAML 字面量

    private static let defaultYaml = """
config_version: "0.1"

schema_list:
  - schema: luna_pinyin
    name: 朙月拼音

switcher:
  caption: "[方案选单]"
  hotkeys:
    - "Control+grave"
    - "F4"

menu:
  page_size: 9
  alternative_select_keys: "123456789"

ascii_composer:
  switch_key:
    Shift_L: commit_code
    Shift_R: commit_code

key_binder:
  import_preset: default

punctuator:
  import_preset: default

recognizer:
  import_preset: default
"""

    private static let installationYaml = """
distribution_code_name: "UniverseKeyboard"
distribution_name: "Universe Keyboard"
distribution_version: "1.0.0"
installation_id: "universe-keyboard-ios"
sync_dir: "sync"
"""

    /// 官方 luna_pinyin.schema.yaml（来自 rime/librime data/minimal/）
    /// 兼容 librime 1.8.5
    private static let lunaPinyinSchema = """
schema:
  schema_id: luna_pinyin
  name: 朙月拼音
  version: "0.15"
  author:
    - RIME Developers

switches:
  - name: ascii_mode
    reset: 0
    states: [ 中文, ABC ]

engine:
  processors:
    - ascii_composer
    - recognizer
    - key_binder
    - speller
    - punctuator
    - selector
    - navigator
    - express_editor
  segmentors:
    - ascii_segmentor
    - matcher
    - abc_segmentor
    - punct_segmentor
    - fallback_segmentor
  translators:
    - punct_translator
    - script_translator
  filters:
    - uniquifier

speller:
  alphabet: zyxwvutsrqponmlkjihgfedcba
  delimiter: " '"
  algebra:
    - erase/^xx$/
    - abbrev/^([a-z]).+$/$1/
    - abbrev/^([zcs]h).+$/$1/
    - derive/^([nl])ve$/$1ue/
    - derive/^([jqxy])u/$1v/
    - derive/un$/uen/
    - derive/ui$/uei/
    - derive/iu$/iou/
    - derive/([aeiou])ng$/$1gn/
    - derive/([dtngkhrzcs])o(u|ng)$/$1o/
    - derive/ong$/on/
    - derive/ao$/oa/
    - derive/([iu])a(o|ng?)$/a$1$2/

translator:
  dictionary: luna_pinyin

punctuator:
  import_preset: default

key_binder:
  import_preset: default

recognizer:
  import_preset: default
"""

    /// 内嵌最小词库（当 bundle 中找不到官方 dict 时使用）
    private static let fallbackDict = """
---
name: luna_pinyin
version: "0.1"
sort: by_weight
use_preset_vocabulary: true
...

的	de
一	yi
是	shi
了	le
我	wo
不	bu
人	ren
在	zai
他	ta
有	you
这	zhe
个	ge
上	shang
们	men
来	lai
到	dao
时	shi
大	da
地	di
为	wei
子	zi
中	zhong
你	ni
说	shuo
生	sheng
国	guo
年	nian
着	zhe
就	jiu
那	na
和	he
要	yao
她	ta
出	chu
也	ye
得	de
里	li
后	hou
自	zi
以	yi
会	hui
家	jia
可	ke
下	xia
过	guo
天	tian
去	qu
能	neng
好	hao
看	kan
起	qi
发	fa
当	dang
没	mei
成	cheng
只	zhi
如	ru
事	shi
把	ba
还	hai
用	yong
第	di
样	yang
道	dao
想	xiang
作	zuo
种	zhong
开	kai
美	mei
总	zong
从	cong
无	wu
情	qing
己	ji
面	mian
最	zui
女	nv
但	dan
现	xian
前	qian
些	xie
所	suo
同	tong
日	ri
手	shou
又	you
行	xing
意	yi
动	dong
方	fang
期	qi
它	ta
头	tou
经	jing
长	chang
儿	er
回	hui
位	wei
爱	ai
很	hen
两	liang
间	jian
因	yin
门	men
东	dong
话	hua
今	jin
斯	si
被	bei
教	jiao
高	gao
月	yue
实	shi
进	jin
此	ci
文	wen
什	shen
关	guan
定	ding
其	qi
全	quan
新	xin
重	zhong
明	ming
工	gong
老	lao
做	zuo
者	zhe
我们	wo men
他们	ta men
什么	shen me
自己	zi ji
知道	zhi dao
没有	mei you
可以	ke yi
这个	zhe ge
那个	na ge
一个	yi ge
不过	bu guo
因为	yin wei
所以	suo yi
但是	dan shi
如果	ru guo
虽然	sui ran
已经	yi jing
还是	hai shi
开始	kai shi
起来	qi lai
这样	zhe yang
怎么	zen me
不是	bu shi
就是	jiu shi
出来	chu lai
中国	zhong guo
时候	shi hou
可能	ke neng
问题	wen ti
工作	gong zuo
现在	xian zai
而且	er qie
一下	yi xia
觉得	jue de
需要	xu yao
一些	yi xie
时间	shi jian
世界	shi jie
一样	yi yang
重要	zhong yao
生活	sheng huo
关系	guan xi
喜欢	xi huan
东西	dong xi
事情	shi qing
地方	di fang
发现	fa xian
看到	kan dao
然后	ran hou
最后	zui hou
这里	zhe li
那里	na li
大家	da jia
一起	yi qi
今天	jin tian
昨天	zuo tian
明天	ming tian
朋友	peng you
孩子	hai zi
很多	hen duo
应该	ying gai
比较	bi jiao
非常	fei chang
不同	bu tong
之后	zhi hou
公司	gong si
服务	fu wu
手机	shou ji
电脑	dian nao
信息	xin xi
通过	tong guo
使用	shi yong
方法	fang fa
系统	xi tong
管理	guan li
技术	ji shu
提供	ti gong
增加	zeng jia
解决	jie jue
处理	chu li
你好	ni hao
测试	ce shi
谢谢	xie xie
再见	zai jian
"""
}
