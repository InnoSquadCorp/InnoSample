import ProjectDescription

public struct LaunchScreenConfiguration {
    public let storyboardName: String
    public let resources: ResourceFileElements?

    public init(
        storyboardName: String,
        resources: ResourceFileElements? = nil
    ) {
        self.storyboardName = storyboardName
        self.resources = resources
    }

    public static func `default`(storyboardName: String = "LaunchScreen") -> Self {
        .init(
            storyboardName: storyboardName,
            resources: [
                .glob(
                    pattern: "Resources/\(storyboardName).storyboard",
                    inclusionCondition: .when([.ios])
                )
            ]
        )
    }
}

public struct WatchCompanionConfiguration {
    public let appName: String
    public let appBundleNamespace: String
    public let extensionName: String
    public let extensionBundleNamespace: String
    public let appDisplayName: String
    public let extensionDisplayName: String
    public let extensionBuildableFolders: [BuildableFolder]
    public let appResources: ResourceFileElements?
    public let extensionResources: ResourceFileElements?
    public let extensionDependencies: [TargetDependency]

    public init(
        appName: String,
        appBundleNamespace: String,
        extensionName: String,
        extensionBundleNamespace: String,
        appDisplayName: String,
        extensionDisplayName: String,
        extensionBuildableFolders: [BuildableFolder] = ["WatchExtension/Sources"],
        appResources: ResourceFileElements? = ["WatchApp/Resources/**"],
        extensionResources: ResourceFileElements? = nil,
        extensionDependencies: [TargetDependency] = []
    ) {
        self.appName = appName
        self.appBundleNamespace = appBundleNamespace
        self.extensionName = extensionName
        self.extensionBundleNamespace = extensionBundleNamespace
        self.appDisplayName = appDisplayName
        self.extensionDisplayName = extensionDisplayName
        self.extensionBuildableFolders = extensionBuildableFolders
        self.appResources = appResources
        self.extensionResources = extensionResources
        self.extensionDependencies = extensionDependencies
    }

    public static func `default`(
        appName: String = "InnoSampleWatchApp",
        extensionName: String = "InnoSampleWatchExtension"
    ) -> Self {
        .init(
            appName: appName,
            appBundleNamespace: "app.watchkitapp",
            extensionName: extensionName,
            extensionBundleNamespace: "app.watchkitapp.watchkitextension",
            appDisplayName: "InnoSample Watch",
            extensionDisplayName: "InnoSample Watch Extension"
        )
    }
}

public extension Project {
    static func app(
        name: String = "InnoSampleApp",
        bundleNamespace: String = "app",
        packages: [Package] = [],
        destinations: Destinations = Manifest.defaultDestinations,
        deploymentTargets: DeploymentTargets = Manifest.defaultDeploymentTargets,
        settings: Settings = Manifest.baseSettings,
        options: Project.Options = .options(
            automaticSchemesOptions: .disabled,
            defaultKnownRegions: Manifest.knownRegions
        ),
        infoPlistValues: [String: Plist.Value] = [
            "CFBundleDisplayName": .string("InnoSample")
        ],
        launchScreen: LaunchScreenConfiguration? = .default(),
        scripts: [TargetScript] = [],
        resources: ResourceFileElements? = nil,
        watchCompanion: WatchCompanionConfiguration? = nil,
        dependencies: [TargetDependency],
        testBuildableFolders: [BuildableFolder] = ["Tests"],
        testDependencies: [TargetDependency] = [],
        uiTestBuildableFolders: [BuildableFolder] = ["UITests"],
        uiTestDependencies: [TargetDependency] = [],
        schemes: [Scheme] = []
    ) -> Self {
        var resolvedInfoPlistValues = infoPlistValues
        if let launchScreen {
            resolvedInfoPlistValues["UILaunchStoryboardName"] = .string(launchScreen.storyboardName)
        }

        return appProject(
            name: name,
            bundleNamespace: bundleNamespace,
            packages: packages,
            destinations: destinations,
            deploymentTargets: deploymentTargets,
            settings: settings,
            options: options,
            infoPlist: .extendingDefault(with: resolvedInfoPlistValues),
            scripts: scripts,
            resources: resources ?? launchScreen?.resources,
            watchCompanion: watchCompanion,
            dependencies: dependencies,
            testBuildableFolders: testBuildableFolders,
            testDependencies: testDependencies,
            uiTestBuildableFolders: uiTestBuildableFolders,
            uiTestDependencies: uiTestDependencies,
            schemes: schemes
        )
    }
}
