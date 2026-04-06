import Foundation
import Domain
import Observation

@Observable
@MainActor
public final class AlbumViewModel {
    public private(set) var album: Album?
    public private(set) var songs: [Song] = []
    public private(set) var isLoading = true
    public private(set) var error: String?

    private let albumId: Int
    private let getAlbumSongsUseCase: GetAlbumSongsUseCase

    public init(albumId: Int, getAlbumSongsUseCase: GetAlbumSongsUseCase) {
        self.albumId = albumId
        self.getAlbumSongsUseCase = getAlbumSongsUseCase
    }

    public func onAppear() async {
        do {
            let result = try await getAlbumSongsUseCase.execute(albumId: albumId)
            album = result.album
            songs = result.songs
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    public var totalDuration: String {
        let totalMillis = songs.reduce(0) { $0 + $1.trackTimeMillis }
        let totalMinutes = totalMillis / 60000
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return "\(hours) hr \(minutes) min"
        }
        return "\(totalMinutes) min"
    }
}

// MARK: - Preview Support

public extension AlbumViewModel {
    static func preview(
        album: Album? = .mock,
        songs: [Song] = Song.mockList,
        isLoading: Bool = false
    ) -> AlbumViewModel {
        let viewModel = AlbumViewModel(
            albumId: 100,
            getAlbumSongsUseCase: GetAlbumSongsUseCase(repository: PreviewSongRepository())
        )
        viewModel.album = album
        viewModel.songs = songs
        viewModel.isLoading = isLoading
        return viewModel
    }
}

private final class PreviewSongRepository: SongRepository, @unchecked Sendable {
    func searchSongs(query: String, offset: Int, limit: Int) async throws -> [Song] { [] }
    func getRecentlyPlayed() async throws -> [Song] { [] }
    func saveRecentlyPlayed(_ song: Song) async throws {}
    func getSongsForAlbum(id: Int) async throws -> [Song] { Song.mockList }
    func getAlbum(id: Int) async throws -> Album? { .mock }
}
