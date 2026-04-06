import SwiftUI
import Domain

public struct SongsView: View {
    @Bindable var viewModel: SongsViewModel
    var onSongTap: (Song) -> Void
    var onViewAlbum: (Int) -> Void

    @State private var selectedSong: Song?
    @State private var showActionSheet = false

    public init(
        viewModel: SongsViewModel,
        onSongTap: @escaping (Song) -> Void,
        onViewAlbum: @escaping (Int) -> Void
    ) {
        self.viewModel = viewModel
        self.onSongTap = onSongTap
        self.onViewAlbum = onViewAlbum
    }

    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                searchBar
                contentView
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .sheet(isPresented: $showActionSheet) {
            if let song = selectedSong {
                SongActionSheet(
                    song: song,
                    onViewAlbum: {
                        if let albumId = song.collectionId {
                            onViewAlbum(albumId)
                        }
                    },
                    onDismiss: { showActionSheet = false }
                )
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.hidden)
                .presentationBackground(AppColors.cardBackground)
            }
        }
    }

    private var headerView: some View {
        Text("Search")
            .appLargeTitle()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.sm)
    }

    private var searchBar: some View {
        SearchBarView(
            text: $viewModel.searchQuery,
            placeholder: "Songs, artists, albums...",
            onSubmit: { viewModel.search() }
        )
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.bottom, AppSpacing.sm)
        .onChange(of: viewModel.searchQuery) { _, newValue in
            if newValue.isEmpty {
                viewModel.search()
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .loading:
            loadingView

        case .error(let message):
            errorView(message: message)

        case .empty:
            emptySearchView

        default:
            if viewModel.showRecentlyPlayed {
                recentlyPlayedView
            } else if viewModel.showEmptyRecentlyPlayed {
                emptyRecentlyPlayedView
            } else if !viewModel.songs.isEmpty {
                searchResultsView
            } else {
                emptyRecentlyPlayedView
            }
        }
    }

    private var loadingView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { _ in
                    SongRowSkeletonView()
                }
            }
        }
        .scrollDisabled(true)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.accentRed)

            Text("Something went wrong")
                .appHeadline()

            Text(message)
                .appSubheadline()
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.search()
            }
            .buttonStyle(.bordered)
            .tint(AppColors.accent)
        }
        .padding(AppSpacing.xl)
        .frame(maxHeight: .infinity)
    }

    private var emptySearchView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.secondaryText)

            Text("No results found")
                .appHeadline()

            Text("Try searching for something else")
                .appSubheadline()
        }
        .padding(AppSpacing.xl)
        .frame(maxHeight: .infinity)
    }

    private var emptyRecentlyPlayedView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "music.note")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.secondaryText)

            Text("Search for music")
                .appHeadline()

            Text("Find your favorite songs and artists")
                .appSubheadline()
        }
        .padding(AppSpacing.xl)
        .frame(maxHeight: .infinity)
    }

    private var recentlyPlayedView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text("Recently Played")
                    .appHeadline()
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .padding(.vertical, AppSpacing.sm)

                ForEach(viewModel.recentlyPlayed) { song in
                    SongRowView(
                        song: song,
                        onTap: { onSongTap(song) },
                        onLongPress: {
                            selectedSong = song
                            showActionSheet = true
                        }
                    )
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.songs) { song in
                    SongRowView(
                        song: song,
                        onTap: { onSongTap(song) },
                        onLongPress: {
                            selectedSong = song
                            showActionSheet = true
                        }
                    )
                    .onAppear {
                        if song == viewModel.songs.last {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                }

                if viewModel.state == .loadingMore {
                    ProgressView()
                        .tint(AppColors.accent)
                        .padding(AppSpacing.lg)
                }
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview("With Recently Played") {
    SongsView(
        viewModel: .preview(recentlyPlayed: Song.mockList),
        onSongTap: { _ in },
        onViewAlbum: { _ in }
    )
}

#Preview("Empty State") {
    SongsView(
        viewModel: .preview(),
        onSongTap: { _ in },
        onViewAlbum: { _ in }
    )
}

#Preview("Loading") {
    SongsView(
        viewModel: .preview(state: .loading),
        onSongTap: { _ in },
        onViewAlbum: { _ in }
    )
}

#Preview("Search Results") {
    SongsView(
        viewModel: .preview(songs: Song.mockList, state: .loaded, searchQuery: "Queen"),
        onSongTap: { _ in },
        onViewAlbum: { _ in }
    )
}
