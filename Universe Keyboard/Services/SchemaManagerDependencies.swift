import Foundation
import Synchronization

/// Storage for schema-related App Group flags. Access remains on the main actor
/// because these values are part of the UI-observed schema state.
@MainActor
protocol SharedSettingsStoring: AnyObject {
    func string(forKey key: String) -> String?
    func bool(forKey key: String) -> Bool
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
    func synchronize()
}

@MainActor
final class AppGroupSharedSettingsStore: SharedSettingsStoring {
    private let defaults: UserDefaults

    init(appGroupID: String) {
        self.defaults = UserDefaults(suiteName: appGroupID) ?? .standard
    }

    /// Isolated MainActor deinit hops through a task-local scope. On the
    /// XCTest host (App Group not entitled) that hop has aborted with
    /// `pointer being freed was not allocated` during SchemaManager teardown.
    nonisolated deinit {}

    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func object(forKey key: String) -> Any? { defaults.object(forKey: key) }
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func removeObject(forKey key: String) { defaults.removeObject(forKey: key) }
    func synchronize() { defaults.synchronize() }
}

struct DownloadedSchemaArchive: Sendable {
    let localURL: URL
    let expectedContentLength: Int64
    let operationID: UUID
    let attemptID: UUID
    let sourceID: String
    let artifactID: UUID
    let finalHost: String

    var ownedTemporaryArtifact: SchemaOwnedTemporaryArtifact {
        SchemaOwnedTemporaryArtifact(
            operationID: operationID,
            attemptID: attemptID,
            sourceID: sourceID,
            artifactID: artifactID,
            localURL: localURL
        )
    }
}

protocol SchemaArchiveDownloading: Sendable {
    /// - Parameter onProgress: Optional fraction `0...1` when total size is known;
    ///   `nil` means indeterminate (unknown total). Called from a background queue.
    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive
}

struct URLSessionSchemaArchiveDownloader: SchemaArchiveDownloading {
    private let registry: SchemaTemporaryArtifactRegistry

    init(registry: SchemaTemporaryArtifactRegistry = .live) {
        self.registry = registry
    }

    func downloadArchive(
        from source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)? = nil
    ) async throws -> DownloadedSchemaArchive {
        var request = URLRequest(url: source.downloadURL)
        request.timeoutInterval = 300
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let (temporaryURL, response) = try await ProgressReportingURLSession.download(
            for: request,
            onProgress: onProgress
        )
        return try await adoptDownloadedFile(
            temporaryURL: temporaryURL,
            response: response,
            source: source,
            operationID: operationID,
            attemptID: attemptID,
            onProgress: onProgress
        )
    }

    /// Validates the copied URLSession file, then registers it. Any rejected
    /// HTTP/host/length branch must delete that copy before throwing.
    func adoptDownloadedFile(
        temporaryURL: URL,
        response: URLResponse,
        source: RimeSchemeSourceVariant,
        operationID: UUID,
        attemptID: UUID,
        onProgress: (@Sendable (Double?) -> Void)? = nil
    ) async throws -> DownloadedSchemaArchive {
        do {
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DownloadError.networkError("无效的 HTTP 响应")
            }

            guard httpResponse.statusCode == 200,
                let finalHost = httpResponse.url?.host?.lowercased(),
                source.allowedRedirectHosts.contains(finalHost)
            else {
                throw DownloadError.networkError("下载失败，HTTP \(httpResponse.statusCode)")
            }

            let expectedSize = response.expectedContentLength
            guard expectedSize > 0 || expectedSize == -1 else {
                throw DownloadError.networkError("服务器未提供文件大小")
            }

            onProgress?(expectedSize > 0 ? 1 : nil)
            let archive = DownloadedSchemaArchive(
                localURL: temporaryURL,
                expectedContentLength: expectedSize,
                operationID: operationID,
                attemptID: attemptID,
                sourceID: source.id,
                artifactID: UUID(),
                finalHost: finalHost
            )
            try await registry.register(archive.ownedTemporaryArtifact)
            return archive
        } catch {
            do {
                try SchemaTemporaryFile.removeAndVerifyAbsent(temporaryURL)
            } catch {
                throw DownloadError.temporaryCleanupFailed
            }
            throw error
        }
    }
}

