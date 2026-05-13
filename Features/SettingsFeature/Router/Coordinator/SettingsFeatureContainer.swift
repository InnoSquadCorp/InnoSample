import InnoDI
import SettingsFeatureInterface

@MainActor
@DIContainer
public struct SettingsFeatureContainer {
    @Provide(.input)
    public var input: SettingsFeatureInput

    @Provide(.transient, factory: { (input: SettingsFeatureInput) in
        SettingsFeatureCoordinator(input: input)
    }, concrete: true)
    public var coordinator: SettingsFeatureCoordinator
}
