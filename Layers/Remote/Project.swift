import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.leafLayer(
    .remote,
    dependencies: [
        .core(.network),
        .layer(.data)
    ]
)
