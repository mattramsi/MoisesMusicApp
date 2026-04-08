import SwiftUI
import Domain
import Presentation

public struct RootView: View {
    @EnvironmentObject private var container: AppDependencyContainer
    @State private var showSplash = true
    @State private var selectedSong: Song?
    @State private var selectedAlbumId: Int?
    @State private var navigationPath = NavigationPath()

    public init() {}

    public var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }

    private var mainContent: some View {
        NavigationStack(path: $navigationPath) {
            SongsView(
                viewModel: container.makeSongsViewModel(),
                onSongTap: { song in
                    selectedSong = song
                },
                onViewAlbum: { albumId in
                    selectedAlbumId = albumId
                    navigationPath.append(NavigationDestination.album(albumId))
                }
            )
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .album(let albumId):
                    AlbumView(
                        viewModel: container.makeAlbumViewModel(albumId: albumId),
                        onSongTap: { song in
                            selectedSong = song
                        }
                    )
                }
            }
        }
        .fullScreenCover(item: $selectedSong) { song in
            PlayerView(
                viewModel: container.makePlayerViewModel(song: song),
                onViewAlbum: {
                    if let albumId = song.collectionId {
                        selectedSong = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigationPath.append(NavigationDestination.album(albumId))
                        }
                    }
                }
            )
        }
        .tint(AppColors.accent)
    }
}

enum NavigationDestination: Hashable {
    case album(Int)
}

#Preview {
    RootView()
        .environmentObject(AppDependencyContainer())
}
