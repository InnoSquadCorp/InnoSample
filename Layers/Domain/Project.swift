import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.layer(
    .domain,
    dependencies: [
        .package(.innoDI)
    ],
    testBuildableFolders: ["Tests"],
    schemes: [
        Project.moduleScheme(
            name: "Domain",
            buildTargets: [.target("Domain")],
            testTargets: [.testableTarget(target: .target("DomainTests"))]
        )
    ]
)
