import Foundation
import InnoRouter

/// Builds the canonical `DeepLinkMatcher<SampleDeepLink>` for InnoSample.
///
/// Scheme validation lives outside the matcher: the matcher only inspects
/// path + query, and the caller (`EntireTabCoordinator.handleDeepLink`)
/// gates on `innosample://` before forwarding. Keeping scheme acceptance at
/// the caller side mirrors the InnoRouter `DeepLinkPipeline` factoring and
/// keeps this matcher reusable from tests that pass URLs without a scheme.
public enum SampleDeepLinkMatcherFactory {
    public static let allowedScheme = "innosample"

    public static func make() -> DeepLinkMatcher<SampleDeepLink> {
        DeepLinkMatcher<SampleDeepLink> {
            DeepLinkMapping("/people/:id") { params in
                guard
                    let raw = params.firstValue(forName: "id"),
                    let id = Int(raw)
                else { return nil }
                return .peopleDetail(userID: id)
            }
            DeepLinkMapping("/settings/:id") { params in
                guard
                    let raw = params.firstValue(forName: "id"),
                    let id = Int(raw)
                else { return nil }
                return .settingsDetail(assigneeID: id)
            }
        }
    }
}
