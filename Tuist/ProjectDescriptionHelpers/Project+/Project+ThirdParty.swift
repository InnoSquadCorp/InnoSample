import ProjectDescription

public extension Project {
    static func thirdParty(
        _ module: ThirdPartyModule,
        packages: [Package] = [],
        interfaceBuildableFolders: [BuildableFolder] = ["Interfaces"],
        interfaceDependencies: [TargetDependency] = [],
        buildableFolders: [BuildableFolder] = ["Sources"],
        resources: ResourceFileElements? = nil,
        headers: Headers? = nil,
        dependencies: [TargetDependency] = [],
        testBuildableFolders: [BuildableFolder] = ["Tests"],
        testDependencies: [TargetDependency] = [],
        schemes: [Scheme] = []
    ) -> Self {
        let interfaceTargetName = "\(module.rawValue)Interface"
        let interfaceTarget = Target.target(
            name: interfaceTargetName,
            destinations: Manifest.sharedModuleDestinations,
            product: .framework,
            bundleId: "\(Manifest.bundlePrefix).\(module.bundleNamespace).interface",
            deploymentTargets: Manifest.sharedModuleDeploymentTargets,
            infoPlist: .default,
            buildableFolders: interfaceBuildableFolders,
            dependencies: interfaceDependencies
        )

        let implementationTarget = Target.target(
            name: module.rawValue,
            destinations: Manifest.sharedModuleDestinations,
            product: .staticLibrary,
            bundleId: "\(Manifest.bundlePrefix).\(module.bundleNamespace)",
            deploymentTargets: Manifest.sharedModuleDeploymentTargets,
            infoPlist: .default,
            resources: resources,
            buildableFolders: buildableFolders,
            headers: headers,
            dependencies: dependencies + [.target(name: interfaceTargetName)]
        )

        let testTargets: [Target]
        if testBuildableFolders.isEmpty, testDependencies.isEmpty {
            testTargets = []
        } else {
            testTargets = [
                testTarget(
                    targetName: module.rawValue,
                    bundleNamespace: module.bundleNamespace,
                    destinations: Manifest.sharedModuleDestinations,
                    deploymentTargets: Manifest.sharedModuleDeploymentTargets,
                    buildableFolders: testBuildableFolders,
                    dependencies: testDependencies
                )
            ]
        }

        return .init(
            name: module.rawValue,
            organizationName: Manifest.organizationName,
            options: .options(
                automaticSchemesOptions: .disabled,
                defaultKnownRegions: Manifest.knownRegions
            ),
            packages: packages,
            settings: Manifest.baseSettings,
            targets: [interfaceTarget, implementationTarget] + testTargets,
            schemes: schemes
        )
    }
}
