public protocol PostRemoteDataSourceProtocol: Sendable {
    func fetchPosts() async throws -> [PostRemoteModel]
}
