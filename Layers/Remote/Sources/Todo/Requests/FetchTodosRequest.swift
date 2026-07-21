import Data
import InnoNetwork

@APIDefinition(method: .get, path: "/todos", auth: .required)
struct FetchTodosRequest: RemoteRequest {
    typealias APIResponse = [TodoRemoteModel]

    var featureName: String { "Settings" }
}
