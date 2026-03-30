import Foundation

public struct NetworkEnvironment: Sendable {
    public let baseURL: URL
    public let appName: String
    public let appVersion: String
    public let environmentName: String
    public let preferredLanguage: String

    public init(
        baseURL: URL,
        appName: String = "InnoSample",
        appVersion: String = "1.0.0",
        environmentName: String = "development",
        preferredLanguage: String = Locale.preferredLanguages.first ?? "ko-KR"
    ) {
        self.baseURL = baseURL
        self.appName = appName
        self.appVersion = appVersion
        self.environmentName = environmentName
        self.preferredLanguage = preferredLanguage
    }

    public var platformName: String {
        PlatformInfo.name
    }

    public var clientIdentifier: String {
        "\(appName)\(platformName)"
    }

    public var userAgent: String {
        "\(appName)/\(appVersion) (\(platformName))"
    }

    func resolvedHeaders(for policy: HeaderPolicy) -> [String: String] {
        switch policy {
        case .appDefault:
            return [
                "Accept-Language": preferredLanguage,
                "User-Agent": userAgent,
                "X-Sample-Client": clientIdentifier,
                "X-Sample-Environment": environmentName,
            ]
        case .external:
            return [
                "Accept-Language": preferredLanguage,
                "User-Agent": userAgent,
            ]
        case .custom:
            return [:]
        }
    }
}
