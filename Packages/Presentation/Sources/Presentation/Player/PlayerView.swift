import SwiftUI
import Domain

public struct PlayerView: View {
    @Bindable var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    var onViewAlbum: () -> Void

    public init(viewModel: PlayerViewModel, onViewAlbum: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onViewAlbum = onViewAlbum
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                Spacer()

                artworkView

                songInfo
                    .padding(.top, 116)

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
        .sheet(isPresented: $viewModel.showActionSheet) {
            SongActionSheet(
                song: viewModel.song,
                onViewAlbum: {
                    viewModel.showActionSheet = false
                    onViewAlbum()
                },
                onDismiss: {
                    viewModel.showActionSheet = false
                }
            )
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.hidden)
        }
    }

    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    // Top-leading arc
                    Circle()
                        .trim(from: 0.55, to: 0.95)
                        .stroke(AppColors.primaryText.opacity(0.3), lineWidth: 1)
                    // Bottom-trailing arc
                    Circle()
                        .trim(from: 0.05, to: 0.45)
                        .stroke(AppColors.primaryText.opacity(0.3), lineWidth: 1)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(AppColors.primaryText)
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close player")

            Spacer()

            Text(viewModel.song.collectionName)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)

            Spacer()

            Button {
                viewModel.onMoreTapped()
            } label: {
                ZStack {
                    // Top-leading arc
                    Circle()
                        .trim(from: 0.55, to: 0.95)
                        .stroke(AppColors.primaryText.opacity(0.3), lineWidth: 1)
                    // Bottom-trailing arc
                    Circle()
                        .trim(from: 0.05, to: 0.45)
                        .stroke(AppColors.primaryText.opacity(0.3), lineWidth: 1)

                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(AppColors.primaryText)
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("More options")
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.sm)
    }

    private var artworkView: some View {
        AsyncImageView(
            url: viewModel.song.artworkUrl600,
            size: 264,
            cornerRadius: AppSpacing.cornerRadiusLarge
        )
    }

    private var songInfo: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
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
            }

            Spacer()

            Button {
                viewModel.toggleRepeat()
            } label: {
                Image(systemName: "repeat")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(viewModel.isRepeatEnabled ? AppColors.accent : AppColors.secondaryText)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.top, AppSpacing.xxs)
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
    PlayerView(viewModel: .preview(isPlaying: true, currentTime: 45, duration: 90), onViewAlbum: {})
}

#Preview("Paused") {
    PlayerView(viewModel: .preview(isPlaying: false, currentTime: 30, duration: 90), onViewAlbum: {})
}
