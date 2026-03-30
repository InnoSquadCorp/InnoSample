public enum ThirdPartyModule: String {
    case analytics = "Analytics"

    var bundleNamespace: String {
        switch self {
        case .analytics:
            "thirdparties.analytics"
        }
    }
}
