import Foundation
import Domain
import Core

public final class SongRepositoryImpl: SongRepository, @unchecked Sendable {
    private let remoteDataSource: iTunesDataSourceProtocol
    private let localDataSource: any LocalDataSource

    public init(
        remoteDataSource: iTunesDataSourceProtocol,
        localDataSource: any LocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    public func searchSongs(query: String, offset: Int, limit: Int) async throws -> [Song] {
        let response = try await remoteDataSource.searchSongs(term: query, offset: offset, limit: limit)
        return SongMapper.map(response.results)
    }

    public func getRecentlyPlayed() async throws -> [Song] {
        try await localDataSource.getRecentlyPlayed()
    }

    public func saveRecentlyPlayed(_ song: Song) async throws {
        try await localDataSource.saveRecentlyPlayed(song)
    }

    public func getSongsForAlbum(id: Int) async throws -> [Song] {
        let response = try await remoteDataSource.lookupAlbum(id: id)
        return SongMapper.mapLookupResults(response.results)
            .sorted { ($0.discNumber ?? 0, $0.trackNumber ?? 0) < ($1.discNumber ?? 0, $1.trackNumber ?? 0) }
    }

    public func getAlbum(id: Int) async throws -> Album? {
        let response = try await remoteDataSource.lookupAlbum(id: id)
        return response.results.compactMap { AlbumMapper.map($0) }.first
    }
}
