import Foundation
import InnoNetwork
import OSLog

struct RemoteRequestLogger: NetworkLogger {
    private let baseLogger: DefaultNetworkLogger
    private let diagnosticLogger = Logger(subsystem: "com.innosquad.InnoSample", category: "Remote")

    init(options: NetworkLoggingOptions = .secureDefault) {
        self.baseLogger = DefaultNetworkLogger(options: options)
    }

    func log(request: URLRequest) {
        diagnosticLogger.debug("request \(request.httpMethod ?? "UNKNOWN", privacy: .public)")
        baseLogger.log(request: request)
    }

    func log(response: Response, isError: Bool) {
        diagnosticLogger.debug("response status \(response.statusCode) error=\(isError)")
        baseLogger.log(response: response, isError: isError)
    }

    func log(error: NetworkError) {
        diagnosticLogger.error("network error code=\(error.errorCode)")
        baseLogger.log(error: error)
    }
}
