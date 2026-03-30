import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    launchScreen: .default(),
    watchCompanion: .default(),
    dependencies: [
        .features,
        .core(.network),
        .layers,
        .thirdParty(.analytics),
        .thirdParty(interface: .analytics),
        .package(.innoDI)
    ],
    testDependencies: [
        .features,
        .core(.network),
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
