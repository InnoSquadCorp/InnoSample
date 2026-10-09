import Domain
import Foundation

@MainActor
enum SampleAppContainerFactory {
    static func make() -> AppContainer {
        let baseURL = URL(string: "https://jsonplaceholder.typicode.com")!
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            let domain = DomainContainer(dataContainer: SampleUITestRepositories())
            return AppContainer(baseURL: baseURL) { overrides in
                overrides.featureUseCases = domain
            }
        }
#endif
        return AppContainer(baseURL: baseURL)
    }
}
