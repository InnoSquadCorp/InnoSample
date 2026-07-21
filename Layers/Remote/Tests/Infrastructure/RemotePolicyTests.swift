import Foundation
import InnoNetwork
import InnoNetworkTestSupport
@testable import Remote
import XCTest

final class RemotePolicyTests: XCTestCase {
    private let baseURL = URL(string: "https://example.com")!

    func testTransientServerErrorIsRetriedThenRecovers() async throws {
        let session = MockURLSession(sequences: [
            "/users": [
                .init(statusCode: 500),
                .init(statusCode: 200, data: Self.usersFixture),
            ]
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        let users = try await transport.send(FetchUsersRequest())

        XCTAssertEqual(users.count, 1)
        let callCount = session.callCount(forPath: "/users")
        XCTAssertEqual(callCount, 2, "single 500 should be retried exactly once before success")
    }

    func testRetryExhaustsAndMapsToInvalidStatus() async {
        let session = MockURLSession(sequences: [
            "/users": Array(
                repeating: MockURLSessionResponse(statusCode: 500),
                count: 5
            )
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        do {
            _ = try await transport.send(FetchUsersRequest())
            XCTFail("Expected RemoteFailure.invalidStatus after retry exhaustion")
        } catch let failure as RemoteFailure {
            guard case .invalidStatus(let code, _, _) = failure else {
                return XCTFail("Unexpected failure: \(failure)")
            }
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let callCount = session.callCount(forPath: "/users")
        // ExponentialBackoffRetryPolicy is configured with maxRetries: 2 in
        // RemoteClientFactory, so the coordinator makes 1 initial attempt
        // followed by up to 2 retries.
        XCTAssertEqual(callCount, 3, "should run 1 initial + 2 retries before giving up")
    }

    func testClientErrorIsNotRetried() async {
        let session = MockURLSession(sequences: [
            "/users": [.init(statusCode: 404)]
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        do {
            _ = try await transport.send(FetchUsersRequest())
            XCTFail("Expected RemoteFailure.invalidStatus for 404")
        } catch let failure as RemoteFailure {
            guard case .invalidStatus(let code, _, _) = failure else {
                return XCTFail("Unexpected failure: \(failure)")
            }
            XCTAssertEqual(code, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let callCount = session.callCount(forPath: "/users")
        XCTAssertEqual(callCount, 1, "4xx other than 408/429 must not consume retry budget")
    }

    func testDecodingFailureMapsToRemoteFailureDecoding() async {
        let malformedJSON = Data("{ not valid json".utf8)
        let session = MockURLSession(sequences: [
            "/users": [.init(statusCode: 200, data: malformedJSON)]
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        do {
            _ = try await transport.send(FetchUsersRequest())
            XCTFail("Expected RemoteFailure.decoding")
        } catch let failure as RemoteFailure {
            guard case .decoding(_, _, let request) = failure else {
                return XCTFail("Unexpected failure: \(failure)")
            }
            XCTAssertEqual(request?.url?.path, "/users")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let callCount = session.callCount(forPath: "/users")
        XCTAssertEqual(callCount, 1, "decoding failures must not trigger retry")
    }

    func testRetryAppliesRemoteMetadataHeadersOnEveryAttempt() async throws {
        let session = MockURLSession(sequences: [
            "/users": [
                .init(statusCode: 500),
                .init(statusCode: 200, data: Self.usersFixture),
            ]
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        _ = try await transport.send(FetchUsersRequest())

        let requests = session.requestsByPath["/users"] ?? []
        XCTAssertEqual(requests.count, 2)
        for request in requests {
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Sample-Feature"), "People")
            XCTAssertNil(request.value(forHTTPHeaderField: "X-Request-ID"))
            XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
            XCTAssertNotNil(request.value(forHTTPHeaderField: "User-Agent"))
        }
    }

    func testResponseCacheReusesStableMetadataHeaders() async throws {
        let session = MockURLSession(sequences: [
            "/users": [
                .init(
                    statusCode: 200,
                    data: Self.usersFixture,
                    headers: ["Cache-Control": "max-age=60"]
                )
            ]
        ])
        let cache = InMemoryResponseCache()
        let transport = RemoteClientFactory.makeTransport(
            baseURL: baseURL,
            session: session,
            responseCache: cache
        )

        _ = try await transport.send(FetchUsersRequest())
        _ = try await transport.send(FetchUsersRequest())

        let callCount = session.callCount(forPath: "/users")
        XCTAssertEqual(
            callCount,
            1,
            "stable public request headers should allow the second GET to hit response cache"
        )
    }

    func testAuthRequiredRequestAttachesBearerTokenAndRefreshesOn401() async throws {
        let tokenStore = RemoteTokenStore(initialToken: "init-token")
        let session = MockURLSession(sequences: [
            "/todos": [
                .init(statusCode: 401),
                .init(statusCode: 200, data: Self.todosFixture),
            ]
        ])
        let transport = RemoteClientFactory.makeTransport(
            baseURL: baseURL,
            session: session,
            tokenStore: tokenStore
        )

        let todos = try await transport.send(FetchTodosRequest())
        XCTAssertEqual(todos.count, 1)

        let callCount = session.callCount(forPath: "/todos")
        XCTAssertEqual(callCount, 2, "401 must trigger exactly one refresh + replay")

        let requests = session.requestsByPath["/todos"] ?? []
        XCTAssertEqual(requests[0].value(forHTTPHeaderField: "Authorization"), "Bearer init-token")
        XCTAssertEqual(requests[1].value(forHTTPHeaderField: "Authorization"), "Bearer innosample-demo-token-v2")

        let refreshCount = await tokenStore.refreshCount
        XCTAssertEqual(refreshCount, 1, "RefreshTokenCoordinator must invoke refresh exactly once")
    }

    func testConcurrentAuthRequiredRequestsCollapseRefreshIntoOneFlight() async throws {
        let tokenStore = RemoteTokenStore(initialToken: "init-token")
        // Both paths return 401 then 200 — concurrent requests should share
        // a single refresh task rather than each triggering its own.
        let session = MockURLSession(sequences: [
            "/todos": [
                .init(statusCode: 401),
                .init(statusCode: 200, data: Self.todosFixture),
                .init(statusCode: 200, data: Self.todosFixture),
            ],
        ])
        let transport = RemoteClientFactory.makeTransport(
            baseURL: baseURL,
            session: session,
            tokenStore: tokenStore
        )

        async let first = try transport.send(FetchTodosRequest())
        async let second = try transport.send(FetchTodosRequest())
        _ = try await (first, second)

        let refreshCount = await tokenStore.refreshCount
        XCTAssertEqual(refreshCount, 1, "Single-flight: two waiters must share one refresh task")
    }

    func testHeadersUseTypedSampleFeatureName() async throws {
        let session = MockURLSession(sequences: [
            "/users": [.init(statusCode: 200, data: Self.usersFixture)]
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        _ = try await transport.send(FetchUsersRequest())

        let requests = session.requestsByPath["/users"] ?? []
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "X-Sample-Feature"), "People")
        XCTAssertEqual(
            HTTPHeaderName<SingleValueHeader>.sampleFeature.rawValue,
            "X-Sample-Feature",
            "Typed name must agree with the wire-format header"
        )
    }

    func testRetryAfterHintIsHonoredOn503() async throws {
        // 503 + `Retry-After: 1` exercises the RFC 9110 §10.2.3 honor path:
        // `ExponentialBackoffRetryPolicy.shouldRetry` parses the hint and
        // returns `.retryAfter(1)`, which the coordinator clamps to
        // `maxRetryAfterDelay` (1.5s here). We assert behavior — the
        // hinted retry succeeds — rather than timing, because the
        // coordinator's transport observation overhead is comparable to
        // the hint itself and would make wall-clock assertions flaky.
        let session = MockURLSession(sequences: [
            "/users": [
                .init(statusCode: 503, headers: ["Retry-After": "1"]),
                .init(statusCode: 200, data: Self.usersFixture),
            ]
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        _ = try await transport.send(FetchUsersRequest())

        let callCount = session.callCount(forPath: "/users")
        XCTAssertEqual(callCount, 2)
    }

    func testPostWithoutIdempotencyKeyIsNotRetriedEvenOnRetryableStatus() async {
        let session = MockURLSession(sequences: [
            "/todos": Array(
                repeating: MockURLSessionResponse(statusCode: 503),
                count: 4
            )
        ])
        let transport = RemoteClientFactory.makeTransport(baseURL: baseURL, session: session)

        do {
            _ = try await transport.send(CreateTodoRequest())
            XCTFail("Expected failure on 503")
        } catch let failure as RemoteFailure {
            guard case .invalidStatus(let code, _, _) = failure else {
                return XCTFail("Unexpected failure: \(failure)")
            }
            XCTAssertEqual(code, 503)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let callCount = session.callCount(forPath: "/todos")
        XCTAssertEqual(
            callCount,
            1,
            "POST without Idempotency-Key must not consume retry budget per RFC 9110 idempotency policy"
        )
    }

    private static let todosFixture = Data(
        """
        [
          {
            "id": 1,
            "userId": 1,
            "title": "Wire auth refresh",
            "completed": false
          }
        ]
        """.utf8
    )

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

private struct EmptyAck: Decodable, Sendable {}

@APIDefinition(method: .post, path: "/todos", auth: .required)
private struct CreateTodoRequest: RemoteRequest {
    typealias APIResponse = EmptyAck

    var featureName: String { "Settings" }
}
