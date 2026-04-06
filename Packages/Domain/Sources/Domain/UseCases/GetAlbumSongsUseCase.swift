import Foundation

public struct GetAlbumSongsUseCase: Sendable {
    private let repository: SongRepository

    public init(repository: SongRepository) {
        self.repository = repository
    }

    public func execute(albumId: Int) async throws -> (album: Album?, songs: [Song]) {
        async let album = repository.getAlbum(id: albumId)
        async let songs = repository.getSongsForAlbum(id: albumId)

        return try await (album, songs)
    }
}
