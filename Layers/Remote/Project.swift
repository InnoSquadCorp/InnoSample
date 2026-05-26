import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.leafLayer(
    .remote,
    dependencies: [
        .layer(.data),
        .package(.innoNetwork),
        .package(.innoNetworkPersistentCache)
    ],
    testBuildableFolders: ["Tests"],
    testDependencies: [
        .package(.innoNetwork),
        .package(.innoNetworkPersistentCache)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Remote",
            buildTargets: [.target("Remote")],
            testTargets: [.testableTarget(target: .target("RemoteTests"))]
        )
    ]
)
