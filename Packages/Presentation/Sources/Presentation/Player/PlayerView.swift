import SwiftUI
import Domain

public struct PlayerView: View {
    @Bindable var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: PlayerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                Spacer()

                artworkView

                songInfo
                    .padding(.top, AppSpacing.xxl)

                progressView
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, AppSpacing.xl)

                controlsView
                    .padding(.top, AppSpacing.xl)

                Spacer()
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close player")

            Spacer()

            Text("Now Playing")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.sm)
    }

    private var artworkView: some View {
        AsyncImageView(
            url: viewModel.song.artworkUrl600,
            size: AppSpacing.artworkSizePlayer,
            cornerRadius: AppSpacing.cornerRadiusLarge
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }

    private var songInfo: some View {
        VStack(spacing: AppSpacing.xxs) {
            HStack(spacing: AppSpacing.xxs) {
                Text(viewModel.song.trackName)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                if viewModel.song.isExplicit {
                    ExplicitBadge()
                }
            }

            Text(viewModel.song.artistName)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)

            Text(viewModel.song.collectionName)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.tertiaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, AppSpacing.xl)
    }

    private var progressView: some View {
        ProgressSliderView(
            currentTime: viewModel.formattedCurrentTime,
            duration: viewModel.formattedDuration,
            progress: .init(
                get: { viewModel.progress },
                set: { _ in }
            ),
            onSeek: { progress in
                let time = progress * viewModel.duration
                viewModel.seek(to: time)
            }
        )
    }

    private var controlsView: some View {
        PlaybackControlsView(
            isPlaying: viewModel.isPlaying,
            isLoading: viewModel.isLoading,
            onPlayPause: { viewModel.togglePlayPause() },
            onSkipBackward: { viewModel.skipBackward() },
            onSkipForward: { viewModel.skipForward() }
        )
    }
}

#Preview("Playing") {
    PlayerView(viewModel: .preview(isPlaying: true, currentTime: 45, duration: 90))
}

#Preview("Paused") {
    PlayerView(viewModel: .preview(isPlaying: false, currentTime: 30, duration: 90))
}
