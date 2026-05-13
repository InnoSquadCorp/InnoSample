import Foundation

struct RemoteEnvironment: Sendable {
    let baseURL: URL
    let appName: String
    let appVersion: String
    let preferredLanguage: String

    init(
        baseURL: URL,
        appName: String = "InnoSample",
        appVersion: String = "1.0.0",
        preferredLanguage: String = Locale.preferredLanguages.first ?? "ko-KR"
    ) {
        self.baseURL = baseURL
        self.appName = appName
        self.appVersion = appVersion
        self.preferredLanguage = preferredLanguage
    }

    var userAgent: String {
        "\(appName)/\(appVersion) (\(RemotePlatformInfo.name))"
    }

    var headers: [String: String] {
        [
            "Accept-Language": preferredLanguage,
            "User-Agent": userAgent,
        ]
    }
}
