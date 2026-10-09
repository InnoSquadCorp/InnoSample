import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.layer(
    .domain,
    packages: [.innoDI],
    dependencies: [
        .package(.innoDI),
        .package(.innoDIDAGValidationPlugin)
    ],
    testBuildableFolders: ["Tests"],
    testDependencies: [.package(.innoDI), .package(.innoDITesting)],
    schemes: [
        Project.moduleScheme(
            name: "Domain",
            buildTargets: [.target("Domain")],
            testTargets: [.testableTarget(target: .target("DomainTests"))]
        )
    ]
)
