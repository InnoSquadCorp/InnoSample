import ProjectDescription

public extension Project {
    static func moduleScheme(
        name: String,
        buildTargets: [TargetReference],
        testTargets: [TestableTarget] = [],
        runTarget: String? = nil
    ) -> Scheme {
        .scheme(
            name: name,
            shared: true,
            hidden: false,
            buildAction: buildTargets.isEmpty ? nil : .buildAction(targets: buildTargets),
            testAction: testTargets.isEmpty ? nil : .targets(testTargets),
            runAction: runTarget.map {
                .runAction(configuration: .debug, executable: .init(stringLiteral: $0))
            }
        )
    }

    static func featureScheme(module: FeatureModule) -> Scheme {
        moduleScheme(
            name: module.rawValue,
            buildTargets: [.target(module.routerTargetName)],
            testTargets: [.testableTarget(target: .target(module.testsTargetName))]
        )
    }

    static func appScheme(
        name: String,
        testTarget: String? = nil,
        uiTestTarget: String? = nil
    ) -> Scheme {
        moduleScheme(
            name: name,
            buildTargets: [.target(name)],
            testTargets: [testTarget, uiTestTarget].compactMap { targetName in
                targetName.map { .testableTarget(target: .target($0)) }
            },
            runTarget: name
        )
    }
}
