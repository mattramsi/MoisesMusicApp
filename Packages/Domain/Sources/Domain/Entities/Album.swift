import Foundation

public struct Album: Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let collectionName: String
    public let artistName: String
    public let artworkUrl100: String
    public let trackCount: Int
    public let releaseDate: Date?
    public let primaryGenreName: String?
    public let copyright: String?

    public init(
        id: Int,
        collectionName: String,
        artistName: String,
        artworkUrl100: String,
        trackCount: Int,
        releaseDate: Date? = nil,
        primaryGenreName: String? = nil,
        copyright: String? = nil
    ) {
        self.id = id
        self.collectionName = collectionName
        self.artistName = artistName
        self.artworkUrl100 = artworkUrl100
        self.trackCount = trackCount
        self.releaseDate = releaseDate
        self.primaryGenreName = primaryGenreName
        self.copyright = copyright
    }

    public var artworkUrl600: String {
        artworkUrl100.replacingOccurrences(of: "100x100", with: "600x600")
    }

    public var releaseYear: String? {
        guard let date = releaseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

public extension Album {
    static let mock = Album(
        id: 100,
        collectionName: "A Night at the Opera",
        artistName: "Queen",
        artworkUrl100: "https://example.com/album.jpg",
        trackCount: 12,
        releaseDate: Date(),
        primaryGenreName: "Rock",
        copyright: "© 1975 Hollywood Records"
    )
}
