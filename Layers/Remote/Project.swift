import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.leafLayer(
    .remote,
    dependencies: [
        .layer(.data),
        .package(.innoNetwork)
    ],
    testBuildableFolders: ["Tests"],
    testDependencies: [
        .package(.innoNetwork)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Remote",
            buildTargets: [.target("Remote")],
            testTargets: [.testableTarget(target: .target("RemoteTests"))]
        )
    ]
)
