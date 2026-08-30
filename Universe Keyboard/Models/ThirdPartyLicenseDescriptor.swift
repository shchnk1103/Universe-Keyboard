import Foundation

/// One auditable source of truth for a third-party component's license disclosure.
///
/// Downloadable schemes also use `acceptanceRevision` to bind the user's
/// acknowledgement to the exact disclosure that was shown. Changing any
/// material source, license or modification statement must bump that revision.
struct ThirdPartyLicenseDescriptor: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let projectName: String
    let licenseName: String
    let attribution: String
    let usageNote: String
    let modificationNotice: String?
    let sourceURL: URL
    let licenseURL: URL
    let summaryItems: [String]
    let offlineDocuments: [ThirdPartyNoticeDocument]
    let acceptanceRevision: String
}

struct ThirdPartyNoticeDocument: Codable, Equatable, Identifiable, Sendable {
    let title: String
    let resourceName: String

    var id: String { resourceName }
}

enum ThirdPartyLicenseCatalog {
    static let rimeIce = ThirdPartyLicenseDescriptor(
        id: "rime-ice",
        projectName: "雾凇拼音（rime-ice）",
        licenseName: "GPL-3.0-only",
        attribution: "版权归 iDvel/rime-ice 项目及其贡献者所有。",
        usageNote: "Universe Keyboard 仅在用户主动请求后，从上游 GitHub Release 下载该输入方案。",
        modificationNotice: "下载后会在设备本地筛除不适用于当前 iOS RIME 运行环境的文件，并进行兼容性后处理；这些修改不代表上游项目认可或背书。",
        sourceURL: URL(string: "https://github.com/iDvel/rime-ice")!,
        licenseURL: URL(string: "https://github.com/iDvel/rime-ice/blob/main/LICENSE")!,
        summaryItems: [
            "允许在 GPL-3.0-only 条件下使用、研究、修改和再分发。",
            "修改或再分发时需要保留许可证、来源和相应的修改说明。",
            "软件按现状提供，不附带担保。完整法律条款以许可证原文为准。",
        ],
        offlineDocuments: [
            document("GPL-3.0-only 许可证原文", "RIME-ICE-GPL-3.0-only")
        ],
        acceptanceRevision: "rime-ice-gpl-3.0-only-v1"
    )

    static let wanxiang = ThirdPartyLicenseDescriptor(
        id: "rime-wanxiang",
        projectName: "万象拼音（rime-wanxiang）",
        licenseName: "CC BY 4.0",
        attribution: "作品来源：amzxyz/rime-wanxiang 项目及其贡献者。",
        usageNote: "Universe Keyboard 仅在用户主动请求后，从上游 GitHub Release 下载 base 输入方案。",
        modificationNotice: "下载后会在设备本地筛除桌面端或非当前产品范围文件，并生成适用于 Universe Keyboard 的部署配置；这些修改不代表上游项目认可或背书。",
        sourceURL: URL(string: "https://github.com/amzxyz/rime-wanxiang")!,
        licenseURL: URL(string: "https://github.com/amzxyz/rime-wanxiang/blob/main/LICENSE")!,
        summaryItems: [
            "允许在遵守 CC BY 4.0 条件的前提下共享和改编。",
            "使用时需要提供适当署名、许可证链接，并说明是否进行过修改。",
            "不得暗示上游作者认可 Universe Keyboard。完整法律条款以许可证原文为准。",
        ],
        offlineDocuments: [
            document("CC BY 4.0 许可证原文", "RIME-WANXIANG-CC-BY-4.0")
        ],
        acceptanceRevision: "rime-wanxiang-cc-by-4.0-v1"
    )

