import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.leafLayer(
    .data,
    dependencies: [
        .layer(.domain),
        .package(.innoDI)
    ],
    testBuildableFolders: ["Tests"],
    testDependencies: [
        .layer(.domain)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Data",
            buildTargets: [.target("Data")],
            testTargets: [.testableTarget(target: .target("DataTests"))]
        )
    ]
)
