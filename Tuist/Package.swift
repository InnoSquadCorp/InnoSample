// swift-tools-version: 6.3

@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "InnoDI": .framework,
        "InnoFlow": .framework,
        "InnoNetwork": .framework,
        "InnoRouter": .framework,
    ]
)
#endif

let package = Package(
    name: "InnoSampleDependencies",
    dependencies: [
        .package(url: "https://github.com/InnoSquadCorp/InnoDI.git", exact: "3.0.1"),
        .package(url: "https://github.com/InnoSquadCorp/InnoFlow", exact: "3.0.2"),
        .package(url: "https://github.com/InnoSquadCorp/InnoNetwork.git", exact: "3.1.0"),
        .package(url: "https://github.com/InnoSquadCorp/InnoRouter.git", exact: "3.0.0"),
    ]
)
