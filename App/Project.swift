import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    launchScreen: .default(),
    watchCompanion: .default(),
    dependencies: [
        .features,
        .layers,
        .thirdParty(.analytics),
        .thirdParty(interface: .analytics),
        .package(.innoDISwiftUI)
    ],
    testDependencies: [
        .features,
        .layers,
        .thirdParty(.analytics),
        .thirdParty(interface: .analytics)
    ],
    schemes: [
        Project.appScheme(
            name: "InnoSampleApp",
            testTarget: "InnoSampleAppTests",
            uiTestTarget: "InnoSampleAppUITests"
        )
    ]
)
