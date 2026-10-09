import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        compatibleXcodeVersions: .upToNextMajor("27.1"),
        swiftVersion: "6.4"
    )
)
