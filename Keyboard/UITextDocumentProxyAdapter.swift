//
//  UITextDocumentProxyAdapter.swift
//  Keyboard
//
//  将 UITextDocumentProxy 适配为 KeyboardCore.TextInputClient 协议。
//

import UIKit
import KeyboardCore

final class UITextDocumentProxyAdapter: TextInputClient {
    private unowned let proxy: UITextDocumentProxy

    init(proxy: UITextDocumentProxy) {
        self.proxy = proxy
    }

    func insertText(_ text: String) {
        proxy.insertText(text)
    }

    func deleteBackward() {
        proxy.deleteBackward()
    }
}
