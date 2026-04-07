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
            // Previous track button
            Button(action: onSkipBackward) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Previous track")

            // Play/Pause button
            Button(action: onPlayPause) {
                ZStack {
                    Circle()
                        .fill(AppColors.secondaryBackground)
                        .frame(width: 80, height: 80)

                    if isLoading {
                        ProgressView()
                            .tint(AppColors.primaryText)
                            .scaleEffect(1.5)
                    } else {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(AppColors.primaryText)
                            .offset(x: isPlaying ? 0 : 2)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

            // Next track button
            Button(action: onSkipForward) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Next track")
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
