import Foundation

public extension LayerContainer {
    static func make(baseURL: URL) -> LayerContainer {
        LayerContainer(baseURL: baseURL)
    }
}
