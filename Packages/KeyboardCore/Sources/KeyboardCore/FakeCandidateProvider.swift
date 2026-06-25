public final class FakeCandidateProvider: CandidateProvider {
    private let dictionary: [String: [String]] = [
        "ni":       ["你", "呢", "尼"],
        "hao":      ["好", "号", "浩"],
        "nihao":    ["你好", "拟好", "你号"],
        "shi":      ["是", "时", "事"],
        "shijie":   ["世界", "视界", "十届"],
        "shijian":  ["时间", "事件", "实践"],
        "zhong":    ["中", "种", "重"],
        "zhongguo": ["中国", "中过", "中果"],
        "zhongwen": ["中文", "中文输入", "中闻"],
        "ceshi":    ["测试", "侧室", "测时"],
        "wo":       ["我", "握", "窝"],
        "woaini":   ["我爱你", "我碍你", "我艾你"],
        "women":    ["我们", "我门", "沃门"],
        "jintian":  ["今天", "金天", "尽天"],
        "xiexie":   ["谢谢", "写写", "歇歇"]
    ]

    public init() {}

    public func candidates(for composition: String) -> [String] {
        dictionary[composition] ?? []
    }
}
