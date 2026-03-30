import ProjectDescription

public extension TargetDependency {
    static var features: Self {
        .project(target: FeatureModule.features.rawValue, path: .relativeToRoot(FeatureModule.features.path))
    }

    static var layers: Self { layer(.layers) }

    static func feature(_ module: FeatureModule) -> Self {
        .project(target: module.rawValue, path: .relativeToRoot(module.path))
    }

    static func feature(interface module: FeatureModule) -> Self {
        .project(target: module.interfaceTargetName, path: .relativeToRoot(module.path))
    }

    static func feature(logic module: FeatureModule) -> Self {
        .project(target: module.logicTargetName, path: .relativeToRoot(module.path))
    }

    static func feature(ui module: FeatureModule) -> Self {
        .project(target: module.uiTargetName, path: .relativeToRoot(module.path))
    }

    static func feature(router module: FeatureModule) -> Self {
        .project(target: module.routerTargetName, path: .relativeToRoot(module.path))
    }

    static func feature(testing module: FeatureModule) -> Self {
        .project(target: module.testingTargetName, path: .relativeToRoot(module.path))
    }

    static func childFeature(_ module: FeatureModule) -> [Self] {
        [.feature(interface: module), .feature(router: module)]
    }

    static func layer(_ module: LayerModule) -> Self {
        let path: String
        switch module {
        case .layers:
            path = "Layers"
        case .domain, .data, .remote:
            path = "Layers/\(module.rawValue)"
        }

        return .project(target: module.rawValue, path: .relativeToRoot(path))
    }

    static func core(_ module: CoreModule) -> Self {
        .project(target: module.rawValue, path: .relativeToRoot("Cores/\(module.rawValue)"))
    }

    static func thirdParty(_ module: ThirdPartyModule) -> Self {
        .project(target: module.rawValue, path: .relativeToRoot("ThirdParties/\(module.rawValue)"))
    }

    static func thirdParty(interface module: ThirdPartyModule) -> Self {
        .project(
            target: "\(module.rawValue)Interface",
            path: .relativeToRoot("ThirdParties/\(module.rawValue)")
        )
    }

    static func util(_ module: UtilModule) -> Self {
        .project(target: module.rawValue, path: .relativeToRoot("Utils/\(module.rawValue)"))
    }

    static func package(_ product: ExternalPackageProduct) -> Self {
        .external(name: product.rawValue)
    }
}
