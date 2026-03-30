public protocol RemoteDataSourceContaining {
    var userRemoteDataSource: any UserRemoteDataSourceProtocol { get }
    var postRemoteDataSource: any PostRemoteDataSourceProtocol { get }
    var todoRemoteDataSource: any TodoRemoteDataSourceProtocol { get }
}
