import Foundation

public enum HeaderPolicy: String, Sendable {
    /// Applies the environment's default app metadata headers.
    case appDefault
    /// Applies only the reduced header set suitable for external domains.
    case external
    /// Skips environment-provided headers and keeps only request-provided headers.
    ///
    /// `NetworkMetadataInterceptor` still injects `X-Request-ID` so requests remain traceable.
    case custom
}
