@testable import CoreNetwork
import Foundation
import XCTest

final class NetworkTransportTests: XCTestCase {
    func testSendBuildsRequestWithQueryItemsAndExternalHeaders() async throws {
        let session = StubURLSession()
        let environment = NetworkEnvironment(
            baseURL: URL(string: "https://example.com")!,
            environmentName: "test"
        )
        let transport = NetworkFactory.makeTransport(environment: environment, session: session)
        let request = TransportTestRequest(
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "limit", value: "20"),
            ],
            headerPolicy: .external,
            additionalHeaders: ["X-Request-Source": "unit-test"]
        )

        let response = try await transport.send(request)
        let lastRequest = await session.lastRequest
        let capturedRequest = try XCTUnwrap(lastRequest)
        let components = URLComponents(url: try XCTUnwrap(capturedRequest.url), resolvingAgainstBaseURL: false)

        XCTAssertEqual(response, TransportTestResponse(value: "ok"))
        XCTAssertEqual(capturedRequest.httpMethod, "GET")
        XCTAssertEqual(components?.queryItems?.count, 2)
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "User-Agent"), environment.userAgent)
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "X-Request-Source"), "unit-test")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "X-Sample-Feature"), "People")
        XCTAssertNil(capturedRequest.value(forHTTPHeaderField: "X-Sample-Environment"))
        XCTAssertNil(capturedRequest.value(forHTTPHeaderField: "X-Sample-Client"))
        XCTAssertNotNil(capturedRequest.value(forHTTPHeaderField: "X-Request-ID"))
    }

    func testSendBuildsRequestWithJSONBodyAndAppHeaders() async throws {
        let session = StubURLSession()
        let environment = NetworkEnvironment(
            baseURL: URL(string: "https://example.com")!,
            environmentName: "test"
        )
        let transport = NetworkFactory.makeTransport(environment: environment, session: session)
        let body = Data(#"{"name":"alex"}"#.utf8)
        let request = TransportTestRequest(
            method: .post,
            body: .json(body),
            additionalHeaders: ["X-Request-Source": "unit-test"]
        )

        _ = try await transport.send(request)
        let lastRequest = await session.lastRequest
        let capturedRequest = try XCTUnwrap(lastRequest)

        XCTAssertEqual(capturedRequest.httpMethod, "POST")
        XCTAssertEqual(capturedRequest.httpBody, body)
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json; charset=UTF-8")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "X-Sample-Environment"), "test")
        XCTAssertEqual(capturedRequest.value(forHTTPHeaderField: "X-Sample-Client"), environment.clientIdentifier)
    }

    func testSendRejectsBodyAndQueryCombination() async {
        let session = StubURLSession()
        let transport = NetworkFactory.makeTransport(
            environment: NetworkEnvironment(baseURL: URL(string: "https://example.com")!),
            session: session
        )
        let request = TransportTestRequest(
            queryItems: [URLQueryItem(name: "page", value: "1")],
            body: .raw(Data("body".utf8))
        )

        do {
            _ = try await transport.send(request)
            XCTFail("Expected invalid request configuration failure")
        } catch let failure as NetworkFailure {
            guard case .invalidRequestConfiguration = failure else {
                XCTFail("Unexpected failure: \(failure)")
                return
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
