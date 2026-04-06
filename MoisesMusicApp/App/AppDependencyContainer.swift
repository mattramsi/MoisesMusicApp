import SwiftUI
import SwiftData
import Core
import Domain
import Data
import Persistence
import Presentation

@MainActor
public final class AppDependencyContainer: ObservableObject {
    // MARK: - Model Container

    let modelContainer: ModelContainer

    // MARK: - Core

    private lazy var httpClient: HTTPClient = URLSessionHTTPClient()
    private lazy var audioPlayer: AudioPlayerService = AudioPlayerServiceImpl()

    // MARK: - Data Sources

    private lazy var iTunesRemoteDataSource: iTunesDataSourceProtocol = iTunesDataSource(httpClient: httpClient)
    private lazy var swiftDataSource: LocalDataSource = {
        SwiftDataSourceAdapter(modelContainer: modelContainer)
    }()

    // MARK: - Repositories

    private lazy var songRepository: SongRepository = SongRepositoryImpl(
        remoteDataSource: iTunesRemoteDataSource,
        localDataSource: swiftDataSource
    )

    // MARK: - Use Cases

    private lazy var searchSongsUseCase: SearchSongsUseCase = SearchSongsUseCase(repository: songRepository)
    private lazy var getRecentlyPlayedUseCase: GetRecentlyPlayedUseCase = GetRecentlyPlayedUseCase(repository: songRepository)
    private lazy var saveRecentlyPlayedUseCase: SaveRecentlyPlayedUseCase = SaveRecentlyPlayedUseCase(repository: songRepository)
    private lazy var getAlbumSongsUseCase: GetAlbumSongsUseCase = GetAlbumSongsUseCase(repository: songRepository)

    // MARK: - Init

    public init() {
        do {
            modelContainer = try ModelContainer.create()
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    // MARK: - View Model Factories

    func makeSongsViewModel() -> SongsViewModel {
        SongsViewModel(
            searchSongsUseCase: searchSongsUseCase,
            getRecentlyPlayedUseCase: getRecentlyPlayedUseCase
        )
    }

    func makePlayerViewModel(song: Song) -> PlayerViewModel {
        PlayerViewModel(
            song: song,
            audioPlayer: audioPlayer,
            saveRecentlyPlayedUseCase: saveRecentlyPlayedUseCase
        )
    }

    func makeAlbumViewModel(albumId: Int) -> AlbumViewModel {
        AlbumViewModel(
            albumId: albumId,
            getAlbumSongsUseCase: getAlbumSongsUseCase
        )
    }
}

// MARK: - SwiftData Adapter

@MainActor
private final class SwiftDataSourceAdapter: LocalDataSource {
    private let dataSource: SwiftDataSource

    init(modelContainer: ModelContainer) {
        self.dataSource = SwiftDataSource(modelContainer: modelContainer)
    }

    nonisolated func getRecentlyPlayed() async throws -> [Song] {
        try await dataSource.getRecentlyPlayed()
    }

    nonisolated func saveRecentlyPlayed(_ song: Song) async throws {
        try await dataSource.saveRecentlyPlayed(song)
    }
}
