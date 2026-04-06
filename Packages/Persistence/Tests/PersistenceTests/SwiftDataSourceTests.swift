import XCTest
import SwiftData
@testable import Persistence
@testable import Domain

final class SwiftDataSourceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var dataSource: SwiftDataSource!

    @MainActor
    override func setUp() async throws {
        modelContainer = try ModelContainer.createInMemory()
        dataSource = SwiftDataSource(modelContainer: modelContainer)
    }

    override func tearDown() async throws {
        modelContainer = nil
        dataSource = nil
    }

    func testSaveAndRetrieveRecentlyPlayed() async throws {
        let song = Song.mock

        try await dataSource.saveRecentlyPlayed(song)
        let retrieved = try await dataSource.getRecentlyPlayed()

        XCTAssertEqual(retrieved.count, 1)
        XCTAssertEqual(retrieved.first?.id, song.id)
        XCTAssertEqual(retrieved.first?.trackName, song.trackName)
    }

    func testRecentlyPlayedUpdatesTimestamp() async throws {
        let song = Song.mock

        try await dataSource.saveRecentlyPlayed(song)
        try await Task.sleep(for: .milliseconds(100))
        try await dataSource.saveRecentlyPlayed(song)

        let retrieved = try await dataSource.getRecentlyPlayed()

        XCTAssertEqual(retrieved.count, 1) // Should not duplicate
    }

    func testRecentlyPlayedOrderedByMostRecent() async throws {
        let song1 = Song(
            id: 1,
            trackName: "Song 1",
            artistName: "Artist",
            collectionName: "Album",
            artworkUrl100: "https://example.com/art.jpg",
            trackTimeMillis: 180000
        )

        let song2 = Song(
            id: 2,
            trackName: "Song 2",
            artistName: "Artist",
            collectionName: "Album",
            artworkUrl100: "https://example.com/art.jpg",
            trackTimeMillis: 180000
        )

        try await dataSource.saveRecentlyPlayed(song1)
        try await Task.sleep(for: .milliseconds(100))
        try await dataSource.saveRecentlyPlayed(song2)

        let retrieved = try await dataSource.getRecentlyPlayed()

        XCTAssertEqual(retrieved.count, 2)
        XCTAssertEqual(retrieved.first?.id, song2.id) // Most recent first
    }

    func testRecentlyPlayedLimitedTo20() async throws {
        // Save 25 songs
        for i in 1...25 {
            let song = Song(
                id: i,
                trackName: "Song \(i)",
                artistName: "Artist",
                collectionName: "Album",
                artworkUrl100: "https://example.com/art.jpg",
                trackTimeMillis: 180000
            )
            try await dataSource.saveRecentlyPlayed(song)
            try await Task.sleep(for: .milliseconds(50))
        }

        let retrieved = try await dataSource.getRecentlyPlayed()

        XCTAssertEqual(retrieved.count, 20) // Limited to 20
    }
}
