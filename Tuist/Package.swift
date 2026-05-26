// swift-tools-version: 6.3

@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "InnoDI": .framework,
        "InnoDICore": .staticLibrary,
        "InnoDISwiftUI": .framework,
        "InnoFlow": .framework,
        "InnoNetwork": .framework,
        "InnoNetworkPersistentCache": .framework,
        "InnoRouter": .framework,
        "InnoRouterCore": .framework,
        "InnoRouterSwiftUI": .framework,
        "InnoRouterDeepLink": .framework,
    ]
)
#endif

let package = Package(
    name: "InnoSampleDependencies",
    dependencies: [
        .package(url: "https://github.com/InnoSquadCorp/InnoDI.git", exact: "4.3.0"),
        .package(url: "https://github.com/InnoSquadCorp/InnoFlow", exact: "4.0.0"),
        .package(url: "https://github.com/InnoSquadCorp/InnoNetwork.git", exact: "4.0.0"),
        .package(url: "https://github.com/InnoSquadCorp/InnoRouter.git", exact: "4.2.1"),
    ]
)
