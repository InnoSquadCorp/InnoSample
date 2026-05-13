import Foundation
@testable import Remote
import XCTest

final class RemoteTransportTests: XCTestCase {
    func testSendAppliesRemoteHeadersAndDecodesResponse() async throws {
        let session = StubURLSession(fixtures: ["/users": Self.usersFixture])
        let transport = RemoteClientFactory.makeTransport(
            baseURL: URL(string: "https://example.com")!,
            session: session
        )

        let users = try await transport.send(FetchUsersRequest())

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.city, "Seoul")

        let request = await session.lastRequest
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Accept-Language"), Locale.preferredLanguages.first ?? "ko-KR")
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "Accept-Encoding"))
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), "InnoSample/1.0.0 (\(RemotePlatformInfo.name))")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "X-Sample-Feature"), "People")
        XCTAssertNotNil(request?.value(forHTTPHeaderField: "X-Request-ID"))
    }

    func testSendMapsStatusCodeFailureToRemoteFailure() async throws {
        let session = StubURLSession(fixtures: ["/posts": Data("{}".utf8)], statusCode: 500)
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
