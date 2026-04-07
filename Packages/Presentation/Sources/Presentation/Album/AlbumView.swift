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

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(message: error)
            } else {
                contentView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.primaryText)
                }
            }
        }
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
