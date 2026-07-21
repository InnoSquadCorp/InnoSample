import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    .settings,
    packages: [.innoDI, .innoFlow, .innoRouter],
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
            .package(.innoDIDAGValidationPlugin),
            .package(.innoRouter),
            .package(.innoRouterMacros)
        ],
        tests: [
            .layer(.domain),
            .package(.innoFlowTesting),
            .package(.innoRouterTesting)
        ]
    )
)
