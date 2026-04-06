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
            VStack(spacing: 0) {
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
                    size: 200,
                    cornerRadius: AppSpacing.cornerRadiusMedium
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)

                VStack(spacing: AppSpacing.xxs) {
                    Text(album.collectionName)
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text(album.artistName)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.accent)

                    HStack(spacing: AppSpacing.xs) {
                        if let genre = album.primaryGenreName {
                            Text(genre)
                        }

                        if let year = album.releaseYear {
                            Text("•")
                            Text(year)
                        }
                    }
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryText)

                    Text("\(viewModel.songs.count) songs, \(viewModel.totalDuration)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.tertiaryText)
                        .padding(.top, AppSpacing.xxs)
                }
            }
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.lg)
    }

    private var songsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(viewModel.songs.enumerated()), id: \.element.id) { index, song in
                AlbumSongRow(
                    trackNumber: song.trackNumber ?? (index + 1),
                    song: song,
                    onTap: { onSongTap(song) }
                )
            }
        }
    }
}

struct AlbumSongRow: View {
    let trackNumber: Int
    let song: Song
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.sm) {
                Text("\(trackNumber)")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.tertiaryText)
                    .frame(width: 24, alignment: .center)

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Text(song.trackName)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)

                        if song.isExplicit {
                            ExplicitBadge()
                        }
                    }

                    if song.artistName != (song.collectionName.isEmpty ? "" : song.artistName) {
                        Text(song.artistName)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text(song.formattedDuration)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
