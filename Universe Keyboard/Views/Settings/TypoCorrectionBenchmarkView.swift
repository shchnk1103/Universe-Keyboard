import SwiftUI

struct TypoCorrectionBenchmarkView: View {
    private let supportedExamples = [
        TypoCorrectionExample(input: "nihap", correction: "nihao -> 你好", badge: "高置信", color: .green),
        TypoCorrectionExample(input: "bihao", correction: "nihao -> 你好", badge: "前排展示", color: .blue),
        TypoCorrectionExample(input: "nigao", correction: "nihao -> 你好", badge: "前排展示", color: .blue),
        TypoCorrectionExample(input: "nihaoo", correction: "nihao -> 你好", badge: "保守展示", color: .orange),
    ]

    private let unsupportedExamples = [
        TypoCorrectionExample(input: "niho", correction: "漏字暂不支持", badge: "不纠错", color: .secondary),
        TypoCorrectionExample(input: "nihoa", correction: "转置暂不支持", badge: "不纠错", color: .secondary),
        TypoCorrectionExample(input: "nihso", correction: "中间跨类替换风险高", badge: "不纠错", color: .secondary),
        TypoCorrectionExample(input: "zhonghuo", correction: "当前生成优先级可能漏召回", badge: "待优化", color: .orange),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                statusSection
                scoringSection
                benchmarkSection(title: "当前覆盖", examples: supportedExamples)
                benchmarkSection(title: "已知边界", examples: unsupportedExamples)
                rimeBoundarySection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("智能纠错")
    }

    private var statusSection: some View {
        InfoSection(title: "当前状态", systemImage: "wand.and.stars") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    CapsuleBadge(text: "本地判断", color: .blue)
                    CapsuleBadge(text: "可选候选", color: .green)
                    CapsuleBadge(text: "不自动替换", color: .orange)
                }

                Text("智能纠错只在候选栏中追加明确的旁路建议。用户仍然需要手动选择，系统不会自动改写输入。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("下方样例是 benchmark 代表项，不是固定白名单。真实覆盖由邻键规则、候选验证和评分共同决定。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scoringSection: some View {
        InfoSection(title: "评分原则", systemImage: "checklist") {
            VStack(alignment: .leading, spacing: 8) {
                TypoCorrectionRuleRow(text: "优先保证高精度，误纠错比漏纠错更糟。")
                TypoCorrectionRuleRow(text: "纠错必须先通过 RIME 候选验证，不能只靠字符串猜测。")
                TypoCorrectionRuleRow(text: "末尾邻键替换可以更靠前，首字母和中间替换保持前排但不抢首位。")
                TypoCorrectionRuleRow(text: "重复末尾字符删除保持保守，不激进提升。")
            }
        }
    }

    private func benchmarkSection(title: String, examples: [TypoCorrectionExample]) -> some View {
        InfoSection(title: title, systemImage: "tablecells") {
            VStack(spacing: 0) {
                ForEach(examples) { example in
                    TypoCorrectionExampleRow(example: example)
                    if example.id != examples.last?.id {
                        Divider().padding(.leading, 76)
                    }
                }
            }
        }
    }

    private var rimeBoundarySection: some View {
        InfoSection(title: "与 RIME 权重的关系", systemImage: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 8) {
                Text("RIME 负责同一个输入码下的候选排序，例如多次选择“你好”后，下一次输入 nihao 时 RIME 会让它更靠前。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("智能纠错只判断是否需要从另一个纠正后的输入码生成旁路候选，例如 bihao 是否值得额外展示 nihao 的“你好”。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct TypoCorrectionExample: Identifiable {
    let input: String
    let correction: String
    let badge: String
    let color: Color

    var id: String { input }
}

private struct TypoCorrectionExampleRow: View {
    let example: TypoCorrectionExample

    var body: some View {
        HStack(spacing: 12) {
            Text(example.input)
                .font(.system(.subheadline, design: .monospaced).weight(.semibold))
                .frame(width: 64, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(example.correction)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                CapsuleBadge(text: example.badge, color: example.color)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 9)
    }
}

private struct TypoCorrectionRuleRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(.green)
                .padding(.top, 1)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        TypoCorrectionBenchmarkView()
    }
}
