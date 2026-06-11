//
//  CandidateItem.swift
//  KeyboardCore
//
//  候选栏数据模型：定义候选项目的类型和结构。
//  用枚举替代散落在 25+ 处的字符串字面量 ("candidate" / "composition" / "placeholder")。
//
//  ## 为什么用枚举而不是字符串？
//  - 编译期拼写检查：写 ".candiate" 编译直接报错，不会像 "candiate" 那样默默运行出错
//  - switch 穷尽性检查：将来新增 CandidateKind case 时，编译器会报告所有未处理的 switch 分支
//  - IDE 自动补全：CandidateKind. 之后会列出所有可选值，不需要记忆字符串
//
//  ## 为什么 Int rawValue？
//  - Int 可以直接赋值给 UIButton.tag（每个 UIView 自带的整型标记属性）
//  - 避免了用 accessibilityIdentifier（那是给 VoiceOver 无障碍功能用的）来传递业务数据的设计误区
//
//  ## 数据流全景
//
//  打字 → KeyboardController → CandidateProvider.candidates(for:)
//                                      ↓ 返回 [String]
//   KeyboardViewController.candidateItems()
//                                      ↓ 拼接为 [CandidateItem]
//   fillCandidateBar() / makeExpandedCandidatePanel()
//                                      ↓ 创建 UIButton + tag = kind.rawValue
//   用户点击按钮
//                                      ↓
//   insertCandidate(_:) 读取 sender.tag → CandidateKind
//                                      ↓
//   controller.handle(.insertCandidate(title, kind: kind))
//                                      ↓
//   handleInsertCandidate() switch kind → 上屏 / 提交拼音 / 忽略
//

import Foundation

// MARK: - 候选类型枚举

/// 候选栏中每个按钮的"类型"，决定点击后的行为。
/// 使用枚举替代字符串字面量，利用编译器的类型检查保证安全。
public enum CandidateKind: Int, CaseIterable, Sendable {
    /// 正常候选词：点击后交给 RIME 选择；完整候选会结束 composition，
    /// 部分候选可保留剩余输入继续编辑。
    case candidate = 0

    /// 原始拼音组合：点击后把当前输入的拼音串直接上屏（不选候选词）。
    /// 适用于用户输入的不是拼音而是想直接打出的英文/缩写。
    /// 例如：输入 "abc"（无中文候选）→ 点击 "abc" → 文本中插入 "abc"。
    case composition = 1

    /// 占位提示文字：不可点击，仅用于视觉提示。
    /// 例如 "输入拼音"、"英文模式"、"更多候选" 等灰色提示。
    case placeholder = 2

    /// 误触纠错候选：点击后直接提交纠错候选文本，不从当前 RIME session 选择。
    /// 例如：输入 "nihap" → 显示 "你好 p→o" → 点击后提交 "你好"。
    case correctionCandidate = 3
}

/// RIME 候选在候选页中的稳定位置。
///
/// Phase 1 仅保存该元数据，不参与候选点击或提交行为。
public struct CandidateSelectionReference: Equatable, Sendable {
    public let page: Int
    public let indexOnPage: Int
    public let globalIndex: Int?

    public init(page: Int, indexOnPage: Int, globalIndex: Int? = nil) {
        self.page = page
        self.indexOnPage = indexOnPage
        self.globalIndex = globalIndex
    }
}

// MARK: - 候选项目结构体

/// 候选栏中显示的一个"项"，包含显示文字和行为类型。
/// 替代原来散落在各处的 (title: String, kind: String) 匿名元组。
/// 使用命名结构体的好处：
/// - 属性名 self-documenting（title / kind 比 .0 / .1 更清晰）
/// - 可在多个文件间传递而保持类型一致性
public struct CandidateItem: Equatable, Sendable {
    /// 在按钮上显示的文字
    public let title: String
    /// 该项目的类型：候选词 / 拼音组合 / 提示占位
    public let kind: CandidateKind
    /// 误触纠错候选的提交与展示元数据。普通候选为 nil。
    public let correction: TypoCorrectionCommit?
    /// 普通 RIME 候选的页码和页内索引。其他候选类型为 nil。
    public let selectionReference: CandidateSelectionReference?

    public init(
        title: String,
        kind: CandidateKind,
        correction: TypoCorrectionCommit? = nil,
        selectionReference: CandidateSelectionReference? = nil
    ) {
        self.title = title
        self.kind = kind
        self.correction = correction
        self.selectionReference = selectionReference
    }

    /// Creates a normal RIME candidate with its stable page position.
    public static func rimeCandidate(
        _ candidate: RimeCandidate,
        page: Int,
        indexOnPage: Int,
        globalIndex: Int? = nil
    ) -> CandidateItem {
        CandidateItem(
            title: candidate.text,
            kind: .candidate,
            selectionReference: CandidateSelectionReference(
                page: page,
                indexOnPage: indexOnPage,
                globalIndex: globalIndex
            )
        )
    }
}
