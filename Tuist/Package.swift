// swift-tools-version: 6.3

@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [:]
)
#endif

let package = Package(
    name: "InnoSampleDependencies",
    dependencies: []
)
