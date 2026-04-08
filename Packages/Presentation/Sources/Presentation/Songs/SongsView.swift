import SwiftUI
import Domain

public struct SongsView: View {
    @Bindable var viewModel: SongsViewModel
    var onSongTap: (Song) -> Void
    var onViewAlbum: (Int) -> Void

    @State private var selectedSongForSheet: Song?
    @State private var scrollOffset: CGFloat = 0
    @State private var shouldScrollToTop = false
    @State private var initialTopOffset: CGFloat?

    // MARK: - Header Height Constants
    private let collapsedHeaderHeight: CGFloat = 44
    private let expandedHeaderHeight: CGFloat = 68 // SearchBar + paddings

    private var isCollapsed: Bool {
        scrollOffset > expandedHeaderHeight - collapsedHeaderHeight
    }

    private var headerOpacity: Double {
        let fadeEnd = expandedHeaderHeight - collapsedHeaderHeight

        if scrollOffset <= 0 {
            return 1
        } else if scrollOffset >= fadeEnd {
            return 0
        } else {
            return Double(1 - scrollOffset / fadeEnd)
        }
    }

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
        
        VStack(spacing: 0) {
            ZStack {
                shortHeader
                    .opacity(isCollapsed ? 1 : 0)

                longHeader
                    .opacity(isCollapsed ? 0 : 1)
            }
            .animation(.easeInOut(duration: 0.25), value: isCollapsed)

            ScrollView {
                VStack(spacing: 0) {
                   
                    
                    searchTextField
                        .opacity(headerOpacity)

                    contentView
                }
                .background(scrollOffsetReader)
                .background(
                    ScrollToTopView(
                        shouldScroll: shouldScrollToTop,
                        initialTopOffset: $initialTopOffset,
                        isCollapsed: isCollapsed,
                        onScrollComplete: { shouldScrollToTop = false }
                    )
                )
            }
            .coordinateSpace(name: "scroll")
            .refreshable {
                await viewModel.refresh()
            }
            .background(AppColors.background)
            .onChange(of: viewModel.searchQuery) { _, newValue in
                viewModel.onSearchQueryChanged(newValue)
            }
            .task {
                await viewModel.onAppear()
            }
            .sheet(item: $selectedSongForSheet) { song in
                SongActionSheet(
                    song: song,
                    onViewAlbum: {
                        if let albumId = song.collectionId {
                            selectedSongForSheet = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onViewAlbum(albumId)
                            }
                        }
                    },
                    onDismiss: { selectedSongForSheet = nil }
                )
                .presentationDetents([.height(180)])
                .presentationDragIndicator(.visible)
                .presentationBackground(AppColors.cardBackground)
            }
        }
    }

    var searchButton: some View {
        Button {
            shouldScrollToTop = true
        } label: {
            Image("ic-search", bundle: .module)
                .resizable()
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("search button")
    }
    
    var shortHeader: some View {
        HStack {
            searchButton

            Spacer()

            Text("Songs")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            // Invisible spacer to balance the search button
            Color.clear
                .frame(width: 48, height: 48)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .opacity(1 - headerOpacity)
    }

    var longHeader: some View {
        HStack {
            Text("Songs")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)

            Spacer()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.md)
        .opacity(headerOpacity)
        .frame(height: 48)
        .padding(.top, 20)
    }
    // MARK: - Expanded Header

    private var searchTextField: some View {
        SearchBarView(
            text: $viewModel.searchQuery,
            placeholder: "Search",
            onSubmit: { viewModel.search() }
        )
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.sm)
    }

    // MARK: - Scroll Offset Reader

    private var scrollOffsetReader: some View {
        GeometryReader { geo in
            Color.clear.preference(
                key: ScrollOffsetPreferenceKey.self,
                value: -geo.frame(in: .named("scroll")).minY
            )
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = max(0, value)
        }
    }

    // MARK: - Content Views

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
                recentlyPlayedContent
            } else if viewModel.showEmptyRecentlyPlayed {
                emptyRecentlyPlayedView
            } else if !viewModel.songs.isEmpty {
                searchResultsContent
            } else {
                emptyRecentlyPlayedView
            }
        }
    }

    private var loadingView: some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<10, id: \.self) { _ in
                SongRowSkeletonView()
            }
        }
        .padding(.top, AppSpacing.xs)
        .padding(.leading, AppSpacing.xl)
        .padding(.trailing, AppSpacing.screenPadding)
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

    private var recentlyPlayedContent: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.recentlyPlayed) { song in
                SongRowView(
                    song: song,
                    onTap: { onSongTap(song) },
                    onLongPress: {
                        selectedSongForSheet = song
                    }
                )
            }
        }
        .padding(.top, AppSpacing.xs)
        .padding(.leading, AppSpacing.xl)
        .padding(.trailing, AppSpacing.screenPadding)
    }

    private var searchResultsContent: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.songs) { song in
                SongRowView(
                    song: song,
                    onTap: { onSongTap(song) },
                    onLongPress: {
                        selectedSongForSheet = song
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
        .padding(.top, AppSpacing.xs)
        .padding(.leading, AppSpacing.xl)
        .padding(.trailing, AppSpacing.screenPadding)
    }
}

// MARK: - Scroll Offset Preference Key

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Scroll To Top Helper

private struct ScrollToTopView: UIViewRepresentable {
    let shouldScroll: Bool
    @Binding var initialTopOffset: CGFloat?
    let isCollapsed: Bool
    let onScrollComplete: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let scrollView = findScrollView(in: uiView) else { return }

            // Capture initial offset when not collapsed and we haven't stored it yet
            if initialTopOffset == nil && !isCollapsed {
                initialTopOffset = scrollView.contentOffset.y
                print("📍 Captured initialTopOffset: \(scrollView.contentOffset.y)")
            }

            // Scroll to top when requested
            if shouldScroll, let targetY = initialTopOffset {
                let targetOffset = CGPoint(x: 0, y: targetY)
                print("🔍 ScrollToTop - targetOffset: \(targetOffset)")
                scrollView.setContentOffset(targetOffset, animated: true)
                onScrollComplete()
            }
        }
    }

    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        var superview = view.superview
        while let current = superview {
            if let scrollView = current as? UIScrollView {
                return scrollView
            }
            superview = current.superview
        }
        return nil
    }
}

// MARK: - Previews

#Preview("With Recently Played") {
    NavigationStack {
        SongsView(
            viewModel: .preview(recentlyPlayed: Song.mockList),
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    NavigationStack {
        SongsView(
            viewModel: .preview(),
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Loading") {
    NavigationStack {
        SongsView(
            viewModel: .preview(state: .loading),
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Search Results") {
    NavigationStack {
        SongsView(
            viewModel: .preview(songs: Song.mockList, state: .loaded, searchQuery: "Queen"),
            onSongTap: { _ in },
            onViewAlbum: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
