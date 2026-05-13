import Data

struct FetchPostsRequest: RemoteRequest {
    typealias APIResponse = [PostRemoteModel]

    let featureName = "Posts"
    let path = "/posts"
}
