import XCTest
@testable import Presentation
@testable import Domain

@MainActor
final class SongsViewModelTests: XCTestCase {

    func testInitialState() {
        let viewModel = SongsViewModel(
            searchSongsUseCase: MockSearchSongsUseCase(),
            getRecentlyPlayedUseCase: MockGetRecentlyPlayedUseCase()
        )

        XCTAssertTrue(viewModel.songs.isEmpty)
        XCTAssertTrue(viewModel.recentlyPlayed.isEmpty)
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertTrue(viewModel.searchQuery.isEmpty)
    }

    func testSearchWithEmptyQueryClearsSongs() {
        let viewModel = SongsViewModel(
            searchSongsUseCase: MockSearchSongsUseCase(),
            getRecentlyPlayedUseCase: MockGetRecentlyPlayedUseCase()
        )

        viewModel.searchQuery = ""
        viewModel.search()

        XCTAssertTrue(viewModel.songs.isEmpty)
        XCTAssertEqual(viewModel.state, .idle)
    }

    func testSearchWithQueryUpdatesSongs() async throws {
        let mockSearchUseCase = MockSearchSongsUseCase()
        mockSearchUseCase.result = Song.mockList
        let viewModel = SongsViewModel(
            searchSongsUseCase: mockSearchUseCase,
            getRecentlyPlayedUseCase: MockGetRecentlyPlayedUseCase()
        )

        viewModel.searchQuery = "Queen"
        viewModel.search()

        // Wait for async task
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertEqual(viewModel.songs.count, Song.mockList.count)
        XCTAssertEqual(viewModel.state, .loaded)
    }

    func testSearchWithNoResultsShowsEmptyState() async throws {
        let mockSearchUseCase = MockSearchSongsUseCase()
        mockSearchUseCase.result = []
        let viewModel = SongsViewModel(
            searchSongsUseCase: mockSearchUseCase,
            getRecentlyPlayedUseCase: MockGetRecentlyPlayedUseCase()
        )

        viewModel.searchQuery = "nonexistent"
        viewModel.search()

        try await Task.sleep(for: .milliseconds(100))

        XCTAssertTrue(viewModel.songs.isEmpty)
        XCTAssertEqual(viewModel.state, .empty)
    }

    func testOnAppearLoadsRecentlyPlayed() async throws {
        let mockGetRecentlyPlayedUseCase = MockGetRecentlyPlayedUseCase()
        mockGetRecentlyPlayedUseCase.result = Song.mockList
        let viewModel = SongsViewModel(
            searchSongsUseCase: MockSearchSongsUseCase(),
            getRecentlyPlayedUseCase: mockGetRecentlyPlayedUseCase
        )

        await viewModel.onAppear()

        XCTAssertEqual(viewModel.recentlyPlayed.count, Song.mockList.count)
    }

    func testShowRecentlyPlayedWhenNoSearch() async throws {
        let mockGetRecentlyPlayedUseCase = MockGetRecentlyPlayedUseCase()
        mockGetRecentlyPlayedUseCase.result = Song.mockList
        let viewModel = SongsViewModel(
            searchSongsUseCase: MockSearchSongsUseCase(),
            getRecentlyPlayedUseCase: mockGetRecentlyPlayedUseCase
        )

        await viewModel.onAppear()

        XCTAssertTrue(viewModel.showRecentlyPlayed)
    }

    func testHideRecentlyPlayedWhenSearching() async throws {
        let mockGetRecentlyPlayedUseCase = MockGetRecentlyPlayedUseCase()
        mockGetRecentlyPlayedUseCase.result = Song.mockList
        let viewModel = SongsViewModel(
            searchSongsUseCase: MockSearchSongsUseCase(),
            getRecentlyPlayedUseCase: mockGetRecentlyPlayedUseCase
        )

        await viewModel.onAppear()
        viewModel.searchQuery = "test"

        XCTAssertFalse(viewModel.showRecentlyPlayed)
    }
}

// MARK: - Mocks

final class MockSearchSongsUseCase: SearchSongsUseCaseProtocol, @unchecked Sendable {
    var result: [Song] = []
    var error: Error?

    func execute(query: String, offset: Int, limit: Int) async throws -> [Song] {
        if let error = error {
            throw error
        }
        return result
    }
}

final class MockGetRecentlyPlayedUseCase: GetRecentlyPlayedUseCaseProtocol, @unchecked Sendable {
    var result: [Song] = []
    var error: Error?

    func execute() async throws -> [Song] {
        if let error = error {
            throw error
        }
        return result
    }
}
