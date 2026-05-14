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
    public let appDisplayName: String
    public let buildableFolders: [BuildableFolder]
    public let appResources: ResourceFileElements?
    public let dependencies: [TargetDependency]

    public init(
        appName: String,
        appBundleNamespace: String,
        appDisplayName: String,
        buildableFolders: [BuildableFolder] = ["WatchApp/Sources"],
        appResources: ResourceFileElements? = ["WatchApp/Resources/**"],
        dependencies: [TargetDependency] = []
    ) {
        self.appName = appName
        self.appBundleNamespace = appBundleNamespace
        self.appDisplayName = appDisplayName
        self.buildableFolders = buildableFolders
        self.appResources = appResources
        self.dependencies = dependencies
    }

    public static func `default`(
        appName: String = "InnoSampleWatchApp"
    ) -> Self {
        .init(
            appName: appName,
            appBundleNamespace: "app.watchkitapp",
            appDisplayName: "InnoSample Watch"
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
