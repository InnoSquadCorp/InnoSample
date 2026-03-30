import ProjectDescription

public struct FeatureTargetDependencies {
    public var interface: [TargetDependency]
    public var logic: [TargetDependency]
    public var ui: [TargetDependency]
    public var router: [TargetDependency]
    public var testing: [TargetDependency]
    public var tests: [TargetDependency]

    public init(
        interface: [TargetDependency] = [],
        logic: [TargetDependency] = [],
        ui: [TargetDependency] = [],
        router: [TargetDependency] = [],
        testing: [TargetDependency] = [],
        tests: [TargetDependency] = []
    ) {
        self.interface = interface
        self.logic = logic
        self.ui = ui
        self.router = router
        self.testing = testing
        self.tests = tests
    }
}

public extension Project {
    static func rootFeatures(
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
        frameworkProject(
            name: FeatureModule.features.rawValue,
            bundleNamespace: FeatureModule.features.bundleNamespace,
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

    static func feature(
        _ module: FeatureModule,
        packages: [Package] = [],
        dependencies: FeatureTargetDependencies = .init()
    ) -> Self {
        precondition(module != .features, "Use rootFeatures(...) for the root Features target.")

        let interfaceTarget = Target.target(
            name: module.interfaceTargetName,
            destinations: Manifest.defaultDestinations,
            product: .framework,
            bundleId: "\(Manifest.bundlePrefix).\(module.interfaceBundleNamespace)",
            deploymentTargets: Manifest.defaultDeploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Interfaces"],
            dependencies: dependencies.interface
        )

        let logicTarget = Target.target(
            name: module.logicTargetName,
            destinations: Manifest.defaultDestinations,
            product: .staticLibrary,
            bundleId: "\(Manifest.bundlePrefix).\(module.logicBundleNamespace)",
            deploymentTargets: Manifest.defaultDeploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Logics"],
            dependencies: [.feature(interface: module)] + dependencies.logic
        )

        let uiTarget = Target.target(
            name: module.uiTargetName,
            destinations: Manifest.defaultDestinations,
            product: .staticLibrary,
            bundleId: "\(Manifest.bundlePrefix).\(module.uiBundleNamespace)",
            deploymentTargets: Manifest.defaultDeploymentTargets,
            infoPlist: .default,
            buildableFolders: ["UIs"],
            dependencies: [.feature(interface: module), .feature(logic: module)] + dependencies.ui
        )

        let routerTarget = Target.target(
            name: module.routerTargetName,
            destinations: Manifest.defaultDestinations,
            product: .staticLibrary,
            bundleId: "\(Manifest.bundlePrefix).\(module.routerBundleNamespace)",
            deploymentTargets: Manifest.defaultDeploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Router"],
            dependencies: [.feature(interface: module), .feature(ui: module)] + dependencies.router
        )

        let testingTarget = Target.target(
            name: module.testingTargetName,
            destinations: Manifest.defaultDestinations,
            product: .staticLibrary,
            bundleId: "\(Manifest.bundlePrefix).\(module.testingBundleNamespace)",
            deploymentTargets: Manifest.defaultDeploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Testings"],
            dependencies: [.feature(interface: module)] + dependencies.testing
        )

        let testsTarget = Target.target(
            name: module.testsTargetName,
            destinations: Manifest.defaultDestinations,
            product: .unitTests,
            bundleId: "\(Manifest.bundlePrefix).\(module.bundleNamespace).tests",
            deploymentTargets: Manifest.defaultDeploymentTargets,
            infoPlist: .default,
            buildableFolders: ["Tests"],
            dependencies: [
                .xctest,
                .feature(interface: module),
                .feature(logic: module),
                .feature(ui: module),
                .feature(router: module),
                .feature(testing: module)
            ] + dependencies.tests
        )

        return .init(
            name: module.rawValue,
            organizationName: Manifest.organizationName,
            options: .options(
                automaticSchemesOptions: .disabled,
                defaultKnownRegions: Manifest.knownRegions
            ),
            packages: packages,
            settings: Manifest.baseSettings,
            targets: [
                interfaceTarget,
                logicTarget,
                uiTarget,
                routerTarget,
                testingTarget,
                testsTarget
            ],
            schemes: [
                featureScheme(module: module)
            ]
        )
    }

    static func compositeFeature(
        _ module: FeatureModule,
        children: [FeatureModule],
        packages: [Package] = [],
        dependencies: FeatureTargetDependencies = .init()
    ) -> Self {
        precondition(module != .features, "Use rootFeatures(...) for the root Features target.")
        precondition(children.allSatisfy { $0 != .features && $0 != module }, "Composite feature children must be leaf features.")

        var compositeDependencies = dependencies
        compositeDependencies.interface += children.map { .feature(interface: $0) }
        compositeDependencies.router += children.flatMap(TargetDependency.childFeature(_:))

        return feature(
            module,
            packages: packages,
            dependencies: compositeDependencies
        )
    }
}
