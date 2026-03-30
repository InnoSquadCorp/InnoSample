public enum LayerModule: String {
    case layers = "Layers"
    case domain = "Domain"
    case data = "Data"
    case remote = "Remote"

    var bundleNamespace: String {
        switch self {
        case .layers:
            "layers"
        case .domain:
            "layers.domain"
        case .data:
            "layers.data"
        case .remote:
            "layers.remote"
        }
    }
}
