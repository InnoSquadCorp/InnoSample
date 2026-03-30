import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    .settings,
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
            .package(.innoRouter)
        ],
        tests: [
            .layer(.domain)
        ]
    )
)
