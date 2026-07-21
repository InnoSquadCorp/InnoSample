import InnoRouter
import SwiftUI

/// Command-only macro router. Its generated resolver admits exact app origins;
/// the tab bridge translates the result into a tab selection and leaf route.
@Router(
    deepLinkSchemes: ["innosample"],
    deepLinkHosts: ["host"]
)
public enum SampleDeepLink {
    @DeepLink("/people/:userID")
    case peopleDetail(userID: Int)

    @DeepLink("/settings/:assigneeID")
    case settingsDetail(assigneeID: Int)

    public var destination: some View {
        EmptyView()
    }
}
