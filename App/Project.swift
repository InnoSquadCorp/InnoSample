import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.app(
    packages: [.innoDI],
    infoPlistValues: [
        "CFBundleDisplayName": .string("InnoSample"),
        "CFBundleURLTypes": .array([
            .dictionary([
                "CFBundleURLName": .string("com.innosquad.InnoSample.app"),
                "CFBundleURLSchemes": .array([.string("innosample")]),
            ])
        ]),
    ],
    launchScreen: .default(),
    watchCompanion: .init(
        appName: "InnoSampleWatchApp",
        appBundleNamespace: "app.watchkitapp",
        appDisplayName: "InnoSample Watch",
        dependencies: [.layer(.domain)]
    ),
    dependencies: [
        .features,
        .layers,
        .thirdParty(.analytics),
        .thirdParty(interface: .analytics),
        .package(.innoDI),
        .package(.innoDIDAGValidationPlugin)
    ],
    testDependencies: [
        .features,
        .layers,
        .thirdParty(.analytics),
        .thirdParty(interface: .analytics)
    ],
    schemes: [
        Project.moduleScheme(
            name: "InnoSampleAppUnitTests",
            buildTargets: [.target("InnoSampleApp")],
            testTargets: [.testableTarget(target: .target("InnoSampleAppTests"))]
        ),
        Project.appScheme(
            name: "InnoSampleApp",
            testTarget: "InnoSampleAppTests",
            uiTestTarget: "InnoSampleAppUITests"
        )
    ]
)
