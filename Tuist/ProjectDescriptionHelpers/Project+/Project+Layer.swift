import ProjectDescription

public extension Project {
    static func layer(
        _ module: LayerModule,
        packages: [Package] = [],
        destinations: Destinations? = nil,
        deploymentTargets: DeploymentTargets? = nil,
        settings: Settings = Manifest.baseSettings,
        options: Project.Options = .options(
            automaticSchemesOptions: .disabled,
            defaultKnownRegions: Manifest.knownRegions
        ),
        buildableFolders: [BuildableFolder] = ["Sources"],
        infoPlist: InfoPlist = .default,
        resources: ResourceFileElements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        testBuildableFolders: [BuildableFolder] = [],
        testDependencies: [TargetDependency] = [],
        schemes: [Scheme] = []
    ) -> Self {
        let resolvedDestinations = destinations ?? (
            module == .domain ? Manifest.sharedModuleDestinations : Manifest.defaultDestinations
        )
        let resolvedDeploymentTargets = deploymentTargets ?? (
            module == .domain ? Manifest.sharedModuleDeploymentTargets : Manifest.defaultDeploymentTargets
        )

        return frameworkProject(
            name: module.rawValue,
            bundleNamespace: module.bundleNamespace,
            packages: packages,
            destinations: resolvedDestinations,
            deploymentTargets: resolvedDeploymentTargets,
            settings: settings,
            options: options,
            buildableFolders: buildableFolders,
            infoPlist: infoPlist,
            resources: resources,
            scripts: scripts,
            dependencies: dependencies,
            testBuildableFolders: testBuildableFolders,
            testDependencies: testDependencies,
            schemes: schemes
        )
    }

    static func leafLayer(
        _ module: LayerModule,
        packages: [Package] = [],
        destinations: Destinations = Manifest.defaultDestinations,
        deploymentTargets: DeploymentTargets = Manifest.defaultDeploymentTargets,
        settings: Settings = Manifest.baseSettings,
        options: Project.Options = .options(
            automaticSchemesOptions: .disabled,
            defaultKnownRegions: Manifest.knownRegions
        ),
        buildableFolders: [BuildableFolder] = ["Sources"],
        infoPlist: InfoPlist = .default,
        resources: ResourceFileElements? = nil,
        scripts: [TargetScript] = [],
        dependencies: [TargetDependency] = [],
        testBuildableFolders: [BuildableFolder] = [],
        testDependencies: [TargetDependency] = [],
        schemes: [Scheme] = []
    ) -> Self {
        staticLibraryProject(
            name: module.rawValue,
            bundleNamespace: module.bundleNamespace,
            packages: packages,
            destinations: destinations,
            deploymentTargets: deploymentTargets,
            settings: settings,
            options: options,
            buildableFolders: buildableFolders,
            infoPlist: infoPlist,
            resources: resources,
            scripts: scripts,
            dependencies: dependencies,
            testBuildableFolders: testBuildableFolders,
            testDependencies: testDependencies,
            schemes: schemes
        )
    }
}
