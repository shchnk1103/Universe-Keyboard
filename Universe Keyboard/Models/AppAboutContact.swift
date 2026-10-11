import Foundation

/// Contact and identity helpers for the main-App About page (`PD-APP-ABOUT-001`).
enum AppAboutContact: Sendable {
    nonisolated static let emailAddress = "doubleshy0n@gmail.com"
    nonisolated static let xiaohongshuURLString = "https://xhslink.cn/o/7lEn4EM0BtP"

    nonisolated static var xiaohongshuURL: URL {
        URL(string: xiaohongshuURLString)!
    }

    nonisolated static func feedbackMailSubject(version: String, build: String) -> String {
        "Universe Keyboard 反馈 · \(version) (Build \(build))"
    }

    nonisolated static func feedbackMailtoURL(version: String, build: String) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = emailAddress
        components.queryItems = [
            URLQueryItem(name: "subject", value: feedbackMailSubject(version: version, build: build))
        ]
        return components.url
    }

    nonisolated static func marketingVersion(from bundle: Bundle = .main) -> String {
        bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    nonisolated static func buildNumber(from bundle: Bundle = .main) -> String {
        bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
}
