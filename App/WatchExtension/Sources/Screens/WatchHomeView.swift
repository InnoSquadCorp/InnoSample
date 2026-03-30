import SwiftUI

struct WatchHomeView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "applewatch.watchface")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.tint)

            Text("InnoSample Watch")
                .font(.headline)

            Text("Installed as a companion to the iPhone app.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