    static let lunaPinyin = ThirdPartyLicenseDescriptor(
        id: "rime-luna-pinyin",
        projectName: "朙月拼音（rime-luna-pinyin）",
        licenseName: "LGPL-3.0",
        attribution: "版权归 Rime Developers 及相关词典数据贡献者所有；详细来源保留在随 App 分发的词典头部。",
        usageNote: "作为 Universe Keyboard 的内置基础输入方案和九宫格合法拼音目录来源。",
        modificationNotice: "Universe Keyboard 会生成仅包含合法拼音拼写的派生索引，不改变原始词典的版权归属。",
        sourceURL: URL(string: "https://github.com/rime/rime-luna-pinyin")!,
        licenseURL: URL(string: "https://github.com/rime/rime-luna-pinyin/blob/master/LICENSE")!,
        summaryItems: [
            "内置词典保留 Rime Developers 及上游数据来源说明。",
            "派生的九宫格拼音索引只包含合法拼音拼写，不包含完整中文词条。",
            "完整法律条款和对应源码可从上游及 Universe Keyboard 源码仓库查看。",
        ],
        offlineDocuments: [
            document("LGPL-3.0 许可证原文", "RIME-LUNA-PINYIN-LGPL-3.0"),
            document("上游作者文件", "RIME-LUNA-PINYIN-AUTHORS"),
            document("词典来源与署名", "RIME-LUNA-PINYIN-SOURCE-ATTRIBUTIONS"),
        ],
        acceptanceRevision: "rime-luna-pinyin-lgpl-3.0-v1"
    )

