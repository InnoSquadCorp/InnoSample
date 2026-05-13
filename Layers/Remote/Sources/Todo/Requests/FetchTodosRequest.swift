import Data

struct FetchTodosRequest: RemoteRequest {
    typealias APIResponse = [TodoRemoteModel]

    let featureName = "Settings"
    let path = "/todos"
}
