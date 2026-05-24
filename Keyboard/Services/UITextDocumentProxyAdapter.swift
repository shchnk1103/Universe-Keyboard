//
//  UITextDocumentProxyAdapter.swift
//  Keyboard
//
//  将 UITextDocumentProxy 适配为 KeyboardCore.TextInputClient 协议。
//
//  Apple 文档说明：
//  UITextDocumentProxy 是 UIInputViewController 提供的代理对象，
//  用于在自定义键盘中与宿主 App 的文本输入交互。
//  它遵循 UIKeyInput 协议（提供 insertText/deleteBackward/hasText），
//  并提供额外的文本上下文信息（documentContextBeforeInput 等）。
//
//  ── 适配器模式的设计原因 ──────────────────────────────────────
//  KeyboardCore 包是一个纯逻辑的 Swift Package，不含 UIKit 依赖。
//  它的 KeyboardController 通过 TextInputClient 协议与文本输入交互。
//
//  此适配器将 UIKit 的 UITextDocumentProxy 实现包装为
//  TextInputClient 协议，使 KeyboardController 可以在不依赖
//  UIKit 的情况下进行单元测试（使用 FakeTextInputClient）。
//
//  unowned 引用：proxy 的生命周期由 UIInputViewController 管理，
//  适配器不应持有强引用延长 proxy 的生命周期。
//

import UIKit
import KeyboardCore

final class UITextDocumentProxyAdapter: TextInputClient {

    /// 底层 UITextDocumentProxy 的弱引用。
    /// unowned 使用：proxy 由 UIInputViewController 持有，
    /// VC 存在期间 proxy 一定存在，所以不会造成悬空引用。
    private unowned let proxy: UITextDocumentProxy

    init(proxy: UITextDocumentProxy) {
        self.proxy = proxy
    }

    /// 委托给 UITextDocumentProxy.insertText(_:)。
    /// Apple 文档：在插入点位置插入文本字符串。
    func insertText(_ text: String) {
        proxy.insertText(text)
    }

    /// 委托给 UITextDocumentProxy.deleteBackward()。
    /// Apple 文档：从插入点向前删除一个字符。
    func deleteBackward() {
        proxy.deleteBackward()
    }
}
