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

import KeyboardCore
import UIKit

/// A content-free snapshot of the gate state supplied by the owning view controller.
struct KeyboardWakeDiagnosticContext: Sendable {
    let appearanceID: UUID?
    let isHighFidelityActive: Bool
    let expiration: Date?

    static let disabled = KeyboardWakeDiagnosticContext(
        appearanceID: nil,
        isHighFidelityActive: false,
        expiration: nil
    )

    func allowsRecording(at now: Date) -> Bool {
        isHighFidelityActive && (expiration.map { $0 > now } ?? false)
    }
}

@MainActor
enum KeyboardWakeDiagnosticProducer {
    /// Marker submission is best-effort; this gate reads only the in-memory snapshot.
    @discardableResult
    static func recordKeyboardLifecycle(
        _ phase: DiagnosticEvent.KeyboardLifecyclePhase,
        journal: DiagnosticsJournalRuntime?,
        context: KeyboardWakeDiagnosticContext,
        now: Date = Date()
    ) -> Bool {
        let isInScope =
            phase == .viewWillAppear
            || phase == .viewDidAppear
            || phase == .viewWillDisappear
            || phase == .hostWillResignActive
        guard isInScope, context.allowsRecording(at: now), let journal else { return false }
        return journal.recordKeyboardLifecycle(
            phase,
            appearanceID: context.appearanceID
        )
    }

    @discardableResult
    static func recordRimeResumeStarted(
        journal: DiagnosticsJournalRuntime?,
        context: KeyboardWakeDiagnosticContext,
        now: Date = Date()
    ) -> Bool {
        guard context.allowsRecording(at: now), let journal else { return false }
        return journal.recordRimeResume(
            .started,
            appearanceID: context.appearanceID
        )
    }

    @discardableResult
    static func recordTextProxyOperation(
        _ operation: DiagnosticEvent.TextProxyOperation,
        phase: DiagnosticEvent.TextProxyPhase,
        journal: DiagnosticsJournalRuntime?,
        context: KeyboardWakeDiagnosticContext,
        now: Date = Date()
    ) -> Bool {
        guard context.allowsRecording(at: now), let journal else { return false }
        return journal.recordTextProxyOperation(
            operation: operation,
            phase: phase,
            appearanceID: context.appearanceID
        )
    }
}

@MainActor
final class UITextDocumentProxyAdapter: TextInputClient {

    /// 底层 UITextDocumentProxy 的弱引用。
    /// unowned 使用：proxy 由 UIInputViewController 持有，
    /// VC 存在期间 proxy 一定存在，所以不会造成悬空引用。
    private unowned let proxy: UITextDocumentProxy
    private let diagnosticsJournal: DiagnosticsJournalRuntime?
    private let diagnosticContext: @MainActor () -> KeyboardWakeDiagnosticContext
    /// Test seam for call ordering; accepted submissions may still be dropped by ingress.
    private let diagnosticMarkerObserver:
        (@MainActor (DiagnosticEvent.TextProxyOperation, DiagnosticEvent.TextProxyPhase) -> Void)?

    var hasTextBeforeInput: Bool {
        proxy.hasText
    }

    init(
        proxy: UITextDocumentProxy,
        diagnosticsJournal: DiagnosticsJournalRuntime? = nil,
        diagnosticContext: @escaping @MainActor () -> KeyboardWakeDiagnosticContext = { .disabled },
        diagnosticMarkerObserver: (
            @MainActor (DiagnosticEvent.TextProxyOperation, DiagnosticEvent.TextProxyPhase) -> Void
        )? = nil
    ) {
        self.proxy = proxy
        self.diagnosticsJournal = diagnosticsJournal
        self.diagnosticContext = diagnosticContext
        self.diagnosticMarkerObserver = diagnosticMarkerObserver
    }

    private func recordDiagnosticMarker(
        _ operation: DiagnosticEvent.TextProxyOperation,
        phase: DiagnosticEvent.TextProxyPhase
    ) {
        let submitted = KeyboardWakeDiagnosticProducer.recordTextProxyOperation(
            operation,
            phase: phase,
            journal: diagnosticsJournal,
            context: diagnosticContext()
        )
        if submitted {
            diagnosticMarkerObserver?(operation, phase)
        }
    }

    /// 委托给 UITextDocumentProxy.insertText(_:)。
    /// Apple 文档：在插入点位置插入文本字符串。
    func insertText(_ text: String) {
        recordDiagnosticMarker(.insertText, phase: .entered)
        proxy.insertText(text)
        recordDiagnosticMarker(.insertText, phase: .returned)
    }

    /// 委托给 UITextDocumentProxy.deleteBackward()。
    /// Apple 文档：从插入点向前删除一个字符。
    func deleteBackward() {
        proxy.deleteBackward()
    }

    /// 委托给 UITextDocumentProxy.adjustTextPosition(byCharacterOffset:)。
    /// 用于成对符号插入后把光标移动回左右符号之间。
    func adjustTextPosition(byCharacterOffset offset: Int) {
        proxy.adjustTextPosition(byCharacterOffset: offset)
    }

    /// 委托给 UITextDocumentProxy.setMarkedText(_:selectedRange:)。
    /// Apple 文档：如果已有 marked text，会替换现有 marked text；
    /// 如果没有，则在当前插入点插入一段 marked text。
    func setMarkedText(_ text: String, selectedRange: Range<Int>) {
        let selectedRange = nsRange(for: selectedRange, in: text)
        recordDiagnosticMarker(.setMarkedText, phase: .entered)
        proxy.setMarkedText(
            text,
            selectedRange: selectedRange
        )
        recordDiagnosticMarker(.setMarkedText, phase: .returned)
    }

    /// 委托给 UITextDocumentProxy.unmarkText()，用于确认当前 marked text。
    func unmarkText() {
        recordDiagnosticMarker(.unmarkText, phase: .entered)
        proxy.unmarkText()
        recordDiagnosticMarker(.unmarkText, phase: .returned)
    }

    private func nsRange(for range: Range<Int>, in text: String) -> NSRange {
        let lowerIndex = characterIndex(range.lowerBound, in: text)
        let upperIndex = characterIndex(range.upperBound, in: text)
        let location = lowerIndex.utf16Offset(in: text)
        let upperBound = upperIndex.utf16Offset(in: text)
        return NSRange(location: location, length: max(0, upperBound - location))
    }

    private func characterIndex(_ offset: Int, in text: String) -> String.Index {
        let clampedOffset = min(max(0, offset), text.count)
        return text.index(text.startIndex, offsetBy: clampedOffset)
    }
}
