import Foundation
import InnoNetwork
import InnoNetworkTestSupport
@testable import Remote
import XCTest

final class RemoteTransportTests: XCTestCase {
    func testSendAppliesRemoteHeadersAndDecodesResponse() async throws {
        let session = MockURLSession()
        session.setMockResponse(statusCode: 200, data: Self.usersFixture)
        let transport = RemoteClientFactory.makeTransport(
            baseURL: URL(string: "https://example.com")!,
            session: session
        )

        let users = try await transport.send(FetchUsersRequest())

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.city, "Seoul")

        let request = session.capturedRequest
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Accept-Language"), Locale.preferredLanguages.first ?? "ko-KR")
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "Accept-Encoding"))
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), "InnoSample/1.0.0 (\(RemotePlatformInfo.name))")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "X-Sample-Feature"), "People")
        XCTAssertNil(request?.value(forHTTPHeaderField: "X-Request-ID"))
    }

    func testSendMapsStatusCodeFailureToRemoteFailure() async throws {
        let session = MockURLSession()
        session.setMockResponse(statusCode: 500, data: Data("{}".utf8))
        let transport = RemoteClientFactory.makeTransport(
            baseURL: URL(string: "https://example.com")!,
            session: session
        )

        do {
            _ = try await transport.send(FetchPostsRequest())
            XCTFail("Expected RemoteFailure.invalidStatus")
        } catch let failure as RemoteFailure {
            guard case .invalidStatus(let code, _, let request) = failure else {
                return XCTFail("Unexpected failure: \(failure)")
            }
            XCTAssertEqual(code, 500)
            XCTAssertEqual(request?.url?.path, "/posts")
        }
    }

    func testMacroFirstContractsAndTypedStubClient() async throws {
        let usersRequest = FetchUsersRequest()
        let todosRequest = FetchTodosRequest()

        XCTAssertEqual(usersRequest.method, .get)
        XCTAssertEqual(usersRequest.path, "/users")
        XCTAssertEqual(usersRequest.sessionAuthentication, .anonymous)
        XCTAssertNil(usersRequest.parameters)
        XCTAssertEqual(todosRequest.method, .get)
        XCTAssertEqual(todosRequest.path, "/todos")
        XCTAssertEqual(todosRequest.sessionAuthentication, .required)

        let expected = try JSONDecoder().decode(FetchUsersRequest.APIResponse.self, from: Self.usersFixture)
        let client = StubNetworkClient()
        client.register(expected, for: usersRequest)

        let users = try await RemoteTransport(client: client).send(usersRequest)

        XCTAssertEqual(users.first?.name, "Alex")
    }

    private static let usersFixture = Data(
        """
        [
          {
            "id": 1,
            "name": "Alex",
            "username": "alex",
            "email": "alex@example.com",
            "phone": "010-1111-2222",
            "website": "alex.dev",
            "address": { "city": "Seoul" },
            "company": { "name": "InnoSquad" }
          }
        ]
        """.utf8
    )
}
