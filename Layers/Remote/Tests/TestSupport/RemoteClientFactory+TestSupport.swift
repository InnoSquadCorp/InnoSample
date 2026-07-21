import Foundation
import InnoNetwork
import InnoNetworkTestSupport
@testable import Remote

extension RemoteClientFactory {
    static func makeTransport(
        baseURL: URL,
        session: MockURLSession,
        tokenStore: RemoteTokenStore = RemoteTokenStore(),
        responseCache: (any ResponseCache)? = nil
    ) -> RemoteTransport {
        let configuration = makeConfiguration(
            environment: RemoteEnvironment(baseURL: baseURL),
            tokenStore: tokenStore,
            responseCache: responseCache
        )
        return RemoteTransport(
            client: DefaultNetworkClient(configuration: configuration, session: session)
        )
    }
}
