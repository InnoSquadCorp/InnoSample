import CoreNetwork
import Data

struct FetchUsersRequest: RequestDefinition {
    typealias ResponseBody = [UserRemoteModel]

    let featureName = "People"
    var path: String { "/users" }
    var headerPolicy: HeaderPolicy { .external }
}
