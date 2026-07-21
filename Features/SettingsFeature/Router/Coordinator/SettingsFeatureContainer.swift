import InnoDI
import SettingsFeatureInterface

@DIContainer(mainActor: true)
public struct SettingsFeatureContainer {
    @Provide(.input)
    public var input: SettingsFeatureInput

    @Provide(.transient, SettingsFeatureCoordinator.self, with: [\Self.input])
    public var coordinator: SettingsFeatureCoordinator
}
