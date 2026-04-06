import Foundation
@testable import Domain

public final class MockSongRepository: SongRepository, @unchecked Sendable {
    public var searchSongsResult: Result<[Song], Error> = .success([])
    public var recentlyPlayedResult: Result<[Song], Error> = .success([])
    public var albumResult: Result<Album?, Error> = .success(nil)
    public var albumSongsResult: Result<[Song], Error> = .success([])

    public var searchSongsCallCount = 0
    public var lastSearchQuery: String?
    public var saveRecentlyPlayedCallCount = 0
    public var lastSavedSong: Song?

    public init() {}

    public func searchSongs(query: String, offset: Int, limit: Int) async throws -> [Song] {
        searchSongsCallCount += 1
        lastSearchQuery = query
        return try searchSongsResult.get()
    }

    public func getRecentlyPlayed() async throws -> [Song] {
        return try recentlyPlayedResult.get()
    }

    public func saveRecentlyPlayed(_ song: Song) async throws {
        saveRecentlyPlayedCallCount += 1
        lastSavedSong = song
    }

    public func getSongsForAlbum(id: Int) async throws -> [Song] {
        return try albumSongsResult.get()
    }

    public func getAlbum(id: Int) async throws -> Album? {
        return try albumResult.get()
    }
}
