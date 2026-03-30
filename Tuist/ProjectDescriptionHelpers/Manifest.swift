import ProjectDescription

public enum Manifest {
    public static let organizationName = "InnoSquad"
    public static let bundlePrefix = "com.innosquad.InnoSample"
    public static let knownRegions = ["en", "ko", "Base"]
    public static let sharedModuleDestinations: Destinations = [.iPhone, .iPad, .mac, .appleTv, .appleVision, .appleWatch]
    public static let defaultDestinations: Destinations = [.iPhone, .iPad, .mac]
    public static let uiTestDestinations: Destinations = [.iPhone, .iPad]
    public static let watchOnlyDestinations: Destinations = [.appleWatch]
    public static let sharedModuleDeploymentTargets: DeploymentTargets = .multiplatform(
        iOS: "18.0",
        macOS: "15.0",
        watchOS: "11.0",
        tvOS: "18.0",
        visionOS: "2.0"
    )
    public static let defaultDeploymentTargets: DeploymentTargets = .multiplatform(
        iOS: "18.0",
        macOS: "15.0"
    )
    public static let uiTestDeploymentTargets: DeploymentTargets = .iOS("18.0")
    public static let watchDeploymentTargets: DeploymentTargets = .watchOS("11.0")
    public static let baseSettings: Settings = .settings(base: [
        "SWIFT_VERSION": "6.3",
        "CODE_SIGNING_ALLOWED": "NO",
        "CODE_SIGNING_REQUIRED": "NO"
    ])

}
