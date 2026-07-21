import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.leafLayer(
    .data,
    packages: [.innoDI],
    dependencies: [
        .layer(.domain),
        .package(.innoDI),
        .package(.innoDIDAGValidationPlugin)
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
