import Data
import InnoNetwork

@APIDefinition(method: .get, path: "/posts", auth: .anonymous)
struct FetchPostsRequest: RemoteRequest {
    typealias APIResponse = [PostRemoteModel]

    var featureName: String { "Posts" }
}
