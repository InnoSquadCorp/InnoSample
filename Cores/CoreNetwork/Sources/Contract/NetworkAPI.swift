import Foundation
import InnoNetwork

protocol NetworkAPI: SingleRequestExecutable {
    var apiDefaults: APIDefaults { get }
}

extension NetworkAPI {
    var logger: NetworkLogger { apiDefaults.logger }
    var requestInterceptors: [RequestInterceptor] { apiDefaults.requestInterceptors }
    var responseInterceptors: [ResponseInterceptor] { apiDefaults.responseInterceptors }
}
