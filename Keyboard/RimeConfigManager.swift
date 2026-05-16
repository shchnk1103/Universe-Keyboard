import Foundation
import KeyboardCore

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
            Logger.shared.error("App Group 容器不可用", category: .config)
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
        Logger.shared.info("Bundle yaml (root): \(bundleYamls.map { $0.lastPathComponent }.joined(separator: ", "))", category: .config)
        Logger.shared.info("Bundle yaml (Resources/): \(bundleRimes.map { $0.lastPathComponent }.joined(separator: ", "))", category: .config)

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

        // 4. 写入 OpenCC 配置文件 + 字典（简繁转换）
        let openccDir = sharedDir.appendingPathComponent("opencc")
        try? FileManager.default.createDirectory(at: openccDir, withIntermediateDirectories: true)
        writeIfChanged(name: "t2s.json", content: openccT2S, to: openccDir)
        writeIfChanged(name: "s2t.json", content: openccS2T, to: openccDir)
        for name in ["TSCharacters.ocd2", "TSPhrases.ocd2", "STCharacters.ocd2", "STPhrases.ocd2"] {
            copyFromBundleIfNeeded(name: name, to: openccDir)
        }
        Logger.shared.info("OpenCC configs written to shared/opencc/", category: .config)

        // 5. 检查配置版本号，高于已部署版本则清除 build 缓存
        let currentGen = 2  // 递增此数字可强制全部用户重新部署
        let defs = UserDefaults(suiteName: appGroupID)
        let deployedGen = defs?.integer(forKey: "config_generation") ?? 0
        if currentGen > deployedGen {
            if FileManager.default.fileExists(atPath: buildDir.path) {
                try? FileManager.default.removeItem(at: buildDir)
                try? FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
            }
            for name in ["luna_pinyin.table.bin", "luna_pinyin.prism.bin", "luna_pinyin.reverse.bin"] {
                copyFromBundleIfNeeded(name: name, to: buildDir)
            }
            defs?.set(currentGen, forKey: "config_generation")
            defs?.set(false, forKey: "rime_deployed")
            defs?.set(true, forKey: "rime_needs_deploy")
            defs?.synchronize()
            Logger.shared.info("Config gen \(deployedGen) → \(currentGen), cleared build cache", category: .config)
        }

        // 列出已部署文件
        let sharedFiles = (try? FileManager.default.contentsOfDirectory(at: sharedDir, includingPropertiesForKeys: nil)) ?? []
        Logger.shared.info("SharedDir: \(sharedFiles.map { "\($0.lastPathComponent)(\((try? $0.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0)/1024K)" }.joined(separator: ", "))", category: .config)

        return (sharedDir.path, userDir.path)
    }

    // MARK: - Configuration (custom.yaml)

    /// 从 UserDefaults 读取配置并生成 .custom.yaml 文件到 user_data_dir。
    /// 在部署前调用，确保用户通过主 App 修改的配置被写入。
    static func syncCustomYamlFiles() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }

        let userDir = containerURL.appendingPathComponent("Rime/user")
        try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)

        let defs = UserDefaults(suiteName: appGroupID)

        // default.custom.yaml — 候选数量
        let pageSize = defs?.integer(forKey: "rime_page_size") ?? 0
        if pageSize >= 5 {
            let yaml = "patch:\n  \"menu/page_size\": \(pageSize)\n"
            try? yaml.write(to: userDir.appendingPathComponent("default.custom.yaml"), atomically: true, encoding: .utf8)
            Logger.shared.info("Synced default.custom.yaml (page_size=\(pageSize))", category: .config)
        }

        // luna_pinyin.custom.yaml — 简繁
        if defs?.object(forKey: "rime_simplification") != nil {
            let simplified = defs?.bool(forKey: "rime_simplification") ?? true
            let reset = simplified ? 1 : 0
            let yaml = "patch:\n  \"switches/@1/reset\": \(reset)\n"
            try? yaml.write(to: userDir.appendingPathComponent("luna_pinyin.custom.yaml"), atomically: true, encoding: .utf8)
            Logger.shared.info("Synced luna_pinyin.custom.yaml (simplification.reset=\(reset))", category: .config)
        }
    }

    // MARK: - Configuration UI helpers (called by main app via UserDefaults)

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    /// 获取当前候选数量。默认 9。
    static func currentPageSize() -> Int {
        let val = defaults?.integer(forKey: "rime_page_size") ?? 0
        return val > 0 ? val : 9
    }

    /// 设置候选数量（5-20）。写入 default.custom.yaml。
    static func setPageSize(_ value: Int) {
        let clamped = max(5, min(20, value))
        defaults?.set(clamped, forKey: "rime_page_size")
        writeCustomYaml(filename: "default.custom.yaml", patch: [
            "\"menu/page_size\"": clamped,
        ])
        requestDeploy()
    }

    /// 获取默认简繁状态。true = 简体。
    static func currentSimplification() -> Bool {
        if defaults?.object(forKey: "rime_simplification") == nil {
            return true // 默认简体
        }
        return defaults?.bool(forKey: "rime_simplification") ?? true
    }

    /// 设置默认简繁。true = 简体（reset=1），false = 繁体（reset=0）。
    static func setSimplification(_ simplified: Bool) {
        defaults?.set(simplified, forKey: "rime_simplification")
        writeCustomYaml(filename: "luna_pinyin.custom.yaml", patch: [
            "\"switches/@1/reset\"": simplified ? 1 : 0,
        ])
        requestDeploy()
    }

    /// 设置部署标记，键盘下次按键时自动部署。
    static func requestDeploy() {
        defaults?.set(false, forKey: "rime_deployed")
        defaults?.set(true, forKey: "rime_needs_deploy")
        defaults?.synchronize()
        Logger.shared.info("Deploy requested — rime_needs_deploy set", category: .config)
    }

    /// 将 patch 字典写入 user_data_dir 下的 .custom.yaml 文件。
    private static func writeCustomYaml(filename: String, patch: [String: Any]) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return }

        let userDir = containerURL.appendingPathComponent("Rime/user")
        try? FileManager.default.createDirectory(at: userDir, withIntermediateDirectories: true)

        var yaml = "patch:\n"
        for (key, value) in patch {
            if let intVal = value as? Int {
                yaml += "  \(key): \(intVal)\n"
            } else if let boolVal = value as? Bool {
                yaml += "  \(key): \(boolVal)\n"
            } else if let strVal = value as? String {
                yaml += "  \(key): \(strVal)\n"
            }
        }

        let fileURL = userDir.appendingPathComponent(filename)
        try? yaml.write(to: fileURL, atomically: true, encoding: .utf8)
        Logger.shared.info("Wrote \(filename): \(yaml.replacingOccurrences(of: "\n", with: " "))", category: .config)
    }

    // MARK: - Private helpers

    @discardableResult
    private static func writeIfChanged(name: String, content: String, to dir: URL) -> Bool {
        let url = dir.appendingPathComponent(name)
        if (try? String(contentsOf: url, encoding: .utf8)) == content { return false }
        try? content.write(to: url, atomically: true, encoding: .utf8)
        Logger.shared.info("已写入 \(name)", category: .config)
        return true
    }

    private static func copyFromBundleIfNeeded(name: String, to dir: URL) {
        let dest = dir.appendingPathComponent(name)

        // 尝试多个可能的 bundle 路径
        let resourceName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension

        let sourceURL = Bundle.main.url(forResource: resourceName, withExtension: ext)
                     ?? Bundle.main.url(forResource: resourceName, withExtension: ext, subdirectory: "Resources")

        guard let source = sourceURL else {
            Logger.shared.warning("Bundle 中未找到 \(name)，使用内嵌词库", category: .config)
            writeIfChanged(name: name, content: fallbackDict, to: dir)
            return
        }

        let sourceSize = (try? source.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        let destSize = (try? dest.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0

        // 始终用 bundle 中的版本替换（bundle 中的官方词典 > 内嵌回退）
        if sourceSize != destSize {
            try? FileManager.default.removeItem(at: dest)
            try? FileManager.default.copyItem(at: source, to: dest)
            Logger.shared.info("已从 bundle 复制 \(name) (\(sourceSize/1024) KB)", category: .config)
        } else {
            Logger.shared.info("\(name) 已是最新 (\(sourceSize/1024) KB)", category: .config)
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
  - name: simplification
    reset: 1
    states: [ 漢字, 汉字 ]

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
    - simplifier
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

simplifier:
  option_name: simplification
  opencc_config: opencc/t2s.json
  tips: none
"""

    // MARK: - OpenCC 配置文件

    private static let openccT2S = """
{
  "name": "Traditional Chinese to Simplified Chinese",
  "segmentation": {
    "type": "mmseg",
    "dict": {
      "type": "ocd2",
      "file": "TSPhrases.ocd2"
    }
  },
  "conversion_chain": [{
    "dict": {
      "type": "ocd2",
      "file": "TSCharacters.ocd2"
    }
  }]
}
"""

    private static let openccS2T = """
{
  "name": "Simplified Chinese to Traditional Chinese",
  "segmentation": {
    "type": "mmseg",
    "dict": {
      "type": "ocd2",
      "file": "STPhrases.ocd2"
    }
  },
  "conversion_chain": [{
    "dict": {
      "type": "ocd2",
      "file": "STCharacters.ocd2"
    }
  }]
}
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