// MARK: - Progress-capable download

/// URLSession download with optional byte progress (TD-009).
nonisolated private enum ProgressReportingURLSession {
    static func download(
        for request: URLRequest,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> (URL, URLResponse) {
        let cancellation = DownloadCancellationBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                let delegate = DownloadDelegate(onProgress: onProgress, continuation: continuation)
                let session = URLSession(
                    configuration: .default,
                    delegate: delegate,
                    delegateQueue: nil
                )
                delegate.retainSession(session)
                let task = session.downloadTask(with: request)
                cancellation.install(task)
                task.resume()
            }
        } onCancel: {
            cancellation.cancel()
        }
    }

    private struct DownloadCancellationState {
        var task: URLSessionTask?
        var isCancelled = false
    }

    private final class DownloadCancellationBox: Sendable {
        private let state = Mutex(DownloadCancellationState())

        func install(_ task: URLSessionTask) {
            let shouldCancel = state.withLock { state in
                state.task = task
                return state.isCancelled
            }
            if shouldCancel { task.cancel() }
        }

        func cancel() {
            let task = state.withLock { state in
                state.isCancelled = true
                return state.task
            }
            task?.cancel()
        }
    }

    private final class DownloadDelegate: NSObject, URLSessionDownloadDelegate, @unchecked Sendable {
        private let onProgress: (@Sendable (Double?) -> Void)?
        private var continuation: CheckedContinuation<(URL, URLResponse), Error>?
        private var session: URLSession?
        private var lastEmittedProgress: Double = -1
        private let lock = NSLock()

        init(
            onProgress: (@Sendable (Double?) -> Void)?,
            continuation: CheckedContinuation<(URL, URLResponse), Error>
        ) {
            self.onProgress = onProgress
            self.continuation = continuation
        }

        func retainSession(_ session: URLSession) {
            self.session = session
        }

        func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didWriteData bytesWritten: Int64,
            totalBytesWritten: Int64,
            totalBytesExpectedToWrite: Int64
        ) {
            guard let onProgress else { return }
            if totalBytesExpectedToWrite > 0 {
                let fraction = min(1, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
                // Throttle UI-facing updates (~1% or first/last).
                lock.lock()
                let previous = lastEmittedProgress
                let shouldEmit = previous < 0 || fraction - previous >= 0.01 || fraction >= 0.999
                if shouldEmit { lastEmittedProgress = fraction }
                lock.unlock()
                if shouldEmit { onProgress(fraction) }
            } else {
                onProgress(nil)
            }
        }

        func urlSession(
            _ session: URLSession,
            downloadTask: URLSessionDownloadTask,
            didFinishDownloadingTo location: URL
        ) {
            let tempDirectory = FileManager.default.temporaryDirectory
            let destination = tempDirectory.appendingPathComponent(
                "schema-dl-\(UUID().uuidString).zip"
            )
            do {
                try? FileManager.default.removeItem(at: destination)
                try FileManager.default.copyItem(at: location, to: destination)
                guard let response = downloadTask.response else {
                    finishAfterFailedCopy(
                        destination,
                        DownloadError.networkError("无效的 HTTP 响应")
                    )
                    return
                }
                finish(.success((destination, response)))
            } catch {
                finishAfterFailedCopy(destination, error)
            }
        }

        func urlSession(
            _ session: URLSession,
            task: URLSessionTask,
            didCompleteWithError error: Error?
        ) {
            if let error {
                finish(.failure(error))
            }
        }

        private func finishAfterFailedCopy(_ destination: URL, _ error: Error) {
            do {
                try SchemaTemporaryFile.removeAndVerifyAbsent(destination)
                finish(.failure(error))
            } catch {
                finish(.failure(DownloadError.temporaryCleanupFailed))
            }
        }

        private func finish(_ result: Result<(URL, URLResponse), Error>) {
            lock.lock()
            let cont = continuation
            continuation = nil
            lock.unlock()
            session?.finishTasksAndInvalidate()
            session = nil
            cont?.resume(with: result)
        }
    }
}
