import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.leafLayer(
    .remote,
    packages: [.innoDI, .innoNetwork],
    dependencies: [
        .layer(.data),
        .package(.innoDI),
        .package(.innoDIDAGValidationPlugin),
        .package(.innoNetwork),
        .package(.innoNetworkPersistentCache)
    ],
    testBuildableFolders: ["Tests"],
    testDependencies: [
        .package(.innoNetwork),
        .package(.innoNetworkPersistentCache),
        .package(.innoNetworkTestSupport)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Remote",
            buildTargets: [.target("Remote")],
            testTargets: [.testableTarget(target: .target("RemoteTests"))]
        )
    ]
)
