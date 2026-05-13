import Data

struct FetchUsersRequest: RemoteRequest {
    typealias APIResponse = [UserRemoteModel]

    let featureName = "People"
    let path = "/users"
}
