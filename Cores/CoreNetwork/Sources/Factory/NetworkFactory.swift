import Foundation
import InnoNetwork

public enum NetworkFactory {
    public static func makeEnvironment(baseURL: URL) -> NetworkEnvironment {
        NetworkEnvironment(
            baseURL: baseURL,
            appName: "InnoSample",
            appVersion: "1.0.0",
            environmentName: "sample-dev"
        )
    }

    public static func makeTransport(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared
    ) -> NetworkTransport {
        makeTransport(
            environment: makeEnvironment(baseURL: baseURL),
            session: session
        )
    }

    public static func makeTransport(
        environment: NetworkEnvironment,
        session: URLSessionProtocol = URLSession.shared
    ) -> NetworkTransport {
        let defaults = makeDefaults(environment: environment)
        return NetworkTransport(
            client: makeClient(environment: environment, session: session),
            defaults: defaults
        )
    }

    static func makeDefaults(environment: NetworkEnvironment) -> APIDefaults {
        APIDefaults(
            environment: environment,
            logger: RequestLogger(),
            requestInterceptors: [
                NetworkMetadataInterceptor(environment: environment),
            ],
            responseInterceptors: [
                NetworkStatusInterceptor(),
            ]
        )
    }

    static func makeClient(
        environment: NetworkEnvironment,
        session: URLSessionProtocol = URLSession.shared
    ) -> any LowLevelNetworkClient {
        let configuration = NetworkConfiguration.advanced(baseURL: environment.baseURL) { builder in
            builder.timeout = 20.0
            builder.cachePolicy = .reloadIgnoringLocalCacheData
            builder.retryPolicy = ExponentialBackoffRetryPolicy(
                maxRetries: 2,
                retryDelay: 0.4,
                maxDelay: 1.5,
                waitsForNetworkChanges: true,
                networkChangeTimeout: 3.0
            )
        }
        return DefaultNetworkClient(configuration: configuration, session: session)
    }
}
