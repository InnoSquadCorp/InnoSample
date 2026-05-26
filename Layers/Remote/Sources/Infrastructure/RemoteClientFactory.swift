import Foundation
import InnoNetwork

enum RemoteClientFactory {
    private static let authenticatedPaths: Set<String> = ["/todos"]

    static func makeTransport(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared,
        tokenStore: RemoteTokenStore = RemoteTokenStore(),
        responseCache: (any ResponseCache)? = nil
    ) -> RemoteTransport {
        RemoteTransport(
            client: makeClient(
                baseURL: baseURL,
                session: session,
                tokenStore: tokenStore,
                responseCache: responseCache
            )
        )
    }

    static func makeClient(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared,
        tokenStore: RemoteTokenStore = RemoteTokenStore(),
        responseCache: (any ResponseCache)? = nil
    ) -> any NetworkClient {
        let environment = RemoteEnvironment(baseURL: baseURL)
        return makeClient(
            environment: environment,
            session: session,
            tokenStore: tokenStore,
            responseCache: responseCache
        )
    }

    static func makeClient(
        environment: RemoteEnvironment,
        session: URLSessionProtocol = URLSession.shared,
        tokenStore: RemoteTokenStore = RemoteTokenStore(),
        responseCache: (any ResponseCache)? = nil
    ) -> any NetworkClient {
        let cache = responseCache.map {
            CachePack(
                responseCachePolicy: .rfc9111Compliant(wrapping: .cacheFirst(maxAge: .seconds(300))),
                responseCache: $0
            )
        } ?? CachePack()
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
            cache: cache,
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
            appliesTo: isAuthRequiredRequest,
            currentToken: { await tokenStore.token() },
            refreshToken: { await tokenStore.rotateToken() }
        )
    }

    private static func isAuthRequiredRequest(_ request: URLRequest) -> Bool {
        request.url.map { authenticatedPaths.contains($0.path) } ?? false
    }
}
