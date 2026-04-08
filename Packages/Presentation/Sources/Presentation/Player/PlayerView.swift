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
                
                artworkView
                    .padding(.top, 100)

                songInfo
                    .frame(height: 66)
                    .padding(.top, 116)

                progressView
                    .frame(height: 45)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.top, AppSpacing.xl)

                controlsView
                    .frame(height: 72)
                    .padding(.top, AppSpacing.lg)
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
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image("ic-back", bundle: .module)
                .resizable()
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("back button")
    }
    
    private var moreButton: some View {
        Button {
            viewModel.onMoreTapped()
        } label: {
            Image("ic-more", bundle: .module)
                .resizable()
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("more button")
    }

    private var navigationBar: some View {
        HStack {
            backButton

            Spacer()

            Text(viewModel.song.collectionName)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)

            Spacer()

            moreButton
        }
        .frame(height: 50)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.sm)
    }

    private var artworkView: some View {
        AsyncImageView(
            url: viewModel.song.artworkUrl600,
            size: 264,
            cornerRadius: 32
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

                HStack {
                    Text(viewModel.song.artistName)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    repeatButton
                }
            }
        }
        .padding(.horizontal, AppSpacing.xl)
    }

    var repeatButton: some View {
        Button {
            viewModel.toggleRepeat()
        } label: {
            Image("ic-repeat", bundle: .module)
                .renderingMode(.template)
                .foregroundStyle(viewModel.isRepeatEnabled ? AppColors.accent : AppColors.primaryText)
        }
        .buttonStyle(.plain)
        .tint(AppColors.primaryText)
        .padding(.top, AppSpacing.xxs)
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
