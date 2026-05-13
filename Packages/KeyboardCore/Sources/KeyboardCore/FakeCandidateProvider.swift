public final class FakeCandidateProvider: CandidateProvider {
    private let dictionary: [String: [String]] = [
        "ni":       ["你", "呢", "尼"],
        "hao":      ["好", "号", "浩"],
        "nihao":    ["你好", "拟好", "你号"],
        "shi":      ["是", "时", "事"],
        "shijie":   ["世界", "视界", "十届"],
        "zhong":    ["中", "种", "重"],
        "zhongguo": ["中国", "中过", "中果"],
        "ceshi":    ["测试", "侧室", "测时"],
        "wo":       ["我", "握", "窝"],
        "woaini":   ["我爱你", "我碍你", "我艾你"]
    ]

    public init() {}

    public func candidates(for composition: String) -> [String] {
        dictionary[composition] ?? []
    }
}
