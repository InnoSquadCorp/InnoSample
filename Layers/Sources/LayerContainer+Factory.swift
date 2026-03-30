import CoreNetwork

public extension LayerContainer {
    static func make(networkTransport: NetworkTransport) -> LayerContainer {
        LayerContainer(networkTransport: networkTransport)
    }
}
