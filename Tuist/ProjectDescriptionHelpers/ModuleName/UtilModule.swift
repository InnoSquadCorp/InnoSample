public enum UtilModule: String {
    case designSupport = "SampleDesignSupport"

    var bundleNamespace: String {
        switch self {
        case .designSupport:
            "utils.designsupport"
        }
    }
}
