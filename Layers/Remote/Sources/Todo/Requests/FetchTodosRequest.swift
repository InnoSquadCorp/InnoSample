import CoreNetwork
import Data

struct FetchTodosRequest: RequestDefinition {
    typealias ResponseBody = [TodoRemoteModel]

    let featureName = "Settings"
    var path: String { "/todos" }
    var headerPolicy: HeaderPolicy { .external }
}
