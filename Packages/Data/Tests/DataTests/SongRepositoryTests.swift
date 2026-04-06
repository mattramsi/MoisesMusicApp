import XCTest
@testable import Data
@testable import Domain
@testable import Core

final class SongRepositoryTests: XCTestCase {

    // MARK: - SearchSongs Tests

    func testSearchSongsReturnsResults() async throws {
        let mockDataSource = MockiTunesDataSource()
        let mockLocalDataSource = MockLocalDataSource()
        let repository = SongRepositoryImpl(
            remoteDataSource: mockDataSource,
            localDataSource: mockLocalDataSource
        )

        mockDataSource.searchResponse = iTunesSearchResponse(
            resultCount: 2,
            results: [
                iTunesTrackDTO(
                    trackId: 1,
                    trackName: "Test Song",
                    artistName: "Test Artist",
                    collectionName: "Test Album",
                    artworkUrl100: "https://example.com/art.jpg",
                    previewUrl: nil,
                    trackTimeMillis: 240000,
                    collectionId: 100,
                    trackNumber: 1,
                    discNumber: 1,
                    releaseDate: nil,
                    primaryGenreName: "Rock",
                    trackExplicitness: nil,
                    wrapperType: "track",
                    kind: "song"
                ),
                iTunesTrackDTO(
                    trackId: 2,
                    trackName: "Test Song 2",
                    artistName: "Test Artist",
                    collectionName: "Test Album",
                    artworkUrl100: "https://example.com/art2.jpg",
                    previewUrl: nil,
                    trackTimeMillis: 180000,
                    collectionId: 100,
                    trackNumber: 2,
                    discNumber: 1,
                    releaseDate: nil,
                    primaryGenreName: "Rock",
                    trackExplicitness: nil,
                    wrapperType: "track",
                    kind: "song"
                )
            ]
        )

        let results = try await repository.searchSongs(query: "test", offset: 0, limit: 25)

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].trackName, "Test Song")
        XCTAssertEqual(results[1].trackName, "Test Song 2")
    }

    func testSearchSongsFiltersInvalidResults() async throws {
        let mockDataSource = MockiTunesDataSource()
        let mockLocalDataSource = MockLocalDataSource()
        let repository = SongRepositoryImpl(
            remoteDataSource: mockDataSource,
            localDataSource: mockLocalDataSource
        )

        mockDataSource.searchResponse = iTunesSearchResponse(
            resultCount: 2,
            results: [
                iTunesTrackDTO(
                    trackId: 1,
                    trackName: "Valid Song",
                    artistName: "Artist",
                    collectionName: "Album",
                    artworkUrl100: "https://example.com/art.jpg",
                    previewUrl: nil,
                    trackTimeMillis: 240000,
                    collectionId: nil,
                    trackNumber: nil,
                    discNumber: nil,
                    releaseDate: nil,
                    primaryGenreName: nil,
                    trackExplicitness: nil,
                    wrapperType: nil,
                    kind: nil
                ),
                iTunesTrackDTO(
                    trackId: nil, // Invalid - no ID
                    trackName: nil,
                    artistName: nil,
                    collectionName: nil,
                    artworkUrl100: nil,
                    previewUrl: nil,
                    trackTimeMillis: nil,
                    collectionId: nil,
                    trackNumber: nil,
                    discNumber: nil,
                    releaseDate: nil,
                    primaryGenreName: nil,
                    trackExplicitness: nil,
                    wrapperType: nil,
                    kind: nil
                )
            ]
        )

        let results = try await repository.searchSongs(query: "test", offset: 0, limit: 25)

        XCTAssertEqual(results.count, 1)
    }
}

// MARK: - Mocks

final class MockiTunesDataSource: iTunesDataSourceProtocol, @unchecked Sendable {
    var searchResponse = iTunesSearchResponse(resultCount: 0, results: [])
    var lookupResponse = iTunesLookupResponse(resultCount: 0, results: [])

    func searchSongs(term: String, offset: Int, limit: Int) async throws -> iTunesSearchResponse {
        searchResponse
    }

    func lookupAlbum(id: Int) async throws -> iTunesLookupResponse {
        lookupResponse
    }
}

final class MockLocalDataSource: LocalDataSource, @unchecked Sendable {
    var recentlyPlayed: [Song] = []

    func getRecentlyPlayed() async throws -> [Song] {
        recentlyPlayed
    }

    func saveRecentlyPlayed(_ song: Song) async throws {
        recentlyPlayed.insert(song, at: 0)
    }
}
