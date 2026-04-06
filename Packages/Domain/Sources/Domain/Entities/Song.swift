import Foundation

public struct Song: Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let trackName: String
    public let artistName: String
    public let collectionName: String
    public let artworkUrl100: String
    public let previewUrl: String?
    public let trackTimeMillis: Int
    public let collectionId: Int?
    public let trackNumber: Int?
    public let discNumber: Int?
    public let releaseDate: Date?
    public let primaryGenreName: String?
    public let isExplicit: Bool

    public init(
        id: Int,
        trackName: String,
        artistName: String,
        collectionName: String,
        artworkUrl100: String,
        previewUrl: String? = nil,
        trackTimeMillis: Int,
        collectionId: Int? = nil,
        trackNumber: Int? = nil,
        discNumber: Int? = nil,
        releaseDate: Date? = nil,
        primaryGenreName: String? = nil,
        isExplicit: Bool = false
    ) {
        self.id = id
        self.trackName = trackName
        self.artistName = artistName
        self.collectionName = collectionName
        self.artworkUrl100 = artworkUrl100
        self.previewUrl = previewUrl
        self.trackTimeMillis = trackTimeMillis
        self.collectionId = collectionId
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.isExplicit = isExplicit
    }

    public var artworkUrl600: String {
        artworkUrl100.replacingOccurrences(of: "100x100", with: "600x600")
    }

    public var formattedDuration: String {
        let totalSeconds = trackTimeMillis / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

public extension Song {
    static let mock = Song(
        id: 1,
        trackName: "Bohemian Rhapsody",
        artistName: "Queen",
        collectionName: "A Night at the Opera",
        artworkUrl100: "https://example.com/artwork.jpg",
        previewUrl: "https://example.com/preview.m4a",
        trackTimeMillis: 354000,
        collectionId: 100,
        trackNumber: 11,
        discNumber: 1,
        releaseDate: Date(),
        primaryGenreName: "Rock",
        isExplicit: false
    )

    static let mockList: [Song] = [
        .mock,
        Song(
            id: 2,
            trackName: "Don't Stop Me Now",
            artistName: "Queen",
            collectionName: "Jazz",
            artworkUrl100: "https://example.com/artwork2.jpg",
            previewUrl: "https://example.com/preview2.m4a",
            trackTimeMillis: 210000,
            collectionId: 101,
            trackNumber: 12,
            discNumber: 1,
            releaseDate: Date(),
            primaryGenreName: "Rock",
            isExplicit: false
        ),
        Song(
            id: 3,
            trackName: "We Will Rock You",
            artistName: "Queen",
            collectionName: "News of the World",
            artworkUrl100: "https://example.com/artwork3.jpg",
            previewUrl: "https://example.com/preview3.m4a",
            trackTimeMillis: 122000,
            collectionId: 102,
            trackNumber: 1,
            discNumber: 1,
            releaseDate: Date(),
            primaryGenreName: "Rock",
            isExplicit: false
        )
    ]
}
