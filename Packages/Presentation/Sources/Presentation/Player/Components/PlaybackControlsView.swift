import SwiftUI

struct PlayButtonBackground: View {
    var body: some View {
        ZStack {
            // Base escura
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.9),
                            Color.gray.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Brilho (efeito glossy)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .blendMode(.overlay)

            // Borda leve
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        }
        .frame(width: 72, height: 72)
        .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

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
        HStack(spacing: 28) {
            // Previous track button
            Button(action: onSkipBackward) {
                Image("ic-skip", bundle: .module)
                    .scaleEffect(x: -1, y: 1)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .accessibilityLabel("Previous track")

            // Play/Pause button
            Button(action: onPlayPause) {
                ZStack {
                    PlayButtonBackground()

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
                Image("ic-skip", bundle: .module)
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
