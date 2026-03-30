import ProjectDescription

extension Project {
    private static var defaultOptions: Project.Options {
        .options(
            automaticSchemesOptions: .disabled,
            defaultKnownRegions: Manifest.knownRegions
        )
    }

    private static func moduleTarget(
        name: String,
        destinations: Destinations,
        product: Product,
        bundleNamespace: String,
        deploymentTargets: DeploymentTargets,
        infoPlist: InfoPlist,
        buildableFolders: [BuildableFolder],
        resources: ResourceFileElements?,
        scripts: [TargetScript],
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: "\(Manifest.bundlePrefix).\(bundleNamespace)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            resources: resources,
            buildableFolders: buildableFolders,
            scripts: scripts,
            dependencies: dependencies
        )
    }

    private static func appTarget(
        name: String,
        destinations: Destinations,
        bundleNamespace: String,
        deploymentTargets: DeploymentTargets,
        infoPlist: InfoPlist,
        sources: SourceFilesList,
        resources: ResourceFileElements?,
        scripts: [TargetScript],
        dependencies: [TargetDependency]
    ) -> Target {
        .target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: "\(Manifest.bundlePrefix).\(bundleNamespace)",
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            scripts: scripts,
            dependencies: dependencies
        )
    }

    private static func watchAppTarget(
        configuration: WatchCompanionConfiguration,
        mainBundleId: String
    ) -> Target {
        .target(
            name: configuration.appName,
            destinations: Manifest.watchOnlyDestinations,
            product: .watch2App,
            bundleId: "\(Manifest.bundlePrefix).\(configuration.appBundleNamespace)",
            deploymentTargets: Manifest.watchDeploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": .string(configuration.appDisplayName),
                    "WKApplication": .boolean(true),
                    "WKCompanionAppBundleIdentifier": .string(mainBundleId),
                ]
            ),
            resources: configuration.appResources,
            dependencies: [
                .target(name: configuration.extensionName)
            ]
        )
    }

    private static func watchExtensionTarget(
        configuration: WatchCompanionConfiguration
    ) -> Target {
        .target(
            name: configuration.extensionName,
            destinations: Manifest.watchOnlyDestinations,
            product: .watch2Extension,
            bundleId: "\(Manifest.bundlePrefix).\(configuration.extensionBundleNamespace)",
            deploymentTargets: Manifest.watchDeploymentTargets,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": .string(configuration.extensionDisplayName),
                ]
            ),
            resources: configuration.extensionResources,
            buildableFolders: configuration.extensionBuildableFolders,
            dependencies: configuration.extensionDependencies
        )
    }

    static func frameworkProject(
        name: String,
        bundleNamespace: String,
        packages: [Package] = [],
        destinations: Destinations = Manifest.sharedModuleDestinations,
        deploymentTargets: DeploymentTargets = Manifest.sharedModuleDeploymentTargets,
        settings: Settings = Manifest.baseSettings,
        options: Project.Options = defaultOptions,
        buildableFolders: [BuildableFolder] = ["Sources"],
        infoPlist: InfoPlist = .default,
        resources: ResourceFileElements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        testBuildableFolders: [BuildableFolder] = [],
        testDependencies: [TargetDependency] = [],
        schemes: [Scheme] = []
    ) -> Self {
        let mainTarget = moduleTarget(
            name: name,
            destinations: destinations,
            product: .framework,
            bundleNamespace: bundleNamespace,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            buildableFolders: buildableFolders,
            resources: resources,
            scripts: scripts,
            dependencies: dependencies
        )

        let testTargets: [Target]
        if testBuildableFolders.isEmpty, testDependencies.isEmpty {
            testTargets = []
        } else {
            testTargets = [
                testTarget(
                    targetName: name,
                    bundleNamespace: bundleNamespace,
                    destinations: destinations,
                    deploymentTargets: deploymentTargets,
                    buildableFolders: testBuildableFolders.isEmpty ? ["Tests"] : testBuildableFolders,
                    dependencies: testDependencies
                )
            ]
        }

        return .init(
            name: name,
            organizationName: Manifest.organizationName,
            options: options,
            packages: packages,
            settings: settings,
            targets: [mainTarget] + testTargets,
            schemes: schemes
        )
    }

    static func staticLibraryProject(
        name: String,
        bundleNamespace: String,
        packages: [Package] = [],
        destinations: Destinations = Manifest.defaultDestinations,
        deploymentTargets: DeploymentTargets = Manifest.defaultDeploymentTargets,
        settings: Settings = Manifest.baseSettings,
        options: Project.Options = defaultOptions,
        buildableFolders: [BuildableFolder] = ["Sources"],
        infoPlist: InfoPlist = .default,
        resources: ResourceFileElements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        testBuildableFolders: [BuildableFolder] = [],
        testDependencies: [TargetDependency] = [],
        schemes: [Scheme] = []
    ) -> Self {
        let mainTarget = moduleTarget(
            name: name,
            destinations: destinations,
            product: .staticLibrary,
            bundleNamespace: bundleNamespace,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            buildableFolders: buildableFolders,
            resources: resources,
            scripts: scripts,
            dependencies: dependencies
        )

        let testTargets: [Target]
        if testBuildableFolders.isEmpty, testDependencies.isEmpty {
            testTargets = []
        } else {
            testTargets = [
                testTarget(
                    targetName: name,
                    bundleNamespace: bundleNamespace,
                    destinations: destinations,
                    deploymentTargets: deploymentTargets,
                    buildableFolders: testBuildableFolders.isEmpty ? ["Tests"] : testBuildableFolders,
                    dependencies: testDependencies
                )
            ]
        }

        return .init(
            name: name,
            organizationName: Manifest.organizationName,
            options: options,
            packages: packages,
            settings: settings,
            targets: [mainTarget] + testTargets,
            schemes: schemes
        )
    }

    static func appProject(
        name: String = "InnoSampleApp",
        bundleNamespace: String = "app",
        packages: [Package] = [],
        destinations: Destinations = Manifest.defaultDestinations,
        deploymentTargets: DeploymentTargets = Manifest.defaultDeploymentTargets,
        settings: Settings = Manifest.baseSettings,
        options: Project.Options = defaultOptions,
        infoPlist: InfoPlist = .extendingDefault(
            with: [
                "CFBundleDisplayName": "InnoSample"
            ]
        ),
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
        let mainBundleId = "\(Manifest.bundlePrefix).\(bundleNamespace)"
        let mainTarget = appTarget(
            name: name,
            destinations: destinations,
            bundleNamespace: bundleNamespace,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: ["Sources/**"],
            resources: resources,
            scripts: scripts,
            dependencies: dependencies + (watchCompanion.map {
                [.target(name: $0.appName, condition: .when([.ios]))]
            } ?? [])
        )

        let testTargets: [Target]
        if testBuildableFolders.isEmpty {
            testTargets = []
        } else {
            testTargets = [
                testTarget(
                    targetName: name,
                    bundleNamespace: bundleNamespace,
                    destinations: destinations,
                    deploymentTargets: deploymentTargets,
                    buildableFolders: testBuildableFolders,
                    dependencies: testDependencies
                )
            ]
        }

        let uiTestTargets: [Target]
        if uiTestBuildableFolders.isEmpty {
            uiTestTargets = []
        } else {
            uiTestTargets = [
                uiTestTarget(
                    targetName: name,
                    bundleNamespace: bundleNamespace,
                    buildableFolders: uiTestBuildableFolders,
                    dependencies: uiTestDependencies
                )
            ]
        }

        let watchTargets: [Target] = if let watchCompanion {
            [
                watchAppTarget(configuration: watchCompanion, mainBundleId: mainBundleId),
                watchExtensionTarget(configuration: watchCompanion),
            ]
        } else {
            []
        }

        return .init(
            name: name,
            organizationName: Manifest.organizationName,
            options: options,
            packages: packages,
            settings: settings,
            targets: [mainTarget] + testTargets + uiTestTargets + watchTargets,
            schemes: schemes
        )
    }
}
