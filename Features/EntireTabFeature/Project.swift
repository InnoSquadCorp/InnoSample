import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.compositeFeature(
    .entireTab,
    children: [.people, .posts, .settings],
    dependencies: .init(
        logic: [
            .package(.innoDI),
            .package(.innoFlow)
        ],
        router: [
            .package(.innoDI),
            .package(.innoRouter)
        ]
    )
)
