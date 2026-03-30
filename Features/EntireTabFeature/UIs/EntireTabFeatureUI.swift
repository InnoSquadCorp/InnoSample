import EntireTabFeatureInterface
import SwiftUI

public struct EntireTabBackgroundView: View {
    let selectedTab: SampleTab

    public init(selectedTab: SampleTab) {
        self.selectedTab = selectedTab
    }

    public var body: some View {
        Color.clear
            .accessibilityIdentifier("tab-\(selectedTab.rawValue)")
    }
}
