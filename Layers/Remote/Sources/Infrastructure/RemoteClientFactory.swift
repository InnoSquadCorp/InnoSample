import Foundation
import InnoNetwork

enum RemoteClientFactory {
    static func makeTransport(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared
    ) -> RemoteTransport {
        RemoteTransport(client: makeClient(baseURL: baseURL, session: session))
    }

    static func makeClient(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared
    ) -> any NetworkClient {
        let environment = RemoteEnvironment(baseURL: baseURL)
        return makeClient(environment: environment, session: session)
    }

    static func makeClient(
        environment: RemoteEnvironment,
        session: URLSessionProtocol = URLSession.shared
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
}
