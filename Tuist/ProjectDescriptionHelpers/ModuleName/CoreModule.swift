public enum CoreModule: String {
    case network = "CoreNetwork"

    var bundleNamespace: String {
        switch self {
        case .network:
            "cores.network"
        }
    }
}
