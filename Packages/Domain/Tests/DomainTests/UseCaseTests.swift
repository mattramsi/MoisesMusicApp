import XCTest
@testable import Domain

final class UseCaseTests: XCTestCase {

    // MARK: - SearchSongsUseCase Tests

    func testSearchSongsUseCaseReturnsResults() async throws {
        let mockRepo = MockSongRepository()
        mockRepo.searchSongsResult = .success(Song.mockList)
        let useCase = SearchSongsUseCase(repository: mockRepo)

        let results = try await useCase.execute(query: "Queen", offset: 0, limit: 25)

        XCTAssertEqual(results.count, Song.mockList.count)
        XCTAssertEqual(mockRepo.searchSongsCallCount, 1)
        XCTAssertEqual(mockRepo.lastSearchQuery, "Queen")
    }

    func testSearchSongsUseCaseReturnsEmptyForEmptyQuery() async throws {
        let mockRepo = MockSongRepository()
        mockRepo.searchSongsResult = .success(Song.mockList)
        let useCase = SearchSongsUseCase(repository: mockRepo)

        let results = try await useCase.execute(query: "", offset: 0, limit: 25)

        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(mockRepo.searchSongsCallCount, 0)
    }

    func testSearchSongsUseCaseReturnsEmptyForWhitespaceQuery() async throws {
        let mockRepo = MockSongRepository()
        let useCase = SearchSongsUseCase(repository: mockRepo)

        let results = try await useCase.execute(query: "   ", offset: 0, limit: 25)

        XCTAssertTrue(results.isEmpty)
        XCTAssertEqual(mockRepo.searchSongsCallCount, 0)
    }

    // MARK: - GetRecentlyPlayedUseCase Tests

    func testGetRecentlyPlayedUseCaseReturnsResults() async throws {
        let mockRepo = MockSongRepository()
        mockRepo.recentlyPlayedResult = .success(Song.mockList)
        let useCase = GetRecentlyPlayedUseCase(repository: mockRepo)

        let results = try await useCase.execute()

        XCTAssertEqual(results.count, Song.mockList.count)
    }

    func testGetRecentlyPlayedUseCaseHandlesEmptyList() async throws {
        let mockRepo = MockSongRepository()
        mockRepo.recentlyPlayedResult = .success([])
        let useCase = GetRecentlyPlayedUseCase(repository: mockRepo)

        let results = try await useCase.execute()

        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - SaveRecentlyPlayedUseCase Tests

    func testSaveRecentlyPlayedUseCaseSavesSong() async throws {
        let mockRepo = MockSongRepository()
        let useCase = SaveRecentlyPlayedUseCase(repository: mockRepo)

        try await useCase.execute(Song.mock)

        XCTAssertEqual(mockRepo.saveRecentlyPlayedCallCount, 1)
        XCTAssertEqual(mockRepo.lastSavedSong?.id, Song.mock.id)
    }

    // MARK: - GetAlbumSongsUseCase Tests

    func testGetAlbumSongsUseCaseReturnsAlbumAndSongs() async throws {
        let mockRepo = MockSongRepository()
        mockRepo.albumResult = .success(.mock)
        mockRepo.albumSongsResult = .success(Song.mockList)
        let useCase = GetAlbumSongsUseCase(repository: mockRepo)

        let result = try await useCase.execute(albumId: 100)

        XCTAssertNotNil(result.album)
        XCTAssertEqual(result.songs.count, Song.mockList.count)
    }
}
