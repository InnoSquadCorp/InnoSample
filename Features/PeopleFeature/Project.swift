import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    .people,
    dependencies: .init(
        interface: [
            .layer(.domain)
        ],
        logic: [
            .layer(.domain),
            .package(.innoDI),
            .package(.innoFlow)
        ],
        ui: [
            .util(.designSupport)
        ],
        router: [
            .package(.innoDI),
            .package(.innoRouter),
            .package(.innoRouterMacros)
        ],
        tests: [
            .layer(.domain)
        ]
    )
)
