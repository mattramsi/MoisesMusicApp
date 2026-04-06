import SwiftUI

public struct PlaybackControlsView: View {
    let isPlaying: Bool
    let isLoading: Bool
    let onPlayPause: () -> Void
    let onSkipBackward: () -> Void
    let onSkipForward: () -> Void

    public init(
        isPlaying: Bool,
        isLoading: Bool,
        onPlayPause: @escaping () -> Void,
        onSkipBackward: @escaping () -> Void,
        onSkipForward: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        self.isLoading = isLoading
        self.onPlayPause = onPlayPause
        self.onSkipBackward = onSkipBackward
        self.onSkipForward = onSkipForward
    }

    public var body: some View {
        HStack(spacing: AppSpacing.xxl) {
            // Skip backward button
            Button(action: onSkipBackward) {
                Image(systemName: "gobackward.15")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Skip backward 15 seconds")

            // Play/Pause button
            Button(action: onPlayPause) {
                ZStack {
                    if isLoading {
                        ProgressView()
                            .tint(AppColors.primaryText)
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(AppColors.primaryText)
                    }
                }
                .frame(width: 72, height: 72)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            // Skip forward button
            Button(action: onSkipForward) {
                Image(systemName: "goforward.15")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Skip forward 15 seconds")
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        PlaybackControlsView(
            isPlaying: false,
            isLoading: false,
            onPlayPause: {},
            onSkipBackward: {},
            onSkipForward: {}
        )

        PlaybackControlsView(
            isPlaying: true,
            isLoading: false,
            onPlayPause: {},
            onSkipBackward: {},
            onSkipForward: {}
        )

        PlaybackControlsView(
            isPlaying: false,
            isLoading: true,
            onPlayPause: {},
            onSkipBackward: {},
            onSkipForward: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
