import Foundation
import InnoNetwork
import OSLog

struct RemoteStatusInterceptor: ResponseInterceptor {
    private let logger = Logger(subsystem: "com.innosquad.InnoSample", category: "Remote")

    func adapt(_ urlResponse: Response, request: URLRequest) async throws -> Response {
        if urlResponse.statusCode == 429 || (500...599).contains(urlResponse.statusCode) {
            logger.warning("server-side retry candidate status \(urlResponse.statusCode)")
        }
        return urlResponse
    }
}
