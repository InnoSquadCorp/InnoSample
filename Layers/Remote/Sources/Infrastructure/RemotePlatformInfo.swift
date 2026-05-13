enum RemotePlatformInfo {
    #if os(iOS)
    static let name = "iOS"
    #elseif os(macOS)
    static let name = "macOS"
    #elseif os(watchOS)
    static let name = "watchOS"
    #elseif os(tvOS)
    static let name = "tvOS"
    #elseif os(visionOS)
    static let name = "visionOS"
    #else
    static let name = "unknown"
    #endif
}