    static let bundledComponents: [ThirdPartyLicenseDescriptor] = [
        component(
            id: "librime",
            name: "RIME / librime",
            license: "BSD-3-Clause",
            source: "https://github.com/rime/librime",
            licenseURL: "https://github.com/rime/librime/blob/master/LICENSE",
            usage: "中文输入引擎。",
            documents: [document("BSD-3-Clause 许可证原文", "RIME-LIBRIME-BSD-3-Clause")]
        ),
        component(
            id: "librime-lua",
            name: "librime-lua",
            license: "BSD-3-Clause",
            source: "https://github.com/hchunhui/librime-lua",
            licenseURL: "https://github.com/hchunhui/librime-lua/blob/master/LICENSE",
            usage: "RIME 的本地 Lua 扩展。精确二进制 source revision 仍在许可来源审计中。",
            documents: [document("BSD-3-Clause 许可证原文", "RIME-LUA-PLUGIN-BSD-3-Clause")]
        ),
        component(
            id: "librime-octagram",
            name: "librime-octagram",
            license: "BSD-3-Clause（根许可证）",
            source: "https://github.com/lotem/librime-octagram",
            licenseURL: "https://github.com/lotem/librime-octagram/blob/master/LICENSE",
            usage: "当前二进制包含语法模块能力，但不随 App 分发语法模型。上游源码文件仍有历史 GPLv3 文件头残余，项目保留对应来源审计说明。",
            documents: [
                document("BSD-3-Clause 许可证原文", "RIME-OCTAGRAM-BSD-3-Clause"),
                document("来源与文件头残余", "RIME-OCTAGRAM-PROVENANCE"),
            ]
        ),
        component(
            id: "opencc",
            name: "OpenCC",
            license: "Apache-2.0",
            source: "https://github.com/BYVoid/OpenCC",
            licenseURL: "https://github.com/BYVoid/OpenCC/blob/master/LICENSE",
            usage: "简繁转换及随 App 分发的 OpenCC 数据。",
            documents: [document("Apache-2.0 许可证原文", "OPENCC-Apache-2.0")]
        ),
        component(
            id: "rime-essay",
            name: "RIME Essay（八股文预设词汇）",
            license: "LGPL-3.0",
            source: "https://github.com/rime/rime-essay",
            licenseURL: "https://github.com/rime/rime-essay/blob/master/LICENSE",
            usage: "内置朙月拼音的官方预设词汇与词频来源；不包含 Octagram 语法模型。",
            documents: [
                document("LGPL-3.0 许可证原文", "RIME-ESSAY-LGPL-3.0"),
                document("上游作者文件", "RIME-ESSAY-AUTHORS"),
            ]
        ),
        component(
            id: "rime-prelude",
            name: "RIME Prelude",
            license: "LGPL-3.0",
            source: "https://github.com/rime/rime-prelude",
            licenseURL: "https://github.com/rime/rime-prelude/blob/master/LICENSE",
            usage: "内置方案共享的官方默认设置、标点、符号和按键绑定。",
            documents: [
                document("LGPL-3.0 许可证原文", "RIME-PRELUDE-LGPL-3.0"),
                document("上游作者文件", "RIME-PRELUDE-AUTHORS"),
            ]
        ),
        component(
            id: "rime-stroke",
            name: "RIME Stroke（五笔画）",
            license: "LGPL-3.0",
            source: "https://github.com/rime/rime-stroke",
            licenseURL: "https://github.com/rime/rime-stroke/blob/master/LICENSE",
            usage: "内置朙月拼音的官方笔画反查依赖。",
            documents: [
                document("LGPL-3.0 许可证原文", "RIME-STROKE-LGPL-3.0"),
                document("上游作者文件", "RIME-STROKE-AUTHORS"),
            ]
        ),
        component(
            id: "boost",
            name: "Boost",
            license: "BSL-1.0",
            source: "https://github.com/boostorg/boost",
            licenseURL: "https://www.boost.org/users/license.html",
            usage: "librime 使用的静态 C++ 组件。",
            documents: [document("Boost Software License 1.0", "BOOST-BSL-1.0")]
        ),
        component(
            id: "glog",
            name: "Google glog",
            license: "BSD-3-Clause",
            source: "https://github.com/google/glog",
            licenseURL: "https://github.com/google/glog/blob/master/LICENSE.md",
            usage: "librime 的日志依赖。",
            documents: [document("BSD-3-Clause 许可证原文", "GOOGLE-GLOG-BSD-3-Clause")]
        ),
        component(
            id: "leveldb",
            name: "LevelDB",
            license: "BSD-3-Clause",
            source: "https://github.com/google/leveldb",
            licenseURL: "https://github.com/google/leveldb/blob/main/LICENSE",
            usage: "RIME 用户词典数据存储。",
            documents: [document("BSD-3-Clause 许可证原文", "LEVELDB-BSD-3-Clause")]
        ),
        component(
            id: "lua",
            name: "Lua",
            license: "MIT",
            source: "https://www.lua.org/",
            licenseURL: "https://www.lua.org/license.html",
            usage: "可选输入方案的本地脚本运行时；随包头文件固定版本为 Lua 5.4.8。",
            documents: [document("Lua 5.4.8 MIT 许可证", "LUA-5.4.8-MIT")]
        ),
        component(
            id: "marisa-trie",
            name: "MARISA Trie",
            license: "BSD-2-Clause OR LGPL-2.1-or-later",
            source: "https://github.com/s-yata/marisa-trie",
            licenseURL: "https://github.com/s-yata/marisa-trie/blob/master/COPYING.md",
            usage: "RIME 静态词典索引。",
            documents: [document("MARISA 许可选项原文", "MARISA-COPYING")]
        ),
        component(
            id: "yaml-cpp",
            name: "yaml-cpp",
            license: "MIT",
            source: "https://github.com/jbeder/yaml-cpp",
            licenseURL: "https://github.com/jbeder/yaml-cpp/blob/master/LICENSE",
            usage: "RIME YAML 配置解析。",
            documents: [document("MIT 许可证原文", "YAML-CPP-MIT")]
        ),
    ]

    static let downloadableSchemes = [rimeIce, wanxiang]
    static let bundledContent = [lunaPinyin] + bundledComponents

    private static func component(
        id: String,
        name: String,
        license: String,
        source: String,
        licenseURL: String,
        usage: String,
        documents: [ThirdPartyNoticeDocument]
    ) -> ThirdPartyLicenseDescriptor {
        ThirdPartyLicenseDescriptor(
            id: id,
            projectName: name,
            licenseName: license,
            attribution: "版权和贡献者信息以对应上游项目的许可证及源码记录为准。",
            usageNote: usage,
            modificationNotice: nil,
            sourceURL: URL(string: source)!,
            licenseURL: URL(string: licenseURL)!,
            summaryItems: ["完整版权声明和法律条款请查看上游许可证原文。"],
            offlineDocuments: documents,
            acceptanceRevision: "notice-\(id)-v1"
        )
    }

    private static func document(_ title: String, _ resourceName: String) -> ThirdPartyNoticeDocument {
        ThirdPartyNoticeDocument(title: title, resourceName: resourceName)
    }
}
