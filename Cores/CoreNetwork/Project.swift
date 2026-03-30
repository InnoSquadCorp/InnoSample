import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.core(
    .network,
    dependencies: [
        .package(.innoNetwork)
    ],
    testBuildableFolders: ["Tests"],
    testDependencies: [
        .package(.innoNetwork)
    ],
    schemes: [
        Project.moduleScheme(
            name: "CoreNetwork",
            buildTargets: [.target("CoreNetwork")],
            testTargets: [.testableTarget(target: .target("CoreNetworkTests"))]
        )
    ]
)
