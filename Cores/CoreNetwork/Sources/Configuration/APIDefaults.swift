import Foundation
import InnoNetwork

struct APIDefaults: Sendable {
    let environment: NetworkEnvironment
    let logger: NetworkLogger
    let requestInterceptors: [RequestInterceptor]
    let responseInterceptors: [ResponseInterceptor]
}
