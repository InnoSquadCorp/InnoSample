import SwiftUI

public struct SampleLoadingStateView: View {
    private let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

public struct SampleErrorStateView: View {
    private let title: String
    private let message: String
    private let retryTitle: String
    private let retry: () -> Void

    public init(
        title: String,
        message: String,
        retryTitle: String = "Retry",
        retry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.retry = retry
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 34))
            Text(title)
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(retryTitle, action: retry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

public struct SampleMetricCard: View {
    private let title: String
    private let value: String
    private let subtitle: String
    private let tint: Color

    public init(
        title: String,
        value: String,
        subtitle: String,
        tint: Color = .accentColor
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.tint = tint
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.bold))
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}

public struct SampleStatusPill: View {
    private let text: String
    private let tint: Color

    public init(text: String, tint: Color) {
        self.text = text
        self.tint = tint
    }

    public var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.15), in: Capsule())
            .foregroundStyle(tint)
    }
}
