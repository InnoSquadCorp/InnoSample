import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.layer(
    .layers,
    dependencies: [
        .layer(.data),
        .layer(.domain),
        .layer(.remote),
        .package(.innoDI)
    ],
    testDependencies: [
        .layer(.domain)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Layers",
            buildTargets: [.target("Layers")],
            testTargets: [.testableTarget(target: .target("LayersTests"))]
        )
    ]
)
