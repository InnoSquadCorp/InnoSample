import Foundation
import InnoNetwork
import OSLog

struct NetworkStatusInterceptor: ResponseInterceptor {
    private let logger = Logger(subsystem: "com.innosquad.InnoSample", category: "CoreNetwork")

    init() {}

    func adapt(_ urlResponse: Response, request: URLRequest) async throws -> Response {
        if urlResponse.statusCode == 429 || (500...599).contains(urlResponse.statusCode) {
            let url = request.url?.absoluteString ?? "unknown"
            logger.warning("server-side retry candidate for \(url, privacy: .public) status \(urlResponse.statusCode)")
        }
        return urlResponse
    }
}
