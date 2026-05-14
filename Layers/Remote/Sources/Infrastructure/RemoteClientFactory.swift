import Foundation
import InnoNetwork

enum RemoteClientFactory {
    static func makeTransport(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared,
        tokenStore: RemoteTokenStore = RemoteTokenStore()
    ) -> RemoteTransport {
        RemoteTransport(
            client: makeClient(baseURL: baseURL, session: session, tokenStore: tokenStore)
        )
    }

    static func makeClient(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared,
        tokenStore: RemoteTokenStore = RemoteTokenStore()
    ) -> any NetworkClient {
        let environment = RemoteEnvironment(baseURL: baseURL)
        return makeClient(environment: environment, session: session, tokenStore: tokenStore)
    }

    static func makeClient(
        environment: RemoteEnvironment,
        session: URLSessionProtocol = URLSession.shared,
        tokenStore: RemoteTokenStore = RemoteTokenStore()
    ) -> any NetworkClient {
        let configuration = NetworkConfiguration.advanced(
            baseURL: environment.baseURL,
            resilience: ResiliencePack(
                retry: ExponentialBackoffRetryPolicy(
                    maxRetries: 2,
                    maxTotalRetries: 2,
                    retryDelay: 0.4,
                    maxRetryAfterDelay: 1.5,
                    maxDelay: 1.5,
                    waitsForNetworkChanges: true,
                    networkChangeTimeout: 3.0
                )
            ),
            auth: AuthPack(
                refreshToken: makeRefreshTokenPolicy(tokenStore: tokenStore),
                additionalSigners: [
                    RemoteMetadataInterceptor(environment: environment),
                ],
                additionalResponseInterceptors: [
                    RemoteStatusInterceptor(),
                ]
            ),
            transport: TransportPack(
                timeout: 20.0,
                cachePolicy: .reloadIgnoringLocalCacheData
            )
        )
        return DefaultNetworkClient(configuration: configuration, session: session)
    }

    /// Bearer-token refresh policy used for endpoints opting into
    /// `Auth = AuthRequiredScope`. The closures are stateless from the
    /// library's perspective — single-flight coordination and one-time
    /// replay on 401 live inside InnoNetwork's `RefreshTokenCoordinator`.
    private static func makeRefreshTokenPolicy(
        tokenStore: RemoteTokenStore
    ) -> RefreshTokenPolicy {
        RefreshTokenPolicy(
            currentToken: { await tokenStore.token() },
            refreshToken: { await tokenStore.rotateToken() }
        )
    }
}
