import Foundation

public protocol SongRepository: Sendable {
    func searchSongs(query: String, offset: Int, limit: Int) async throws -> [Song]
    func getRecentlyPlayed() async throws -> [Song]
    func saveRecentlyPlayed(_ song: Song) async throws
    func getSongsForAlbum(id: Int) async throws -> [Song]
    func getAlbum(id: Int) async throws -> Album?
}
