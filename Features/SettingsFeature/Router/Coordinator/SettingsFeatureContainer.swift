import InnoDI
import SettingsFeatureInterface

@DIContainerRole(role: ContainerRole.local, mainActor: true)
public struct SettingsFeatureContainer {
    @Input
    public var input: SettingsFeatureInput

    @Provide(.transient, SettingsFeatureCoordinator.self, with: [\Self.input])
    public var coordinator: SettingsFeatureCoordinator
}
