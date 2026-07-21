import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.compositeFeature(
    .entireTab,
    children: [.people, .posts, .settings],
    packages: [.innoDI, .innoFlow, .innoRouter],
    dependencies: .init(
        logic: [
            .package(.innoDI),
            .package(.innoFlow)
        ],
        router: [
            .package(.innoDI),
            .package(.innoDIDAGValidationPlugin),
            .package(.innoRouter),
            .package(.innoRouterMacros)
        ]
    )
)
