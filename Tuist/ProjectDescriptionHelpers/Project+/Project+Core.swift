import ProjectDescription

public extension Project {
    static func core(
        _ module: CoreModule,
        packages: [Package] = [],
        destinations: Destinations = Manifest.sharedModuleDestinations,
        deploymentTargets: DeploymentTargets = Manifest.sharedModuleDeploymentTargets,
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
        frameworkProject(
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
