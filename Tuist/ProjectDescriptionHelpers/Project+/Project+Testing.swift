import ProjectDescription

public extension Project {
    static func testTarget(
        targetName: String,
        bundleNamespace: String,
        destinations: Destinations = Manifest.defaultDestinations,
        deploymentTargets: DeploymentTargets = Manifest.defaultDeploymentTargets,
        buildableFolders: [BuildableFolder] = ["Tests"],
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: "\(targetName)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(Manifest.bundlePrefix).\(bundleNamespace).tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .default,
            buildableFolders: buildableFolders,
            dependencies: [.target(name: targetName)] + dependencies
        )
    }

    static func uiTestTarget(
        targetName: String,
        bundleNamespace: String,
        buildableFolders: [BuildableFolder] = ["UITests"],
        dependencies: [TargetDependency] = []
    ) -> Target {
        .target(
            name: "\(targetName)UITests",
            destinations: Manifest.uiTestDestinations,
            product: .uiTests,
            bundleId: "\(Manifest.bundlePrefix).\(bundleNamespace).uitests",
            deploymentTargets: Manifest.uiTestDeploymentTargets,
            infoPlist: .default,
            buildableFolders: buildableFolders,
            dependencies: [.target(name: targetName)] + dependencies
        )
    }
}
