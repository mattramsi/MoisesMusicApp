import SwiftUI
import Domain

public struct AlbumView: View {
    @Bindable var viewModel: AlbumViewModel
    @Environment(\.dismiss) private var dismiss
    var onSongTap: (Song) -> Void

    public init(viewModel: AlbumViewModel, onSongTap: @escaping (Song) -> Void) {
        self.viewModel = viewModel
        self.onSongTap = onSongTap
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(message: error)
                } else {
                    contentView
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.onAppear()
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .tint(AppColors.accent)
                .scaleEffect(1.5)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.accentRed)

            Text("Failed to load album")
                .appHeadline()

            Text(message)
                .appSubheadline()
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }

    private var navigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image("ic-back", bundle: .main)
                    .resizable()
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

            Spacer()

            if let album = viewModel.album {
                Text(album.collectionName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
            }

            Spacer()

            // Empty spacer to balance the back button
            Color.clear
                .frame(width: 48, height: 48)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.sm)
    }

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 40) {
                albumHeader

                songsList
            }
        }
    }

    private var albumHeader: some View {
        VStack(spacing: AppSpacing.md) {
            if let album = viewModel.album {
                AsyncImageView(
                    url: album.artworkUrl600,
                    size: 120,
                    cornerRadius: AppSpacing.cornerRadiusMedium
                )

                VStack(spacing: AppSpacing.xxs) {
                    Text(album.collectionName)
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text(album.artistName)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.lg)
    }

    private var songsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.songs) { song in
                SongRowView(
                    song: song,
                    onTap: { onSongTap(song) },
                    showMoreButton: false
                )
            }
        }
    }
}

#Preview("Album View") {
    NavigationStack {
        AlbumView(
            viewModel: .preview(),
            onSongTap: { _ in }
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        AlbumView(
            viewModel: .preview(isLoading: true),
            onSongTap: { _ in }
        )
    }
}
