import Foundation

/// In-memory bearer-token store wired into `RemoteClientFactory`'s
/// `RefreshTokenPolicy`. JSONPlaceholder ignores the `Authorization`
/// header, so the values here only need to be stable and distinguishable
/// between the initial token and a post-refresh token — they exist so
/// the sample's auth pipeline (single-flight refresh + replay) is
/// observable end-to-end and so unit tests can verify rotation.
///
/// Production apps replace this actor with their real session/Keychain
/// store while keeping the `RefreshTokenPolicy` closures unchanged.
actor RemoteTokenStore {
    private var currentToken: String
    private(set) var refreshCount: Int = 0

    init(initialToken: String = "innosample-demo-token-v1") {
        self.currentToken = initialToken
    }

    func token() -> String {
        currentToken
    }

    @discardableResult
    func rotateToken() -> String {
        refreshCount += 1
        currentToken = "innosample-demo-token-v\(refreshCount + 1)"
        return currentToken
    }
}
