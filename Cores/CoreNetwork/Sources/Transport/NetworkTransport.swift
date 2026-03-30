import Foundation
import InnoNetwork

public actor NetworkTransport {
    private let client: any LowLevelNetworkClient
    private let defaults: APIDefaults

    init(client: any LowLevelNetworkClient, defaults: APIDefaults) {
        self.client = client
        self.defaults = defaults
    }

    public func send<Request: RequestDefinition>(_ request: Request) async throws -> Request.ResponseBody {
        do {
            return try await client.perform(executable:
                RequestAdapter(request: request, apiDefaults: defaults)
            )
        } catch let error as NetworkError {
            throw NetworkFailure(networkError: error)
        } catch {
            throw NetworkFailure.transport(SendableUnderlyingError(error), request: nil)
        }
    }
}
