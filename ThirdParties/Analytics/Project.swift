import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.thirdParty(
    .analytics,
    schemes: [
        Project.moduleScheme(
            name: "Analytics",
            buildTargets: [.target("Analytics")],
            testTargets: [.testableTarget(target: .target("AnalyticsTests"))]
        )
    ]
)
