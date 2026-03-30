import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.layer(
    .layers,
    dependencies: [
        .core(.network),
        .layer(.data),
        .layer(.domain),
        .layer(.remote),
        .package(.innoDI)
    ],
    testDependencies: [
        .core(.network),
        .layer(.domain),
        .package(.innoNetwork)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Layers",
            buildTargets: [.target("Layers")],
            testTargets: [.testableTarget(target: .target("LayersTests"))]
        )
    ]
)
