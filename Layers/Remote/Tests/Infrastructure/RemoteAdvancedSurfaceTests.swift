import Foundation
import InnoNetwork
import InnoNetworkTestSupport
import Testing
@testable import Remote

@Suite("Released operation and encoded-request surfaces")
struct RemoteAdvancedSurfaceTests {
    @Test("JSON endpoints use the same client through an operation handle")
    func operationReturnsTypedJSON() async throws {
        let session = MockURLSession()
        session.setMockResponse(statusCode: 200, data: Data("[]".utf8))
        let client = makeClient(session)
        let operation = OperationNetworkClient(client: client).start(FetchUsersRequest())

        #expect(try await operation.value().isEmpty)
        #expect(session.capturedRequestsInOrder.count == 1)
        await client.shutdown()
    }

    @Test("an expired deadline fails before transport")
    func expiredDeadlineDoesNotSend() async {
        let session = MockURLSession()
        let client = makeClient(session)
        let operation = OperationNetworkClient(client: client).start(
            FetchUsersRequest(), deadline: .init(after: .zero)
        )
        do {
            _ = try await operation.value()
            Issue.record("Expected deadline failure")
        } catch {
            #expect(error.kind == .timeout)
            #expect(error.deadlineStage == .requestPreparation)
            #expect(error.recovery == .retry)
        }
        #expect(session.capturedRequestsInOrder.isEmpty)
        await client.shutdown()
    }

    @Test("binary payloads keep their codec and resource bounds explicit")
    func encodedPayloadRoundTrip() async throws {
        let session = MockURLSession()
        session.setMockResponse(statusCode: 200, data: Data([9, 8]))
        let client = makeClient(session)
        let payload = Data([1, 2, 3])
        let request = EncodedRequest<Data>(
            method: .post, path: "/binary", auth: .anonymous,
            body: .init(contentType: "application/octet-stream", maximumBytes: 16) { payload },
            options: .init(maximumResponseBytes: 16),
            responseDecoder: .init { data, _ in data }
        )
        let result = try await OperationNetworkClient(client: client).start(request).value()

        #expect(result == Data([9, 8]))
        let sent = try #require(session.capturedRequestsInOrder.first)
        #expect(sent.httpBody == payload)
        #expect(sent.value(forHTTPHeaderField: "Content-Type") == "application/octet-stream")
        await client.shutdown()
    }

    @Test("oversized encoded requests fail before transport")
    func encodedRequestBudgetIsEnforced() async {
        let session = MockURLSession()
        let client = makeClient(session)
        let request = EncodedRequest<Data>(
            method: .post, path: "/binary", auth: .anonymous,
            body: .init(contentType: "application/octet-stream", maximumBytes: 1) { Data([1, 2]) },
            responseDecoder: .init { data, _ in data }
        )
        await #expect(throws: NetworkError.self) { try await client.request(request) }
        #expect(session.capturedRequestsInOrder.isEmpty)
        await client.shutdown()
    }

    @Test("client shutdown is terminal for later operations")
    func closedClientDoesNotSend() async {
        let session = MockURLSession()
        let client = makeClient(session)
        await client.shutdown()
        let operation = OperationNetworkClient(client: client).start(FetchUsersRequest())
        do {
            _ = try await operation.value()
            Issue.record("Expected cancelled operation")
        } catch {
            #expect(error.kind == .cancelled)
            #expect(error.recovery == .none)
        }
        #expect(session.capturedRequestsInOrder.isEmpty)
    }

    private func makeClient(_ session: MockURLSession) -> DefaultNetworkClient {
        DefaultNetworkClient(
            configuration: .safeDefaults(baseURL: URL(string: "https://example.com")!),
            session: session
        )
    }
}
