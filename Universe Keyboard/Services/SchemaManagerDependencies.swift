import Foundation

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

    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func bool(forKey key: String) -> Bool { defaults.bool(forKey: key) }
    func object(forKey key: String) -> Any? { defaults.object(forKey: key) }
    func set(_ value: Any?, forKey key: String) { defaults.set(value, forKey: key) }
    func removeObject(forKey key: String) { defaults.removeObject(forKey: key) }
    func synchronize() { defaults.synchronize() }
}

protocol SchemaCatalogClient: Sendable {
    func latestArchiveURL(for distribution: RimeSchemeDistribution) async throws -> URL?
}

struct GitHubSchemaCatalogClient: SchemaCatalogClient {
    func latestArchiveURL(for distribution: RimeSchemeDistribution) async throws -> URL? {
        let apiURL = URL(
            string: "https://api.github.com/repos/\(distribution.githubOwner)/\(distribution.githubRepository)/releases/latest"
        )!
        var request = URLRequest(url: apiURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("UniverseKeyboard/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DownloadError.networkError("无效的 HTTP 响应")
        }
        if httpResponse.statusCode == 403 {
            throw DownloadError.gitHubRateLimit
        }
        guard httpResponse.statusCode == 200 else {
            throw DownloadError.networkError("HTTP \(httpResponse.statusCode)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let assets = json["assets"] as? [[String: Any]],
            let fullZip = assets.first(where: { ($0["name"] as? String) == distribution.assetName }),
            let downloadURL = fullZip["browser_download_url"] as? String
        else {
            return nil
        }
        return URL(string: downloadURL)
    }
}

struct DownloadedSchemaArchive: Sendable {
    let localURL: URL
    let expectedContentLength: Int64
    let eTag: String?
}

protocol SchemaArchiveDownloading: Sendable {
    /// - Parameter onProgress: Optional fraction `0...1` when total size is known;
    ///   `nil` means indeterminate (unknown total). Called from a background queue.
    func downloadArchive(
        from url: URL,
        existingETag: String?,
        cachedArchiveURL: URL,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> DownloadedSchemaArchive
}

struct URLSessionSchemaArchiveDownloader: SchemaArchiveDownloading {
    func downloadArchive(
        from url: URL,
        existingETag: String?,
        cachedArchiveURL: URL,
        onProgress: (@Sendable (Double?) -> Void)? = nil
    ) async throws -> DownloadedSchemaArchive {
        var request = URLRequest(url: url)
        request.timeoutInterval = 300
        if let existingETag, !existingETag.isEmpty {
            request.setValue(existingETag, forHTTPHeaderField: "If-None-Match")
        }

        let (temporaryURL, response) = try await ProgressReportingURLSession.download(
            for: request,
            onProgress: onProgress
        )
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DownloadError.networkError("无效的 HTTP 响应")
        }

        if httpResponse.statusCode == 304 {
            if FileManager.default.fileExists(atPath: cachedArchiveURL.path) {
                onProgress?(1)
                return DownloadedSchemaArchive(
                    localURL: cachedArchiveURL,
                    expectedContentLength: response.expectedContentLength,
                    eTag: existingETag
                )
            }
            return try await downloadArchive(
                from: url,
                existingETag: nil,
                cachedArchiveURL: cachedArchiveURL,
                onProgress: onProgress
            )
        }

        guard httpResponse.statusCode == 200 else {
            throw DownloadError.networkError("下载失败，HTTP \(httpResponse.statusCode)")
        }

        let expectedSize = response.expectedContentLength
        guard expectedSize > 0 || expectedSize == -1 else {
            throw DownloadError.networkError("服务器未提供文件大小")
        }

        try? FileManager.default.removeItem(at: cachedArchiveURL)
        try FileManager.default.moveItem(at: temporaryURL, to: cachedArchiveURL)
        onProgress?(expectedSize > 0 ? 1 : nil)
        return DownloadedSchemaArchive(
            localURL: cachedArchiveURL,
            expectedContentLength: expectedSize,
            eTag: httpResponse.value(forHTTPHeaderField: "Etag")
        )
    }
}

// MARK: - Progress-capable download

/// URLSession download with optional byte progress (TD-009).
private enum ProgressReportingURLSession {
    static func download(
        for request: URLRequest,
        onProgress: (@Sendable (Double?) -> Void)?
    ) async throws -> (URL, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let delegate = DownloadDelegate(onProgress: onProgress, continuation: continuation)
            let session = URLSession(
                configuration: .default,
                delegate: delegate,
                delegateQueue: nil
            )
            delegate.retainSession(session)
            session.downloadTask(with: request).resume()
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
                    finish(.failure(DownloadError.networkError("无效的 HTTP 响应")))
                    return
                }
                finish(.success((destination, response)))
            } catch {
                finish(.failure(error))
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
