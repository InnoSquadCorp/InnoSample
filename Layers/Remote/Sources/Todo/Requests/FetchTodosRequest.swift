import Data
import InnoNetwork

struct FetchTodosRequest: RemoteRequest {
    typealias APIResponse = [TodoRemoteModel]
    typealias Auth = AuthRequiredScope

    let featureName = "Settings"
    let path = "/todos"
}
