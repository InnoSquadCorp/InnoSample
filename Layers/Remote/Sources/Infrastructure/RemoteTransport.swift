import InnoNetwork

actor RemoteTransport {
    private let client: any NetworkClient

    init(client: any NetworkClient) {
        self.client = client
    }

    func send<Request: RemoteRequest & APIDefinition>(_ request: Request) async throws -> Request.APIResponse {
        do {
            return try await client.request(request)
        } catch {
            throw RemoteFailure(networkError: error)
        }
    }
}
