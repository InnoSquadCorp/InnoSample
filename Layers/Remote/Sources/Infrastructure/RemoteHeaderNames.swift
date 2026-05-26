import InnoNetwork

/// Typed `HTTPHeaderName` extensions for InnoSample's custom request
/// headers. Routing single-value headers through `HTTPHeaderName<SingleValueHeader>`
/// (instead of raw `headers.update(name:value:)`) keeps interceptors and
/// retry passes from accidentally accumulating duplicates and gives the
/// call site a compile-time check that the right header variant is used.
extension HTTPHeaderName where Variant == SingleValueHeader {
    static var sampleFeature: HTTPHeaderName<SingleValueHeader> { .init("X-Sample-Feature") }
}
