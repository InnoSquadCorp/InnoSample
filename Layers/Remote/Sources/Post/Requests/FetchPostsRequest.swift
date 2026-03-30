import CoreNetwork
import Data

struct FetchPostsRequest: RequestDefinition {
    typealias ResponseBody = [PostRemoteModel]

    let featureName = "Posts"
    var path: String { "/posts" }
    var headerPolicy: HeaderPolicy { .external }
}
