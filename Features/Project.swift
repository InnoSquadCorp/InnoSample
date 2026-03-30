import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.rootFeatures(
    dependencies: [
        .feature(router: .entireTab),
        .feature(router: .people),
        .feature(router: .posts),
        .feature(router: .settings),
        .feature(interface: .entireTab),
        .feature(interface: .people),
        .feature(interface: .posts),
        .feature(interface: .settings),
        .layer(.domain)
    ],
    testDependencies: [
        .layer(.domain),
        .feature(interface: .entireTab)
    ],
    schemes: [
        Project.moduleScheme(
            name: "Features",
            buildTargets: [.target("Features")],
            testTargets: [.testableTarget(target: .target("FeaturesTests"))]
        )
    ]
)
