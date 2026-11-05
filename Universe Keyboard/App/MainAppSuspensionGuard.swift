import Foundation
import KeyboardCore
import Synchronization
import UIKit

/// 到期标记不放在 MainActor 上。排空在 KeyboardCore 里读它，不能假设还在主线程。
nonisolated private enum MainAppSuspensionCancelFlags {
    static let ids = Mutex<Set<UUID>>([])
}

nonisolated func mainAppSuspensionReportsCancelled(id: UUID) -> Bool {
    MainAppSuspensionCancelFlags.ids.withLock { $0.contains(id) }
}

/// 主 App 向系统申请的一段后台时间。每个 `begin` 都是独立 token。
/// 到期或 `end` 都只结束这一个 token，不能结束后来申请的 token。
@MainActor
final class MainAppSuspensionGuard {
    struct Token: Hashable, Sendable {
        fileprivate let id: UUID
        fileprivate let systemIdentifier: Int

        fileprivate init(id: UUID, systemIdentifier: Int) {
            self.id = id
            self.systemIdentifier = systemIdentifier
        }
    }

    static let shared = MainAppSuspensionGuard()

    /// Token 的身份给非 MainActor 的取消闭包用。不读 MainActor 上的记录。
    nonisolated static func cancellationID(_ token: Token) -> UUID {
        token.id
    }

    private struct Record {
        var systemIdentifier: Int
        var ended = false
    }

    private var records: [UUID: Record] = [:]
    private var controller: any MainAppBackgroundTaskControlling

    init(controller: any MainAppBackgroundTaskControlling = UIApplicationBackgroundTaskController()) {
        self.controller = controller
    }

    #if DEBUG
        func installControllerForTesting(_ controller: any MainAppBackgroundTaskControlling) {
            self.controller = controller
        }
    #endif

    func isCancelled(_ token: Token) -> Bool {
        mainAppSuspensionReportsCancelled(id: token.id)
    }

    /// 申请失败或系统返回 invalid 时返回 nil，并记录保护不可用。不得据此声称保护成功。
    func begin(reason: String) -> Token? {
        let id = UUID()
        let systemIdentifier = controller.beginTask(name: reason) { [weak self] in
            MainAppSuspensionCancelFlags.ids.withLock { flags in
                _ = flags.insert(id)
            }
            MainActor.assumeIsolated {
                self?.endRecord(id)
            }
        }
        guard systemIdentifier != UIBackgroundTaskIdentifier.invalid.rawValue else {
            Logger.shared.warning("保护不可用", category: .general)
            return nil
        }
        records[id] = Record(systemIdentifier: systemIdentifier)
        return Token(id: id, systemIdentifier: systemIdentifier)
    }

    func end(_ token: Token) {
        endRecord(token.id)
    }

    private func endRecord(_ id: UUID) {
        guard var record = records[id], !record.ended else { return }
        record.ended = true
        records[id] = record
        controller.endTask(record.systemIdentifier)
    }
}

@MainActor
protocol MainAppBackgroundTaskControlling: AnyObject {
    func beginTask(name: String, expirationHandler: @escaping () -> Void) -> Int
    func endTask(_ identifier: Int)
}

@MainActor
final class UIApplicationBackgroundTaskController: MainAppBackgroundTaskControlling {
    func beginTask(name: String, expirationHandler: @escaping () -> Void) -> Int {
        let identifier = UIApplication.shared.beginBackgroundTask(withName: name) {
            expirationHandler()
        }
        return identifier.rawValue
    }

    func endTask(_ identifier: Int) {
        UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: identifier))
    }
}
